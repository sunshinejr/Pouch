# Next

## 0.4.0
- Added ability to read all .pouch.yml files from current directory, supporting multiple configurations

## 0.3.0
- Added `--print-secrets` flag that outputs resolved secrets per environment to standard output
- Added firebase option for input (where previously it was only environment variables). You can now use Info.plist for Firebase RemoteConfig variable fetcher
- Added optional `environments`, which derive all options from global settings
- Added `representation` option to the output (for now you can use dictionary/staticVariables)
- Updated min macOS version to 13.0.

## 0.2.0 (2021-04-02)
- Added `swiftlint:disable all` to the top of the file. [@Igor-Palaguta]
- Added "Generated using Pouch" to the top of the file. [@Igor-Palaguta]
- Fixed spacing in the generated file. [@Igor-Palaguta]

## 0.1.2 (2021-03-24)
- Resigned from building fat binaries due to problems with brew & intel macs.

## 0.1.1 (2021-03-24)
- Small updates to Makefile for brew support.

## 0.1.0 (2021-03-24)
- No need for `filePath` keyword in the `.pouch.yml` output if there is a single path (with multiple config options you need to type parameter names, similar to how secret parsing works).
- `pouch` will now by default run `pouch retrieve`.
- Fixed a bug where if you didn't provide output language it would print parser error.

## 0.0.1 (2021-03-15)
- Initial release 🥳

[@Igor-Palaguta]: https://github.com/Igor-Palaguta
