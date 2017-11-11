/bin/echo

clear

displayMenu() {
	echo "Menu"
    echo "1) View the Top 10 Cryptocurrencies"
    echo "2) View Your Portfolio"
    echo "3) Buy"
    echo "4) Sell"
    echo "5) Exit"
    printf ": " # Doesn't allow you to use echo -n
}


#WHEN BUYING HAVE THE CURRENT MARKET PRICE AND KEEP IT FLUCTUATING

getAPIData() {
	wget -qO- https://api.coinmarketcap.com/v1/ticker/?limit=10 > topCryptosData.txt # takes the top 10 cryptos and puts it into a file
}

cleanAPIData() { # gets rid of unneccesary api stuff, do i need this function?
	cat topCryptosData.txt | sed s/"\""/""/g | sed s/" "/""/g | sed s/"},"/"}"/g | sed s/","/""/g > cleanTopCryptosData.txt # only do this once
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

	#two while loops until it is a legit transaction

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

	#check if we have enough money to buy the quantity, the quantity has to be > 0
	#market price times quantity, Ex. S,1209382903
	echo
}

echo "Welcome to the Cryptocurrency Trading Simulator"
printf "Please input your starting amount: " # if starting amount is less than 0 then don't let this happen
read startingAmount
echo

while true
do
	displayMenu
	read userInput

	case $userInput in 
		1) topCryptosData
		;;
		2) echo
		;;
		3) echo
		;;
		4) sell
		;;
		5) echo "Goodbye!"
			break
		;;
		*) echo "That is not a valid input!"
	esac
done