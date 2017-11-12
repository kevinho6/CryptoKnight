wget -qO- "https://api.coindesk.com/v1/bpi/historical/close.json" > history.txt

cat history.json | jq .bpi > cleanerHist.txt

cat cleanerHist.txt | sed s/'{'/''/g | sed s/','/''/g | sed s/'}'/''/g | sed s/'\"'/''/g | sed s/':'/''/g | sed s/'-'/''/g | sed s/'2017'/''/g | sed '/^\s*$/d' > cleanedHistory.dat

#if [ -f history.dat ]
#then
#	echo "Deleting old history"
#	rm history.dat
#fi

lines=0

cat cleanedHistory.dat | while read line
do
	echo $line $lines >> history.dat;
	lines=$((lines+1));
done

gnuplot << EOF
set term png 
set output "plot.png"
set ylabel "Market Price ($)"
set xlabel "Day"
set title "Market Price History"
plot 'history.dat' using 3:2 notitle w l
EOF
$SHELL
