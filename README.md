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

# Status - Released (1.3.2)

**Gordian Seed Tool** has been released through the [Apple Appstore](https://apps.apple.com/us/app/gordian-seed-tool/id1545088229).

## Version History

[Join the Test Flight Open Beta](https://testflight.apple.com/join/0LIl6H1h)

### Summary of changes in version 1.3

* OS Support: This release supports iOS 15 or later and introduces support for macOS 12 (Monterey) or later.
* Scan view: A camera selector button has been added for front/back cameras (iOS) and built-in/desktop webcam (macOS).
* PSBT Signing: When a `ur:crypto-request` for PSBT signing is scanned, Seed Tool will attempt to find seeds that it is managing from which it can derive keys to sign the transaction's inputs. A confirmation screen is then displayed showing the details of the transaction. If the user approves, a ur:crypto-response is displayed. A "bare" PSBT may 
* Bare PSBT Signing: For compatibility testing with third-party wallets that have already implemented this, a bare `ur:crypto-psbt` may now be scanned and signed. Using `ur:crypto-request` is Blockchain Commons' recommended method for requesting PSBT signing, so when a bare `ur:crypto-psbt` is scanned, users are notified of this, thus this capability should be used only for developer compatibility testing and developers are encourage to adopt `ur:crypto-request` as soon as possible. 
* PSBT import formats: Importing a PSBT for signing may be done from the camera for `ur:crypto-request` and `ur:crypto-psbt`, or the clipboard for Base64-encoded PSBTs, or from a file for binary or Base64-encoded `.psbt` files.
* PSBT export formats: Exporting a signed PSBT may be done in several formats: `ur:crypto-response`, `ur:crypto-psbt`, Base64-encoded PSBT, or binary `.psbt` file. All of these formats may use the share sheet, allowing (for example) Copy to Clipboard, *except* for binary `.psbt` files, which must be saved to the file system. The two UR formats can be displayed as (possibly animating) QR codes.
* Key Export via Output Descriptors: Master keys derived from seeds can now be exported to Output Descriptors (`ur:crypto-output` or text) or Account Descriptors (`ur:crypto-account`). To see this new feature:
    1. choose a seed from the Seed List
    2. In the Encrypted Data section, tap "Authenticate"
    3. Tap "Derive Key" and then "Other Key Derivations"
    4. In the "Parameters" area, make sure "Bitcoin" and "Master Key" are selected
    5. Scroll down to the "Secondary Derivation" section and choose "Output Descriptor" or "Account Descriptor".
    6. Edit the "Account Number" field if desired.
    7. If you chose "Output Descriptor", then choose an "Output Type".
    8. Scroll down to the bottom to export your Output Descriptor or Account Descriptor.
* QR Code Display: To increase compatibility with certain QR code readers, QR codes are now displayed as black modules (pixels) on a white background, even in dark mode.
* Other bug fixes and minor enhancements.

### 1.4 (55)

* #152 In the Seed Detail screen, the "Randomize" and "Clear Field" buttons that appear in the Seed Name field when editing it have been replaced with a menu button that includes "Randomize" and "Clear" commands, that only appears when the field is *not* being edited. This is to reduce the chance of the user accidentally changing the field.
* #114 When responding to a request for a key derivation that asks the user to select a seed, the pre-seed selection screen now shows information about the derivation path, as well as any note included with the request. This is in addition to showing this information on the request approval screen.

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

### 1.3 (42), December 15, 2021

* This is a final release candidate.
* PSBT Signing: The option to return a mock ur:crypto-response when signing a bare PSBT is now hidden unless "Show Developer Functions" is turned on in Settings.

### 1.3 (41), December 8, 2021

* Key Export: Master keys derived from seeds can now be exported to Output Descriptors (`crypto-output`) or Account Descriptors (`crypto-account`).
* To see this new feature, 1) choose a seed from the Seed List, 2) In the Encrypted Data section, tap Authenticate, 3) Tap Derive Key and then Other Key Derivations, 4) In the Parameters area, make sure Bitcoin and Master Key are selected, 5) Scroll down to the Secondary Derivation section and choose Output Descriptor or Account Descriptor. 6) Choose Output Descriptor or Account Descriptor, and edit the Account Number field if desired. 7) If you chose Output Descriptor, then choose an Output Type. 8) Scroll down to the bottom to export your Output Descriptor or Account Descriptor.
* Output Descriptors may be exported as text format or `ur:crypto-output` format. Account Descriptors may be exported in `ur:crypto-account` format.

### 1.3 (40), November 25, 2021

* Scan view: added camera selector button for front/back cameras (iOS) and built-in/desktop webcam (macOS).
* First Mac Catalyst Release

### 1.3 (38), November 18, 2021

