# What is a Cosigner?

A m-of-n multi-sig is a cryptographic lock that can be opened with "m" private keys out of a set of "n". For cryptocurrencies, when funds are sent to a multi-sig address, then "m" out of "n" private keys are required to spend the funds. The most common sorts of multi-sig addresses are 1-of-n (where any one person from a group of two or more can spend funds); 2-of-2 (where both members of a pair must agree to spend funds); and 2-of-3 (where any two members of a group of three can spend funds).

A Cosigner is one of the people (or more generally, one of the keys) that signs a multi-sig transaction. 

## Seed Tool and Cosigner

**Gordian Seed Tool** is built to be used with **Gordian Cosigner**. A cosigner public key can be exported from **Gordian Seed Tool** to create a multi-sig account map in **Gordian Cosigner**, describing a multi-sig. The encrypted data from **Gordian Seed Tool** may then be used to produce signatures required by the multi-sig.

Blockchain Commons is committed to open and transparent protocols and code. The entire source code for [**Gordian Seed Tool**](https://github.com/BlockchainCommons/GordianSeedTool-iOS) and [**Gordian Cosigner**](https://github.com/BlockchainCommons/GordianCosigner-iOS) is available from our [GitHub repos](https://github.com/BlockchainCommons).
