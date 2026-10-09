Crypter - new kind of cryptography!

# Using Crypter

## Encryct file

```
./crypter --password=LqEI96iqFeOvaBgzxc3wr23r3rrarM8ic7mp --input=test.txt --output=test.txt.crypted
```

Crypter will generate test.txt.crypted and test.txt.crypted.key files. test.txt.crypted.key - keyfile for uncrypting!

Keep keyfiles protect!

## Uncrypting file

Put encryptedfile file and keyfile in same folder, and run uncrypter:

```
./uncrypter --input=test.txt.crypted --output=out.txt
```


