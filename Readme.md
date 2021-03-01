# Pouch
Secret management tool written in Swift.

## Why
Let's face it - managing secret keys is not an easy task. We usually want:
1. Protect ourselves against unwanted intruders that gain access to the repository (plain text is bad so is e.g. symetric cryptography that only needs the attacker to either run the code to get the keys or calculate the secret by hand)
2. Protect ourselves against unwanted access to binary through e.g. jailbreak (e.g. in iOS the binary will hold plain text keys even if you ignored them in git, storing them in `.xcconfig` makes it even easier to the attacker)
3. The secret management to be as simple as possible.

While writing this tool there was nothing that I found that helped with all of the above. 

## How
_Note: Pouch's goal is to be highly customizable and available to the broader audience, but right now this tool works only for Swift projects. (though I'd welcome any other output functions!)._

### Setup the project
Enter the root of your project and type:
```bash
pouch setup
```

Now, answer few questions like the input (right now only environment variables), destination path for your generated Swift file and encryption (you can choose between randomized (or not) salt in xor cipher).

### Add keys you want to use
Run:
```bash
pouch add __KEY1__, __KEY2__ ...
```

This will add the keys you want to use through Pouch. 
 
### Retrieve the keys & generate a Swift file
Enter the root of your project and type:
```bash
pouch retrieve
```
If you added at least one key to the configuration, the generation process will start. For each key **pouch** will go through input function and if we cannot find the key in there, **pouch** will ask in the command line to provide the necessary key.

## License
[Mit](License.md)
