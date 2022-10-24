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
TITLE="${GREEN_HI_B}System info${NC} for ${BLUE_B}${HOSTNAME}${NC}"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Updated ${RED_B}${RIGHT_NOW}${NC} by ${BLUE_B}${USER}${NC}"

## Main program

system_info() {
  echo -e "${CYAN_U}(?) INFO${NC}"
  echo -e "${YELLOW_HI_B}>> KERNEL: ${NC}$(uname -s)"
  echo -e "${YELLOW_HI_B}>> KERNEL-VERSION: ${NC}$(uname -v)"
  echo -e "${YELLOW_HI_B}>> KERNEL-RELEASE: ${NC}$(uname -r)"
  echo -e "${YELLOW_HI_B}>> NODE: ${NC}$(uname -n)"
  echo -e "${YELLOW_HI_B}>> CPU: ${NC}$(uname -p)"
  echo -e "${YELLOW_HI_B}>> PLATFORM: ${NC}$(uname -i)"
  echo -e "${YELLOW_HI_B}>> OS: ${NC}$(uname -o)"
}

terminal_info() {
  echo -e "${CYAN_U}(?) TERMINAL${NC}"
  echo -e "${YELLOW_HI_B}>> SHELL: ${NC}${SHELL}"
}

show_uptime() {
  echo -e "${CYAN_U}(?) UPTIME${NC}"
  echo -e "${YELLOW_HI_B}>>${NC} $(uptime)"
}

drive_space() {
  echo -e "${CYAN_U}(?) DRIVESPACE${NC}"
  echo -e "${YELLOW_HI_B}>> USED:${NC}$(df -h --output=pcent / | tail -1)"
  echo -e "${YELLOW_HI_B}>> FREE:${NC}$(df -h --output=avail / | tail -1)"
}

home_space() {
  echo -e "${CYAN_U}(?) HOMESPACE${NC}"
  if [ $(whoami) == "root" ]; then
    du -h -d1 /home | xargs -L1 echo -e "${YELLOW_HI_B}>>${NC}"
  else
    echo -e "${YELLOW_HI_B}>> USED:${NC} $(du -h -d0 ~)"
  fi
}

main() {
  MESSAGE=$(cat <<EOF
=========================================================
${TITLE}
${TIME_STAMP}
=========================================================\n
EOF
  )
  echo -e "$MESSAGE"
  system_info
  echo
  terminal_info
  echo
  show_uptime
  echo
  drive_space
  echo
  home_space
  echo
}

main
