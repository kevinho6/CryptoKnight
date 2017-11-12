clear

displayMenu() {
	echo "Menu"
    echo "1) View the Top 10 Cryptocurrencies"
    echo "2) View Your Portfolio"
    echo "3) Buy"
    echo "4) Sell"
    echo "5) Exit"
    printf ": " # Because echo -n is not working
}


#WHEN BUYING HAVE THE CURRENT MARKET PRICE AND KEEP IT FLUCTUATING

getAPIData() {
	wget -qO- https://api.coinmarketcap.com/v1/ticker/?limit=10 > topCryptosData.txt
}

cleanAPIData() { # Gets rid of unneccesary api stuff
	cat topCryptosData.txt | sed s/"\""/""/g | sed s/" "/""/g | sed s/"},"/"}"/g | sed s/","/""/g > cleanTopCryptosData.txt
}

topCryptosData() {
	getAPIData	
	cleanAPIData

	IFS=$"{"

	for crypto in `cat cleanTopCryptosData.txt`
	do
		echo $crypto | grep "rank" | awk -F: '{print "Rank:", $2}'
		echo $crypto | grep "symbol" | awk -F: '{print "Ticker:", $2}'
		echo $crypto | grep "name" | awk -F: '{print "Name:", $2}'
		echo $crypto | grep "price_usd" | awk -F: '{print "Price USD:", $2}'
		echo $crypto | grep "price_btc" | awk -F: '{print "Price BTC:", $2}'
		echo $crypto | grep "24h_volume_usd" | awk -F: '{print "24 Hour Volume:", $2}'
		echo $crypto | grep "percent_change_1h" | awk -F: '{print "1 Hour Change:", $2}'
		echo $crypto | grep "percent_change_24h" | awk -F: '{print "24 Hour Change:", $2}'
		echo
	done
}

sell() {
	topCryptosData # Function Call

	cryptoRankToSell=0

	while [ $cryptoRankToSell -le 0 ] || [ $cryptoRankToSell -gt 10 ]
	do
		printf "Input the rank of the cryptocurrency that you want to sell: "
		read cryptoRankToSell
		if [ $cryptoRankToSell -le 0 ] || [ $cryptoRankToSell -gt 10 ]
		then
			echo "Invalid Rank"
		fi
	done

	quantityToSell=0
	while [ $quantityToSell -le 0 ]
	do
		printf "Input the quantity that you want to sell: "
		read quantityToSell
		if [ $quantityToSell -le 0 ]
		then
			echo "Invalid quantity"
		fi
	done

	index=$((($cryptoRankToSell - 1) * 17 + 7)) # Takes the line that has the price
	sellMarketPrice=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`
	totalMarketPrice=$(echo "$quantityToSell * $sellMarketPrice" | bc)

	index=$((($cryptoRankToSell - 1) * 17 + 5)) # Takes the line that has the ticker
	cryptoTicker=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`

	echo
	echo "Sold $quantityToSell $cryptoTicker for \$$totalMarketPrice"

	# check if we have enough money to buy the quantity

	echo "S,$cryptoTicker,$sellMarketPrice,$quantityToSell,$totalMarketPrice" >> transactionHistory.txt
	cat transactionHistory.txt



	portfolioAmount=$(echo "$portfolioAmount - $totalMarketPrice" | bc)



	echo
}

startingAmount=100000
portfolioAmount=$startingAmount
echo "Welcome to the Cryptocurrency Trading Simulator"
echo "Your portfolio starting amount is \$$startingAmount"
echo

while true
do
	echo "Your portfolio value is \$$portfolioAmount"
	echo
	displayMenu # Function Call
	read userInput

	case $userInput in 
		1) topCryptosData # Function Call
		;;
		2) echo
		;;
		3) echo
		;;
		4) sell # Function Call
		;;
		5) echo "Goodbye!"
			break
		;;
		*) echo "That is not a valid input!"
	esac
done