#!/bin/bash

set -eu

! rm -r figures
mkdir figures

plot() {
    gnuplot <<EOF
set terminal png
set output "figures/$3.png"
set xlabel "N"
set ylabel "Time"
set style line 1 lc rgb "purple" lw 5
set style line 2 lc rgb "orange" lw 5
set autoscale
set title "$3"
set style data lines
plot "$1" ls 1 title "$(basename "$1" | tr _ ' ')", \
     "$2" ls 2 title "$(basename "$2" | tr _ ' ')"
EOF
}

barplot() {
    file=$(mktemp)
    paste "$1" "$2" >$file
gnuplot <<EOF
    set terminal png
    set output "figures/$3.png"
    set style histogram clustered
    set boxwidth 1
    set style line 1 lc rgb "purple"
    set style line 2 lc rgb "orange"
    set style fill solid
    set ylabel "Time"

    set yrange [0:*]
    plot "$file" using 1:xtic(2) with histograms ls 1 title "$(basename "$1" | tr _ ' ')", \
         ""      using 2:xtic(2) with histograms ls 2 title "$(basename "$2" | tr _ ' ')"
EOF
}

plot results/{im,}pure_head_length.time         "head: Length"
plot results/{im,}pure_head_numfiles.time       "head: Num Files"
plot results/{im,}pure_tail_length.time         "tail: Length"
plot results/{im,}pure_tail_numfiles.time       "tail: Num Files"
plot results/{im,}pure_readfile_length.time     "readfile: Length"
plot results/{im,}pure_readfile_numfiles.time   "readfile: Num Files"
plot results/{im,}pure_cat_length.time          "cat: Length"
plot results/{im,}pure_cat_numfiles.time        "cat: Num Files"
plot results/pure_cat{,2}_length.time           "cat2: Length"
plot results/pure_cat{,2}_numfiles.time         "cat2: Num Files"
plot results/{im,}pure_touch.time               "Touch"

plot results/{im,}pure_extract.time             "Extract"
plot results/pure_extract{,_improv}.time        "Extract Alt"

barplot results/{im,}pure_find.time             "Find"
barplot results/{im,}pure_count.time            "Count"
