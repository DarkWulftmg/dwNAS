#!/bin/sh
#
#
# Script to display
#       Started project July 21 - 2015
#       Owner of project: Thor Miller Grotle - thor@grotle.dk

# Guided help from: http://bash.cyberciti.biz/guide/Infinite_while_loop
. /usr/local/etc/dwNAS/dwNASlib
. /usr/local/etc/dwNAS/dwNASglobal.conf

mainMenu(){
	while :
	do
	clear
        # display Main menu
  echo "Server Name - $(hostname)"
	echo -------------------------------------------------------------------------------
	echo "	 This is the Main System settings and system statistic script"
	echo -------------------------------------------------------------------------------
	echo "1. System overview"
	echo "2. ** Services management"
	echo "3. Jail management"
	echo "4. ** Filesharing management"
	echo "5. ZFS and Dataset management"
	echo "6. Module management"
	echo "7. Filemanager - Midnight Commander"
	echo "8. User and groups"
	echo "9. ** System update"
	echo -------------------------------------------------------------------------------
	echo "Q. Exit menu"
	echo "rb. Restart system"
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
			servicesManagement
			;;
		3)
			jailManagement
			;;
		5)
			storageManagement
			;;
		6)
			moduleManagement
			;;
		7)
			mc
			;;
		8)
			userMenu
			;;
		[XxQq])
			echo "Bye!"
			exit 0
			;;
		rb)
			reStart
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
}

userMenu(){
while :
do
clear
echo "Server Name - $(hostname)"
echo -------------------------------------------------------------------------------
echo "	 This is the user and group management menu"
echo -------------------------------------------------------------------------------
echo "1. List users"
echo "2. Add user"
echo "3. Remove user"
#echo "*Modify user [Advanced]"
#echo "** Change user UUID"
#echo "** Change user homedir"
echo "5. List groups"
echo "6. Add group"
echo "7. Remove group"
#echo "*Modify Group [Advanced]"
#echo "** Modify group members"
#echo "** Change group GUID"
echo "9. Add  user to group"
echo "10. Lock/unlock User"
echo -------------------------------------------------------------------------------
echo "B. Back to main menu"
echo "Q. Exit menu"
read -p "Enter your choice [ 1 -7 ] " choice
case $choice in
	1)
		cat /etc/passwd
		pressENTER
		;;
	2)
		adduser
		;;
	3)
		cat /etc/passwd
		read -p "Remove what user? " choice
			echo user is member of group:
			groups $choice
			read -p "Are you sure you want to delete $choice? [YN] " choice2
				case $choice2 in
				[Yy])
					pw user del $choice
					pressENTER
					;;
				[NnBb])
					echo "Doing nothing"
					pressENTER
					;;
				*)
					echo "Invalid option"
					pressENTER
					;;
				esac
				;;
	5)
		cat /etc/group
		pressENTER
		;;
	6)
		read -p "Groupname? " choice
		pw add group $choice
		pressENTER
		;;
	7)
		cat /etc/group
		read -p "Remove what group? " choice
		echo "Group has the following members:"
		users $choice
		read -p "Are you sure you want to delete $choice? [YN] " choice2
			case $choice2 in
			[Yy])
				pw group del $choice
				pressENTER
				;;
			[NnBb])
				echo "Doing nothing"
				pressENTER
				;;
			*)
				echo "Invalid option"
				pressENTER
				;;
			esac
			;;

	[Bb])
		break
		;;
	[XxQq])
		echo "Bye!"
		exit 0
		;;
	*)
		echo "Error: Invalid option..."
		pressENTER
		;;
esac

