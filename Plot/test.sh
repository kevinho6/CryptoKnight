wget -qO- "https://api.coindesk.com/v1/bpi/historical/close.json" > history.txt

cat history.json | jq .bpi > cleanerHist.txt


cat cleanerHist.txt | sed s/'{'/''/g | sed s/','/''/g | sed s/'}'/''/g | sed s/'\"'/''/g | sed s/':'/''/g | sed s/'-'/''/g | sed s/'2017'/''/g | sed '/^\s*$/d' > cleanedHistory.dat

lines=0
cat cleanedHistory.dat | while read line
do
	echo $line $lines >> history.dat;
	lines=$((lines+1));
done

$SHELL
