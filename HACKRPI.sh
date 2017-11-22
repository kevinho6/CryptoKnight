# CHANGES TO BE IMPLEMENTED
# When you have 0 quantity, delete it from outputting it on the view_profile function

tput setab 0
tput setaf 7
clear

startingAmount=100000

displayMenu() {
	echo "Menu"
    echo "1) View the Top 10 Cryptocurrencies"
    echo "2) View Your Portfolio"
    echo "3) Buy"
    echo "4) Sell"
    echo "5) View Leaderboard"
    echo "6) View Graph"
    echo "7) Exit"
    printf ": "
}

getAPIData() {
	wget -qO- https://api.coinmarketcap.com/v1/ticker/?limit=10 > topCryptosData.txt
}

cleanAPIData() { # Gets rid of unneccesary api stuff
	cat topCryptosData.txt | sed s/"\""/""/g | sed s/" "/""/g | sed s/"},"/"}"/g | sed s/","/""/g > cleanTopCryptosData.txt

	# Clean data for Amy
	index=0
	printf "" > amysCleanFile.txt
	while [ $index -lt 10 ]
	do
		newIndex=$(($index * 17 + 5))
		cat cleanTopCryptosData.txt | head -$newIndex | tail -1 | awk -F: '{printf $2}' >> amysCleanFile.txt
		newIndex=$(($index * 17 + 7))
		printf ',' >> amysCleanFile.txt
		cat cleanTopCryptosData.txt | head -$newIndex | tail -1 | awk -F: '{printf $2}' >> amysCleanFile.txt
		cat amysCleanFile.txt | echo >> amysCleanFile.txt
		index=$((index+1))
	done
}

