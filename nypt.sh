#!/bin/bash

## Crypt files and messages using three layers of openssl 256-bit encryption and a layer of random number encryption

fstart()																#Startup function
{
	ENCCDIR="0_Encrypted_Messages"
	DECDIR="0_Decrypted_Messages"
	trap fexit 2
	LIST="""shred
xclip
openssl
zip
unzip
base64
md5sum
awk
sed
grep"""
	echo "$LIST" > tmp1
	
	while read COMMAND
		do
			if [ $(which $COMMAND) -z ] 2> /dev/null
				then
					clear
					tput setab 6
					read -p " [*] It looks like $COMMAND is not installed on your system, it is needed by Nypt. Do you want to install it? [Y/n]" INSTALL
					tput setab 9
					if [ $(whoami) = "root" ]
						then
							case $INSTALL in
								"y") apt-get install $COMMAND;;
								"Y") apt-get install $COMMAND;;
								"") apt-get install $COMMAND
							esac
						else
							case $INSTALL in
								"y") sudo apt-get install $COMMAND;;
								"Y") sudo apt-get install $COMMAND;;
								"") sudo apt-get install $COMMAND
							esac
					fi
				else 
					tput setab 2
					echo " [*] $COMMAND found"
					tput setab 9
			fi
		done < tmp1
		
	rm -rf tmp1
	fmenu
}

fkeygen()																#Generate keys
{
	clear
	tput setab 6
	echo " [>] What shall we name your key?"
	tput setab 9
	read -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ -d $KEY ]
		then
			clear
			tput setab 2
			echo " [*] $KEY already exists, try again."
			sleep 2
			fkeygen
		else
			clear
			tput setab 4
			echo " [*] Generating $KEY, please wait..."
			mkdir $KEY
			mkdir $KEY/$ENCCDIR
			mkdir $KEY/$DECDIR
			sort -R list > $KEY/list
			DIRNUM=10
			
			while [ $DIRNUM -le 99 ]
				do
					mkdir $KEY/$DIRNUM
					DIRNUM=$(( DIRNUM + 1 ))
				done
				
			CODLINE=10110		
			LISTNUM=10
			LISTNUMB=11
	
			while [ $CODLINE -le 900000 ]
				do 
					echo -n $(head -"$CODLINE" $KEY/list | tail -10110) > $KEY/$LISTNUM/$LISTNUM
					sed -e 's/\s/\n/g' $KEY/$LISTNUM/$LISTNUM > $KEY/$LISTNUM/$LISTNUMB	
					shred -zfun 3 $KEY/$LISTNUM/$LISTNUM
					mv $KEY/$LISTNUM/$LISTNUMB $KEY/$LISTNUM/$LISTNUM

					LISTNUM=$(( LISTNUM + 1 ))
					LISTNUMB=$(( LISTNUMB + 1 ))
					CODLINE=$(( CODLINE + 10110 ))
				done
			
			RAND1=${RANDOM:0:2}
			RAND2=${RANDOM:0:2}
			RAND3=${RANDOM:0:2}
			if [ $RAND1 -le 50 ]
				then
					RAND1=$(( RAND1 + 35 ))
			fi
			if [ $RAND2 -le 50 ]
				then
					RAND2=$(( RAND2 + 35 ))
			fi
			if [ $RAND3 -le 50 ]
				then
					RAND3=$(( RAND3 + 35 ))
			fi
			mkdir $KEY/meta/
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND1 | tr -d '\n'; echo) > $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND2 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND3 | tr -d '\n'; echo) >> $KEY/meta/meta
			shred -zfun 3 $KEY/list
			echo
			tput setab 2
			echo " [*] $KEY Complete!"
			tput setab 9
			sleep 1
			fmenu
	fi
}

