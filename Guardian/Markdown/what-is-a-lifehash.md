# What is a LifeHash?

Being long random numbers, seeds are difficult to tell apart at first glance. Our brains aren't equipped to distinguish one long string of numbers from another quickly or accurately.

A LifeHash is a small picture that helps you recognize seeds and other digitial objects at a glance. You can think of it as the object's unique visual "fingerprint". Just like a real fingerprint is something unique about a person, but isn't a whole person, you can't reconstruct a seed from just its LifeHash. Unlike a QR code, which can encode any digital data, a LifeHash is *produced* from data, but doesn't actually *encode* any data that can be decoded.

**Gordian Guardian** uses LifeHashes to help you quickly identify seeds and other objects. Once you generate a seed, it will *always* have the same LifeHash regardless of its name or other metadata. Other apps and systems that generate LifeHashes from data should use the same methods so when you transmit your seed, or a key generated from your seed to someone else, their LifeHashes should match exactly.

The code to produce LifeHashes is open source by Blockchain Commons, and you're welcome to use it in your own software. Visit the [LifeHash GitHub repo](https://github.com/BlockchainCommons/bc-lifehash) for more information.
