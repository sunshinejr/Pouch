## Next
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