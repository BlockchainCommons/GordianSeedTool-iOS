# Gordian Seed Tool Manual

[image of main screen, aligned right]

**Gordian Seed Tool** is an iOS-based seed manager that is a reference app for the Gordian system. It allows you to safely and securely store your keys and to export public keys, private keys, and seeds as required.

Why use **Seed Tool**? Because storing your seeds on a fully networked device is a major security vulnerability, and it also leaves your seeds vulnerable to loss. Seed Tool resolves both of these problems. You can move selected public and private keys online only as they're required, and you can be sure that your seeds are in a secure vault that's backed up, and not dependent on a single device.

**Usability Features:**

* Import via QR or a variety or text specifications
* Export QR or text Clipboard or Printing
* Identify Seeds using [Object Identity Block](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#object-identity-block)
 
**Security Features:**

* Stored Securely with Apple Encryption
* Protected via 2FA: you must login in to your Apple account, then you must verify with biometrics whenever you access private data
* Automated iCloud backup and recovery

**Gordian Seed Tool** is a reference app, demonstrating the [Gordian Principles](https://github.com/BlockchainCommons/GordianSeedTool-iOS#gordian-principles) of independence, privacy, resilience, and openness.

## Installing Seed Tool

You can either purchase **Gordian Seed Tool** from the Apple store or you can compile from the source here.

For full functionality of the iCloud backup, be sure to turn on the following functionality under "Settings > Apple ID > iCloud" on all devices running **Gordian Seed Tool**:

* Keychain
* iCloud Drive

Be _very_ sure that all devices running **Gordian Seed Tool** are fully logged into your Apple account, with full access to iCloud, and switches set as noted above. Failure to do so will either result in Seed entries not being synced to the iCloud (and other devices).

## Using Seed Tool

**Seed Tool** allows you to import (or create) seeds, store them, and export them.

### Viewing the Main Menu

The main menu contains three buttons in the menu bar along the top:

* **Information** (circled "i"). Read documentation on all of the specifications and data types found in **Seed Tool**.
* **Scan** (qr code). Scan a QR code of a seed.
* **Setting (gear). Choose MainNet or TestNet as your default network; choose whether to sync to iCloud or not. If you wanted to erase all of your data, this would be the place to do so.

> :warning: **WARNING:** We highly suggest you leave iCloud backups on. Without it, if you lose your phone, you will lose all of your seeds. The iCloud backups are encrypted, so no one but you should be able to acces them.

> :warning: **WARNING:** If you choose to delete all your data in Settings, then your seeds will really, genuinely be gone.

Under the main menu are options to **add** ("+") and **delete** ("edit") seeds, followed by a list of each of your seeds, with each seed identified by an Object identity Block ("OID"). You can click the right arrow on a seed to see more data about it and to export it.

### Importing Seeds

Seeds can be imported into **Seed Tool** via a variety of means.

The **Scan** (qr code) button on the main menu provides the most automated methods for importing seeds, using your camera, or the cut-and-paste clipboard. Just point your camera at a QR of a seed (for first time usage, you will be required to provide access to the camera), or copy text containing a standard `ur` description of a seed into the clipboard, then hit the **Paste** button.

Note that for these methodologies, **Seed Tool** expects the QR code or the clipboard to contain a [Uniform Resource](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md), a standardized way to encode data in an efficient and self-identifying way. This will usually mean a [`ur-crypto-seed`](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-006-urtypes.md#cryptographic-seed-crypto-seed), though SSKR and Request/Response URs are also possible.

The **add** ("+") button below the main menu gives a number of options for creating seeds in **Seed Tool**, but also lets you as hex bytes, `ur:crypto-seed`, `Bytewords`, BIP39 Mnemonic Words, or Share words. In each case, you just type or paste the words, and then click "Done".

The following show examples of the data you might input for each data type:

* **Hex Bytes:** 59F2293A5BCE7D4DE59E71B4207AC5D2
* **`ur:crypto-seed`:** `ur:crypto-seed/oyadgdhkwzdtfthptokigtvwnnjsqzcxknsktdhpyljeda`
* **Byte Words:** hawk whiz diet fact help taco kiwi gift view noon jugs quiz crux kiln silk tied omit keno lung jade
* **BIP 39 Mnemonic Words:** fly mule excess resource treat plunge nose soda reflect adult ramp planet

The SSKR shares require additional discussion:

#### Importing SSKR Shares


### Creating Seeds

### Reading the OIB

### Deleting a Seed

[undo!]

### Viewing a Seed

### Exporting a Seed

### Transforming a Seed
