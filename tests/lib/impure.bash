#!/bin/bash

# NB: These implementations call the process as many times as possible. In many
# cases the more efficient option is to call the process once with the full
# argument list, but here we wish to emulate the situation where part of your
# script running once per file may be called N times.

##############################
## These take a list of files
##############################
impure_tail() {
    for x in "$@"; do
        tail -10 $x
    done
}

impure_head() {
    for x in "$@"; do
        head -10 $x
    done
}

impure_readfile() {
    for x in "$@"; do
        local var="$(cat "$x")"
    done
}

impure_cat() {
    for x in "$@"; do
        cat "$x"
    done
}

##############################
## These take a single folder
##############################
impure_count() {
    # Usage: count /path/to/dir/*
    #        count /path/to/dir/*/
    find "$1" | wc -l
}

alias impure_find=find

##############################
## this take a list of files to create
##############################
impure_touch() {
    for x in "$@"; do
        touch "$x"
    done
}

##############################
## This takes a single folder
##############################
impure_extract() {
    sed -n "/^$2\$/,/^$3\$/p" "$1"
}
