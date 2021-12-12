#! /bin/bash

echo "DAY 12"

# data="./d12_test.txt"
# data="./d12_test_2.txt"
# data="./d12_test_3.txt"
data="./d12.txt"

# ------------------------------- Parsing

declare -A node_list
while IFS="-" read -r n1 n2; do
    if [[ -z ${node_list[$n1]} ]]; then
        node_list[$n1]=$n2
    else
        node_list[$n1]="${node_list[$n1]} $n2"
    fi
    if [[ -z ${node_list[$n2]} ]]; then
        node_list[$n2]=$n1
    else
        node_list[$n2]="${node_list[$n2]} $n1"
    fi
done < "$data"

# for node in ${!node_list[@]}; do
#     echo "links from $node: ${node_list[$node]}"
# done

lower="[a-z]+"
function part_one_link {
    links=("${node_list[$1]}")
    # echo "current path: $2"
    # echo "links fom $1: ${links[*]}"
    for link in ${links[*]}; do
        if [ $link = "end" ]; then
            paths=$(($paths + 1))
            # echo "found path: $2-end"
        elif ( [[ $link =~ $lower ]] && [[ $2 =~ "$link" ]] ); then
            # echo "already have '$link' in path..."
            noop=1
        else
            # echo "moving to $link"
            path="$2-$link"
            part_one_link $link $path
        fi
    done
}

IFS=" "
paths=0
# part_one_link "start" "start"

echo "Part 1, path count: $paths"
echo ""

# -----------------------------------

function part_two_link {
    local links=("${node_list[$1]}")
    # echo "current path (dupe=$dupe): $2"
    # echo "links fom $1: ${links[*]}"
    for link in ${links[*]}; do
        if [ $link = "end" ]; then
            paths=$(($paths + 1))
            dupe=""
            # echo "found path: $2-end"
            echo "paths: $paths"
        elif [ $link = "start" ]; then
            noop=1
        elif ( [[ $link =~ $lower ]] && [[ $2 =~ "$link" ]] ); then
            if [[ $3 -eq 0 ]]; then
                # echo "moving to $link (dupe)"
                path="$2-$link"
                part_two_link $link $path 1
            else
                # echo "already have '$link' in path (and a dupe)..."
                noop=1
            fi
        else
            # echo "moving to $link"
            path="$2-$link"
            part_two_link $link $path $3
        fi
    done
}

paths=0
part_two_link "start" "start" 0

echo "Part 2, path count: $paths"
