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
		echo $crypto | grep "percent_change_24h" | awk -F: '{print "24 Hour Change:", $2}' #ADD THE PERCENTAGE SYMBOLS TO THE 3
		echo
	done
}

buy() {
	topCryptosData # Function Call

	cryptoRankToBuy=0

	while [ $cryptoRankToBuy -le 0 ] || [ $cryptoRankToBuy -gt 10 ]
	do
		printf "Input the rank of the cryptocurrency that you want to buy: "
		read cryptoRankToBuy
		if [ $cryptoRankToBuy -le 0 ] || [ $cryptoRankToBuy -gt 10 ]
		then
			echo "Invalid Rank"
		fi
	done

	quantityToBuy=0
	while [ $quantityToBuy -le 0 ]
	do
		printf "Input the quantity that you want to buy: "
		read quantityToBuy
		if [ $quantityToBuy -le 0 ]
		then
			echo "Invalid quantity"
		fi

		index=$((($cryptoRankToBuy - 1) * 17 + 7)) # Takes the line that has the price
		buyMarketPrice=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`
		totalMarketPrice=$(echo "$quantityToBuy * $buyMarketPrice" | bc)

		index=$((($cryptoRankToBuy - 1) * 17 + 5)) # Takes the line that has the ticker
		cryptoTicker=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`

		if [ $(echo "$availableCash <= $totalMarketPrice" | bc) -eq 1 ]
		then
			echo "You don't have enough cash available to buy $quantityToBuy $cryptoTicker"
			echo
			quantityToBuy=0
		else
			availableCash=$(echo "$availableCash - $totalMarketPrice" | bc)
		fi
	done

	echo
	echo "Bought $quantityToBuy $cryptoTicker for \$$totalMarketPrice"

	echo "B,$cryptoTicker,$buyMarketPrice,$quantityToBuy,$totalMarketPrice" >> transactionHistory.txt


# THIS IS A TEST, kind of like a ledger
# if it is not there then 

if [ `cat portfolioHoldings.txt | wc -l` -ge 1 ]
then
	#use a sed to replace the old value with the new incremented value
	# doesn't make sense because if you have the same numbers then they will also be replaced
else
	portfolioHoldings.txt >> echo "$cryptoTicker,$quantityToBuy"
fi

# STARTOFF WITH A THINGY WITH BALANCE
# what happens when a currency overtakes another on the to 10


cat portfolioHoldings

echo

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
	
		index=$((($cryptoRankToSell - 1) * 17 + 7)) # Takes the line that has the price
		sellMarketPrice=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`
		totalMarketPrice=$(echo "$quantityToSell * $sellMarketPrice" | bc)

		index=$((($cryptoRankToSell - 1) * 17 + 5)) # Takes the line that has the ticker
		cryptoTicker=`cat cleanTopCryptosData.txt | head -$index | tail -1 | awk -F: '{print $2}'`







# should have a portfolioHoldings.txt and is overwritten everytime

		if [ $(echo "$availableCash <= $totalMarketPrice" | bc) -eq 1 ]
		then
			echo "You don't have enough $cryptoTicker coins to sell $quantityToSell $cryptoTicker"
			echo
			quantityToSell=0
		else
			availableCash=$(echo "$availableCash + $totalMarketPrice" | bc)
		fi





	done



	echo
	echo "Sold $quantityToSell $cryptoTicker for \$$totalMarketPrice"

	echo "S,$cryptoTicker,$sellMarketPrice,$quantityToSell,$totalMarketPrice" >> transactionHistory.txt









	# check if we have enough coins to sell the quantity
	echo
}

startingAmount=100000
availableCash=$startingAmount
echo "Welcome to the Cryptocurrency Trading Simulator"
echo "Your portfolio starting amount is \$$startingAmount"
echo

while true
do
	echo "Your Available Cash is \$$availableCash" # WANT TO MAKE THIS CURRENT PORTFOLIO VALUE
	echo
	displayMenu # Function Call
	read userInput

	case $userInput in 
		1) topCryptosData # Function Call
		;;
		2) echo
		;;
		3) buy # Function Call
		;;
		4) sell # Function Call
		;;
		5) echo "Goodbye!"
			break
		;;
		*) echo "That is not a valid input!"
	esac
done