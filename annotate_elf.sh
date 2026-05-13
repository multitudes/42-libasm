#!/bin/bash
file=$1
xxd -g 1 -c 16 "$file" | while IFS= read -r line; do
  offset=$(echo "$line" | awk '{print $1}' | sed 's/:$//')
  offset_dec=$((16#$offset))
  
  section=""
  if [ "$offset_dec" -lt 64 ]; then
    section="[ELF HEADER]"
  elif [ "$offset_dec" -lt 384 ]; then
    section="[SECTION HEADERS]"
  elif [ "$offset_dec" -lt 400 ]; then
    section="[.text CODE]"
  elif [ "$offset_dec" -lt 432 ]; then
    section="[.shstrtab]"
  elif [ "$offset_dec" -lt 592 ]; then
    section="[.symtab]"
  elif [ "$offset_dec" -lt 658 ]; then
    section="[.strtab]"
  fi
  
  printf "%-70s %s\n" "$line" "$section"
done
