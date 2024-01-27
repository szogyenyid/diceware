#!/bin/bash

arg0=$(basename "$0" .sh)
blnk=$(echo "$arg0" | sed 's/./ /g')

usage_info()
{
    echo "Usage: $arg0 [{-s|--size} size]"
    #echo "Usage: $arg0 [{-s|--size} size] [{-b|--bbb} bbb] \\"
    #echo "       $blnk [{-c|--ccc} ccc] [{-d|--ddd} ddd] \\"
}

help()
{
    usage_info
    echo
    echo "  {-s|--size} size  -- The number of words in the passphrase (default: 6)"
    echo "  {-h|--help}       -- Print this help message and exit"
    exit 0
}

usage()
{
    exec 1>2
    usage_info
    exit 1
}

error()
{
    echo "$arg0: $*" >&2
    exit 1
}

flags()
{
    OPTCOUNT=0
    while test $# -gt 0
    do
        case "$1" in
        (-s|--size)
            shift
            [ $# = 0 ] && error "No size specified"
            export SIZE="$1"
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-h|--help)
            help;;
#       (-V|--version)
#           version_info;;
        (--)
            shift
            OPTCOUNT=$(($OPTCOUNT + 1))
            break;;
        (*) usage;;
        esac
    done
}

SIZE=6
flags "$@"

for i in $(seq 1 $SIZE);
do
    CURRNUM=""
    for j in $(seq 1 5);
    do
        CURRRAND=$(($((16#$(cat /dev/urandom | head -n 50 | od -x | cut -b 8-12,14-18 | xargs | sed 's/ //g' | cut -b 1-14)))%6 + 1))
        CURRNUM="${CURRNUM}${CURRRAND}"
    done
    echo -ne $(grep ${CURRNUM} eff_large_wordlist.txt | cut -f 2) " "
done
echo