done
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
	echo "3. Enabled/disable Jail"
	echo "4. Console to Jail"
	echo "5. Create Jail"
	echo "6. Delete Jail"
	echo "** Update Jail"
	echo "** Recover Jail"
	echo "9. Archive Jail"
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
			3)
				selectJail
				jailcheck="$JAILNAME"
				checkJail
					if [ "$jailpresent" == "TRUE" ]
						then
						read -p "should $JAILNAME be enabled [YN]? " choice2
						case $choice2 in
							[Yy])
								ezjail-admin config -r run $JAILNAME
								echo "Jail $JAILNAME is now ready for action"
								pressENTER
								;;
							[NnXx])
								ezjail-admin config -r norun $JAILNAME
								echo "Jail $JAILNAME is now set to be dormant"
								pressENTER
								;;
							*)
							 	echo "Doing nothing"
								pressENTER
								continueæ
								;;
							esac
						else
							echo "Are you insane? Jail $JAILNAME does not exist"
					fi
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
				## Delete jail routing, first select jail, check if awake, then delete Jail.
				JAILNAME=""
				selectJail
				jailcheck="$JAILNAME"
				jailAwake
				if [ "$jailawake" == "TRUE" ]
					then
					echo "Unable to delete jail while running, please stop jail, and try again." ; pressENTER
				fi
				deleteJail
				pressENTER
				;;

			9)
				## Archive jail routing, first select jail, check if awake,then archive.
				echo ""
				echo "Select jail to archive"
				selectJail
				jailcheck="$JAILNAME"
				jailAwake
					if [ "$jailawake" == "TRUE" ]
						then
						echo "Unable to Archive jail while running, please stop jail, and try again."
						pressENTER
						break
					fi
				echo "backing up jail into $JAILSROOT/ezjail_archives/"
				ezjail-admin archive $JAILNAME
				ls $JAILSROOT/ezjail\_archives/ | grep $JAILNAME
				pressENTER
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

servicesManagement(){
	while :
	do
		clear
	  echo "Server Name - $(hostname)"
		echo -------------------------------------------------------------------------------
		echo "	 Services management Menu"
		echo -------------------------------------------------------------------------------
		echo "1. Check services"
		echo "Enable/Disable service on Boot"

		echo -------------------------------------------------------------------------------
		echo "B. Back to Main Menu"
		echo "Q. Exit menu"

		read -p "Enter your choice [ 1 - 2 ] " choice
		case $choice in
			1)
				echo "menu"
				pressENTER
				;;
			[Bb])
				break
				;;
			[XxQq])
				echo "Bye!"
				exit 0
				;;
			*)
				echo "Error: Invalid option..."
				pressENTER
				;;
		esac

	done

}

