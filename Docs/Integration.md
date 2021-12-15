# Integrating Seed Tool with Other Apps

One of the primary goals of **Gordian Seed Tool** is to use it to store seeds which can then be used by separate wallets. This allows for the secure and resilient storage of your seeds while still maintaining high usability.

There are two primary ways to do this: a seed can be stored in **Gordian Seed Tool**, then specific key derivations can be released as needed; or the seed can be stored in Seed Tool and it can be used to sign PSBTs as required. The latter is more secure.

## Integrating Seed Tool with Sparrow

[Sparrow](https://sparrowwallet.com/) is a self-sovereign software wallet created by [Craig Raw](https://github.com/craigraw) that is using some of Blockchain Commons' [Uniform Resources](https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/ur-1-overview.md).

### Creating a Multisig Address on Sparrow

One of the best methods of [#SmartCustody](https://github.com/BlockchainCommons/SmartCustody) is to create a multisig wallet where each key for the wallet is held securely. 

To do so in Sparrow, select the "Create New Wallet" button or choose "File->New Wallet" from the menu bar. Enter a name for the Wallet and then choose a "Multi Signature" policy with 2 of 3 M of N.

You can now create (or access) a seed in Seed Tool. View the seed and request the "Cosigner Public Key". This will give you a QR code for the `ur:crypto-hdkey` of the Cosigner derivation (`m/48'/0'/0'/2`) along with the fingerprint and that derivation path.

In Sparrow you can import this as your "Keystore 1", the first of the three keys that will lock your wallet:

1. Select "New or Imported Software Wallet"
2. Choose "xpub / Watch Only Wallet", to keep the seed and key in Seed Tool.
3. Enter the 8-digit master fingerprint and `m/48'/0'/0'/2` as the derivation
4. Click the camera button and view the QR code displayed by Seed Tool. This will translate the `ur:crypto-hdkey` into an `xpub`

Afterward, you will need to import or create two other seeds or HD keys as "Keystore 2" and "Keystore 3". Each of the key-storage devices should be physically separated. One method to do so is to use one or more hardware devices. This is easily done with hardware wallets, which can be connected to your computer and their keys imported as "Connected Hardware Wallet" or via newer "Airgapped Hardware Wallets" such Keystone or the Foundation Devices Passport.

Once you have imported these additional keys, you should see a descriptor something like the following:
```
 wsh(sortedmulti(2,SeedToolWO,TrezorT,LedgerNanoS))
```
You can then "Apply" to finalize your wallet. The "Receive" button will then reveal an address to which you can send funds.


