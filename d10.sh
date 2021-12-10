#! /bin/bash

echo "DAY 10"

# data="./d10_test.txt"
data="./d10.txt"


# ------------------------------- Part 1

# test sample
# {([(<{}[<>[]}>{[]{[(<()> - Expected ], but found } instead.
# [[<[([]))<([[{}[[()]]] - Expected ], but found ) instead.
# [{[{({}]{}}([{[{{{}}([] - Expected ), but found ] instead.
# [<(<(<(<{}))><([]([]() - Expected >, but found ) instead.
# <{([([[(<>()){}]>(<<{{ - Expected ], but found > instead.

declare -A matchers
matchers[")"]="("
matchers["]"]="["
matchers["}"]="{"
matchers[">"]="<"

bad_chars=()
closings=()
openers="[\(\[\{\<]"
while read -r line; do
    symbols=(`echo $line | grep -o .`)
    opened=()
    bad_line=0
    for symbol in ${symbols[*]}; do
        if [[ "$symbol" =~ $openers ]]; then
            opened[${#opened[@]}]=$symbol
            # echo "added opener $symbol: ${opened[*]}"
        elif [ "${matchers[$symbol]}" = "${opened[-1]}" ]; then
            one_less=$((${#opened[@]} - 1))
            opened=("${opened[@]:0:$one_less}")
            # echo "removed matching opener for $symbol: ${opened[*]}"
        else
            echo "syntax error, expected match to ${opened[-1]}, but found $symbol"
            bad_chars[${#bad_chars[@]}]=$symbol
            bad_line=1
            break
        fi
    done

    # Part 2
    if [[ $bad_line -eq 0 ]]; then
        # echo "processing incomplete line with openers: ${opened[*]}"
        line_closing=""
        for sub in $(seq 1 ${#opened[@]}); do
            i=$(($sub * -1))
            # echo "closing ${opened[$i]}"
            line_closing="$line_closing${opened[$i]}"
        done
        closings[${#closings[@]}]=$line_closing
    fi

done < "$data"

declare -A points
points[")"]=3
points["]"]=57
points["}"]=1197
points[">"]=25137
score=0
for char in ${bad_chars[*]}; do
    score=$(($score + ${points[$char]}))
done

echo "Part 1, score: $score"

echo ""

# echo "closings: ${closings[*]}"

declare -A points
points["("]=1
points["["]=2
points["{"]=3
points["<"]=4
scores=()
for closing in ${closings[*]}; do
    line_score=0
    symbols=(`echo $closing | grep -o .`)
    for symbol in ${symbols[*]}; do
        line_score=$(($line_score * 5))
        line_score=$(($line_score + ${points[$symbol]}))
    done
    scores[${#scores[@]}]=$line_score
    # echo "score for $closing: $line_score"
done

IFS=$'\n' sorted=(`sort -n <<< "${scores[*]}"`)
echo ${sorted[*]}
middle=$((${#sorted[@]} / 2))

echo "Part 2, score: ${sorted[$middle]}"