topCryptosData() {
	clear
	getAPIData	
	cleanAPIData

	IFS=$"{"

	row=1
	column=1
	count=0
	num_row=5

	for crypto in `cat cleanTopCryptosData.txt`
	do

		if [ $count -gt 0 ]
		then 

			rank=`echo $crypto | grep "rank" | awk -F: '{print "Rank:", $2}'`
			ticker=`echo $crypto | grep "symbol" | awk -F: '{print "Ticker:", $2}'`
			name=`echo $crypto | grep "name" | awk -F: '{print "Name:", $2}'`
			price_usd=`echo $crypto | grep "price_usd" | awk -F: '{print "Price USD:", $2}'`
			price_btc=`echo $crypto | grep "price_btc" | awk -F: '{print "Price BTC:", $2}'`
			volume_24th=`echo $crypto | grep "24h_volume_usd" | awk -F: '{print "24 Hour Volume:", $2}'`
			change_1h=`echo $crypto | grep "percent_change_1h" | awk -F: '{print "1 Hour Change:", $2}'`
			change_24th=`echo $crypto | grep "percent_change_24h" | awk -F: '{print "24 Hour Change:", $2}'` #ADD THE PERCENTAGE SYMBOLS TO THE 3

			negative=`echo $change_1h | grep "-" | wc -l`
			same=`echo $change_1h | grep "0.00" | wc -l`

            tput setaf 0;

            if [ $negative -eq 1 ]
            then
               tput setab 1;
            elif [ $same -eq 1 ]
            then
               tput setab 3;
            else
               tput setab 2;
            fi


			tput cup $row $column
			echo "                              "
			tput cup $row $column
			printf "%-30s" $rank

			tput cup `expr "$row" + 1` $column
			echo "                              "
			tput cup `expr "$row" + 1` $column
			printf "%-30s" $ticker

			tput cup `expr "$row" + 2` $column
			echo "                              "
        	tput cup `expr "$row" + 2` $column
        	printf "%-30s" $name

        	tput cup `expr "$row" + 3` $column
        	echo "                              "
        	tput cup `expr "$row" + 3` $column
        	printf "%-30s" $price_usd

       	    tput cup `expr "$row" + 4` $column
     	    echo "                              "
        	tput cup `expr "$row" + 4` $column
        	printf "%-30s" $price_btc

      	    tput cup `expr "$row" + 5` $column
        	echo "                              "
        	tput cup `expr "$row" + 5` $column
        	printf "%-30s" $volume_24th

      	    tput cup `expr "$row" + 6` $column
        	echo "                              "
        	tput cup `expr "$row" + 6` $column
        	printf "%-30s" $change_1h

        	tput cup `expr "$row" + 7` $column
        	echo "                              "
        	tput cup `expr "$row" + 7` $column
        	printf "%-30s" $change_24th
 
      	    column=`expr "$column" + 40`

            if [ $(($count % $num_row)) $num -eq 0 ]
            then
   	           row=`expr "$row" + 10`
      	       column=1
        	fi
        fi

        count=`expr "$count" + 1`     
	done

	tput setab 0
    tput setaf 7

    echo

	IFS=$' \t\n'
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
	availableCash=`cat $Username.portValue`
	count_buy=0
	while [ $quantityToBuy -le 0 ] && [ $count_buy -le 4 ]
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
 
		if [ $(bc <<< "$availableCash < $totalMarketPrice") -eq 1 ]
		then
			echo "You don't have enough cash available to buy $quantityToBuy $cryptoTicker"
			echo
			quantityToBuy=0
			count_buy=$((count_buy+1))
		else
			availableCash=$(echo "$availableCash - $totalMarketPrice" | bc)
		fi
	done
	echo $availableCash > $Username.portValue

	echo
	echo "Bought $quantityToBuy $cryptoTicker for \$$totalMarketPrice"
	echo
	echo "B,$cryptoTicker,$buyMarketPrice,$quantityToBuy,$totalMarketPrice" >> $transaction_file
	echo
	view_profile $Username
#	echo "Buy,Ticker: $cryptoTicker,Price Brought: $buyMarketPrice,Quantity Buy: $quantityToBuy, Total Market Price: $totalMarketPrice,Available Cash: $availableCash" | mailx $send_to
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
	availableCash=`cat $Username.portValue`
	count_sell=0
	while [ $quantityToSell -le 0 ] && [ $count_sell -le 4 ]
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

		if [ `cat $Username.stocks | grep "$cryptoTicker" | wc -l` -eq 0 ] || [ `cat $Username.stocks | grep "$cryptoTicker" | awk -F, '{print $2}'` -lt $quantityToSell ]
		then
			echo "You don't have enough $cryptoTicker coins to sell $quantityToSell $cryptoTicker"
			echo
			quantityToSell=0
			count_sell=$((count_sell+1))
		else
			availableCash=$(echo "$availableCash + $totalMarketPrice" | bc)
		fi
	done
	echo $availableCash > $Username.portValue

	echo
	echo "Sold $quantityToSell $cryptoTicker for \$$totalMarketPrice"
	echo
	echo "S,$cryptoTicker,$sellMarketPrice,$quantityToSell,$totalMarketPrice" >> $transaction_file
	echo

#	echo "Sell,Ticker: $cryptoTicker,Price Sold: $sellMarketPrice,Quantity Sold: $quantityToSell,Total Market Price: $totalMarketPrice, Available Cash: $availableCash" | mailx $send_to
	view_profile $Username
}

