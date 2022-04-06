# Gordian Seed Tool

## Gordian Seed Tool Cryptographic Seed Manager for iOS

### _by [Wolf McNally](https://www.github.com/wolfmcnally) and [Christopher Allen](https://www.github.com/ChristopherA)_
* <img src="https://github.com/BlockchainCommons/Gordian/blob/master/Images/logos/gordian-icon.png" width=16 valign="bottom"> ***part of the [gordian](https://github.com/BlockchainCommons/gordian/blob/master/README.md) technology family***

**Gordian Seed Tool** protects your cryptographic seeds while also making them available for easy use. Using Seed Tool, you can generate seeds and store them securely on your device. You can then derive and share multi-signature signing and verification keys from those seeds. Sophisticated backup procedures include printed pages and Sharded Secret Key Reconstruction ([SSKR](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/README.md#sharded-secret-key-reconstruction-sskr)) — which lets you split your seed into pieces and send them to trusted parties, who can send them back to you in an emergency for seed recovery. You can even use an entirely offline device (no internet access) to store your seeds and use QR codes to exchange necessary information with online devices running compatible wallet or signing software.

![](images/logos/gordian-seedtool-screen.jpg)

<img src="images/gg-list.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-addseed.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-adddie.jpg" width=200 align="center">&nbsp;&nbsp;<img src="images/gg-seed.jpg" width=200 align="center">

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

# Status - Released (1.4)

**Gordian Seed Tool** has been released through the [Apple Appstore](https://apps.apple.com/us/app/gordian-seed-tool/id1545088229).

## Version History

[Join the Test Flight Open Beta](https://testflight.apple.com/join/0LIl6H1h)

### Summary of changes in version 1.4

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

### 1.3.3 (53)

* All Object Identity Blocks for Seeds now display the seed's master HD key fingerprint. It is 8 hex digits surrounded by square brackets: [1234abcd].
* When printing an SSKR backup, you now have the option to print the seed's Notes field on the SSKR summary page.
* Fixed an issue where sharing a string like an SSKR share to Messages resulted in a file containing the string being shared, instead of bare string.
* #142 In Key Export, the list of Output Descriptors now includes a human-readable name for each descriptor type. When exporting the filename used when exporting output descriptors now includes a subtype of `[masterKeyFingerprint_outputDescriptorType_account]`, e.g.:
  `cb71b92-6a97d31-HDKey from Pastel Gray Cats Blue-Output-[e7b150d2_nestedmultisig_0]-UR.txt`
* The order of the output descriptors has been changed in accordance with #142.

### 1.3.3 (52)

* Withdrawn due to late-discovered bug.

### 1.3.3 (51)

* Fixed #139, #140: Could not long-press to export QR code of derived address.
* Enhancement #127: Seed creation workflows Quick Create, Coin Flips, Die Rolls, and Playing Cards now set the seed's Creation Date to the current date.
* Enhancement #129: When importing seeds in ByteWords and BIP39 format, Seed Tool is now more flexible about what it accepts for input. It will accept input that includes extra whitespace (including newlines) and non-letter input like line numbers.
* Updated all custom icons in the app to Apple's latest specifications. Many icons throughout the app have improved appearance.
* In the Seed Detail screen, the Notes field now reports the length of the seed's note and the size (in QR code modules) of how large/dense the QR code needed to print it will be. In addition, If the Notes field goes over 1,000 characters (reduced from 2,000 in a previous beta release) a warning will be displayed that some metadata will be shortened to fit into a printed QR code (this warning is also printed on the Seed backup page itself). Finally, a notice will be displayed if the seed's on-screen QR code will be animated.
* All QR codes, whether on screen or printed, now use the "medium" level of error correction.
* The minimum system requirements have been reduced from iOS 15.2 to 15.1 and macOS 12.1 to 12.0.

### 1.3.3 (50)

* Seed Tool now recognizes and processes external URLs with the `ur:` scheme, so a number of actions will cause Seed Tool to become active:
    * Scanning a UR QR Code with the Camera app,
    * Tapping a UR link in a web page,
    * Pasting a UR into Safari's address bar,
    * Tapping a UR link in text, like in the Notes app,
    * Tapping a UR in a URL field like in the Contacts to Calendars apps,
    * Tapping the device with an NDEF-formatted NFC tag containing a UR. 

* You can hold a properly formatted and written tag to the top part of your device screen. Even if Seed Tool is not running, if your device is unlocked and the camera is not active, then you will receive a banner asking if your want Seed Tool to open it, and when Seed Tool opens, it behaves just as if you had scanned a QR code.
* The Scan view now contains an "NFC Tag" button that starts a tag reading session. Again, Seed Tool treats NFC tags containing URs like QR codes. If you are restoring a seed from an SSKR, you will need to tap this button once per SSKR tag you wish to read.
* All Share Sheet and Print actions now include additional detail in their "Save to Files" filenames.

### 1.3.3 (49)

* Superceded by 1.3.3 (50)

### 1.3.3 (48)

* Most Share Sheet and Print actions now include additional detail in their "Save to Files" filenames.
    * The default filename for exporting a seed:
        * `1c907cb-TestSeed-Seed-UR.txt`
        * (seedID-name-type-format)
    * And exporting a key derived from that seed gives the following filename:
        * `1c907cb-07bc595-HDKey from TestSeed-PrivateHDKey-[94b193eb_48h_0h_0h_2h]-3fb97f42-UR.txt`
        * (seedID-keyID-name-type-[masterFingerprint_path]-fingerprint-format)
    * An SSKR share from a backup of the same seed:
        * `1c907cb-[group1_1of3]-GRAY COLA LION EYES-SSKR-UR.txt`
        * (seedID-[group_share]-name-type-format)
    * An Address derived from the seed:
        * `1c907cb-07bc595-Address from TestSeed-Address-[94b193eb_48h_0h_0h_2h]-3fb97f42.txt`
        * (seedID-keyID-name-type-[masterFingerprint_path]-fingerprint)
    * A ur:crypto-response returning the same seed:
        * `1c907cb-TestSeed-Response-Seed-UR.txt`
        * (seedID-name-type-format)
    * A printed PDF of an exported key:
        * `1c907cb-c04e2df-HDKey from TestSeed-PrivateHDKey-[94b193eb_84h_0h_0h]-f168af3e.pdf`
* When printing a Seed backup page, it is possible that the size of the notes field will exceed the maximum that can be encoded in a QR code. Seed Tool has always had limits on this, and would truncate the encoded notes if they reached 500 characters, and the name field if it reached 100 characters. This has now been increased to 2000 characters for the Notes field, and 200 characters for the Name field. In addition, if any metadata must be truncated to fit within the QR code capacity, a warning will be printed on the output page. This does not affect the integrity of the seed; only the metadata like name and notes.
* Seed Tool now recognizes (but does not yet process) external URLs with the `ur:` scheme, so a number of actions will cause Seed Tool to become active:
    * Scanning a UR QR Code with the Camera app,
    * Tapping a UR link in a web page,
    * Pasting a UR into Safari's address bar,
    * Tapping a UR link in text, like in the Notes app,
    * Tapping a UR in a URL field like in the Contacts to Calendars apps,
    * Tapping the device with an NDEF-formatted NFC tag containing a UR. 

### 1.3.3 (47)

* All actions that invoke the Share Sheet (including long presses on many of the displayed data items in the app) now have sensible default file names that are offered if the Share Sheet "Save to Files" option is invoked.
* On iOS, the Copy to Clipboard function now erases the clipboard 1 minute after the copy.
* On macOS, the Copy to Clipboard function is now available from the Share Sheet. Unfortunately, macOS does not support the self-erasing clipboard feature.

### 1.3.3 (46), February 11, 2022

* Added an interface for exporting individual SSKR shares as ByteWords, ur:crypto-sskr, or QR code.
* All interfaces for generating and printing SSKR shares now display a "Generated" date and time to ensure that shares are compatible.
* The summary page for printing SSKR shares now has the notice: "The following verification words may be used to establish that printed shares are part of this SSKR share collection. Check them against the last four ByteWords of each share. Only shares that were created at the same time can be used together."
* Printed seed backup pages now include a "Derivations" section containing the Master HD key fingerprint and Ethereum account ID that can be derived from the seed.
* Fixed a bug when printing a seed backup page where the text in the UR section would sometimes be very tiny. 
* Fixed bug where repeatedly printing or exporting a set of SSKR shares without leaving the SSKR presentation screen caused the shares to be regenerated and therefore incompatible.
 
### 1.3.3 (45), February 8, 2022

* When printing SSKR shares two new options have been added: 
    1. Before you could only print multiple share "coupons" on each page, which had to be cut apart. You can still do this, but the default is to print one share per page.
    2. All the information necessary to identify the shares and their group membership is now on a "summary page" at the beginning of the print job. This can also be turned off. 

### 1.3.2 (44), February 3, 2022

* Fixed bug #118: SSKR print preview displays incorrectly.

### 1.3.1 (43), January 5, 2022

* Key Export: Fixed a bug where changing the network wouldn't always update the derived ur:crypto-account to reflect the change.
* QR code display: Reduced the threshold for a QR code to be animated from 800 to 600 bytes per segment.


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

[**Gordian System Discussions**](https://github.com/BlockchainCommons/Gordian/discussions). For users and developers of the Gordian system, including the Gordian Server, Bitcoin Standup technology, QuickConnect, and the Gordian Wallet. If you want to talk about our linked full-node and wallet technology, suggest new additions to our Bitcoin Standup standards, or discuss the implementation our standalone wallet, the Discussions area of the [main Gordian repo](https://github.com/BlockchainCommons/Gordian) is the place.

[**Wallet Standard Discussions**](https://github.com/BlockchainCommons/AirgappedSigning/discussions). For standards and open-source developers who want to talk about wallet standards, please use the Discussions area of the [Airgapped Signing repo](https://github.com/BlockchainCommons/AirgappedSigning). This is where you can talk about projects like our [LetheKit](https://github.com/BlockchainCommons/bc-lethekit) and command line tools such as [seedtool](https://github.com/BlockchainCommons/bc-seedtool-cli), both of which are intended to testbed wallet technologies, plus the libraries that we've built to support your own deployment of wallet technology such as [bc-bip39](https://github.com/BlockchainCommons/bc-bip39), [bc-slip39](https://github.com/BlockchainCommons/bc-slip39), [bc-shamir](https://github.com/BlockchainCommons/bc-shamir), [Sharded Secret Key Reconstruction](https://github.com/BlockchainCommons/bc-sskr), [bc-ur](https://github.com/BlockchainCommons/bc-ur), and the [bc-crypto-base](https://github.com/BlockchainCommons/bc-crypto-base). If it's a wallet-focused technology or a more general discussion of wallet standards,discuss it here.

[**Blockchain Commons Discussions**](https://github.com/BlockchainCommons/Community/discussions). For developers, interns, and patrons of Blockchain Commons, please use the discussions area of the [Community repo](https://github.com/BlockchainCommons/Community) to talk about general Blockchain Commons issues, the intern program, or topics other than the [Gordian System](https://github.com/BlockchainCommons/Gordian/discussions) or the [wallet standards](https://github.com/BlockchainCommons/AirgappedSigning/discussions), each of which have their own discussion areas.

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
