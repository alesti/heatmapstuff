#!/usr/bin/env bash
#

# maximal allowed distance in m (15km)
maxdist=15000
logfile=/tmp/trackmunging.log

# logfile
rm -f $logfile
touch $logfile


echo "Importing trackpoints from $1 - this needs some time"
unset coords
# example line
#      <trkpt lat="54.757862600" lon="11.461799800">
IFS=$'\n'
while read line  
do 
  coords+=($(echo $line | grep '<trkpt'| sed -e 's/.*<trkpt lat="//' -e 's/" lon="/ /' -e 's/">//')) 
done < $1 

# search for dupes
#echo "Checkin dupes:" >> $logfile
#printf '%s\n' "${coords[@]}"|awk '!($0 in seen){seen[$0];next} 1' >> $logfile

elements=${#coords[*]}
echo -e "We have $elements trackpoints in this file. Calculating distances...\n"

# check if uneven, discard last element
if [[ $((elements % 2)) -eq 0 ]]; then
  :
else
  #echo "Trackpoints are odd, discarting the last"
  unset 'coords[-1]'
  #elements=${#coords[*]}
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

 # haversine does the distance compute stuff
 if [[ -z "$lat1" || -z "$lat2" ]] ; then 
   echo -e "No more trackpoints to check, change to next file.\n"
   break
 else
   distance=$(./haversine.sh $lat1 $lon1 $lat2 $lon2)
 fi
 if [[ $distance -gt $maxdist ]] ; then
   echo "Distance between trackpoints $n and $m is $distance meters, check in GoogleEarth: \"from: ${coords[$n]} to: ${coords[$m]}\""
   # find ${coords[$m]} in $1, delete the complete entry
   echo "Found $(grep -c "$lat2\" lon=\"$lon2" $1) occurrencies"
   sed -i "/$lat2\" lon=\"$lon2/,+3d" $1 # deletes all occurrencies!
   echo -e "Deleted a set of wrong trackpoints, restart me :-)\n\n"
   break
 fi  
 n=n+1

done


