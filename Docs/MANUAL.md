# Gordian Seed Tool Manual v1.6.0 (73)

<a href="../images/st-listing.jpeg"><img src="../images/st-listing.jpeg" align="right" width=250 style="border:1px solid black;"></a>

**Gordian Seed Tool** is an iOS and macOS seed manager that is a reference app for the Gordian system. It allows you to safely and securely store your cryptographic seeds and to derive and export Bitcoin public keys, private keys, and descriptors and Ethereum and Tezos master keys, private keys, public keys, and addresses. You can also backup or export the seed itself in a variety of forms, including as SSKR shares and respond to a variety of requests from other apps.

Why use **Seed Tool**? Because storing your seeds in the unecrypted RAM of a fully networked device is a major security vulnerability and also leaves your seeds vulnerable to loss. It's both a Single Point of Compromise and a Single Point of Failure. **Seed Tool** resolves both of these problems. You can move selected public and private keys online only as they're required, or even better you can leave them offline for signing of PSBTs, and you can be sure that your seeds are in a secure vault that's backed up and not dependent on a single device.

**Usability Features:**

* Import or export via QR or a variety of text specifications.
* Integrate with Clipboard, files, MicroSDs, or printing, as you prefer.
* View & identify unique seeds using [Object Identity Blocks](https://developer.blockchaincommons.com/oib/).
* Sign using PSBTs.

**Security Features:**

* Store seeds securely with Apple Encryption.
* Protect seeds with 2FA: you must login in to your Apple account, then you must verify whenever you access private data.
* Automatically backup and recover seeds with automated iCloud system.
* Optionally run offline, not connected to any network.

**Developer Features:**

* Test out Gordian Envelopes.
* Experiment with NFCs, but please consider this feature _experimental_ as discussed in ":warning: Using NFC Tags".

**Gordian Seed Tool** is a reference app, demonstrating the [Gordian Principles](https://developer.blockchaincommons.com/principles/) of independence, privacy, resilience, and openness.

## Table of Contents

* [Installing Seed Tool](MANUAL.md#installing-seed-tool)
* [Seed Tool Overview](MANUAL.md#seed-tool-overview)
* [Adding a Seed](MANUAL.md#adding-a-seed)
* [Viewing a Seed](MANUAL.md#viewing-a-seed)
* [Using a Seed](MANUAL.md#using-a-seed)
* [Exporting a Seed](MANUAL.md#exporting-a-seed)
* [Deleting a Seed](MANUAL.md#deleting-a-seed)
* [Integrating with Ethereum](MANUAL.md#integrating-with-ethereum)
* [Integrating with Tezos](MANUAL.md#integrating-with-tezos)
* [Using Seed Tool for Transactions](MANUAL.md#using-seed-tool-for-transactions)

* [Appendix I: Threat Modeling](MANUAL.md#appendix-i-threat-modeling)
* [Appendix II: Other Tools](MANUAL.md#appendix-ii-other-tools)

## Installing Seed Tool

You can either purchase **Gordian Seed Tool** from the Apple store or you can compile from the source <a href="https://github.com/BlockchainCommons/GordianSeedTool-iOS/tags">using the newest release tag</a>. The release tags often will be updated to a beta that is ina dvance of the release in the Apple store.

For full functionality of the iCloud backup, be sure to turn on the following functionality under "Settings > [Your Name] > iCloud" on all devices running **Gordian Seed Tool**:

* Passwords and Keychain
* iCloud Drive

Be _very_ sure that all devices running **Gordian Seed Tool** are fully logged into your Apple account, with full access to iCloud, and switches set as noted above. Failure to do so will result in seed entries not being synced to the iCloud (or other devices).

Conversely, if you want to use Seed Tool on a network-isolated device, make sure the device is in Airplane Mode.

## Seed Tool Overview

**Gordian Seed Tool** is a storage mechanism for seeds, particularly those used in cryptography systems. Once stored, seeds can be used to generate keys, answer requests, and sign PSBTs. Seeds used with **Seed Tool** will usually follow a three-part cycle.

1. **[Add a Seed.](MANUAL.md#adding-a-seed)** First, you must add seeds to the system. There are two ways to do so.
   * **Import a Seed.** You can import an existing seed that you generated elsewhere.
   * **Create a Seed.** You can create a new seed.
2. **[Store a Seed.](MANUAL.md#viewing-a-seed)** Your seed will be encrypted (and also backed up if you have iCloud enabled).
   * **View & Edit a Seed.** While a seed is stored in **Gordian Seed Tool**, you will be able to view it and change its metadata.
   * **Read an OIB.** Each seed (and key) comes with an Identity Block that makes it easy to identify.
3. **[Use a Seed.](MANUAL.md#using-a-seed)** You can actively use a seed that is stored in **Gordian Seed Tool** without ever having to export it.
   * **Answer Key Requests.** Seed Tool uses the Envelope request system defined by Blockchain Commons. This allows Seed Tool to export precisely what's needed by another app. Exporting keys is preferred, but seeds can also be exported via this mechanism.
   * **Sign PSBTs.** Besides just exporting seeds or keys, you can also use your keys to sign PSBTs, again responding to an Envelope (or to a `crypto-psbt`, though this is not preferred).
   * **Derive a Key.** Alternatively, you can choose to export specific derived keys on your own, while keeping the seed in the app.
   * **Shard a Seed.** Finally, you can improve the resilience of your seed by sharding it with SSKR and giving out those shares.

The philosophy of **Gordian Seed Tool** is that once you've imported a seed you shouldn't need to ever export it. Nonetheless, you sometimes must in the modern-day, and that's supported by the following functions:

4. **[Export a Seed.](MANUAL.md#exporting-a-seed)** You can export seeds using a variety of interoperable specifications.
5. **[Delete a Seed.](MANUAL.md#deleting-a-seed)** You can also just delete a seed.

Many exports are actually wrapped as [Gordian Envelopes](https://developer.blockchaincommons.com/envelope/) to allow for the inclusion of metadata beyond the specific keys, seeds, or other data.

In the future we expect that more wallets will be able to participate with **Seed Tool** in a request/response cycle, both for derived child keys and with PSBTs needing signature.

The main functionality of **Seed Tool** is laid out in this manual to demonstrate its integration with Bitcoin, but **Seed Tool** also works with Ethereum and Tezos, which causes some slight variations in functionality as explained in ["Integrating with Ethereum"](MANUAL.md#integrating-with-ethereum) and ["Integrating with Tezos"](MANUAL.md#integrating-with-tezos).

### Viewing the Main Menu

<blockquote>
  <img src="../images/st-bar.jpg" align="center" width=500>
</blockquote>

Most pages in **Seed Tool** contains three buttons along the bottom in a menu bar:

* **Information** (circled "i"). Read documentation on all of the specifications and data types found in **Seed Tool**. (Info buttons linnking to specific questions are also available throughout the app.)
* **Scan** (qr code). Import a seed (see "Importing a Seed") or an Envelope request or a PSBT (see "Signing PSBTs") from a QR code; or import text from the Clipboard, Files, Photos, or an NFC Tag.
* **Settings** (gear). Change major ways in which the App works.

The main menu has two more options at top, to **add** ("+") or **delete** ("edit") seeds. That's followed by a list of each of your seeds, with each seed identified by an [Object identity Block ("OIB")](https://developer.blockchaincommons.com/oib/). You can click the right arrow on a seed to see more data about it and to export it (or a key derivation).

### Adjusting Settings

<a href="../images/st-settings.jpeg"><img src="../images/st-settings.jpeg" align="right" width=250></a>

The Settings page has five major options:

* **Default Network**. Choose "Main" or "Test" for different blockchain networks. This is used for key derivation, especially as the network for the default "Cosigner Public Key" and "Cosigner Private Key" options under Bitcoin. This is relevant for the Bitcoin and Ethereum networks, but not the Tezos network. (Default: Main.)
* **Primary Asset**. Choose "Bitcoin" (orange blob), "Ethereum" (green pyramids), or Tezos (stylized green t & z). This is used for address generation and key derivation. (Default: Bitcoin.)
* **Sync to iCloud**. Choose "On" or "Off". If "On", this exports your keys to your iCloud account, protected by a local encryption key. This ensures that you can restore your seeds to a new device if you lose your current one, provided you know your Apple ID password and the PIN of a previous device. (Default: On.)
* **Show Developer Function.** Swap toggle. If toggled "On", this will show you example requests, responses, and other features of interest to developers. See "Viewing Developer Options". (Default: Off.)
* **Erase All Data.** Click to erase all data, including data on your local device and in iCloud (if iCloud Sync is "on"). Be very certain you want to do this!

> :warning: **WARNING:** We highly suggest you leave iCloud backups "On". Without them, if you lose your phone, you will lose all of your seeds. The iCloud backups are encrypted, so no one but you should be able to access them.

> :warning: **WARNING:** Deleting your seeds through the Settings function of "Erase All Data" will entirely remove them: they will be gone! Your cloud data will also be removed, presuming that you have "Sync to iCloud" set to "On".

## Adding a Seed

Seeds can be imported or created. Seed importing is done via either the Scan button (which imports via camera or other automated means), the **add** button (which does so via cut-and-pasting), or through `ur:` links; seed creation is done through the **add** ("+") button.

### Scanning a Seed via Automated Means

<a href="../images/st-scan.jpeg"><img src="../images/st-scan.jpeg" align="right" width=250></a>

The **Scan** (qr code) button on the main menu provides the most automated methods for importing seeds, using your camera, the cut-and-paste Clipboard, the file system, your photo roll, or an NFC Tag.

To scan a QR code, you can:
* Point your camera at the QR of a seed, using the circular "flip" symbol to switch between front-facing and back-facing cameras if needed; or
* Import a QR of a seed from your "Photos"; or
* Choose an image of a QR from your "Files".

To scan text:
* Copy it into your Clipboard and click "Paste."

To scan an NDEF-encoded NFC:
* Select "NFC Tag" and point your device at the NFC Tag.

Note that these methodologies expect the QR code, the Clipboard, or the NFC Tag to contain a [Uniform Resource](https://developer.blockchaincommons.com/ur/), a standardized way to encode data in an efficient and self-identifying way. This will typically mean a [`ur:crypto-seed`](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-006-urtypes.md#cryptographic-seed-crypto-seed), or (preferably) an [Envelope](https://developer.blockchaincommons.com/envelope/).

Besides using these various methods on the scan page to import seeds, you can also use them to import SSKR shares (See "Importing SSKR Shares"), to respond to a Envelope request (see "Answering Seed & Key Requests"), or to respond to PSBT signing requests (see "Signing PSBTs"), as described below.

### Importing a Seed via Cut and Paste

The **add** ("+") button below the main menu gives a number of options for creating seeds in **Seed Tool**, but it also lets you input text as hex bytes, Bytewords, Crypto Seeds, SSKR, BIP39 words, or Envelopes. In each case, you just choose the data type, type or paste the data, and then click "Done".

The following show examples of the data you might import for each data type.

URs can either be imported via scan or add:

* **Envelope:** `ur:envelope/lstpcsgdhkwzdtfthptokigtvwnnjsqzcxknsktdoyadcsspoybdtpcskpfyhsjpjecxgdkpjpjojzihcxgdihiajecxhfinhsjzsbldpmve`
* **`ur:crypto-seed`:** `ur:crypto-seed/oyadgdhkwzdtfthptokigtvwnnjsqzcxknsktdhpyljeda`

Other data types must be imported via the correct link from "Add Seed".

* **Bytewords:** hawk whiz diet fact help taco kiwi gift view noon jugs quiz crux kiln silk tied omit keno lung jade
* **BIP 39 Mnemonic Words:** fly mule excess resource treat plunge nose soda reflect adult ramp planet
* **Hex Bytes:** 59 F2 29 3A 5B CE 7D 4D E5 9E 71 B4 20 7A C5 D2

Again, you can also add SSKR shares, as described below.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-paste-1.jpeg"><img src="../images/st-paste-1.jpeg" width=250></a>
        <br><div align="center"><b>Import Options</b></div>
      </center></td>
      <td>
        <a href="../images/st-paste-2.jpeg"><img src="../images/st-paste-2.jpeg" width=250></a>
        <br><div align="center"><b>Envelope Import</b></div>
      </center></td>
      <td>
        <a href="../images/st-paste-3.jpeg"><img src="../images/st-paste-3.jpeg" width=250></a>
        <br><div align="center"><b>Hex Import</b></d
      </center></td>
    </tr>
  </table>
</div>

### Importing SSKR Shares

<a href="../images/st-sskr-import.jpeg"><img src="../images/st-sskr-import.jpeg" align="right" width=250></a>

SSKR stands for Sharded Secret Key Reconstruction, a Blockchain Commons [specification](https://developer.blockchaincommons.com/sskr/). It allows you to shard a secret (such as a seed) into a number of shares, and then reconstruct the secret from some number (threshold) of those seeds that's typically fewer than all of them. For example, you might shard a seed into three shares with a threshold of two. SSKR shares can be used in one of two ways:

***Self-sovereign key recovery.*** You store shares in multiple, safe places, such as: in your safety deposit box, in your home-office safe, and in a locked drawer at work.

***Social key recovery.*** You give out shares to friends and family who are physically separated and who store them securely.

In either case, if a seed is lost, a threshold of shares can be collected (either on one's own or from friends and family) to reconstruct the seed.

**Gordian Seed Tool** can be used to collect together shares and reconstruct your seed. There are currently four ways to do so:

* **Scan: QRs.** Photograph QRs of SSKR shares until you have a threshold.
* **Scan: NFC Tags.** Import SSKR shares from NFC Tags, hitting the "NFC Tag" button once per share.
* **Scan: Paste Crypto-SSKR.** Paste `ur:crypto-sskr` of SSKR shares until you have a threshold.
* **Add: Shares.** Paste sufficient shares into the "add" box to meet a threshold

The `ur:crypto-sskr` specification, which can be used in the `Add` section, in the `Scan: Paste`, or encoded as a QR, look like this:

* ur:crypto-sskr/gobnbdaeadaevdbkclhseeehtldedikgpysoenreceeeeorofrwn
* ur:crypto-sskr/gobnbdaeadadrkhesefhjzdycypduokkjejponsayabguymwwnwz

The SSKR words, which can only be used in the `Add` section, look like this:

* tuna acid epic gyro gray tent able acid able frog cusp heat poem owls undo holy rich monk zaps cost brag loud fair dice idle skew iris beta tied
* tuna acid epic gyro gray tent able acid acid diet fact gala numb leaf fish toys kite cyan inky help keep heat inky song trip bulb flap yoga jazz

The **Scan** functionality is currently the more advanced of the two options, and so is the suggested methodology. It will allow you to photograph or paste individual shares, and will alert you to how many more are needed to meet the threshold and reconstruct the seed.

### Importing a Seed via `ur:`

Seed Tool recognizes external URLs with the `ur:` sceheme, including Envelopes. This means that when `ur:`s are accessed in other programs on your device, they will open appropriate in **Gordian Seed Tool**.

Possible external actions that will activate **Seed Tool** include:
<ul>
<li>Scanning a UR QR Code with the Camera app;
<li>Tapping a UR link in a web page;
<li>Pasting a UR into Safari's address bar;
<li>Tapping a UR link in text, such as in the Notes app;
<li>Tapping a UR in a URL field such as in the Contacts or Calendars apps; and
<li>Scanning a NDEF-formatted NFC tag containing a UR.
</ul>

Once a `ur:` has been opened in Seed Tool, import should continuie as normal.

### Creating a Seed

**Gordian Seed Tool** can also be used to create new seeds. This is doing using the **add** (+) button on the main menu. There are four ways to do so:

* **Quick Create.** Use your mobile device's randomization to create a seed.
* **Coin Flips.** Flip coins and enter results.
* **Die Rolls.** Roll six-sided dice and enter results.
* **Card Draws.** Draw cards and enter results. (Be sure to replace cards and reshuffle as you draw, for the entropy calculation to be correct.)

The easiest of these methods is certainly the "Quick Create", but in that case you are depending on the randomization of your mobile device, and if there is ever an exploit revealed, you'll be forced to sweep all of your funds. 

Using coin flips, die rolls, or playing cards is perhaps more likely to create good entropy, and is less likely to have an exploit revealed, but you _must_ properly flip every coin, roll every die, or draw every card, no matter how tedious it is, and you must wait until you have at least 128 bits of entropy, which is considered "Very Strong". If you are not willing to do this, you should just "Quick Create" instead. 

The coin flipping, die rolling, and card drawing methods all have three buttons at the bottom, which allow you to: erase one entry (back arrow); use the randomizer to add one entry (a die with a "1"); or use the randomizer to add all of the entries (a die with an "all"). The usage of coin (binary) and die entropy in **Gordian Seed Tool** matches that of [**Ian Coleman's BIP-39 Mnemonic Code Converter**](https://iancoleman.io/bip39/), so you can check the results there if you want to be sure of a new seed you've created. Our card draw technique is not identical to his.

Once you have a "Very Strong" amount of entropy, whichever method you used, you should click the "Done" button, and then you'll be given the opportunity to "Save" your new seed.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-coin.jpeg"><img src="../images/st-coin.jpeg" width=250></a>
        <br><div align="center"><b>Coin Flips</b></div>
      </center></td>
      <td>
        <a href="../images/st-die.jpeg"><img src="../images/st-die.jpeg" width=250></a>
        <br><div align="center"><b>Die Rolls</b></div>
      </center></td>
      <td>
        <a href="../images/st-cards.jpeg"><img src="../images/st-cards.jpeg" width=250></a>
        <br><div align="center"><b>Card Draws</b></div>
      </center></td>
    </tr>
  </table>
</div>


## Viewing a Seed

Once you have created a seed or imported it into **Gordian Seed Tool** it will be safely encrypted, and it will be securely backed up to iCloud as long as you've enabled iCloud's access to Keychain and iCloud Drive: all devices logged into the same iCloud account will show the same seeds.

### Displaying & Editing a Seed

You can view additional details of a seed by clicking the seed on the main menu.  The resulting page will show you the OIB, the bit size, the resultant strength, and the creation date. You can also edit the "Name", including clearing it or rerandomizing it, using the "..." button, or add "Notes".

This is also where you export information on the seed, either the public key, the private data, or the seed itself, as described in "Using a Seed" and "Exporting a Seed".

### Reading the OIB

Each seed is displayed with an [Object Identity Block (OIB)](https://developer.blockchaincommons.com/oib/), which can be seen on both the listing and view pages. It helps you to visually identify a seed.

An OIB contains the following elements:

* **LifeHash.** A [methodology](https://github.com/BlockchainCommons/lifehash.info/blob/master/README.md) for creating an evocative visual representation of data based on Conway's Game of Life. It makes it easy to recognize a seed at a glance.
* **Type.** An icon representing the type of data. On the listings and main views, this is a seed icon.
* **Abbreviated Digest.** The first 7 digits of the SHA256 digest of the object.
* **Master Fingerprint.** The Hash 160 of the master public key, used as the root of the derivation path.
* **Name.** A human-readable name for the seed. As a default, **Seed Tool** chooses a one-or-two word phrase based on the dominant color of the LifeHash followed by two random Bytewords. When you edit a Name you can click the "..." icon to re-randomize the name or to clear it.

The LifeHash, the type, the digest, the master fingerprint, and the color words in the default name should be identical anywhere that you import your seed to that uses the Blockchain Commons OIB specification. That will help you to know that your seed was accurately transmitted, and to ensure that you're working with the right seed.

OIBs are also displayed for various keys derived from your seed. They use different icons for the "type" and do not include a name, as seen in "Deriving a Key".

### Storing Output Descriptors

A seed's OIB page also allows you to store an Output Descriptor. This will allow you to record information on how the seed is being used in the Bitcoin network, so that you don't later have to guess (and guess and guess) about which derivation path and which sort of signature a seed's keys are involved with.

Once you've determined how a seed will be used, you can create an output descriptor from Authenticate > Derive Key > Other Key Derivations > Master Key > Output Descriptor. Choose the appropriate Output Type, export either a `ur:envelope` or text and then "Copy to Clipboard". You now have a minute to return to the main OIB page and paste that into the "Output Descriptor" space for the seed.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-view.jpeg"><img src="../images/st-view.jpeg" width=250></a>
        <br><div align="center"><b>OIB Page</b></div>
      </center></td>
      <td>
        <a href="../images/st-view-od.jpeg"><img src="../images/st-view-od.jpeg" width=250></a>
        <br><div align="center"><b>Adding Descriptor</b></div>
      </center></td>
      <td>
        <a href="../images/st-output-od.jpeg"><img src="../images/st-output-od.jpeg" width=250></a>
        <br><div align="center"><b>Creating Descriptor</b></div>
      </center></td>
    </tr>
  </table>
</div>

### Viewing Developer Functions

**Seed Tool** is an exemplar reference tool that is fully functional as a seed vault that can support responsible seed usage. It also provides functions to make it easier for developers to create apps of their own that embody the Gordian Principles. You can choose to enable these functions by selecting "Show Developer Functions" in the Settings.

There are currently four developer functions:

* **Show Example Request for this Seed.** Displays a `ur:envelope` that will request this seed. Available from the Seed view page.
* **Show Example Response for this Seed.** Displays a `ur:envelope` that answers a requests for this seed. Available from the "Authenticate" area of the Seed view page.
* **Show Request for this Key.** Displays a `ur:envelope` for a key. Available from the Key derivation page.
* **Show Request for this Derivation.** Displays a `ur:envelope` for a key's derivation. Available from the Key derivation page.
* **Show Response for this Key.** Displays a `ur:envelope` for a key. Available from the Key derivation page.

These functions allow developers to test Envelope request and response interactions with other wallets, by providing the QR they would use to request a seed and also displaying the QR response, so that they can double-check their work.

## Using a Seed

The main power of **Gordian Seed Tool** is that you can permanently store your seeds there, and instead give out keys or sign PSBTs, as needed.

### Answering Seed & Key Requests

The Blockchain Commons [Envelope request system](TBD) specifies how one app can request a certain type of data using an Envelope, and another app can send that requested data using an Envelope. **Gordian Seed Tool** is integrated with this standard: another app can request a seed or a specific derived key, and **Gordian Seed Tool** will send it (with your approval).

This is accomplished via the **Scan** (qr code) feature. Select it and import a Envelope request QR code through camera, Photos, or File, or else read it in through the Clipboard or an NFC Tag. You will be told what seed or key is being requested, and you can choose to approve it. If you do, you'll then be given a QR code that you can scan into the other app as the `ur:crypto-response`.

Although seeds can be requested via fingerprint, the biggest use of this function is to send a key that matches a derivation path requested by another application. For example, if an application needs a Segwit Cosigner key, it can request `48'/0'/0'/2'`, and the user doesn't have to know how to derive that themselves. This allows _any_ key derivation path to be easily accessed and shared.

After reading a request, the response can be sent via QR (often animated), via share sheets (see "Using Share Sheets"), or via NFC Tag (see ":warning: Using NFC Tags" for the dangers of doing so).

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-request-1.jpeg"><img src="../images/st-request-1.jpeg" width=250></a>
        <br><div align="center"><b>Seed Request</b></div>
      </center></td>
      <td>
        <a href="../images/st-request-2.jpeg"><img src="../images/st-request-2.jpeg" width=250></a>
        <br><div align="center"><b>Derivation Request</b></div>
      </center></td>
      <td>
        <a href="../images/st-request-3.jpeg"><img src="../images/st-request-3.jpeg" width=250></a>
        <br><div align="center"><b>Key Response/Request</b></div>
      </center></td>
    </tr>
  </table>
</div>

### Signing PSBTs

[TBD: This still needs to be edited and likely re-screenshot when PSBT legacy issues are resolved]

The goal of **Gordian Seed Tool** is to demonstrate how a seed may be kept in a protective and closely held device, such as your phone, but still actively used. One way is to export specific key derivations when they're required, as demonstrated above. However a safer method is to have the seeds and their keys _never_ leave your device. You can do this by receiving transactions as PSBTs, signing those within **Seed Tool**, and then exporting the signed result.

This can be done by reading a `ur:crypto-request` via QR code, Clipboard, or NFC Tag or by reading a binary .psbt file.

When you read a PSBT, a summary will show the following information:

* **In.** The amount of Bitcoins used as inputs for the transaction.
* **Sent.** The amount of Bitcoins being sent somewhere else in the transaction.
* **Fee.** The amount of Bitcoins used to pay network fees.
* **Change.** The amount of Bitcoins returned on a change address. _This is currently not being reported due to changes in our underlying library._ 

There is also additional information on everything but the fee.

* **Inputs.** Describes the number of inputs, their addresses, and their values. Will also show the keys in your Seed Tool needed to sign the UTXO(s) used in the PSBT.
* **Outputs.** Lists the number of outputs, which will typically be a Change address and a Sent address.
   * **Change.** Reveals the address and amount of money being sent back as change, as well as the signatures that will be required for that new UTXO. (Signatures associated with keys in Seed Tool will be fully described; others will not.)
   * **Sent.** Displays the address the rest of the funds are being sent to.

If you like everything you read in the Summary and additional information, you can **Approve**.

> :warning: **WARNING:** Seed Tool also allows you read in PSBTs using the `ur:crypto-psbt` specification, either scanned as QRs or read as text. This is primarily offered for backward compatibility, since `ur:crypto-psbt` was released prior to `ur:crypto-request`. It is not suggested for actual usage beyond testing because `ur:crypto-psbt` does not provide the full context of a PSBT. Read [our article on crypto-psbt vs. crypto-request](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/crypto-request-or-crypto-psbt.md) for why.

#### Outputting PSBTs

Obviously, once you have signed a PSBT, you will need to output it, so that you can pass it on to another app or Wallet, which can finish signing (if necessary) and/or send the transaction to the Bitcoin network. By default, Seed Tool will try to send back the PSBT in the same format that it received it, to maximize interoperability. This is ideally a `ur:envelope`, but for the sake of compatibility could be a `ur:psbt`, a `ur:crypto-psbt`, or a .psbt file. The data could be formatted as a QR code, output to an NFC Tag, or shared via share sheets.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-psbt-1.jpeg"><img src="../images/st-psbt-1.jpeg" width=250></a>
        <br><div align="center"><b>PSBT Info I</b></div>
      </center></td>
      <td>
        <a href="../images/st-psbt-2.jpeg"><img src="../images/st-psbt-2.jpeg" width=250></a>
        <br><div align="center"><b>PSBT Info 2</b></div>
      </center></td>
      <td>
        <a href="../images/st-psbt-3.jpeg"><img src="../images/st-psbt-3.jpeg" width=250></a>
        <br><div align="center"><b>PSBT Output</b></div>
      </center></td>
    </tr>
  </table>
</div>

Note that output PSBTs output as QRs *may* be animated. This is required for larger PSBTs, such as those that have been signed by multiple people, because of limitations in the size of PSBTs. The airgapped wallet that is receiving the signed PSBT will need to be able to recognize animated QR codes; if it can't, export via another of the methods, such as a binary .psbt file.

### Deriving a Key

If you want to use **Gordian Seed Tool** to derive a key (instead of outputting a derivation in response to an Envelope request or simply doing your signing in **Seed Tool** using PSBTs), you can do so by selecting a seed, choosing to "Authenticate" the "Encrypted Data", and then clicking the "Derive Key" button. The "Other Key Derivations" option will allow you to easily derive keys on testnet or mainnet for: Master Keys, Cosigner keys (48'/0'/0'/2' for mainnet or 48'/1'/0'/2 for testnet), or Segwit keys (84'/0'/0' for mainnet or 84'/1'/0' for testnet). Simply click the "Derivation Preset" that you prefer. You can also enter a "Custom" derivation by hand.

These various derivations will output a variety of keys for you:

* Most Bitcoin derivations will output a private HD key, a public HD key, and an address.
* A Bitcoin master key outputs the typical keys and address and also allows you to ouput an Output Descriptor (as a text descriptor or `ur:output`) and an Account Descriptor (as `ur:account`). Be sure to touch the "Share" button for access to all the export options.

The seed view page also contains quick buttons that just say "Cosigner Public Key" (at the top) and "Cosigner Private Key" (under the "Derive Key" button in the Encrypted Data). They derive a public or private Bitcoin Cosigner Key, using either Mainnet or Testnet, as recorded in your **Settings**.

After deriving a key, you can export it by using a QR code, by sharing a `ur:envelope` via a variety of means, by printing the `ur:envelope`, or by sharing the text of the Base58 encoding (`xprv` for traditional keys, `zprv` for segwit keys, see "Using Share Sheets"). Just tap the appropriate share button or touch-and-hold the element you want to share. For sharing text, see "Using Share Sheets" below.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-derive-1.jpeg"><img src="../images/st-derive-1.jpeg" width=250></a>
        <br><div align="center"><b>Public Key</b></div>
      </center></td>
      <td>
        <a href="../images/st-derive-2.jpeg"><img src="../images/st-derive-2.jpeg" width=250></a>
        <br><div align="center"><b>Bitcoin Derivation</b></div>
      </center></td>
      <td>
        <a href="../images/st-derive-3.jpeg"><img src="../images/st-derive-3.jpeg" width=250></a>
        <br><div align="center"><b>Ethereum Derivation (see below)</b></div>
      </center></td>
    </tr>
  </table>
</div>

Whenever you derive a key, you will be given a visual cue to remind you how much security is required by the key: export options for private keys appear in yellow, while export options for public keys appear in green.

### Sharding a Seed

SSKR sharding allow you to make a backup of your key that's not easily susceptible to attacks. You shard your key, you give out the shares to friends and family (or maintain them in separate locations of your own), and then if you ever lose your key you can reconstruct it by recovering a threshold of shares.

To create SSKR shares of your seed, go to the seed view, "Authenticate" to access your "Encrypted Data" and choose "Backup". Then select the "Backup as SSKR Multi-Share" option. We suggest you leave the format as "Gordian Envelope", because it includes metadata such as your seed's name and notes that might be vital when you restore it, but you could alternatively use the legacy `ur:sskr` format. Afterward, you can set a number of groups, a number of shares, and a number of thresholds to define your sharding. A number of default presets will probably suit you needs:

* **1 of 1:** A method for backing up your seed using just one share. It's very similar to backing up the Bytewords for the seed.
* **2 of 3:** Use this if you're not sure: it's probably the most common methodology. Place your three shares in three locations (or with three people) and then reconstruct by recovering two of them.
* **3 of 5:** An expansion of 2-of-3. If you've got more locations where you can store keys, or more friends, or both, or if you're a little less certain of the continued availability of any individual place or person, use this.
* **4 of 9:** A very large-scale sharding. This is most likely to be used in a corporate environment where different shares are kept by different personnel, but it could also be used by someone with a very large group of trusted friends.

You can also choose a more complex methodology with SSKR's "groups", which allows you to define multiple groups, then to set a threshold of a certain number of shares from a certain number of groups: for example, you could create 3 groups, with a group threshold of 2, then have each group include 3 shares, with a threshold of 2. You'd then be able to recover your seed from 4 of the 9 shares, as long as 2 each come from 2 different groups. (But, this is more complex than most people will need: just do something simple like a 2 of 3 sharding or a 3 of 5 sharding if the group sharding sounds like something you wouldn't know how to use).

* **2 of 3 shares, of two of three groups:** A complex "groups" situation, where you need two shares from two groups to recover. It may be more secure than a straight 4 of 9 because you can partition your keys to different groups of people to ensure that you can always recover and they can never collude.

A [Scenario Guide for SSKR Shares](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Sharing.md) explains more about why to use a particular scenario and how to get the best use of it. But, again, if that's too much, just use a 2-of-3 and make sure that each of the shares is separated physically from the others.

#### Exporting the Shares

After you create your SSKR shares, you have to export them, to make them available either to the people you'll be giving them to or to other places where you want to store them. After you've created your SSKR shares, you can either: export the shares individually as Envelopes, ByteWords, or QRs using share sheets; export the shares individually to NFC tags; print them individually or jointly as QRs and `ur:envelopes`; or export them jointly as ByteWords or Envelopes. You should answer the following questions to determine your favorite SSKR export method.

*Individually or Jointly?* The most secure way to export your SSKR shares is to do so individually, preferably by saving them to different MicroSD cards or to different NFC Tags. The saves to MicroSD card  can be done "Using Share Sheets", while saves to NFC Tags are available from the "NFC Tag" selector. Saving shares individually ensures that your shares are never in the same place once they leave **Gordian Seed Tool**, which is the optimal security methodology.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-sskr-ind-1.jpeg"><img src="../images/st-sskr-ind-1.jpeg" width=250></a>
        <br><div align="center"><b>Individual Export</b></div>
      </center></td>
      <td>
        <a href="../images/st-sskr-ind-2.jpeg"><img src="../images/st-sskr-ind-2.jpeg" width=250></a>
        <br><div align="center"><b>Individual NFC Export</b></div>
      </center></td>
      <td>
        <a href="../images/st-sskr-ind-3.jpeg"><img src="../images/st-sskr-ind-3.jpeg" width=250></a>
        <br><div align="center"><b>Individual NFC Write</b></div>
      </center></td>
    </tr>
  </table>
</div>

*QR, Envelope, or ByteWords?* You can store the words (whether you're exporting them individually or jointly) using QR codes, Envelope, or Bytewords. We suggest QR codes as a first choice because they're very easy to scan back into compatible seed stores. Envelopes are a second choice, but are still good because they're self-describing and self-verifying. Bare ByteWords may seem the most resilient, because they're words you can see, but they don't have the usability or resilience advantages of QRs or Envelopes.

*To Print or Not to Print?* Printing is the most convenient export methodology. The deficit of printing is that your shares could be compromised if your local network is compromised. Thus, you should _never_ print sufficient shares to allow the theft of your digital assets. If you're just printing shares for one key in a multisig, no problem, but if you have shares for a single-key account, or if you want to backup multiple keys for a multisig, do _not_ print all the shares.

There are two methodologies for printing:

With "Print All Shares" you will print individual sheets for each share, with an optional cover sheet. You'll also have the option to print any notes about the seed itself. This allows you to keep the cover sheet to track where all the shares are, and to give out the shares  on full-sized sheets of paper, which are much less likely to get lost. (As noted, printing them all together like this is _not_ secure.)

With "Export Shares Individually" you can choose to print one or more shares one at a time by choosing the "Print" button.

*How to Store?* For physical storage, we suggest printing on waterproof paper, or better, etching into steel. Saving individual shares to a MicroSD alternatively offers a resilient digital means for storing SSKR shares, but we suggest doing new writes to your MicroSD at least once a year and replacing your MicroSD cards every three years. Saving individual shares to NFC Tags is a newer method, and thus we're not as sure about the long-term benefits and deficits, so this feature is primarily intended for developers. But you may choose it because it's simpler than anything else. See ":warning: Using NFC Tags" for more cautions.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-sskr-export-1.jpeg"><img src="../images/st-sskr-export-1.jpeg" width=250></a>
        <br><div align="center"><b>SSKR Creation</b></div>
      </center></td>
      <td>
        <a href="../images/st-sskr-export-2.jpeg"><img src="../images/st-sskr-export-2.jpeg" width=250></a>
        <br><div align="center"><b>SSKR Export</b></div>
      </center></td>
      <td>
        <a href="../images/st-sskr-export-3.jpeg"><img src="../images/st-sskr-export-3.jpeg" width=250></a>
        <br><div align="center"><b>SSKR Print</b></div>
      </center></td>
    </tr>
  </table>
</div>

Be sure that anyone receiving shares knows to return them only after receiving live visual or voice confirmation from you, and to send them via an encrypted channel, such as Signal. An in-person meeting is even better, because it resolves most threats that come about through the reconstruction of a seed. See [The Dangers of Secret-Sharing Schemes](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Dangers.md) for why this is important.

### 2FAing Your Requests

<a href="../images/st-2fa.jpeg"><img src="../images/st-2fa.jpeg" align="right" width=250 style="border:1px solid black;"></a>
Any time you request private data, such as your seed or private keys derived from your seed, **Gordian Seed Tool's** two-factor authentication (2FA) will go into effect.

The first authentication factor was entered by you when you logged into your Apple ID the first time that you used **Seed Tool.**

The second authentication factor is applied whenever you access private data, most frequently by choosing to "Authenticate" to access your Encrypted Data. Usually, you will enter a thumbprint, but on a newer iPhone you will use Face ID and on most Mac systems you will enter a password.

This ensures that even if someone acquires your device in an unlocked mode, they won't be able to get to your seed data.

## Exporting a Seed

You should be able to safely and securely use your seed within **Gordian Seed Tool** by responding to Envelope requests, by signing PSBTs, and by deriving keys. However, if you want to some day export the whole seed, you can.

A seed can be exported by touching the "Authenticate" box under the "Encrypted Data" section of a seed. This will, as usual, require your 2FA. After it decrypts, you can then click the "Share" button. This will allow you to share as Gordian Envelope, as ByteWords, as BIP39 Words, or as Hex.

**Human-Readable Exports:**
* **BIP39 Mnemonic Words:** The mostly widely used human-readable specification. Use this as a backup if you might need to later import the seed to an older wallet.
* **ByteWords:** Blockchain Commons' [human-readable specification](https://developer.blockchaincommons.com/bytewords/). It was constructed to maximize the ability to remember the words and to minimize the ability to confuse them. This is a preferred backup method if you'll later be importing into a modern wallet, such as a Gordian app.

**Computer-Readable Exports:**
* **Hex:** The mostly widely used computer-readable specification. Use this if you plan to export to an older wallet.
* **Envelope:** Blockchain Commons' UR computer-readable specification. This is the best export method for modern wallets that support Uniform Resources, including Gordian apps, because it will also preserve metadata such as data of creation and notes.

These functions will all allow you to share your data as described in "Using Share Sheets", below. 

In addition, you can choose "Backup" to share your seed in an envelope or with SSKR shares by a few additional means, including displaying a QR for scanning, writing to an NFC Tag (see ":warning: Using NFC Tags" for the dangers of doing so), or printing.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-export-1.jpeg"><img src="../images/st-export-1.jpeg" width=250></a>
        <br><div align="center"><b>Export: Backup</b></div>
      </center></td>
      <td>
        <a href="../images/st-export-2.jpeg"><img src="../images/st-export-2.jpeg" width=250></a>
        <br><div align="center"><b>Export: Print</b></div>
      </center></td>
      <td>
        <a href="../images/st-export-3.jpeg"><img src="../images/st-export-3.jpeg" width=250></a>
        <br><div align="center"><b>Export: Share</b></div>
      </center></td>
    </tr>
  </table>
</div>

> :warning: **WARNING:** Generally, you want to always keep your seeds in **Seed Tool**. A seed is both secure and resilient in the app. There is no reason to export it. Instead, sign PSBTs or export keys as appropriate — ideally watch-only public keys or specific derived keys in response to a request from another app.

## Deleting a Seed

If you're done with a seed or if you've exported it to another app or device, you may then want to delete it.

Seeds can be deleted with the "Edit" function on the main page or by swiping left on a seed in that listing. You can immediately "Undo" a deletion (circle back arrow) if you deleted the wrong seed, and you can then "Redo" it (circle forward arrow), but as soon as you make any other change (such as adding a new seed or even resorting your seeds), any seed you deleted will be gone forever. Be careful!

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-delete-1.jpeg"><img src="../images/st-delete-1.jpeg" width=250></a>
        <br><div align="center"><b>Delete</b></div>
      </center></td>
      <td>
        <a href="../images/st-delete-2.jpeg"><img src="../images/st-delete-2.jpeg" width=250></a>
        <br><div align="center"><b>Undo Delete</b></div>
      </center></td>
      <td>
        <a href="../images/st-delete-3.jpeg"><img src="../images/st-delete-3.jpeg" width=250></a>
        <br><div align="center"><b>Redo Delete</b></div>
      </center></td>
    </tr>
  </table>
</div>

You can also remove all seeds, including those in iCloud (assuming iCloud Sync is On), with the "Erase All Data" button in the Settings menu.

## Integrating with Ethereum

If you use seeds with Ethereum instead of Bitcoin, you can set that as your default view by choosing "Ethereum" as your "Primary Asset" under **Settings**.

This will cause some changes in functionality.

### Viewing an Ethereum Seed

When you "View a Seed", you will see a new option for "Ethereum Address", which will reveal the Ethereum address associated with the seed.

### Exporting an Ethereum Seed

When you choose to "Derive Key" from a Seed after you "Authenticate", you will see new options related to Ethereum.

1. Deriving an "Ethereum Private Key" will provide the standard Ethereum Private Key.
2. Choosing "Other Key Derivations" will allow you to export a "Master Key", a "44'/60'/0'/0/0" derived key, or a custom derivation for Ethereum. Each choice will depict four options: Ethereum Private Key, Ethereum Address, Private HD Key, and Public HD Key.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-eth-1.jpeg"><img src="../images/st-eth-1.jpeg" width=250></a>
        <br><div align="center"><b>Settings</b></div>
      </center></td>
      <td>
        <a href="../images/st-eth-2.jpeg"><img src="../images/st-eth-2.jpeg" width=250></a>
        <br><div align="center"><b>Address</b></div>
      </center></td>
      <td>
        <a href="../images/st-eth-3.jpeg"><img src="../images/st-eth-3.jpeg" width=250></a>
        <br><div align="center"><b>Derivations</b></div>
      </center></td>
    </tr>
  </table>
</div>

### Reading the Blockies

For the Ethereum Private Key and Address, the "blockie" associated with the address is shown rather than a LifeHash. This is a [widely used specification](https://www.npmjs.com/package/ethereum-blockies) that much like LifeHash provides a visual representation. However, rather than being available for any key or  seed, a blockie is always associated with the Ethereum address.

## Integrating with Tezos

If you use seeds with Ethereum instead of Bitcoin, you can set that as your default view by choosing "Tezos" as your "Primary Asset" under **Settings**.

This will cause some changes in functionality.

### Viewing a Tezos Seed

### Exporting a Tezos Seed

[TBD: What does this show, other than Tezos private key & address?]
[TBD: are there new defaults to replace 'cosigner public key' and 'cosigner private key'?]
[TBD: Do the HD Keys belong here?]
[TBD: need pics when things are finalized]

## Using Seed Tool for Transactions

**Seed Tool** can be used to store seeds for live transactions by taking advantage of its Request and PSBT capabilities. See [Integrating Seed Tool with Other Apps](Integration.md) for real-life examples of **Seed Tool** use.

## Outputting Data

Methods for outputting data are available throughout **Seed Tool**, including QR codes, text, files, printing, and using NFC Tags. The following notes cover the specifics of some of those.

### Using Share Sheets

A Share Sheet pops up when you touch and hold certain elements (such as parts of the OIB or the QR code) or when you click certain 'share' buttons. This lets you share text or graphics for derived keys, SSKR shares, seeds, and PSBTs. To start with, you can share via apps that have sharing capabilities, such as Airdrop, Messages, and Mail. We suggest sharing via an encrypted app, such as Signal. 

If you scroll down on the sharing page, you can also "Copy to Clipboard", "New Quick Note", "Save to Files", and "Print" for text and a number of additional options for non-animated graphics such as simple QR codes and LifeHashes. Of these, "Save to Files" can be particularly powerful because it allows saving data to a backed up location, such as an iCloud drive, or even to an attached MicroSD card if you have an appropriate adapter. Obviously, you should be sure that any private information is only backed up to a secure location: MicroSD cards are a particularly good option.

<div align="center">
  <table border=0>
    <tr>
      <td>
        <a href="../images/st-save-clipboard.jpeg"><img src="../images/st-save-clipboard.jpeg" width=250></a>
        <br><div align="center"><b>Clipboard</b></div>
      </center></td>
      <td>
        <a href="../images/st-save-print.jpeg"><img src="../images/st-save-print.jpeg" width=250></a>
        <br><div align="center"><b>Print</b></div>
      </center></td>
      <td>
        <a href="../images/st-save-file.jpeg"><img src="../images/st-save-file.jpeg" width=250></a>
        <br><div align="center"><b>File</b></div>
      </center></td>
    </tr>
  </table>
</div>

### Using NFC Tags

:warning: NFC Tags are a relatively fresh technology. There are some raw edges in their usage: we don't know a lot about their long-term durability and we haven't entirely modeled the security repercussions of their usage. We _do_ know that the data being written to the Tags is not currently encrypted in any way. It's thus theoretically possible for someone with a strong antenna to read your NFC Tag, without you ever knowing they're doing so.

:warning: Please consider all NFC features _experimental_ at this time. They are primarily intended for _developers_. If you do choose to use them because of their ease-of-use, we strongly suggest against putting complete information for a secret on a Tag. Though they may work well for encoding individual SSKR shares (as long as they are seperated!) or for sending back signed PSBTs, encoding a private key or a seed on an NFC Tag could endanger it, and definitely should not be done if you have large holdings associated with that key or seed.

A few additional caveats about their usage:

* Writing to a _large_, previously unused NFC Tag will not initially work from **Seed Tool**, which uses the standard Apple toolkit. We've had no problems with Tags up to 924 bytes, but failures with those at 8 kbytes. If you have a large tag that **Seed Tool** times out when writing to, we suggest writing an initial record with the free [NFC Tools](https://apps.apple.com/us/app/nfc-tools/id1252962749). Afterward, you'll be able to read and write fine from **Seed Tool**. Resolving this problem, important to allow easy writing of large seeds and PSBTs, is on our [TODO list](https://github.com/BlockchainCommons/GordianSeedTool-iOS/issues/173).
* Writing to an NFC Tag may sometimes result in a "Stack Error". This is a standard Apple error that usually means that you weren't able to hover your phone in the correct proximity to the Tag within the time limit. Try again and the write will probably be successful. (This can also show up, less frequently, when reading.)
* The life-time of unpowered NFC Tags may be as long as 10 years. They should be replaced every 2-3.

## Appendix I: Threat Modeling

**Gordian Seed Tool** is built on a standard [#SmartCustody threat model](https://www.smartcustody.com/): the Gordian reference applications prioritize the management of risks and adversaries based on our assessment of the ones most likely to affect an average or sophisticated user in a first-world country. It focuses on the following #SmartCustody adversary categories:

* **Loss by Mistakes.** Making mistakes, particularly losing keys or seeds, is likely the main source of digital-asset loss for independent users. **Seed Tool** is thus all about resilience: protecting your keys from loss.
* **Loss by Acts of God.** The resilience of **Seed Tool** will also protect your seeds from many natural disasters, because they can be restored if your computing device is lost.
* **Loss by Theft.** There are many ways that your keys could be stolen, though these problems are more likely to affect large institutions. Nonetheless, **Seed Tool** helps to protect you against _external_ theft, particularly Network Attacks, by keeping your seeds in a closely held device. It does not necessarily protect against _internal_ theft, including Institutional Theft, which is discussed below.
* **Privacy-Related Problems.** **Seed Tool** gives some attention to privacy-related problems, as knowledge of your funds is protected by the app itself.

We have explicitly chosen "Loss by Institutional Theft" and "Loss by Government" as categories that we do not additionally guard against.

* **Loss by Institutional Theft.** To be specific, we trust the platform, which is currently Apple. We believe that their methods of encryption are not just secure, but also have a lower chance of systemic compromise than something that we might hand code. We additionally believe that their incentives for maintaining that security are much higher than any incentives to purposefully break it — and that they've proven that in the past through stand-offs with spy agencies.
* **Loss by Government.** Though we don't necessarily trust the government, we do believe that digital assets would be the least of one's problems if a government were acting against an individual. We say this with a caveat: our risk model presumes a law-abiding non-authoritarian government. That means that our risk model, and thus our reference apps, may not be secure in an authoritarian regime, such as in China where [Apple has been required to store iCloud data within the country](https://www.datacenterknowledge.com/apple/apples-icloud-china-set-move-state-controlled-data-center), making it vulnerable to covert or overt seizure.

Usage of specific features could cause the activation of other threats:

* **Loss through Convenience.** We have chosen some features that introduce a Convenience threat, where we potentially decrease the security of **Seed Tool** in order to increase its usability. One of these Convenience threats comes about through the use of the Clipboard to transmit key material. We consider this a minor threat as other apps can read the Clipboard; with Universal Clipboard enabled, this can even be the case for apps on your other machines logged in to the same iCloud account. Similarly, the Share Sheets allow sharing via methodologies that may not be secure, such as Mail and Messages. If you consider Clipboard a larger threat, do not use it to import key material, instead depending on hand entry or use of the Camera. When sharing via the Share Sheets, you should use methods that are encrypted and safe, such as Signal.
* **Loss through Personal Network Attack.** The gathering of shares to reconstruct a seed _always_ represents a threat where someone might steal and use your seed before or as you reconstruct it, as discussed in [The Dangers of Secret-Sharing Schemes](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Dangers.md). An adversary could intercept your shares as they're being returned (so use an encrypted channel, or do it in person), and an adversary could compromise the computer where you're reconstructing the seed (so do it on an offline device, if possible).

## Appendix II: Other Tools

Power users may wish to use our command-line tools for manipulating seeds.

* [**seedtool-cli.**](https://github.com/BlockchainCommons/seedtool-cli) — A CLI tool for generating seeds and outputting them in a variety of formats.
* [**keytool-cli.**](https://github.com/BlockchainCommons/keytool-cli) — A CLI tool for deriving a variety of keys from a seed.
