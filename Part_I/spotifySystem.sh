# !/bin/bash

# Colors
GREEN="\e[1;32m"
BLUE="\e[1;34m"
RED="\e[1;31m"
WHITE="\e[1;38m"
RESET="\e[0m"

# Files
DATA_FILE="songs.data"
LOCK_FILE="lock.songs"

touch "$DATA_FILE"

# Functions
lock(){
 while [ -f "$LOCK_FILE" ]; do
  sleep 5
 done
 touch "$LOCK_FILE"
}

unlock(){
 rm -f "$LOCK_FILE"
}

capture(){
 echo -n "${WHITE}Song title: ${RESET}"; read title
 echo -n "${WHITE}Artist: ${RESET}"; read artist
 echo -n "${WHITE}Album: ${RESET}"; read album
 echo -n "${WHITE}Genre: ${RESET}"; read genre
 echo -n "${WHITE}Duration (in minutes): ${RESET}"; read duration
 echo -n "${WHITE}Release year: ${RESET}"; read year
}

exists(){
 echo ""
 echo -n "${WHITE}Song ID: ${RESET}"; read id
 record=$(awk -F: -v key="$id" '($1==key){print}' "$DATA_FILE")
}

add(){
 exists
 if [ -z "$record" ]; then
  capture
  lock
  echo "$id:$title:$artist:$album:$genre:$duration:$year" >> "$DATA_FILE"
  unlock
  echo "${BLUE}Song added successfully!${RESET}"
 else
  echo "${RED}The song ID $id already exists!${RESET}"
 fi
}

delete_id(){
 echo ""
 echo -n "${WHITE}Song ID to delete: ${RESET}"; read id
 record=$(awk -F: -v key="$id" '($1==key){print}' "$DATA_FILE")
 if [ -z "$record" ]; then
  echo "${RED}The song ID $id does not exists${RESET}"
 else
  echo ""
  echo "${WHITE}Record found: ${RESET}"
  echo "$record"
  echo ""
  echo -n "${WHITE}Do you want to delete this record? (y/n): ${RESET}"; read confirmation
  if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
   lock
   awk -F: -v key="$id" '($1!=key){print}' "$DATA_FILE" > tmp.$$
   mv -f tmp.$$ "$DATA_FILE"
   unlock
   echo "${BLUE}Song deletion completed successfully!${RESET}"
  else
   echo "${RED}Canceled operation${RESET}"
  fi
 fi
}

delete_general(){
 echo ""
 echo -n "${WHITE}Data to search (delete song): ${RESET}"; read data
 match=$(grep -i "$data" "$DATA_FILE")
 if [ -z "$match" ]; then
  echo "${RED}No matches were found for \"$data\"${RESET}"
 else
  echo "${WHITE}Matches found: ${RESET}"
  echo "$match"
  echo ""
  echo -n "${WHITE}Do you want to delete this records? (y/n): ${RESET}"; read confirmation
  if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
   lock
   grep -iv "$data" "$DATA_FILE" > tmp.$$
   mv -f tmp.$$ "$DATA_FILE"
   unlock
   echo "${BLUE}Records successfully deleted!${RESET}"
  else
   echo "${RED}Canceled operation${RESET}"
  fi
 fi
}

