# Diceware
Diceware is a lightweight CLI tool that generates strong passphrases using randomly selected English words. Compatible with most Linux distros and MacOS.

## Why Diceware

[Diceware](https://theworld.com/~reinhold/diceware.html) is a powerful passphrase generation method known for its simplicity and security. Instead of relying on physical dice, the script employs a cryptographically secure source of randomness to ensures that the chosen words are truly random and resistant to attacks. The resulting passphrases consist of carefully selected words, adding complexity to enhance security, while keeping the words easy to remember. Diceware strikes a balance by offering customizable passphrase lengths, allowing users to tailor security to their needs. Its straightforward yet effective approach, combined with the script's capability to create more intricate phrases, makes Diceware a reliable and user-friendly choice for generating strong and memorable passphrases.

[Related XKCD.](https://imgs.xkcd.com/comics/password_strength.png)

## Installation

1. Download the script (either by `git clone`ing or any other way)
1. (optional) Add an alias to the script in your .bashrc/.zshrc file:  
`alias diceware="/home/myuser/diceware/diceware.sh"`
1. Run the script

### Dependencies

- __wget__: if you do not download a wordlist manually, or you want to verify your wordlist against the one provided by EFF
- __OpenSSL__ or __LibreSSL__: if you want to verify your wordlist against the one provided by EFF

## Usage

If you have added an alias:

```
diceware [options]
```

Otherwise, from it's directory:

```
./diceware.sh [options]
```

### Options

- __--length__ (__-l__) __\<number\>__: The number of words in the passphrase (default: 6)
- __--entropy__ (__-e__): Show the entropy of the generated passphrase
- __--delimiter__ (__-d__) __\<string\>__: Delimiter to use between words (default: space)
- __--quiet__ (__-q__): Only print the passphrase
- __--verify__ (__-v__): Verifies if the present wordlist is the one provided by EFF
- __--help__ (__-h__): Print a help message and exit

### Copying to clipboard

If you do not want to expose the generated passphrase, the best option is to pipe diceware into a clipboard manager. Most Linux distros have `xclip`:

```
diceware -l 10 -v -q | xclip -selection c
```

after this command, you can simply Ctrl+V the passphrase to the password field.

The MacOS equivalent is
```
diceware -l 10 -v -q | pbcopy
```

## License

This tool is open-source and distributed under the [MIT License](LICENSE).
