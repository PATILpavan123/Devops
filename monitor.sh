bash script to get cpu, memory, disk usage
-----------------------------------------
#! /bin/bash
printf "Memory\t\tDisk\t\tCPU\n"
end=$((SECONDS+3600))
while [ $SECONDS -lt $end ]; do
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
echo "$MEMORY$DISK$CPU"
sleep 5
done
---------------------------------------------------------

mail -s "Monitor Report" pavanpatil0744@gmail.com < <( bash monitor.sh )

mail command:

mail -s "Monitor Report" admin@example.com < <( bash monitor.sh )

With sendmail:

echo "Subject: Monitor Report" | sendmail -v admin@example.com  < <( bash monitor.sh )

With ssmtp:

ssmtp admin@example.com < <( echo "Subject: Monitor" ; bash monitor.sh )

With curl and gmail:

bash monitor.sh > report.txt
curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
  --mail-from 'developer@gmail.com' --mail-rcpt 'admin@example.com' \
  --upload-file report.txt --user 'developer@gmail.com:your-accout-password'
  
  --------------
 #!/bin/bash

CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
THRESHOLD=20


mail -s 'Disk Space Alert' pavanpatil0744@gmail.com << EOF

Your root partition remaining free space is critically low. Used: $CURRENT% $MEMORY $CPU

EOF

-----------------------------------

# vi /opt/scripts/memory-alert-1.sh

#!/bin/bash
ramusage=$(free | awk '/Mem/{printf("RAM Usage: %.2f\n"), $3/$2*100}'| awk '{print $3}' | cut -d. -f1)

if [ $ramusage -ge 45 ]; then
SUBJECT="ATTENTION: Memory Utilization is High on $(hostname) at $(date)"
MESSAGE="/tmp/Mail.out"
TO="example@gmail.com"

  echo "Memory Current Usage is: $ramusage%" >> $MESSAGE
  echo "" >> $MESSAGE
  echo "------------------------------------------------------------------" >> $MESSAGE
  echo "Top Memory Consuming Processes Using top command" >> $MESSAGE
  echo "------------------------------------------------------------------" >> $MESSAGE
  echo "$(top -b -o +%MEM | head -n 20)" >> $MESSAGE
  echo "" >> $MESSAGE
  echo "------------------------------------------------------------------" >> $MESSAGE
  echo "Top Memory Consuming Processes Using ps command" >> $MESSAGE
  echo "------------------------------------------------------------------" >> $MESSAGE
  echo "$(ps -eo pid,ppid,%mem,%cpu,cmd --sort=-%mem | head)" >> $MESSAGE
  mail -s "$SUBJECT" "$TO" < $MESSAGE
  rm /tmp/Mail.out
  fi
