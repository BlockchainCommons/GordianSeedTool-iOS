# What is BIP-39?

BIP-39 is Bitcoin’s traditional [mnemonic word specification](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), which translates seeds into words and vice versa. It allows for the encoding of a seed in human-readable form, and has traditionally been used as a back-up mechanism, with the words often being stamped in metal for best survivability.

BIP-39 mnemonic words are supported by Gordian Seed Tool primarily for interoperability, allowing you to import a seed using BIP-39 words or to share a seed using those words. It allows for interaction with older wallets that do not support the Blockchain Commons specifications. For newer wallets, instead use ByteWords, which were designed to be easier to remember and harder to confuse, and which integrate with Blockchain Commons’ Uniform Resources.
