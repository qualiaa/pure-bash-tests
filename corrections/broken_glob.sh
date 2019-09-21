#!/bin/bash

set -eu
source ../tools.bash

readonly dir=$(mktemp -d)

do_tests() {
    header - Fail case

    for x in "$dir"/*; do
        echo "$x"
    done

    header - Expected behaviour

    shopt -s nullglob
    for x in "$dir"/*; do
        echo "$x"
    done
    shopt -u nullglob

    header - Example where this still fails

    shopt -s nullglob
    printf "%s\n" "$dir"/*
    shopt -u nullglob

    header - Possible, inelegant solution:

    shopt -s nullglob
    OFS="$IFS"
    IFS=":"
    tempvar=$(printf "%s:" "$dir"/*)
    set -f
    if [ -n "$tempvar" ]; then
        set -- $tempvar
        IFS=$'\n'
        printf "%s\n"  "$*"
        IFS=$OFS
    fi
    shopt -u nullglob
    set +f
}

header = "Empty Directory"
do_tests

touch globtest/{a,"b c",d}

header = "With Files (should all pass)"
do_tests