search_id(){
 echo ""
 echo -n "${WHITE}Song ID: ${RESET}"; read id
 result=$(awk -F: -v key="$id" '
  ($1==key){
   print "Song title: " $2
   print "Artist: " $3
   print "Album: " $4
   print "Genre: " $5
   print "Duration (in minutes): " $6
   print "Release year: " $7
   exists=1
  }
  END{
    if (!exists){
     print "Song ID not found!"
    }
  }
 ' "$DATA_FILE")
  echo "$result" | grep -q "Song ID not found!"
  if [ $? -eq 0 ]; then
   echo -n "${RED}Song ID not found!${RESET}"
   echo ""
  else
   echo "${WHITE}$result${RESET}"
  fi
}

search_general(){
 echo ""
 echo -n "${WHITE}Data to search: ${RESET}"; read data
 grep -i -n --color=always "$data" "$DATA_FILE" | less -R
}

edit_info(){
 exists
 if [ "$record" != "" ]
 then
  temp_title=$(echo "$record" | cut -d: -f2)
  temp_artist=$(echo "$record" | cut -d: -f3)
  temp_album=$(echo "$record" | cut -d: -f4)
  temp_genre=$(echo "$record" | cut -d: -f5)
  temp_duration=$(echo "$record" | cut -d: -f6)
  temp_year=$(echo "$record" | cut -d: -f7)
  echo "${WHITE}***Only capture the data you want to modify${RESET}"
  echo -n "${WHITE}Song title [$temp_title]: ${RESET}"; read title
  echo -n "${WHITE}Artist [$temp_artist]: ${RESET}"; read artist
  echo -n "${WHITE}Album [$temp_album]: ${RESET}"; read album
  echo -n "${WHITE}Genre [$temp_genre]: ${RESET}"; read genre
  echo -n "${WHITE}Duration (in minutes) [$temp_duration]: ${RESET}"; read duration
  echo -n "${WHITE}Release year [$temp_year]: ${RESET}"; read year
  lock
  awk -F: -v key="$id" \
          -v new_title="$title" \
          -v new_artist="$artist" \
          -v new_album="$album" \
          -v new_genre="$genre" \
          -v new_duration="$duration" \
          -v new_year="$year" '
  ($1!=key){print}
  ($1==key){
    if(new_title==""){new_title=$2}
    if(new_artist==""){new_artist=$3}
    if(new_album==""){new_album=$4}
    if(new_genre==""){new_genre=$5}
    if(new_duration==""){new_duration=$6}
    if(new_year==""){new_year=$7}
    print key":"new_title":"new_artist":"new_album":"new_genre":"new_duration":"new_year
  }
  ' "$DATA_FILE" > tmp.$$ \
    && mv -f tmp.$$ "$DATA_FILE"
  unlock
  echo "${BLUE}Modification saved for song with ID $id!${RESET}"
  else
   echo "${RED}The song ID $id does not exists!${RESET}"
  fi
}

genre_report(){
 echo ""
 echo -n "${WHITE}Enter the genre to search for: ${RESET}"; read genre
 genre=$(echo "$genre" | tr '[:upper:]' '[:lower:]' | xargs)
 count=0
 total_duration=0
 while IFS=: read -r id title artist album genre_field duration year; do
  if [ "$(echo "$genre_field" | tr '[:upper:]' '[:lower:]' | xargs)" = "$genre" ]; then
   count=$((count+1))
   total_duration=$(echo "$total_duration" + "$duration" | bc)
  fi
 done < "$DATA_FILE"
 if [ "$count" -eq 0 ]; then
  echo "${RED}There's no song of the \"$genre\" genre!${RESET}"
 else
  total_duration=$(echo "scale=2; $total_duration" | bc)
  echo ""
  echo "${BLUE}--- Genre Report: $genre ----${RESET}"
  echo "${WHITE}Total songs: ${RESET}$count"
  echo "${WHITE}Total duration: ${RESET}$total_duration minutes"
  echo "${BLUE}------------------------------${RESET}"
 fi
}

year_report(){
 echo ""
 echo -n "${WHITE}Enter the year to search for: ${RESET}"; read year
 year=$(echo "$year" | xargs)
 count=0
 while IFS=: read -r id title artist album genre duration year_field; do
  if [ "$(echo "$year_field" | xargs)" = "$year" ]; then
   count=$((count+1))
  fi
 done < "$DATA_FILE"
 if [ "$count" -eq 0 ]; then
  echo "${RED}There's no songs of the $year year!${RESET}"
 else
  echo ""
  echo "${BLUE}--- Year Report: $year ----${RESET}"
  echo "${WHITE}Total songs: ${RESET}$count"
  echo "${BLUE}------------------------------${RESET}"
 fi
}

artist_report(){
 echo ""
 echo -n "${WHITE}Enter the artist name to search for: ${RESET}"; read artist
 artist=$(echo "$artist" | tr '[:upper:]' '[:lower:]' | xargs)
 count=0
 titles=""
 while IFS=: read -r id title artist_field album genre duration year; do
  if [ "$(echo "$artist_field" | tr '[:upper:]' '[:lower:]' | xargs)" = "$artist" ]; then
   count=$((count+1))
   titles="$titles 
   - $title"
  fi
 done < "$DATA_FILE"
 if [ "$count" -eq 0 ]; then
  echo "${RED}No songs found for the artist \"$artist\"!${RESET}"
 else
  echo ""
  echo "${BLUE}--- Artist Report: $artist ----${RESET}"
  echo "${WHITE}Total songs: ${RESET}$count"
  echo "${WHITE}Song titles: ${RESET}"
  echo "$titles"
  echo "${BLUE}------------------------------${RESET}"
 fi
}

clear_terminal(){
 clear
}

menu(){
 echo ""
 echo "${WHITE}======== MENU ========${RESET}"
 echo "${WHITE}1) ${RESET}${GREEN}Add new song${RESET}"
 echo "${WHITE}2) ${RESET}${GREEN}Delete song by ID${RESET}"
 echo "${WHITE}3) ${RESET}${GREEN}Delete song by other field${RESET}"
 echo "${WHITE}4) ${RESET}${GREEN}Search song by ID${RESET}"
 echo "${WHITE}5) ${RESET}${GREEN}Search song by other field${RESET}"
 echo "${WHITE}6) ${RESET}${GREEN}Edit song information${RESET}"
 echo "${WHITE}7) ${RESET}${GREEN}Reports Submenu ${RESET}"
 echo "${WHITE}8) ${RESET}${GREEN}Clear terminal${RESET}"
 echo "${WHITE}E) ${RESET}${GREEN}Exit${RESET}"
 echo -n "${WHITE}Option: ${RESET}"; read option
 case "$option" in
  1) add ;;
  2) delete_id ;;
  3) delete_general ;;
  4) search_id ;;
  5) search_general ;;
  6) edit_info ;;
  7) echo ""
     echo "${WHITE}a) ${RESET}${GREEN}Songs by genre${RESET}"
     echo "${WHITE}b) ${RESET}${GREEN}Songs by year${RESET}"
     echo "${WHITE}c) ${RESET}${GREEN}Songs by artist${RESET}"
     echo -n "${WHITE}Report type: ${RESET}"; read type
     case "$type" in
      [Aa]) genre_report ;;
      [Bb]) year_report ;;
      [Cc]) artist_report ;;
      *) echo "${RED}Invalid report type!${RESET}" ;;
     esac
     ;;
  8) clear_terminal ;;
  [Ee]) echo ""
        echo "${WHITE}Goodbye User!${RESET}"
        sleep 0.5
        clear_terminal
        exit 0
        ;;
  *) echo "${RED}Invalid option!${RESET}" ;;
 esac
}

# Main code
option=0
echo ""
echo "${GREEN}¡WELCOME TO SPOTIFY'S SONG DATABASE!${RESET}"
while true; do
 menu
done
