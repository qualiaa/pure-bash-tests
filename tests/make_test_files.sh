#!/bin/bash

# NB: Generates about 20GB of test data
# We do this to thwart caching

set -eu

source ../settings.bash

mkdir -p "$OUTDIR"/length/
for i in $(seq 1 $NUM_OUTPUTS); do
    mkdir -p "$OUTDIR/num_files/$i"

    yes $TESTFILE | head -$i | xargs cat > "$OUTDIR/length/$i"

    for j in $(seq 1 $i); do
        cp "$TESTFILE" "$OUTDIR/num_files/$i/$j"
    done
done
