# Definitions

Words in `this make up` will not be defined further, example `BIP39`. Google is your friend to find out what they mean.

## Abbreviations
In alphabetic order:\
`2FA` = Two factor authentication\
CBOR = [Concise Binary Object Representation](#concise-binary-object-representation)\
`DKMI` = Decentralized Key Mangement Infrastructure\
`HSM` = Hardware Security Module\
OIB = [Object Identity Block](#object-identity-block)\
PKI = [Public Key Infrastructure](#public-key-infrastructure)\
`PR` = Pull Request; github terminology\
QR = [Quick response (code)](#qr-code)\
`RAM` = Random Access Memory\
SSKR = [Sharded Secret Key Reconstruction](#sharded-secret-key-reconstruction)\
`SSSS` = Shamir Secret Sharing Scheme\
`URs` = Uniform Resources\

Definitions in alphabetic order:

#### Airgap 
This is a _network security measure_ employed on one or more computers to ensure that a secure computer network is _physically isolated_ from unsecured networks.\
[More in source](https://en.wikipedia.org/wiki/Air_gap_(networking)) on Wikipedia.

#### Biometric authentication
Biometrics are body measurements and calculations related to human characteristics. Biometric authentication (or realistic authentication) is used in computer science as a form of identification and access control.\
[More in source](https://en.wikipedia.org/wiki/Biometrics)

#### Bytewords
Encoding binary data as English words. This Blockchain Commons proposal has similar ends as `BIP39` and `SLIP39`, with a few unique characteristics.\
[More](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md)

#### Clipboard
The clipboard is a buffer that some operating systems provide for short-term storage and transfer within and between application programs. The clipboard is usually temporary and unnamed, and its contents reside in the computer's [RAM](#Abbreviations).\
[More in source](https://en.wikipedia.org/wiki/Clipboard_(computing))

#### Concise Binary Object Representation 
Also CBOR. It is a binary data serialization format loosely based on `JSON`. Like JSON it allows the transmission of data objects that contain name–value pairs, but in a more concise manner. This increases processing and transfer speeds at the cost of human readability. \
[More in source](https://en.wikipedia.org/wiki/CBOR)

#### Content-addressable hash
Content addressing is a way to find data in a network using its content rather than its location. The way we do is by taking the content of the content and hashing it. Try uploading an image to IPFS and get the hash using the below button. In the IPFS ecosystem, this hash is called Content Identifier, or CID.

#### Controller
The entity that has the ability to make changes to an _identity_, _cryptocurrency_ or _verifiable credential_. 

The controller of an `autonomous identifier` is the entity (person, organization, or autonomous software) that has the capability, as defined by derivation, to make changes to an `Event Log`. This capability is typically asserted by the control of a single inception key. In DIDs this is typically asserted by the control of set of cryptographic keys used by software acting on behalf of the controller, though it may also be asserted via other mechanisms. In KERI an AID has one single controller. Note that a DID may have more than one controller, and the DID `subject` can be the DID controller, or one of them.


#### Cryptocurrency
A digital asset designed to work as a medium of exchange wherein individual coin ownership records are stored in a digital ledger or computerized database using strong cryptography to secure transaction record entries, to control the creation of additional digital coin records. See [more in source](https://en.wikipedia.org/wiki/Cryptocurrency).\
Note: Gordian **Seed Tool is not a cryptocurrency wallet**. It neither stores nor transmits value in any cryptocurrency.

#### Entropy
Unpredictable information. Often used as a _secret_ or as input to a _key_ generation algorithm.[More in source](https://en.wikipedia.org/wiki/Entropy_(information_theory))

The term entropy is also used to describe the degree of unpredictability of a message. Entropy is then measured in bits. The degree or strength of randomness determines how difficult it would be for someone else to reproduce the same large random number. This is called _collision resistance_. 

#### Gordian
Gordian is the umbrella name of open source products, services and technologies of Blockchain Commons.\
![](https://github.com/BlockchainCommons/Gordian/blob/master/Images/logos/gordian-overview-screen.png?raw=true)
[More](https://github.com/BlockchainCommons/Gordian)

#### Key
A mechanism for granting or restricing access to something. MAY be used to issue and prove, MAY be used to transfer and control over _identity_ and _cryptocurrency_. \
[More in source](https://en.wikipedia.org/wiki/Key_(cryptography))

#### Multi-signature signing
Multisignature (also multi-signature or multisig) is a digital signature scheme which allows a group of users to sign a single document.\
[More in source](https://en.wikipedia.org/wiki/Multisignature)

#### Normative
In general, we call a theory “normative” if it, in some sense, tells you what you should do - what action you should take. If it includes a usable procedure for determining the optimal action in a given scenario. [Source](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Non-normative
A theory is called non-normative if it does not do that. In general, the purpose of non-normative theories is not to give answers, but rather to describe possibilities or predict what might happen as a result of certain actions.
[Source](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Object Identity Block
Also OIB. It's a UI technique for making any digital object immediately recognizable to users. Example:\
![](https://github.com/BlockchainCommons/Research/raw/master/papers/bcr-2021-002/oib-1.png)

[More](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#object-identity-block)

#### Payload
The term 'payload' is used to distinguish between the 'interesting' information in a chunk of data or similar, and the overhead to support it. It is borrowed from transportation, where it refers to the part of the load that 'pays': for example, a tanker truck may carry 20 tons of oil, but the fully loaded vehicle weighs much more than that - there's the vehicle itself, the driver, fuel, the tank, etc. It costs money to move all these, but the customer only cares about (and pays for) the oil, hence, 'pay-load'. [source](https://softwareengineering.stackexchange.com/questions/158603/what-does-the-term-payload-mean-in-programming).

#### Public Key Infrastructure
A public key infrastructure (PKI) is a set of roles, policies, hardware, software and procedures needed to create, manage, distribute, use, store and revoke digital certificates and manage public-key encryption. [Wikipedia].(https://en.wikipedia.org/wiki/Public_key_infrastructure)

#### QR code
A quick response code is a type of matrix barcode (or two-dimensional barcode) invented in 1994 by a Japanese automotive company. A barcode is a machine-readable `optical label` or identifier that can contain information about the item to which it is attached.\

More on [Wikipedia](https://en.wikipedia.org/wiki/QR_code)

#### Seed (key)
Gordian Seed Tool considers wallets to provide **mnemonic** seeds that use the `BIP39` standard word list and methods for generating the seed. `BIP32` master keys are generated from the seed.

#### Sharded Secret Key Reconstruction 
Also SSKR. SSKR lets you split your seed into pieces and send them to trusted parties, who can send them back to you in an emergency for seed recovery. You can even use an entirely offline device (no internet access) to store your seeds and use [QR codes](#qr-codes) to exchange necessary information with online devices running compatible wallet or signing software.\
[More on github](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/README.md#sharded-secret-key-reconstruction-sskr)\
[More in HackMD](https://hackmd.io/1Oo3Tj6WQmGDOPD--hbyVA?view) by CA.

#### Torgap
Torgap is the Blockchain Commons security and privacy architecture model for creating gaps between connected apps and microservices. See also [Airgap](#airgap).\
[More](https://github.com/BlockchainCommons/torgap)

#### Transfer
The process of changing the _controller_ of _cryptocurrency_, _identity_ or _verifiable credential_. MAY require the use of a _key_.

#### Verification keys
{TBW}

#### Wallet
In our context it is software and sometimes hardware that serves as a key store and functionality. Keys can be private keys and public keys, hashes and pointers. Functionality can be signing, invoices (receive), send, virtual credentials, delegation, etc. \
[More about cryto Wallets](https://cryptocurrencyfacts.com/what-is-a-cryptocurrency-wallet/).