fmenu()
{
	clear
	if [ $DISPCOP = "1" ] 2> /dev/null
		then
			tput setab 2
			echo " [*] File text copied to clipboard"
			tput setab 9
			DISPCOP=0
	elif [ $DISPCOPMSG = "1" ] 2> /dev/null
		then
			tput setab 2
			echo " [*] Message copied to clipboard"
			DISPCOPMSG=0
			tput setab 9
	fi
	cd $DIRR
	tput setab 6
	echo "  [*] Nypt 1.32"		
	tput setab 9														#This is the main menu
	read -p """      ~~~~~~~~
 [1] Encryption
 [2] Decryption
 [3] Keys
 [4] Quit
 >""" MENU
  
		case $MENU in
	1)	clear
		tput setab 6
		echo " [*] Encryption Menu"
		tput setab 9
		read -p """      ~~~~~~~~
 [1] Encrypt a message.
 [2] Encrypt a file.
 [3] Browse Encryption folder.
 [4] Read Encrypted messages.
 [5] Securely delete Encrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fencryptmsg;;2)fencryptfile;;3)fopenenc;;4)fcatenc;;5)fsecuredelenc;;6)fmenu;esac
	;;
	2)	clear
		tput setab 6
		echo " [*] Decryption Menu"
		tput setab 9
		read -p """      ~~~~~~~~
 [1] Decrypt a message.
 [2] Decrypt a file.
 [3] Browse Decryption folder.
 [4] Read Decrypted messages.
 [5] Securely delete Decrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fdecryptmsg;;2)fdecryptfile;;3)fopendec;;4)fcatdec;;5)fsecuredeldec;;6)fmenu;esac
	;;
	3)	clear
		tput setab 6
		echo " [*] Key Menu"
		tput setab 9
		read -p """      ~~~~~~~~
 [1] Generate a new Key.
 [2] Export a Key.
 [3] Import a Key.
 [4] Securely delete a Key.
 [5] Back
 >""" MENU 
		case $MENU in 1)fkeygen;;2)fexport;;3)fimport;;4)fsecuredelkey;;5)fmenu;esac
	;;	
	4)fexit
	esac
	fmenu
}

fcatenc()																#Read encrypted messages from the 0_Encrypted_Messages Directory
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 	
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fcatenc
		else
			clear
			tput setab 6
			echo " [>] Which file do you want to read?"
			tput setab 9
			cd $KEY/$ENCCDIR;ls
			read -e -p " >" ENCCAT
			if [ -f $ENCCAT ]
				then
					clear
					clear
					cat $ENCCAT
					echo
					DLEN=$(wc -l $ENCCAT)
					DLENT=7
					RLEN=${DLEN:0:$DLENT}										
					while [[ "$RLEN" ==  *"/"* ]]
						do
							DLENT=$((DLENT - 1))							
							RLEN=${DLEN:0:$DLENT}
						done
					
					DLENT=$((DLENT - 1))
					RLEN=${DLEN:0:$DLENT}
					tput setab 2
					echo " [*] Message is $RLEN lines long and stored at $DIRR$KEY$ENCCDIR$ENCCAT"
					tput setab 9
					read -p """ [>] Press c and Enter to copy to clipboard
 [>] Press Enter to return to menu
 >""" SMF
					case $SMF in
						"c") cat $ENCCAT | xclip -sel clip;DISPCOPMSG=1;fmenu;;
						"") fmenu
					esac
					
				else
					clear
					tput setab 1
					echo " [*] There does not appear to be any file at $ENCCAT, try again.."
					tput setab 9
					sleep 2
					fmenu
			fi
	fi
}


fcatdec()																#Read decrypted messages from the 0_Decrypted_Messages Directory
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 	
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fcatdec
		else
			clear
			tput setab 6
			echo " [>] Which file do you want to read?"
			tput setab 9
			cd $KEY/$DECDIR; ls
			read -e -p " >" DECCAT
			if [ -f $DECCAT ]
				then
					clear
					cat $DECCAT
					echo
					read -p " [>] Press Enter to return to main menu" SMF
					fmenu
				else
					clear
					tput setab 1
					echo " [*] There does not appear to be any file at $DECCAT, try again.."
					tput setab 9
					sleep 2
					fmenu
			fi
	fi
}

fopenenc()
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 	
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY/$ENCCDIR ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 2
			fopenenc
		else
			nautilus $KEY/$ENCCDIR
	fi

	fmenu	
}

fopendec()
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY/$DECDIR ]
		then
			clear
			echo " [*] $KEY is not a valid key, try again.."
			sleep 2
			fopendec
		else
			nautilus $KEY/$DECDIR
	fi
	fmenu
}

fimport()
{
	clear
	read -e -p """ [>] Please Enter the location of the key file eg. $HOME/Desktop/key
 >""" KEYLOC
	KEYFILE=$(basename $KEYLOC)
	clear
	if [ -f $KEYLOC ]
		then
			read -p " [>] Do you have a custom key password? [Y/n]: " CUSTP
			
			case $CUSTP in
			
				"Y")fimportcus;;
			
				"y")fimportcus;;
				
				"n")fimportdef;;
			
				"N")fimportdef;;
			
				"")fimportcus
			
			esac
		else
				clear
				echo " [*] There does not appear to be any file at $KEYFILE, try again."
				sleep 2
				fimport
	fi
}

