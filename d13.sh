#! /bin/bash

echo "DAY 13"

# data="./d13_test.txt"
data="./d13.txt"

# ------------------------------- Parsing

num_pattern="[0-9]+"
fold_pattern="^fold along (x|y)=([0-9]+)$"
declare -A rows
max_y=0
max_x=0
folds=()
while IFS="," read -r x y; do
    if [[ "$x" =~ $fold_pattern ]]; then
        # echo "fold at ${BASH_REMATCH[1]} = ${BASH_REMATCH[2]}"
        folds[${#folds[@]}]="${BASH_REMATCH[1]}=${BASH_REMATCH[2]}"
    elif [[ "$x" =~ $num_pattern ]]; then
        row=(${rows[$y]})
        row[${#row[@]}]=$x
        IFS=$'\n' row=(`sort -n <<< "${row[*]}"`)
        IFS=" "
        rows[$y]="${row[*]}"
        if [ $y -gt $max_y ]; then max_y=$y; fi
        if [ $x -gt $max_x ]; then max_x=$x; fi
        # echo "row at y=$y: ${rows[$y]}"
    fi
done < "$data"
unset IFS

# for y in ${!rows[@]}; do
#     echo "$y: ${rows[$y]}"
# done


function fold_on_x {
    # echo "folding on x=$1"
    for y in ${!rows[@]}; do
        IFS=" "
        row=(${rows[$y]})
        new_row=""
        for x in ${row[*]}; do
            if [ $x -gt $1 ]; then
                new_x=$(($1 - ($x - $1)))
                new_row="$new_row $new_x"
            else
                new_row="$new_row $x"
            fi
        done
        row=(${new_row[*]})
        IFS=$'\n' row=(`sort -n -u <<< "${row[*]}"`)
        IFS=" "
        rows[$y]="${row[*]}"
        # echo "new $y: ${rows[$y]}"
    done
    max_x=$(($1 - 1))
}

function fold_on_y {
    # echo "folding on y=$1"
    for y in ${!rows[@]}; do
        if [ $y -gt $1 ]; then
            new_y=$(($1 - ($y - $1)))
            # echo "merging $y (${rows[$y]}) and $new_y (${rows[$new_y]})"
            IFS=" "
            row=(${rows[$new_y]} ${rows[$y]})
            IFS=$'\n' row=(`sort -n -u <<< "${row[*]}"`)
            IFS=" "
            rows[$new_y]="${row[*]}"
            # echo "merged @ $new_y: ${rows[$new_y]}"
            unset rows[$y]
        fi
    done
    max_y=$(($1 - 1))
}

function count_dots {
    local count=0
    for y in ${!rows[@]}; do
        IFS=" "
        local row=(${rows[$y]})
        count=$(($count + ${#row[@]}))
    done
    echo $count
}

first=1
for fold in ${folds[*]}; do
    IFS="="; read -r dir pos <<< "$fold"
    # echo "fold at $dir = $pos"
    if [ $dir = "x" ]; then
        fold_on_x $pos
    elif [ $dir = "y" ]; then
        fold_on_y $pos
    else
        echo "bad fold... $fold"
    fi
    
    if [ $first -eq 1 ]; then
        count=`count_dots`
        echo "Part 1: After 1 fold, $count dots";
        first=0;
    fi
done
unset IFS

echo ""
echo "Part 2..."

# max_y=0
# for y in ${!rows[@]}; do
#     if [ $y -gt $max_y ]; then max_y=$y; fi
# done

# echo "max_y: $max_y; max_x: $max_x"

for y in $(seq 0 $max_y); do
    # echo "row: ${rows[$y]}"
    row_string=""
    for x in $(seq 0 $max_x); do
        x_pattern="(^|\s)$x(\s|$)"
        if [[ "${rows[$y]}" =~ $x_pattern ]]; then
            row_string="$row_string#"
        else
            row_string="$row_string."
        fi
    done
    echo "$row_string"
done
