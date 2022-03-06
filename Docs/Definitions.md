# Definitions

_The following defintiopns are only applicable in the context of Gordian Seed Tool. We acknowledge that there's controversy in the space about which term means what means what to whom. However, for the novice learner it's indespensible to have some sort of hand rail to hold on to while climbing the steps of the steep learning curve that proper key management involves._

Words in `this format`, such as `BIP39 `, will not be defined further, but definitions and descriptions are available on the internet.

## Table of Contents

- Definitions:
      - [Account Map](#account-map)
      - [Airgap](#airgap)
      - [Biometric authentication](#biometric-authentication)
      - [Bytewords](#bytewords)
      - [Clipboard](#clipboard)
      - [Concise Binary Object Representation](#concise-binary-object-representation)
      - [Content-addressable hash](#content-addressable-hash)
      - [Controller](#controller)
      - [Cryptocurrency](#cryptocurrency)
      - [Descriptor wallet](#descriptor-wallet)
      - [Entropy](#entropy)
      - [Gordian](#gordian)
      - [Key](#key)
      - [Multi-signature signing](#multi-signature-signing)
      - [Normative](#normative)
      - [Non-normative](#non-normative)
      - [Object Identity Block](#object-identity-block)
      - [Output descriptor](#output-descriptor)
      - [Payload](#payload)
      - [Public Key Infrastructure](#public-key-infrastructure)
      - [QR code](#qr-code)
      - [Seed (key)](#seed--key-)
      - [Sharded Secret Key Reconstruction](#sharded-secret-key-reconstruction)
      - [Torgap](#torgap)
      - [Transfer](#transfer)
      - [Verification keys](#verification-keys)
      - [Wallet](#wallet)
      - [Wallet descriptor](#wallet-descriptor)
      - [xpub](#xpub)

## Abbreviations

`2FA` = Two factor authentication\
CBOR = [Concise Binary Object Representation](#concise-binary-object-representation)\
`DKMI` = Decentralized Key Mangement Infrastructure\
`HSM` = Hardware Security Module\
OIB = [Object Identity Block](#object-identity-block)\
PKI = [Public Key Infrastructure](#public-key-infrastructure)\
`PR` = Pull Request; github terminology\
PSBT = [Partially Signed Bitcoin Transaction](#crypto-pbst)\ 
QR = [Quick Response (code)](#qr-code)\
`RAM` = Random Access Memory\
SSKR = [Sharded Secret Key Reconstruction](#sharded-secret-key-reconstruction)\
`SSSS` = Shamir Secret Sharing Scheme\
`URs` = Uniform Resources\
`UUID` = Universally unique identifier\

## Definitions

### Account Map
A dataset with xpubs, wallet descriptors, and other metadata for fully restoring a multisig account.

### Airgap
A _network security measure_ employed on one or more computers to ensure that a secure computer network is _physically isolated_ from unsecured networks.\
[More  on Wikipedia](https://en.wikipedia.org/wiki/Air_gap_(networking)).

#### Biometric authentication
Body measurements and calculations related to human characteristics. Biometric authentication (or realistic authentication) is used in computer science as a form of identification and access control.\
[More  on Wikipedia](https://en.wikipedia.org/wiki/Biometrics).

#### Bytewords
A format to encode binary data as English words. This Blockchain Commons specification has similar goals as `BIP39` and `SLIP39`, with a few unique characteristics.\
[More in specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md).

#### Clipboard
A buffer that some operating systems provide for short-term storage and transfer within and between application programs. The clipboard is usually temporary and unnamed, and its contents reside in the computer's [RAM](#Abbreviations).\
[More on Wikipedia](https://en.wikipedia.org/wiki/Clipboard_(computing)).

#### Concise Binary Object Representation 
Also CBOR, a binary data serialization format loosely based on `JSON`. Like JSON it allows the transmission of data objects that contain name–value pairs, but in a more concise manner. This increases processing and transfer speeds at the cost of human readability. \
[More on Wikipedia](https://en.wikipedia.org/wiki/CBOR).

#### Content-addressable hash
A way to find data in a network using its content rather than its location. This is done by taking the content of the content and hashing it. For example, you might upload an image to IPFS and retrieve the hash. In the IPFS ecosystem, this hash is called Content Identifier, or CID.

#### Controller
The entity that has the ability to make changes to an _identity_, _cryptocurrency_ or _verifiable credential_. 

The controller of an `autonomous identifier` is the entity (person, organization, or autonomous software) that has the capability, as defined by derivation, to make changes to an `Event Log`. This capability is typically asserted by the control of a single inception key. In DIDs, this is typically asserted by the control of set of cryptographic keys used by software acting on behalf of the controller, though it may also be asserted via other mechanisms. In KERI ,an AID has one single controller. Note that a DID may have more than one controller, and the DID `subject` can be the DID controller, or one of them.

#### Cryptocurrency
A digital asset designed to work as a medium of exchange. In the most common deployments, individual coin ownership records are stored in a digital ledger or computerized database using strong cryptography to secure transaction record entries, to control the creation of additional digital coin records. [More on Wikipedia](https://en.wikipedia.org/wiki/Cryptocurrency).\
Note: Gordian **Seed Tool is not a cryptocurrency wallet**. It neither stores nor transmits value in any cryptocurrency.

#### Crypto-request
A UR with a UUID that requests specific information from the recipient. [More in specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-001-request.md), [More in documentation](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/ur-99-request-response.md).

#### Crypto-response
A UR that responds to a `crypto-request` with the specified information and the same UUID. [More in specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-001-request.md), [More in documentation](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/ur-99-request-response.md).

#### Crypto-pbst
A UR that embeds a PSBT.

#### Descriptor wallet
A wallet that stores output descriptors and uses them to create addresses and sign transactions. By abstracting address creation and transaction signing to a largely standalone module, such wallets can upgrade to using new address types much more easily.\
For most users, the only visible effects will be in wallet import/export. Descriptors will only be shown during exporting, and descriptors should only be handled by the user when they want to import their wallet. Wallets that use descriptors internally shouldn't have any noticeable effect to the user.\
[More on Stackexchange](https://bitcoin.stackexchange.com/questions/99540/what-are-output-descriptors).

#### Entropy
Unpredictable information. Often used as a _secret_ or as input to a _key_ generation algorithm. The term entropy is also used to describe the degree of unpredictability of a message. 

Entropy is measured in bits. The degree or strength of randomness determines how difficult it would be for someone else to reproduce the same large random number. [More in source](https://en.wikipedia.org/wiki/Entropy_(information_theory)).

#### Gordian
Gordian is the umbrella name for open source products, services and technologies from Blockchain Commons that abide by the [Gordian Principles](https://www.blockchaincommons.com/vision.html#principle).\
![](https://github.com/BlockchainCommons/Gordian/blob/master/Images/logos/gordian-overview-screen.png?raw=true)
[More in Gordian repo](https://github.com/BlockchainCommons/Gordian).

#### Key
A mechanism for granting or restricing access to something. MAY be used to issue and prove, MAY be used to control of transfer _identity_ or _cryptocurrency_. \
[More on Wikipedia](https://en.wikipedia.org/wiki/Key_(cryptography)).

#### Multi-signature signing
Also multi-signature or multisig. A digital signature scheme which allows a group of users to jointly sign a transaction or message, each using their own key.\
[More in Wikipedia](https://en.wikipedia.org/wiki/Multisignature).

#### Normative
In general, a theory is “normative” if it, in some sense, tells you what you should do: what action you should take. If it includes a usable procedure for determining the optimal action in a given scenario. [More on Quora](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Non-normative
A theory is non-normative if it does not do that. In general, the purpose of non-normative theories is not to give answers, but rather to describe possibilities or predict what might happen as a result of certain actions.
[More on Quora](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Object Identity Block
Also OIB. A UI technique for making any digital object immediately recognizable to users. Example:\
![](https://github.com/BlockchainCommons/Research/raw/master/papers/bcr-2021-002/oib-1.png)

[More in specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#object-identity-block).

#### Output Descriptor
See [Wallet Descriptor](#wallet-descriptor).

#### Payload
The 'interesting' information in a chunk of data, as opposed to the overhead needed to support it. It is borrowed from transportation, where it refers to the part of the load that 'pays'. For example, a tanker truck may carry 20 tons of oil, but the fully loaded vehicle weighs much more than that: there's the vehicle itself, the driver, fuel, the tank, etc. It costs money to move all these, but the customer only cares about (and pays for) the oil, hence, 'pay-load'. [More on Stackexchange](https://softwareengineering.stackexchange.com/questions/158603/what-does-the-term-payload-mean-in-programming).

#### Public Key Infrastructure
A public key infrastructure (PKI) is a set of roles, policies, hardware, software, and procedures needed to create, manage, distribute, use, store, and revoke digital certificates and manage public-key encryption. [More on Wikipedia].(https://en.wikipedia.org/wiki/Public_key_infrastructure).

#### QR Code
A quick response code: a type of matrix barcode (or two-dimensional barcode) invented in 1994 by a Japanese automotive company. A barcode is a machine-readable `optical label` or identifier that can contain information about the item to which it is attached.\

[More on Wikipedia](https://en.wikipedia.org/wiki/QR_code).

#### Seed
A large random number that provides entropy and is the starting point for other things, such as keys and cryptocurrency addresses.
Gordian Seed Tool supports seeds in a variety of formats, including **mnemonic** seeds, which use the `BIP39` standard word list or Bytewords. `BIP32` master keys are generated from a seed.

#### Sharded Secret Key Reconstruction 
Also SSKR. Allows you to split your seed into pieces and send them to trusted parties, who can send them back to you in an emergency for seed recovery. You can even use an entirely offline device (no internet access) to store your seeds and use [QR codes](#qr-codes) to exchange necessary information with online devices running compatible wallet or signing software.\
[More on github](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/README.md#sharded-secret-key-reconstruction-sskr), [More in Documentation](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/sskr-overview.md).

#### Torgap
A Blockchain Commons security and privacy architecture model for creating gaps between connected apps and microservices. See also [Airgap](#airgap).\
[More in repo](https://github.com/BlockchainCommons/torgap).

#### Transfer
The process of changing the _controller_ of _cryptocurrency_, _identity_ or _verifiable credential_. MAY require the use of a _key_.

#### Verification keys
{TBW}

#### Wallet
Software and sometimes hardware that serves as a key store and provide functionality for those keys. Keys can be private keys or public keys, hashes, or pointers. Functionality can include signatures, invoices (receive), sending, virtual credentials, delegation, etc. \
[More about cryto Wallets](https://cryptocurrencyfacts.com/what-is-a-cryptocurrency-wallet/).

#### Wallet descriptor
An **output descriptor** (note that output descriptor and wallet descriptor refer to the same thing) is a human readable string that represents an output script (a scriptPubKey) and everything needed in order to _solve_ for that script. Descriptors also have a bech32-like checksum which allows for the descriptor to be given to others with less risk of accidentally mistyping or losing some characters in the descriptor string.\
_Solving_ a script means that one would be able to create a final scriptSig/witness with valid signatures if they had a private key. This means that all public keys and other scripts are available.\
Descriptors are unambiguous as to the public keys to use (derivation paths for extended keys are explicit) and the scripts to use. This makes them suitable for importing to other wallets without confusion. In contrast, traditional import mechanisms support only keys with special versioning to indicate the scripts to produce, and don't provide the derivation paths. This creates a situation where a user imports an extended key into a wallet but is unable to see their addresses because that wallet uses a different derivation path than the original wallet. Descriptors avoids this issue entirely by specifying the derivation paths (if any) and the scripts to produce.\
[More on stackexchange](https://bitcoin.stackexchange.com/questions/99540/what-are-output-descriptors).

#### xpub
An extended public key. The foundation of a series of addresses.
