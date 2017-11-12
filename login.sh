# Amy Feng
# 11/12/2017
# Login, Create User

login()
{	if [ -f users.txt ]
	then
		echo "Enter Username: "
		read Username

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

			else
				exit
			fi
		else
			count=0
			is_match=false

			while [ $count -le 4 ] && [ $is_match = false ]
			do
				echo "Enter Password: "
				read Password

				is_password=`cat users.txt | grep $Username | awk -F, '{printf "%s\n",$2}' | grep -w $Password | wc -l`

				if [ $is_password -eq 0 ]
				then
					echo "Incorrect Password"
				else
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

login