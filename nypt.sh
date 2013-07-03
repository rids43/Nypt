#!/bin/bash

## Crypt files and messages using three layers of openssl 256-bit encryption and a layer of random number encryption

fstart()																#Startup function
{
	COLOR="tput setab"
	DIRR=$HOME/Desktop/nypt/
	if [ ! -d $DIRR ]
		then
			mkdir $DIRR
	fi
	
	if [ ! -f "$DIRR"list ]
		then
			cp "$PWD"/list "$DIRR"list 2> /dev/null
			if [ ! -f "$DIRR"list ]
				then
					flistgen
			fi
	fi
	
	
	cd $DIRR
	ENCDIR="0_Encrypted_Messages"
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
					$COLOR 6
					read -p " [*] It looks like $COMMAND is not installed on your system, it is needed by Nypt. Do you want to install it? [Y/n]" INSTALL
					$COLOR 9
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
					$COLOR 2
					echo " [*] $COMMAND found"
					$COLOR 9
			fi
		done < tmp1
		
	rm -rf tmp1
	fmenu
}

fmenu()
{
	clear
	if [ $DISPCOP = "1" ] 2> /dev/null
		then
			$COLOR 2
			echo " [*] File text copied to clipboard"
			$COLOR 9
			DISPCOP=0
	elif [ $DISPCOPMSG = "1" ] 2> /dev/null
		then
			$COLOR 2
			echo " [*] Message copied to clipboard"
			DISPCOPMSG=0
			$COLOR 9
	fi
	cd $DIRR
	$COLOR 6
	echo "  [*] Nypt 1.34"		
	$COLOR 9														#This is the main menu
	read -p """      ~~~~~~~~
 [1] Encryption
 [2] Decryption
 [3] Keys
 [4] Quit
 >""" MENU
  
		case $MENU in
	1)	clear
		$COLOR 6
		echo " [*] Encryption Menu"
		$COLOR 9
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
		$COLOR 6
		echo " [*] Decryption Menu"
		$COLOR 9
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
		$COLOR 6
		echo " [*] Key Menu"
		$COLOR 9
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

fkeygen()																#Generate keys
{
	clear
	$COLOR 6
	echo " [>] What shall we name your key?"
	$COLOR 9
	read -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key name, try again..."
			$COLOR 9
			sleep 2
			fkeygen
	fi
	if [ -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY already exists, try again..."
			$COLOR 9
			sleep 2
			fkeygen
		else
			clear
			$COLOR 4
			echo " [*] Generating $KEY, please wait..."
			mkdir $KEY
			mkdir $KEY/$ENCDIR
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
			RAND4=${RANDOM:0:2}
			RAND5=${RANDOM:0:2}
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
			if [ $RAND4 -le 50 ]
				then
					RAND4=$(( RAND4 + 35 ))
			fi
			if [ $RAND5 -le 50 ]
				then
					RAND5=$(( RAND5 + 35 ))
			fi
			mkdir $KEY/meta/
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND1 | tr -d '\n'; echo) > $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND2 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND3 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND4 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND5 | tr -d '\n'; echo) >> $KEY/meta/meta

			shred -zfun 3 $KEY/list
			echo
			$COLOR 2
			echo " [*] $KEY Complete!"
			$COLOR 9
			sleep 1.5
			fmenu
	fi
}

