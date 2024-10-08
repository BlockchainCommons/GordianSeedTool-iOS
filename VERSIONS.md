# Version History

_This is a listing of previous versions. The info on the most current versions can be found in the [main README](README.md)._


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
### 1.0.1 (21), July 3, 2021

* Cloud syncing is now more robust.
* The "Gordian Cosigner" button has been renamed "Cosigner Public Key" and the "Gordian Private Key" has been renamed "Cosigner Private Key".
* In the Key Export view, the "Gordian" derivation path has been renamed "Cosigner".
* The app version and build number is now shown at the bottom of the Settings (gear) panel. When built for pre-release, additional information may be shown indicating a debug build, and/or the app sandbox (Test Flight), push notifications (APNS) sandbox, and iCloud sandbox environment. If none of this additional information shows up, then you are running a final App Store release.

### 1.0 (20), June 17, 2021

* Added support for iCloud synchronization. All seeds will be synchronized across devices logged into the same iCloud account. The Settings (gear) screen now includes a "Sync to iCloud" switch. If Sync to iCloud is on, the Erase All Data function now also erases all seeds that were on the device from iCloud as well.
* If you make a change on one device and want to wait for the changes to appear on another, be aware that iCloud does not guarantee real-time replication. Often the first change you make may take 30 seconds or longer to appear. Subsequence changes usually appear much faster.
* Turning on Sync to iCloud always does a non-destructive merge of the seeds on the device with the seeds in iCloud. In other words, if you turn off Sync to iCloud, add and delete some seeds, then turn it back on, the result on all devices will be the union of the seeds originally on all devices— the seeds you deleted while Sync to iCloud was turned off will *not* be deleted on iCloud or other devices.
* Current known limitation: Seeds created or modified while a device is off-network (e.g., Airplane Mode) will not be automatically uploaded to the cloud until "Sync to iCloud" is turned off and then on again. Turning off Sync to iCloud, adding seeds, and then turning Sync to iCloud back on *will* upload the new seeds to iCloud.
* Added Shannon's improved "About Seed Tool" 

### 1.0 (19), May 31, 2021

* App name changed to “Gordian Seed Tool”.

### 1.0 (18), May 23, 2021

* Fixed a crash when a seed was deleted. This crash did not manifest in iOS versions before the current one (14.5), and is due to how the delete confirmation alert was shown. SwiftUI does not currently provide a standard way to do row deletion where the row might not actually be deleted, so the method of doing this was a hack. Apple's own apps suggest their preferred approach is to implement Undo functionality, so this is what I did: when you delete a seed, rather than warning you, an Undo button appears, giving you a chance to reconsider.

### 1.0 (17), April 13, 2021

* Fixed a regression where attempting to print seeds and derived keys would produce an empty page.

### 1.0 (16), April 13, 2021

* Unreleased.

### 1.0 (15), April 12, 2021

* You can now back up a seed by printing its SSKR shares. Access this from Seed Detail > Decrypt > Export Menu > Export as SSKR Multi-Share > Set group and share parameters > Next > Print All Shares.
* The printed SSKR shares can be cut apart into share "coupons" that would then be distributed to the share trustees. Each coupon has a "receipt stub" that can be retained by the seed owner.
* A seed can be reconstructed from SSKR share coupons by scanning them using the main screen Scan button. As shares are scanned, a HUD shows the progress of reconstructing the seed from the SSKR shares.

### 1.0 (14), March 31, 2021

