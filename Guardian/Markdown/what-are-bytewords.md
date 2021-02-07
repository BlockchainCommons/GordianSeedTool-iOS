# What are ByteWords?

ByteWords are a method of encoding a sequence of bytes as four-letter English words. Each of the 256 possible sequences of 8 bits (byte) is assigned a unique word. Each byte in a binary message is encoded as one of these words, and four more words are added to the end of the sequence to enable error detection.

A seed encoded as ByteWords can easily and accurately transmitted by voice, or inscribed on permanent media such as metal. We don't recommend it, but they're also easier to commit to memory than a raw sequence of hexadecimal bytes.

The sequence of letters in a Uniform Resource (UR) are also ByteWords: the first and last letters of each ByteWord are guaranteed to be unique, so URs just use those two letters to encode each byte.

The [specification for ByteWords](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md) as well as [reference code](https://github.com/BlockchainCommons/bc-bytewords) are open source and available in the Blockchain Commons GitHub repo.
