#!/bin/bash

set -e

IDENTIFIER="$1"
final_id=""

# if identifier is less than or equal to 60, shorten
IDENTIFIER_LENGTH=${#IDENTIFIER}
if (( $IDENTIFIER_LENGTH < 60 )) ; then
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
      current_match_replace_length=$(expr $current_match_length - 2)
      
      current_replace="${current_match_first_character}${current_match_replace_length}${current_match_last_character}"

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
  echo "$final_id"
else
  echo "$IDENTIFIER"
fi