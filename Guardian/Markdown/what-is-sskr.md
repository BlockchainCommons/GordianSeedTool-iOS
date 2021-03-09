# What is SSKR?

Sharded Secret Key Reconstruction (SSKR) is a method of taking a secret (like a seed) and breaking it up into pieces called *shards*. The secret can then be backed up by providing trustees with copies of the various shards. Gathering enough of the shards together enables the reconstruction of your original secret. Since your trustees each only have one shard, they cannot recover your seed. Since your trustees don't all know each other, they can't collude to steal your seed.

**Gordian Guardian** lets you export your seeds to SSKR shards, and recover your seeds from them again.

You decide:

* How many groups of shards to create.
* How many groups (the "threshold") you need to collect shards from.

For each group you decide:

* How many shards are in the group.
* How many shards (the "threshold") you need to collect from the group.

In a simple case, you create one group with three shards and a threshold of two ("2-of-3"). You give one shard to each of your three trustees. In the event you need to recover your seed, you only need to recover two out of the three shards to recover your seed.

Many other configurations are possible depending on your key recovery strategy.

Blockchain Commons provides [open source code to perform Sharded Secret Key Reconstruction](https://github.com/blockchaincommons/bc-shamir) as well as a [UR type definition](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-011-sskr.md) ("`ur:crypto-sskr`") used to transport SSKR shards.