fencryptmsg()															#Encrypt messages
{
	clear
	
	if [ $(find  -mindepth 1 -maxdepth 1 -type d -printf '\n' | wc -l) -lt "1" ]
		then
			fkeygen
	fi
	
	$COLOR 6
	echo " [>] Please choose your key"
	$COLOR 9
	ls 
	echo
	read -e -p " >" KEY

	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fencryptmsg
	
	elif [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must choose a key, try again..."
			$COLOR 9
			sleep 1.5
			fencryptmsg
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	
	clear
	$COLOR 6
	echo " [>] Please Enter your message:"
	$COLOR 9
	read -p " >" MSG
	MSGLEN=${#MSG}
	MSGCNT=0
	
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
			$COLOR 6
			echo " [>] Please Enter a filename for your message:"
			$COLOR 9
			read -p " >" ENCCMSGF
			if [ -f $KEY/$ENCDIR/$ENCCMSGF ]
				then
					$COLOR 1
					echo " [*] $ENCCMSGF already exists, Try again..."
					$COLOR 9
					sleep 1.5
					clear
			elif [ $ENCCMSGF -z ] 2> /dev/null
				then
					$COLOR 1
					echo " [*] You must Enter a filename, try again..."
					$COLOR 9
					sleep 1.5
					clear
			else
				MSGNAME=1
			fi
		done
		
	clear
	$COLOR 4
	echo " [*] Encrypting, Please wait.."
	$COLOR 9	
		
	while read LINE
		do
			echo $(cat $KEY/$LINE/$LINE | sort -R | head -n 1) >>tmp2
		done <$FILE
		
	echo $(tr '\n' ' ' < tmp2 | sed -e 's/\s//g') > tmp3
		
	FILE=$DIRR$KEY"/meta/meta"
	LNUM=1
	while read LINE
		do
			case $LNUM in
					1)PASS1="$LINE";;
					2)PASS2="$LINE";;
					3)PASS3="$LINE";;
					4)PASS4="$LINE";;
					5)PASS5="$LINE"
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <"$FILE"

	openssl enc -aes-256-cbc -a -salt -in tmp3 -out $DIRR$KEY/$ENCDIR/tmp01 -k "$PASS1" 2> /dev/null
	openssl enc -camellia-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS2" 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp02  -out $DIRR$KEY/$ENCDIR/tmp03 -k "$PASS3" 2> /dev/null
	openssl enc -camellia-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp03  -out $DIRR$KEY/$ENCDIR/tmp04 -k "$PASS4" 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp04  -out $DIRR$KEY/$ENCDIR/$ENCCMSGF -k "$PASS5" 2> /dev/null	
	
	shred -zfun 3 tmp*
	clear
	RLEN=$(wc -l $DIRR$KEY/$ENCDIR/$ENCCMSGF)
	DLENT=7
	while [[ "$RLEN" ==  *"/"* ]]
			do
				DLENT=$((DLENT - 1))							
				RLEN=${RLEN:0:$DLENT}
			done
	DLENT=$((DLENT - 1))
	RLEN=${RLEN:0:$DLENT}
	cat $KEY/$ENCDIR/$ENCCMSGF
	echo
	$COLOR 2
	echo " [*] Message is $RLEN lines long and stored at $DIRR$KEY/$ENCDIR/$ENCCMSGF"
	$COLOR 9
	read -p """ [>] Press c and Enter to copy to clipboard
 [>] Press Enter to return to menu
 >""" SMF
	case $SMF in
		"c") cat $KEY/$ENCDIR/$ENCCMSGF | xclip -sel clip; DISPCOPMSG=1;fmenu;;
		"") fmenu
	esac
}

