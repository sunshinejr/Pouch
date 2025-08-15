# Pouch
A secure key management tool for Swift projects. Pouch helps you manage API keys and secrets by generating obfuscated Swift code, keeping sensitive data out of your repository while maintaining ease of use.

Heavily inspired by [CocoaPods-Keys](https://github.com/orta/cocoapods-keys) & [NSHipster's article on secret management](https://nshipster.com/secrets/).

## Features

- 🔐 **Multiple Input Sources**: Environment variables, 1Password, Firebase Remote Config (experimental)
- 🎯 **Environment-based Configuration**: Different keys for development, staging, and production
- 🔒 **Obfuscation**: XOR cipher with random salt generation
- 🚀 **Swift Code Generation**: Type-safe access to your keys
- 📦 **Zero Runtime Dependencies**: Generated code is standalone

## Quick Start

Create a `.pouch.yml` configuration file:
```yaml
keys:
- API_KEY
- API_SECRET

input:
  type: env

outputs:
- filePath: ./Secrets.swift
  typeName: Secrets
```

With `API_KEY` and `API_SECRET` in your environment variables, run:
```bash
pouch retrieve
```

This generates an obfuscated Swift file:
```swift
import Foundation

enum Secrets {
    static let apiKey: String = Secrets._xored([15, 26, 26, ...], salt: [97, 115, 121, ...])
    static let apiSecret: String = Secrets._xored([153, 59, 35, ...], salt: [252, 85, 73, ...])

    private static func _xored(_ secret: [UInt8], salt: [UInt8]) -> String {
        return String(bytes: secret.enumerated().map { index, character in
            return character ^ salt[index % salt.count]
        }, encoding: .utf8) ?? ""
    }
}
```

Add the generated file to your project (and `.gitignore`), then use it:
```swift
api.configure(key: Secrets.apiKey, secret: Secrets.apiSecret)
```

## Installation

### Homebrew
```bash
brew install sunshinejr/formulae/pouch
```

### From Source
```bash
git clone https://github.com/sunshinejr/Pouch.git
cd Pouch
make install
```

## Configuration

Pouch uses YAML configuration files (default: `.pouch.yml`). You can specify a custom config file:
```bash
pouch retrieve --config ./custom-config.yml
```

### Basic Configuration

The minimal configuration requires at least one key and one output:
```yaml
keys:
- API_KEY

input:
  type: env

outputs:
- filePath: ./Secrets.swift
```

### Input Sources

#### Environment Variables (Default)
```yaml
input:
  type: env
  keyMapping:
    API_KEY: MY_CUSTOM_ENV_VAR  # Optional: map to different env var names
```

#### 1Password
```yaml
input:
  type: 1password
  vault: MyVault
  account: my-account@example.com  # Optional: specific 1Password account
  section: production
  keyMapping:
    API_KEY: prod_api_key  # Optional: map to different item names
```

**Requirements:**
- 1Password CLI (`op`) must be installed
- Must be signed in to 1Password (`op signin`)

#### Firebase Remote Config (Experimental ⚠️)
```yaml
input:
  type: firebase
  configPath: ./GoogleService-Info.plist
  keyMapping:
    FEATURE_FLAG: remote_feature_flag_key
```

**Note:** Firebase Remote Config support is experimental and may have issues with configuration propagation. Best suited for non-sensitive configuration values rather than secrets.

### Multiple Environments

Configure different keys for different environments:
```yaml
keys:
- API_KEY
- DATABASE_URL
- ANALYTICS_ID

environments:
  dev:
    input:
      type: env
    outputs:
      - filePath: ./Secrets-Dev.swift
        typeName: DevSecrets
  
  staging:
    input:
      type: 1password
      vault: Staging
      section: api-keys
    outputs:
      - filePath: ./Secrets-Staging.swift
        typeName: StagingSecrets
  
  prod:
    input:
      type: 1password
      vault: Production
      account: company-account@1password.com
      section: api-keys
    outputs:
      - filePath: ./Secrets-Prod.swift
        typeName: ProdSecrets
```

### Output Configuration

#### Custom Type Names
```yaml
outputs:
- filePath: ./Constants.swift
  typeName: Constants  # Default: "Secrets"
```

#### Custom Property Names
```yaml
keys:
- name: API_KEY
  generatedName: youtubeApiKey  # Custom property name in Swift
- DATABASE_URL  # Will be converted to camelCase: databaseUrl
```

#### Multiple Output Files

Generate a single secrets file for multiple targets in your workspace:
```yaml
keys:
- API_KEY
- SHARED_SECRET

outputs:
- filePath: ./MainApp/Secrets.swift
  typeName: Secrets
- filePath: ./WidgetExtension/Secrets.swift  
  typeName: Secrets
- filePath: ./NotificationExtension/Secrets.swift
  typeName: Secrets
```

#### Encryption Options

For sensitive data (API keys, secrets):
```yaml
keys:
- API_KEY
- API_SECRET
- DATABASE_PASSWORD

outputs:
- filePath: ./Secrets.swift
  typeName: Secrets
  encryption: xor  # Default: obfuscates sensitive data
```

For non-sensitive configuration values (e.g., from Firebase Remote Config):
```yaml
keys:
- REVIEW_PROMPT_LAUNCHES  # Number of launches before showing app review
- MAX_CACHE_SIZE_MB
- FEATURE_FLAG_NEW_ONBOARDING
- API_TIMEOUT_SECONDS

input:
  type: firebase
  configPath: ./GoogleService-Info.plist

outputs:
- filePath: ./AppConfig.swift
  typeName: AppConfig
  encryption: none  # Plain text for non-sensitive configuration values
```

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
