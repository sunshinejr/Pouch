# Pouch
Secret management tool written in Swift. This was heavily inspired by [CcocoaPods-Keys](https://github.com/orta/cocoapods-keys) & [NSHipster article regarding secret management](https://nshipster.com/secrets/).

## Usage

Set up a config file for a project once:
```yaml
secrets:
- API_KEY
- API_SECRET
outputs:
- ./Secrets.swift
```

Now, with `API_KEY` and `API_SECRET` stored in environment variables, you can generate a file with secrets using:
```
pouch retrieve
```

Which should generate an output similar to this one (applied `xor` on a string (+ randomly generated salt) with a reverse func to read it in the app)):
```swift
import Foundation

enum Secret {
    static let apiKey: String = Secret._xored([15, 26, 26, 243, 46, 124, 234, 140, 48, 169, 192], salt: [97, 115, 121, 150, 65, 18, 143, 225, 81, 221, 165, 134, 36, 222, 157, 20, 172, 203, 97, 8, 26, 81, 49, 144, 147, 1, 197, 21, 35, 32, 83, 156, 247, 108, 211, 108, 202, 174, 119, 134, 141, 176, 180, 38, 171, 110, 89, 21, 213, 32, 171, 146, 63, 245, 87, 139, 162, 194, 63, 57, 75, 0, 165, 122, 142])
    static let apiSecret: String = Secret._xored([153, 59, 35, 31, 242, 106, 45, 3, 19, 67, 207, 9, 190, 40, 55, 197, 218, 221, 1, 40, 170, 117, 103, 211, 204, 168, 44, 18, 39, 207, 44, 158, 217, 135, 163, 16, 145, 120, 158, 221, 212, 49, 229, 116, 188, 145, 91, 203, 174, 184, 158, 78, 146, 106, 100, 166, 93, 239, 8, 18, 38, 129, 97, 249, 218, 137, 48, 58, 80, 252, 102, 47, 7, 92, 90, 194, 64, 61, 151, 221, 39], salt: [252, 85, 73, 112, 139, 3, 67, 100, 51, 55, 167, 96, 205, 8, 68, 168, 187, 177, 109, 8, 222, 26, 8, 191, 243, 136, 101, 50, 80, 160, 89, 242, 189, 167, 207, 127, 231, 29, 190, 174, 187, 92, 128, 84, 212, 244, 55, 187, 142, 207, 247, 58, 250, 74, 13, 210, 124, 207, 88, 64, 85, 174, 8, 138, 169])

    private static func _xored(_ secret: [UInt8], salt: [UInt8]) -> String {
        return String(bytes: secret.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }, encoding: .utf8) ?? ""
    }
}
```
<br />

Now, add this file to your project structure (and to `.gitignore`) and use it!<br />

```swift
api.auth(key: Secret.apiKey, secret: Secret.apiSecret)
```

Note: The idea is that each developer would regenerate that file and not commit to the repository (however, you can use it however you want).

## Why?
Let's face it - managing secret keys is not an easy task. We usually want:
1. Protect ourselves against unwanted intruders that gain access to the repository (plain text is bad and so is e.g. symetric cryptography that only needs the attacker to either run the code to get the keys or calculate the secret by hand)
2. Protect ourselves against unwanted access to binary through e.g. jailbreak (e.g. in iOS the binary will hold plain text keys even if you ignored them in git, storing them in `.xcconfig` makes it even easier to the attacker)
3. The secret management to be as simple as possible.

While writing this tool there was nothing that I found that helped with all of the above.

`pouch` will make sure that static analysis tools will not be able to get to the keys easily. Though, for your own good, do not commit this file to the repository. 


## Configuration options
The config is in [YAML](https://yaml.org/spec/1.2/spec.html) format. By default the tool will look for `.pouch.yml` file, but you can provide a custom file path as a parameter:
```
pouch retrieve --config ./.custom.pouch.yml
```

For the config itself, you are required to have at least one secret and one output:
```yaml
secrets:
- API_KEY
outputs:
- ./Secrets.swift
```

Though, there are also custom properties you can set.

### Generated type name 
You can change the generated type name (it's `Secrets` by default):
```yaml
secrets:
- API_KEY
outputs:
- filePath: ./Constants.swift
  typeName: Constant
```

### Generated secret name
You are also able to provide a custom generated name for a secret (otherwise it will do the `camelCase`):
```yaml
secrets:
- name: API_KEY
  generatedName: youtubeApiKey
- API_SECRET
outputs:
- ./Secrets.swift
```

There are also things like custom inputs, but for now we only support environment variables.

## Installing
You can either build & install it by using my Homebrew tap:
```
brew install sunshinejr/formulae/pouch
```
or by cloning the repo and using Make:
```
make install
```

## Contributing
This project is at its early stage and it currently only supports `xor` with random salt & only Swift output, but I'm open to:
- Adding new ciphers (ideally something that works on all characters, e.g. `Caesar` is great but shifting might be problematic for things like emoji)
- Adding new cipher options (e.g. salt length)
- Adding new outputs (e.g. Kotlin, though I'd love to add only things that would be quite useful, not just a PoC)

## Notes about security
While this is for sure an improvement to your normal, plain-text based flow, this doesn't guarantee that your keys won't be reverse-engineered.
If you want to learn more about secret management and it's security, I recomend you to read the whole article I linked at the top of the Readme: [NSHipster article regarding secret management](https://nshipster.com/secrets/)

## Kudos
- to [@nshipster](https://github.com/NSHipster) folks for awesome articles, especially on [secret management](https://nshipster.com/secrets/) & [Homebrew releases](https://nshipster.com/homebrew/),<br />
- to [@orta](https://github.com/orta) for [cocoapods-keys](https://github.com/orta/cocoapods-keys),
- to [@yonaskolb](https://github.com/yonaskolb) and the whole team behind Mint for a [pretty nice Makefile template in Mint]() that I slightly modified,<br />
- to [@mxcl](https://github.com/mxcl) for a Swift clone of [Chalk](https://github.com/mxcl/Chalk) that Pouch uses for logging,<br />
- to [@jpsim](https://github.com/jpsim) and the contributors of [Yams](https://github.com/jpsim/Yams) for a yummy YAML parser that just works,<br />
- to [@natecook1000](https://github.com/natecook1000) and the contributors of [Swift Argument Parser](https://github.com/apple/swift-argument-parser) for an awesome experience that is building a modern command line tool<br />

## License
[Mit](License.md)