fdecryptmsg()															#Decrypt messages
{
	clear
	$COLOR 6
	echo " [>]  Which key?"
	$COLOR 9
	ls 
	echo
	read -e -p " >" KEY
	
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fdecryptmsg
	
	elif [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must choose a key, try again..."
			$COLOR 9
			sleep 1.5
			fdecryptmsg
	
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	
	ISDONE=0
	TMPCHK=0
	
	while [ $ISDONE = "0" ]
		do
			clear
			$COLOR 6
			echo " [>] Paste your message from clipboard or read message file from 0_Encrypted_Messages? [P/f]:"
			$COLOR 9
			read -p " >" DODEC
			case $DODEC in
				"P") fdecpaste;;
				"p") fdecpaste;;
				"") fdecpaste;;
				"f") clear; LSS=$(ls $KEY/$ENCDIR)
				if [ $LSS -z ] 2> /dev/null
					then
						$COLOR 1
						echo " [*] There are no files in $DIRR$KEY/$ENCDIR"
						$COLOR 9
						sleep 2
						fmenu
					else
						echo $LSS
					
				fi
				cd $KEY/$ENCDIR
				read -e -p " >" DECMSGF

				if [ ! -f $DECMSGF ]
					then
						$COLOR 1
						echo " [*] $DECMSGF is not a valid file, try again..."
						$COLOR 9
						sleep 2
				else
					ISDONE=1
				fi;;
				"F") clear; LSS=$(ls $KEY/$ENCDIR)
				if [ $LSS -z ] 2> /dev/null
					then
						$COLOR 1
						echo " [*] There are no files in $DIRR$KEY/$ENCDIR"
						$COLOR 9
						sleep 2
						fmenu
					else
						echo $LSS
					
				fi
				cd $KEY/$ENCDIR
				read -e -p " >" DECMSGF

				if [ ! -f $DECMSGF ]
					then
						$COLOR 1
						echo " [*] $DECMSGF is not a valid file, try again..."
						$COLOR 9
						sleep 2
				else
					ISDONE=1
				fi
			esac
		done
		
	clear
	cd "$DIRR"
	$COLOR 4
	echo " [*] Decrypting, Please wait.."
	$COLOR 9
	DATEFILE="$DIRR""$KEY"/"$ENCDIR"/"$DATER"
	case $DODEC in
		"P") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DECMSGF="$DATER";;
		"p") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DECMSGF="$DATER";;
		"") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DECMSGF="$DATER";;
		"f") cat $KEY/$ENCDIR/$DECMSGF  > $KEY/$ENCDIR/tmp01;;
		"F") cat $KEY/$ENCDIR/$DECMSGF  > $KEY/$ENCDIR/tmp01
	esac
	
	FILE=$DIRR$KEY"/meta/meta"
	LNUM=1
	while read LINE
		do
			case $LNUM in
					1)PASS1="$LINE";;
					2)PASS2="$LINE";;
					3)PASS3="$LINE";;
					4)PASS4="$LINE";;
					5)PASS5="$LINE"
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <"$FILE"
		
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS5" 2> /dev/null	
	openssl enc -camellia-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp02  -out $DIRR$KEY/$ENCDIR/tmp03 -k "$PASS4" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp03  -out $DIRR$KEY/$ENCDIR/tmp04 -k "$PASS3" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp04  -out $DIRR$KEY/$ENCDIR/tmp05 -k "$PASS2" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp05 -out $DIRR$KEY/$ENCDIR/tmp06 -k "$PASS1" 2> /dev/null

	mv $DIRR$KEY/$ENCDIR/tmp06 $PWD/tmp04
	shred -zfun 3 $KEY/$ENCDIR/tmp0*
	
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
	shred -zfun 3 $PWD/tmp04
	clear
	cat $KEY/$DECDIR/$DECMSGF
	echo
	$COLOR 2
	echo " [*] Message saved to $DIRR$KEY/$DECDIR/$DECMSGF"
	$COLOR 9
	read -p " [>] Press Enter to return to menu" SMF
	fmenu
}

fdecpaste()
{
	DATER=$( date +%Y_%d_%m_%H_%M_%S )
	DATEFILE="$DIRR""$KEY"/"$ENCDIR"/"$DATER"
	touch $DATEFILE
	xclip -sel clip -o > $DATEFILE
	ISDONE=1
}

fencryptfile()
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 	
	read -e -p " >" KEY
	
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fencryptfile
	fi
	
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fencryptfile
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	clear
	$COLOR 6
	echo " [>] Please Enter the location of the file: e.g. $HOME/file"
	$COLOR 9
	read -e -p " >" INFILE
	
	if [ $INFILE -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter the path to the keyfile e.g. $HOME/file, try again..."
			$COLOR 9
			sleep 1.5
			fencryptfile
	fi
	
	if [ ! -f $INFILE ]
		then
			$COLOR 1
			echo " [*] There does not appear to be any file at $INFILE, try again..."
			$COLOR 9
			sleep 2
			fencryptfile
	fi
	clear
	PASS=$(cat $KEY/meta/meta)
	ENCCMSGF=$(basename $INFILE)
	$COLOR 4
	echo " [*] Encrypting "$ENCCMSF", please wait.."
	$COLOR 9
	
	if [ ! -d $KEY/$ENCDIR/0_Encrypted_Files ]
		then
			mkdir $KEY/$ENCDIR/0_Encrypted_Files
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

	openssl enc -aes-256-cbc -a -salt -in $INFILE -out $DIRR$KEY/$ENCDIR/tmp01 -k "$PASS2" 2> /dev/null	
	openssl enc -camellia-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS1" 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp02 -out $DIRR$KEY/$ENCDIR/0_Encrypted_Files/$ENCCMSGF -k "$PASS3" 2> /dev/null

	clear
	$COLOR 2
	echo " [*] File saved to $DIRR$KEY/$ENCDIR/0_Encrypted_Files/$ENCCMSGF"
	$COLOR 9
	echo
	echo " [*] Press c and Enter to copy encrypted file to the clipboard"
	read -p " [>] Press Enter to return to menu" DOFILE
	echo
	case $DOFILE in
		"c")cat $KEY/$ENCDIR/0_Encrypted_Files/$ENCCMSGF | xclip -sel clip;DISPCOP=1;fmenu;;
		"C")cat $KEY/$ENCDIR/0_Encrypted_Files/$ENCCMSGF | xclip -sel clip;DISPCOP=1;fmenu;;
		"")fmenu
	esac
}

