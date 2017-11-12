#Grab Top 10 currencies from coinmarketcap

#Extracted Function from HACKRPI.sh

getAPIData() {
	wget -qO- https://api.coinmarketcap.com/v1/ticker/?limit=10 > topCryptosData.txt
}

cleanAPIData() { 
	cat topCryptosData.txt | sed s/"\""/""/g | sed s/" "/""/g | sed s/"},"/"}"/g | sed s/","/""/g > cleanTopCryptosData.txt
}

getTopTen() {
	getAPIData
	cleanAPIData

	IFS=$"{"
	rm topTen.txt
	cat cleanTopCryptosData.txt | while read line
	do
		echo $line | grep "symbol" | awk -F: '{print $2}' >> topTen.txt
	done
}
#grabHistory() {
#	getTopTen
#	
#	while read symbol
#	do
#		echo $symbol $symbol $symbol
		#echo "https://min-api.cryptocompare.com/data/histoday?fsym=$symbol&tsym=USD&limit=60&aggregate=3&e=CCCAGG"
		
#		wget -qO- "https://min-api.cryptocompare.com/data/histoday?fsym=$symbol&tsym=USD&limit=60&aggregate=3&e=CCCAGG" > $symbol.txt
#	done <(cat topTen.txt)
#}
 

parseJSON() {
	#grabHistory
	close=()
	time=()
	for symbol in `cat topTen.txt`
	do
		#echo $symbol $symbol $symbol $symbol

		cat $symbol.txt | jq .Data | grep 'close' | sed s/','/''/g | awk -F: '{print $2}' > y$symbol.txt  
		
		cat $symbol.txt | jq .Data | grep 'time' | sed s/','/''/g | awk -F: '{print $2}' > x$symbol.txt
		


		paste x$symbol.txt y$symbol.txt > xy$symbol.dat
	done
}

singleLine() {
	gnuplot << EOF
	set term x11 persist
	set ylabel "$1 Price ($)"
	set xlabel "Day"
	set title "$1 History"
	set style line 1 lt 2 lw 3
	plot 'xy$1.dat' using 1:2 notitle w l
	EOF
}



display() {

	rank=1
	rankCoin=()
	echo "Select a Currency to View"
	cat topTen.txt | while read line
	do
		rankCoin+=$line
		echo $rank ") " $line
		((rank++))
	done
	echo "11) All Ten Currencies"
	read userInput

	case $userInput in
		1) fileName=$rankCoin[0]
			singleLine $fileName
			;;
		2) fileName=$rankCoin[1]
			singleLine $fileName
			;;
		3) fileName=$rankCoin[2]
			singeLine $fileName
			;;
		4) fileName=$rankCoin[3]
			singleLine $fileName
			;;
		5) fileName=$rankCoin[4]
			singleLine $fileName
			;;
		6) fileName=$rankCoin[5]
			singleLine $fileName
			;;
		7) fileName=$rankCoin[6]
			singleLine $fileName
			;;
		8) fileName=$rankCoin[7]
			singleLine $fileName
			;;
		9) fileName=$rankCoin[8]
			singleLine $fileName
			;;
		10) fileName=$rankCoin[9]
			singleLine $fileName
			;;
		11) gnuplot << EOF
			set ylabel "Price ($)
			set xLabel "Day"
			set title "History"
			
			set key left bottom
		
			set autoscale

			set style line 1 lt 1 lc rgb "#A00000" lw 2 pt 7 ps 1.5
			set style line 2 lt 1 lc rgb "#00A000" lw 2 pt 11 ps 1.5
			set style line 3 lt 1 lc rgb "#5060D0" lw 2 pt 9 ps 1.5
			set style line 4 lt 1 lc rgb "#0000A0" lw 2 pt 8 ps 1.5
			set style line 5 lt 1 lc rgb "#D0D000" lw 2 pt 13 ps 1.5
			set style line 6 lt 1 lc rgb "#00D0D0" lw 2 pt 12 ps 1.5
			set style line 7 lt 1 lc rgb "#B200B2" lw 2 pt 5 ps 1.5
			set style line 8 lt 1 lc rgb "#A3D021" lw 2 pt 14 ps 1.5
			set style line 8 lt 1 lc rgb "FF13ASD" lw 2 pt 6 ps 1.5
			set style line 9 lt 1 lc rgb "4444444" lw 2 pt 15 ps 1.5
			set style line 10 lt 1 lc rgb "9932000" lw 2 pt 16 ps 1.5

			plot "xy$rankCoin[0].dat" u 1:2 lp ls 1 t "$rankCoin[0]" w l, 
			"xy$rankCoin[1].dat" u 1:2 lp ls 2 t "$rankCoin[1]" w l, 
			"xy$rankCoin[2].dat" u 1:2 lp ls 3 t "$rankCoin[2]" w l,
			"xy$rankCoin[3].dat" u 1:2 lp ls 4 t "$rankCoin[3]" w l,
			"xy$rankCoin[4].dat" u 1:2 lp ls 5 t "$rankCoin[4]" w l,
			"xy$rankCoin[5].dat" u 1:2 lp ls 6 t "$rankCoin[5]" w l,
			"xy$rankCoin[6].dat" u 1:2 lp ls 7 t "$rankCoin[6]" w l,
			"xy$rankCoin[7].dat" u 1:2 lp ls 8 t "$rankCoin[7]" w l,
			"xy$rankCoin[8].dat" u 1:2 lp ls 9 t "$rankCoin[8]" w l,
			"xy$rankCoin[9].dat" u 1:2 lp ls 10 t "$rankCoin[9]" w l

			;;
		*) echo "Invalid Input"
	esac

}

parseJSON
display