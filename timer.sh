# timer until leaderboard shutdowns

count=604800 #week=86400 * 7
temp=604800
# assumes there are 30 days in a month
# no years included
while [ $count -gt 0 ]
do
month=$((count/2592000))
temp=$((2592000*month))
temp=$((count-temp))
day=$((temp/86400))
hour=$((86400*day))
temp=$((temp-hour))
hour=$((temp/3600))
minute=$((3600*hour))
temp=$((temp-minute))
minute=$((temp/60))
second=$((60*minute))
second=$((temp-second))

printf "Time Remaining (Months/Days/Hours/Minutes/Seconds): $month:$day:$hour:$minute:$second\n" > time_remaining
count=$((count-1))
sleep 1
done
echo