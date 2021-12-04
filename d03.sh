#! /bin/bash

echo "DAY 03"

# data="./d03_test.txt"  # 5 chars
data="./d03.txt"  # 12 chars

# Part 1

l=0
zeros=()
ones=()
while read -r line; do
    l=$((${#line} - 1))
    for i in $(seq 0 $l); do
        # echo "char $i:1: ${line:$i:1}"
        if [ "${line:$i:1}" = "0" ]; then
            zeros[$i]=$((${zeros[$i]} + 1))
        fi
        if [ "${line:$i:1}" = "1" ]; then
            ones[$i]=$((${ones[$i]} + 1))
        fi
    done
done < "$data"

gamma=()
epsilon=()
for i in $(seq 0 $l); do
    if [[ zeros[$i] -gt ones[$i] ]]; then
        gamma[$i]=0
        epsilon[$i]=1
    else
        gamma[$i]=1
        epsilon[$i]=0
    fi
done

function join_by { local IFS="$1"; shift; echo "$*"; }

g_string=`join_by "" "${gamma[@]}"`
e_string=`join_by "" "${epsilon[@]}"`
# echo "gamma: " ${gamma[*]} "; epsilon: " ${epsilon[*]}
# echo "gamma: " $g_string "; epsilon: " $e_string
# echo "gamma: " $((2#$g_string)) "; epsilon: " $((2#$e_string))
g_num=$((2#$g_string))
e_num=$((2#$e_string))

echo "Part 1: " $((e_num * g_num))


# Part 2

function filter {
    zeros=0
    ones=0
    inputs=("${@:3}")
    for bin in ${inputs[*]}; do
        # echo "binary: $bin; char $2:1: ${bin:$2:1}"
        if [ "${bin:$2:1}" = "0" ]; then
            zeros=$(($zeros + 1))
        fi
        if [ "${bin:$2:1}" = "1" ]; then
            ones=$(($ones + 1))
        fi
    done
    
    # echo "zeros: " $zeros "; ones: " $ones
    
    keep="1"
    if [ "$1" = "more" ]; then
        if [[ zeros -gt ones ]]; then
            keep="0"
        fi
    else
        if [[ zeros -le ones ]]; then
            keep="0"
        fi
    fi

    local filtered=()
    for number in ${inputs[*]}; do
        if [ "${number:$2:1}" = "$keep" ]; then
            filtered[${#filtered[@]}]=$number
        fi
    done

    echo ${filtered[*]}
}

position=0
numbers=(`cat $data`)

# echo "count:" ${#numbers[@]}
# echo "    all:" ${numbers[*]}
# echo "not all?" ${numbers[@]:1}

while [ ${#numbers[@]} -gt 1 ]; do
    # echo "current set (${#numbers[@]}):" ${numbers[*]}
    result=`filter more $position "${numbers[*]}"`
    numbers=($result)
    position=$(($position + 1))
    # echo "new set (${#numbers[@]}):" ${numbers[*]}
done
oxy=$((2#${numbers[0]}))
echo "oxy:" $oxy

position=0
numbers=(`cat $data`)
while [ ${#numbers[@]} -gt 1 ]; do
    # echo "current set (${#numbers[@]}):" ${numbers[*]}
    result=`filter less $position "${numbers[*]}"`
    numbers=($result)
    position=$(($position + 1))
    # echo "new set (${#numbers[@]}):" ${numbers[*]}
done
co2=$((2#${numbers[0]}))
echo "co2:" $co2

echo "Part 2:" $(($oxy * $co2))