fimportcus()															#Import key using custom password
{
	clear
	DONPS=0
	while [ $DONPS != "1" ]
		do
			clear
			echo " [>] Please Enter the password"
			read -s RPASS
			echo " [>] Enter one more time"
			read -s SPASS
			if [ $RPASS != $SPASS ]
				then
					clear
					echo " [*] Passwords do not match, try again.."
					sleep 2
				else
					DONPS=1
			fi
		done
	NPASS=$(echo $SPASS | base64)
	NPASS=$(echo $NPASS$NPASS | md5sum)
	GPASS=$(echo NPASS | md5sum)
	LPASS=$NPASS$GPASS$SPASS$GPASS
	
	openssl enc -aes-256-cbc -d -a -salt -in $KEYLOC -out tmp01 -k $LPASS 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in tmp01 -out tmp02 -k $NPASS 2> /dev/null
	openssl enc -aes-256-gcm -d -a -salt -in tmp02 -out $KEYFILE.zip -k $SPASS 2> /dev/null
	
	unzip -P $GPASS $KEYFILE.zip -d .  2> /dev/null
	chown -hR $USER $KEYFILE
	clear
	echo " [*] $KEYFILE imported."
	shred -zfun 3 $KEYFILE.zip
	shred -zfun 3 tmp0*
	sleep 2
	fmenu
}

fimportdef()															#Import key using default password
{
	openssl enc -d -a -aes-256-gcm -salt -in $KEYLOC -out $KEY.zip -k "FQhs2UOb6UfY6h4h20hf49LTS9EnkSuQP66357693hahal0l286501EfOoWCvjScbanpDrJ3sWXupryAQLj71Qt" 2> /dev/null
	unzip -P "cPHQ0bkM2zEUZY245h9ZwgS7l98Hi0WqIeamJVhow1osQ" $KEY.zip -d .  2> /dev/null
	shred -zfun 3 $KEY.zip
	shred -zfun 3 $KEY
	chown -hR $USER $KEYFILE
	clear
	echo " [*] $KEYFILE imported."
	sleep 2
	fmenu
}

fexport()
{
	clear
	echo " [>] Which key?"
	ls 
	read -e -p " >" KEY
	
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ ! -d $KEY ]
		then
			clear
			echo " [*] $KEY is not a valid key, try again.."
			sleep 1
			fexport
		else
			if [ ! -d $KEY/0_Exported_Keys ]
				then
					mkdir $KEY/0_Exported_Keys
			fi			
			
			WHSAV=$KEY/0_Exported_Keys
			clear
			PASSCHI=""
			echo " [*] Please note it is NOT safe to export keys over untrusted networks using the default password."
			echo
			read -p " [>] Do you want to use the default or a custom password? [C/d]: " PASSCHI

			case $PASSCHI in
				"")fexportcus;;
			
				"D")fexportdef;;
			
				"d")fexportdef;;
			
				"c")fexportcus;;
			
				"C")fexportcus;;
			esac

	clear
	echo " [*] $KEY exported to $DIRR$WHSAV/$KEY"
	shred -zfun 3 $WHSAV/tmp0*
	shred -zfun 3 $KEY.zip
	sleep 2.5
	fmenu
	fi
}

fexportcus()															#Export key using custom password
{
	clear
	PASSDON=0
	while [ $PASSDON != "1" ]
		do
			clear
			echo " [>] Please Enter your password"
			read -s  TPASS
			echo " [>] Enter once more"  
			read -s ZPASS
			if [ $TPASS != $ZPASS ]
				then
					clear
					echo " [*] Passwords do not match, try again.."
					sleep 2
				else
					PASSDON="1"
					NPASS=$(echo $ZPASS | base64)
					NPASS=$(echo $NPASS$NPASS | md5sum)
					GPASS=$(echo NPASS | md5sum)
					LPASS=$NPASS$GPASS$ZPASS$GPASS
					zip -reP $GPASS  $KEY.zip $KEY 2> /dev/null
					
					openssl enc -aes-256-gcm -a -salt -in $KEY.zip -out $WHSAV/tmp01 -k $ZPASS 2> /dev/null
					openssl enc -camellia-256-cbc -a -salt -in $WHSAV/tmp01 -out $WHSAV/tmp02 -k $NPASS 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in $WHSAV/tmp02 -out $WHSAV/$KEY -k $LPASS 2> /dev/null
					
			fi
		done
}