moduleManagement(){
	while :
	do
		clear
	  echo "Server Name - $(hostname)"
		echo -------------------------------------------------------------------------------
		echo "	 Module management menu"
		echo -------------------------------------------------------------------------------
		echo "1. List available modules"
		echo "2. edit/view available module"
		echo "3. Edit and Execute a modules"
		echo "4. List and download module from online repository"
		echo "** 5.List and download module from local repository"
		echo "6. Remove module"

		echo -------------------------------------------------------------------------------
		echo "B. Back to Main Menu"
		echo "Q. Exit menu"

		read -p "Enter your choice [ 1 - 5 ] " choice
		case $choice in
			1)
				## List modules from /usr/local/etc/dwNAS/mod
				echo ""
				echo "Listing available Modules"
				echo -------------------------------------------------------------------------------
				ls /usr/local/etc/dwNAS/mod/dwNASmod*
				echo ""
				pressENTER
				;;
			2)
				unlistMod
				modList=`w | ls /usr/local/etc/dwNAS/mod/dwNASmod* | awk -F'/' '{print $NF}'`
				selectModule
				if [ -z "$modname" ]
					then
						echo "Doing nothing"
					else
						nano /usr/local/etc/dwNAS/mod/$modname
				fi
				pressENTER
				;;
			3)
				unlistMod
				modList=`w | ls /usr/local/etc/dwNAS/mod/dwNASmod* | awk -F'/' '{print $NF}'`
				selectModule
				if [ -z "$modname" ]
					then
						echo "Doing nothing"
					else
						nano /usr/local/etc/dwNAS/mod/$modname
						read -p "Do you want to execute module $modname [YN] ? " choice2
					case $choice2 in
						[Yy])
						. /usr/local/etc/dwNAS/mod/$modname
						pressENTER
						;;
						*)
						echo Doing nothing
							;;
					esac
				fi
				pressENTER
				;;
			4)
				## This download module list, let user select module to download, if file exist ask to overwrite.
				unlistMod
				fetch http://www.itso.dk/dwNASProject/mod/dwNASlistMods -o /tmp/dwNASlistMods
				echo ""
				echo "Modlist bhttp://www.itso.dk/dwNASProject/mod/dwNASlistMods"
				modList=`w | cat /tmp/dwNASlistMods | awk -F'/' '{print $NF}'`
				selectModule
				if [ -z "$modname" ]
					then
						echo "Doing nothing"
					else
						if [ -f /usr/local/etc/dwNAS/mod/$modname ]
						then
							read -p "$modname allready exist, should i overwrite [YN]? " choice2
							case $choice2 in
								[Yy])
								fetch http://www.itso.dk/dwNASProject/mod/$modname -o /usr/local/etc/dwNAS/mod/$modname
								pressENTER
								;;
								[Nn])
									echo "ok, doing nothing"
									pressENTER
									break
									;;
									[Bb])
									break
									;;
									[XxQq])
									echo "Bye!"
									exit 0
									;;
									*)
									echo "Error: Invalid option..."
									pressENTER
									;;
								esac
							else
								fetch http://www.itso.dk/dwNASProject/mod/$modname -o /usr/local/etc/dwNAS/mod/$modname
								# for later: transfer to temp dir
								# for later: check md5 sum,  if fail delete
							fi
							read -p "Do you want to edit module $modname[YN] ? " choice3
							case $choice3 in
								[Yy])
								nano /usr/local/etc/dwNAS/mod/$modname
								break
								;;
								*)
								echo Doing nothing
								;;
								esac
				fi
				pressENTER
				;;

				6)
					unlistMod
					modList=`w | ls /usr/local/etc/dwNAS/mod/dwNASmod* | awk -F'/' '{print $NF}'`
					selectModule
					if [ -z "$modname" ]
						then
							echo "Doing nothing"
						else
							head /usr/local/etc/dwNAS/mod/$modname
							read -p "Do you want to Delete module: $modname [YN] ? " choice2
							case $choice2 in
								[Yy])
								rm /usr/local/etc/dwNAS/mod/$modname
								break
								;;
								*)
								echo Doing nothing
								;;
						esac
					fi
					pressENTER
					;;
			[Bb])
				break
				;;

			[XxQq])
				echo "Bye!"
				exit 0
				;;
			*)
				echo "Error: Invalid option..."
				pressENTER
				;;
		esac

	done

}

