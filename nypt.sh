#!/bin/bash

## Nypt 1.34 Copyright 2013, Rids43 (rids@tormail.org)
#
## Crypt files, messages and keys using a layer of random number encryption 
## and five layers of openssl 256-bit AES and Camellia CBC encryption.
## Uses SSH to transfer data.
#
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
#
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License at (http://www.gnu.org/licenses/) for
## more details.


fstart()																#Startup function
{
	COLOR="tput setab"
	DIRR=$HOME/Desktop/nypt/keys/
	if [ ! -d $DIRR ]
		then
			mkdir $HOME/Desktop/nypt/ 2> /dev/null
			mkdir $HOME/Desktop/nypt/SSH_Recieved_Files 2> /dev/null
			mkdir $DIRR
			DEPCHK=1
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
	
	if [ $DEPCHK = "1" ] 2> /dev/null
		then		
			LIST="""shred
ssh
scp
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
							$COLOR 4;echo " [*] $COMMAND not found, Installing...";$COLOR 9
							if [ $(whoami) = "root" ]
								then
									apt-get install $COMMAND
									if [ $(which $COMMAND) -z ] 2> /dev/null
										then
											$COLOR 1;echo " [*] Error $COMMAND could not be installed, please install manually";$COLOR 9
										else
											$COLOR 2;echo " [*] $COMMAND Installed";$COLOR 9
									fi
								else
									sudo apt-get install $COMMAND
									if [ $(which $COMMAND) -z ] 2> /dev/null
										then
											$COLOR 1;echo " [*] Error $COMMAND could not be installed, please install manually";$COLOR 9
											sleep 0.4
										else
											$COLOR 2;echo " [*] $COMMAND Installed";$COLOR 9
									fi
							fi
						else 
							$COLOR 2;echo " [*] $COMMAND found";$COLOR 9
					fi
				done < tmp1
	sleep 1.5
	rm -rf tmp1
	fi
	if [ $(find  -mindepth 1 -maxdepth 1 -type d -printf '\n' | wc -l) -lt "1" ]
		then
			fkeygen
	fi
	fmenu
}

fmenu()																	#Main menu
{
	cd $DIRR
	clear
	SSHSEND=0
	if [ $DISPCOP = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] "$EMSGFILE"'s encrypted text copied to clipboard!";$COLOR 9
			DISPCOP=0
	elif [ $DISPCOPMSG = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] Message copied to clipboard!";$COLOR 9
			DISPCOPMSG=0
	elif [ $DISPKEY = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] $KEY Complete!";$COLOR 9
			DISPKEY=0
	elif [ $DISPSHRED = "1" ] 2> /dev/null
		then
			$COLOR 2;echo " [*] $DMSGFILE shredded!";$COLOR 9
			DISPSHRED=0
	elif [ $DISPSSH = "1" ] 2> /dev/null
		then
			$COLOR 2;echo " [*] $BASEFILE sent to "$RUSER"@"$IPSEND"";$COLOR 9
			DISPSSH=0

	fi
	$COLOR 6;echo " [*] Nypt 1.34";$COLOR 9															
	read -e -p """      ~~~~~~~~
 [1] Encryption
 [2] Decryption
 [3] Keys
 [4] SSH
 [5] Quit
 >""" MENU
  
		case $MENU in
	1)	clear
		$COLOR 6;echo " [*] Encryption Menu";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Encrypt a message.
 [2] Encrypt a file.
 [3] Browse Encryption folder.
 [4] Read Encrypted messages.
 [5] Securely delete Encrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fencryptmsg;;2)fencryptfile;;3)OPENDIR=$ENCDIR;fopendir;;4)CATDIR=$ENCDIR;fcat;;5)SHREDDIR=$ENCDIR;fshreddir;;6)fmenu;esac
	;;
	2)	clear
		$COLOR 6;echo " [*] Decryption Menu";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Decrypt a message.
 [2] Decrypt a file.
 [3] Browse Decryption folder.
 [4] Read Decrypted messages.
 [5] Securely delete Decrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fdecryptmsg;;2)fdecryptfile;;3)OPENDIR=$DECDIR;fopendir;;4)CATDIR=$DECDIR;fcat;;5)SHREDDIR=$DECDIR;fshreddir;;6)fmenu;esac
	;;
	3)	clear
		$COLOR 6;echo " [*] Key Menu";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Generate a new Key.
 [2] Export a Key.
 [3] Import a Key.
 [4] Securely delete a Key.
 [5] Back
 >""" MENU 
		case $MENU in 1)fkeygen;;2)fexportkey;;3)fimportkey;;4)SHREDDIR="KEY";fshreddir;;5)fmenu;esac
	;;
	4)	clear
		$COLOR 6;echo " [*] SSH Menu";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Send file
 [2] Send Encrypted message 
 [3] Send Encrypted file
 [4] Send Encrypted key
 [5] Install openssh server
 [6] Start SSH server
 [7] Back
 >""" MENU
		case $MENU in 1)fsshsend;;2)fsshencmsg;;3)fsshencfile;;4)fsshkey;;5)finstallssh;;6)fsshstart;;7)fmenu;esac
	;;
	5)fexit
	esac
	fmenu
}

fkeygen()																#Generate keys
{
	clear
	$COLOR 6;echo " [>] What shall we name your key?";$COLOR 9
	read -e -p " >" KEY
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter a key name, try again...";$COLOR 9
			sleep 2
			fkeygen
	fi
	if [ -d $KEY ]
		then
			$COLOR 1;echo " [*] $KEY already exists, try again...";$COLOR 9
			sleep 2
			fkeygen
		else
			clear
			$COLOR 4;echo " [*] Generating $KEY, Please wait...";$COLOR 9
			mkdir $KEY
			mkdir $KEY/$ENCDIR
			mkdir $KEY/$DECDIR
			mkdir $KEY/$ENCDIR/0_Encrypted_Files
			mkdir $KEY/$DECDIR/0_Decrypted_Files
			sort -R list > $KEY/list
			DIRNUM=10
			
			while [ $DIRNUM -le 99 ]
				do
					mkdir $KEY/$DIRNUM
					DIRNUM=$(( DIRNUM + 1 ))
				done
				
			LNUM=10110		
			DIRNUM=10
			DIRNUMB=11
	
			while [ $LNUM -le 900000 ]
				do 
					echo -n $(head -"$LNUM" $KEY/list | tail -10110) > $KEY/$DIRNUM/$DIRNUM
					sed -e 's/\s/\n/g' $KEY/$DIRNUM/$DIRNUM > $KEY/$DIRNUM/$DIRNUMB	
					shred -zfun 3 $KEY/$DIRNUM/$DIRNUM
					mv $KEY/$DIRNUM/$DIRNUMB $KEY/$DIRNUM/$DIRNUM

					DIRNUM=$(( DIRNUM + 1 ))
					DIRNUMB=$(( DIRNUMB + 1 ))
					LNUM=$(( LNUM + 10110 ))
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
			DISPKEY=1
			sleep 1.5
			fmenu
	fi
}

fencryptmsg()															#Encrypt messages
{
	finputkey
	clear
	$COLOR 6;echo " [>] Please Enter your message:";$COLOR 9
	read -e -p " >" MSG
	MSGLEN=${#MSG}
	MSGCNT=0	
	FILE=tmp1
	MSGNAME=0
	clear
	while [ $MSGNAME = "0" ]
		do
			$COLOR 6;echo " [>] Please Enter a filename for your message:";$COLOR 9
			read -e -p " >" EMSGFILE
			if [ -f $KEY/$ENCDIR/$EMSGFILE ]
				then
					$COLOR 1;echo " [*] $EMSGFILE already exists, Try again...";$COLOR 9
					sleep 1.5
					clear
			elif [ $EMSGFILE -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter a filename, try again...";$COLOR 9
					sleep 1.5
					clear
			else
				MSGNAME=1
			fi
		done
		
	clear
	$COLOR 4;echo " [*] Encrypting "$EMSGFILE", Please wait..";$COLOR 9
	
	while [ $MSGCNT -lt $MSGLEN ]
		do
			CHAR=${MSG:$MSGCNT:1}
			case $CHAR in
				"a")ENCC="11";;"b")ENCC="12";;"c")ENCC="13";;"d")ENCC="14";;"e")ENCC="15";;"f")ENCC="16";;"g")ENCC="17";;"h")ENCC="18";;"i")ENCC="19";;"j")ENCC="20";;"k")ENCC="21";;"l")ENCC="22";;"m")ENCC="23";;"n")ENCC="24";;"o")ENCC="25";;"p")ENCC="26";;"q")ENCC="27";;"r")ENCC="28";;"s")ENCC="29";;"t")ENCC="30";;"u")ENCC="31";;"v")ENCC="32";;"w")ENCC="33";;"x")ENCC="34";;"y")ENCC="35";;"z")ENCC="36";;1)ENCC="37";;2)ENCC="38";;3)ENCC="39";;4)ENCC="40";;5)ENCC="41";;6)ENCC="42";;7)ENCC="43";;8)ENCC="44";;9)ENCC="45";;0)ENCC="10";;" ")ENCC="46";;"A")ENCC="47";;"B")ENCC="48";;"C")ENCC="49";;"D")ENCC="50";;"E")ENCC="51";;"F")ENCC="52";;"G")ENCC="53";;"H")ENCC="54";;"I")ENCC="55";;"J")ENCC="56";;"K")ENCC="57";;"L")ENCC="58";;"M")ENCC="59";;"N")ENCC="60";;"O")ENCC="61";;"P")ENCC="62";;"Q")ENCC="63";;"R")ENCC="64";;"S")ENCC="65";;"T")ENCC="66";;"U")ENCC="67";;"V")ENCC="68";;"W")ENCC="69";;"X")ENCC="70";;"Y")ENCC="71";;"Z")ENCC="72";;".")ENCC="73";;"?")ENCC="74";;",")ENCC="75";;"!")ENCC="76"		
			esac
		
			echo $ENCC >> tmp1
			MSGCNT=$(( MSGCNT +1 ))
		done
		
	while read LINE
		do
			echo $(cat $KEY/$LINE/$LINE | sort -R | head -n 1) >> tmp2
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
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp04  -out $DIRR$KEY/$ENCDIR/$EMSGFILE -k "$PASS5" 2> /dev/null	
	
	shred -zfun 3 tmp* 2> /dev/null
	shred -zfun 3 $DIRR$KEY/$ENCDIR/tmp* 2> /dev/null
	clear
	RLEN=$(wc -l $DIRR$KEY/$ENCDIR/$EMSGFILE)
	DLENT=7
	while [[ "$RLEN" ==  *"/"* ]]
			do
				DLENT=$((DLENT - 1))							
				RLEN=${RLEN:0:$DLENT}
			done
	DLENT=$((DLENT - 1))
	RLEN=${RLEN:0:$DLENT}
	cat $KEY/$ENCDIR/$EMSGFILE
	echo " "
	$COLOR 2;echo " [*] Message is $RLEN lines long and stored at $DIRR$KEY/$ENCDIR/$EMSGFILE";$COLOR 9
	echo " [>] Press c and Enter to copy to clipboard"
	echo " [>] Press s and Enter to send via SSH"
	read -e -p """ [>] Press Enter to return to menu
 >""" SMF
	case $SMF in
		"s")INFILE=$DIRR$KEY/$ENCDIR/$EMSGFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
		"S")INFILE=$DIRR$KEY/$ENCDIR/$EMSGFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
		"c") cat $KEY/$ENCDIR/$EMSGFILE | xclip -sel clip; DISPCOPMSG=1;fmenu;;
		"C") cat $KEY/$ENCDIR/$EMSGFILE | xclip -sel clip; DISPCOPMSG=1;fmenu;;
		"") fmenu
	esac
}

fdecryptmsg()															#Decrypt messages
{
	finputkey
	ISDONE=0
	TMPCHK=0
	
	while [ $ISDONE = "0" ]
		do
			clear
			$COLOR 6;echo " [>] Paste your message from clipboard or read message file from 0_Encrypted_Messages? [P/f]:";$COLOR 9
			read -e -p " >" DODEC
			case $DODEC in
				"P") fdecpaste;;
				"p") fdecpaste;;
				"") fdecpaste;;
				"f") clear; LSS=$(ls $KEY/$ENCDIR)
				if [ $LSS -z ] 2> /dev/null
					then
						$COLOR 1;echo " [*] There are no files in $DIRR$KEY/$ENCDIR";$COLOR 9
						sleep 2
						fmenu

				elif [ $LSS = "0_Encrypted_Files" ] 2> /dev/null
					then
						$COLOR 1;echo " [*] There are no message files in $DIRR$KEY/$ENCDIR";$COLOR 9
						sleep 1.5
						fmenu
				fi
				
				echo $LSS	
				cd $KEY/$ENCDIR
				read -e -p " >" DMSGFILE

				if [ ! -f $DMSGFILE ]
					then
						$COLOR 1;echo " [*] $DMSGFILE is not a valid file, try again...";$COLOR 9
						sleep 2
				else
					ISDONE=1
				fi;;
				"F") clear; LSS=$(ls $KEY/$ENCDIR)
				if [ $LSS -z ] 2> /dev/null
					then
						$COLOR 1;echo " [*] There are no files in $DIRR$KEY/$ENCDIR";$COLOR 9
						sleep 2
						fmenu

				elif [ $LSS = "0_Encrypted_Files" ] 2> /dev/null
					then
						$COLOR 1;echo " [*] There are no message files in $DIRR$KEY/$ENCDIR";$COLOR 9
						sleep 1.5
						fmenu
				fi
				
				echo $LSS	
				cd $KEY/$ENCDIR
				read -e -p " >" DMSGFILE

				if [ ! -f $DMSGFILE ]
					then
						$COLOR 1;echo " [*] $DMSGFILE is not a valid file, try again...";$COLOR 9
						sleep 2
				else
					ISDONE=1
				fi
			esac
		done
		
	clear
	cd "$DIRR"
	$COLOR 4;echo " [*] Decrypting, Please wait..";$COLOR 9
	DATEFILE="$DIRR""$KEY"/"$ENCDIR"/"$DATER"
	case $DODEC in
		"P") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DMSGFILE="$DATER";;
		"p") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DMSGFILE="$DATER";;
		"") mv "$DATEFILE" "$DIRR""$KEY"/"$ENCDIR"/"tmp01" ; DMSGFILE="$DATER";;
		"f") cat $KEY/$ENCDIR/$DMSGFILE  > $KEY/$ENCDIR/tmp01;;
		"F") cat $KEY/$ENCDIR/$DMSGFILE  > $KEY/$ENCDIR/tmp01
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
	shred -zfun 3 $DIRR$KEY/$ENCDIR/tmp* 2> /dev/null
	
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
	echo "${DEKD%?}" > $KEY/$DECDIR/$DMSGFILE
	shred -zfun 3 tmp* 2> /dev/null
	clear
	if [ $( cat $KEY/$DECDIR/$DMSGFILE ) -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] ERROR: $DMSGFILE not decrypted, wrong key or not an encrypted message.";$COLOR 9;sleep 1.5;fmenu
		else
			cat $KEY/$DECDIR/$DMSGFILE
			echo
			$COLOR 2;echo " [*] Message saved to $DIRR$KEY/$DECDIR/$DMSGFILE";$COLOR 9
			echo
			echo " [>] Press d and Enter to securely delete $DMSGFILE"
			echo " [>] Press Enter to return to menu"
			read -e -p " >" SMF
			clear
			case $SMF in
				"")fmenu;;
				"d")$COLOR 4;echo " [*] Shredding $DMSGFILE...";$COLOR 9;shred -zfun 3 $DIRR$KEY/$DECDIR/$DMSGFILE;DISPSHRED=1;sleep 1.5;fmenu;;
				"D")$COLOR 4;echo " [*] Shredding $DMSGFILE...";$COLOR 9;shred -zfun 3 $DIRR$KEY/$DECDIR/$DMSGFILE;DISPSHRED=1;sleep 1.5;fmenu
			esac
	fi
	
}

fdecpaste()																#Paste messages into fdecryptmsg from the clipboard																
{
	DATER=$( date +%Y_%d_%m_%H_%M_%S )
	DATEFILE="$DIRR""$KEY"/"$ENCDIR"/"$DATER"
	xclip -sel clip -o > $DATEFILE
	ISDONE=1
}

fencryptfile()															#Encrypt files
{
	finputkey
	clear
	$COLOR 6;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
	read -e -p " >" INFILE
	
	if [ $INFILE -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter the path to the file e.g. $HOME/file, try again...";$COLOR 9
			sleep 1.5
			fencryptfile
	fi
	
	if [ ! -f $INFILE ]
		then
			$COLOR 1;echo " [*] There does not appear to be any file at $INFILE, try again...";$COLOR 9
			sleep 2
			fencryptfile
	fi
	clear
	PASS=$(cat $KEY/meta/meta)
	EMSGFILE=$(basename $INFILE)
	$COLOR 4;echo " [*] Encrypting "$ENCCMSF", Please wait..";$COLOR 9
	
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
					3)PASS3=$LINE;;
					4)PASS4=$LINE;;
					5)PASS5=$LINE
			esac
		LNUM=$(( LNUM + 1 ))
		done <$FILE

	openssl enc -aes-256-cbc -a -salt -in $INFILE -out $DIRR$KEY/$ENCDIR/tmp01 -k "$PASS1" 2> /dev/null	
	openssl enc -camellia-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS2" 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp02  -out $DIRR$KEY/$ENCDIR/tmp03 -k "$PASS3" 2> /dev/null
	openssl enc -camellia-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp03  -out $DIRR$KEY/$ENCDIR/tmp04 -k "$PASS4" 2> /dev/null
	openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY/$ENCDIR/tmp04 -out $DIRR$KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE -k "$PASS5" 2> /dev/null

	shred -zfun 3 $DIRR$KEY/$ENCDIR/tmp* 2> /dev/null
	clear
	$COLOR 2;echo " [*] File saved to $DIRR$KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE";$COLOR 9
	echo
	echo " [>] Press c and Enter to copy encrypted file to the clipboard"
	echo " [>] Press s and Enter to send via SSH"
	read -e -p """ [>] Press Enter to return to menu
 >""" DOFILE
	echo
	case $DOFILE in
		"s")INFILE=$DIRR$KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
		"S")INFILE=$DIRR$KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
		"c")cat $KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE | xclip -sel clip;DISPCOP=1;fmenu;;
		"C")cat $KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE | xclip -sel clip;DISPCOP=1;fmenu;;
		"")fmenu
	esac
}

fdecryptfile()															#Decrypt files
{
	finputkey
	clear
	$COLOR 6;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
	read -e -p " >" INFILE
	
	if [ $INFILE -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter the location of the file e.g. $HOME/file, try again...";$COLOR 9
			sleep 1.5
			fencryptfile
	fi
	
	if [ ! -f $INFILE ]
		then
			$COLOR 1;echo " [*] There does not appear to be any file at $INFILE, try again...";$COLOR 9
			sleep 2
			fdecryptfile
	fi
	DFILE=$(basename $INFILE)
	PASS=$(cat $KEY/meta/meta)
	clear
	$COLOR 4;echo " [*] Decrypting "$DFILE", Please wait..";$COLOR 9
	
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
					3)PASS3=$LINE;;
					4)PASS4=$LINE;;
					5)PASS5=$LINE
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <$FILE
		
	openssl enc -aes-256-cbc -d -a -salt -in $INFILE -out $DIRR$KEY/$ENCDIR/tmp01 -k "$PASS5" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp01  -out $DIRR$KEY/$ENCDIR/tmp02 -k "$PASS4" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp02  -out $DIRR$KEY/$ENCDIR/tmp03 -k "$PASS3" 2> /dev/null
	openssl enc -camellia-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp03  -out $DIRR$KEY/$ENCDIR/tmp04 -k "$PASS2" 2> /dev/null
	openssl enc -aes-256-cbc -d -a -salt -in $DIRR$KEY/$ENCDIR/tmp04  -out $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DFILE -k "$PASS1" 2> /dev/null	

	shred -zfun 3 $KEY/$ENCDIR/tmp0* 2> /dev/null
	clear
	if [ $( cat $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DFILE 2> /dev/null ) -z ] 
		then
			$COLOR 1;echo " [*] ERROR: $DFILE not decrypted, wrong key or not an encrypted file.";$COLOR 9;sleep 1.5;fmenu
		else
			$COLOR 2;echo " [*] File saved to $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DFILE";$COLOR 9
			echo
			STRT=" [*] "
			CHKFILE=$( file $KEY/$DECDIR/0_Decrypted_Files/$DFILE )
			$COLOR 5;echo $STRT$CHKFILE;$COLOR 9
			echo
			read -e -p " [>] Press Enter to return to menu"
			fmenu
	fi
}

fcat()																	#Read messages to the screen
{
	finputkey
	clear
	LSS=$(ls $KEY/$CATDIR)
	if [ $LSS -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] There are no message files in $DIRR$KEY/$CATDIR";$COLOR 9
			sleep 1.5
			fmenu
	elif [ $LSS = "0_Decrypted_Files" ] 2> /dev/null
		then
			$COLOR 1;echo " [*] There are no message files in $DIRR$KEY/$CATDIR";$COLOR 9
			sleep 1.5
			fmenu
	elif [ $LSS = "0_Encrypted_Files" ] 2> /dev/null
		then
			$COLOR 1;echo " [*] There are no message files in $DIRR$KEY/$CATDIR";$COLOR 9
			sleep 1.5
			fmenu
	fi
				
	$COLOR 6;echo " [>] Which file do you want to read?";$COLOR 9
	cd $KEY/$CATDIR; ls
	read -e -p " >" CATFILE
		
	if [ -f $CATFILE ]
		then
			clear
			cat $CATFILE
			echo
			if [ $CATDIR = $DECDIR ]
				then
					echo " [>] Press d and Enter to securely delete $CATFILE"
					echo " [>] Press Enter to return to menu"
					read -e -p " >" SMF
					clear
					case $SMF in
						"")fmenu;;
						"d")$COLOR 4;echo " [*] Shredding $CATFILE...";$COLOR 9;DMSGFILE=$CATFILE;DISPSHRED=1;shred -zfun 3 $DIRR$KEY/$CATDIR/$CATFILE;sleep 1.5;fmenu;;
						"D")$COLOR 4;echo " [*] Shredding $CATFILE...";$COLOR 9;DMSGFILE=$CATFILE;DISPSHRED=1;shred -zfun 3 $DIRR$KEY/$CATDIR/$CATFILE;sleep 1.5;fmenu
					esac
				else
					echo " [>] Press c and Enter to copy to clipboard"
					echo " [>] Press s and Enter to send via SSH"
					read -e -p """ [>] Press Enter to return to menu
 >""" SMF
					case $SMF in
						"s")INFILE=$DIRR$KEY/$CATDIR/$CATFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
						"S")INFILE=$DIRR$KEY/$CATDIR/$CATFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
						"c") cat $CATFILE | xclip -sel clip; DISPCOPMSG=1;fmenu;;
						"C") cat $CATFILE | xclip -sel clip; DISPCOPMSG=1;fmenu;;
						"") fmenu
					esac
					fmenu
			fi
		else
			$COLOR 1;echo " [*] There does not appear to be any file at $CATFILE, try again...";$COLOR 9
			sleep 2
			fcat
	fi
}

fopendir()																#Open message folder
{
	finputkey
	
	nautilus $KEY/$OPENDIR 2> /dev/null
	
	fmenu
}

fimportkey()															#Import keys
{
	clear
	$COLOR 6;echo " [>] Please Enter the location of the key file eg. $HOME/Desktop/key";$COLOR 9
	read -e -p " >" KEYLOC
	if [ $KEYLOC -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter the path to key file eg. $HOME/Desktop/key, try again...";$COLOR 9
			sleep 2
			fimportkey
		else
			KEYLOC=$( echo $KEYLOC | tr -d \ )
			echo $KEYLOC
			KEYFILE=$(basename $KEYLOC)
	fi
	if [ -f $KEYLOC ]
		then
			clear
			DONPS=0
			while [ $DONPS != "1" ]
				do
					clear
					$COLOR 6;echo " [>] Please Enter the password";$COLOR 9
					read -s RPASS
					$COLOR 6;echo " [>] Enter one more time";$COLOR 9
					read -s SPASS
					if [ $RPASS != $SPASS ]
						then
							$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
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
			
			clear
			$COLOR 4;echo " [*] Decrypting "$KEY", Please wait...";$COLOR 9
	
			openssl enc -aes-256-cbc -d -a -salt -in $KEYLOC -out tmp01 -k "$LPASS" 2> /dev/null
			openssl enc -camellia-256-cbc -d -a -salt -in tmp01 -out tmp02 -k "$MPASS" 2> /dev/null
			openssl enc -aes-256-cbc -d -a -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
			openssl enc -camellia-256-cbc -d -a -salt -in tmp03 -out tmp04 -k "$NPASS" 2> /dev/null
			openssl enc -aes-256-cbc -d -a -salt -in tmp04 -out $DIRR$KEYFILE.zip -k "$SPASS" 2> /dev/null
			
			shred -zfun 3 tmp0* 2> /dev/null
			
			if [ $( cat tmp04 2> /dev/null ) -z ] 2> /dev/null
				then
					shred -zfun 3 $KEYFILE.zip
					$COLOR 1;echo " [*] ERROR: $KEYFILE not imported, wrong password or not an encrypted key.";$COLOR 9;sleep 1.5;fmenu
				else
					unzip -P $SPASS $KEYFILE.zip -d .  2> /dev/null
					chown -hR $USER $KEYFILE
					clear
					$COLOR 2;echo " [*] $KEYFILE imported.";$COLOR 9
					shred -zfun 3 $KEYFILE.zip
					sleep 2
					fmenu
			fi
		else
			$COLOR 1;echo " [*] There does not appear to be any file at $KEYFILE, try again...";$COLOR 9
			sleep 2
			fimportkey
	fi
}

fexportkey()															#Export keys
{
	finputkey
	
	if [ ! -d $KEY/0_Exported_Keys ]
		then
			mkdir $KEY/0_Exported_Keys
	fi			
			
	WHSAV="$KEY/0_Exported_Keys"
	clear
	PASSDON=0
	while [ $PASSDON != "1" ]
		do
			clear
			$COLOR 6;echo " [>] Please Enter your password";$COLOR 9
			read -s  TPASS
			$COLOR 6;echo " [>] Enter once more"  ;$COLOR 9
			read -s ZPASS
			if [ $TPASS != $ZPASS ]
				then
					$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
					sleep 2
				else
					PASSDON=1
					NPASS=$(echo $ZPASS | base64)
					NPASS=$(echo $NPASS$NPASS | md5sum)
					GPASS=$(echo NPASS | md5sum)
					LPASS=$NPASS$GPASS$ZPASS$GPASS
					FPASS=$ZPASS$GPASS$NPASS
					MPASS=$FPASS$NPASS$ZPASS
							
					mv "$DIRR""$KEY"/$DECDIR $DIRR$DECDIR
					mv "$DIRR""$KEY"/$ENCDIR $DIRR$ENCDIR
							
					if [ -f  $WHSAV/$KEY ] 2> /dev/null
						then
							shred -zfun 3 $WHSAV/$KEY
					fi
					zip -reP $ZPASS $KEY.zip $KEY
					clear
					$COLOR 4;echo " [*] Encrypting "$KEY", Please wait...";$COLOR 9
					openssl enc -aes-256-cbc -a -salt -in $DIRR$KEY.zip -out "$WHSAV"/tmp01 -k "$ZPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -a -salt -in "$WHSAV"/tmp01 -out "$WHSAV"/tmp02 -k "$NPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in "$WHSAV"/tmp02 -out "$WHSAV"/tmp03 -k "$GPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -a -salt -in "$WHSAV"/tmp03 -out "$WHSAV"/tmp04 -k "$MPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in "$WHSAV"/tmp04 -out $WHSAV/$KEY -k "$LPASS" 2> /dev/null
							
					mv $DIRR$DECDIR "$DIRR""$KEY"/$DECDIR 
					mv $DIRR$ENCDIR "$DIRR""$KEY"/$ENCDIR
					
			fi
		done

	shred -zfun 3 "$WHSAV"/tmp0*
	shred -zfun 3 $KEY.zip
	clear
	$COLOR 2;echo " [*] $KEY exported to $DIRR$WHSAV/$KEY"
	SIZE=$( du -h $DIRR$WHSAV/$KEY )
	echo ${SIZE:0:4} " in size";$COLOR 9
	echo " [>] Press s and Enter to send via SSH"
	read -e -p """ [>] Press Enter to return to menu
 >""" DOFILE
	echo
	case $DOFILE in
		"s")INFILE=$DIRR$WHSAV/$KEY;SSHSEND=1;cd "$DIRR";fsshsend;;
		"S")INFILE=$DIRR$WHSAV/$KEY;SSHSEND=1;cd "$DIRR";fsshsend;;
		"")fmenu
	esac
	fmenu
}

finstallssh()															#Install OpenSSH server
{
	clear
	if [ $(whoami) = 'root' ] 2> /dev/null
		then
			apt-get install openssh-server
		else
			sudo apt-get install openssh-server
	fi
}

fsshstart()																#Start OpenSSH server
{
	echo
	$COLOR 4
	if [ $(whoami) = 'root' ] 2> /dev/null
		then
			service ssh start
		else
			sudo service ssh start
	fi;$COLOR 9
	sleep 1.5
	fmenu
}

fsshsend()																#Send files via SSH (SCP)
{
	clear
	cd "$DIRR"
	if [ $SSHSEND = "0" ] 2> /dev/null
		then
			$COLOR 6;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
			read -e -p " >" INFILE
	fi
	SSHSEND=0
	if [ $INFILE -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter the path to the file, try again...";$COLOR 9
			sleep 1.5
			fsshsend
	fi
	
	if [ ! -f $INFILE ]
		then
			$COLOR 1;echo " [*] There does not appear to be any file at $DIRR$INFILE, try again...";$COLOR 9
			sleep 2
			fsshsend
	fi
	BASEFILE=$(basename $INFILE)
	INUSER=0
	while [ $INUSER != "1" ]
		do
			clear
			$COLOR 6;echo " [>] Please Enter the user you are logging in to";$COLOR 9
			read -e -p " >" RUSER
	
			if [ $RUSER -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter the user you are logging in to, try again...";$COLOR 9
					sleep 1.5
				else
					INUSER=1
			fi
		done
	IPDONE=0
	while [ $IPDONE != "1" ]
		do
			clear
			$COLOR 6;echo " [>] Please Enter the IP address you are connecting to";$COLOR 9
			read -e -p " >" IPSEND
			if [ $IPSEND -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter the IP address you are connecting to, try again...";$COLOR 9
					sleep 1.5
				else
					IPDONE=1
			fi
		done
		
	clear
	$COLOR 6;echo " [>] Is there a custom port number? [N/y]";$COLOR 9
	read -e -p " >" SSHPORTDO
	
	case $SSHPORTDO in
		"")SSHPORT=22;;
		"n")SSHPORT=22;;
		"N")SSHPORT=22;;
		"y")clear
			$COLOR 6;echo " [>] Please Enter the port number";$COLOR 9
			read -e -p " >" SSHPORT
			if [ $SSHPORT -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter the port number you are connecting to, try again...";$COLOR 9
					sleep 1.5
					fsshsend
			fi;;
		"Y")clear
			$COLOR 6;echo " [>] Please Enter the port number";$COLOR 9
			read -e -p " >" SSHPORT
			if [ $SSHPORT -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter the port number you are connecting to, try again...";$COLOR 9
					sleep 1.5
					fsshsend
			fi
	esac
	clear
	$COLOR 4;echo " [*] Sending $BASEFILE to "$RUSER"@"$IPSEND" on port number "$SSHPORT"";$COLOR 9
	if [ $RUSER != 'root' ] 2> /dev/null
		then
			SSEND="scp -P $SSHPORT $INFILE "$RUSER"@"$IPSEND":/home/$RUSER/Desktop/nypt/SSH_Recieved_Files/$BASEFILE"
		else
			SSEND="scp -P $SSHPORT $INFILE "$RUSER"@"$IPSEND":/root/Desktop/nypt/SSH_Recieved_Files/$BASEFILE"
	fi
	$SSEND
	echo
	DISPSSH=1
	fmenu
}

fsshencmsg()															#Send encrypted message into fsshsend
{
	finputkey
	clear
	$COLOR 6;echo " [>] Which message do you want to send?";$COLOR 9
	cd $KEY/$ENCDIR;ls
	read -e -p " >" ENCCAT
	if [ -f $ENCCAT ]
		then
			INFILE=$KEY/$ENCDIR/$ENCCAT
			SSHSEND=1
			cd "$DIRR"
			fsshsend
		else
			clear
			$COLOR 1;echo " [*] There does not appear to be any file at $ENCCAT, try again...";$COLOR 9
			sleep 2
			fsshencmsg
	fi
}

 fsshkey()																#Send encrypted keys into fsshsend
{
	finputkey
	clear
	INFILE=$KEY/0_Exported_Keys/$KEY
	SSHSEND=1
	cd "$DIRR"
	fsshsend
}

fsshencfile()															#Send encrypted file into fsshsend
{
	finputkey
	clear
	$COLOR 6;echo " [>] Which Encrypted file do you want to send?";$COLOR 9
	cd $KEY/$ENCDIR/0_Encrypted_Files;ls
	read -e -p " >" ENCCAT
	if [ -f $ENCCAT ]
		then
			INFILE=$KEY/$ENCDIR/0_Encrypted_Files/$ENCCAT
			SSHSEND=1
			cd "$DIRR"
			fsshsend
		else
			clear
			$COLOR 1;echo " [*] There does not appear to be any file at $ENCCAT, try again...";$COLOR 9
			sleep 2
			fsshencfile
	fi
}

fshred()																#Shred
{
	$COLOR 4
	if [ $SHREDDIR = $DECDIR ]
		then
			echo " [*] Securely deleting "$KEY"'s decrypted messages, Please wait.."
	elif [ $SHREDDIR = $ENCDIR ]
		then
			echo " [*] Securely deleting "$KEY"'s encrypted messages, Please wait.."
	elif [ $SHREDDIR = $KEY ]
		then
			echo " [*] Securely deleting $KEY, Please wait.."
	fi
	if [ $SHREDDIR = $KEY ]
		then
			find $KEY -type f -exec shred -zfun 3 {} \;
			rm -rf $KEY
			$COLOR 2;echo " [*] $KEY and all its messages securely deleted.";$COLOR 9
		else
			find $KEY/$SHREDDIR -type f -exec shred -zfun 3 {} \;
			$COLOR 2
			if [ $SHREDDIR = $DECDIR ]
				then
					echo " [*] "$KEY"'s decrypted messages securely deleted."
			elif [ $SHREDDIR = $ENCDIR ]
				then
					echo " [*] "$KEY"'s encrypted messages securely deleted."
			fi;$COLOR 9
	fi	
	sleep 2
}

fshreddir()																#Shred messages and keys
{
	finputkey	
	clear
	$COLOR 1
	if [ $SHREDDIR = $DECDIR ]
		then
			echo " [>] Warning, this will securely delete all of "$KEY"'s decrypted messages, are you sure? [Y/n]"
	elif [ $SHREDDIR = $ENCDIR ]
		then
			echo " [>] Warning, this will securely delete all of "$KEY"'s encrypted messages, are you sure? [Y/n]"
	elif [ $SHREDDIR = "KEY" ]
		then
			echo " [>] Warning, this will securely delete the key $KEY and all of its messages, are you sure? [Y/n]"
			SHREDDIR=$KEY
	fi;$COLOR 9
	read -e -p " >" DODEL
	clear
	
	case $DODEL in
		"Y")	fshred;;
		"y")	fshred;;
		"")		fshred
	esac

	fmenu
}

flistgen()																#Generate full list of 6 digit numbers to use for random number cryptography
{
	cd $DIRR
	clear
	STARTNUM=100000

	while [ $STARTNUM -le 999999 ]
		do
			if [ $(( $STARTNUM % 10000 )) -eq 0 ]
				then
					DONENUM=$((STARTNUM - 100000))
					PERCENT=$((DONENUM / 9000))
					clear
					$COLOR 2;echo " [*] Setting up Nypt for first use, Please wait.."
					$COLOR 4;echo " [*] Done "$PERCENT"%   "$DONENUM"/900000 lines";$COLOR 9
					CHECKMSG=0
			fi
			echo -n $STARTNUM >> list
			echo \ >> list
			STARTNUM=$(( STARTNUM + 1 ))
		done
	clear
	$COLOR 2;echo " [*] Setup complete!";$COLOR 9
	sleep 1.5
}

finputkey()
{
	clear
	$COLOR 6;echo " [>] Which key?";$COLOR 9
	ls 
	read -e -p " >" KEY
	
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	fi
	if [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter a key, try again...";$COLOR 9
			sleep 1.5
			finputkey
	fi
	if [ ! -d $KEY ]
		then
			$COLOR 1;echo " [*] $KEY is not a valid key, try again...";$COLOR 9
			sleep 1.5
			finputkey
	fi
}
 
fexit()																	#Delete left over tempory files when exitting
{   $COLOR 9
	cd $DIRR
	shred -zfun 3 tmp* 2> /dev/null
	echo
	exit
}
	
	fstart
