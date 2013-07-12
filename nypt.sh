#!/bin/bash

## Nypt 1.37 Copyright 2013, Rids43 (rids@tormail.org)
#
## Crypt files, messages and keys using a layer of custom random number  
## encryption and five layers of custom openssl encryption.
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


fstart()																																#Startup function
{
	COLOR="tput setab"
	DIRR=$HOME/Desktop/nypt/keys/
	if [ ! -d $DIRR ]
		then
			mkdir $HOME/Desktop/nypt/ 2> /dev/null
			mkdir $HOME/Desktop/nypt/Exported_Keys 2> /dev/null
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
	
	if [ $DEPCHK = "1" ] 2> /dev/null																			#Dependancy check
		then		
			LIST="""shred
gedit
sha512sum
ssh
scp
xclip
openssl
zip
unzip
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

fmenu()																																	#Main menu
{
	cd $DIRR
	clear
	SSHSEND=0
	fdisplaymenu
	$COLOR 5;echo " [*] Nypt 1.37 [*] ";$COLOR 9															
	read -e -p """      ~~~~~~~~
 [1] Encryption
 [2] Decryption
 [3] Keys
 [4] SSH
 [5] Quit
 >""" MENU
  
		case $MENU in
	1)	clear
		$COLOR 5;echo " [*] Encryption Menu [*] ";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Encrypt a message.
 [2] Encrypt a file.
 [3] Browse Encryption folder.
 [4] Read Encrypted messages.
 [5] Shred Encrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fencryptmsg;;2)fencryptfile;;3)OPENDIR=$ENCDIR;fopendir;;4)CATDIR=$ENCDIR;fcat;;5)SHREDDIR=$ENCDIR;fshreddir;;6)fmenu;esac
	;;
	2)	clear
		$COLOR 5;echo " [*] Decryption Menu [*] ";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Decrypt a message.
 [2] Decrypt a file.
 [3] Browse Decryption folder.
 [4] Read Decrypted messages.
 [5] Shred Decrypted messages.
 [6] Back
 >""" MENU
		case $MENU in 1)fdecryptmsg;;2)fdecryptfile;;3)OPENDIR=$DECDIR;fopendir;;4)CATDIR=$DECDIR;fcat;;5)SHREDDIR=$DECDIR;fshreddir;;6)fmenu;esac
	;;
	3)	clear
		$COLOR 5;echo " [*] Key Menu [*] ";$COLOR 9
		read -e -p """      ~~~~~~~~
 [1] Generate a new Key.
 [2] Export a Key.
 [3] Import a Key.
 [4] Shred a Key.
 [5] Edit Key config
 [6] Lock/Unlock a Key
 [7] Back
 >""" MENU 
		case $MENU in 1)fkeygen;;2)fexportkey;;3)fimportkey;;4)SHREDDIR="KEY";fshreddir;;5)finputkey;flockcheck;gedit $KEY/config 2> /dev/null;;6)fkeylock;;7)fmenu;esac
	;;
	4)	clear
		$COLOR 5;echo " [*] SSH Menu [*] ";$COLOR 9
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