fdecryptfile()
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 	
	read -e -p " >" KEY
	
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fdecryptfile
	fi
	
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fencryptfile
	elif [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	clear
	$COLOR 6
	echo " [>] Please Enter the location of the file: e.g. $HOME/file"
	$COLOR 9
	read -e -p " >" INFILE
	
	if [ $INFILE -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter the location of the file e.g. $HOME/file, try again..."
			$COLOR 9
			sleep 1.5
			fencryptfile
	fi
	
	if [ ! -f $INFILE ]
		then
			$COLOR 1
			echo " [*] There does not appear to be any file at $INFILE, try again..."
			$COLOR 9
			sleep 2
			fdecryptfile
	fi
	DECMSGT=$(basename $INFILE)
	PASS=$(cat $KEY/meta/meta)
	clear
	$COLOR 4
	echo " [*] Decrypting "$DECMSGT", please wait.."
	$COLOR 9
	
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
		
	openssl enc -aes-256-cbc -d -a -salt -in $INFILE -out $DIRR$KEY/$ENCDIR/tmp01 -k "$PASS3" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS1" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp02  -out $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DECMSGT -k "$PASS2" 2> /dev/null	

	shred -zfun 3 $KEY/$ENCDIR/tmp0*
	clear
	$COLOR 2
	echo " [*] File saved to $KEY/$DECDIR/0_Decrypted_Files/$DECMSGT"
	$COLOR 9
	echo
	STRT=" [*] "
	CHKFILE=$( file $KEY/$DECDIR/0_Decrypted_Files/$DECMSGT )
	$COLOR 5
	echo $STRT$CHKFILE
	$COLOR 9
	echo
	read -p " [>] Press Enter to return to menu"
	fmenu
}

fcatenc()																#Read encrypted messages from the 0_Encrypted_Messages Directory
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 	
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fcatenc
	fi
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fcatenc
		else
			clear
			$COLOR 6
			echo " [>] Which file do you want to read?"
			$COLOR 9
			cd $KEY/$ENCDIR;ls
			read -e -p " >" ENCCAT
			if [ -f $ENCCAT ]
				then
					clear
					clear
					cat $ENCCAT
					echo
					DLEN=$(wc -l $DIRR$KEY"/"$ENCDIR"/"$ENCCAT)
					DLENT=7
					RLEN=${DLEN:0:$DLENT}
					while [[ "$RLEN" ==  *"/"* ]]
						do
							DLENT=$((DLENT - 1))							
							RLEN=${DLEN:0:$DLENT}
						done
					
					DLENT=$((DLENT - 1))
					RLEN=${DLEN:0:$DLENT}
					$COLOR 2
					echo " [*] Message is $RLEN lines long and stored at $DIRR$KEY/$ENCDIR/$ENCCAT"
					$COLOR 9
					echo " [>] Press c and Enter to copy to clipboard"
					read -p """ [>] Press Enter to return to menu
 >""" SMF
					case $SMF in
						"c") cat $ENCCAT | xclip -sel clip;DISPCOPMSG=1;fmenu;;
						"") fmenu
					esac
					
				else
					clear
					$COLOR 1
					echo " [*] There does not appear to be any file at $ENCCAT, try again..."
					$COLOR 9
					sleep 2
					fcatenc
			fi
	fi
}


fcatdec()																#Read decrypted messages from the 0_Decrypted_Messages Directory
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 	
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fcatdec
	fi
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fcatdec
		else
			clear
			$COLOR 6
			echo " [>] Which file do you want to read?"
			$COLOR 9
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
					$COLOR 1
					echo " [*] There does not appear to be any file at $DECCAT, try again..."
					$COLOR 9
					sleep 2
					fcatdec
			fi
	fi
}

fopenenc()
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 	
	read -e -p " >" KEY
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 2
			fopenenc
	fi
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
			
	if [ ! -d $KEY/$ENCDIR ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 2
			fopenenc
		else
			nautilus $KEY/$ENCDIR 2> /dev/null
	fi

	fmenu	
}

fopendec()
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 2
			fopendec
	fi
	if [ ! -d $KEY/$DECDIR ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 2
			fopendec
		else
			nautilus $KEY/$DECDIR 2> /dev/null
	fi
	fmenu
}

