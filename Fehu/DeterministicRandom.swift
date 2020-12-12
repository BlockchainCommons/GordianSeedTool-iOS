//
//  HKDFSHA256.swift
//  Fehu
//
//  Created by Wolf McNally on 12/11/20.
//

import Foundation
import CryptoBase

//    ByteVector deterministic_random(const ByteVector &entropy, size_t n) {
//        ByteVector result;
//        result.resize(n);
//
//        auto seed = sha256(entropy);
//
//        hkdf_sha256(result.data(), n,
//        NULL, 0, // no salt
//        seed.data(), SHA256_DIGEST_LENGTH,
//        NULL, 0); // no info
//
//        return result;
//    }

func deterministicRandom(entropy: Data, count: Int) -> Data {
    let seed = sha256(data: entropy)
    return hkdfSha256(input: seed, count: count)
}

fileprivate func hkdfSha256(salt s: Data = .init(), input k: Data, info: Data = .init(), count: Int) -> Data {
    let digestLength = 32

    assert(count < 255 * digestLength)

    /* RFC 5869:
     *
     * 2.2.  Step 1: Extract
     *
     *   HKDF-Extract(salt, IKM) -> PRK
     *
     *    Options:
     *       Hash     a hash function; HashLen denotes the length of the
     *                hash function output in octets
     *
     *    Inputs:
     *       salt     optional salt value (a non-secret random value);
     *                if not provided, it is set to a string of HashLen zeros.
     *       IKM      input keying material
     *
     *    Output:
     *       PRK      a pseudorandom key (of HashLen octets)
     *
     *    The output PRK is calculated as follows:
     *
     *    PRK = HMAC-Hash(salt, IKM)
     */

    //    if(s == NULL || ssize == 0) {
    //        uint8_t a[SHA256_DIGEST_LENGTH];
    //        memset(a, 0, SHA256_DIGEST_LENGTH);
    //        hmac_sha256(a, SHA256_DIGEST_LENGTH, k, ksize, prk);
    //    } else {
    //        hmac_sha256(s, ssize, k, ksize, prk);
    //    }

    let prk: Data
    if s.isEmpty {
        prk = hmacSHA256(key: Data(repeating: 0, count: digestLength), message: k)
    } else {
        prk = hmacSHA256(key: s, message: k)
    }

    /*
     * 2.3.  Step 2: Expand
     *
     *    HKDF-Expand(PRK, info, L) -> OKM
     *
     *    Options:
     *       Hash     a hash function; HashLen denotes the length of the
     *                hash function output in octets
     *
     *    Inputs:
     *       PRK      a pseudorandom key of at least HashLen octets
     *                (usually, the output from the extract step)
     *       info     optional context and application specific information
     *                (can be a zero-length string)
     *       L        length of output keying material in octets
     *                (<= 255*HashLen)
     *
     *    Output:
     *       OKM      output keying material (of L octets)
     *
     *    The output OKM is calculated as follows:
     *
     *    N = ceil(L/HashLen)
     *    T = T(1) | T(2) | T(3) | ... | T(N)
     *    OKM = first L octets of T
     *
     *    where:
     *    T(0) = empty string (zero length)
     *    T(1) = HMAC-Hash(PRK, T(0) | info | 0x01)
     *    T(2) = HMAC-Hash(PRK, T(1) | info | 0x02)
     *    T(3) = HMAC-Hash(PRK, T(2) | info | 0x03)
     *    ...
     *
     *    (where the constant concatenated to the end of each T(n) is a
     *    single octet.)
     */

    //    c = 1;
    //    hmac_sha256_Init(&ctx, prk, sizeof(prk));
    //    hmac_sha256_Update(&ctx, info, isize);
    //    hmac_sha256_Update(&ctx, &c, 1);
    //    hmac_sha256_Final(&ctx, t);

    var c: UInt8 = 1
    var t = hmacSHA256(key: prk, message: info + [c])

    //    while (okm_size > sizeof(t)) {
    //        memcpy(okm, &t, sizeof(t));
    //        okm = okm + sizeof(t);
    //        okm_size -= sizeof(t);
    //
    //        c++;
    //        hmac_sha256_Init(&ctx, prk, sizeof(prk));
    //        hmac_sha256_Update(&ctx, t, sizeof(t));
    //        hmac_sha256_Update(&ctx, info, isize);
    //        hmac_sha256_Update(&ctx, &c, 1);
    //        hmac_sha256_Final(&ctx, t);
    //    }
    //    memcpy(okm, &t, okm_size);

    var remaining = count
    var result = Data()
    while remaining > t.count {
        result += t
        remaining -= t.count

        c += 1
        t = hmacSHA256(key: prk, message: t + info + [c])
    }
    result += t.prefix(remaining)
    return result
}
