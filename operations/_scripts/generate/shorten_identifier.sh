#!/bin/bash

set -e

IDENTIFIER="$1"
final_id=""
MAX_IDENTIFIER_LENGTH=$2


if [ -z $MAX_IDENTIFIER_LENGTH ]; then
  MAX_IDENTIFIER_LENGTH=60
fi

# if identifier is less than or equal to 60, shorten
IDENTIFIER_LENGTH=${#IDENTIFIER}
if (( $IDENTIFIER_LENGTH < $MAX_IDENTIFIER_LENGTH )) ; then
  echo "$IDENTIFIER"
  exit 0
fi

re='^[-_]*([[:alnum:]]*).*'
if [[ $IDENTIFIER =~ $re ]]; then
  while [[ $IDENTIFIER =~ $re ]]; do
    if [ -z "${BASH_REMATCH[1]}" ]; then
      break;
    fi

    # echo "BASE_REMATCH[0]"
    # echo "${BASH_REMATCH[0]}"
    # echo "BASE_REMATCH[1]"
    # echo "${BASH_REMATCH[1]}"
    # echo "BASE_REMATCH[2]"
    # echo "${BASH_REMATCH[2]}"

    # echo "==="
    # echo "IDENTIFIER"
    # echo "$IDENTIFIER"

    for current_match in "${BASH_REMATCH[@]}"; do
      if [ "$current_match" == "$IDENTIFIER" ]; then
        continue;
      fi


      # echo "current_match"
      # echo $current_match

      # get first letter
      current_match_first_character=${current_match:0:1}
      # get last letter
      current_match_last_character=${current_match: -1}
      # gete match length
      current_match_length=${#current_match}
      
      if (( $current_match_length <= 3 )) ; then
        current_replace="${current_match}"
      else
        current_match_replace_length=$(expr $current_match_length - 2)
        current_replace="${current_match_first_character}${current_match_replace_length}${current_match_last_character}"
      fi
      # echo "current_match_first_character"
      # echo $current_match_first_character
      # echo "current_match_last_character"
      # echo $current_match_last_character
      # echo "current_replace"
      # echo $current_replace

      if [ -n "$final_id" ]; then
        final_id="${final_id}-${current_replace}"
      else
        final_id="${current_replace}"
      fi

      # replace BASE_REMATCH[1] in IDENTIFIER
      IDENTIFIER=$(echo ${IDENTIFIER} | sed -e "s/${BASH_REMATCH[1]}//")
    done
  done
  # If final length exceeds limit - get the firts part, last part, and create a hash in the middle
  if [ ${#final_id} -gt $MAX_IDENTIFIER_LENGTH ]; then
    max_length=$(( $MAX_IDENTIFIER_LENGTH - 8 ))
    part1=$(echo $final_id | cut -d "-" -f 1)
    part2=$(echo $final_id | cut -c 5- | rev | cut -c 5- | rev | md5sum | cut -c 1-$max_length)
    part3=$(echo $final_id | rev | cut -d "-" -f 1 | rev)
    final_id="$part1-$part2-$part3"
  fi
  echo "$final_id"
else
  echo "$IDENTIFIER"
fi
