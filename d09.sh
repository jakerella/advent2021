#! /bin/bash

echo "DAY 09"

# data="./d09_test.txt"
data="./d09.txt"


# ------------------------------- Part 1

rows=()
while read -r line; do
    rows[${#rows[@]}]=$line
done < "$data"
# echo "rows: ${rows[*]}"

risk=0
max_i=$((${#rows[@]} - 1))
max_j=$((${#rows[0]} - 1))
low_points=()

for i in $(seq 0 $max_i); do
    for j in $(seq 0 $max_j); do
        # echo "proessing ${rows[$i]:$j:1}"
        left=$(($j - 1))
        right=$(($j + 1))
        up=$(($i - 1))
        down=$(($i + 1))
        adjacents=()
        if [[ $left -lt 0 ]]; then adjacents[0]=9; else adjacents[0]=${rows[$i]:$left:1}; fi
        if [[ $right -gt $max_j ]]; then adjacents[1]=9; else adjacents[1]=${rows[$i]:$right:1}; fi
        if [[ $i -gt 0 ]]; then adjacents[2]=${rows[$up]:$j:1}; else adjacents[2]=9; fi
        if [[ $i -lt $max_i ]]; then adjacents[3]=${rows[$down]:$j:1}; else adjacents[3]=9; fi
        # echo "adjacents to ${rows[$i]:$j:1}: ${adjacents[*]}"

        is_low=1
        for adj in ${adjacents[*]}; do
            if [[ $adj -le ${rows[$i]:$j:1} ]]; then is_low=0; fi
        done

        if [[ $is_low -eq 1 ]]; then
            # echo "found low point at ($i, $j): ${rows[$i]:$j:1}"
            risk=$(($risk + 1 + ${rows[$i]:$j:1}))
            low_points[${#low_points[@]}]="$i,$j"
        fi
    done
done

echo "Part 1, risk: $risk"

# ---------------------------------------

function map_basin {
    local pattern="(^|;)$1,$2(;|$)"
    if [[ ! "$mapped_points" =~ $pattern ]]; then
        mapped_points="$mapped_points$1,$2;"
        # echo "mapping $1, $2"

        local left=$(($2 - 1))
        local right=$(($2 + 1))
        local up=$(($1 - 1))
        local down=$(($1 + 1))
        if [[ $left -ge 0 && ${rows[$1]:$left:1} -lt 9 ]]; then
            # echo "mapping left from $1,$2 to ${rows[$1]:$left:1}"
            map_basin $1 $left
        fi
        if [[ $right -le $max_j && ${rows[$1]:$right:1} -lt 9 ]]; then
            # echo "mapping right from $1,$2 to ${rows[$1]:$right:1}"
            map_basin $1 $right
        fi
        if [[ $up -ge 0  && ${rows[$up]:$2:1} -lt 9 ]]; then
            # echo "mapping up from $1,$2 to ${rows[$up]:$2:1}"
            map_basin $up $2
        fi
        if [[ $down -le $max_i && ${rows[$down]:$2:1} -lt 9 ]]; then
            # echo "mapping down from $1,$2 to ${rows[$down]:$2:1}"
            map_basin $down $2
        fi
    # else
    #     echo "already mapped $1,$2"
    fi
}

first=0
second=0
third=0
for low_point in ${low_points[*]}; do
    IFS=","; low_point=($low_point)
    # echo "finding basin at ${low_point[0]}, ${low_point[1]}"
    mapped_points=""  # x1,y1;x2,y2;...
    map_basin ${low_point[*]}
    IFS=";"; mapped_points=($mapped_points)
    # echo "mapped_points (${#mapped_points[@]}): ${mapped_points[*]}"
    if [[ ${#mapped_points[@]} -gt $first ]]; then
        third=$second
        second=$first
        first=${#mapped_points[@]}
    elif [[ ${#mapped_points[@]} -gt $second ]]; then
        third=$second
        second=${#mapped_points[@]}
    elif [[ ${#mapped_points[@]} -gt $third ]]; then
        third=${#mapped_points[@]}
    fi
    
    # IFS=" "; counts[${#counts[@]}]=${#mapped_points[@]}
done

# IFS=$'\n' counts=($(sort <<<"${counts[*]}"))
# echo "counts: ${counts[*]}"

product=$(($first * $second * $third))
echo "Part 2: $first, $second, $third: $product"