* PSBTs containing Taproot bech32m addresses are now displayed correctly.
* Reading UR QR codes is now tolerant of QR codes that have content beginning or ending with whitespace. UR QR codes should not include whitespace like trailing carriage returns, and should be translated to upper case, because failing to do so causes QR code encoders to fall back to the less-efficient binary encoding mode resulting in unnecessarily dense QR codes. Previously Seed Tool would reject QR codes that begin or end with whitespace, but now accepts them.
* Scanning now falls back gracefully when unavailable due to running in the simulator.
* Scanning now provides diagnostic messages when the camera cannot be accessed due to system settings permissions.
* All methods of importing text data including URs and Base64-encoded PSBTs are now tolerant of strings that start or end with whitespace.
* Importing PSBT files encoded as binary or Base64 is now supported.
* Importing and exporting ur:crypto-seed and ur:crypto-sskr to and from files and the clipboard is now supported. 
* When importing text from a file or the clipboard, the text may contain any number of URs on separate lines. Non-UR lines are ignored as comments. For example, all the shares of an SSKR may be pasted at one time or imported from a single text file. Currently this is only useful for SSKRs, as a block of text containing multiple ur:crypto-seeds will only import the first one.

### 1.3 (37), November 15, 2021

* Improved support for various PSBT formats.
    * Importing a PSBT for signing may now be done from the camera for ur:crypto-request and ur:crypto-psbt, or the clipboard for Base64-encoded PSBTs, or from a file for binary `.psbt` files.
    * Exporting a signed PSBT may now be done in several formats: ur:crypto-response, ur:crypto-psbt, Base64-encoded PSBT, or binary `.psbt` file. All of these formats may use the share sheet, allowing (for example) Copy to Clipboard, *except* for binary `.psbt` files, which must be saved to the file system. The two UR formats can be displayed as (possibly animating) QR codes.

### 1.3 (36), November 10, 2021

* To increase compatibility with certain QR code readers, made all displayed QR codes black on white, even in dark mode.
* Fixed: When "Erase All Data" in Settings is used, the Undo buffer may still be used to recover the last-deleted seed. The undo buffer is now invalidated when Settings is accessed.
* Clarified explanation of how the "Erase All Data" in Settings interacts with iCloud. 

### 1.3 (35), November 9, 2021

* Fixed: QR code for crypto-response was displayed where QR code for crypto-psbt should have been displayed.

### 1.3 (34), November 9, 2021

* Fixed a couple potential crashes during PSBT signing.

### 1.3 (33), November 5, 2021

* For compatibility testing with third-party wallets that have already implemented this, a bare `ur:crypto-psbt` may now be scanned and signed. Using `ur:crypto-request` is Blockchain Commons' recommended method for requesting PSBT signing, so when a bare `ur:crypto-psbt` is scanned, users are notified of this, thus this capability should be used only for developer compatibility testing and developers are encourage to adopt `ur:crypto-request` as soon as possible. 
* When a `ur:crypto-psbt` is scanned, two possible outputs are offered: the signed bare `ur:crypto-psbt` and a dummy `ur:crypto-response`. This is a "dummy" response because it is not actually a response to a particular `ur:crypto-request` and thus the transaction ID included in the response is random and does not correspond to any actual prior request.
* Two new example QR codes have been added to the [Testing](https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing) folder: `Bare PSBT 1 of 2.png` and `Bare PSBT 2 of 2.png` which can be used to test the bare PSBT signing capability. These are the same transactions also provided in `ur:crypto-request` form.

### 1.3 (32), October 13, 2021

* The minimum OS version requirement is now iOS 15. This build is only available for iOS, but a future build will be compatible with macOS 12 (Monterey).
* Seed Tool now supports signing PSBTs scanned via the camera option. When a ur:crypto-request for PSBT signing is scanned, Seed Tool will attempt to find seeds that it is managing from which it can derive keys to sign the transaction's inputs. A confirmation screen is then displayed showing the details of the transaction. If the user approves, a ur:crypto-response is displayed. The [Testing](https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing) folder contains two sample testnet multisig transactions along with the seeds "Alice" and "Bob" that can be used to sign them.
 
### 1.2.1 (31), September 19, 2021 (Latest released version)

* Better Ethereum Support: The Settings View now has a "Primary Asset" switch that can be changed between Bitcoin and Ethereum. When Ethereum is selected, the following changes apply: 1) In the Seed Detail view, the green "Cosigner Public Key" changes to "Ethereum Address" for quick export of the Ethereum Address derived from the seed. 2) After clicking "Authenticate," the "Derive Key" popup has an item that changes from "Cosigner Private Key" to "Ethereum Private Key." 3) In the "Other Key Derivations" view, the default derivation path for Ethereum is now `44'/60'/0'/0/0` which is compatible with many existing wallets. 4) The bottom of the "Other Key Derivations" view now contains an "Address" box for exporting the Bitcoin or Ethereum address. 5) In the "Other Key Derivations" view, when deriving Ethereum, a new "Private Key" box appears that can be used to export the Ethereum private key. When printed, this page also includes the Ethereum address. 6) All visual hashes (identicons) associated with Ethereum keys or addresses now use "Blockies", which is widely recognized in the Ethereum world, instead of the usual LifeHash algorithm.

### 1.2.1 (30), September 12, 2021

* Fixed a bug where the layout when printing a seed would overflow the page margins or cause certain fields like the ByteWords or BIP-39 mnemonics to be truncated.

