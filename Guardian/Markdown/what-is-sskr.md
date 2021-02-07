# What is SSKR?

Shamir Secret Key Recovery (SSKR) is a method of taking a secret (like a seed) and breaking it up into pieces called *shares*. The secret can then be backed up by providing trustees copies of the various shares. Gathering enough of the shares back together enables the recovery of your original secret. Since your trustees each only have one share, they cannot recover your seed. Since your trustees don't all know each other, they can't collude to steal your seed.

**Gordian Guardian** lets you export your seeds to SSKR shares, and recover your seeds from them again.

You decide:

* How many groups of shares to create.
* What threshold of groups you need to collect shares from.

For each group you decide:

* How many shares are in the group.
* What threshold of shares you need to collect from the group.

In a simple case, you create one group with three shares and a threshold of two ("2-of-3"). You give one share to each of your three trustees. In the event you need to recover your seed, you only need to recover two out of the three shares to be able to recover your seed.

Many other configurations are possible depending on your key recovery strategy.

Blockchain Commons provides [open source code to perform Shamir Secret Key Recovery](https://github.com/blockchaincommons/bc-shamir) as well as a [UR type definition](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-011-sskr.md) ("`ur:crypto-sskr`") used to transport SSKR shares.
