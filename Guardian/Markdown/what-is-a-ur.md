# What is a UR?

A "Uniform Resource" or *UR*, is a way of encoding any binary data in a format that is suitable for transmission as plain text or inside a QR code. URs all begin with `ur:` and look similar to web `http:` addresses you're familiar with. But unlike web addresses that *point* to a resource on the Internet, a UR is *itself* a complete resource. In the case of seeds, URs begin with `ur:crypto-seed` to help you identify their contents.

Text URs can be as long as necessary, but QR codes have limited capacity. So the UR technology also provides a way to break up long binary objects into *parts* that can be shown as an animated QR code. This enables devices that don't have or share a network connection to transfer larger binary objects like Partially Signed Bitcoin Transactions (PSBTs) using only their screen and camera.

The UR specification, UR implementations for various languages, and the list of binary types supported by URs is growing all the time, powered by the community around Blockchain Commons. To learn more, visit the [UR specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md) and the [list of registered UR types](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-006-urtypes.md).
