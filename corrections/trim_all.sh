#!/bin/bash

set -eu
source ../tools.bash

: ${NUM_TESTS:=1}
: ${NUM_WORDS:=500}

trim_all() {
    set -f
    set -- $*
    printf '%s\n' "$*"
    set +f
}

trim_all_2() {
    set -f
    local IFS=" "
    echo -E $*
    set +f


    # Same behaviour
    #set -f
    #local IFS=" "
    #set -- $*
    #printf '%s\n' "$*"
    #set +f
}

gen_string() {
    for part in $(strings < /dev/urandom | head -$NUM_WORDS); do
        echo -n $part
        printf "%.s " $(seq 1 $(randint))
    done
    echo
}

do_tests() {
    SUBSHELL_IFS=${1:-$IFS}
    string="$(gen_string)"
    for i in $(seq 1 $NUM_TESTS); do
        t1="$(IFS="$SUBSHELL_IFS" trim_all "$string")"
        t2="$(IFS="$SUBSHELL_IFS" trim_all_2 "$string")"
        echo -E "$string"
        echo -E "$t1"
        echo -E "$t2"
        if [[ "$t1" != "$t2" ]]; then
            exit 1
        fi
    done
    echo All passed!
}

header = Default IFS
do_tests "$string"
header = Changed IFS
do_tests :