fexportdef()          													#Export key using default password
{
	( zip -reP "cPHQ0bkM2zEUZY245h9ZwgS7l98Hi0WqIeamJVhow1osQ" $KEY.zip $KEY ) 2> /dev/null
	openssl enc -a -aes-256-gcm -salt -in $KEY.zip -out $WHSAV/$KEY -k "FQhs2UOb6UfY6h4h20hf49LTS9EnkSuQP66357693hahal0l286501EfOoWCvjScbanpDrJ3sWXupryAQLj71Qt" 2> /dev/null
}


fsecuredelkey()															#Shred key
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fsecuredelkey
		else
			clear
			tput setab 1
			echo " [>] Warning, this will securely delete $KEY and all of its messages, are you sure? [Y/n]: " 
			tput setab 9
			read -p " >" DODEL
			case $DODEL in
				"Y")	fdoseckey;;
				"y")	fdoseckey;;
				"")     fdoseckey
					
			esac
		fmenu
					
	fi
}

fdoseckey()
{
	echo
	tput setab 4
	echo " [*] Securely deleting $KEY, please wait.."
	find $KEY/ -type f -exec shred -zfun 3 {} \;
	rm -rf $KEY
	tput setab 2
	echo " [*] $KEY and all its messages securely deleted."
	tput setab 9
	sleep 2
}

fsecuredelenc()															#Shred encrypted messages
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fsecuredelenc
		else
			clear
			tput setab 1
			echo " [>] Warning, this will securely delete all of "$KEY"'s encrypted messages, are you sure? [Y/n]:"
			tput setab 9
			read -p " >" DODEL
			clear
		
			case $DODEL in
				"Y")	fsecdelenc;;
				"y")	fsecdelenc;;
				"")		fsecdelenc
			esac

		fmenu
					
	fi
}

fsecdelenc()
{
	tput setab 4
	echo " [*] Securely deleting "$KEY"'s encrypted messages, please wait.."
	find $KEY/$ENCCDIR -type f -exec shred -zfun 3 {} \;
	tput setab 2
	echo " [*] "$KEY"'s encrypted messages securely deleted."
	tput setab 9
	sleep 2
}

fsecuredeldec()															#Shred decrypted messages  
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fsecuredeldec
		else
			clear
			tput setab 1
			echo " [>] Warning, this will securely delete all of "$KEY"'s decrypted messages, are you sure? [Y/n]:"
			tput setab 9
			read -p " >" DODEL
			clear
		
			case $DODEL in
				"Y")	fsecdeldec;;
				"y")	fsecdeldec;;
				"")		fsecdeldec
			esac

		fmenu
					
	fi
}

fsecdeldec()
{
	tput setab 4
	echo " [*] Securely deleting "$KEY"'s decrypted messages, please wait.."
	find $KEY/$DECDIR -type f -exec shred -zfun 3 {} \;
	tput setab 2
	echo " [*] "$KEY"'s decrypted messages securely deleted."
	tput setab 9
	sleep 2
}