fkeygen()																																#Generate keys
{
	clear
	$COLOR 5;echo " [>] What shall we name your key?";$COLOR 9
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
																																				##Random number key
			sort -R list > $KEY/list																					#List of 6-digit numbers is sorted randomly
			DIRNUM=10
																																				#Create directories for each character
			while [ $DIRNUM -le 98 ]																					###Custom###
				do
					mkdir $KEY/$DIRNUM
					DIRNUM=$(( DIRNUM + 1 ))
				done
																																				#Sorted list is cut into character files of 10110 lines each
			LNUM=10110																												###Custom###
			DIRNUM=10
			DIRNUMB=11
																		
			while [ $LNUM -le 900000 ]																				###Custom###
				do 
					echo -n $(head -"$LNUM" $KEY/list | tail -10110) > $KEY/$DIRNUM/$DIRNUM
					sed -e 's/\s/\n/g' $KEY/$DIRNUM/$DIRNUM > $KEY/$DIRNUM/$DIRNUMB	
					shred -zfun 3 $KEY/$DIRNUM/$DIRNUM
					mv $KEY/$DIRNUM/$DIRNUMB $KEY/$DIRNUM/$DIRNUM

					DIRNUM=$(( DIRNUM + 1 ))
					DIRNUMB=$(( DIRNUMB + 1 ))
					LNUM=$(( LNUM + 10110 ))							
				done
																																				##Openssl keys
																																				#Random password lengths are generated from urandom
			RANDLENTH=$(strings /dev/urandom | grep -o '[1-9]' | head -n 45 | tr -d '\n'; echo)
			RAND1=${RANDLENTH:0:3}																						###Custom###
			RAND2=${RANDLENTH:3:3}
			RAND3=${RANDLENTH:6:3}
			RAND4=${RANDLENTH:9:3}
			RAND5=${RANDLENTH:12:3}
			RANDL1=${RANDLENTH:15:3}	
			RANDL2=${RANDLENTH:18:3}
			RANDL3=${RANDLENTH:21:3}
			RANDL4=${RANDLENTH:24:3}
			RANDL5=${RANDLENTH:27:3}
			RANDA1=${RANDLENTH:30:3}	
			RANDA2=${RANDLENTH:33:3}
			RANDA3=${RANDLENTH:36:3}
			RANDA4=${RANDLENTH:39:3}									
			RANDA5=${RANDLENTH:42:3}

																																				#Make passwords randomly longer
			if [ $RAND1 -le $RANDL1 ]																					###Custom###
				then
					RAND1=$(( RAND1 + RANDA1 ))
			fi
			if [ $RAND2 -le $RANDL2 ]
				then
					RAND2=$(( RAND2 + RANDA2 ))
			fi
			if [ $RAND3 -le $RANDL3 ]
				then
					RAND3=$(( RAND3 + RANDA3 ))
			fi
			if [ $RAND4 -le $RANDL4 ]
				then
					RAND4=$(( RAND4 + RANDA4 ))
			fi
			if [ $RAND5 -le $RANDL5 ]
				then
					RAND5=$(( RAND5 + RANDA5 ))
			fi
			
			mkdir $KEY/meta/
																																				#Passwords for openssl layers are generated from urandom
																																				###Custom###
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND1 | tr -d '\n'; echo) > $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND2 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND3 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND4 | tr -d '\n'; echo) >> $KEY/meta/meta
			echo $(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $RAND5 | tr -d '\n'; echo) >> $KEY/meta/meta

			shred -zfun 3 $KEY/list																						#Write config file
			
			PADDINGL=$(strings /dev/urandom | grep -o '[0-9]' | head -n 4 | tr -d '\n'; echo)
			PADDING1=${PADDINGL:0:2}
			PADDING2=${PADDINGL:2:2}
			while [ $PADDING1 = "00" ]
				do
					PADDING1=$(strings /dev/urandom | grep -o '[0-9]' | head -n 2 | tr -d '\n'; echo)
				done
			if [ ${PADDING1:0:1} = "0" ] 2> /dev/null
				then
					PADDING1=${PADDING1:1:1}
			fi

			while [ $PADDING2 = "00" ]
				do
					PADDING2=$(strings /dev/urandom | grep -o '[0-9]' | head -n 2 | tr -d '\n'; echo)
				done
			if [ ${PADDING2:0:1} = "0" ] 2> /dev/null
				then
					PADDING2=${PADDING2:1:1}
			fi
			PLACEMENT=$(strings /dev/urandom | grep -o '[2-9]' | head -n 1 | tr -d '\n'; echo)
			CIPHERL=$(strings /dev/urandom | grep -o '[1-8]' | head -n 5 | tr -d '\n'; echo)
			CIPHER1=${CIPHERL:0:1}
			CIPHER2=${CIPHERL:1:1}
			CIPHER3=${CIPHERL:2:1}
			CIPHER4=${CIPHERL:3:1}
			CIPHER5=${CIPHERL:4:1}
			case $CIPHER1 in
				1)CIPHER1="aes-256-cbc";;
				2)CIPHER1="aes-256-ecb";;
				3)CIPHER1="camellia-256-cbc";;
				4)CIPHER1="camellia-256-ecb";;
				5)CIPHER1="bf-cbc";;
				6)CIPHER1="cast5-cbc";;
				7)CIPHER1="aes-192-cbc";;
				8)CIPHER1="desx"
			esac
			case $CIPHER2 in
				1)CIPHER2="aes-256-cbc";;
				2)CIPHER2="aes-256-ecb";;
				3)CIPHER2="camellia-256-cbc";;
				4)CIPHER2="camellia-256-ecb";;
				5)CIPHER2="bf-cbc";;
				6)CIPHER2="cast5-cbc";;
				7)CIPHER2="aes-192-cbc";;
				8)CIPHER2="desx"
			esac
			case $CIPHER3 in
				1)CIPHER3="aes-256-cbc";;
				2)CIPHER3="aes-256-ecb";;
				3)CIPHER3="camellia-256-cbc";;
				4)CIPHER3="camellia-256-ecb";;
				5)CIPHER3="bf-cbc";;
				6)CIPHER3="cast5-cbc";;
				7)CIPHER3="aes-192-cbc";;
				8)CIPHER3="desx"
			esac
			case $CIPHER4 in
				1)CIPHER4="aes-256-cbc";;
				2)CIPHER4="aes-256-ecb";;
				3)CIPHER4="camellia-256-cbc";;
				4)CIPHER4="camellia-256-ecb";;
				5)CIPHER4="bf-cbc";;
				6)CIPHER4="cast5-cbc";;
				7)CIPHER4="aes-192-cbc";;
				8)CIPHER4="desx"
			esac
			case $CIPHER5 in
				1)CIPHER5="aes-256-cbc";;
				2)CIPHER5="aes-256-ecb";;
				3)CIPHER5="camellia-256-cbc";;
				4)CIPHER5="camellia-256-ecb";;
				5)CIPHER5="bf-cbc";;
				6)CIPHER5="cast5-cbc";;
				7)CIPHER5="aes-192-cbc";;
				8)CIPHER5="desx"
			esac
			
			echo """#Cipher commands to be used with openssl  layers: CIPHER(1-5)							
#aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
#aes-256-cbc       aes-256-ecb       base64            bf                
#bf-cbc            bf-cfb            bf-ecb            bf-ofb            
#camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  camellia-192-ecb  
#camellia-256-cbc  camellia-256-ecb  cast              cast-cbc          
#cast5-cbc         cast5-cfb         cast5-ecb         cast5-ofb         
#des               des-cbc           des-cfb           des-ecb           
#des-ede           des-ede-cbc       des-ede-cfb       des-ede-ofb       
#des-ede3          des-ede3-cbc      des-ede3-cfb      des-ede3-ofb 
#des-ofb           des3              desx              rc2               
#rc2-40-cbc        rc2-64-cbc        rc2-cbc           rc2-cfb           
#rc2-ecb           rc2-ofb           rc4               rc4-40            
#seed              seed-cbc          seed-cfb          seed-ecb          
#seed-ofb          zlib  

#CIPHER1 Variable
$CIPHER1

#CIPHER2 Variable
$CIPHER2

#CIPHER3 Variable 
$CIPHER3

#CIPHER4 Variable
$CIPHER4

#CIPHER5 Variable 
$CIPHER5

#Enable Random Number Layer cryptography for messages
1

#Enable Dummmy characters
1

#Dummy character placement (every n characters)
$PLACEMENT

#Enable Random Padding
1

#Padding at start of message
$PADDING1

#Padding at end of message
$PADDING2

#Enable Random Padding length
1""" > $KEY/config
			clear
			$COLOR 5;echo " [*] Do you want to lock $KEY? [Y/n]";$COLOR 9;read -p " >" LOCK
			case $LOCK in
				"")DOLOCK=1;fkeylock;;
				"Y")DOLOCK=1;fkeylock;;
				"y")DOLOCK=1;fkeylock;;
				"n")DISPKEY=1;fmenu;;
				"N")DISPKEY=1;fmenu
			esac
	fi
}

