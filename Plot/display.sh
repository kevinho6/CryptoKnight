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

display() {
	rank=1
	rankCoin=()
	echo "Select a Currency to View"
	cat topTen.txt | while read line
	do
		rankCoin+=$line
		echo $rank $line
		((rank++))
	done
	read userInput

	case $userInput in
		1) fileName=$rankCoin[0]
			;;
		2) fileName=$rankCoin[1]
			;;
		3) fileName=$rankCoin[2]
			;;
		4) fileName=$rankCoin[3]
			;;
		5) fileName=$rankCoin[4]
			;;
		6) fileName=$rankCoin[5]
			;;
		7) fileName=$rankCoin[6]
			;;
		8) fileName=$rankCoin[7]
			;;
		9) fileName=$rankCoin[8]
			;;
		10) fileName=$rankCoin[9]
			;;
		*) echo "Invalid Input"
	esac

	gnuplot << EOF
	set term x11 persist
	set ylabel "$fileName Price ($)"
	set xlabel "Day"
	set title "$filename History"
	plot 'xy$fileName.dat' using 1:2 notitle w l
	EOF

}

parseJSON
display
