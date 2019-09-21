bar() {
    : ${1:=-}
    printf "%.s$1" $(seq 80)
    echo
}

header() {
    local d=$1
    shift
    bar $d
    echo "$@"
    bar $d
}

randint() {
    shuf -i1-100 -n1
}

word_diff() {
    diff -U100000 \
        <(grep -o . <<<"$1") \
        <(grep -o . <<<"$2") | tail -n+4
}

assert_same() {
    local results=("$@")
    local base="${results[0]}"
    for (( i = 1; i < ${#results[@]}; ++i )); do
        if [[ "$base" != "${results[i]}" ]]; then
            let ++i
            echo command 1 differs from command $i:
            header - "$1"
            header - "${!i}"
            return 1
        fi
    done
}

real() {
    tr 'ms.' '   ' | awk '/real/ { print 60*$2 + $3 + $4/1000 }'
}