fencryptmsg()															#Encrypt messages
{
	clear
	
	if [ $(find  -mindepth 1 -maxdepth 1 -type d -printf '\n' | wc -l) -lt "1" ]
		then
			fkeygen
	fi
	
	tput setab 6
	echo " [>] Please choose your key"
	tput setab 9
	ls 
	echo
	read -e -p " >" KEY

	if [ ! -d $KEY ]
		then
			tput setab 1
			echo " [*] $KEY is not a valid key, try again."
			tput setab 9
			sleep 1
			fencryptmsg
	
	elif [ $KEY -z ] 2> /dev/null
		then
			tput setab 1
			echo " [*] You must choose a key, try again"
			tput setab 9
			sleep 1
			fencryptmsg
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	
	clear
	tput setab 6
	echo " [>] Please Enter your message:"
	tput setab 9
	read -p " >" MSG
	MSGLEN=${#MSG}
	MSGCNT=0
	touch tmp1
	touch tmp2
	touch tmp3
	
	while [ $MSGCNT -lt $MSGLEN ]
		do
		CHAR=${MSG:$MSGCNT:1}
		case $CHAR in
			"a")ENCC="11";;"b")ENCC="12";;"c")ENCC="13";;"d")ENCC="14";;"e")ENCC="15";;"f")ENCC="16";;"g")ENCC="17";;"h")ENCC="18";;"i")ENCC="19";;"j")ENCC="20";;"k")ENCC="21";;"l")ENCC="22";;"m")ENCC="23";;"n")ENCC="24";;"o")ENCC="25";;"p")ENCC="26";;"q")ENCC="27";;"r")ENCC="28";;"s")ENCC="29";;"t")ENCC="30";;"u")ENCC="31";;"v")ENCC="32";;"w")ENCC="33";;"x")ENCC="34";;"y")ENCC="35";;"z")ENCC="36";;1)ENCC="37";;2)ENCC="38";;3)ENCC="39";;4)ENCC="40";;5)ENCC="41";;6)ENCC="42";;7)ENCC="43";;8)ENCC="44";;9)ENCC="45";;0)ENCC="10";;" ")ENCC="46";;"A")ENCC="47";;"B")ENCC="48";;"C")ENCC="49";;"D")ENCC="50";;"E")ENCC="51";;"F")ENCC="52";;"G")ENCC="53";;"H")ENCC="54";;"I")ENCC="55";;"J")ENCC="56";;"K")ENCC="57";;"L")ENCC="58";;"M")ENCC="59";;"N")ENCC="60";;"O")ENCC="61";;"P")ENCC="62";;"Q")ENCC="63";;"R")ENCC="64";;"S")ENCC="65";;"T")ENCC="66";;"U")ENCC="67";;"V")ENCC="68";;"W")ENCC="69";;"X")ENCC="70";;"Y")ENCC="71";;"Z")ENCC="72";;".")ENCC="73";;"?")ENCC="74";;",")ENCC="75";;"!")ENCC="76"		
		esac
		
		echo $ENCC >> tmp1
		MSGCNT=$(( MSGCNT +1 ))
		done
				
	FILE=tmp1
	MSGNAME=0
	clear
	while [ $MSGNAME = "0" ]
		do
			tput setab 6
			echo " [>] Please Enter a filename for your message:"
			tput setab 9
			read -p " >" ENCCMSGF
			if [ -f $KEY/$ENCCDIR/$ENCCMSGF ]
				then
					tput setab 1
					echo " [*] $ENCCMSGF already exists, Try again.."
					tput setab 9
					sleep 1
					clear
			elif [ $ENCCMSGF -z ] 2> /dev/null
				then
					tput setab 1
					echo " [*] You must Enter a filename, try again."
					tput setab 9
					sleep 1
					clear
			else
				touch $KEY/$ENCCDIR/$ENCCMSGF
				MSGNAME=1
			fi
		done
		
	clear
	tput setab 4
	echo " [*] Encrypting, Please wait.."
	tput setab 9	
		
	while read LINE
		do
			echo $(cat $KEY/$LINE/$LINE | sort -R | head -n 1) >>tmp2
		done <$FILE
		
	echo $(tr '\n' ' ' < tmp2 | sed -e 's/\s//g') > tmp3
		
	FILE=$KEY/meta/meta
	LNUM=1
	while read LINE
		do
		
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE
			esac
		
		LNUM=$(( LNUM + 1 ))
		done <$FILE

	openssl enc -aes-256-gcm -a -salt -in tmp3 -out $KEY/$ENCCDIR/tmp01 -k $PASS1 2> /dev/null
	openssl enc -camellia-256-cbc -a -salt -in $KEY/$ENCCDIR/tmp01  -out $KEY/$ENCCDIR/tmp02 -k $PASS2 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $KEY/$ENCCDIR/tmp02  -out $KEY/$ENCCDIR/$ENCCMSGF -k $PASS3 2> /dev/null	
	
	shred -zfun 3 tmp*
	clear
	RLEN=$(wc -l $DIRR$KEY/$ENCCDIR/$ENCCMSGF)
	DLENT=7
	while [[ "$RLEN" ==  *"/"* ]]
			do
				DLENT=$((DLENT - 1))							
				RLEN=${RLEN:0:$DLENT}
			done
	DLENT=$((DLENT - 1))
	RLEN=${RLEN:0:$DLENT}
	cat $KEY/$ENCCDIR/$ENCCMSGF
	echo
	tput setab 2
	echo " [*] Message is $RLEN lines long and stored at $DIRR$KEY/$ENCCDIR/$ENCCMSGF"
	tput setab 9
	read -p """ [>] Press c and Enter to copy to clipboard
 [>] Press Enter to return to menu
 >""" SMF
	case $SMF in
		"c") cat $KEY/$ENCCDIR/$ENCCMSGF | xclip -sel clip; DISPCOPMSG=1;fmenu;;
		"") fmenu
	esac
}

