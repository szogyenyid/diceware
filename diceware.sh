#!/bin/bash

arg0=$(basename "$0" .sh)
blnk=$(echo "$arg0" | sed 's/./ /g')

usage_info()
{
    echo "Usage: $arg0 [{-l|--length} length] [-e|--entropy] [-v|--verify]"
    echo "       $blnk [{-d|--delimiter} delimiter] [-q|--quiet]"
}

help()
{
    usage_info
    echo
    echo "  {-l|--length} length        -- The number of words in the passphrase (default: 6)"
    echo "  {-e|--entropy}              -- Show the entropy of the generated passphrase"
    echo "  {-d|--delimiter} delimiter  -- Delimiter to use between words (default: space)"
    echo "  {-q|--quiet}                -- Only print the passphrase"
    echo "  {-v|--verify}               -- Verifies if the present wordlist is the one provided by EFF"
    echo "  {-h|--help}                 -- Print this help message and exit"
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
        (-d|--delimiter)
            shift
            export DELIMITER="$1"
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-e|--entropy)
            shift
            export ENTROPY=1
            OPTCOUNT=$(($OPTCOUNT + 1));;
        (-h|--help)
            help;;
        (-l|--length)
            shift
            [ $# = 0 ] && error "No length specified"
            export LENGTH="$1"
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-q|--quiet)
            shift
            export QUIET=1
            OPTCOUNT=$(($OPTCOUNT + 1));;
        (-v|--verify)
            shift
            export VERIFY=1
            OPTCOUNT=$(($OPTCOUNT + 1));;
        (*) usage;;
        esac
    done
}

BASEDIR=$(dirname "$0")
LENGTH=6
DELIMITER=" "
flags "$@"

if ! test -f $BASEDIR/eff_large_wordlist.txt; then
    if [[ "$QUIET" -eq "1" ]]; then
        $(wget -q -P $BASEDIR https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt)
    else
        echo "Wordlist not found. Trying to download..."
        $(wget -P $BASEDIR https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt)
    fi
    VERIFY=1
fi

if [[ "$VERIFY" -eq "1" ]]; then
    if [[ "$QUIET" -ne "1" ]]; then
        echo "Verifying fingerprints..."
    fi
    EFFFINGERPRINT=$(wget -qO- https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt | openssl dgst -sha256 | cut -d " " -f 2)
    LISTFINGERPRINT=$(cat $BASEDIR/eff_large_wordlist.txt | openssl dgst -sha256 | cut -d " " -f 2)
    if [[ "$LISTFINGERPRINT" != "$EFFFINGERPRINT" ]]; then
        if [[ "$QUIET" -ne "1" ]]; then
            echo "Your dictionary differs from the one provided by EFF. Aborting"
        fi
        exit 1
    fi
    if [[ "$QUIET" -ne "1" ]]; then
        echo "Verification successful"
        echo
    fi
fi

if [[ "$LENGTH" -lt 6 ]]; then
    if [[ "$QUIET" -ne "1" ]]; then
        echo "Warning! It is advised to use at least 6 words for a passphrase."
    fi
fi

for i in $(seq 1 $LENGTH);
do
    CURRNUM=""
    for j in $(seq 1 5);
    do
        CURRRAND=$(($((16#$(cat /dev/urandom | head -n 50 | od -x | cut -b 8-12,14-18 | xargs | sed 's/ //g' | cut -b 1-14)))%6 + 1))
        CURRNUM="${CURRNUM}${CURRRAND}"
    done
    WORD=$(grep ${CURRNUM} $BASEDIR/eff_large_wordlist.txt | cut -f 2)
    if [ $i -eq $LENGTH ]; then
        echo -ne "$WORD"
    else
        echo -ne "$WORD$DELIMITER"
    fi
done
echo

if [[ "$ENTROPY" -eq "1" ]]; then
    if [[ "$QUIET" -ne "1" ]]; then
        echo
        echo "Entropy: ~$(($LENGTH*323/25)) bits"
    fi
fi
exit 0