fencryptmsg()																														#Encrypt messages
{
	finputkey
	flockcheck
	clear
	$COLOR 5;echo " [>] Please Enter your message or press p and Enter to paste from clipboard";$COLOR 9
	read -e -p " >" MSG
	if [ $MSG = "p" ] 2> /dev/null
		then
			MSG=$(xclip -sel clip -o)
	fi
	MSGLEN=${#MSG}
	MSGCNT=0	
	FILE=tmp1
	MSGNAME=0
	clear
	while [ $MSGNAME = "0" ]
		do
			$COLOR 5;echo " [>] Please Enter a filename for your message:";$COLOR 9
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
	if [ $ENABLERAND = "1" ] 2> /dev/null
		then																																##Random number layer##
			while [ $MSGCNT -lt $MSGLEN ]																			#Each character is assigned a number
				do																															###Custom###
					CHAR=${MSG:$MSGCNT:1}
					case $CHAR in
						"a")ENCC="11";;"b")ENCC="12";;"c")ENCC="13";;"d")ENCC="14";;"e")ENCC="15";;"f")ENCC="16";;"g")ENCC="17";;"h")ENCC="18";;"i")ENCC="19";;"j")ENCC="20";;"k")ENCC="21";;"l")ENCC="22";;"m")ENCC="23";;"n")ENCC="24";;"o")ENCC="25";;"p")ENCC="26";;"q")ENCC="27";;"r")ENCC="28";;"s")ENCC="29";;"t")ENCC="30";;"u")ENCC="31";;"v")ENCC="32";;"w")ENCC="33";;"x")ENCC="34";;"y")ENCC="35";;"z")ENCC="36";;1)ENCC="37";;2)ENCC="38";;3)ENCC="39";;4)ENCC="40";;5)ENCC="41";;6)ENCC="42";;7)ENCC="43";;8)ENCC="44";;9)ENCC="45";;0)ENCC="10";;" ")ENCC="46";;"A")ENCC="47";;"B")ENCC="48";;"C")ENCC="49";;"D")ENCC="50";;"E")ENCC="51";;"F")ENCC="52";;"G")ENCC="53";;"H")ENCC="54";;"I")ENCC="55";;"J")ENCC="56";;"K")ENCC="57";;"L")ENCC="58";;"M")ENCC="59";;"N")ENCC="60";;"O")ENCC="61";;"P")ENCC="62";;"Q")ENCC="63";;"R")ENCC="64";;"S")ENCC="65";;"T")ENCC="66";;"U")ENCC="67";;"V")ENCC="68";;"W")ENCC="69";;"X")ENCC="70";;"Y")ENCC="71";;"Z")ENCC="72";;".")ENCC="73";;"?")ENCC="74";;",")ENCC="75";;"!")ENCC="76";;";")ENCC="77";;"$")ENCC="78";;"£")ENCC="79";;"&")ENCC="80";;'(')ENNC="81";;')')ENC="82";;"-")ENC="83";;"+")ENCC="84";;"@")ENCC="85";;":")ENCC="86";;'"')ENCC="87";;"#")ENCC="88";;"%")ENCC="89";;"^")ENCC="90";;"'")ENCC="91";;"=")ENCC="92";;"~")ENCC="93";;"/")ENCC="94";;"<")ENCC="95";;">")ENCC="96";;"_")ENCC="97"
					esac
		
					echo $ENCC >> tmp1
					MSGCNT=$(( MSGCNT +1 ))
				done
			
			DUMCNT=0
			while read LINE																										#Random 6 digit number line is chosen from the character file
				do
					RAND=$(strings /dev/urandom | grep -o '[0-9]' | head -n 5 | tr -d '\n'; echo)
					if [ $RAND -gt "10110" ] 2> /dev/null
						then
							RAND=${RAND:0:4}
					fi
					if [ $ENABLEDUMMY = "1" ] 2> /dev/null												#Dummy characters are added
						then
							if [ $DUMCNT = "$DUMMYPOSITION" ] 2> /dev/null
								then
									echo $(strings /dev/urandom | grep -o '[0-9]' | head -n 6 | tr -d '\n'; echo) >> tmp2
									echo $(cat $KEY/$LINE/$LINE | sed -n "$RAND"p) >> tmp2
									DUMCNT=1
								else
									echo $(cat $KEY/$LINE/$LINE | sed -n "$RAND"p) >> tmp2
									DUMCNT=$(( DUMCNT + 1 ))
							fi
						else
							echo $(cat $KEY/$LINE/$LINE | sed -n "$RAND"p) >> tmp2
					fi
				done <$FILE																											###Custom###
		
				echo $(tr '\n' ' ' < tmp2 | sed -e 's/\s//g') > tmp3						#Newlines are removed leaving a continuous stream of numbers
				if [ $ENABLEPADDING = "1" ] 2> /dev/null												#Random padding is added
					then
							FPAD=$(strings /dev/urandom | grep -o '[0-9]' | head -n $PADDING1 | tr -d '\n'; echo)
							LPAD=$(strings /dev/urandom | grep -o '[0-9]' | head -n $PADDING2 | tr -d '\n'; echo)
							CATMSG=$(cat tmp3)
							MSG=$FPAD$CATMSG$LPAD
							echo $MSG > tmp3
				fi
				if [ $ENABLERANDLENGTH = "1" ] 2> /dev/null											#Random length is acheived by reading from $FPAD
					then
						ADD=${FPAD:0:2}
						ADD=$(strings /dev/urandom | grep -o '[0-9]' | head -n $ADD | tr -d '\n'; echo)
						MSG=$(cat tmp3)
						echo $MSG$ADD > tmp3																				#Add random length to message
				fi
		else
			echo $MSG > tmp3
	fi
	FILE=$KEY/meta/meta
	LNUM=1																																##Openssl layer##
	while read LINE																												#Passwords for openssl layers are imported from $KEY/meta/meta
		do																																	###Custom###
			case $LNUM in
					1)PASS1="$LINE";;
					2)PASS2="$LINE";;
					3)PASS3="$LINE";;
					4)PASS4="$LINE";;
					5)PASS5="$LINE"
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <"$FILE"
																																				###Custom###
	openssl enc $CIPHER1 -salt -in tmp3 -out tmp01 -k "$PASS1" 2> /dev/null
	openssl enc $CIPHER2 -salt -in tmp01 -out tmp02 -k "$PASS2" 2> /dev/null
	openssl enc $CIPHER3 -salt -in tmp02 -out tmp03 -k "$PASS3" 2> /dev/null
	openssl enc $CIPHER4 -salt -in tmp03 -out tmp04 -k "$PASS4" 2> /dev/null
	openssl enc $CIPHER5 -a -salt -in tmp04 -out $KEY/$ENCDIR/$EMSGFILE -k "$PASS5" 2> /dev/null	
	
	shred -zfun 3 tmp* 2> /dev/null
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
		"c") cat $KEY/$ENCDIR/$EMSGFILE | xclip -sel clip; DISPCOPYMSG=1;fmenu;;
		"C") cat $KEY/$ENCDIR/$EMSGFILE | xclip -sel clip; DISPCOPYMSG=1;fmenu;;
		"") fmenu
	esac
}

