#!/usr/bin/env bash

usage() {
  cat - >&2 <<EOF
NAME
    program-name.sh - Brief description
 
SYNOPSIS
    program-name.sh [-h|--help]
    program-name.sh [-f|--foo]
                    [-b|--bar <arg>]
                    [--baz[=<arg>]]
                    [--]
                    FILE ...

REQUIRED ARGUMENTS
  FILE ...
          input files

OPTIONS
  -h, --help
          Prints this and exits

  -f, --foo
          A flag option
      
  -b, --bar <arg>
          Option requiring an argument <arg>

  --baz[=<arg>]
          Option that has an optional argument <arg>. If <arg>
          is not specified, defaults to 'DEFAULT'
  --     
          Specify end of options; useful if the first non option
          argument starts with a hyphen

EOF
}

fatal() {
    for i; do
        echo -e "${i}" >&2
    done
    exit 1
}

# For long option processing
next_arg() {
    if [[ $OPTARG == *=* ]]; then
        # for cases like '--opt=arg'
        OPTARG="${OPTARG#*=}"
    else
        # for cases like '--opt arg'
        OPTARG="${args[$OPTIND]}"
        OPTIND=$((OPTIND + 1))
    fi
}

# ':' means preceding option character expects one argument, except
# first ':' which make getopts run in silent mode. We handle errors with
# wildcard case catch. Long options are considered as the '-' character
optspec=":hfb:-:"
args=("" "$@")  # dummy first element so $1 and $args[1] are aligned
while getopts "$optspec" optchar; do
    case "$optchar" in
        h) usage; exit 0 ;;
        f) foo=1 ;;
        b) bar="$OPTARG" ;;
        -) # long option processing
            case "$OPTARG" in
                help)
                    usage; exit 0 ;;
                foo)
                    foo=1 ;;
                bar|bar=*) next_arg
                    bar="$OPTARG" ;;
                baz)
                    baz=DEFAULT ;;
                baz=*) next_arg
                    baz="$OPTARG" ;;
                -) break ;;
                *) fatal "Unknown option '--${OPTARG}'" "see '${0} --help' for usage" ;;
            esac
            ;;
        *) fatal "Unknown option: '-${OPTARG}'" "See '${0} --help' for usage" ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -eq 0 ]; then
    fatal "Expected at least one required argument FILE" \
    "See '${0} --help' for usage"
fi

echo "foo=$foo, bar=$bar, baz=$baz, files=${@}"
