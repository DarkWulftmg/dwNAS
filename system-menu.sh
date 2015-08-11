#!/bin/sh
#
#
# Script to display
#       Started project July 21 - 2015
#       Owner of project: Thor Miller Grotle - thor@grotle.dk

# Guided help from: http://bash.cyberciti.biz/guide/Infinite_while_loop
. /mnt/DarkVolume/AppData/scripts/dwNAS-project/dwNASlib
. /mnt/DarkVolume/AppData/scripts/dwNAS-project/dwNASGlobal.conf

consoleJail(){
	selectJail
	ezjail-admin console $JAILNAME
}

jailManagement(){
	while :
	do
	clear
	echo "Server Name - $(hostname)"
	echo -------------------------------------------------------------------------------
	echo "	 This is the Jail Management"
	echo -------------------------------------------------------------------------------
	echo "1. List Jails"
	echo "2. Start/stop Jail"
	echo "** Enabled/disable Jail on startup"
	echo "4. Console to Jail"
	echo "5. Create Jail"
	echo "6. Delete Jail"
	echo "** Update Jail"
	echo "** Recover Jail"
	echo "** Archive Jail"
	echo -------------------------------------------------------------------------------
	echo "B. Back to main Menu"
	echo "Q. Exit Menu"

	        # get input from the user
		read -p "Enter your choice [ 1 - 9 ] " choice
	        # make decision using case..in..esac
		case $choice in
			1)
				ezjail-admin list
				pressENTER
				;;
			2)
				selectJail
				jailcheck="$JAILNAME"
				jailAwake
				startstopJail
				;;



			4)
				selectJail
				ezjail-admin console $JAILNAME
				;;
			5)
				JAILNAME=""
				createJail
				checkJail
				read -p "Start Jail $JAILNAME [YN] ?" choice
					case $choice in
						[Yy]) ezjail-admin start $JAILNAME ;;
						*)	echo "Ok Leaving Jail untouched" ; pressENTER;;
					esac

				;;

			6)
				JAILNAME=""
				selectJail
				jailcheck="$JAILNAME"
				jailAwake
				if [ "$jailawake" == "TRUE" ]
					then
					echo "Unable to delete jail while running, please stop jail, and try again." ; pressENTER
				fi
				deleteJail
				;;

			[Bb])
				break
				;;

			[QqXx])
				exit 0
				;;
			*)
				echo "Error: Invalid option..."
				pressENTER
				;;

		esac
	done
}


while :
do
	clear
        # display Main menu
  echo "Server Name - $(hostname)"
	echo -------------------------------------------------------------------------------
	echo "	 This is the Main System settings and system statistic script"
	echo -------------------------------------------------------------------------------
	echo "1. System overview"
	echo "2. Services management"
	echo "3. Jail management"
	echo "4. *Filesharing management"
	echo "5. *Zpool and dataset management"
	echo "6. *Module management"
	echo "7. *System - and updates"
	echo -------------------------------------------------------------------------------
	echo "Q. Exit menu"
	echo "po. Poweroff system."

	read -p "Enter your choice [ 1 -7 ] " choice
	case $choice in
		1)
			echo "Today is $(date)"
			top -bt 0
			echo""
			zpool list
			echo""
			listDisk
			pressENTER
			;;
		2)
			echo " Service menu no ready yet"
			pressENTER
			#read -p "Press [Enter] key to continue..." readEnterKey
			;;
		3)
			jailManagement ;;
		[XxQq])
			echo "Bye!"
			exit 0
			;;
		po)
			shutDown
			;;
		*)
			echo "Error: Invalid option..."
			pressENTER
			;;
	esac

done