fdecryptmsg()																														#Decrypt messages
{
	finputkey
	flockcheck
	ISDONE=0
	TMPCHK=0
	
	while [ $ISDONE = "0" ]
		do
			clear
			$COLOR 5;echo " [>] Paste your message from clipboard or read message file from 0_Encrypted_Messages? [P/f]:";$COLOR 9
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
		"P") mv "$DATEFILE" tmp01 ; DMSGFILE="$DATER";;
		"p") mv "$DATEFILE" tmp01 ; DMSGFILE="$DATER";;
		"") mv "$DATEFILE" tmp01 ; DMSGFILE="$DATER";;
		"f") cat $KEY/$ENCDIR/$DMSGFILE  > tmp01;;
		"F") cat $KEY/$ENCDIR/$DMSGFILE  > tmp01
	esac
	
	FILE=$DIRR$KEY"/meta/meta"
	LNUM=1																																##Openssl layer##
	while read LINE																												#Passwords for openssl layers are imported from $KEY/meta/meta
		do																																	###Custom###
			case $LNUM in
					1)PASS1="$LINE";;
					2)PASS2="$LINE";;
					3)PASS3="$LINE";;
					4)PASS4="$LINE";;
					5)PASS5="$LINE"
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <"$FILE"
																																				###Custom###
	openssl enc $CIPHER5 -d -a -salt -in tmp01 -out tmp02 -k "$PASS5" 2> /dev/null	
	openssl enc $CIPHER4 -d -salt -in tmp02 -out tmp03 -k "$PASS4" 2> /dev/null
	openssl enc $CIPHER3 -d -salt -in tmp03 -out tmp04 -k "$PASS3" 2> /dev/null
	openssl enc $CIPHER2 -d -salt -in tmp04 -out tmp05 -k "$PASS2" 2> /dev/null
	openssl enc $CIPHER1 -d -salt -in tmp05 -out tmf -k "$PASS1" 2> /dev/null

	shred -zfun 3 tmp* 2> /dev/null
	
	if [ $ENABLERAND = "1" ] 2> /dev/null																	##Random number layer##
		then
		
			if [ $ENABLERANDLENGTH = "1" ] 2> /dev/null												#Remove extra random length
					then
						ENCCMSG=$(cat tmf)
						REMOVE=${ENCCMSG:0:2}
						echo ${ENCCMSG:0:-$REMOVE} > tmf
			fi
			if [ $ENABLEPADDING = "1" ] 2> /dev/null													#Remove padding
				then
					ENCCMSG=$(cat tmf)
					echo ${ENCCMSG:$PADDING1:-$PADDING2} > tmf				
			fi
			ENCCLEN=$(wc -c tmf)																							
			ENCCMSG=$(cat tmf)
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
	
			while [ $DECCNT -le $ENLEN ]																			###Custom###
				do																															#Add newlines every 6 characters
					CHAR=${ENCCMSG:$DECCNT:6}
					echo $CHAR >> tmp01			
					DECCNT=$(( DECCNT + 6 ))
				done
				
			FILE=tmp01
			if [ $ENABLEDUMMY = "1" ] 2> /dev/null
				then
					REMOVEDUM=$( awk NR%$DUMMYREMOVE tmp01 )											#Remove dummy characters
					echo "$REMOVEDUM" > tmp01
			fi

			while read LINE																										#6 digit number is located using grep from the character files
				do
					LONGLET=$(grep -rl $LINE $KEY/)
					echo ${LONGLET: -2} >> tmp02
				done <$FILE
			FILE=tmp02

			while read LINE																										#Each file number is assigned a character 
				do																															###Custom###
					case $LINE in
						10)DECC="0";;11)DECC="a";;12)DECC="b";;13)DECC="c";;14)DECC="d";;15)DECC="e";;16)DECC="f";;17)DECC="g";;18)DECC="h";;19)DECC="i";;20)DECC="j";;21)DECC="k";;22)DECC="l";;23)DECC="m";;24)DECC="n";;25)DECC="o";;26)DECC="p";;27)DECC="q";;28)DECC="r";;29)DECC="s";;30)DECC="t";;31)DECC="u";;32)DECC="v";;33)DECC="w";;34)DECC="x";;35)DECC="y";;36)DECC="z";;37)DECC="1";;38)DECC="2";;39)DECC="3";;40)DECC="4";;41)DECC="5";;42)DECC="6";;43)DECC="7";;44)DECC="8";;45)DECC="9";;46)echo -n ' ' >> tmp03;DECC=" ";;47)DECC="A";;48)DECC="B";;49)DECC="C";;50)DECC="D";;51)DECC="E";;52)DECC="F";;53)DECC="G";;54)DECC="H";;55)DECC="I";;56)DECC="J";;57)DECC="K";;58)DECC="L";;59)DECC="M";;60)DECC="N";;61)DECC="O";;62)DECC="P";;63)DECC="Q";;64)DECC="R";;65)DECC="S";;66)DECC="T";;67)DECC="U";;68)DECC="V";;69)DECC="W";;70)DECC="X";;71)DECC="Y";;72)DECC="Z";;73)DECC=".";;74)DECC="?";;75)DECC=",";;76)DECC="!";;77)DECC=";";;78)DECC="$";;79)DECC="£";;80)DECC="&";;81)DECC='(';;82)DECC=')';;83)DECC="-";;84)DECC="+";;85)DECC="@";;86)DECC=":";;87)DECC='"';;88)DECC="#";;89)DECC="%";;90)DECC="^";;91)DECC="'";;92)DECC="=";;93)DECC="~";;94)DECC="/";;95)DECC="<";;96)DECC=">";;97)DECC="_"
					esac
			
					echo -n $DECC >> tmp03
				done <$FILE
			if [ $ENABLEDUMMY = "1" ] 2> /dev/null
				then
					echo "$(cat tmp03)" > $KEY/$DECDIR/$DMSGFILE									#Cleartext message
				else 
					MSG="$(cat tmp03)"
					MSG="${MSG%?}"
					echo "$MSG" > $KEY/$DECDIR/$DMSGFILE
			fi
		else
			cat tmf > $KEY/$DECDIR/$DMSGFILE
	fi
	shred -zfun 3 tm* 2> /dev/null
	clear
	if [ $( cat $KEY/$DECDIR/$DMSGFILE ) -z ] 2> /dev/null
		then
			DISPERRORMSG=1;fmenu
		else
			cat $KEY/$DECDIR/$DMSGFILE
			echo
			$COLOR 2;echo " [*] Message saved to $DIRR$KEY/$DECDIR/$DMSGFILE";$COLOR 9
			echo
			echo " [>] Press d and Enter to shred $DMSGFILE"
			echo " [>] Press Enter to return to menu"
			read -e -p " >" SMF
			clear
			case $SMF in
				"")fmenu;;
				"d")$COLOR 4;echo " [*] Shreding $DMSGFILE...";$COLOR 9;shred -zfun 3 $DIRR$KEY/$DECDIR/$DMSGFILE;DISPSHRED=1;sleep 1.5;fmenu;;
				"D")$COLOR 4;echo " [*] Shreding $DMSGFILE...";$COLOR 9;shred -zfun 3 $DIRR$KEY/$DECDIR/$DMSGFILE;DISPSHRED=1;sleep 1.5;fmenu
			esac
	fi
	
}

fdecpaste()																															#Paste messages into fdecryptmsg from the clipboard																
{
	DATER=$( date +%Y_%d_%m_%H_%M_%S )
	DATEFILE="$DIRR""$KEY"/"$ENCDIR"/"$DATER"
	xclip -sel clip -o > $DATEFILE
	ISDONE=1
}

