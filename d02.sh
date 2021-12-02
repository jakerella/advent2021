#! /bin/bash

echo "DAY 02"

# data="./d02_test.txt"
data="./d02.txt"

# Part 1

depth=0
pos=0
while IFS=" " read -r cmd amt; do
    # echo "cmd: $cmd, amt: $amt"
    if [[ "forward" = "$cmd" ]]; then
        pos=$(($pos + $amt))
    elif [[ "down" = "$cmd" ]]; then
        depth=$(($depth + $amt))
    elif [[ "up" = "$cmd" ]]; then
        depth=$(($depth - $amt))
    else
        echo "bad command $cmd"
    fi
done < "$data"

p1=$(($pos * $depth))
echo "Part 1: pos $pos; depth $depth; answer: $p1"


# Part 2

depth=0
pos=0
aim=0
while IFS=" " read -r cmd amt; do
    if [[ "forward" = "$cmd" ]]; then
        pos=$(($pos + $amt))
        depth=$(($depth + ($aim * $amt)))
    elif [[ "down" = "$cmd" ]]; then
        aim=$(($aim + $amt))
    elif [[ "up" = "$cmd" ]]; then
        aim=$(($aim - $amt))
    else
        echo "bad command $cmd"
    fi
done < "$data"

p1=$(($pos * $depth))
echo "Part 2: pos $pos; depth $depth; aim $aim; answer: $p1"
