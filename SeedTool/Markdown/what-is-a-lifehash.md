# What is a LifeHash?

LifeHash solves the problem of distinguishing cryptographic seeds. On their own, seeds are difficult to tell apart at first glance because they're long random numbers, and our brains aren't equipped to distinguish one long string of numbers from another quickly or accurately.

A LifeHash is a small picture that helps you recognize seeds and other digitial objects at a glance. You can think of it as the object's visual "fingerprint". That means that it's unique, but it doesn't encode the entire object: you can't reconstruct a seed from just its LifeHash. That's because a LifeHash is *produced* from data, but doesn't actually *encode* any data that can be decoded — which is unlike a QR code, which can encode any digital data.

**Gordian Seed Tool** uses LifeHashes to help you quickly identify seeds and other objects. Once you generate a seed, it will *always* have the same LifeHash regardless of its name or other metadata. Other apps and systems that generate LifeHashes from data should use the same methods so when you transmit your seed, or a key generated from your seed, to someone else, their LifeHashes should match exactly.

The code to produce LifeHashes is open source from Blockchain Commons, and you're welcome to use it in your own software. Visit the [LifeHash GitHub repo](https://github.com/BlockchainCommons/bc-lifehash) for more information. There is also an [online demonstration of LifeHash](http://lifehash.info).