fimport()
{
	clear
	$COLOR 6
	echo " [>] Please Enter the location of the key file eg. $HOME/Desktop/key"
	$COLOR 9
	read -e -p " >" KEYLOC
	if [ $KEYLOC -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter the path to key file eg. $HOME/Desktop/key, try again..."
			$COLOR 9
			sleep 2
			fimport
		else
			KEYFILE=$(basename $KEYLOC)
	fi
	if [ -f $KEYLOC ]
		then
			$COLOR 6
			echo " [>] Do you have a custom key password? [Y/n]:" 
			$COLOR 9
			read -p " >" CUSTP
			
			case $CUSTP in
			
				"Y")fimportcus;;
			
				"y")fimportcus;;
				
				"n")fimportdef;;
			
				"N")fimportdef;;
			
				"")fimportcus
			
			esac
		else
			$COLOR 1
			echo " [*] There does not appear to be any file at $KEYFILE, try again..."
			$COLOR 9
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
			$COLOR 6
			echo " [>] Please Enter the password"
			$COLOR 9
			read -s RPASS
			$COLOR 6
			echo " [>] Enter one more time"
			$COLOR 9
			read -s SPASS
			if [ $RPASS != $SPASS ]
				then
					$COLOR 1
					echo " [*] Passwords do not match, try again..."
					$COLOR 9
					sleep 2
				else
					DONPS=1
			fi
		done
	NPASS=$(echo $SPASS | base64)
	NPASS=$(echo $NPASS$NPASS | md5sum)
	GPASS=$(echo NPASS | md5sum)
	LPASS=$NPASS$GPASS$SPASS$GPASS
	FPASS=$SPASS$GPASS$NPASS
	MPASS=$FPASS$NPASS$SPASS
	
	openssl enc -aes-256-cbc -d -a -salt -in $KEYLOC -out tmp01 -k "$LPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in tmp01 -out tmp02 -k "$MPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in tmp03 -out tmp04 -k "$NPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in tmp04 -out $DIRR$KEYFILE.zip -k "$SPASS" 2> /dev/null
	
	unzip -P $SPASS $KEYFILE.zip -d .  2> /dev/null
	chown -hR $USER $KEYFILE
	clear
	$COLOR 2
	echo " [*] $KEYFILE imported."
	$COLOR 9
	shred -zfun 3 $KEYFILE.zip
	shred -zfun 3 tmp0*
	sleep 2
	fmenu
}

fimportdef()															#Import key using default password
{
	openssl enc -d -a -aes-256-cbc -salt -in $KEYLOC -out $DIRR$KEY.zip -k "FQhs2UOb6UfY6h4h20hf49LTS9EnkSuQP66357693hahal0lp4s501EfOoWCvjScbanpDrJ3sWXupryAQLj71Qt" 2> /dev/null
	unzip -P "cPHQ0bkM2zEUZY245h9ZwgS7l98Hi0WqIeamJVhow1osQ" $KEY.zip -d .  2> /dev/null
	shred -zfun 3 $KEY.zip
	shred -zfun 3 $KEY
	chown -hR $USER $KEYFILE
	clear
	$COLOR 2
	echo " [*] $KEYFILE imported."
	$COLOR 9
	sleep 2
	fmenu
}

fexport()
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 
	read -e -p " >" KEY
	
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep
	fi
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fexport
		else
			if [ ! -d $KEY/0_Exported_Keys ]
				then
					mkdir $KEY/0_Exported_Keys
			fi			
			
			WHSAV="$KEY/0_Exported_Keys"
			clear
			PASSCHI=""
			$COLOR 1
			echo " [*] Please note it is NOT safe to export keys over untrusted networks using the default password."
			$COLOR 9
			echo
			$COLOR 6
			echo " [>] Do you want to use the default or a custom password? [C/d]:"
			$COLOR 9
			read -p " >" PASSCHI

			case $PASSCHI in
				"")fexportcus;;
			
				"D")fexportdef;;
			
				"d")fexportdef;;
			
				"c")fexportcus;;
			
				"C")fexportcus;;
			esac

	clear
	$COLOR 2
	echo " [*] $KEY exported to $DIRR$WHSAV/$KEY"
	$COLOR 9
	shred -zfun 3 "$WHSAV"/tmp0*
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
			$COLOR 6
			echo " [>] Please Enter your password"
			$COLOR 9
			read -s  TPASS
			$COLOR 6
			echo " [>] Enter once more"  
			$COLOR 9
			read -s ZPASS
			if [ $TPASS != $ZPASS ]
				then
					$COLOR 1
					echo " [*] Passwords do not match, try again..."
					$COLOR 9
					sleep 2
				else
					PASSDON=1
					NPASS=$(echo $ZPASS | base64)
					NPASS=$(echo $NPASS$NPASS | md5sum)
					GPASS=$(echo NPASS | md5sum)
					LPASS=$NPASS$GPASS$ZPASS$GPASS
					FPASS=$ZPASS$GPASS$NPASS
					MPASS=$FPASS$NPASS$ZPASS
					
					zip -reP $ZPASS $KEY.zip $KEY 

					openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY.zip -out "$WHSAV"/tmp01 -k "$ZPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -a -salt -in "$WHSAV"/tmp01 -out "$WHSAV"/tmp02 -k "$NPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in "$WHSAV"/tmp02 -out "$WHSAV"/tmp03 -k "$GPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -a -salt -in "$WHSAV"/tmp03 -out "$WHSAV"/tmp04 -k "$MPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in "$WHSAV"/tmp04 -out $WHSAV/$KEY -k "$LPASS" 2> /dev/null
					
			fi
		done
}

