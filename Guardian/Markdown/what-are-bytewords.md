# What is ByteWords?

ByteWords is a method of encoding a sequence of bytes as four-letter English words. It's intended to translate a binary string into human-readable words. Each of the 256 possible sequences of 8 bits (1 byte) is assigned a unique word. Each byte in a binary message is encoded as one of these words, and four more words are added to the end of the sequence to enable error detection.

The 256 ByteWords were chosen according to an extensive set of criteria including: being common, easily pronouncable, non-offensive, generally regarded as positive, memorable, not pronounced like other words in the list, not spelled like other words in the list, and having initial letters that are spread throughout the alphabet. It's also guaranteed that each ByteWord is distinct from all others in that its first three letters are unique, its last three letters are unique, and its first and last letters are unique. These criteria make it unlikely that one ByteWord can accidentally be mistaken for another.

A seed encoded as ByteWords can be easily and accurately transmitted by voice or inscribed on permanent media such as metal. They're also easier to commit to memory than a raw sequence of hexadecimal bytes (but we don't recommend that!).

The sequence of letters in a Uniform Resource (UR) are also ByteWords: since the first and last letters of each ByteWord are guaranteed to be unique, URs just use those two letters to encode each byte.

The [specification for ByteWords](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md), as well as [reference code](https://github.com/BlockchainCommons/bc-bytewords), are open source and available in the Blockchain Commons GitHub repo.