fdecpaste()
{
	DATER=$(date +%Y_%d_%m_%H_%M_%S)
	touch $KEY/$ENCCDIR/$DATER
	DATEFILE=$KEY/$ENCCDIR/$DATER
	xclip -sel clip -o > $DATEFILE
	ISDONE=1
}

fdecryptmsg()															#Decrypt messages
{
	clear
	tput setab 6
	echo " [>]  Which key?"
	tput setab 9
	ls 
	echo
	read -e -p " >" KEY
	
	if [ ! -d $KEY ]
		then
			tput setab 1
			echo " [*] $KEY is not a valid key, try again."
			tput setab 9
			sleep 1
			fdecryptmsg
	
	elif [ $KEY -z ] 2> /dev/null
		then
			tput setab 1
			echo " [*] You must choose a key, try again."
			tput setab 9
			sleep 1
			fdecryptmsg
	
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	
	touch tmp01
  	touch tmp02
  	touch tmp03
	touch tmp04
	ISDONE=0
	TMPCHK=0
	
	while [ $ISDONE = "0" ]
		do
			clear
			tput setab 6
			echo " [>] Paste your message from clipboard or read message file from 0_Encrypted_Messages? [P/f]:"
			tput setab 9
			read -p " >" DODEC
			case $DODEC in
				"P") fdecpaste;;
				"p") fdecpaste;;
				"") fdecpaste;;
				"f") clear;cd $KEY/$ENCCDIR; ls
				echo
				read -e -p " >" DECMSGF
			
				if [ ! -f $DECMSGF ]
					then
						tput setab 1
						echo " [*] $DECMSGF is not a valid file, try again."
						tput setab 9
						sleep 2
				else
					ISDONE=1
				fi;;
				"F") cd $KEY/$ENCCDIR;ls
				echo
				read -e -p " >" DECMSGF
				if [ ! -f $DECMSGF ]
					then
						tput setab 1
						echo " [*] $DECMSGF is not a valid file, try again."
						tput setab 9
						sleep 2
					else
						ISDONE=1
				fi
			esac
		done
		
	clear
	cd "$DIRR"
	tput setab 4
	echo " [*] Decrypting, Please wait.."
	tput setab 9

	case $DODEC in
		"P") cat $DATEFILE  > $KEY/$ENCCDIR/tmp01;DECMSGF=$DATER;;
		"p") cat $DATEFILE  > $KEY/$ENCCDIR/tmp01;DECMSGF=$DATER;;
		"") cat $DATEFILE  > $KEY/$ENCCDIR/tmp01;DECMSGF=$DATER;;
		"f") cat $KEY/$ENCCDIR/$DECMSGF  > $KEY/$ENCCDIR/tmp01;;
		"F") cat $KEY/$ENCCDIR/$DECMSGF  > $KEY/$ENCCDIR/tmp01
	esac
	
	FILE=$KEY/meta/meta
	LNUM=1
	while read LINE
		do
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <$FILE
		
	openssl enc -aes-256-cbc -d -a -salt -in $KEY/$ENCCDIR/tmp01  -out $KEY/$ENCCDIR/tmp02 -k $PASS3 2> /dev/null	
	openssl enc -camellia-256-cbc -d -a -salt -in $KEY/$ENCCDIR/tmp02  -out $KEY/$ENCCDIR/tmp03 -k $PASS2 2> /dev/null
	openssl enc -aes-256-gcm -d -a -salt -in $KEY/$ENCCDIR/tmp03 -out tmp04 -k $PASS1 2> /dev/null
	
	shred -zfun 3 $KEY/$ENCCDIR/tmp0*
	
	ENCCLEN=$(wc -c tmp04)
	ENCCMSG=$(cat tmp04)
  	CHARCNT=0
  	CHAR=0
  	DECCNT=0

  	while [ $CHAR != " " ] 2> /dev/null
		do
			CHAR=${ENCCLEN:$CHARCNT:1}
			CHARCNT=$(( CHARCNT + 1 ))
		done
	CHARCNT=$(( CHARCNT - 1 ))
	ENLEN=${ENCCLEN:0:$CHARCNT} 
	
	while [ $DECCNT -le $ENLEN ]
		do
			CHAR=${ENCCMSG:$DECCNT:6}
			echo $CHAR >> tmp01
			DECCNT=$(( DECCNT + 6 ))
		done 
	FILE=tmp01
	LINECNT=0
	STPCNT=$(wc -l tmp01)
	
	while read LINE
		do			
			LONGLET=$(grep -rl $LINE $KEY/)
			echo ${LONGLET: -2} >> tmp02 
		done <$FILE
	FILE=tmp02

	while read LINE
		do
			case $LINE in
				10)DECC="0";;11)DECC="a";;12)DECC="b";;13)DECC="c";;14)DECC="d";;15)DECC="e";;16)DECC="f";;17)DECC="g";;18)DECC="h";;19)DECC="i";;20)DECC="j";;21)DECC="k";;22)DECC="l";;23)DECC="m";;24)DECC="n";;25)DECC="o";;26)DECC="p";;27)DECC="q";;28)DECC="r";;29)DECC="s";;30)DECC="t";;31)DECC="u";;32)DECC="v";;33)DECC="w";;34)DECC="x";;35)DECC="y";;36)DECC="z";;37)DECC="1";;38)DECC="2";;39)DECC="3";;40)DECC="4";;41)DECC="5";;42)DECC="6";;43)DECC="7";;44)DECC="8";;45)DECC="9";;46)echo -n ' ' >> tmp03;DECC=" ";;47)DECC="A";;48)DECC="B";;49)DECC="C";;50)DECC="D";;51)DECC="E";;52)DECC="F";;53)DECC="G";;54)DECC="H";;55)DECC="I";;56)DECC="J";;57)DECC="K";;58)DECC="L";;59)DECC="M";;60)DECC="N";;61)DECC="O";;62)DECC="P";;63)DECC="Q";;64)DECC="R";;65)DECC="S";;66)DECC="T";;67)DECC="U";;68)DECC="V";;69)DECC="W";;70)DECC="X";;71)DECC="Y";;72)DECC="Z";;73)DECC=".";;74)DECC="?";;75)DECC=",";;76)DECC="!"
			esac
			
			echo -n $DECC >> tmp03
		done <$FILE
		
	DEKD=$(cat tmp03)
	echo "${DEKD%?}" > $KEY/$DECDIR/$DECMSGF
	shred -zfun 3 tmp0*
	clear
	cat $KEY/$DECDIR/$DECMSGF
	echo
	tput setab 2
	echo " [*] Message saved to $DIRR$KEY/$DECDIR/$DECMSGF"
	tput setab 9
	read -p " [>] Press Enter to return to menu" SMF
	fmenu
}

