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
grabHistory() {
	getTopTen
	
	cat topTen.txt | while read symbol
	do
		echo $symbol $symbol $symbol
		echo "https://min-api.cryptocompare.com/data/histoday?fsym=$symbol&tsym=USD&limit=60&aggregate=3&e=CCCAGG"
		
		wget -qO- "https://min-api.cryptocompare.com/data/histoday?fsym=$symbol&tsym=USD&limit=60&aggregate=3&e=CCCAGG" > $symbol.txt
	done
}
 

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
	set term x11 persist background rgb 'black'
	set ylabel "$1 Price ($)" tc rgb 'white'
	set xlabel "Day" tc rgb 'white'
	set title "$1 History" tc rgb 'white'
	set autoscale
	set grid lc rgb 'white'
	set border lc rgb 'white'
	set style line 1 lt 2 lw 3
	plot 'xy$1.dat' using 1:2 notitle w l
EOF
}

allLines()
{
	gnuplot << EOF
	set term x11 persist background 'black'
	set ylabel "Price ($) tc rgb 'white'
	set xlabel "Day" tc rgb 'white'
	set title "History" tc rgb 'white
	set grid lc rgb 'white'
	set border lc rgb 'white'
	set key left bottom
	set autoscale

	set style line 1 lt 1 lc rgb "#A00000" lw 2 pt 7 ps 1.5
	set style line 2 lt 1 lc rgb "#00A000" lw 2 pt 11 ps 1.5
	set style line 3 lt 1 lc rgb "#5060D0" lw 2 pt 9 ps 1.5
	set style line 4 lt 1 lc rgb "#0000A0" lw 2 pt 8 ps 1.5
	set style line 5 lt 1 lc rgb "#D0D000" lw 2 pt 13 ps 1.5
	set style line 6 lt 1 lc rgb "#00D0D0" lw 2 pt 12 ps 1.5
	set style line 7 lt 1 lc rgb "#B200B2" lw 2 pt 5 ps 1.5
	set style line 8 lt 1 lc rgb "#C9C79C" lw 2 pt 6 ps 1.5
	set style line 9 lt 1 lc rgb "#D02090" lw 2 pt 15 ps 1.5
	set style line 10 lt 1 lc rgb "#98BAD7" lw 2 pt 16 ps 1.5

	plot "xyBTC.dat" u 1:2 lp ls 1 t "BTC" with lines,w l, \
	"xyBCH.dat" u 1:2 lp ls 2 t "BCH" with lines, \
	"xyETH.dat" u 1:2 lp ls 3 t "ETH" with lines, \
	"xyXRP.dat" u 1:2 lp ls 4 t "XRP" with lines, \
	"xyLTC.dat" u 1:2 lp ls 5 t "LTC" with lines, \
	"xyDASH.dat" u 1:2 lp ls 6 with lines,  \
	"xyETC.dat" u 1:2 lp ls 7 t "ETC" with lines, \
	"xyXMR.dat" u 1:2 lp ls 8 t "XMR" with lines,  \
	"xyNEO.dat" u 1:2 lp ls 9 t "NEO" with lines, \
	"xyXEM.dat" u 1:2 lp ls 10 t "XEM" with lines
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
		1) fileName="BTC"
			singleLine $fileName
			;;
		2) fileName="BCH"
			singleLine $fileName
			;;
		3) fileName="ETH"
			singeLine $fileName
			;;
		4) fileName="XRP"
			singleLine $fileName
			;;
		5) fileName="LTC"
			singleLine $fileName
			;;
		6) fileName="DASH"
			singleLine $fileName
			;;
		7) fileName="ETC"
			singleLine $fileName
			;;
		8) fileName="XMR"
			singleLine $fileName
			;;
		9) fileName="NEO"
			singleLine $fileName
			;;
		10) fileName="XEM"
			singleLine $fileName
			;;
		11) allLines
		;;
		12) echo "Update Top Ten History"
			grabHistory
			;;
		*) echo "Invalid Input"
		break
	esac

}

parseJSON
display
