# What is Key Derivation?

The core idea of seeds is that they can be used to create (derive) a whole hierarchy of keys based on the [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) specification for a Hierarchical Deterministic (HD) wallet. One seed leads to many keys (and thus many addresses).

To derive a key requires a derivation path. This describes which precise key you're talking about of the infinite keys that could be derived from a specific seed. A derivation path typically looks like this:

```
[604b93f2/84'/0'/0'/2]
```

The first number (`604b93f2` in this example) is the fingerprint of the master key, which is not the seed, but derived *from* the seed. The rest is the derivation path proper, which was defined by [BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki). It explains the steps to derive a particular key: in this case the derivation path refers to the second key of the zeroth key of the zeroth key of the eighty-fourth key derived from the master key. (This is the Native Segwit Multisig Cosigner derivation path.)

However, the derivation path is more than just a listing of how to get to a key. It also defines what the meaning of each derivation step is. Per BIP-44, the traditional meaning is:

```
m / purpose' / coin_type' / account' / change / address_index
```

In other words, this example not only shows the precise derivation of a key, but also defines that key as follows:

* `84'` = purpose: Native Segwit
* `0'` = coin_type: 0=Bitcoin, 60=Ethereum, 1=TestNet
* `0'` = account: The first account for this key
* `0` = change: Not change
* 
Individual keys could then be created as individual indices from that derivation path, for example:

* `m/84'/0'/0'/0/0`
* `m/84'/0'/0'/0/1`
* `m/84'/0'/0'/0/2`

The `'`s in a path refer to “hardening”, which makes that level of keys more secure.

Some newer derivation paths have slightly evolved the traditional categorization. In the case of the `48'` derivation, the step originally meant for change now refers to what type of address is used:

* `0'` = Legacy
* `1'` = Nested Segwit
* `2'` = Native Segwit

Putting together a seed and a derivation path is deterministic: everyone will always derive the same public and private key from that combination, but the keys cannot be used to predict other keys, nor backtrack to the seed. Instead, they each appear to be entirely discrete, except to the seed holder.
