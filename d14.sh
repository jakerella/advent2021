#! /bin/bash

echo "DAY 14"

data="./d14_test.txt"
# data="./d14.txt"

# ------------------------------- Parsing

template_pattern="^[A-Z]+$"
pair_pattern="^([A-Z]{2}) \-> ([A-Z])$"
template=""
declare -A pairs
while read -r line; do
    if [[ $line =~ $template_pattern ]]; then
        # template=(`echo $line | grep -o .`)
        template=$line
        # echo "template: ${template[*]}"
    elif [[ $line =~ $pair_pattern ]]; then
        pairs[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
        # echo "set pair ${BASH_REMATCH[1]} = ${BASH_REMATCH[2]}"
    fi
done < "$data"


# ------------------------------- Part 1 & 2

declare -A counts
dir="d14"
mkdir "$dir"
mkdir "$dir/counts"
mkdir "$dir/memo"

function increment_letter {
    local count=0
    if [[ -f "$dir/counts/$1" ]]; then count=`cat "$dir/counts/$1"`; fi
    count=$(($count + 1))
    # echo "incremented $1 to $count" >&2
    echo $count > "$dir/counts/$1"
}

function process_file {
    IFS="," read -r -a letters < "$dir/memo/$1"
    echo "using memoize file for $1: ${letters[*]}" >&2
    for letter in ${letters[*]}; do
        # if [ -z ${counts[$letter]} ]; then counts[$letter]=0; fi
        # local curr=${counts[$letter]}
        # counts[$letter]=$(($curr + 1))
        if ! [ -z $letter ]; then increment_letter $letter; fi
    done
}

function insert {
    key="$1$2"

    if [[ -f "$dir/memo/$key" ]]; then
        # echo "$key file exists" >&2
        process_file $key
        return
    fi

    local new_letter=${pairs[$1]}
    local steps_left=$(($2 - 1))
    # echo "insert $new_letter in $1 ($steps_left steps left)" >&2
    local mem="$new_letter"

    # if [ -z ${counts[$new_letter]} ]; then counts[$new_letter]=0; fi
    # local curr=${counts[$new_letter]}
    # counts[$new_letter]=$(($curr + 1))
    increment_letter $new_letter

    if [ $2 -gt 1 ]; then
        local left_pair="${1:0:1}$new_letter"
        local right_pair="$new_letter${1:1:1}"
        # echo "recursing to left:$left_pair, right:$right_pair" >&2
        local left_letters=`insert $left_pair $steps_left`
        local right_letters=`insert $right_pair $steps_left`
        mem="$mem,$left_letters,$right_letters"
    fi

    echo "$mem" > "$dir/memo/$key"
    echo $mem
}

# count letters in the initial template
max_i=$((${#template} - 1))
for i in $(seq 0 $max_i); do
    letter=${template:$i:1}
    # if [ -z ${counts[$letter]} ]; then counts[$letter]=0; fi
    # curr=${counts[$letter]}
    # counts[$letter]=$(($curr + 1))
    increment_letter $letter
done

steps=10
max_pair_i=$(($max_i - 1))
for i in $(seq 0 $max_pair_i); do
    next_i=$(($i + 1))
    pair="${template:$i:1}${template:$next_i:1}"
    echo ">> handling initial pair: $pair"
    mem=`insert $pair $steps`
done


most_letter=""
most_count=0
least_letter=""
least_count=9999999999
for letter_file in $dir/counts/*; do
    count=`cat $letter_file`
    IFS="/" read -r d1 d2 letter <<< "$letter_file"
    echo "$letter => $count"
    if [[ $count -gt $most_count ]]; then
        most_count=$count
        most_letter=$letter
    elif [[ $count -lt $least_count ]]; then
        least_count=$count
        least_letter=$letter
    fi
done
# for letter in ${!counts[@]}; do
#     echo "$letter => ${counts[$letter]}"
#     if [[ ${counts[$letter]} -gt $most_count ]]; then
#         most_count=${counts[$letter]}
#         most_letter=$letter
#     elif [[ ${counts[$letter]} -lt $least_count ]]; then
#         least_count=${counts[$letter]}
#         least_letter=$letter
#     fi
# done

diff=$(($most_count - $least_count))
echo "After $steps steps: most is $most_letter ($most_count), least is $least_letter ($least_count): $diff"

rm -rf "$dir/"
