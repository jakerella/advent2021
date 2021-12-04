#! /bin/bash

echo "DAY 04"

# row win: 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
# col win: 7,4,9,5,11,17,23,2,0,14,21,3,20,24,10,16,13,6,15,25,12,22,18,8,19,26,1
# data="./d04_test.txt"
data="./d04.txt"

# Part 1

function reset_boards {
    numbers=""
    boards=()
    current_board=()
    while read -r line; do
        if [ -z $numbers ]; then
            numbers="$line"
        elif [ ! -z "$line" ]; then
            if [[ ${#current_board[@]} -ge 25 ]]; then
                boards[${#boards[@]}]="${current_board[*]}"
                current_board=()
            fi

            line_numbers=("$line")
            for number in ${line_numbers[*]}; do
                current_board[${#current_board[@]}]=$number
            done
        fi
    done < "$data"
    # pick up the last board
    boards[${#boards[@]}]="${current_board[*]}"


    IFS="," read -r -a numbers <<< "$numbers"
}

reset_boards

# echo "numbers (${#numbers[@]}): ${numbers[*]}"
# echo "boards (${#boards[@]}); entry 0: ${boards[0]}"

function check_board {
    local board=($1)
    local unmarked_check='(^|\s)[0-9]+(\s|$)'
    
    # check rows
    for j in $(seq 0 4); do
        start=$(($j * 5))
        row=${board[@]:$start:5}
        if [[ ! "${row[*]}" =~ $unmarked_check ]]; then
            # echo "row win: ${row[*]}"
            return 1
        fi
    done

    # check columns
    for j in $(seq 0 4); do
        col=()
        for k in $(seq 0 4); do
            check=$(($j + (5 * $k)))
            col[${#col[@]}]=${board[$check]}
        done
        # echo "checking col: ${col[*]}"
        if [[ ! "${col[*]}" =~ $unmarked_check ]]; then
            # echo "col win: ${col[*]}"
            return 1
        fi
    done
}

winner=""
board_max=$((${#boards[@]} - 1))
for num in ${numbers[*]}; do
    for i in $(seq 0 $board_max); do
        boards[$i]=`echo "${boards[$i]}" | sed -E "s/(^|\s)$num($|\s)/\1X-$num\2/g"`
        check_board "${boards[$i]}"
        if [[ $? -eq 1 ]]; then
            winner="${boards[$i]}"
            break
        fi
    done
    if [ ! -z "$winner" ]; then
        break
    fi
done

if [ -z "$winner" ]; then
    echo "no winner after all numbers called!"
    exit 0
fi

echo "win on num $num: $winner"
total=0
win_numbers=($winner)
for spot in ${win_numbers[*]}; do
    if [[ ! "$spot" =~ X ]]; then
        total=$(($total + $spot))
    fi
done

echo "Part 1: unmarked total=$total, answer: " $(($total * $num))
echo ""


# Part 2

reset_boards

winner=""
board_max=$((${#boards[@]} - 1))
last_winning_num=0
for num in ${numbers[*]}; do
    for i in $(seq 0 $board_max); do
        if [ ! -z "${boards[$i]}" ]; then
            boards[$i]=`echo "${boards[$i]}" | sed -E "s/(^|\s)$num($|\s)/\1X-$num\2/g"`
            check_board "${boards[$i]}"
            if [[ $? -eq 1 ]]; then
                echo "winning num for board $i was $num: ${boards[$i]}"
                last_winning_num=$num
                winner="${boards[$i]}"
                boards[$i]=""
            fi
        fi
    done
done

total=0
win_numbers=($winner)
for spot in ${win_numbers[*]}; do
    if [[ ! "$spot" =~ X ]]; then
        total=$(($total + $spot))
    fi
done

echo "Part 2: unmarked total=$total, answer: " $(($total * $last_winning_num))
