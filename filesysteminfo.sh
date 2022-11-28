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

## Flags
F_INVERT=""
F_SOPEN=""
F_SDEVICE=""
F_DEVICE_FILES=""

## Main program

print_title() {
  echo -e "${TITLE}"
  echo -e "${TIME_STAMP}"
}

warn() {
  echo -e "${BLACK}${YELLOW_BG} WARNING ${NC} ${1}"
  echo
}

throw_error() {
  echo -e "${RED_BG}  ERROR  ${NC} ${1:-"Unknown error"}"
  echo -e "${WHITE_B}Use the ${CYAN}--help${NC} option for more information${NC}"
  echo
  exit 1
}

throw_if_existing() {
  if [[ $1 == "1" ]]; then
    throw_error "The ${WHITE_B}$2${NC} option has already been specified"
  fi
}

show_filesystems() {
  HEADERS="NAME TYPE COUNT USED NLOW NHIGH MOUNT"
  if [[ ${USERS_FILTER} ]]; then
    USERS_FILTER_FORMATED=$(echo "${USERS_FILTER}" | sed -r 's/ /|/g')
  fi
  SORT_COLUMN=2
  SORT_PARAMS=""
  if [[ ${F_SOPEN} ]]; then
    SORT_PARAMS="-n"
    SORT_COLUMN=7
  elif [[ ${F_SDEVICE} ]]; then
    SORT_COLUMN=3
    SORT_PARAMS="-n"
  fi
  if [[ ${F_INVERT} ]]; then
    SORT_PARAMS="${SORT_PARAMS} -r"
  fi
  DF_TABLE="$(df -aT | tail -n+2 | tr -s ' ' | sort -k4,2 | awk '{ print $1, $2, $4, $7 }')"
  FINAL_TABLE=""
  PREVIOUS_TYPE=""
  USAGE_SUM=0
  PREV_IFS="${IFS}"
  IFS=$'\n'
  for line in $DF_TABLE; do
    IFS=$' ' read -a LINE <<< "${line}"
    if [[ "${PREVIOUS_TYPE}" != "${LINE[1]}" ]]; then
      if [[ "${PREVIOUS_TYPE}" ]]; then
        if [[ "${FS_HIGH}" != "*" || ${F_DEVICE_FILES} != "1" ]]; then
          # Adds rows to the final table
          FINAL_TABLE="${FINAL_TABLE}${WHITE_B}${FS_NAME}${NC}"
          FINAL_TABLE="${FINAL_TABLE} ${FS_TYPE} ${COUNT} ${USAGE_SUM} ${FS_HIGH} ${FS_LOW}"
          if [[ "${F_DEVICE_FILES}" ]]; then
            FINAL_TABLE="${FINAL_TABLE} ${OPEN_FILE_COUNT}"
          fi
          FINAL_TABLE="${FINAL_TABLE} ${FS_MOUNT}\n"
        fi
      fi
      COUNT=1
      PREVIOUS_TYPE="${LINE[1]}"
      USAGE_SUM="${LINE[2]}"
      FS_NAME="${LINE[0]}"
      FS_TYPE="${LINE[1]}"
      FS_MOUNT="${LINE[3]}"
      FS_HIGH=$(stat -c %T ${FS_NAME} 2> /dev/null)
      FS_LOW=$(stat -c %t ${FS_NAME} 2> /dev/null)
      if [[ ${USERS_FILTER} ]]; then
        OPEN_FILE_COUNT=$(lsof ${FS_NAME} 2> /dev/null | tail -n+2 | tr -s ' ' | cut -d' ' -f3 | grep -E -i "^${USERS_FILTER_FORMATED}$" | wc -l)
      else
        OPEN_FILE_COUNT=$(lsof ${FS_NAME} 2> /dev/null | tail -n+2 | wc -l)
      fi
      if [[ ! "${FS_HIGH}" ]]; then
        FS_HIGH="*"
        FS_LOW="*"
      else
        FS_HIGH=$((16#${FS_HIGH}))
        FS_LOW=$((16#${FS_LOW}))
      fi
    else
      COUNT=$((${COUNT} + 1))
      USAGE_SUM=$((${USAGE_SUM} + ${LINE[2]}))
    fi
  done
  # Print leftover
  if [[ "${FS_HIGH}" != "*" || ${F_DEVICE_FILES} != "1" ]]; then
    FINAL_TABLE="${FINAL_TABLE}${WHITE_B}${FS_NAME}${NC}"
    FINAL_TABLE="${FINAL_TABLE} ${FS_TYPE} ${COUNT} ${USAGE_SUM} ${FS_HIGH} ${FS_LOW}"
    if [[ "${F_DEVICE_FILES}" ]]; then
      FINAL_TABLE="${FINAL_TABLE} ${OPEN_FILE_COUNT}"
    fi
    FINAL_TABLE="${FINAL_TABLE} ${FS_MOUNT}\n"
  fi
  IFS="${PREV_IFS}"
  FINAL_TABLE=$(echo -e "${FINAL_TABLE}" | sort -k${SORT_COLUMN} ${SORT_PARAMS})
  if [[ ${F_DEVICE_FILES} ]]; then
    HEADERS="NAME TYPE COUNT USED NHIGH NLOW OPEN MOUNT"
  fi
  if [[ ${F_NO_HEADER} ]]; then
    HEADERS=""
  fi
  echo -e "${YELLOW_B}${HEADERS}${NC}\n" "${FINAL_TABLE}" | column -t
}

usage() {
  echo -e "$(cat <<EOF

${YELLOW_B}>${NC} ${WHITE_B}filesysteminfo${NC} [options]

${CYAN_B}# Description${NC}
  Shows the system mounted filesystems

${CYAN_B}# Options${NC}
  ${WHITE_B}--help, -h${NC}\t\t Shows this message.

  ${CYAN}> Misc${NC}
  ${WHITE_B}-devicefiles${NC}\t\t Only shows device files type filesystems and counts
  \t\t\t the amount of files currently opened.

  ${WHITE_B}-noheader${NC}\t\t Hides the table header.

  ${CYAN}> Filtering${NC}
  ${WHITE_B}-u <user1> <user2>... ${NC} Implies -devicefiles and only counts files opened
  \t\t\t by the specified users.

  ${CYAN}> Sorting${NC} 
  ${WHITE_B}--invert${NC}\t\t Inverts the order in which the table is printed.
  \t\t\t (Applies to any sorting mode)

  ${WHITE_B}-sopen${NC}\t\t Sort by opened files.
  \t\t\t (Requires -devicefiles)

  ${WHITE_B}-sdevice${NC}\t\t Sort by filesystem count.
\n
EOF
  )"
}

parse_arguments() {
  while [[ "$1" != "" ]]; do
    case $1 in
      -inv )
        throw_if_existing ${F_INVERT} "-inv"
        F_INVERT=1
        ;;
      -sopen )
        throw_if_existing ${F_SOPEN} "-sopen"
        F_SOPEN=1
        ;;
      -sdevice )
        throw_if_existing ${F_SDEVICE} "-sdevice"
        F_SDEVICE=1
        ;;
      -devicefiles )
        throw_if_existing ${F_DEVICE_FILES} "-devicefiles"
        F_DEVICE_FILES=1
        ;;
      -noheader )
        throw_if_existing ${F_NO_HEADER} "-noheader"
        F_NO_HEADER=1
        ;;
      -u )
        throw_if_existing ${F_USERS} "-u"
        USERS_FILTER=""
        F_USERS=1
        F_DEVICE_FILES=1
        shift
        while [[ "$1" != "" && "${1:0:1}" != "-" ]]; do
          if [[ ! ${USERS_FILTER} ]]; then
            USERS_FILTER="$1"
            shift
            continue
          fi
          USERS_FILTER="${USERS_FILTER} $1"
          shift
        done
        if [[ ! ${USERS_FILTER} ]]; then
          throw_error "The -u option requires a list of users but none was provided"
        fi
        SKIP_SHIFT=1
        ;;
      -h | --help )
        usage
        exit 0
        ;;
      * )
        throw_error "Unexpected parameter"
    esac
    if [[ ${SKIP_SHIFT} == "1" ]]; then
      SKIP_SHIFT=""
      continue
    fi
    shift
  done
  if [[ ${F_SOPEN} == "1" && ${F_SDEVICE} == "1" ]]; then
    throw_error "Cannot have more than one sorting mode at a time"
  fi
  if [[ ${F_SOPEN} == "1" && ${F_DEVICE_FILES} != "1" ]]; then
    throw_error "The ${WHITE_B}-sopen${NC} option requires the ${WHITE_B}-devicefiles${NC} option but it was not provided"
  fi
}

main() {
  echo
  if [[ ${SUDO_USER} ]]; then
    warn "Executing as sudo"
  fi
  parse_arguments $@
  print_title
  echo
  show_filesystems
  echo
}

main $@

