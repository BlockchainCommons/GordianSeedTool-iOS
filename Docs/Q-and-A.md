# Q&A about Gordian Seed Tool

## Introduction

<img src="../images//gg-list.jpg" alt="Gordian Seed Tool" border="0" width="300">

This document refers to a common list of [Definitions](./Definitions.md).

Why should you read or step through the Q&A? To get a different angle to the same topic: Gordian Seed Tool.

**The questions are of a varied level: basic and detailed. The answers are mostly directed towards generally interested people and newbies.**\
*Q = one star question. Novice to Gordian Seed Tool, advanced in public private key (PKI)\
**Q = two star question. Proficient in PKI and advanced in Gordian Seed Tool\
***Q = three star question. Expert in PKI and proficient in Gordian Seed Tool

```text
{TBW} means: to be written
{TBW prio 1} means to be written with the highest priority, 3 = no urgency, 2 = intermediate}
```

- [Q&A about Gordian Seed Tool](#qa-about-gordian-seed-tool)
  - [Disclaimer](#disclaimer)
  - [List of questions and definitions](#list-of-questions-and-definitions)
  - [Knowledge you should be confidently applying](#knowledge-you-should-be-confidently-applying)
  - [Actions you should be comfortable with](#actions-you-should-be-comfortable-with)
- [Jump table to categories](#jump-table-to-categories)

**Beware: A Q&A is always *work in progress*. Tips & help welcome**

## Disclaimer

There are no references added to the answers. We think it's unnecessary to disclose who answered the question. We'll seek confirmation of the given answers by peer review. Most of the editing is done by Henk van Cann, which might have introduced ommission, errors, language glitches and such. Sorry for that, feel free to correct by submitting a pull request (PR).\
For practical reasons educational images uploaded by Github members have been downloaded. We de-personalised them by giving images a new name. Under these new names these images have been uploaded to github and used in the Q&A to clarify the questions and answers.

Gordian Seed Tool's content is licensed under the [CC by SA 4.0. license](https://creativecommons.org/licenses/by-sa/4.0/). 

We've done our best to protect the privacy of the Github by investigating the images we used. We haven't come across personal identifiable information (pii). However, should we have made a mistake after all, please let us know and we'll correct this immediately.

### List of questions and definitions

_Please note that our definitions are only applicable in the context of Gordian Seed Tool and within the Blockchaincommons domain. We acknowledge that there's some controversion in the space about which term means what means what to who. However, for the novice learner it's indespensible to have some sort of hand rail to hold on to while climbing the steps of the steep learning curve that proper key management involves._

- [Definitions:](#definitions)
      - [Account Map](./Definitions#account-map)
      - [Airgap](./Definitions#airgap)
      - [Biometric authentication](./Definitions#biometric-authentication)
      - [Bytewords](./Definitions#bytewords)
      - [Clipboard](./Definitions#clipboard)
      - [Concise Binary Object Representation](./Definitions#concise-binary-object-representation)
      - [Content-addressable hash](./Definitions#content-addressable-hash)
      - [Controller](./Definitions#controller)
      - [Cryptocurrency](./Definitions#cryptocurrency)
      - [Descriptor wallet](./Definitions#descriptor-wallet)
      - [Entropy](./Definitions#entropy)
      - [Gordian](./Definitions#gordian)
      - [Key](./Definitions#key)
      - [Multi-signature signing](./Definitions#multi-signature-signing)
      - [Normative](./Definitions#normative)
      - [Non-normative](./Definitions#non-normative)
      - [Object Identity Block](./Definitions#object-identity-block)
      - [Output descriptor](./Definitions#output-descriptor)
      - [Payload](./Definitions#payload)
      - [Public Key Infrastructure](./Definitions#public-key-infrastructure)
      - [QR code](./Definitions#qr-code)
      - [Seed (key)](./Definitions#seed--key-)
      - [Sharded Secret Key Reconstruction](./Definitions#sharded-secret-key-reconstruction)
      - [Torgap](./Definitions#torgap)
      - [Transfer](./Definitions#transfer)
      - [Verification keys](./Definitions#verification-keys)
      - [Wallet](./Definitions#wallet)
      - [Wallet descriptor](./Definitions#wallet-descriptor)
      - [xpub](./Definitions#xpub)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Preparation

### Knowledge you should be confidently applying

- The definitions in the [glossary](./Definitions.md)
- Public private key pairs
- Hashing and hashes
- Signatures and Seeds

### Actions you should be comfortable with

- Amend knowledge and keep existing knowledge up to date
- create a key pair safely and back it up safely
- sweep to a new wallet

## Jump table to categories

- [General](#qa-section-general)
- [Gordian Seed Tool](#qa-gordian-seed-tool)
- [Schemes](#qa-section-schemes)
- [Wallets](#qa-section-wallets)
- [Private Key Management](#qa-section-private-key-management)
- [Security](#qa-section-security)
- [Gordian Seed Tool operational](#qa-section-gordian-seed-tool-operational)

## Q&A section General

### *Q: What is Gordian?
A set of open source products and services of [BlockchainCommons](https://www.blockchaincommons.com). They come based on a set of strong and innovative [principles](https://github.com/BlockchainCommons/Gordian#gordian-principles).
The name is a [symbol](https://en.wikipedia.org/wiki/Gordian_Knot) for untying a seemingly impossibly tangled knot.
[More](https://github.com/BlockchainCommons/Gordian)

### *Q: Why Gordian?
[Background](https://github.com/BlockchainCommons/Gordian/blob/master/Docs/Why-Gordian.md#why-gordian)

### *Q: What is Gordian Seed Tool?
Gordian Seed Tool protects your cryptographic seeds while also making them available for easy use. Using Seed Tool, you can generate seeds and store them securely on your device. You can then derive and share multi-signature signing and verification keys from those seeds.\
[More info](https://github.com/BlockchainCommons/GordianSeedTool-iOS) on the github homepage.

### *Q: What is GordianGuardian?
The old name for the Gordian Seed Tool, it's a synonym.

### *Q: Where has QR vault gone?
This is now called QR Tool! "QR Vault" is legacy and a synonym for QR Tool.

<!--CA -->**Gordian Seed Tool and Gordian QR Tool are distinctive and separate**. Gordian QR Tool just stores QRs to iCloud.  That those QRs can include things like Covid credentials, SSKR shares, and 2FA details we offer a more secure place to save them than your camera roll.

### *Q: In what kind of tooling landscape is Seed Tool sitting?

<img src="https://raw.githubusercontent.com/BlockchainCommons/Gordian/master/Images/appmap.png" alt="Gordian App Map" border="0" width="600"> 

More on the Gordian App Map [here](https://github.com/BlockchainCommons/Gordian#overview-gordian-app-map).

### **Q: Is there crypto-request for Output Descriptors or Account Descriptors as well?
We haven't defined them yet (<!--WM -->December 2021).

<!-- <img src="../images/xxxx.png" alt="xxxx" border="0" width="600">   -->

### For who is Gordian Seed Tool?

### WHy should I use Gordian Seed Tool?
 Because storing your seeds in the unecrypted RAM of a fully networked device is a major security vulnerability and also leaves your seeds vulnerable to loss. It's both a Single Point of Compromise and a Single Point of Failure. Seed Tool resolves both of these problems.\
[More in the manual](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#gordian-seed-tool-manual-v13-41)

### When should I use Gordian Seed Tool?

## Q&A section Gordian Seed Tool operational

### *Q: On which platforms is Gordian Seed Tool available 
Gordian Seed Tool is available for iOS and Mac 1.3 (December 2021, HC)

### *Q: Why do I need to use iCloud?
It'd not strictly needed, it's recommended, because if activated, **Seed Tool** can use automated iCloud backup and recovery.

### Does Gordian Seed Tool run on a Mac?
<!--WM -->It runs on the Mac as an iPad app, not Mac native.

### **Q: What is the 'primary asset' switch for?
"Primary Asset" switch can be changed between Bitcoin and Ethereum. When Ethereum is selected, the following changes apply<!--WM -->: 
1. In the Seed Detail view, the green "Cosigner Public Key" changes to "Ethereum Address" for quick export of the Ethereum Address derived from the seed. 
2. After clicking "Authenticate," the "Derive Key" popup has an item that changes from "Cosigner Private Key" to "Ethereum Private Key." 
3. In the "Other Key Derivations" view, the default derivation path for Ethereum is now `44'/60'/0'/0/0` which is compatible with many existing wallets. 
4. The bottom of the "Other Key Derivations" view now contains an "Address" box for exporting the Bitcoin or Ethereum address. 
5. In the "Other Key Derivations" view, when deriving Ethereum, a new "Private Key" box appears that can be used to export the Ethereum private key. When printed, this page also includes the Ethereum address. 
6. All visual hashes (identicons) associated with Ethereum keys or addresses now use "Blockies", which is widely recognized in the Ethereum world, instead of the usual LifeHash algorithm.

### **Q: I get confused by a _seed request_ on one device. Could you explain more?

<!--WM -->I'm not sure how to make this clearer. Typically "another device" **will note** be this device. If the requested seed is not already on the device, it obviously can't send it, and will tell you so. It also makes clear the consequences of sending the seed (via the QR Code) to another device.\
The request URs available [in the test PDFs](https://github.com/BlockchainCommons/GordianGuardian-iOS/tree/master/Testing) are so, you can test a UR similar to what another device would show when requesting a seed from this device.\
_In reference to github [issue 40](https://github.com/BlockchainCommons/GordianGuardian-iOS/issues/40)_

### *Q: What is the vision behind the Seed Tool?
Gordian Seed Tool demonstrates the Gordian principles. It allows you maintain control of your own key material (independence), stores them on your closely held mobile device (privacy), protects them with 2FA and biometrics (resilience), and communicates via QRs and URs (openness).\
[Info straight from the app](../SeedTool/Markdown/about-seed-tool.md)
### **Q: Under what license has Gordian Seed Tool been released?
The use of Gordian Seed Tool is under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).\
[More info straight from the app](../SeedTool/Markdown/license-and-disclaimer.md)
### *Q:What are bytewords
ByteWords is a method (invented at BlockchainCommons) of encoding a sequence of bytes as four-letter English words. It's intended to translate a binary string into human-readable words.\
[More info straight from the app](../SeedTool/Markdown/what-are-bytewords.md)
### *Q:What is a cosigner
A Cosigner is one of the people (or more generally, one of the keys) that signs a multi-sig transaction.\
Gordian Seed Tool is built to be used with [Gordian Cosigner](https://github.com/BlockchainCommons/Gordian#spotlight-gordian-cosigner-on-android-macos-or-ios).\
[More info straight from the app](../SeedTool/Markdown/what-is-a-cosigner.md)

## Q&A Schemes

### *Q: What is a lifehash?
A LifeHash is a small picture that helps you recognize [seeds](#what-is-a-seed) and other digitial objects at a glance.\
[More info straight from the app](../SeedTool/Markdown/what-is-a-lifehash.md)
### *Q: What is a Seed?
A seed is a large random number used in cryptography.\
[More info straight from the app](../SeedTool/Markdown/what-is-a-seed.md)
### *Q: What is a UR?
A "Uniform Resource" or UR, is a way of encoding binary data in a format that is suitable for transmission as plain text or inside a QR code. URs are a type of Uniform Resource Identifier (URI) and look similar to the web http: URL addresses you're familiar with. Unlike a web address, which points to a resource on the Internet, a UR is itself a complete resource.\
[More info straight from the app](../SeedTool/Markdown/what-is-a-ur.md)
### *Q: Wat is BIP39?
BIP-39 is Bitcoin’s traditional mnemonic word specification, which translates seeds into words and vice versa. It allows for the encoding of a seed in human-readable form, and has traditionally been used as a back-up mechanism, with the words often being stamped in metal for best survivability.\
[More info straight from the app](../SeedTool/Markdown/what-is-bip-39.md)
### *Q: What is key derivation?
The core idea of [seeds](#what-is-a-seed) is that they can be used to create (derive) a whole hierarchy of keys based on the BIP-32 specification for a Hierarchical Deterministic (HD) wallet. One seed leads to many keys (and thus many addresses).\
To derive a key requires a derivation path. This describes which precise key you're talking about of the infinite keys that could be derived from a specific seed. \
[More info straight from the app](../SeedTool/Markdown/what-is-key-derivation.md)

### *Q: What is SSKR?
Sharded Secret Key Reconstruction (SSKR) is a method of taking a secret (like a [seed](#what-is-a-seed)) and breaking it up into pieces called `shards`.\
[More info straight from the app](../SeedTool/Markdown/what-is-sskr.md)

### **Q: Is SSKR a rebrand of SSSS, Shamir Secret Sharing scheme?
<!--WM -->Under the hood SSKR is using the technique of Shamir's Secret Sharing (SSS) but SSKR is a particular packaging of that technique optimized for `CBOR` and `UR`s.
<img src="https://i.imgur.com/SYpP0sK.png" alt="" border="0" width="300" align="right">

_In reference to github [issue 37](https://github.com/BlockchainCommons/GordianGuardian-iOS/issues/37)_

## Q&A Security

### *Q: Why do I need 2FA?
Once protected via 2FA, you must login in to your Apple account, then you must verify whenever you access private data.

### **Q: What is the most secure way to create a new seed from scratch?
Using coin flips, die rolls, or playing cards. But you must properly flip every coin, roll every die, or draw every card, no matter how tedious it is.\
[More in the manual](https://github.com/henkvancann/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#creating-a-seed)

### **Q: What is the least secure way to create a new seed from scratch?
Quick Create. It depends on your mobile device's randomization to create a seed. If there is ever an exploit revealed, you'll be forced to sweep all of your funds.\
[More in the manual](https://github.com/henkvancann/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#creating-a-seed)

### ***Q: Which algorithms have been used to create entropy for creating seeds?
_Quick Create_ depends on your mobile device's randomization to create a seed.\
_Coin_ (binary) and _Die_ entropy in Gordian Seed Tool matches that of [Ian Coleman's BIP-39 Mnemonic Code Converter](https://iancoleman.io/bip39/).\
Card drawing entropy is generated by {TBW1}

### *Q: I can import the same seed twice
*I can't think of a reason why I would want to import the same seed twice.*
<!--WM -->`ur:crypto-seed` contains metadata like name and notes that can be different. It's up to the user to reconcile these differences.
<img src="https://i.imgur.com/y7QwKOI.png" alt="" border="0" width="300" align="right">

_In reference to github [issue 41](https://github.com/BlockchainCommons/GordianGuardian-iOS/issues/41)_

### *Q: Why it is recommended to delete all data from the device before deleting the app?
<!--WM -->{TBW1}
<img src="https://i.imgur.com/QuQ9EZB.png" alt="" border="0" width="300" align="right">

_In reference to github [issue 36](https://github.com/BlockchainCommons/GordianGuardian-iOS/issues/36)_

### *Q: I swiped to delete a seed, now the settings cog asks me to delete ALL seeds??
*If as a user 'I don't know that I have to right-left swipe' to delete a rendundant seed, then clicking on the seed and as natural flow, I choose the cog, I might go forward and delete everything, instead of trying to get rid of just one seed.*

| Swipe left | Click on |
| -------- | -------- |
| <img src="https://i.imgur.com/3knEgl3.png" alt="" border="0" width="300"> |<img src="https://i.imgur.com/hqilJcJ.png" alt="" border="0" width="300" align="right">|
_In reference to github [issue 42](https://github.com/BlockchainCommons/GordianGuardian-iOS/issues/42)_

**You don't have to swipe on a seed to delete it**. Just tap the Edit button and then tap one of the Delete buttons that appear. This is iOS-standard behavior. Swipe-to-delete is a shortcut. Later when we have more settings the "Danger Zone" box will get pushed down further. 
> The warning message has been clarified to: "All data will be erased from the app, including ALL seeds stored in the device keychain. This is recommended before deleting the app from your device, because deleting an app does not guarantee deletion of all data added to the keychain by that app."

### *Q: Copy paste of a BIP39 seed is a good idea?
There are security issues related to copy-pasting when your computer has been compromised. On the other hand it's easy and less error prone to copy and paste. It's your choice. You can also type in the 24 word seed.

### **Q: To which formats can I export my GST keys?
Key Export: Master keys derived from seeds can now be exported to Output Descriptors (`crypto-output`) or Account Descriptors (`crypto-account`). <!--WM -->

### **Q: How can I export my GST keys?
To see this new feature:
1. choose a seed from the Seed List
2. In the Encrypted Data section, tap Authenticate
3. Tap Derive Key and then Other Key Derivations
4. In the Parameters area, make sure Bitcoin and Master Key are selected
5. Scroll down to the Secondary Derivation section and choose Output Descriptor or Account Descriptor
6. Choose Output Descriptor or Account Descriptor, and edit the Account Number field if desired
7. If you chose Output Descriptor, then choose an Output Type
8. Scroll down to the bottom to export your Output Descriptor or Account Descriptor.

Output Descriptors may be exported as text format or `ur:crypto-output` format. Account Descriptors may be exported in `ur:crypto-account` format.<!--WM -->

## Wallet

### *Q Can I store my bitcoin and ethereum in Gordian Seed Tool?
No, Gordian **Seed Tool is not a cryptocurrency wallet**. It neither stores nor transmits value in any cryptocurrency.\
What it is and what it does, see Gordian Seed Tool's [Github homepage](https://github.com/BlockchainCommons/GordianSeedTool-iOS).