Crypter: new kind of cryptography!


# Installation

```
perl Makefile.pl
make && make test
sudo make install
```

# Using Crypter

## Encryct file

```
crypter --salt=Strong_Slat_Like_Next__LqEI96iqFeOvaBgzxc3wr23r3rrarM8ic7mp --input=test.txt --output=test.txt.crypted
```

Crypter will generate test.txt.crypted and test.txt.crypted.key files. test.txt.crypted.key - keyfile for uncrypting!

Slat needed only for strong keyfile generation! 

Don't use salt more longer than encrtyped information, it's unneeded!

Keep keyfiles protect!

## Uncrypting file

Put encryptedfile file and keyfile in same folder, and run uncrypter:

```
crypter -d test.txt.crypted
```

## Password Genrator

```
crypter --pwdgen
```

## Noise Genrator

```
crypter --noise
```


