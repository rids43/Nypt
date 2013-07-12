 Nypt 1.37
 
NOTE: V.1.37 is incompatible with previous versions

Use:

Nypt is a command line and menu based bash script that is designed to be as user friendly as possible, thereby allowing new users of encryption to get access to strong encryption as quickly as possible.
All of the features are accessable from the menu based command line and there is autocomplete for file names, message names, keys and paths by pressing the tab key.
Received encrypted messages can be pasted in to Nypt from the clipboard, using the menu command at the "Decrypt message" menu.
Nypt also accepts message files saved into the 0_Encrypted_Messages directory in the directory of the key that you will use to decrypt it.

Video: http://www.youtube.com/watch?v=gQ0teiUdJjU

Custom wrapper for OpenSSL

Nypt uses a custom random based polyalphabetic encryption layer and five layers of customizable OpenSSL encryption to encrypt messages, files and keys for transmission across the internet. The secret keys are stored locally on the drive, and so passwords are not needed to encrypt/decrypt messages or files. The passwords for the layers are generated from urandom, have a variable possible length and are unique to each layer and key. All openssl layers are salted. Nypt uses symmetric encryption, which means that both communicating parties are required to have the same copy of the secret key, in order to read each others messages. Config files are located in each keys directory that can be edited to customize ciphers used for the openssl layers.

Changelog:
1.37

Added Random Padding feature in random based polyalphabetic encryption layer.
Added Dummy characters feature in random based polyalphabetic encryption layer.
Dummy character placement random for each key.
Padding amounts random for each key.

Key Transmission:

1. The safest way to transmit keys is always in person, in order to avoid interception all together.

2. SSH can be used to send keys over a peer-to-peer secure encrypted connection.

3. Keys can be encrypted with a custom password and sent across the internet in an email. The strength of this method will rely on the strength of the password and method used to transmit it.

4. Keys and/or their secret password can be transferred via SSH, PGP, cryptocat private room, or any other suitable encrypted communication method. There is functionality to send files via SSH built into Nypt.


Random based Polyalphabetic Encryption Layer:

There is a random based polyalphabetic encryption layer before the message gets encrypted with OpenSSL. 
The way this works is that every character is given a total of 10,110 different 6-digit combinations, and a 6-digit number is chosen randomly from this list for each character in a message. 
This ensures that every encrypted message, even if the same characters are encrypted multiple times, will have a different looking output but decode to the same deciphered text.
Dummy characters are then placed into the message, further obscuring any attempts at word pattern recognition.
Finally a random amount of random padding is added the start and end of the message. 
The settings for dummy placement and random padding can be found in the keys config file.

Nypt can be used as an additional layer under PGP encryption in your emails. 
We recommend the Thunderbird email client with enigmail addon for easy PGP use with your email account:

Thunderbird: http://www.mozilla.org/projects/thunderbird/
Enigmail: http://www.enigmail.net/home/index.php


Programmers: 
As determining the method of encryption is a very important step in breaking it, customizing certain parameters in this script is highly recommended to make it even more secure. The other communicating party must have a copy of the edited script for it to work.
Recommended areas of consideration for modification are commented ###Custom###
Send the edited script using secure encrypted communication methods.

rids@tormail.org 
