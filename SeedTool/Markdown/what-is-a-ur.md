# What is a UR?

A "Uniform Resource" or *UR*, is a way of encoding binary data in a format that is suitable for transmission as plain text or inside a QR code. URs are a type of Uniform Resource Identifier (URI) and look similar to the web `http:` URL addresses you're familiar with. Unlike a web address, which *points* to a resource on the Internet, a UR is *itself* a complete resource. 

URs always begin with prefixes to identify their contents. In the case of seeds, that prefix is `ur:seed`.

## URs Have Rich Internal Structure

URs are structured internally as CBOR, which you can think of as "JSON in binary instead of text." This means that CBOR objects can contain metadata about the object as well as sub-objects. For instance, `ur:seed` URs can contain more than just the seed data; they also can optionally contain the seed creation date, the name of the seed, and notes about the seed. This ability to embed rich, self-identifying binary objects inside of a text string is one of the key advantages of URs.

## URs Can Be Broken into Multiple Parts

Text URs can be as long as necessary, but QR codes have limited capacity. To accomodate this, the UR specification provides a way to break up long binary objects into *parts* that can be shown together as an animated QR code. This enables devices that don't have or share a network connection to transfer larger binary objects like Partially Signed Bitcoin Transactions (PSBTs) using only their screen and camera.

## Learn More

The UR specification, UR implementations for various languages, and the list of binary types supported by URs is growing all the time, powered by the community around Blockchain Commons. To learn more, visit the [UR specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md), the [list of registered UR types](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-006-urtypes.md), and the [CBOR](https://cbor.io/) specification.