### 1.2 (29), August 20, 2021

* In the Key Detail view, an info button has been added next to the Derive Key button.
* Other than the above, this build has no new features, but does include the latest BCLibsSwift, which in turn contains the latest bc-shamir and bc-sskr, which have been reviewed and hardened for security issues. It also has been partly refactored, with some generally useful code being moved into a reusable package. These refactorings should not change the app functionally at all. Nonetheless, it should be thoroughly tested to ensure that nothing has been broken in the refactoring process.

### 1.2 (28), August 17, 2021

* An intermittent crashing bug when creating a new seed has (probably) been fixed and should be thoroughly tested. #83
* When setting up a new seed, the coaching text at the top has been changed to: "You may change the name of this seed or enter notes before saving." #82
* In the settings panel, when turning on and off iCloud syncing, a small graphical glitch in the coaching text has been fixed. #81
* Fixed typo in the "What is Key Derivation?" User Guide chapter. #80
* In the Key Export view, changed section titles "(Private|Public) Key" to be "(Private|Public) HD Key". #78
* In the Seed Detail view, fixed a case where narrow screens like iPod Touch would show wrapped or truncated buttons after authenticating.

### 1.2 (27), August 12, 2021

* Key Derivation Parameters now includes several presets including Master Key, Cosigner, and Segwit. Each preset shows the corresponding derivation path, which updates correctly depending on whether Mainnet or Testnet is selected.
* When the Segwit derivation is used, keys exported as Base58 are now prefixed with `zpub`/`zprv` (Mainnet) or `vpub`/`vprv` (Testnet).
* Key Derivation Parameters now includes a "Custom Derivation Path" field, into which users can enter any specific derivation BIP-32 path for the keys.
* Added two new section to the User's Guide: "What is BIP-39?" and "What is Key Derivation?", along with Info buttons for them at appropriate places in the interface.

### 1.2 (26), July 28, 2021

* In the Export SSKR display, removed export individual shares views. Since the SSKR generated is ephemeral, it wasn't really useful to conditionally show each one. You can now only share or print all the generated shares at once.
* The last preset in the SSKR export display is now called, "2 of 3 shares, of two of three groups".
* In the Derive Key view, both the private and public keys are now simulatenously derived, so a separate parameter for Key Type (i.e., private or public) is no longer necessary.
* In the Derive Key view, selecting Ethereum as the asset type now only allows master key derivations.
* In the Derive Key view, the share buttons for the derived public and private keys are no longer popup menus: they take you directly the the Key Export view, which shows all the export options including the QR code, print button, share as Base58. If Developer Functions are turned on in Settings, then buttons to show sample requests and responses are also visible here.
* The Share as Base58 function in the Key Export view now includes the master key fingerprint and derivation path along with the Base-58 key.

### 1.2 (25), July 27, 2021

This is a preview testing release of what will become version 1.2. It does not yet include the full set of planned features to be release with 1.2.

* You can now navigate from various places of the app to specific pages of the built-in user's guide via the ⓘ buttons.
* The Settings panel now contains a Show Developer Functions switch that shows the "Show Request/Response for this Seed/Key" options at appropriate places in the app.
* All functions that copied data to the clipboard, including long presses on QR codes, life hashes, and other static fields, now invoke the system share sheet instead. The downside to this is that the "Copy" function in the share sheet does not automatically expire the clipboard contents after a minute. It *might* be possible to add this as an app-specific function in the share sheet.
* In the Seed Detail view, the "Data" section has been renamed "Encrypted Data", and the "Decrypt" button is now called "Authenticate". It now reveals several buttons: Backup, Share, and Derive Key, which are menus that lead to futher functionality. There are also links to the documentation. This was done to make the many functions that authentication reveals more discoverable and intuitive. 
* The SSKR export view now includes a "preset selector" that lets users choose among comon sharding configurations. Users can still choose any configuration they like and this will be reflected in the preset selector as "custom".
* The "Next" button in the SSKR Export view has been moved from the bottom of the form to the top right of the view.
* All "Done" buttons are now consistently in the upper-right corner of their views.
* In the Settings panel, the default network is now "mainnet". This will only apply to users who have not manually changed this setting. 
* "Allows Further Derivation" has been removed from Key Export parameters, as it's an advanced feature not likely to be used by many users, and leaving it in was causing confusion.
* Fixed: Text in SSKR heads-up display in Scan View should always be white. Currently it is black when the phone is not in Dark Mode.

### 1.1 (24), July 13, 2021

* More detailed diagnostic messages when pasting SSKR fails.
* Scan view can now pick image(s) from document picker or photos picker.
* Added textual UR to Seed, HDKey, and SSKR print pages.

### 1.0.1 (23), July 7, 2021

* Added support on the macOS version for Print to PDF.

### 1.0.1 (22), July 7, 2021

* Fixed issues [#59](https://github.com/BlockchainCommons/GordianSeedTool-iOS/issues/59), [#60](https://github.com/BlockchainCommons/GordianSeedTool-iOS/issues/60), [#62](https://github.com/BlockchainCommons/GordianSeedTool-iOS/issues/62)

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