fencryptfile()																													#Encrypt files
{
	finputkey
	flockcheck
	clear
	$COLOR 5;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
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
	EMSGFILE=$(basename $INFILE)
	$COLOR 4;echo " [*] Encrypting "$ENCCMSF", Please wait..";$COLOR 9
	
	if [ ! -d $KEY/$ENCDIR/0_Encrypted_Files ]
		then
			mkdir $KEY/$ENCDIR/0_Encrypted_Files
	fi
	FILE=$KEY/meta/meta
	LNUM=1
	
	while read LINE																												#Passwords for openssl layers are imported from $KEY/meta/meta
		do																																	###Custom###
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE;;
					4)PASS4=$LINE;;
					5)PASS5=$LINE
			esac
		LNUM=$(( LNUM + 1 ))
		done <$FILE
																																				###Custom###
	openssl enc $CIPHER1 -salt -in $INFILE -out tmp01 -k "$PASS1" 2> /dev/null	
	openssl enc $CIPHER2 -salt -in tmp01 -out tmp02 -k "$PASS2" 2> /dev/null
	openssl enc $CIPHER3 -salt -in tmp02 -out tmp03 -k "$PASS3" 2> /dev/null
	openssl enc $CIPHER4 -salt -in tmp03 -out tmp04 -k "$PASS4" 2> /dev/null
	openssl enc $CIPHER5 -a -salt -in tmp04 -out $KEY/$ENCDIR/0_Encrypted_Files/$EMSGFILE -k "$PASS5" 2> /dev/null

	shred -zfun 3 tmp* 2> /dev/null
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

fdecryptfile()																													#Decrypt files
{
	finputkey
	flockcheck
	clear
	$COLOR 5;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
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
	clear
	$COLOR 4;echo " [*] Decrypting "$DFILE", Please wait..";$COLOR 9
	
	if [ ! -d $KEY/$DECDIR/0_Decrypted_Files ]
		then
			mkdir $KEY/$DECDIR/0_Decrypted_Files
	fi
	FILE=$KEY/meta/meta
	LNUM=1
	
	while read LINE  																											#Passwords for openssl layers are imported from $KEY/meta/meta
		do																																	###Custom###
			case $LNUM in
					1)PASS1=$LINE;;
					2)PASS2=$LINE;;
					3)PASS3=$LINE;;
					4)PASS4=$LINE;;
					5)PASS5=$LINE
			esac
		
			LNUM=$(( LNUM + 1 ))
		done <$FILE
																																				###Custom###
	openssl enc $CIPHER5 -d -a -salt -in $INFILE -out tmp01 -k "$PASS5" 2> /dev/null
	openssl enc $CIPHER4 -d -salt -in tmp01 -out tmp02 -k "$PASS4" 2> /dev/null
	openssl enc $CIPHER3 -d -salt -in tmp02  -out tmp03 -k "$PASS3" 2> /dev/null
	openssl enc $CIPHER2 -d -salt -in tmp03 -out tmp04 -k "$PASS2" 2> /dev/null
	openssl enc $CIPHER1 -d -salt -in tmp04  -out $KEY/$DECDIR/0_Decrypted_Files/$DFILE -k "$PASS1" 2> /dev/null	

	if [ $( cat tmp04 2> /dev/null ) -z ] 2> /dev/null
		then
			clear;DISPERRORFILE=1;fmenu
		else
			shred -zfun 3 tmp* 2> /dev/null
			clear
			$COLOR 2;echo " [*] File saved to $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DFILE";$COLOR 9
			echo
			STRT=" [*] "
			CHKFILE=$( file $DIRR$KEY/$DECDIR/0_Decrypted_Files/$DFILE )
			$COLOR 2;echo $STRT$CHKFILE;$COLOR 9
			echo
			read -e -p " [>] Press Enter to return to menu"
			fmenu
	fi
}

fcat()																																	#Read messages to the screen
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
				
	$COLOR 5;echo " [>] Which file do you want to read?";$COLOR 9
	cd $KEY/$CATDIR; ls
	read -e -p " >" CATFILE
		
	if [ -f $CATFILE ]
		then
			clear
			cat $CATFILE
			echo
			if [ $CATDIR = $DECDIR ]
				then
					echo " [>] Press d and Enter to shred $CATFILE"
					echo " [>] Press Enter to return to menu"
					read -e -p " >" SMF
					clear
					case $SMF in
						"")fmenu;;
						"d")$COLOR 4;echo " [*] Shreding $CATFILE...";$COLOR 9;DMSGFILE=$CATFILE;DISPSHRED=1;shred -zfun 3 $DIRR$KEY/$CATDIR/$CATFILE;sleep 1.5;fmenu;;
						"D")$COLOR 4;echo " [*] Shreding $CATFILE...";$COLOR 9;DMSGFILE=$CATFILE;DISPSHRED=1;shred -zfun 3 $DIRR$KEY/$CATDIR/$CATFILE;sleep 1.5;fmenu
					esac
				else
					echo " [>] Press c and Enter to copy to clipboard"
					echo " [>] Press s and Enter to send via SSH"
					read -e -p """ [>] Press Enter to return to menu
 >""" SMF
					case $SMF in
						"s")INFILE=$DIRR$KEY/$CATDIR/$CATFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
						"S")INFILE=$DIRR$KEY/$CATDIR/$CATFILE;SSHSEND=1;cd "$DIRR";fsshsend;;
						"c") cat $CATFILE | xclip -sel clip; DISPCOPYMSG=1;fmenu;;
						"C") cat $CATFILE | xclip -sel clip; DISPCOPYMSG=1;fmenu;;
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

fopendir()																															#Open message folder
{
	finputkey
	
	nautilus $KEY/$OPENDIR 2> /dev/null
	
	fmenu
}

