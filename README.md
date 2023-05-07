# Gordian Seed Tool

## Gordian Seed Tool Cryptographic Seed Manager for iOS

### _by [Wolf McNally](https://www.github.com/wolfmcnally) and [Christopher Allen](https://www.github.com/ChristopherA)_
* <img src="https://github.com/BlockchainCommons/Gordian/blob/master/Images/logos/gordian-icon.png" width=16 valign="bottom"> ***part of the [gordian](https://github.com/BlockchainCommons/gordian/blob/master/README.md) technology family***

**Gordian Seed Tool** protects your cryptographic seeds while also making them available for easy use. Using Seed Tool, you can generate seeds and store them securely on your device. You can then derive and share multi-signature signing and verification keys from those seeds. Sophisticated backup procedures include printed pages and Sharded Secret Key Reconstruction ([SSKR](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/README.md#sharded-secret-key-reconstruction-sskr)) — which lets you split your seed into pieces and send them to trusted parties, who can send them back to you in an emergency for seed recovery. You can even use an entirely offline device (no internet access) to store your seeds and use QR codes to exchange necessary information with online devices running compatible wallet or signing software.

![](images/logos/gordian-seedtool-screen.jpg)

<img src="images/gg-list.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-addseed.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-adddie.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-seed.jpg" width=200 align="center">

## Demos (Videos)

* **[Seed Tool & SSKR](https://www.youtube.com/watch?v=aciTNh402Co)**

## Installation Instructions

**Gordian Seed Tool** is available from the [Apple Appstore for the iPhone](https://apps.apple.com/us/app/gordian-seed-tool/id1545088229), or can be compiled from source here.

To compile from source, simply choose "Code > Open with Xcode" from the top of the repo. This will download the code into Xcode, including all of the dependencies. After you will be able to _Run_ (command-R) it for your Mac or a connected iOS device.

## Usage Instructions

* [**Manual**](Docs/MANUAL.md). An overview of installing and using **Seed Tool**, including info on adding seeds, storing seeds, using seeds, exporting seeds, and removing seeds.
* [**Integrating Seed Tool with Other Apps**](Docs/Integration.md). Using **Seed Tool** as a real-life seedstore for live transactions coordinated by other apps.
  
## Gordian Principles

**Gordian Seed Tool** is a reference implementation meant to display the [Gordian Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles), which are philosophical and technical underpinnings to Blockchain Commons' Gordian technology. This includes:

* **Independence.** Seed Tool allows you to maintain personal control of your cryptographic key material.
* **Privacy.** Seed Tool ensures your privacy because everything is on your closely held mobile device.
* **Resilience.** Seed Tool uses 2FA by combining an Apple login with biometric authentication. It securely backs up your material to iCloud.
* **Openness.** Seed Tool communicates through airgaps via URs and QRs, for maximum interoperability.

Blockchain Commons apps do not phone home and do not run ads. Some are available through various app stores; all are available in our code repositories for your usage.

_For related Threat Modeling, see the [Seed Tool Manual](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/shannona-minimanual/Docs/MANUAL.md#appendix-i-threat-modeling)._

# Status - Released (1.5)

**Gordian Seed Tool** has been released through the [Apple Appstore](https://apps.apple.com/us/app/gordian-seed-tool/id1545088229).

## Version History

[Join the Test Flight Open Beta](https://testflight.apple.com/join/0LIl6H1h)

### 1.6 (66)

* Fixed bug with CBOR serialization of master private keys and the public "master" keys directly derived from them (Issue #182).
* Clarified documentation (BCR-2020-007) for how we're representing pair-components in output descriptors (Issue #183).

### 1.6 (65)

Interim release.

### 1.6 (64)

Interim release (iOS only).

### 1.6 (63)

Interim release.

### 1.6 (62)

* Envelope format has changed, so the app has been updated to use the latest format for requests and responses.

### 1.6 (61)

* Requests and responses are now all based on the Envelope type.

### 1.6 (60)

* Now responds to crypto-request for an output descriptor. This will allow the upcoming Gordian Coordinator or other wallet apps to securely request an output descriptor for use in online wallets.
* Numerous other small changes and improvements throughout the app.
* A lot of code has been moved to where it can be shared between all Gordian apps, particularly the upcoming Gordian Coordinator. As such, this should be considered an *early* beta and all functionality should be thoroughly re-tested.

### Summary of changes in version 1.5 (May 11, 2022)

#### NFC Improvements (Experimental!)

* [Write crypto-seeds to NFC Tags](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#exporting-a-seed).
* [Write crypto-hdkeys to NFC Tags](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#deriving-a-key).
* [Write crypto-requests to NFC Tags (developers only)](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#viewing-developer-functions).
* [Read crypto-requests from NFC Tags](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#answering-seed--key-requests).
* [Write crypto-responses to NFC Tags](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#answering-seed--key-requests).

#### SSKR Improvements

* [Write individual SSKR shares to NFC Tags](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#exporting-the-shares).
* [Print individual SSKR shares](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#exporting-the-shares).
* [Save individual SSKR shares as PDFs (using printing)](https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Docs/MANUAL.md#exporting-the-shares).

General bug fixes and improvements.

### Summary of changes in version 1.4 (April 6, 2022)

#### I/O Improvements

* NFC Import: Allows import from NFC Tags.
* UR Import: Imports and processes "ur:" scheme strings.
* Clipboard Erasure: Erases clipboard in 1 minute when used for export (iOS only).
* File Saving: Exports to files, including MicroSDs and iCloud.
* SSKR Split: Allows individual export of SSKR shares, such as to different MicroSD cards.

#### New Data Details

* Descriptor Checksums: All output descriptors now include their checksum.
* Seed Fingerprints: All seed OIBs now display the fingerprint for their master HD key.
* Request Details: All crypto-requests now show notes and known key derivations.

#### Other Updates & Fixes

* Seed Request Fix: Parses crypto-requests for seeds using the latest spec.
* Other: Various UX improvements, interface standardizations, and small bug fixes.

### 1.4 (56)

* Fixed crash on Mac when exporting keys.

### 1.4 (55)

* #152 In the Seed Detail screen, the "Randomize" and "Clear Field" buttons that appear in the Seed Name field when editing it have been replaced with a menu button that includes "Randomize" and "Clear" commands, that only appears when the field is *not* being edited. This is to reduce the chance of the user accidentally changing the field.
* #114 When responding to a request for a key derivation that asks the user to select a seed, the pre-seed selection screen now shows information about the derivation path, as well as any note included with the request. This is in addition to showing this information on the request approval screen.
* The parsing for requests and responses was using an outdated format. The seed requests and responses now conform to the latest spec. The Seed Request QR in the Testing folder in the repo has also been updated.
* A crash at startup was observed when the most recent builds are run on an iPod Touch running iOS 15.3.1. Based on crash logs, I determined that this is because the CoreNFC framework is missing on the iPod Touch, causing a dynamic link failure at startup. This issue has been [reported by other developers](http://www.openradar.me/FB9836080) and according to this report an iPod Touch running iOS 15.1 does not crash. As I do not have an iPod Touch to test on, the only thing I was able to do in the next build was to set the CoreNFC framework to "weak link." This may avoid the immediate crash at startup, but the app may still crash in places where it attempts to call into CoreNFC. Further crash logs for this build need to be examined to see whether anything further can be done about this. 

### 1.4 (54)

* Seed Tool now shows any associated note attached to requests for seeds or keys. It displays the note text in a distinctive style and warns the user to be careful about whether to trust what the note contains. To facilitate testing this, the "Show Example Request..." functions now include a dummy note.
* #114 When responding to Key Requests, Seed Tool now shows the requested derivation path's known name, if it corresponds to one, or a warning if it does not.
* #143 When long-pressing on the various parts of an Object Identity Block (OIB), and then choosing the Save to Files... option, suggested filenames are now consistent with the identified subject as well as the selected field of the OIB (LifeHash, Identifier, Detail, and Name). All suggested filenames for objects derived from seeds (such as HDKeys and Addresses) now start with the Seed Digest Identifier first and then the Digest Identifier of the derived object. 
* #145 Added checksums to all Output Descriptors exported as text, as well as the filenames used with Save to File for descriptors.
* #147 Fixed crash when Scan view is invoked with camera permissions revoked in Settings > Privacy > Camera > Seed Tool.
* #148 Fixed so all Key Export views have the same export options, including Base58.

See [Version History](VERSIONS.md) for previous builds.

## Origin, Authors, Copyright & Licenses

Unless otherwise noted (either in this [/README.md](./README.md) or in the file's header comments) the contents of this repository are Copyright © 2020 by Blockchain Commons, LLC, and are [licensed](./LICENSE) under the [spdx:BSD-2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

In most cases, the authors, copyright, and license for each file reside in header comments in the source code. When it does not, we have attempted to attribute it accurately in the table below.

This table below also establishes provenance (repository of origin, permalink, and commit id) for files included from repositories that are outside of this repo. Contributors to these files are listed in the commit history for each repository, first with changes found in the commit history of this repo, then in changes in the commit history of their repo of their origin.

| File      | From                                                         | Commit                                                       | Authors & Copyright (c)                                | License                                                     |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------ | ----------------------------------------------------------- |
| exception-to-the-rule.c or exception-folder | [https://github.com/community/repo-name/PERMALINK](https://github.com/community/repo-name/PERMALINK) | [https://github.com/community/repo-name/commit/COMMITHASH]() | 2020 Exception Author  | [MIT](https://spdx.org/licenses/MIT)                        |

### Dependencies

To build  `Gordian Seed Tool` you'll need to use the following tools:

- Xtools with Swift (or another Swift compiler)

### Derived from....

`Gordian Seed Tool` incorporates:
 * [BCLibsSwift](https://github.com/BlockchainCommons/BCLibsSwift) and thus a variety of [crypto commons](https://github.com/BlockchainCommons/crypto-commons/blob/master/README.md) libraries.

### Related to...

Blockchain Commons has two other seedtools:

* [LetheKit](https://github.com/BlockchainCommons/bc-lethekit) — Our DIY hardware project contains a seedtool.
* [seedtool-cli](https://github.com/BlockchainCommons/bc-seedtool-cli) — A command-line version of seedtool.

We also have other related projects:

* [keytool-cli](https://github.com/BlockchainCommons/keytool-cli) — A command-line tool for a wide variety of key derivations.

## Financial Support

`Gordian Seed Tool` is a project of [Blockchain Commons](https://www.blockchaincommons.com/). We are proudly a "not-for-profit" social benefit corporation committed to open source & open development. Our work is funded entirely by donations and collaborative partnerships with people like you. Every contribution will be spent on building open tools, technologies, and techniques that sustain and advance blockchain and internet security infrastructure and promote an open web.

To financially support further development of `Gordian Seed Tool` and other projects, please consider becoming a Patron of Blockchain Commons through ongoing monthly patronage as a [GitHub Sponsor](https://github.com/sponsors/BlockchainCommons). You can also support Blockchain Commons with bitcoins at our [BTCPay Server](https://btcpay.blockchaincommons.com/).

## Contributing

We encourage public contributions through issues and pull requests! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our development process. All contributions to this repository require a GPG signed [Contributor License Agreement](./CLA.md).

### Discussions

The best place to talk about Blockchain Commons and its projects is in our GitHub Discussions areas.

[**Gordian Developer Community**](https://github.com/BlockchainCommons/Gordian-Developer-Community/discussions). For standards and open-source developers who want to talk about interoperable wallet specifications, please use the Discussions area of the [Gordian Developer Community repo](https://github.com/BlockchainCommons/Gordian-Developer-Community/discussions). This is where you talk about Gordian specifications such as [Gordian Envelope](https://github.com/BlockchainCommons/Gordian/tree/master/Envelope#articles), [bc-shamir](https://github.com/BlockchainCommons/bc-shamir), [Sharded Secret Key Reconstruction](https://github.com/BlockchainCommons/bc-sskr), and [bc-ur](https://github.com/BlockchainCommons/bc-ur) as well as the larger [Gordian Architecture](https://github.com/BlockchainCommons/Gordian/blob/master/Docs/Overview-Architecture.md), its [Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles) of independence, privacy, resilience, and openness, and its macro-architectural ideas such as functional partition (including airgapping, the original name of this community).

[**Gordian User Community**](https://github.com/BlockchainCommons/Gordian/discussions). For users of the Gordian reference apps, including [Gordian Coordinator](https://github.com/BlockchainCommons/iOS-GordianCoordinator), [Gordian Seed Tool](https://github.com/BlockchainCommons/GordianSeedTool-iOS), [Gordian Server](https://github.com/BlockchainCommons/GordianServer-macOS), [Gordian Wallet](https://github.com/BlockchainCommons/GordianWallet-iOS), and [SpotBit](https://github.com/BlockchainCommons/spotbit) as well as our whole series of [CLI apps](https://github.com/BlockchainCommons/Gordian/blob/master/Docs/Overview-Apps.md#cli-apps). This is a place to talk about bug reports and feature requests as well as to explore how our reference apps embody the [Gordian Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles).

[**Blockchain Commons Discussions**](https://github.com/BlockchainCommons/Community/discussions). For developers, interns, and patrons of Blockchain Commons, please use the discussions area of the [Community repo](https://github.com/BlockchainCommons/Community) to talk about general Blockchain Commons issues, the intern program, or topics other than those covered by the [Gordian Developer Community](https://github.com/BlockchainCommons/Gordian-Developer-Community/discussions) or the 
[Gordian User Community](https://github.com/BlockchainCommons/Gordian/discussions).

### Other Questions & Problems

As an open-source, open-development community, Blockchain Commons does not have the resources to provide direct support of our projects. Please consider the discussions area as a locale where you might get answers to questions. Alternatively, please use this repository's [issues](./issues) feature. Unfortunately, we can not make any promises on response time.

If your company requires support to use our projects, please feel free to contact us directly about options. We may be able to offer you a contract for support from one of our contributors, or we might be able to point you to another entity who can offer the contractual support that you need.

### Credits

The following people directly contributed to this repository. You can add your name here by getting involved. The first step is learning how to contribute from our [CONTRIBUTING.md](./CONTRIBUTING.md) documentation.

| Name              | Role                | Github                                            | Email                                 | GPG Fingerprint                                    |
| ----------------- | ------------------- | ------------------------------------------------- | ------------------------------------- | -------------------------------------------------- |
| Christopher Allen | Principal Architect | [@ChristopherA](https://github.com/ChristopherA) | \<ChristopherA@LifeWithAlacrity.com\> | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |
| Wolf McNally      | Project Lead        | [@WolfMcNally](https://github.com/wolfmcnally)    | \<Wolf@WolfMcNally.com\>              | 9436 52EE 3844 1760 C3DC  3536 4B6C 2FCF 8947 80AE |

## Responsible Disclosure

We want to keep all of our software safe for everyone. If you have discovered a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner. We are unfortunately not able to offer bug bounties at this time.

We do ask that you offer us good faith and use best efforts not to leak information or harm any user, their data, or our developer community. Please give us a reasonable amount of time to fix the issue before you publish it. Do not defraud our users or us in the process of discovery. We promise not to bring legal action against researchers who point out a problem provided they do their best to follow the these guidelines.

### Reporting a Vulnerability

Please report suspected security vulnerabilities in private via email to ChristopherA@BlockchainCommons.com (do not use this email for support). Please do NOT create publicly viewable issues for suspected security vulnerabilities.

The following keys may be used to communicate sensitive information to developers:

| Name              | Fingerprint                                        |
| ----------------- | -------------------------------------------------- |
| Christopher Allen | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |

You can import a key by running the following command with that individual’s fingerprint: `gpg --recv-keys "<fingerprint>"` Ensure that you put quotes around fingerprints that contain spaces.