sum_trans()
{
	rm -f $Username.stocks
	getAPIData	
	cleanAPIData

	if [ $# -ge 1 ]
    then
		file=$1

		cat $file | sort -t, -k2 | awk -F, '{printf "%s\n",$2}' | uniq > currency_names

		total_value=0

		for currency in `cat currency_names`
		do
			cat $file | grep $currency > one_currency

			sum=0
			for trans in `cat one_currency`
			do
				type_tran=`echo $trans | awk -F, '{printf "%s",$1}'`
				volume=`echo $trans | awk -F, '{printf "%d",$4}'`
				current_price=`cat amysCleanFile.txt | grep $currency | awk -F, '{printf "%f",$2}'`

				if [ $type_tran = "S" ]
				then
					sum=$(($sum-$volume))
				else
					sum=$(($sum+$volume))
				fi	
			done
			
			market_value=$(echo "$sum * $current_price" | bc)
			total_value=$(echo "$total_value + $market_value" | bc)
			printf "%-16s %-20s %.2f %-20s\n" "$sum" "$currency" "$market_value"

			echo "$currency,$sum" >> $Username.stocks

		done

		total_value=$(echo "$total_value + `cat $Username.portValue`" | bc)

		echo "-------------------------------"
		printf "USD: $"
		printf "%0.2f\n" `cat $Username.portValue`

		echo "-------------------------------"
		printf "Value: $"
		printf "%0.2f\n" $total_value
		echo "-------------------------------"

		difference=$(echo "$total_value - $startingAmount" | bc) 
		difference=$(echo "$difference * 100" | bc)
		change=`echo "$difference $startingAmount" | awk '{printf "%.2f\n", $1/$2}'`
		difference=$(echo "$difference / 100" | bc)
		echo "Change: $change%"
		echo "-------------------------------"

		holdings_file=`echo "$Username.holdings"`
	    echo "$total_value,`cat $Username.portValue`" > $holdings_file


	else
    	echo "Error: No File Specified"
    	exit 64
	fi	
}

view_profile()
{   
	if [ $# -ge 1 ]
    then
        echo "------------------------"
    	echo "|       Profile        |"
    	echo "------------------------"
    	echo "Username: $Username"
    	file=`printf "$Username"".tran"`
    	echo "Quantity         Holdings             Market Value"
	    echo "--------         --------             ------------"
    	if [ -f "$file" ]
    	then
    		sum_trans $file
     	else
     		touch -f $file
     		echo "-------------------------------"
		    echo "Value: $startingAmount"
		    echo "-------------------------------"
		    echo "Change: 0%"
		    echo "-------------------------------"
     		echo "WARNING: TRANSACTION FILE IS EMPTY"
     		difference=0
     		total_value=0

    	fi
    else
    	echo "Error: No Username Specified"
    	exit 64
    fi

    rm -f currency_names
    rm -f one_currency
    rm -f temp
}

create_profile()
{
	if [ $# -ge 1 ]
    then
    	file=`printf "$Username"".tran"`
    	if [ -f "$file" ]
    	then
    		c_sum_trans $file
     	else
     		touch -f $file
     		difference=0
     		total_value=0

    	fi
    else
    	echo "Error: No Username Specified"
    	exit 64
    fi

    rm -f currency_names
    rm -f one_currency
    rm -f temp
}

c_sum_trans()
{
	rm -f $Username.stocks
	getAPIData	
	cleanAPIData

	if [ $# -ge 1 ]
    then
		file=$1

		cat $file | sort -t, -k2 | awk -F, '{printf "%s\n",$2}' | uniq > currency_names

		total_value=0
		for currency in `cat currency_names`
		do
			cat $file | grep $currency > one_currency

			sum=0
			for trans in `cat one_currency`
			do
				type_tran=`echo $trans | awk -F, '{printf "%s",$1}'`
				volume=`echo $trans | awk -F, '{printf "%d",$4}'`
				current_price=`cat amysCleanFile.txt | grep $currency | awk -F, '{printf "%f",$2}'`

				if [ $type_tran = "S" ]
				then
					sum=$(($sum-$volume))
				else
					sum=$(($sum+$volume))
				fi	
			done
			
			market_value=$(echo "$sum * $current_price" | bc)
			total_value=$(echo "$total_value + $market_value" | bc)

			echo "$currency,$sum" >> $Username.stocks

		done

		total_value=$(echo "$total_value + `cat $Username.portValue`" | bc)

		difference=$(echo "$total_value - $startingAmount" | bc) 
		difference=$(echo "$difference * 100" | bc) 
		change=`echo "$difference $startingAmount" | awk '{printf "%.2f\n", $1/$2}'`
		difference=$(echo "$difference / 100" | bc) #

		holdings_file=`echo "$Username.holdings"`
	    echo "$total_value,`cat $Username.portValue`" > $holdings_file

	else
    	echo "Error: No File Specified"
    	exit 64
	fi	
}

login()
{	if [ -f users.txt ]
	then
#		echo "Enter Username: "
#		read Username

		Username="kevinho" # BYPASS LOGIN FOR NOW

		is_user=`cat users.txt | awk -F, '{printf "%s\n",$1}' | grep -w $Username | wc -l`

		if [ $is_user -eq 0 ]
		then
			echo "Username does not exist"
			echo "Would you like to sign up? (yes/no)"
			read is_signup
			num_users=`cat users.txt | wc -l`
			is_match=true

			if [ $is_signup = "yes" ]
			then
				while [ $is_match = true ]
				do
					echo "Enter Password: "
					read Password
					echo "Confirm Password: "
					read ConfirmPassword

					if [ $Password != $ConfirmPassword ]
					then
						echo "Mismatch. Try again."
					else
						is_match=false
					fi	
				done

				echo "Enter Phone Number: "
				read phone

				echo "Enter Phone Carrier: "
				echo "(T: Tmobile, S: Sprint, V: Verison, A:AT&T)"
				read carrier

				printf "%s," "$Username" >> users.txt
				printf "%s," "$Password" >> users.txt
				printf "%s," "$phone" >> users.txt
				echo $carrier >> users.txt

				printf "$startingAmount" > "$Username"".portValue"
			else
				exit
			fi
		else
			count=0
			is_match=false

			while [ $count -le 4 ] && [ $is_match = false ]
			do
			#	echo "Enter Password: "
			#	read Password

				Password="ilovedennis" # BYPASS LOGIN FOR NOW

				is_password=`cat users.txt | grep $Username | awk -F, '{printf "%s\n",$2}' | grep -w $Password | wc -l`

				if [ $is_password -eq 0 ]
				then
					echo "Incorrect Password"
				else
					echo
					echo "Welcome $Username!"
					is_match=true
				fi

				count=$((count+1))
			done
		fi
	else
		echo "Error: File Not Found: users.txt"
	fi
}

messaging_setup()
{
	user_phone=`cat users.txt | grep $Username | awk -F, '{printf "%s\n",$3}'`
	user_carrier=`cat users.txt | grep $Username | awk -F, '{printf "%s\n",$4}'`

	case $user_carrier in
		"T") user_carrier="tmomail.net"
		;;
		"S") user_carrier="messaging.sprintpcs.com"
		;;
		"V") user_carrier="vtext.com"
		;;
		"A") user_carrier="txt.att.net"
		;;
		*) echo "Sorry, we do not recognize your carrier"
	esac 

	send_to=`echo "$user_phone@$user_carrier"`
}

