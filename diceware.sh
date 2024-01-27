#!/bin/bash

arg0=$(basename "$0" .sh)
blnk=$(echo "$arg0" | sed 's/./ /g')

usage_info()
{
    echo "Usage: $arg0 [{-s|--size} size] [-e|--entropy] [-v|--verify]"
    echo "       $blnk [{-d|--delimiter} delimiter]"
}

help()
{
    usage_info
    echo
    echo "  {-s|--size} size  -- The number of words in the passphrase (default: 6)"
    echo "  {-e|--entropy}    -- Show the entropy of the generated passphrase"
    echo "  {-d|--delimiter}  -- Delimiter to use between words (default: space)"
    echo "  {-v|--verify}     -- Verifies if the present wordlist is the one provided by EFF"
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
        (-s|--size)
            shift
            [ $# = 0 ] && error "No size specified"
            export SIZE="$1"
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-v|--verify)
            shift
            export VERIFY=1
            OPTCOUNT=$(($OPTCOUNT + 1));;
        (*) usage;;
        esac
    done
}

SIZE=6
DELIMITER=" "
flags "$@"

if [[ "$VERIFY" -eq "1" ]]; then
    echo "Verifying fingerprints..."
    EFFFINGERPRINT=$(wget -qO- https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt | openssl dgst -sha256 | cut -d " " -f 2)
    LISTFINGERPRINT=$(cat eff_large_wordlist.txt | openssl dgst -sha256 | cut -d " " -f 2)
    if [[ "$LISTFINGERPRINT" != "$EFFFINGERPRINT" ]]; then
        echo "Your dictionary differs from the one provided by EFF. Aborting"
        exit 1
    fi
    echo "Verification successful"
    echo
fi

for i in $(seq 1 $SIZE);
do
    CURRNUM=""
    for j in $(seq 1 5);
    do
        CURRRAND=$(($((16#$(cat /dev/urandom | head -n 50 | od -x | cut -b 8-12,14-18 | xargs | sed 's/ //g' | cut -b 1-14)))%6 + 1))
        CURRNUM="${CURRNUM}${CURRRAND}"
    done
    WORD=$(grep ${CURRNUM} eff_large_wordlist.txt | cut -f 2)
    if [ $i -eq $SIZE ]; then
        echo -ne "$WORD"
    else
        echo -ne "$WORD$DELIMITER"
    fi
done
echo

if [[ "$ENTROPY" -eq "1" ]]; then
    echo
    echo "Entropy: ~$(($SIZE*323/25)) bits"
fi
exit 0