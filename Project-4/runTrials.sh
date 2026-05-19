#!/bin/bash
# Usage: ./runTrials.sh <program> [n_elements]
# Runs the program 5 times and reports per-run and average timing (ms).

PROGRAM=${1:?Usage: ./runTrials.sh <program> [n_elements]}
N=${2:-$((1 << 24))}   # default: 16 M elements
TRIALS=5

echo "Program : $PROGRAM"
echo "Elements: $N"
echo "Trials  : $TRIALS"
echo "---"

total=0
for i in $(seq 1 $TRIALS); do
    t=$("$PROGRAM" "$N")
    printf "Trial %d: %s ms\n" "$i" "$t"
    total=$(echo "$total + $t" | bc)
done

avg=$(echo "scale=3; $total / $TRIALS" | bc)
echo "---"
echo "Average : ${avg} ms"
