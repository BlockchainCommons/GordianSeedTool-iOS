# Testing Gordian Seed Tool

This is step by step that guides a tester through the [Testing](https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing) environment of Gordian **Seed Tool**.
It's aimed at the novice user of Seed Tool.
adding seeds, storing seeds, using seeds, exporting seeds, and removing seeds.


**Buckle up, we're going through an exciting journey towards safe, resilient and fun key management!**

## Preparatory work
1. Read the [Readme] (../README.md) about Gordian Seed Tool
2. [Install](./MANUAL.md#installing-seed-tool) Gordian Seed Tool on at least one of the available platforms
3. Check wether you have any Questions that have been posed already in the [Q&A](./Q-and-A.md) and/or whether you have any terms that you'd like to be sure of how we've defined them in the context of Gordian Seed Tool in the list of [definitions and abbreviations](./Definitions.md).

**All set? Let's go forward!**

## Testing material
The directory [Testing](https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing) contains input QR-codes, keys, etc.\
The examples below will link to input docs and images directly. Please report if any file is missing or links broken.

# Step by step
We're going through the process laid out in this document with predictable and measurable results and will train the basic operations for **Seed Tool** at the same time.
1. add seeds, 
2. store seeds, 
3. use seeds, 
4. export seeds, 
5. remove seeds.

WM: To test the app's scanning capabilities, you can find a PDF containing a "ur:crypto-seed" QR code attached, or at this URL: https://github.com/BlockchainCommons/GordianSeedTool-iOS/blob/master/Testing/DPAL%20Seed.pdf

WM: * For compatibility testing with third-party wallets that have already implemented this, a bare `ur:crypto-psbt` may now be scanned and signed. Using `ur:crypto-request` is Blockchain Commons' recommended method for requesting PSBT signing, so when a bare `ur:crypto-psbt` is scanned, users are notified of this, thus this capability should be used only for developer compatibility testing and developers are encourage to adopt `ur:crypto-request` as soon as possible. 
* When a `ur:crypto-psbt` is scanned, two possible outputs are offered: the signed bare `ur:crypto-psbt` and a dummy `ur:crypto-response`. This is a "dummy" response because it is not actually a response to a particular `ur:crypto-request` and thus the transaction ID included in the response is random and does not correspond to any actual prior request.
* Two new example QR codes have been added to the [Testing](https://github.com/BlockchainCommons/GordianSeedTool-iOS/tree/master/Testing) folder: `Bare PSBT 1 of 2.png` and `Bare PSBT 2 of 2.png` which can be used to test the bare PSBT signing capability. These are the same transactions also provided in `ur:crypto-request` form.