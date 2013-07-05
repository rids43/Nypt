 Nypt 1.34
 
NOTE: V.1.34 is incompatible with previous versions

Custom wrapper for OpenSSL

Nypt uses a custom random number symmetric encryption layer and five layers of OpenSSL 256-bit highest grade encryption to encrypt messages, files and keys for transmission across the internet. The secret keys are stored locally on the drive, and so passwords are not needed to encrypt/decrypt messages or files. Both communicating parties are required to have the same copy of the secret key, in order to read each others messages.

Random Number Encryption Layer:

There is a layer of random number encryption before the message gets encrypted with OpenSSL. The way this works is that every character is given a total of 10,110 different 6-digit combinations, and a 6-digit number is chosen randomly from this list for each character in a message. This ensures that every encrypted message, even if the same character is encrypted over and over again, will look different but decode to the same result.

Use:

It is recommended to use Nypt as an additional layer on top of PGP encryption in your emails. Received encrypted messages can be pasted in to Nypt using the xclip program. Nypt accepts files saved into the 0_Encrypted_Messages directory in the directory of the key that you will use to decrypt it. Nypt is command line and menu based and is designed to be as user friendly as possible, thereby allowing new users of encryption to get access to it as quickly as possible.

Key Transmission:

1. The safest way to transmit keys is always in person, in order to avoid interception all together.

2. SSH can be used to send keys over a peer-to-peer secure encrypted connection.

3. Keys can be encrypted with a custom password and sent across the internet in an email. The strength of this method will reley on the strength of the password used.

4. Keys and/or their secret password can be transferred via SSH, PGP, cryptocat private room, or any other suitable encrypted communication method. There is functionality to send files via SSH built into Nypt.

We recommend the Thunderbird email client with enigmail addon for easy PGP use with your email account:

Thunderbird: http://www.mozilla.org/projects/thunderbird/
Enigmail: http://www.enigmail.net/home/index.php

Programmers: Customizing certain parameters in this script is highly recommended to make it even more secure, just remember that the other party must have a copy of the edited script for it to work. This is another problem that must be solved by sending the edited script using secure encrypted communication methods.

rids@tormail.org 
