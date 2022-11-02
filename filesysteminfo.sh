#!/usr/bin/env -S bash

## Styling

NC="\033[0m" # Color reset

# Normal (0;)
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

# Bold (1;)
BLACK_B="\033[1;30m"
RED_B="\033[1;31m"
GREEN_B="\033[1;32m"
YELLOW_B="\033[1;33m"
BLUE_B="\033[1;34m"
PURPLE_B="\033[1;35m"
CYAN_B="\033[1;36m"
WHITE_B="\033[1;37m"

# Italic (3;)
BLACK_I="\033[3;30m"
RED_I="\033[3;31m"
GREEN_I="\033[3;32m"
YELLOW_I="\033[3;33m"
BLUE_I="\033[3;34m"
PURPLE_I="\033[3;35m"
CYAN_I="\033[3;36m"
WHITE_I="\033[3;37m"

# Underlined (4;)
BLACK_U="\033[4;30m"
RED_U="\033[4;31m"
GREEN_U="\033[4;32m"
YELLOW_U="\033[4;33m"
BLUE_U="\033[4;34m"
PURPLE_U="\033[4;35m"
CYAN_U="\033[4;36m"
WHITE_U="\033[4;37m"

# Blinking (5;)
BLACK_BL="\033[5;30m"
RED_BL="\033[5;31m"
GREEN_BL="\033[5;32m"
YELLOW_BL="\033[5;33m"
BLUE_BL="\033[5;34m"
PURPLE_BL="\033[5;35m"
CYAN_BL="\033[5;36m"
WHITE_BL="\033[5;37m"

# Background (4*m)
BLACK_BG="\033[40m"
RED_BG="\033[41m"
GREEN_BG="\033[42m"
YELLOW_BG="\033[43m"
BLUE_BG="\033[44m"
PURPLE_BG="\033[45m"
CYAN_BG="\033[46m"
WHITE_BG="\033[47m"

# High Intensty
BLACK_HI="\033[0;90m"
RED_HI="\033[0;91m"
GREEN_HI="\033[0;92m"
YELLOW_HI="\033[0;93m"
BLUE_HI="\033[0;94m"
PURPLE_HI="\033[0;95m"
CYAN_HI="\033[0;96m"
WHITE_HI="\033[0;97m"

# High Intensty Bold
BLACK_HI_B="\033[1;90m"
RED_HI_B="\033[1;91m"
GREEN_HI_B="\033[1;92m"
YELLOW_HI_B="\033[1;93m"
BLUE_HI_B="\033[1;94m"
PURPLE_HI_B="\033[1;95m"
CYAN_HI_B="\033[1;96m"
WHITE_HI_B="\033[1;97m"

# High Intensty Background
BLACK_HI_BG="\033[0;100m"
RED_HI_BG="\033[0;101m"
GREEN_HI_BG="\033[0;102m"
YELLOW_HI_BG="\033[0;103m"
BLUE_HI_BG="\033[0;104m"
PURPLE_HI_BG="\033[10;95m"
CYAN_HI_BG="\033[0;106m"
WHITE_HI_BG="\033[0;107m"

## Constants

if [ $SUDO_USER ]; then
  USER=$SUDO_USER
else
  USER=$(whoami)
fi
TITLE="${GREEN_HI_B}Filesystems${NC} for ${BLUE_B}${HOSTNAME}${NC}"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Updated ${RED_B}${RIGHT_NOW}${NC} by ${BLUE_B}${USER}${NC}"
ARGS=$@

## Main program

print_title() {
  echo -e "${TITLE}"
  echo -e "${TIME_STAMP}"
}

colorize_line() {
  echo -en "${CYAN_B}$(echo -en "$1" | cut -d' ' -f1)${NC} "
  echo -e "$1" | cut -d' ' -f2-
}

colorize_table() {
  echo -e "$1" | xargs -n1 -L1 -I {} echo $(colorize_line $@)
}

show_filesystems() {
  DF_TABLE=$(df -aT | tail -n+2 | tr -s ' ')
  FS_BIGGEST=$(echo "${DF_TABLE}" | awk '$3 > max[$2] { max[$2] = $3; m[$2] = $0 }
     END { for (i in m) { printf "%s\n",m[i] } }' | sort -k1)
  if [[ $invert ]]; then
    FS_BIGGEST=$(echo "${FS_BIGGEST}" | sort -k1 -r)
  fi
  # FS_BIGGEST=$(colorize_table "$FS_BIGGEST")
  # echo -e "$FS_BIGGEST" | column -tN NAME,TYPE,SIZE,USED,AVAIL,USE,MOUNT
  echo -e "NAME TYPE SIZE USED AVAIL USE MOUNT\n" "$FS_BIGGEST" | column -tc 7
}

usage() {
  OUTPUT=$(cat <<EOF

${CYAN_B}# Usage${NC}
  ${YELLOW_B}>${NC} ${WHITE_B}filesysteminfo${NC} [options]

${CYAN_B}# Description${NC}
  Shows the systems mounted filesystems

${CYAN_B}# Options${NC}
  ${WHITE_B}--help, -h${NC}\t\tShows this message
  ${WHITE_B}--invert, -inv${NC}\tInverts the order in which the table is printed
\n
EOF
  )
  echo -e "${OUTPUT}"
}

parse_arguments() {
  while [ "$1" != "" ]; do
    case $1 in
      -inv | --invert )
        invert=1
        ;;
      -h | --help )
        usage
        exit
        ;;
      * )
        usage
        exit 1
    esac
    shift
  done 
}

main() {
  parse_arguments $@
  echo
  print_title
  echo
  show_filesystems
}

main $@

