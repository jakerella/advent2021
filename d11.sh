#! /bin/bash

echo "DAY 11"

# data="./d11_test.txt"
data="./d11.txt"

# ------------------------------- Parsing

octopi=()
while read -r line; do
    octopi[${#octopi[@]}]=$line
done < "$data"

# ------------------------------- Part 1 & 2

adj_diffs=(-1 0 1)
function flash {
    for y_diff in ${adj_diffs[*]}; do
        local y=$(($1 + $y_diff))
        if [[ $y -gt -1 && $y -lt 10 ]]; then
            for x_diff in ${adj_diffs[*]}; do
                local x=$(($2 + $x_diff))
                if [[ $x -gt -1 && $x -lt 10 ]]; then
                    local row=(`echo ${octopi[$y]} | grep -o .`)
                    if ! ( [ "${row[$x]}" = "f" ]  || [ "${row[$x]}" = "a" ] ); then
                        # echo "looking at adj $y,$x: ${row[$x]}"
                        if [[ ${row[$x]} -lt 9 ]]; then
                            row[$x]=$((${row[$x]} + 1))
                            octopi[$y]=`IFS=""; shift; echo "${row[*]}"`
                        else
                            row[$x]="a"
                            octopi[$y]=`IFS=""; shift; echo "${row[*]}"`
                            # echo "chain flash at $y, $x"
                            flash $y $x
                        fi
                    fi
                fi
            done
        fi
    done
}


steps=999
flashes=0
for step in $(seq 1 $steps); do
    echo "step $step"

    # add 1 to anything under 9...
    for i in $(seq 0 9); do
        row=(`echo ${octopi[$i]} | grep -o .`)
        # echo "looking at row: ${row[*]}"
        for j in $(seq 0 9); do
            if [[ ${row[$j]} -lt 9 ]]; then
                new_val=$((${row[$j]} + 1))
                row[$j]=$new_val
            else
                row[$j]="f"
            fi
        done
        octopi[$i]=`IFS=""; shift; echo "${row[*]}"`
    done

    # echo "after adding 1..."
    # for i in $(seq 0 9); do
    #     echo ${octopi[$i]}
    # done

    # fash 'em
    for i in $(seq 0 9); do
        for j in $(seq 0 9); do
            if [ "${octopi[$i]:$j:1}" = "f" ]; then
                # echo "flashing at $i, $j"
                flash $i $j
            fi
        done
    done

    # count 'em and reset
    step_flashes=0
    for i in $(seq 0 9); do
        row=(`echo ${octopi[$i]} | grep -o .`)
        for j in $(seq 0 9); do
            if [ "${octopi[$i]:$j:1}" = "f" ] || [ "${octopi[$i]:$j:1}" = "a" ]; then
                flashes=$(($flashes + 1))
                step_flashes=$(($step_flashes + 1))
                row[$j]=0
            fi
        done
        octopi[$i]=`IFS=""; shift; echo "${row[*]}"`
    done

    # echo "after flashing..."
    # for i in $(seq 0 9); do
    #     echo ${octopi[$i]}
    # done

    if [[ $step -eq 100 ]]; then
        echo "Part 1, flashes after $step steps: $flashes"
    fi

    if [[ $step_flashes -eq 100 ]]; then
        echo "Part 2, all flash on step: $step"
        break
    fi
done


