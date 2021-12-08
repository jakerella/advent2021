#! /bin/bash

echo "DAY 08"

# data="./d08_test.txt"
data="./d08.txt"


# ------------------------------- parsing

pattern="^([a-z ]+) \| ([a-z ]+)$"

all_signals=()
all_digits=()

while read -r line; do
    if [[ "$line" =~ $pattern ]]; then
        # echo "all_signals & digits: ${BASH_REMATCH[1]} -> ${BASH_REMATCH[2]}"
        all_signals[${#all_signals[@]}]=${BASH_REMATCH[1]}
        all_digits[${#all_digits[@]}]=${BASH_REMATCH[2]}
    fi
done < "$data"

# echo "signals & digits [0]: ${all_signals[0]} -> ${all_digits[0]}"
# echo "signals & digits [9]: ${all_signals[9]} -> ${all_digits[9]}"


# ------------------------------ Part 1

count_unique=0
for digit in ${all_digits[*]}; do
    if [[ ${#digit} -eq 2 || ${#digit} -eq 3 || ${#digit} -eq 4 || ${#digit} -eq 7 ]]; then
        count_unique=$(($count_unique + 1))
    fi
done

echo "Part 1, unique signals: $count_unique"


# ------------------------------ Part 2

# acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
# ab = 1       -> a/b right-top right-bottom
# dab = 7      ->  d  top
# eafb = 4     -> e/f left-top center
# acedgfb = 8  -> c/g left-bottom bottom
# cdfbe = 5  (1 a/b, 1 c/g, 2 e/f)
# gcdfa = 2  (1 a/b, 2 c/g, 1 e/f)
# fbcad = 3  (2 a/b, 1 c/g, 1 e/f)
# cefabd = 9 (2 a/b, 1 c/g, 2 e/f)
# cdfgeb = 6 (1 a/b, 2 c/g, 2 e/f)
# cagedb = 0 (2 a/b, 2 c/g, 1 e/f)

# 2  ->  d  a/b e/f c/g c/g
# 3  ->  d  a/b e/f a/b c/g
# 5  ->  d  e/f e/f a/b c/g
# 6  ->  d  e/f c/g c/g a/b e/f
# 9  ->  d  e/f e/f a/b a/b c/g
# 0  ->  d  a/b a/b c/g c/g e/f


function sort_and_join {
    sorted=(`echo $1 | grep -o . | sort`)
    local IFS=""; shift; echo "${sorted[*]}"
}

total=0
for i in $(seq 0 ${#all_signals[@]}); do
    rt_rb=0
    top=0
    lt_c=0
    lb_b=0

    signals=(${all_signals[$i]})
    declare -A decoded_digits
    scrambled_digits=(${all_digits[$i]})

    if [[ ${#signals[@]} -eq 0 ]]; then
        break
    fi

    one="(^|\s)([a-g]{2})(\s|$)"
    four="(^|\s)([a-g]{4})(\s|$)"
    seven="(^|\s)([a-g]{3})(\s|$)"
    eight="(^|\s)([a-g]{7})(\s|$)"
    if [[ "${all_signals[$i]}" =~ $one ]]; then
        rt_rb=${BASH_REMATCH[2]}
        key=`sort_and_join ${BASH_REMATCH[2]}`
        decoded_digits[$key]=1
    fi
    if [[ "${all_signals[$i]}" =~ $four ]]; then
        lt_c=`echo ${BASH_REMATCH[2]} | sed -E s/[$rt_rb]//g`
        key=`sort_and_join ${BASH_REMATCH[2]}`
        decoded_digits[$key]=4
    fi
    if [[ "${all_signals[$i]}" =~ $seven ]]; then
        top=`echo ${BASH_REMATCH[2]} | sed -E s/[$rt_rb]//g`
        key=`sort_and_join ${BASH_REMATCH[2]}`
        decoded_digits[$key]=7
    fi
    if [[ "${all_signals[$i]}" =~ $eight ]]; then
        all_others="$rt_rb$lt_c$top"
        lb_b=`echo ${BASH_REMATCH[2]} | sed -E s/[$all_others]//g`
        key=`sort_and_join ${BASH_REMATCH[2]}`
        decoded_digits[$key]=8
    fi
    # echo "pieces: rt_rb=$rt_rb, lt_c=$lt_c, lb_b=$lb_b, top=$top"

    # 5 => (1 rt_rb, 2 lt_c, 1 lb_b)
    # 2 => (1 rt_rb, 1 lt_c, 2 lb_b)
    # 3 => (2 rt_rb, 1 lt_c, 1 lb_b)
    # 6 => (1 rt_rb, 2 lt_c, 2 lb_b)
    # 9 => (2 rt_rb, 2 lt_c, 1 lb_b)
    # 0 => (2 rt_rb, 1 lt_c, 2 lb_b)
    for signal in ${signals[*]}; do
        if [[ ${#signal} -eq 5 || ${#signal} -eq 6 ]]; then
            rt_rb_count=`echo $signal | grep -o [$rt_rb] | wc -l`
            lt_c_count=`echo $signal | grep -o [$lt_c] | wc -l`
            lb_b_count=`echo $signal | grep -o [$lb_b] | wc -l`
            # echo "processing: $signal, counts: $rt_rb_count $lt_c_count $lb_b_count"

            key=`sort_and_join $signal`
            if [[ $rt_rb_count -eq 1 && $lt_c_count -eq 2 && $lb_b_count -eq 1 ]]; then
                decoded_digits[$key]=5
            elif [[ $rt_rb_count -eq 1 && $lt_c_count -eq 1 && $lb_b_count -eq 2 ]]; then
                decoded_digits[$key]=2
            elif [[ $rt_rb_count -eq 2 && $lt_c_count -eq 1 && $lb_b_count -eq 1 ]]; then
                decoded_digits[$key]=3
            elif [[ $rt_rb_count -eq 1 && $lt_c_count -eq 2 && $lb_b_count -eq 2 ]]; then
                decoded_digits[$key]=6
            elif [[ $rt_rb_count -eq 2 && $lt_c_count -eq 2 && $lb_b_count -eq 1 ]]; then
                decoded_digits[$key]=9
            elif [[ $rt_rb_count -eq 2 && $lt_c_count -eq 1 && $lb_b_count -eq 2 ]]; then
                decoded_digits[$key]=0
            fi
        fi
    done

    # digit_string="digits: "
    # for signal in ${!decoded_digits[@]}; do
    #     digit_string="$digit_string$signal=${decoded_digits[$signal]}, "
    # done
    # echo $digit_string

    number=""
    for digit in ${scrambled_digits[*]}; do
        sorted_digit=`sort_and_join $digit`
        number="$number${decoded_digits[$sorted_digit]}"
    done
    echo "number: $number"

    total=$(($total + ${number#0}))
done

echo "Part 2, digit total: $total"
