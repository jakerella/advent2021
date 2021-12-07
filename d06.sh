#! /bin/bash

echo "DAY 06"

# data="./d06_test.txt"
data="./d06.txt"

input=`cat $data`
IFS="," read -r -a fishes <<< "$input"

ages=(0 0 0 0 0 0 0 0 0)

for fish in ${fishes[*]}; do
    ages[$fish]=$((${ages[$fish]} + 1))
done

function count_fish {
    local total=0
    for agecount in ${ages[*]}; do
        total=$(($total + $agecount))
    done
    echo $total
}

for day in $(seq 1 256); do
    newfish=${ages[0]}
    # echo "caching newfish at $newfish"
    for i in $(seq 1 8); do
        new_i=$(($i - 1))
        # echo "moving ${ages[$i]} fish from $i to $new_i"
        ages[$new_i]=${ages[$i]}
    done
    # echo "setting newfish (8) to $newfish"
    ages[8]=$newfish
    ages[6]=$((${ages[6]} + $newfish))

    # This will run for....... a long time.
    # count=${#fishes[@]}
    # count=$(($count - 1))
    # for i in $(seq 0 $count); do
    #     if [[ ${fishes[$i]} -eq 0 ]]; then
    #         fishes[$i]=6
    #         fishes[${#fishes[@]}]=8
    #     else
    #         fishes[$i]=$((${fishes[$i]} - 1))
    #     fi
    # done
    # echo "after day $day: ${fishes[*]}"
done

echo "ages: ${ages[*]}"

echo "Total fish:" `count_fish`
