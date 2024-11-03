#!/usr/bin/env bash
# Copyright (c) 2011 rupa deadwyler. Licensed under the WTFPL license, Version 2

[ "$vim" ] || vim=vim
[ "$viminfo" ] || viminfo=~/.viminfo

usage="$(basename "$0") [-a] [-c] [-l] [-[0-9]] [--debug] [--help] [regexes]"

[ "$1" ] || list=1

_pwd="$(command pwd)"

fnd=()
for x; do
  case $x in
  -a) deleted=1 ;;
  -c)
    subdir=1
    shift
    ;;
  -l) list=1 ;;
  -[0-9])
    edit=${x:1}
    shift
    ;;
  --help)
    echo "$usage"
    exit
    ;;
  --debug) vim=$(echo) ;;
  --)
    shift
    fnd+=("$@")
    break
    ;;
  *) fnd+=("$x") ;;
  esac
  shift
done
set -- "${fnd[@]}"

[ -f "$1" ] && {
  $vim "$1"
  exit
}

while IFS=" " read -r line; do
  [ "${line:0:1}" = ">" ] || continue
  fl=${line:2}
  _fl="${fl/~\//$HOME/}"
  [ -f "$_fl" ] || [ "$deleted" ] || continue
  match=1
  for x; do
    [[ "$fl" =~ $x ]] || match=
  done
  [ "$subdir" ] && {
    case "$_fl" in
    $_pwd*) ;;
    *) match= ;;
    esac
  }
  [ "$match" ] || continue
  i=$((i + 1))
  files[i]="$fl"
done <"$viminfo"

if [ "$edit" ]; then
  resp=${files[$((edit + 1))]}
elif [ "$i" = 1 ] || [ "$list" = "" ]; then
  resp=${files[1]}
elif [ "$i" ]; then
  CHOICE=$(printf "%s\n" "${files[@]}" | fzf)
  [ "$CHOICE" ] && resp=$CHOICE
fi

[ "$resp" ] || exit
$vim "${resp/\~/$HOME}"
