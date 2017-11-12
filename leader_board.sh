leader_board()
{	# assumes holding made already for tran, BAD (call view profile without output)
	rm -f all_user_holding
	touch -f all_user_holding
	board_users=`cat users.txt | awk -F, '{printf "%s\n",$1}'`

	for user_i in `echo $board_users`
	do
		if [ -f $user_i.holdings ] && [ `cat $user_i.holdings | wc -l` -gt 0 ]
		then 
			holdings_user=`echo "$user_i.holdings"`
			total_user=`cat $holdings_user | awk -F, '{printf "%f",$1}'`
			cash_user=`cat $holdings_user | awk -F, '{printf "%f",$2}'`

			value_cash=$(echo "$total_user + $cash_user" | bc) 	

			printf "%s,%0.2f\n" "$user_i" "$value_cash" >> all_user_holding
		fi 
	done

	echo "Rank  Username     Value"

	leader_count=1
	for rank in `sort -k2 -r -n -t, all_user_holding`
	do
		printf "%-5d %-50s\n" "$leader_count" "$rank" | sed s/,/"      "/g
		leader_count=$((leader_count+1))
	done
}

leader_board