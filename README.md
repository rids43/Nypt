nypt
====

Custom wrapper for openssl

Uses random number symmetric encryption and OpenSSL 256-bit to encrypt messages and files for transmission across the internet.
The secret keys are stored locally on the drive, and so passwords are not needed to encrypt/decrypt messages or files.
Both communicating parties are required to have the same copy of a key, in order to read each others messages. This means that the keys must
idealy be transmitted in person, in order to avoid interception.

There is a mechanism in place to encrypt the keys and send them across the internet. Using the default settings this is highly 
insecure as any party with this script will be able to decrypt the key and compromise all further communications using the key.
Keys can also be encrypted with a custom password, the downside is the other party must know that the key is encrypted with a custom
password and they must also know what this password is.

It is reccommended to use this script as an additional layer ontop of PGP encryption in your emails.
Recieved encrypted messages can be saved into a file in the 0_Encrypted_Messages directory in the directory of the key that you will 
use to decrypt it. They can also be pasted in provided you install xclip on your system (script will auto prompt if it is not  installed)
