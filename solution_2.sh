#!/usr/bin/env sh

help_menu() {
  echo "Usage:

  ${0##*/} [-h][-l FILENAME][-d]

Options:

  -h, --help
    display this help and exit

  -l, --logfile=FILENAME
    filename

  -d, --debug
    enable debug
  "
}

parse_options() {
  case $opt in
    h|help)
      help_menu
      exit
     ;;
    l|logfile)
      logfile=${attr}
      ;;
    d|debug)
      debug=true
      ;;
    *)
      echo "Unknown option: ${opt}\nRun ${0##*/} -h for help.">&2
      exit 1
  esac
}
options=$@

until [ "$options" = "" ]; do
  if [[ $options =~ (^ *(--([a-zA-Z0-9-]+)|-([a-zA-Z0-9-]+))(( |=)(([\_\.\?\/\\a-zA-Z0-9]?[ -]?[\_\.\?a-zA-Z0-9]+)+))?(.*)|(.+)) ]]; then
    if [[ ${BASH_REMATCH[3]} ]]; then # for --option[=][attribute] or --option[=][attribute]
      opt=${BASH_REMATCH[3]}
      attr=${BASH_REMATCH[7]}
      options=${BASH_REMATCH[9]}
    elif [[ ${BASH_REMATCH[4]} ]]; then # for block options -qwert[=][attribute] or single short option -a[=][attribute]
      pile=${BASH_REMATCH[4]}
      while (( ${#pile} > 1 )); do
        opt=${pile:0:1}
        attr=""
        pile=${pile/${pile:0:1}/}
        parse_options
      done
      opt=$pile
      attr=${BASH_REMATCH[7]}
      options=${BASH_REMATCH[9]}
    else # leftovers that don't match
      opt=${BASH_REMATCH[10]}
      options=""
    fi
    parse_options
  fi
done
