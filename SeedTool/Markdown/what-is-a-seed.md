# What is a Seed?

A *seed* is a large random number used in cryptography. As the name suggests, seeds are used as the starting point for other things, namely generating useful objects such as keys and cryptocurrency addresses.

## Entropy

To make a seed, you need to start with a good source of random numbers, and you need to use enough of those random numbers to make your seed effectively impossible for anyone else to guess. The best random numbers are found in nature, in things like coin flips, die rolls, or thoroughly shuffled decks of cards. Your source of random numbers is called *entropy*.

Many computer programs that generate random numbers have statistical flaws that make them inappropriate for generating seeds. Cryptography-grade random number generators have no known flaws. **Gordian Seed Tool** can generate a seed for you using cryptography-grade entropy or can generate a seed from entropy you provide.

## Storing Seeds

Having a seed effectively means that you also have everything else that can be generated from it, including your private keys, so seeds must always be kept **secure**.

**Gordian Seed Tool** stores your seeds encrypted on your device. If your device is lost or stolen, your seeds cannot be accessed without your device passcode or biometric authorization. 

Blockchain Commons is committed to open and transparent protocols and code. The entire source code for **Gordian Seed Tool** is available in our [GitHub repo](https://github.com/BlockchainCommons/GordianSeedTool-iOS).