fkeylock()																															#Lock local keys by encrypting $KEY/meta/meta and $KEY/config
{
	if [ $DOLOCK = "1" ] 2> /dev/null
		then
			DOLOCK=0
		else
			finputkey
	fi
	clear
	PASSDON=0
	if [ -f $KEY/lconfig ] 2> /dev/null
		then
			fkeyunlock
	fi
	while [ $PASSDON != "1" ]
		do
			clear
			$COLOR 5;echo " [*] Lock $KEY [*] ";$COLOR 9
			$COLOR 1;echo " [*] WARNING: Please use a very strong password, at least 10 characters long including capitals and numbers";$COLOR 9
			echo
			$COLOR 5;echo " [>] Please Enter your password";$COLOR 9
			read -s  TPASS
			$COLOR 5;echo " [>] Enter once more"  ;$COLOR 9
			read -s ZPASS
			if [ $TPASS != $ZPASS ]
				then
					$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
					sleep 2
				else
					PASSDON=1																											###Custom###
					NPASS=$(echo $ZPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					FPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					NPASS=$(echo $NPASS$NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					GPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					GPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					MPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					MPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					LPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					LPASS=$(echo $LPASS$LPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
							
					clear																													###Custom###
					$COLOR 4;echo " [*] Encrypting "$KEY", Please wait...";$COLOR 9
					openssl enc -aes-256-cbc -salt -in $KEY/meta/meta -out tmp01 -k "$FPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp01 -out tmp02 -k "$NPASS" 2> /dev/null
					openssl enc -aes-256-cbc -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp03 -out tmp04 -k "$MPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in tmp04 -out $KEY/meta/lmeta -k "$LPASS" 2> /dev/null
					
					shred -zfun 3 tmp* 2> /dev/null
					shred -zfun 3 $KEY/meta/meta 2> /dev/null
					
					openssl enc -aes-256-cbc -salt -in $KEY/config -out tmp01 -k "$FPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp01 -out tmp02 -k "$NPASS" 2> /dev/null
					openssl enc -aes-256-cbc -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp03 -out tmp04 -k "$MPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in tmp04 -out $KEY/lconfig -k "$LPASS" 2> /dev/null
					
					shred -zfun 3 tmp* 2> /dev/null
					shred -zfun 3 $KEY/config 2> /dev/null
					
			fi
		done
	DISPKEYLOCK=1;fmenu
}

fkeyunlock()																														#Unlock local keys
{
	DONPS=0
	while [ $DONPS != "1" ]
		do
			clear
			$COLOR 5;echo " [*] Unlock $KEY [*] ";$COLOR 9
			echo
			$COLOR 5;echo " [>] Please Enter the password ";$COLOR 9
			read -s RPASS
			$COLOR 5;echo " [>] Enter one more time ";$COLOR 9
			read -s ZPASS
			if [ $RPASS != $ZPASS ]
				then
					$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
					sleep 2
				else
					DONPS=1
			fi
		done
			
	clear
	$COLOR 4;echo " [*] Decrypting "$KEY", Please wait...";$COLOR 9

																																				###Custom###
	NPASS=$(echo $ZPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	FPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	NPASS=$(echo $NPASS$NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	GPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	GPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	MPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	MPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	LPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
	LPASS=$(echo $LPASS$LPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
																																				###Custom###
	openssl enc -aes-256-cbc -d -a -salt -in $KEY/meta/lmeta -out tmp01 -k "$LPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -salt -in tmp01 -out tmp02 -k "$MPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -salt -in tmp03 -out tmp04 -k "$NPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -salt -in tmp04 -out $KEY/meta/meta -k "$FPASS" 2> /dev/null
	
	if [ $(cat tmp03) -z ] 2> /dev/null
		then
			DISPERRORUNLOCKKEY=1;shred -zfun 3 $KEY/meta/meta;shred -zfun 3 tmp* 2> /dev/null; sleep 2;fmenu
	fi
	
	shred -zfun 3 tmp* 2> /dev/null
	shred -zfun 3 $KEY/meta/lmeta 2> /dev/null
		
	openssl enc -aes-256-cbc -d -a -salt -in $KEY/lconfig -out tmp01 -k "$LPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -salt -in tmp01 -out tmp02 -k "$MPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
	openssl enc -camellia-256-cbc -d -salt -in tmp03 -out tmp04 -k "$NPASS" 2> /dev/null
	openssl enc -aes-256-cbc -d -salt -in tmp04 -out $KEY/config -k "$FPASS" 2> /dev/null
			
	shred -zfun 3 tmp* 2> /dev/null
	shred -zfun 3 $KEY/lconfig 2> /dev/null
	
	clear
	DISPKEYUNLOCK=1;fmenu
}

fexportkey()																														#Export keys
{
	finputkey
	flockcheck
	WHSAV=$HOME/Desktop/nypt/Exported_Keys
	clear
	PASSDON=0
	while [ $PASSDON != "1" ]
		do
			clear
			$COLOR 1;echo " [*] WARNING: Please use a very strong password, at least 10 characters long including capitals and numbers";$COLOR 9
			echo
			$COLOR 5;echo " [>] Please Enter your password";$COLOR 9
			read -s  TPASS
			$COLOR 5;echo " [>] Enter once more"  ;$COLOR 9
			read -s ZPASS
			if [ $TPASS != $ZPASS ]
				then
					$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
					sleep 2
				else
					PASSDON=1																											###Custom###
					NPASS=$(echo $ZPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					FPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					NPASS=$(echo $NPASS$NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					GPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					GPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					MPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					MPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					LPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
					LPASS=$(echo $LPASS$LPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
							
					mv $KEY/$DECDIR $DECDIR
					mv $KEY/$ENCDIR $ENCDIR
							
					if [ -f  $WHSAV/$KEY ] 2> /dev/null
						then
							shred -zfun 3 $WHSAV/$KEY
					fi
					zip -reP $ZPASS $KEY.zip $KEY
					clear																													###Custom###
					$COLOR 4;echo " [*] Encrypting "$KEY", Please wait...";$COLOR 9
					openssl enc -aes-256-cbc -salt -in $KEY.zip -out tmp01 -k "$FPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp01 -out tmp02 -k "$NPASS" 2> /dev/null
					openssl enc -aes-256-cbc -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
					openssl enc -camellia-256-cbc -salt -in tmp03 -out tmp04 -k "$MPASS" 2> /dev/null
					openssl enc -aes-256-cbc -a -salt -in tmp04 -out $WHSAV/$KEY -k "$LPASS" 2> /dev/null
							
					mv $DECDIR $KEY/$DECDIR 
					mv $ENCDIR $KEY/$ENCDIR
					
			fi
		done

	shred -zfun 3 tmp* 2> /dev/null
	shred -zfun 3 $KEY.zip
	clear
	$COLOR 2;echo " [*] $KEY exported to $WHSAV/$KEY"
	SIZE=$( du -h $WHSAV/$KEY )
	echo " [*] "${SIZE:0:4} "in size ";$COLOR 9
	echo
	echo " [>] Press s and Enter to send via SSH"
	read -e -p """ [>] Press Enter to return to menu
 >""" DOFILE
	echo
	case $DOFILE in
		"s")INFILE=$WHSAV/$KEY;SSHSEND=1;cd "$DIRR";fsshsend;;
		"S")INFILE=$WHSAV/$KEY;SSHSEND=1;cd "$DIRR";fsshsend;;
		"")fmenu
	esac
	fmenu
}

fimportkey()																														#Import keys
{
	clear
	$COLOR 5;echo " [>] Please Enter the location of the key file eg. $HOME/Desktop/key ";$COLOR 9
	read -e -p " >" KEYLOC
	if [ $KEYLOC -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter the path to key file eg. $HOME/Desktop/key, try again...";$COLOR 9
			sleep 2
			fimportkey
		else
			KEYLOC=$( echo $KEYLOC | tr -d \ )
			KEYFILE=$(basename $KEYLOC)
			if [ -d $KEYFILE ] 2> /dev/null
				then
					clear
					$COLOR 1;echo " [*] ERROR: A key called $KEYFILE aleady exists, do you want to rename the local key? [Y/n]";$COLOR 9
					read -p " >" RENAME
					case $RENAME in
						"")clear;$COLOR 5;read -p " [>] Rename $KEYFILE to: " RNAME;$COLOR 9;mv $KEYFILE $RNAME;echo;$COLOR 2;echo " [*] Key $KEYFILE renamed to $RNAME";$COLOR 9;sleep 1.5;;
						"Y")clear;$COLOR 5;read -p " [>] Rename $KEYFILE to: " RNAME;$COLOR 9;mv $KEYFILE $RNAME;echo;$COLOR 2;echo " [*] Key $KEYFILE renamed to $RNAME";$COLOR 9;sleep 1.5;;
						"y")clear;$COLOR 5;read -p " [>] Rename $KEYFILE to: " RNAME;$COLOR 9;mv $KEYFILE $RNAME;echo;$COLOR 2;echo " [*] Key $KEYFILE renamed to $RNAME";$COLOR 9;sleep 1.5;;
						"N")clear;$COLOR 1;echo " [*] ERROR: Could Not import $KEYFILE";$COLOR 9;sleep 1.5;fmenu;;
						"n")clear;$COLOR 1;echo " [*] ERROR: Could Not import $KEYFILE";$COLOR 9;sleep 1.5;fmenu;;
					esac
			fi
	fi
	if [ -f $KEYLOC ]
		then
			DONPS=0
			while [ $DONPS != "1" ]
				do
					clear
					$COLOR 5;echo " [>] Please Enter the password ";$COLOR 9
					read -s RPASS
					$COLOR 5;echo " [>] Enter one more time ";$COLOR 9
					read -s ZPASS
					if [ $RPASS != $ZPASS ]
						then
							$COLOR 1;echo " [*] Passwords do not match, try again...";$COLOR 9
							sleep 2
						else
							DONPS=1
					fi
				done
			
			clear
			$COLOR 4;echo " [*] Decrypting "$KEYFILE", Please wait...";$COLOR 9

			if [ -f $KEYFILE.zip ] 2> /dev/null
				then
					shred -zfun 3 $DIRR$KEYFILE.zip
			fi
																																				###Custom###
			NPASS=$(echo $ZPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			FPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			NPASS=$(echo $NPASS$NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			GPASS=$(echo $NPASS$NPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			GPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			MPASS=$(echo $GPASS$GPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			MPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			LPASS=$(echo $MPASS$MPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
			LPASS=$(echo $LPASS$LPASS | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum | sha512sum)
																																				###Custom###
			openssl enc -aes-256-cbc -d -a -salt -in $KEYLOC -out tmp01 -k "$LPASS" 2> /dev/null
			openssl enc -camellia-256-cbc -d -salt -in tmp01 -out tmp02 -k "$MPASS" 2> /dev/null
			openssl enc -aes-256-cbc -d -salt -in tmp02 -out tmp03 -k "$GPASS" 2> /dev/null
			openssl enc -camellia-256-cbc -d -salt -in tmp03 -out tmp04 -k "$NPASS" 2> /dev/null
			openssl enc -aes-256-cbc -d -salt -in tmp04 -out $KEYFILE.zip -k "$FPASS" 2> /dev/null
			
			if [ $( cat tmp04 2> /dev/null ) -z ] 2> /dev/null
				then
					shred -zfun 3 $KEYFILE.zip
					shred -zfun 3 tmp* 2> /dev/null
					DISPERRORKEY=1;fmenu
				else
					unzip -P $ZPASS $KEYFILE.zip -d .  2> /dev/null
					chown -hR $USER $KEYFILE
					mkdir $KEYFILE/$ENCDIR
					mkdir $KEYFILE/$DECDIR
					mkdir $KEYFILE/$ENCDIR/0_Encrypted_Files
					mkdir $KEYFILE/$DECDIR/0_Decrypted_Files
					clear
					$COLOR 4;echo " [*] Decrypting "$KEYFILE", Please wait..";$COLOR 9
					DISPIMPORT=1
					shred -zfun 3 $KEYFILE.zip
					shred -zfun 3 tmp* 2> /dev/null
					fmenu
			fi
		else
			$COLOR 1;echo " [*] There does not appear to be any file at $KEYFILE, try again...";$COLOR 9
			sleep 2
			fimportkey
	fi
}

finstallssh()																														#Install OpenSSH server
{
	clear
	if [ $(whoami) = 'root' ] 2> /dev/null
		then
			apt-get install openssh-server
		else
			sudo apt-get install openssh-server
	fi
}

fsshstart()																															#Start OpenSSH server
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

fsshsend()																															#Send files via SSH (SCP)
{
	clear
	cd "$DIRR"
	if [ $SSHSEND = "0" ] 2> /dev/null
		then
			$COLOR 5;echo " [>] Please Enter the location of the file: e.g. $HOME/file";$COLOR 9
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
			$COLOR 5;echo " [>] Please Enter the user you are logging in to";$COLOR 9
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
			$COLOR 5;echo " [>] Please Enter the IP address you are connecting to";$COLOR 9
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
	$COLOR 5;echo " [>] Is there a custom port number? [N/y]";$COLOR 9
	read -e -p " >" SSHPORTDO
	
	case $SSHPORTDO in
		"")SSHPORT=22;;
		"n")SSHPORT=22;;
		"N")SSHPORT=22;;
		"y")clear
			$COLOR 5;echo " [>] Please Enter the port number";$COLOR 9
			read -e -p " >" SSHPORT
			if [ $SSHPORT -z ] 2> /dev/null
				then
					$COLOR 1;echo " [*] You must Enter the port number you are connecting to, try again...";$COLOR 9
					sleep 1.5
					fsshsend
			fi;;
		"Y")clear
			$COLOR 5;echo " [>] Please Enter the port number";$COLOR 9
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

fsshencmsg()																														#Send encrypted message into fsshsend
{
	finputkey
	flockcheck
	clear
	$COLOR 5;echo " [>] Which message do you want to send?";$COLOR 9
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

 fsshkey()																															#Send encrypted keys into fsshsend
{
	finputkey
	flockcheck
	clear
	INFILE=$KEY/Exported_Keys/$KEY
	SSHSEND=1
	cd "$DIRR"
	fsshsend
}

fsshencfile()																														#Send encrypted file into fsshsend
{
	finputkey
	flockcheck
	clear
	$COLOR 5;echo " [>] Which Encrypted file do you want to send?";$COLOR 9
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

fshred()																																#Shred
{
	$COLOR 4
	if [ $SHREDDIR = $DECDIR ]
		then
			echo " [*] Shreding "$KEY"'s decrypted messages, Please wait.."
	elif [ $SHREDDIR = $ENCDIR ]
		then
			echo " [*] Shreding "$KEY"'s encrypted messages, Please wait.."
	fi
	if [ $SHREDDIR = $KEY ]
		then
			echo " [*] Shreding $KEY, Please wait.."
			find $KEY -type f -exec shred -zfun 3 {} \;
			rm -rf $KEY
			$COLOR 2;echo " [*] $KEY and all its messages shreded.";$COLOR 9
		else
			find $KEY/$SHREDDIR -type f -exec shred -zfun 3 {} \;
			$COLOR 2
			if [ $SHREDDIR = $DECDIR ]
				then
					echo " [*] "$KEY"'s decrypted messages shreded."
			elif [ $SHREDDIR = $ENCDIR ]
				then
					echo " [*] "$KEY"'s encrypted messages shreded."
			fi;$COLOR 9
	fi	
	sleep 2
}

fshreddir()																															#Shred messages and keys
{
	finputkey	
	clear
	$COLOR 1
	if [ $SHREDDIR = $DECDIR ]
		then
			echo " [>] Warning, this will shred all of "$KEY"'s decrypted messages, are you sure? [Y/n]"
	elif [ $SHREDDIR = $ENCDIR ]
		then
			echo " [>] Warning, this will shred all of "$KEY"'s encrypted messages, are you sure? [Y/n]"
	elif [ $SHREDDIR = "KEY" ]
		then
			echo " [>] Warning, this will shred $KEY and all of its messages and files, are you sure? [Y/n]"
			SHREDDIR=$KEY
	fi;$COLOR 9
	read -e -p " >" DODEL
	clear
	
	case $DODEL in
		"Y")fshred;;
		"y")fshred;;
		"")	fshred
	esac

	fmenu
}

flistgen()																															#Generate full list of 6 digit numbers
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

finputkey()																															#Select key to use
{
	cd $DIRR
	clear
	$COLOR 5;echo " [>] Which key? [<] ";$COLOR 9
	ls 
	read -e -p " >" KEY
	
	if [ "${KEY: -1}" = "/" ] 2> /dev/null
		then
			KEY="${KEY%?}"
	elif [ $KEY -z ] 2> /dev/null
		then
			$COLOR 1;echo " [*] You must Enter a key, try again...";$COLOR 9
			sleep 1.5
			finputkey
	elif [ ! -d $KEY ] 2> /dev/null
		then
			$COLOR 1;echo " [*] $KEY is not a valid key, try again...";$COLOR 9
			sleep 1.5
			finputkey
	fi
	FILE=$KEY/config 
	LNUM=1
	while read LINE 																											#Assign config variables from $KEY/config file
		do
			case $LNUM in
				18)CIPHER1="-"$LINE;;
				21)CIPHER2="-"$LINE;;
				24)CIPHER3="-"$LINE;;
				27)CIPHER4="-"$LINE;;
				30)CIPHER5="-"$LINE;;
				33)ENABLERAND=$LINE;;
				36)ENABLEDUMMY=$LINE;;
				39)DUMMYPOSITION=$LINE;;
				42)ENABLEPADDING=$LINE;;
				45)PADDING1=$LINE;;
				48)PADDING2=$LINE;;
				51)ENABLERANDLENGTH=$LINE
			esac
			LNUM=$((LNUM + 1))
		done < $FILE 
		DUMMYREMOVE=$((DUMMYPOSITION + 1))
}

