#! /bin/bash

echo "DAY 05"

# data="./d05_test.txt"
data="./d05.txt"

max_x=0
max_y=0
rows=()
grid=()
danger_count=0

function parse_coord {
    local coord_regex="^([0-9]+),([0-9]+) \-> ([0-9]+),([0-9]+)$"
    max_x=0
    max_y=0
    rows=()
    
    while read -r line; do
        if [[ "$line" =~ $coord_regex ]]; then
            if [ "$1" = "no" ]; then
                if [[ ${BASH_REMATCH[1]} -eq ${BASH_REMATCH[3]} || ${BASH_REMATCH[2]} -eq ${BASH_REMATCH[4]} ]]; then
                    # echo "horiz/vert line: ${BASH_REMATCH[@]:1}"
                    rows[${#rows[@]}]="${BASH_REMATCH[@]:1}"
                    if [[ ${BASH_REMATCH[1]} -gt $max_x ]]; then
                        max_x=${BASH_REMATCH[1]}
                    fi
                    if [[ ${BASH_REMATCH[3]} -gt $max_x ]]; then
                        max_x=${BASH_REMATCH[3]}
                    fi
                    if [[ ${BASH_REMATCH[2]} -gt $max_y ]]; then
                        max_y=${BASH_REMATCH[2]}
                    fi
                    if [[ ${BASH_REMATCH[4]} -gt $max_y ]]; then
                        max_y=${BASH_REMATCH[4]}
                    fi
                fi
            else
                rows[${#rows[@]}]="${BASH_REMATCH[@]:1}"
                if [[ ${BASH_REMATCH[1]} -gt $max_x ]]; then
                    max_x=${BASH_REMATCH[1]}
                fi
                if [[ ${BASH_REMATCH[3]} -gt $max_x ]]; then
                    max_x=${BASH_REMATCH[3]}
                fi
                if [[ ${BASH_REMATCH[2]} -gt $max_y ]]; then
                    max_y=${BASH_REMATCH[2]}
                fi
                if [[ ${BASH_REMATCH[4]} -gt $max_y ]]; then
                    max_y=${BASH_REMATCH[4]}
                fi
            fi
        fi
    done < "$data"

    # echo "rows: ${rows[*]}"
}

function create_grid {
    grid=()

    echo "max_x $max_x, max_y: $max_y"

    for i in $(seq 0 $max_y); do
        row=()
        for j in $(seq 0 $max_x); do
            row[$j]="0"
        done
        grid[$i]="${row[*]}"
        # echo "${grid[$i]}"
    done
}

function draw_perpendicular {
    local max_i=$((${#rows[@]} - 1))
    
    for i in $(seq 0 $max_i); do
        coord=(${rows[$i]})
        # echo "row $i: ${coord[*]}"
        x1=${coord[0]}
        y1=${coord[1]}
        x2=${coord[2]}
        y2=${coord[3]}

        if [[ $y1 -lt $y2 ]]; then
            echo "marking col $x1 from $y1 to $y2"
            for j in $(seq $y1 $y2); do
                row=(${grid[$j]})
                if [[ ${row[$x1]} -eq 1 ]]; then
                    danger_count=$(($danger_count + 1))
                fi
                row[$x1]=$((${row[$x1]} + 1))
                grid[$j]="${row[*]}"
            done

        elif [[ $y2 -lt $y1 ]]; then
            echo "marking col $x1 from $y2 to $y1"
            for j in $(seq $y2 $y1); do
                row=(${grid[$j]})
                if [[ ${row[$x1]} -eq 1 ]]; then
                    danger_count=$(($danger_count + 1))
                fi
                row[$x1]=$((${row[$x1]} + 1))
                grid[$j]="${row[*]}"
            done

        elif [[ $x1 -lt $x2 ]]; then
            echo "marking row $y1 from $x1 to $x2"
            row=(${grid[$y1]})
            for j in $(seq $x1 $x2); do
                if [[ ${row[$j]} -eq 1 ]]; then
                    danger_count=$(($danger_count + 1))
                fi
                row[$j]=$((${row[$j]} + 1))
            done
            grid[$y1]="${row[*]}"

        else
            echo "marking row $y1 from $x2 to $x1"
            row=(${grid[$y1]})
            for j in $(seq $x2 $x1); do
                if [[ ${row[$j]} -eq 1 ]]; then
                    danger_count=$(($danger_count + 1))
                fi
                row[$j]=$((${row[$j]} + 1))
            done
            grid[$y1]="${row[*]}"
        fi
    done
}

function draw_diagonals {
    local max_i=$((${#rows[@]} - 1))

    for i in $(seq 0 $max_i); do
        coord=(${rows[$i]})
        # echo "row $i: ${coord[*]}"
        x1=${coord[0]}
        y1=${coord[1]}
        x2=${coord[2]}
        y2=${coord[3]}

        if [[ $x1 -ne $x2 && $y1 -ne $y2 ]]; then
            echo "marking diagonal $x1,$y1 -> $x2,$y2"

            x=$x1
            y=$y1
            count=$(($x2 - $x1))
            count=${count#-}  # absolute value

            for diff in $(seq 0 $count); do
                # echo "marking $x,$y"
                row=(${grid[$y]})
                if [[ ${row[$x]} -eq 1 ]]; then
                    danger_count=$(($danger_count + 1))
                fi
                row[$x]=$((${row[$x]} + 1))
                grid[$y]="${row[*]}"

                if [[ $x2 -lt $x1 ]]; then
                    x=$(($x - 1))
                else
                    x=$(($x + 1))
                fi
                if [[ $y2 -lt $y1 ]]; then
                    y=$(($y - 1))
                else
                    y=$(($y + 1))
                fi
            done
        fi
    done
}

function part_one {
    parse_coord no
    create_grid
    danger_count=0
    draw_perpendicular

    # for i in $(seq 0 $max_y); do
    #     echo "${grid[$i]}"
    # done

    echo "Part 1: $danger_count"
}

# -----------------------------------

function part_two {
    danger_count=0
    parse_coord no
    create_grid
    draw_perpendicular
    parse_coord yes
    draw_diagonals

    # for i in $(seq 0 $max_y); do
    #     echo "${grid[$i]}"
    # done

    echo "Part 2: $danger_count"
}


# -----------------------------------

# part_one
echo ""
part_two