fexportdef()          													#Export key using default password
{
	( zip -reP "cPHQ0bkM2zEUZY245h9ZwgS7l98Hi0WqIeamJVhow1osQ" $KEY.zip $KEY ) 2> /dev/null
	openssl enc -a -aes-256-cbc -salt -in $DIRR$KEY.zip -out $WHSAV/$KEY -k "FQhs2UOb6UfY6h4h20hf49LTS9EnkSuQP66357693hahal0lp4s501EfOoWCvjScbanpDrJ3sWXupryAQLj71Qt" 2> /dev/null
}


fsecuredelkey()															#Shred key
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredelkey
	fi
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredelkey
		else
			clear
			$COLOR 1
			echo " [>] Warning, this will securely delete $KEY and all of its messages, are you sure? [Y/n]: " 
			$COLOR 9
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
	$COLOR 4
	echo " [*] Securely deleting $KEY, please wait.."
	find $KEY/ -type f -exec shred -zfun 3 {} \;
	rm -rf $KEY
	$COLOR 2
	echo " [*] $KEY and all its messages securely deleted."
	$COLOR 9
	sleep 2
}

fsecuredelenc()															#Shred encrypted messages
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredelenc
	fi
			
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredelenc
		else
			clear
			$COLOR 1
			echo " [>] Warning, this will securely delete all of "$KEY"'s encrypted messages, are you sure? [Y/n]:"
			$COLOR 9
			read -p " >" DODEL
		
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
	$COLOR 4
	echo " [*] Securely deleting "$KEY"'s encrypted messages, please wait.."
	find $KEY/$ENCDIR -type f -exec shred -zfun 3 {} \;
	$COLOR 2
	echo " [*] "$KEY"'s encrypted messages securely deleted."
	$COLOR 9
	sleep 2
}

fsecuredeldec()															#Shred decrypted messages  
{
	clear
	$COLOR 6
	echo " [>] Which key?"
	$COLOR 9
	ls 
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1
			echo " [*] You must enter a key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredeldec
	fi
			
	if [ ! -d $KEY ]
		then
			$COLOR 1
			echo " [*] $KEY is not a valid key, try again..."
			$COLOR 9
			sleep 1.5
			fsecuredeldec
		else
			clear
			$COLOR 1
			echo " [>] Warning, this will securely delete all of "$KEY"'s decrypted messages, are you sure? [Y/n]:"
			$COLOR 9
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
	$COLOR 4
	echo " [*] Securely deleting "$KEY"'s decrypted messages, please wait.."
	find $KEY/$DECDIR -type f -exec shred -zfun 3 {} \;
	$COLOR 2
	echo " [*] "$KEY"'s decrypted messages securely deleted."
	$COLOR 9
	sleep 2
}

flistgen()																#Generate full list of 6 digit numbers to use for random number crypto 
{
	cd $DIRR
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
					$COLOR 2
					echo " [*] Setting up Nypt for first use, please wait.."
					$COLOR 4
					echo " [*] Done "$PERCENT"%   "$DONENUM"/900000 lines"
					$COLOR 9
					CHECKMSG=0
			fi
			echo -n $STARTNUM >> list
			echo \ >> list
			STARTNUM=$(( STARTNUM + 1 ))
		done
	clear
	$COLOR 2
	echo " [*] Setup complete!"
	$COLOR 9
	sleep 1.5
}
 
fexit()																	#Delete left over tempory files when exitting
{
	$COLOR 9
	cd $DIRR
	shred -zfun 3 tmp* 2> /dev/null
	echo
	exit
	
}
	
	fstart
