#! /bin/bash

echo "DAY 07"

# data="./d07_test.txt"
data="./d07.txt"

input=`cat $data`
IFS="," read -r -a positions <<< "$input"
positions=( $( printf "%s\n" "${positions[@]}" | sort -n ) )
# echo ${positions[*]}

# -------------------------


total=${#positions[@]}
remainder=$(($total % 2))
if [[ $remainder -eq 1 ]]; then
    median_i=$((($total + 1) / 2))
    median=${positions[$median_i]}
else
    median_i=$(($total / 2))
    median_1=${positions[$median_i]}
    median_i=$(($median_i - 1))
    median_2=${positions[$median_i]}
    median=$((($median_1 + $median_2) / 2))
fi
echo "median:" $median

function calculate_fuel_total {
    local fuel_total=0
    for pos in ${positions[*]}; do
        local cost=$(($pos - $1))
        cost=${cost#-}  # absolute value
        fuel_total=$(($fuel_total + $cost))
    done
    echo "$fuel_total"
}


echo "Part 1: " `calculate_fuel_total $median`
echo ""

# -------------------------


function calculate_acc_fuel_total {
    local fuel_total=0
    for pos in ${positions[*]}; do
        local distance=$(($pos - $1))
        distance=${distance#-}  # absolute value
        local cost=0
        for d in $(seq 1 $distance); do
            cost=$(($cost + $d))
        done
        fuel_total=$(($fuel_total + $cost))
    done
    echo "$fuel_total"
}


# look at both sides, figure out which side is furthest from median
distance_to_start=$(($median - ${positions[0]}))
distance_to_start=${distance_to_start#-}  # absolute value
end_i=$(($total - 1))
distance_to_end=$((${positions[$end_i]} - $median))
distance_to_end=${distance_to_end#-}  # absolute value

if [[ $distance_to_end -gt $distance_to_start ]]; then
    hold_alignment=${positions[$median_i]}
    hold_total=99999999999

    for alignment in $(seq $hold_alignment ${positions[$end_i]}); do
        total=`calculate_acc_fuel_total $alignment`
        # echo "$total fuel when aligned on $alignment"
        if [[ $total -le $hold_total ]]; then
            hold_alignment=$alignment
            hold_total=$total
        else
            break
        fi
    done
fi
# do I need the else??


echo "Part 2: $hold_total fuel when aligned on $hold_alignment"
