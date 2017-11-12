# view profile function
# Amy Feng
# 11/11/2017

# helper functions
sum_trans()
{	
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
				current_price=`cat cleanTopCryptosData.txt | grep $currency | awk -F, '{printf "%f",$2}'`

				if [ $type_tran = "S" ]
				then
					sum=$(echo "$sum - $volume"|bc)
				else
					sum=$(echo "$sum + $volume"|bc)
				fi	
			done
			
			market_value=$(echo "$sum * $current_price"|bc)
			total_value=$(echo "$total_value + $market_value"|bc)
			printf "%-16s %-20s %-20s\n" "$volume" "$currency" "$market_value"
		done

		echo "-------------------------------"
		echo "Value: $total_value"
		echo "-------------------------------"

		difference=$(echo "$total_value - $startAmount"|bc)
		difference=$(echo "$difference * 100"|bc)

		change=$(echo "$difference / $startAmount"|bc)
		echo "Change: $change%"
		echo "-------------------------------"

	else
    	echo "Error: No File Specified"
    	exit 64
	fi	
}

# main function
view_profile()
{   
	if [ $# -ge 1 ]
    then
        username=$1
        echo "------------------------"
    	echo "|       Profile        |"
    	echo "------------------------"
    	echo "Username: $username"
    	file=`echo "$username.tran"`;
    	echo "Quantity         Holdings             Market Value"
	    echo "--------         --------             ------------"

    	if [ -f "$file" ]
    	then
    		sum_trans $file

     	else
     		touch -f $file
     		echo "-------------------------------"
		    echo "Value: $startAmount"
		    echo "-------------------------------"
		    echo "Change: 0%"
		    echo "-------------------------------"
     		echo "WARNING: TRANSACTION FILE IS EMPTY"
    	fi
    else
    	echo "Error: No Username Specified"
    	exit 64
    fi

    rm -f currency_names
    rm -f one_currency
    rm -f temp
}

startAmount=100000

view_profile amy
