clear

displayMenu() {
    echo "1) View the Top 10 Cryptocurrencies"
    echo "2) View Your Portfolio"
    echo "3) Buy"
    echo "4) Sell"
    echo "5) Exit"
    echo ": " # Doesn't allow you to use echo -n
}


#WHEN BUYING HAVE THE CURRENT MARKET PRICE AND KEEP IT FLUCTUATING

getAPIData() {
	wget -qO- https://api.coinmarketcap.com/v1/ticker/?limit=10 > topCryptosData.txt # takes the top 10 cryptos and puts it into a file
}

cleanAPIData() { # gets rid of unneccesary api stuff, do i need this function?
	cat topCryptosData.txt | sed 's/"\""/""/g' | sed 's/" "/""/g' > cleanTopCryptosData.txt # only do this once
}

topCryptos() {
	getAPIData	
	cleanAPIData

	IFS=$"{"

	for crypto in `cleanTopCryptosData.txt`
	do
		echo $crypto | grep "symbol"
	done
	#cat topCryptosData.txt | grep "symbol"
	#cat topCryptosData.txt | grep "price_usd"
	#cat topCryptosData.txt | grep "price_btc"
}

echo "Welcome to the Cryptocurrency Trading Simulator"
echo "Please input your starting amount: " # if starting amount is less than 0 then don't let this happen
read startingAmount

while true
do
	displayMenu
	read userInput

	case $userInput in 
		1) topCryptos
		;;
		2) echo
		;;
		3) echo
		;;
		4) echo
		;;
		5) echo "Goodbye!"
			break
		;;
		*) echo "That is not a valid input!"
	esac
done