fencryptfile()
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 	
	read -e -p " >" KEY
	
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fencryptfile
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	clear
	tput setab 6
	echo " [>] Please Enter the location of the file: e.g. $HOME/file"
	tput setab 9
	read -e -p " >" INFILE
	
	if [ ! -f $INFILE ]
		then
			tput setab 1
			echo " [*] There does not appear to be any file at $INFILE, try again.."
			tput setab 9
			sleep 2
			fencryptfile
	fi
	clear
	PASS=$(cat $KEY/meta/meta)
	ENCCMSGF=$(basename $INFILE)
	tput setab 4
	echo " [*] Decrypting "$ENCCMSF", please wait.."
	tput setab 9
	
	if [ ! -d $KEY/$ENCCDIR/0_Encrypted_Files ]
		then
			mkdir $KEY/$ENCCDIR/0_Encrypted_Files
	fi
	FILE=$KEY/meta/meta
	LNUM=1
	
	while read LINE
		do
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE
			esac
		LNUM=$(( LNUM + 1 ))
		done <$FILE

	openssl enc -aes-256-cbc -a -salt -in $INFILE -out $KEY/$ENCCDIR/tmp01 -k $PASS2 2> /dev/null	
	openssl enc -camellia-256-cbc -a -salt -in $KEY/$ENCCDIR/tmp01  -out $KEY/$ENCCDIR/tmp02 -k $PASS1 2> /dev/null
	openssl enc -aes-256-gcm -a -salt -in $KEY/$ENCCDIR/tmp02 -out $KEY/$ENCCDIR/0_Encrypted_Files/$ENCCMSGF -k $PASS3 2> /dev/null

	clear
	tput setab 2
	echo " [*] File saved to $DIRR$KEY/$ENCCDIR/0_Encrypted_Files/$ENCCMSGF"
	tput setab 9
	echo
	echo " [*] Press c and Enter to copy encrypted file to the clipboard"
	read -p " [>] Press Enter to return to menu" DOFILE
	echo
	case $DOFILE in
		"c")cat $KEY/$ENCCDIR/0_Encrypted_Files/$ENCCMSGF | xclip -sel clip;DISPCOP=1;fmenu;;
		"C")cat $KEY/$ENCCDIR/0_Encrypted_Files/$ENCCMSGF | xclip -sel clip;DISPCOP=1;fmenu;;
		"")fmenu
	esac
}

