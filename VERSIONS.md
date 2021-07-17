# Version History

_This is a listing of previous versions. The info on the most current versions can be found in the [main README](README.md).

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

