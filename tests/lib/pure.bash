#!/bin/bash

pure_tail_impl() {
    mapfile -tn 0 line < "$2"
    printf '%s\n' "${line[@]: -$1}"
}
pure_tail() {
    for x in "$@"; do
        pure_tail_impl 10 "$x"
    done
}

pure_head_impl() {
    mapfile -tn $1 line < "$2"
    printf '%s\n' "${line[@]}"
}
pure_head() {
    for x in "$@"; do
        pure_head_impl 10 "$x"
    done
}

pure_readfile() {
    for x in "$@"; do
        local var="$(<"$x")"
    done
}

pure_cat() {
    for x in "$@"; do
        while read -r line; do
            printf '%s\n' "$line"
        done < "$x"
    done
}
pure_cat2() {
    for x in "$@"; do
        printf "%s" "$(<"$x")"
    done
}

pure_touch() {
    # NB: Added noclobber to emulate touch
    set -o noclobber
    for x in "$@"; do
        >"$@"
    done
    set +o noclobber
}

pure_extract() {
    # Usage: extract file "opening marker" "closing marker"
    while IFS=$'\n' read -r line; do
        [[ $extract && $line != "$3" ]] &&
            printf '%s\n' "$line"

        [[ $line == "$2" ]] && extract=1
        [[ $line == "$3" ]] && extract=
    done < "$1"
}

pure_extract_improv() {
    # Usage: extract file "opening marker" "closing marker"
    while IFS=$'\n' read -r line; do
        [[ $line == "$3" ]] && extract=
        [[ $extract ]] && printf '%s\n' "$line"
        [[ $line == "$2" ]] && extract=1
    done < "$1"
}

# The following take one folder as an argument
#
pure_find() {
    shopt -s globstar nullglob
    for file in "$1"/**/*; do
        printf '%s\n' "$file"
    done
    shopt -u globstar nullglob
}

pure_count_impl() {
    printf '%s\n' "$#"
}
pure_count() {
    shopt -s  globstar nullglob 
    pure_count_impl "$1"/**/*
    shopt -u  globstar nullglob 
}