leader_board()
{

	rm -f all_user_holding
	touch -f all_user_holding
	board_users=`cat users.txt | awk -F, '{printf "%s\n",$1}'`

	for user_i in `echo $board_users`
	do
		if [ -f $user_i.tran ] && [ `cat $user_i.tran | wc -l` -gt 0 ]
		then 
			create_profile $user_i.tran
		fi
		
		if [ -f $user_i.tran ] && [ `cat $user_i.tran | wc -l` -gt 0 ]
		then
			holdings_user=`echo "$user_i.holdings"`
			total_user=`cat $holdings_user | awk -F, '{printf "%f",$1}'`
			cash_user=`cat $holdings_user | awk -F, '{printf "%f",$2}'`
			value_cash=$(echo "$total_user" | bc) # SHOULDN'T REALLY BE CALLED value_cash BECAUSE IT'S THE value of the total portfolio
			value_cash_float=`printf "%0.2f\n" "$value_cash"`

			printf "%-12s %-20s\n" "$user_i" "$value_cash_float" >> all_user_holding 
		fi
	done

	echo "Rank  Username     Value"
    IFS=$'\n'

	leader_count=1
	for rank in `sort -k2 -r -n all_user_holding`
	do
		printf "%-5d %-50s\n" "$leader_count" "$rank"
		leader_count=$((leader_count+1))
	done

	IFS=$' \t\n'
}

visualize()
{
	SCRIPT_PATH="./Plot/display.sh"

	source "$SCRIPT_PATH"
}

echo "Welcome to the Cryptocurrency Trading Simulator"
echo

userInput=1
if [ $userInput -ne 5 ]
then
	login

	# login setup
	transaction_file=`echo $Username.tran`
	# messaging_setup
fi

while true
do
	echo
	displayMenu # Function Call

	read userInput
	echo

	case $userInput in 
		1) topCryptosData # Function Call
		;;
		2) view_profile $Username # Function Call
		;;
		3) buy # Function Call
		;;
		4) sell # Function Call
		;;
		5) leader_board
		;;
		6) visualize
		;;
		7) echo "Goodbye!"
			echo
			break
		;;
		*) echo "That is not a valid input!"
	esac
done
