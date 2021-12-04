#!/usr/bin/env bash
#

# maximal allowed distance in m (15km)
maxdist=15000
# logfile
logfile=/tmp/trackmunging.log
rm -f $logfile
touch $logfile
# Array schmutz
IFS=$'\n'
# while read line; do array+=($(echo $line | grep '<trkpt'| sed -e 's/<trkpt lat="//' -e 's/" lon="/:/' -e 's/">//')) ; done < testfile_short.gpx

# delete last array
unset coords
echo "Importing trackpoints from $1 - this needs some time"
# example line
#      <trkpt lat="54.757862600" lon="11.461799800">
while read line  
do 
  coords+=($(echo $line | grep '<trkpt'| sed -e 's/.*<trkpt lat="//' -e 's/" lon="/ /' -e 's/">//')) 
done < $1 

#for value in "${coords[@]}" ; do echo $value >> $logfile ; done
# search for dupes
echo "Checkin dupes:" >> $logfile
printf '%s\n' "${coords[@]}"|awk '!($0 in seen){seen[$0];next} 1' >> $logfile

# Werte rauspopeln und an distance checker geben.

elements=${#coords[*]}
echo "We have $elements coordinate points in this file"

# check if uneven, if discard last element
if [[ $((elements % 2)) -eq 0 ]]; then
  :
else
  echo "Trackpoints are odd, discarting the last"
  unset 'coords[-1]'
  elements=${#coords[*]}
  #echo "Coords in this file are now $elements"
fi 

# compute the distance between two coords
typeset -i n=0 max=${#coords[*]}
while (( n < max ))
do 
 m=$(echo $n+1|bc)
 lat1=$(echo ${coords[$n]}|awk '{print $1}')
 lon1=$(echo ${coords[$n]}|awk '{print $2}')
 lat2=$(echo ${coords[$m]}|awk '{print $1}')
 lon2=$(echo ${coords[$m]}|awk '{print $2}')
 # debug logfile
 #echo -e "$n \t$lat1 \t$lon1" >> $logfile
 #echo -e "$m \t$lat2 \t$lon2" >> $logfile

 # haversine does the distance compute stuff :-)
 distance=$(./haversine.sh $lat1 $lon1 $lat2 $lon2)

 if [[ $distance -gt $maxdist ]] ; then
   echo "Distance between Point $n to $m is $distance meters, check in ge: \"from: ${coords[$n]} to: ${coords[$m]}\""
   # find ${coords[$m]} in $1, delete the complete entry
   echo "Found $(grep -c "$lat2\" lon=\"$lon2" $1) occurrencies"
   sed -i "/$lat2\" lon=\"$lon2/,+3d" $1 # deletes all occurrencies, i want only to kill the first one...
   echo "Deleted a set of wrong trackpoints, run me again :-)"
   break
 fi  
 n=n+1

done


