#!/bin/bash
#A script to record time worked.

TIME_FILE=/home/kbladow/staq/timefile.txt

function tally {
  filecontent=( `cat $TIME_FILE` )

  i=0
  j=0
  in_times=(0)
  out_times=(0)
  difference=(0)
  dates=(0)

  #Create lists of dates and times.
  for a in "${!filecontent[@]}"
  do
    if [ ${filecontent[$a]} == 'In:' ]; then
      in_times[$i]=$(date -d "${filecontent[$a+1]} ${filecontent[$a+2]}" -u +%s)
      dates[$i]=$(date -d "${filecontent[$a+1]} ${filecontent[$a+2]}" +"%Y-%m-%d")
      ((i=i+1))
    elif [ ${filecontent[$a]} == 'Out:' ]; then
      out_times[$j]=$(date -d "${filecontent[$a+1]} ${filecontent[$a+2]}" -u +%s)
      ((j=j+1))
    fi
  done

  #Find the amount of time worked.
  for b in "${!in_times[@]}"
  do
    ((difference[b]=(out_times[b]-in_times[b])))
  done

  size=${#dates[@]}
  #Combine entries from the same date.
  for c in "${!dates[@]}"
  do
    z=$c
    for d in "${!dates[@]}"
    do
      ((z=z+1))
      if [ $z -ne $c ] && [ $z -lt $size ] && [[ ${#dates[$c]} -ne "" ]]; then
        if [ "${dates[$z]}" == "${dates[$c]}" ]; then
          ((difference[$c]=difference[$c]+difference[$z]))
          unset difference[$z]
          unset dates[$z]
        fi
      fi
    done
  done

  #Print out the totals for the days.
  for e in "${!difference[@]}"
  do
    ((hours=${difference[$e]}/3600))
    ((minutes=(${difference[$e]}-(hours*3600))/60))
    ((seconds=${difference[$e]}-(hours*3600)-(minutes*60)))
    echo "On ${dates[$e]}, you worked $hours hours, $minutes minutes, $seconds seconds."
  done

  #Calculate the total for all logged entries.
  total=0

  for f in "${!difference[@]}"
  do
    ((total=total + difference[$f]))
  done

  #Print out the total for all logged entries.
  ((hours=total/3600))
  ((minutes=(total-(hours*3600))/60))
  ((seconds=total-(hours*3600)-(minutes*60)))
  echo "You worked a total of $hours hours, $minutes minutes, and $seconds seconds."
}

#Enter time you started working.
if [ $1 = 'in' ]; then
  echo -e "In:     $(date +'%Y-%m-%d %T')">>$TIME_FILE

#Enter time you finished working.
elif [ $1 = 'out' ]; then
  echo -e "Out:    $(date +'%Y-%m-%d %T')">>$TIME_FILE
  tally

#Add up the time you spent working.
elif [ $1 = 'tally' ]; then
  tally

fi