fdisplaymenu()																													#Display information at top of menu
{
	if [ $DISPCOP = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] "$EMSGFILE"'s encrypted text copied to clipboard!";$COLOR 9
			DISPCOP=0
	elif [ $DISPERRORUNLOCKKEY = "1" ] 2> /dev/null
		then
			$COLOR 1;echo "  [*] ERROR: $KEY Not unlocked, Wrong password.";$COLOR 9
			DISPERRORUNLOCKKEY=0
	elif [ $DISPKEYLOCK = "1" ] 2> /dev/null
		then
			$COLOR 2; echo " [*] $KEY locked!";$COLOR 9
			DISPKEYLOCK=0
	elif [ $DISPKEYUNLOCK = "1" ] 2> /dev/null
		then
			$COLOR 2; echo " [*] $KEY unlocked!"; $COLOR 9
			DISPKEYUNLOCK=0
	elif [ $DISPIMPORT = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] $KEYFILE successfuly imported.";$COLOR 9
			DISPIMPORT=0
	elif [ $DISPERRORKEY = "1" ] 2> /dev/null
		then
			$COLOR 1;echo "  [*] ERROR: $KEYFILE Not imported, Wrong password or not an encrypted key.";$COLOR 9
			DISPERRORKEY=0
	elif [ $DISPERRORFILE = "1" ] 2> /dev/null
		then
			$COLOR 1;echo "  [*] ERROR: $DFILE Not decrypted, Wrong key or not an encrypted file.";$COLOR 9
			DISPERRORFILE=0
	elif [ $DISPERRORMSG = "1" ] 2> /dev/null
		then
			$COLOR 1;echo "  [*] ERROR: $DMSGFILE Not decrypted, Wrong key or not an encrypted message.";$COLOR 9
			DISPERRORMSG=0
	elif [ $DISPCOPYMSG = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] Message copied to clipboard!";$COLOR 9
			DISPCOPYMSG=0
	elif [ $DISPKEY = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] $KEY Complete!";$COLOR 9
			DISPKEY=0
	elif [ $DISPSHRED = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] $DMSGFILE shreded!";$COLOR 9
			DISPSHRED=0
	elif [ $DISPSSH = "1" ] 2> /dev/null
		then
			$COLOR 2;echo "  [*] $BASEFILE sent to "$RUSER"@"$IPSEND"";$COLOR 9
			DISPSSH=0
	fi
}

flockcheck()																														#Check if Key is locked
{
	if [ -f $KEY/lconfig ] 2> /dev/null
		then
			clear;$COLOR 1;echo " [*] WARNING: $KEY is locked, do you want to unlock it? [Y/n]";$COLOR 9;read -p " >" UNLOCK
			case $UNLOCK in
				"")fkeyunlock;;
				"y")fkeyunlock;;
				"Y")fkeyunlock;;
				"n")fmenu;;
				"N")fmenu
			esac
	fi
}

fexit()																																	#Delete left over tempory files when exitting
{   
	$COLOR 9
	cd $DIRR
	shred -zfun 3 tmp* 2> /dev/null
	echo
	exit
}
	
	fstart
