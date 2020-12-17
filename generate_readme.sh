echo "# Awesome Games You Can Play With ... [![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)"
echo ""
echo "These are awesome games you can play with various common items"
echo ""
echo "| Item |"
echo "|------|"
jq '.[]|"| [\(.Category)](#\(.Category|ascii_downcase|gsub(" ";"_"))) |"' games.json --raw-output
echo ""

xmls=$(curl "https://www.boardgamegeek.com/xmlapi2/thing?id=$(jq -c '.[].Games[].BggId' games.json | sort | uniq | paste -s -d ',')" | xq .)
jq -c .[] games.json | 
{
  while read category; do 
    categoryName=$(echo "$category" | jq '.Category' --raw-output)
    echo "## $categoryName"
    echo ""
    echo "| Game | # of Players | Playtime | Tags |"
    echo "|------|--------------|----------|------|"

    echo "$category" | jq -c '.Games[]' |
    {
      while read game; do
        gameId=$(echo "$game" | jq '.BggId' --raw-output)
        xml=$(echo "$xmls" | jq ".items.item[] | select(.\"@id\"==\"${gameId}\")")
        minPlayers=$(echo "$xml" | jq '.minplayers."@value"' --raw-output)
        maxPlayers=$(echo "$xml" | jq '.maxplayers."@value"' --raw-output)
        maxPlaytime=$(echo "$xml" | jq '.maxplaytime."@value"' --raw-output)
        minPlaytime=$(echo "$xml" | jq '.minplaytime."@value"' --raw-output)

        gameName=$(echo "$game" | jq '"[\(.Name)](https://www.boardgamegeek.com/boardgame/\(.BggId))"' --raw-output)
        players=$(if [ "$minPlayers" = "$maxPlayers" ]; then echo "$minPlayers"; else echo "$minPlayers - $maxPlayers"; fi)
        playtime=$(if [ "$minPlaytime" = "$maxPlaytime" ]; then echo "$minPlaytime"; else echo "$minPlaytime - $maxPlaytime"; fi)
        tags=$(echo "$xml" | jq '.link[] | select(."@type" == "boardgamemechanic" or ."@type" == "boardgamecategory") | ."@value" | sort' --raw-output | paste -s -d ',')
        echo "| $gameName | $players | $playtime | $tags |"
      done
    }
    echo ""
  done
}