storageManagement(){
	while :
	do
		clear
	        # display Main menu
	  echo "Server Name - $(hostname)"
		echo -------------------------------------------------------------------------------
		echo "	 This is the ZFS and Dataset management Menu"
		echo -------------------------------------------------------------------------------
		echo "1. Dataset list"
		echo "2. Dataset Create"
		echo "3. Dataset Destroy ** Very Dangerous **"
		echo "** Dataset Modify [Advance]"
			echo "	** Create nullfs link"
			echo "	** Create snapshot of dataset"
			echo "	** Set Autosnapshot dataset"
			echo "	** Replicate/clone Dataet"
			echo "	** Replicate Dataset to remote host"
			echo "  ** Rename Dataset"
			echo " 	** Change dataset permissions (chown,chgrp, chmod)"
			echo "	** Set ACL for dataset"
		echo "** Zpool Create"
		echo "** Zpool Destroy ** Very Dangerous **"
		echo "7. Zpool import"
		echo "8. Zpool export"
		echo "9. Zpool Scrubbing"
		echo -------------------------------------------------------------------------------
		echo "B. Back to main menu"
		echo "Q. Exit menu"

		read -p "Enter your choice [ 1 -7 ] " choice
		case $choice in
			1)
				zfs list | more
				pressENTER
				;;
			2)
				zfs list | grep $DATAPOOL | more
				echo "Usage: created dataset will be created under /mnt/$DATAPOOL/?? "
				read -p "Enter path to new dataset $DATAPOOL/? or [B. for back] " datasetname
				if  [ "$datasetname" == "b" ]
						then
							break
						elif [ "$datasetname" == "" ]; then
							echo "No dataset selected. Doing nothing"
							pressENTER
							break
				fi
				chkdataset=$DATAPOOL/$datasetname
				checkDataset
					if [ "$datasetstatus" == "false" ]
					then
						read -p "Should I create $chkdataset [YN]? " choice
						if [ "$choice" == "Y" ]
							then
							createDataset
						fi
					elif [ "$datasetstatus" == "true" ]; then
						#statements
								echo "Dataset $chkdataset allready exist, doing nothing"
								pressENTER
								break
					fi
				checkDataset
				pressENTER
				;;
			3)
				zfs list | more
				read -p "Enter path to destroy $DATAPOOL/? or [B. for back] " datasetname
				if  [ "$datasetname" == "b" ]
						then
							break
						elif [ "$datasetname" == "" ]; then
							echo "No dataset selected. Doing nothing"
							pressENTER
							break
				fi
				chkdataset=$DATAPOOL/$datasetname
				checkDataset
					if [ "$datasetstatus" == "true" ]
						then
							read -p "Should I delete $chkdataset and recursive [YN]? " choice
							if [ "$choice" == "Y" ]
								then
								echo "waiting 5 seconds before deleting $chkdataset and recursive"
								echo "zfs destroy -f $chkdataset"
								sleep 5
								zfs destroy -f $chkdataset
							fi
						else
									echo "Dataset $chkdataset does not exist, did you type a correct path?"
									pressENTER
									break
						fi
				checkDataset
				pressENTER
				;;
			7)
				unlistZpool
					read -p "Do you wish to import a Zpool? [YN]" choice
						case $choice in
							[Yy])
									zpoollist=`zpool import | grep pool: |sed 's/pool: //'|sed 's/   //'`
									selectZpool
									echo "importing $namezpool"
										if [ -d /mnt/$namezpool ]
											then
												read -p "/mnt/$namezpool allready exist, import to other name [YN]? " choice2
													case $choice2 in
														[Yy]) read -p "Enter new import zpoolname for $namezpool: " namezpool2
																	if [ -d /mnt/$namezpool2 ]
																		then
																			echo "/mnt/$namezpool also exist, doing nothing."
																			break
																		else
																			zpool import -f $namezpool $namezpool2
																			zfs set mountpoint=/mnt/$namezpool2
																			echo "Mountpoint set at /mnt/$namezpool2/"
																			echo " You might want to reboot to take affect"
																	fi
															;;
														[Nn])
															echo "OK, doing nothing"
															continue
															;;
														*)
														echo "Invalid option, try again"
															;;
														esac
										fi
										if [ ! -d /mnt/$namezpool ]
											then
											zpool import $namezpool
											zfs set mountpoint=/mnt/$namezpool
											echo "Mountpoint set at /mnt/$namezpool/"
											echo " You might want to reboot to take affect"
										fi
									pressENTER
								;;
							[Nn])
								echo "Doing Nothing"
								pressENTER
								continue
								;;
							[Bb])
								echo "Doing noting"
								pressENTER
								break
								;;
							*)
								echo "Error: Invalid option..."
								pressENTER
						esac

								;;

			8)
							unlistZpool
							namezpool=""
							zpoollist=`zpool list | sed 's/NAME         SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT//' | awk '{print $1;}'`
							selectZpool
							if [ "$namezpool" == "" ]
								then
									break
							fi
						 	read -p"Export Zpool with force: $namezpool [YN]? " choice
								case $choice in
									[Yy])
										zpool export -f $namezpool
										echo "removing mountfolder /mnt/$namezpool"
										sleep 5
										rm -rf $namezpool
										;;
									*)
										echo "Doing nothing" ; pressENTER;;
								esac
							;;
			[Bb])
				break
				;;
			[XxQq])
				echo "Bye!"
				exit 0
				;;
			*)
				echo "Error: Invalid option..."
				pressENTER
				;;
		esac
	done
}


mainMenu