* The Scan function now has a "Paste" button at the bottom. This allows a ur:crypto-seed or ur:crypto-request on the clipboard to be entered as if the same UR was scanned in a QR code. (#46)
* In the Derive and Export Key parameters area there is a new "Allows further derivation" toggle. When this is turned off, the derived key will not have a chain code, and therefore cannot be used to derive further keys.
* Now supports the is-derivable flag for key requests and responses. See: https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-001-request.md#cddl-for-request
* To facilitate testing, a set of requests for non-derivable keys have been added to "https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing/Derivation Requests.pdf"

### 1.0 (13), March 8, 2021

* Fixed a bug where the transaction ID in a returned `crypto-response` did not match the transaction ID in the received `crypto-request`.
* Releases are now managed via [fastlane](https://fastlane.tools).

### 1.0 (12), March 2, 2021

* The app logo displays during app startup.
* The first time the app runs a license acceptance screen displays and must be accepted to continue.
* The Settings > Erase All Data explanation has been clarified.
* A scanned `crypto-request` for a HDKey that does not contain a source fingerprint will now cause the user to be asked to choose a seed from which to perform the key derivation.
    * To facilitate testing, there is an additional "Derivation Requests.pdf" file that contains requests for keys without a source fingerprint: https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing
* UI elements throughout the app now have accessibility metadata. This won't be visible to typical users, but facilitates using the app with VoiceOver and other Apple assistive technologies, and also helps automate the production of App Store screen shots.
* Fixed bug where displayed QR code was supposed to be `ur:crypto-response` but was instead the bare requested `crypto-seed` or `crypto-hdkey` without being wrapped in the `crypto-response`.
* Added button to copy displayed `ur:crypto-response`s to the clipboard.

### 1.9 (11), February 24, 2021

* A new "Scan" button appears at the top of the main screen. This can be used to scan `ur:crypto-seed`s or `ur:crypto-request`s.
    * Seeds will be imported.
    * Requests for seeds on the device or keys that can be derived from seeds on the device will display a confirmation screen that requires re-authentication before displaying the response.
    * To facilitate testing, there are PDF files that contain a seed and requests for the seed and associated keys at: https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing
* Seed names, if too long to be displayed in the available space, will be truncated with a middle ellipsis rather than at the end. (#30)
* Copying a seed as Base58 is now in the form: [path]xprv. (#31)
* The seed export screen now displays Ethereum (ETH) as an alternative to Bitcoin (BTC) instead of Bitcoin Cash (BCH). (#33).

### 1.9 (10), February 12, 2021

* The `Seed Detail > Data` area now includes a button to export the Gordian Private Key.
* Every view that shows a UR QR code for export, for seeds and keys, now includes a `Print` button.
* The `Seed Detail > Export Menu > Export as ur:crypto-seed` command has been renamed `Export or Print as ur:crypto-seed...`
* The `Seed Detail > Export Menu > Print Seed Backup...` command has been removed.
* Various minor layout improvements.


### 1.0 (9), February 11, 2021

* Enhancements to the in-app documentation, thanks to Shannon.
* Lock button now easier to tap (Issue #22).
* Icons denoting private and public keys are now color-coded (green: public, red: private)
* The Settings panel now includes an "Erase All Data" button (Issue #16).
* Fixed bug during printing where page would sometimes get cut off.
* When copying a key as Base58 to the clipboard, it is now copied with derivation path and fingerprints (Issue #21):

```
[6b95d49e/48'/1'/0'/2'] -> 6d1cd6b3
tpubDFMKm4rE3gxm58wRhaqwLF79e3msjmr2HR9YozUbc4ktwPxC4GHSc69yKtLoP1KpAFTAx872sQUyBKwgibwP8mRnUJwbi7Q8xWHmaALEzkV
```

### 1.0 (8), February 6, 2021

* The Info icon in the upper left corner of the main screen now leads to the app documentation table of contents.

### 1.0 (7), February 4, 2021

* Printing: The seed export menu now includes "Print Seed Backup..."
* Moved from exporting 1-of-1 SSKR ByteWords to exporting (and importing plain ByteWords for seeds).
    * The Seed Export menu now contains "Copy as ByteWords".
    * The Import section of the New Seed (+) menu now contains Import Existing Seed as ByteWords.

### 1.0 (6), January 30, 2021

* Fixed a crashing bug found just after the previous release, which happened when saving a newly-created seed.

### 1.0 (5), January 30, 2021

#### General

* A UI bar now appears over the main screen with Blockchain Commons branding and a `gear` button that opens the global settings page.
    * The "Info" button that appears does not currently have any content.
    * Currently the only setting available is "Default Network." This affects the `Seed Detail > Gordian Public Key` button and the default Parameters of the `Derive and Export Key` function.
* Button hit boxes now bigger and easier to press.
* The Blockchain Commons logo is now available for use throughtout the app as a custom SF Symbols glyph.

#### Seed Detail

* A prominent button now allows immediate export of the Gordian Public Key derived from the seed's master key [48'/0'/0'/2']. If The Default Network setting is `testnet` then the derived path is [48'/1'/0'/2'].
* The key export menu has been re-arranged to make expected more common tasks appear closer to where the user taps to show the menu.

#### Key Export

* A problem with the base58 export of the derived key not matching other tools and libraries was fixed.
* The Parameters section is set for Gordian Key defaults.
* The Network parameter will match the Default Network setting of the Settings Panel.
* The Derived Key path is displayed like this now: `[314a3f16/48'/1'/0'/2'] -> a1e1c73d`. This makes it clear which master key was used, and that the derived key was the result of deriving the path shown.

#### Known issues

* The on-screen keyboard is likely to cover the Notes field when it is tapped into, forcing the user to scroll down to it after the keyboard appears. This is a bug in SwiftUI and Apple may fix it or we may figure out a workaround at a later date.

### 1.0 (4), January 27, 2021

* Fixed abort in release build.

### 1.0 (3), January 27, 2021

* App name has changed to "Guardian" and the app icon has been updated.
* `Seed Detail > Unlock > Derive and Export Key` has been added that allows several different parameters to be set for the key derivation, and the derived key itself to be exported to either ur:crypto-hdkey (as QR code or to the clipboard) or copied to the clipboard as Base58
* `Seed Detail`: Increased size of clear field button, and moved random name button to left of clear field button for consistency with other fields.
* Add `Seed > Import SSKR` now allows you to paste in shares as either ByteWords or ur:crypto-sskr. You can paste the entire output of  `Seed Detail > Unlock > Export as SSKR Multi-Share` including explanatory text, which will be ignored.
* `Seed Detail > Unlock > Export as ur:crypto-seed` now handles exporting as either a QR code or copying the ur:crypto-seed to the clipboard. There is no longer a separate command in the Export menu to copy the ur:crypto-seed.
* All app model types (Seed and Key) as well as all import and export formats (e.g., Hex, BIP39 SSKR, UR:, etc.) all now have unique custom icons.

### 1.0 (2), January 19, 2021

* Switched to using `.version2` LifeHashes.
* All buttons that reveal or export sensitive information are now coded yellow.
* Seed detail screens now have a lock icon that when tapped triggers local authentication (FaceID, TouchID, or Passcode) before revealing the seed data and the menu that allows export of the seed in various forms.
* Seed Creation Date ("birthdate") is now supported. Newly generated seeds have the current date as their creation date. The creation date can be modified or removed via the Seed Detail view.
* Most static information is now copyable to the clipboard via a long press. Includes: LifeHash images, seed fingerprint (not data, just the hash of the data), seed name, seed data, SSKR shares, QR codes.
* All copy operations now provide haptic feedback.
* Fixed some cosmetic issues.
    * Padding around seed detail when keyboard present.
    * Size text in seed Name field.

### 1.0 (1), December 24, 2020

* First TestFlight Release