fdecryptfile()
{
	clear
	tput setab 6
	echo " [>] Which key?"
	tput setab 9
	ls 	
	read -e -p " >" KEY
	
	if [ ! -d $KEY ]
		then
			clear
			tput setab 1
			echo " [*] $KEY is not a valid key, try again.."
			tput setab 9
			sleep 1
			fencryptfile
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	clear
	tput setab 6
	echo " [>] Please Enter the location of the file: e.g. $HOME/file"
	tput setab 9
	read -e -p " >" INFILE
	
	if [ ! -f $INFILE ]
		then
			tput setab 1
			echo " [*] There does not appear to be any file at $INFILE, try again.."
			tput setab 9
			sleep 2
			fdecryptfile
	fi
	PASS=$(cat $KEY/meta/meta)
	DECMSGT=$(basename $INFILE)
	
	if [ ! -d $KEY/$DECDIR/0_Decrypted_Files ]
		then
			mkdir $KEY/$DECDIR/0_Decrypted_Files
	fi
	FILE=$KEY/meta/meta
	LNUM=1
	
	while read LINE
		do
		
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE
			esac
		
		LNUM=$(( LNUM + 1 ))
		done <$FILE
		
	openssl enc -aes-256-gcm -d -a -salt -in $INFILE -out $KEY/$ENCCDIR/tmp01 -k $PASS3 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in $KEY/$ENCCDIR/tmp01  -out $KEY/$ENCCDIR/tmp02 -k $PASS1 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $KEY/$ENCCDIR/tmp02  -out $KEY/$DECDIR/0_Decrypted_Files/$DECMSGT -k $PASS2 2> /dev/null	

	shred -zfun 3 $KEY/$ENCCDIR/tmp0*
	clear
	tput setab 2
	echo " [*] File saved to $KEY/$DECDIR/0_Decrypted_Files/$DECMSGT"
	tput setab 9
	echo
	file $KEY/$DECDIR/0_Decrypted_Files/$DECMSGT
	echo
	read -p " [>] Press Enter to return to menu"
	fmenu
}

flistgen()																#Generate full list of 6 digit numbers to use for random number crypto 
{
	cd $DIRR
	touch list
	clear
	STARTNUM=100000

	while [ $STARTNUM -le 999999 ]
		do
			if [ $(( $STARTNUM % 10000 )) -eq 0 ]
				then
					CHECKMSG=1
			fi
			
			if [ $CHECKMSG = "1" ]
				then
					DONENUM=$((STARTNUM - 100000))
					PERCENT=$((DONENUM / 9000))
					clear
					tput setab 2
					echo " [*] Setting up Nypt for first use, please wait.."
					tput setab 4
					echo " [*] Done "$PERCENT"%   "$DONENUM"/900000 lines"
					tput setab 9
					CHECKMSG=0
			fi
			echo -n $STARTNUM >> list
			echo \ >> list
			STARTNUM=$(( STARTNUM + 1 ))
		done
	echo
	tput setab 2
	echo " [*] Setup complete!"
	tput setab 9
	sleep 1
}
 
fexit()																	#Delete left over tempory files when exitting
{
	tput setab 9
	cd $DIRR
	if [[ -f tmp* ]]
		then
			(shred -zfun 3 tmp*)
	fi

	echo
	exit
}
	
	DIRR=$HOME/Desktop/nypt/
	if [ ! -d $DIRR ]
		then k
			mkdir $DIRR
			flistgen
	fi
	
	if [ ! -f "$DIRR"list ]
		then
			flistgen
	fi
	
	cd $DIRR
	fstart
