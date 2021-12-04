#!/bin/bash

array=( "1.4344 2.554545" "3 2" "4 5" 7 2 6 7 "1.4344 2.554545" )
printf '%s\n' "${array[@]}"|awk '!($0 in seen){seen[$0];next} 1'
