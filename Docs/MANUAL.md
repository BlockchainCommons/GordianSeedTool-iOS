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

## Install Seed Tool

You can either purchase **Gordian Seed Tool** from the Apple store or you can compile from the source here.

For full functionality of the iCloud backup, be sure to turn on the following functionality under "Settings > Apple ID > iCloud" on all devices running **Gordian Seed Tool**:

* Keychain
* iCloud Drive

Be _very_ sure that all devices running **Gordian Seed Tool** are fully logged into your Apple account, with full access to iCloud, and switches set as noted above. Failure to do so will either result in Seed entries not being synced to the iCloud (and other devices).

## Using Seed Tool
