#!/bin/bash

set -e
source ../tools.bash
source ../settings.bash
source lib/impure.bash
source lib/pure.bash

mkdir -p results

truncate_results_files() {
    for cmd in "$@"; do
        >"results/${cmd}.time"
    done
}

with_list_of_files() {
    # Truncate files
    for cmd in "$@"; do
        >"results/${cmd}_numfiles.time"
        >"results/${cmd}_length.time"
    done

    find "$OUTDIR/length/" -type f | while read -r file; do
        local results=()
        for cmd in "$@"; do
            { time results+=("$($cmd "$file")") ; } 3>&1 >/dev/null 2>&3 \
                | real >>"results/${cmd}_length.time"
        done
        assert_same "${results[@]}" || return 1
    done 
    find "$OUTDIR/num_files/" -mindepth 1 -type d | while read -r folder; do
        local results=()
        for cmd in "$@"; do
            { time results+=("$($cmd "$folder"/*)") ; } 3>&1 >/dev/null 2>&3 \
                | real >>"results/${cmd}_numfiles.time"
        done
        assert_same "${results[@]}" || return 1
    done
}

with_folder() {
    truncate_results_files "$@"

    for i in {1..3}; do
        local results=()
        for cmd in "$@"; do
            { time results+=("$($cmd "$OUTDIR")") ; } 3>&1 >/dev/null 2>&3 \
                | real >>"results/${cmd}.time"
        done
        assert_same "${results[@]}"
    done
}

with_new_files() {
    truncate_results_files "$@"

    for i in {1..1000}; do
        for cmd in "$@"; do
            local dir=$(mktemp -d)
            argstring=$(printf "$dir/%s " $(seq 1 $i))
            { time $cmd $argstring ; } 3>&1 >/dev/null 2>&3 \
                | real >>"results/${cmd}.time"
        done
    done
}

test_batches() {
    local tests=$1
    shift
    local batches=("$@")

    for batch in "${batches[@]}"; do
        header = $batch

        if $tests $batch; then
            echo SUCCESS
        else
            echo FAILURE
        fi
    done
}

test_extract() {
    truncate_results_files "$@"
        
    local file=/usr/share/dict/words
    local length="$(wc -l <"$file")"
    local first_word="$(head -n1 "$file")"
    for i in {1..100}; do
        local results=()
        local last_word=$(tail -n+$(( (i*length)/100 )) "$file" | head -n1)
        for cmd in "$@"; do
            { time results+=("$($cmd "$file" "$first_word" "$last_word")") ; } \
                                                               3>&1 \
                                                               >/dev/null \
                                                               2>&3 \
                | real >>"results/${cmd}.time"
        done
        assert_same "${results[@]}"
    done
}

# NB: We put pure methods second so they will get the benefits of any caching
a=("impure_tail pure_tail"
   "impure_head pure_head"
   "impure_readfile pure_readfile"
   "impure_cat pure_cat pure_cat2")

b=("impure_count pure_count"
   "impure_find pure_find")

c=("impure_touch pure_touch")
d=("impure_extract pure_extract pure_extract_improv")


test_batches test_extract "${d[@]}"
test_batches with_folder "${b[@]}"
test_batches with_new_files "${c[@]}"
test_batches with_list_of_files "${a[@]}"
