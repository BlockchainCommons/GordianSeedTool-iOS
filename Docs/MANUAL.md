# Gordian Seed Tool Manual

<a href="https://raw.githubusercontent.com/BlockchainCommons/GordianSeedTool-iOS/shannona-minimanual/images/st-listing.jpeg"><img src="https://raw.githubusercontent.com/BlockchainCommons/GordianSeedTool-iOS/shannona-minimanual/images/st-listing.jpeg" align="right" width=250></a>

**Gordian Seed Tool** is an iOS-based seed manager that is a reference app for the Gordian system. It allows you to safely and securely store your keys and to export public keys, private keys, and seeds as required.

Why use **Seed Tool**? Because storing your seeds on a fully networked device is a major security vulnerability, and it also leaves your seeds vulnerable to loss. Seed Tool resolves both of these problems. You can move selected public and private keys online only as they're required, and you can be sure that your seeds are in a secure vault that's backed up, and not dependent on a single device.

**Usability Features:**

* Import via QR or a variety or text specifications.
* Export via QR or Clipboard or printing.
* Identify Seeds using [Object Identity Block](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#object-identity-block).
 
**Security Features:**

* Stored Securely with Apple Encryption.
* Protected via 2FA: you must login in to your Apple account, then you must verify with biometrics whenever you access private data.
* Automated iCloud backup and recovery.

**Gordian Seed Tool** is a reference app, demonstrating the [Gordian Principles](https://github.com/BlockchainCommons/GordianSeedTool-iOS#gordian-principles) of independence, privacy, resilience, and openness.

## Installing Seed Tool

You can either purchase **Gordian Seed Tool** from the Apple store or you can compile from the source here.

For full functionality of the iCloud backup, be sure to turn on the following functionality under "Settings > Apple ID > iCloud" on all devices running **Gordian Seed Tool**:

* Keychain
* iCloud Drive

Be _very_ sure that all devices running **Gordian Seed Tool** are fully logged into your Apple account, with full access to iCloud, and switches set as noted above. Failure to do so will result in seed entries not being synced to the iCloud (and other devices).

## Using Seed Tool

**Gordian Seed Tool** is a storage mechanism for seeds, particularly those used in cryptography systems. Seeds used in it will usually follow a three-part cycle.

1. **Add a Seed.** First, you must add seeds to the system. There are two ways to do see.
   * **Import a Seed.** You can import a seed that you generated in a cryptowallet.
   * **Create a Seed.** You can also create a seed directly in Seed Tool.
2. **Store a Seed.** Your seed will be encrypted and also backed up if you have iCloud enabled.
   * **View & Edit a Seed.** While you are storing a seed, you will be able to view it and change its metadata.
   * **Read an OIB.** Each Seed (and Key) comes with an Identity Block that makes it easy to identify the seed.
3. **Use a Seed.** You can actively use a seed that is stored in Gordian Seed Tool, without ever having to export it. 
   * **Answer Requests.** Seed Tool uses the [`crypto-request`/`crypto-response`](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-001-request.md) system defined by Blockchain Commons for URs. This allows Seed Tool to export precisely what's needed by another app.
   * **Derive a Key.** Alternatively, you can choose to export specific derived keys on your own, while maintaining the seed in the app.
   * **Shard a Seed.** Finally, you can improve the resilience of your seed by sharding it with SSKR and giving out those shards.

**Gordian Seed Tool** is designed so that once you've imported a seed you don't need to ever export it. But, if you want to, you can:

4. **Export a Seed.** You can export seeds using a variety of interoperable specifications.
5. **Delete a Seed.** You can also just delete a seed.

### Viewing the Main Menu

<blockquote>
  <img src="https://raw.githubusercontent.com/BlockchainCommons/GordianSeedTool-iOS/shannona-minimanual/images/st-bar.jpg" align="center" width=500>
</blockquote>

The main menu contains three buttons in the menu bar along the top:

* **Information** (circled "i"). Read documentation on all of the specifications and data types found in **Seed Tool**.
* **Scan** (qr code). Scan a seed (see "Importing a Seed") or a `crypto-request` (see "Using a Seed") from a QR code or import from the Clipboard.
* **Setting** (gear). Choose MainNet or TestNet as your default network (this is used for key derivation, as discussed in "Deriving a Key"); choose whether to sync to iCloud or not. If you wanted to erase all of your data, this would be the place to do so.

> :warning: **WARNING:** We highly suggest you leave iCloud backups on. Without it, if you lose your phone, you will lose all of your seeds. The iCloud backups are encrypted, so no one but you should be able to acces them.

> :warning: **WARNING:** If you choose to delete all your data in Settings, then your seeds will really, genuinely be gone.

Under the main menu are options to **add** ("+") and **delete** ("edit") seeds followed by a list of each of your seeds, with each seed identified by an Object identity Block ("OID"). You can click the right arrow on a seed to see more data about it and to export it.

## Adding a Seed

Seeds can be created or imported. Seed Creation is done through the **add** ("+") button, while seed importing is done via either the qr button (which imports via camera or other automated means) or the **add** button (which does so via pasting).

### Scanning a Seed via Automated Means

<a href="https://raw.githubusercontent.com/BlockchainCommons/GordianSeedTool-iOS/shannona-minimanual/images/st-scan.jpeg"><img src="https://raw.githubusercontent.com/BlockchainCommons/GordianSeedTool-iOS/shannona-minimanual/images/st-scan.jpeg" align="right" width=250></a>

The **Scan** (qr code) button on the main menu provides the most automated methods for importing seeds, using your camera, the cut-and-paste clipboard, the file system, or your photo roll. 

To scan a QR code, you can either point your camera at the QR of a seed, import a QR of a seed from your Photos, or choose an image of a QR from your Files. To read the text for a QR, just copy it into your Clipboard and click Paste. Note that for these methodologies, **Seed Tool** expects the QR code or the clipboard to contain a [Uniform Resource](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md), a standardized way to encode data in an efficient and self-identifying way. This will usually mean a [`ur-crypto-seed`](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-006-urtypes.md#cryptographic-seed-crypto-seed).

Besides scanning seeds, you can also scan SSKR shares (See "Importing SSKR Shares") or respond to a `crypto-reqest` (see "Answering Requests"), as described below.

### Importing a Seed via Cut and Paste

The **add** ("+") button below the main menu gives a number of options for creating seeds in **Seed Tool**, but also lets you input text as hex bytes, `ur:crypto-seed`, `Bytewords`, or BIP39 Mnemonic Words. In each case, you just type or paste the words, and then click "Done".

The following show examples of the data you might input for each data type:

* **Hex Bytes:** 59F2293A5BCE7D4DE59E71B4207AC5D2
* **`ur:crypto-seed`:** `ur:crypto-seed/oyadgdhkwzdtfthptokigtvwnnjsqzcxknsktdhpyljeda`
* **Byte Words:** hawk whiz diet fact help taco kiwi gift view noon jugs quiz crux kiln silk tied omit keno lung jade
* **BIP 39 Mnemonic Words:** fly mule excess resource treat plunge nose soda reflect adult ramp planet

Again, you can also add add SSKR shares, as described below.

### Importing SSKR Shares

SSKR stands for Sharded Secret Key Reconstruction, a Blockchain Commons [specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-011-sskr.md). It allows you to shard a secret (such as a seed) into a number of shares, and then reconstruct the secret from some number (threshold) of those seeds that's typically fewer than all of them. For example, you might shard a seed into three shares with a threshold of two. Typically, the shares are given out to friends and family, placed in distant safety deposit boxes, or otherwise separated. A threshold of the shares can then be collected and used to reconstruct the seed if the original is lost. 

One of the notable features in **Gordian Seed Tool** is that it can be used to collect together shares and reconstruct your seed. There are currently three ways to do so:

* **Scan: QRs.** Photograph QRs of SSKR shares until you have a threshold.
* **Scan: Paste Crypto-SSKR.** Paste `ur:crypto-sskr` of SSKR shares until you have a threshold.
* **Add: Shares.** Simultaneouly paste sufficient shares to meet threshold into the box.

The **Scan** functionality is currently the more advanced of the two options, and so is the suggested methodology. It will allow you to photograph or paste individual shares, and will alert you to how many more are needed to meet the threshold and reconstruct the seed.

The `ur:crypto-sskr` specification, which can be used in the `Add` section, in the `Scan: Paste`, or encoded as a QR, look like this:

* ur:crypto-sskr/gobnbdaeadaevdbkclhseeehtldedikgpysoenreceeeeorofrwn
* ur:crypto-sskr/gobnbdaeadadrkhesefhjzdycypduokkjejponsayabguymwwnwz

The SSKR words, which can only be used in the `Add` section, looks like this:

* tuna acid epic gyro gray tent able acid able frog cusp heat poem owls undo holy rich monk zaps cost brag loud fair dice idle skew iris beta tied
* tuna acid epic gyro gray tent able acid acid diet fact gala numb leaf fish toys kite cyan inky help keep heat inky song trip bulb flap yoga jazz

### Creating a Seed

**Gordian Seed Tool** can also be used to create new seeds. This is doing using the **add** (+) button on the main menu. There are four ways to do so:

* **Quick Create.** Depend on your mobile device's randomization to create a seed.
* **Coin Flips.** Flip coins and enter results.
* **Die Rolls.** Roll six-sided dice and enter results.
* **Playing Cards.** Draw cards and enter results. (Be sure to replace cards as you draw, for the entropy calculation to be correct.)

The easiest of these methods is certainly the "Quick Create", but in that case you are depending on the randomization of your phone, and if there is ever an exploit revealed, you'll be forced to sweep all of your funds. Using coin flips, die rolls, or playing cards is perhaps more likely to create good entropy, and is less likely to have an exploit revealed, but you _must_ properly flip every coin, roll every die, or draw every card, no matter how tedious it is, and you must wait until you have at least 128 bits of entropy, which is considered "Very Strong". If you are not willing to do this, you should just "Quick Create" instead. Once you have a "Very Strong" amount of entropy, you should click the "Done" button, and then you'll be given the opportunity to "Save" your new seed.

The coin flipping, die rolling, and card drawing methods all have three buttons at the bottom, which allow you to: erase one entry; use the randomizer to add one entry; or use the randomizer to add all of the entries.

The usage of entropy in **Gordian Seed Tool** matches that of [**LetheKit**](https://github.com/BlockchainCommons/lethekit), so you can check the results for one to the other if you want to be sure of a new seed that you've created.

## Storing a Seed

Once you have a seed in **Gordian Seed Tool** it will be safely encrypted, and it will be safely backed up to iCloud as long as you've enabled iCloud's access to Keychain and iCloud Drive. 

### Viewing & Editing a Seed

You can view additional details of a seed by clicking the seed on the main menu.  The resulting page will show you the OIB, the bit size, the resultant strength, and the creation date. You can also edit the "Name" and add "Notes".

This is also where you export information on the seed, either the public key or the private data, as described in "Using a Seed".

### Reading the OIB

Each seed is displayed with an [Object Identity Block (OIB)](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#object-identity-block), which can be seen on both the listing and view pages. It helps you to visually identify a seed.

It contains the following elements:

* **Lifehash.** A [methodology](https://github.com/BlockchainCommons/LifeHash) for creating an evocative visual representation of data based on Conway's Game of Life. It makes it easy to recognize a seed at a glance.
* **Type.** An icon represents the type of data. On the listings and main views, this is a seed icon.
* **Name.** A human-readable name for the seed. As a deafult, **Seed Tool** chooses an evocative bit of nonsense derived from the content of the seed itself.
* **Digest.** An abbreviated six-character digest of the seed.

The lifehash, the type, the digest, and all but the last two words in the default name should be identical anywhere that you import your seed that uses the Blockchain Commons OIB specification. That will help you to always know that your seed was accurately transmitted, and to always make sure you're working with the right seed.

OIBs are also displayed for various keys derived from your seed. They use different icons for the "type" and do not include a name, as seen in "Deriving a Key".

## Using a Seed

The main power of **Gordian Seed Tool** is that you can permanently store your seeds there, and instead give out keys or otherwise answer requests, as needed.

### Answering Requests

The Blockchain Commons [`crypto-request`/`crypto-response`](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-001-request.md) allows one app to request a certain type of [UR data](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md) and another app to send that requested data. **Gordian Seed Tool** is integrated with this standard: another app can request a seed or a specific derived key, and **Gordian Seed Tool** will send it (with your approval).

This is accomplished via the **Scan** (qr code) feature. Select it and import a QR code through camera, Photos, or File, or else read in a `crypto-request` through the Clipboard. You will be told what seed or key is being requested, and you can choose to approve it. If you do, you'll then be given a QR code which you can scan into the other app as the `crypto-response`. 

The biggest use of this function is to send a very specific derived key that the other app desires. Though you can derive a few specific keys on your own, this allows another app access to _any_ key derived from your seed.

### Deriving a Key

You can derive a key by selecting a seed, choosing to "Decrypt" the private data, and then clicking the Export icon at the top right. One of the options is "Derive and Export Key". You can derive a public or private Master Key or Cosigner" Key (48'/0'/0'/2' by default, which is a multisig SegWit key on mainnet). Alternatively, you can derive either of those keys for TestNet or for Ethereum. You can also set whether a key is further derivable. 

There is also a quick button that just says "Cosigner Private Key". It derives a Private Bitcoin Cosigner Key that allows derivation, using either mainnet or testnet, as recorded in your **Settings**.

Afterward, you can export by using a QR code or copying the text of the `ur:crypto-hdkey`.

### Sharding a Seed

SSKR sharding allow you to make a backup of your key that's not easily susceptible to attacks. You shard your key, you give out the shares to friends and family, and then if you ever lose your key you can reconstruct it by recovering a threshold of shares.

To create SSKR shares of your seed, go to the seed, "Decrypt" the private data, and choose the Export icon at the top right. Then select the "Export as SSKR Multi-Share" option. You will usually leave the groups at one and just choose a number of shares (like 3) and a threshold required to recover the seed (like 2). You can then click "Next" to export the seeds via either copying or printing. 

You can also choose a more complex methodology with SSKR's "groups", which allow you to define multiple groups, then to set a threshold of a certain number of shares from a certain number of groups: for example, you could create 3 groups, with a group threshold of 2, then have each group include 3 shares, with a threshold of 2. You'd then be able to recover your seed from 4 of the 9 shares, as long as 2 each come from 2 different groups. (But, this is more complex than most people will need: just do something simple like a 2 of 3 sharding or a 3 of 5 sharding if this sounds like something you wouldn't know how to use).

When you export your shards, you can copy them to your clipboard as Bytewords (which are human-readable words) or `ur:crypto-sskr` (which are specially formatted URs that can easily and reliably be read into our apps following the UR specification). However, the most useful means to export your SSKR may be printing them. After you print them, you can cut out ribbons of paper for each share and then hand them to the people who will be storing them. We suggest asking they store the QR code in [**Gordian QR Tool**](https://apps.apple.com/us/app/gordian-qr-tool/id1506851070) and then thoroughly destroy the slip of paper.

### 2FAing Your Requests

Any time you request private data, such as your seed or private keys derived from your seed, **Gordian Seed Tool's** 2FA will go into affect.

The first factor was entered by you when you logged into your Apple ID the firs time you used **Seed Tool.**

The second factor is applied whenever you access private data. Usually, you will enter a thumbprint, but on a newer iPhone you will use Face ID and on most Mac systems you will enter a password. 

This ensures that even if someone acquires your phone in an unlocked mode, they won't be able to get to your seed data.

## Exporting a Seed

You should be able to safely and securely use your seed within **Gordian Seed Tool** by responding to `crypto-requests` and deriving keys. However, if you want to someday export the whole seed, you can.

A seed can be exported by touching the "Decrypt" box under the "Data" section of a seed. This will, as usual, require your 2FA. After it decrypts, you can then click the "Share" button to the top right. This will allow you to export as hex, as BIP39 Mnemonic Words, as ByteWords, or as a `ur:crypto-seed`. (This is the functions for exporting SSKR shares and deriving and exporting keys were.)

These functions all will copy the data in the appropriate form to your clipboard, allowing you to then paste it until the app of your choice. The `ur:crypto-seed` alternatively allows you to print the QR containing the `ur:crypto-seed` for your seed.

> :warning: **WARNING:** Generally, you want to always keep your seed in **Seed Tool**. It is both secure and resilient in the app. There is no reason to export it. Instead, export keys as appropriate, ideally watch-only public keys or specific keys in response to a `ur:crypto-request` from another app.

## Deleting a Seed

If you're done with a seed or if you've exported it to another app or device, you may then want to delete it.

Seeds can be deleted with the "Edit" function on the main page. You can immediately "Undo" it if you deleted the wrong seed, but afterward, any seed you deleted will be gone forever. Be careful!
