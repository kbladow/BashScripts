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
  for t in "${!filecontent[@]}"
  do
    if [ ${filecontent[$t]} == 'In:' ]; then
      in_times[$i]=$(date -d "${filecontent[$t+1]} ${filecontent[$t+2]}" -u +%s)
      dates[$i]=$(date -d "${filecontent[$t+1]} ${filecontent[$t+2]}" +"%Y-%m-%d")
      ((i=i+1))
    elif [ ${filecontent[$t]} == 'Out:' ]; then
      out_times[$j]=$(date -d "${filecontent[$t+1]} ${filecontent[$t+2]}" -u +%s)
      ((j=j+1))
    fi
  done

  #Find the amount of time worked.
  for t in "${!in_times[@]}"
  do
    ((difference[t]=(out_times[t]-in_times[t])))
  done

  #Combine entries from the same date.
  for t in "${!dates[@]}"
  do
    for i in "${!dates[@]}"
    do
      ((i=t+i+1))
      if [ $i -ne $t ] && [ $i -le ${#dates[@]} ]; then
        if [ "${dates[$i]}" == "${dates[$t]}" ]; then
          ((difference[$t]=difference[$t]+difference[$i]))
          unset difference[$i]
          unset dates[$i]
        fi
      fi
    done
  done

  #Print out the totals for the days.
  for t in "${!difference[@]}"
  do
    ((hours=${difference[$t]}/3600))
    ((minutes=(${difference[$t]}-(hours*3600))/60))
    ((seconds=${difference[$t]}-(hours*3600)-(minutes*60)))
    echo "On ${dates[$t]}, you worked $hours hours, $minutes minutes, $seconds seconds."
  done

  #Calculate the total for all logged entries.
  total=0

  for t in "${!difference[@]}"
  do
    ((total=total + difference[$t]))
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


