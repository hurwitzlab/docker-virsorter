#!/bin/bash

set -u

BIN="$( readlink -f -- "${0%/*}" )"
INPUT=""
DB=1
DB_DIR=""
DS="VIRSorter"
PHAGE=""
VIROME=""
OUTDIR=$(pwd)

function HELP() {
  printf "Usage:\n  %s -i INPUT\n" $(basename $0)
  echo
  echo Required arguments:
  echo " -i INPUT (file or directory)"
  echo
  echo "Options (default in parentheses):"
  echo " -d Database ($DB)"
  echo " -s Dataset ($DS)"
  echo " -o Output directory ($OUTDIR)"
  echo " -l Location of database"
  echo " -p Custom phage file"
  echo " -v Virome decontamination"
  echo
  exit 0
}

function lc() {
  wc -l $1 | cut -d ' ' -f 1
}

if [[ $# -eq 0 ]]; then
  HELP
fi

echo Invocation $0 $@

while getopts :c:d:i:l:o:p:s:h OPT; do
  case $OPT in
    d)
      DB="$OPTARG"
      ;;
    i)
      INPUT="$OPTARG"
      ;;
    h)
      HELP
      ;;
    l)
      DB_DIR="$OPTARG"
      ;;
    o)
      OUTDIR="$OPTARG"
      ;;
    p)
      PHAGE="$OPTARG"
      ;;
    s)
      DS="$OPTARG"
      ;;
    v)
      VIROME="$OPTARG"
      ;;
    :)
      echo "Error: Option -$OPTARG requires an argument."
      exit 1
      ;;
    \?)
      echo "Error: Invalid option: -${OPTARG:-""}"
      exit 1
  esac
done

if [[ ${#INPUT} -lt 1 ]]; then 
  echo INPUT not defined.
  exit 1
fi

if [[ ! -d $OUTDIR ]]; then 
  mkdir -p $OUTDIR
fi

INPUT_FILES=$(mktemp)
if [[ -d $INPUT ]]; then
  echo Looking for files in directory \"$INPUT\"
  find $INPUT -type f -size +0c > $INPUT_FILES
else
  echo $INPUT > $INPUT_FILES
fi

NUM_FILES=$(lc $INPUT_FILES)
echo Found NUM_FILES \"$NUM_FILES\"

if [[ $NUM_FILES -lt 1 ]]; then
  echo Nothing to do.
  exit
fi

if [[ ${#PHAGE} -gt 0 ]]; then
  PHAGE="-p $PHAGE"
fi

if [[ ${#DB_DIR} -gt 0 ]]; then
  DB_DIR="--data-dir $DB_DIR"
fi

if [[ ${#VIROME} -gt 0 ]]; then
  VIROME="--virome $VIROME"
fi

i=0
while read FILE; do
  let i++
  BASENAME=$(basename $FILE)
  printf "%3d: %s\n" $i $BASENAME
  WDIR="$OUTDIR/$BASENAME"

  if [[ ! -d $WDIR ]]; then
    mkdir -p $WDIR
  fi

  $BIN/VirSorter/wrapper_phage_contigs_sorter_iPlant.pl -f $FILE --db $DB -d $DS --db $DB --wdir $WDIR $DB_DIR $PHAGE $VIROME
done < $INPUT_FILES

echo Done.
