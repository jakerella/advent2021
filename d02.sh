#! /bin/bash

echo "DAY 02"

# data="./d02_test.txt"
data="./d02.txt"

# Part 1

depth=0
pos=0
while read -r line
do
    cmd=($line)
    # echo "cmd: ${cmd[0]}, amt: ${cmd[1]}"
    if [[ "forward" = "${cmd[0]}" ]]; then
        pos=$(($pos + ${cmd[1]}))
    elif [[ "down" = "${cmd[0]}" ]]; then
        depth=$(($depth + ${cmd[1]}))
    elif [[ "up" = "${cmd[0]}" ]]; then
        depth=$(($depth - ${cmd[1]}))
    else
        echo "bad command ${cmd[0]}"
    fi

done < "$data"

p1=$(($pos * $depth))
echo "Part 1 pos: $pos; depth $depth; answer: $p1"


# Part 2

depth=0
pos=0
aim=0
while read -r line
do
    cmd=($line)
    if [[ "forward" = "${cmd[0]}" ]]; then
        pos=$(($pos + ${cmd[1]}))
        depth=$(($depth + ($aim * ${cmd[1]})))
    elif [[ "down" = "${cmd[0]}" ]]; then
        aim=$(($aim + ${cmd[1]}))
    elif [[ "up" = "${cmd[0]}" ]]; then
        aim=$(($aim - ${cmd[1]}))
    else
        echo "bad command ${cmd[0]}"
    fi
    # echo "cmd: ${cmd[0]}, amt: ${cmd[1]} ... new pos $pos, depth $depth, aim $aim"

done < "$data"

p1=$(($pos * $depth))
echo "Part 1 pos $pos; depth $depth; aim $aim; answer: $p1"

