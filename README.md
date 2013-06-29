nypt 1.3
====

Custom wrapper for openssl

Uses random number symmetric encryption and three layers of OpenSSL Highest grade to encrypt messages and files for 
transmission across the internet. The secret keys are stored locally on the drive, and so passwords are not needed to 
encrypt/decrypt messages or files. Both communicating parties are required to have the same copy of the private key, 
in order to read each others messages. 

Random Number Encryption Layer:

There is a layer of random number encryption before the message get's encrypted with OpenSSL. The way this works
is every character is given a total of 10,110 different 6-digit combinations, and a 6-digit number is choosen randomly 
from this list for each character in a message. This ensures that every encrypted message, even if the same character is
encrypted over and over again, will look different but decode to the same result.

Use:
It is reccommended to use this script as an additional layer ontop of PGP encryption in your emails.
Recieved encrypted messages can be pasted in to the program using the xclip program. The program also accepts files saved into 
the 0_Encrypted_Messages directory in the directory of the key that you will use to decrypt it. The script is command line
and menu based. Nypt is designed to be as user friendly as possible, thereby allowing new users of encryption to get access
to it as quickly as possible.

Key Transmission:

1. The safest way to transmit keys is always in person, in order to avoid interception all together.

2. There is a mechanism in place to encrypt the keys and send them across the internet. Using the default settings this is highly 
insecure as any man-in-the-middle with this script will be able to decrypt the key and compromise all further communications using
the key.

3. Keys can be encrypted with a custom password, the downside is the other party must know that the key is encrypted with a custom
password and they must also know what this password is. This information must somehow be transmitted to them (see below).

4. Keys and/or their secret password can be transfered via SSH, PGP, cryptocat private room, or any other suitable encrypted
communication method.


Programmers:
Customizing certain parameters in this script is highly reccommended to make it more secure, just remember that the other
party must have a copy of the edited script for it to work. This is another problem that must be solved by sending the edited
script using secure encrypted communication methods.

please direct any questions or comments to rids@tormail.org 
