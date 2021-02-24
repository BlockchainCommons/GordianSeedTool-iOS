# Definitions

## Abbreviations
In alphabetic order:\
DID = [Decentralized Identity](#decentralized-identity) or Digital Identity dependent of the context.\
DDO = DID Document, look up W3D DID standardization for more info\
DHT = Distributed Hash Table\
DKMI = Decentralized Key Mangement Infrastructure\
HSM = Hardware Security Module\
IPv4 = standard Internet Protocol, version 4\
LOA = [Levels Of Assurance](#levels-of-assurance)\
PKI = [Public Key Infrastructure](#public-key-infrastructure)\
PoA = Proof of Authority\
PR = Pull Request; github terminology\
VC = Verifiable Credential, look up W3D DID standardization for more info\

Definitions in alphabetic order:

#### Agent
A representative for an _identity_. MAY require the use of a_wallet_. MAY support _transfer_

#### Agency
Agents can be people, edge computers and the functionality within [`wallets`](#digital-identity-wallet). The service an agent offers is agency.

#### Claim
An assertion of the truth of something, typically one which is disputed or in doubt. A set of claims might convey personally identifying information: ½name, address, date of birth and citizenship, for example. ([Source](https://www.identityblog.com/?p=352)).

#### Content-addressable hash
Content addressing is a way to find data in a network using its content rather than its location. The way we do is by taking the content of the content and hashing it. Try uploading an image to IPFS and get the hash using the below button. In the IPFS ecosystem, this hash is called Content Identifier, or CID.
#### Controller
The entity that has the ability to make changes to an _identity_, _cryptocurrency_ or _verifiable credential_. 

The controller of an `autonomous identifier` is the entity (person, organization, or autonomous software) that has the capability, as defined by derivation, to make changes to an `Event Log`. This capability is typically asserted by the control of a single inception key. In DIDs this is typically asserted by the control of set of cryptographic keys used by software acting on behalf of the controller, though it may also be asserted via other mechanisms. In KERI an AID has one single controller. Note that a DID may have more than one controller, and the DID `subject` can be the DID controller, or one of them.

#### Correlation
An identifier used to indicate that external parties have observed how wallet contents are related. For example, when a public key is reused, it conveys that some common entity is controlling both identifiers. Tracking correlation allows for software to warn when some new information might be about to be exposed, for example: "Looks like you are about to send crypo currency, from an account you frequently use to a new account you just created."

#### Cryptocurrency
A digital asset designed to work as a medium of exchange wherein individual coin ownership records are stored in a digital ledger or computerized database using strong cryptography to secure transaction record entries, to control the creation of additional digital coin records. See [more](https://en.wikipedia.org/wiki/Cryptocurrency)

#### Decentralized Identity
DID; Decentralized identity is a technology that uses cryptography to allow individuals to create and control their own unique identifiers. They can use these identifiers to obtain `Verifiable Credentials` from trusted organisations and, subsequently, present elements of these credentials as proof of claims about themselves. In this model, the individual takes ownership of their own identity and need not cede control to centralized service providers or companies.

#### Entropy
Unpredictable information. Often used as a _secret_ or as input to a _key_ generation algorithm.[More](https://en.wikipedia.org/wiki/Entropy_(information_theory))

The term entropy is also used to describe the degree of unpredictability of a message. Entropy is then measured in bits. The degree or strength of randomness determines how difficult it would be for someone else to reproduce the same large random number. This is called _collision resistance_. 

#### Entity
Entities are not limited to natural persons but may include groups, organizations, software agents, things, and even data items. 

#### Inconsistency
If a reason, idea, opinion, etc. is inconsistent, different parts of it do not agree, or it does not agree with something else. Data inconsistency occurs when similar data is kept in different formats in more than onFBTe file. When this happens, it is important to match the data between files. 

#### Identity
A unique entity. Typically represented with a unique identifier.

#### Javascript Object Signing and Encryption
Or JOSE. JOSE is a framework intended to provide a method to securely transfer claims (such as authorization information) between parties. The JOSE framework provides a collection of specifications to serve this purpose. Related: `JWK`, `JWT`. [More info](https://jose.readthedocs.io/en/latest/)

#### Key
A mechanism for granting or restricing access to something. MAY be used to issue and prove, MAY be used to transfer and control over _identity_ and _cryptocurrency_. [More](https://en.wikipedia.org/wiki/Key_(cryptography))


#### Level of Assurance
LOA; Identity and other trust decisions are often not binary. They are judgement calls. Any time that judgement is not a simple “Yes/No” answer, you have the option for levels of assurance.
KERI has the same LOAs for entropy and trust in human behaviour preservering the security of keypairs and preservering their own privacy. It has high LOAs for the cryptographical bindings of controllers and identifiers. Also the validation of witnesses and watchtowers has high a LOA.

#### Non-transferable identifier
And identifier of which you can't rotate its controlling private key. When the private key for a non-transferable identifier become exposed to potential compromise then the identifier must be abandoned by the controller as it is no longer secure.  

The main innovation of KERI is that it provides a universal decentralized mechanism that supports *both* non-transferable and more importantly transferable self-certifying identifiers.

#### Normative
In general, we call a theory “normative” if it, in some sense, tells you what you should do - what action you should take. If it includes a usable procedure for determining the optimal action in a given scenario. [Souce](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Non-normative
A theory is called non-normative if it does not do that. In general, the purpose of non-normative theories is not to give answers, but rather to describe possibilities or predict what might happen as a result of certain actions.
[Souce](https://www.quora.com/What-is-the-difference-between-normative-and-non-normative?share=1).

#### Payload
The term 'payload' is used to distinguish between the 'interesting' information in a chunk of data or similar, and the overhead to support it. It is borrowed from transportation, where it refers to the part of the load that 'pays': for example, a tanker truck may carry 20 tons of oil, but the fully loaded vehicle weighs much more than that - there's the vehicle itself, the driver, fuel, the tank, etc. It costs money to move all these, but the customer only cares about (and pays for) the oil, hence, 'pay-load'. [source](https://softwareengineering.stackexchange.com/questions/158603/what-does-the-term-payload-mean-in-programming).

#### Public Key Infrastructure
A public key infrastructure (PKI) is a set of roles, policies, hardware, software and procedures needed to create, manage, distribute, use, store and revoke digital certificates and manage public-key encryption. [Wikipedia].(https://en.wikipedia.org/wiki/Public_key_infrastructure)

#### Race condition
A race condition or race hazard is the condition of an electronics, software, or other system where the system's substantive behavior is dependent on the sequence or timing of other uncontrollable events. It becomes a bug when one or more of the possible behaviors is undesirable. [Source](https://en.wikipedia.org/wiki/Race_condition).

#### Root of trust
Replace human basis-of-trust with cryptographic root-of-trust. With verifiable digital signatures from asymmetric key cryptography we may not trust in “what” was said, but we may trust in “who” said it.\
The root-of-trust is consistent attribution via verifiable integral non-repudiable statements.

#### Secret
Information controlled by an identity. MAY be used to derive _key_s.

#### Self Sovereign Identity
SSI is a new model for Internet-scale digital identity based on an emerging set of protocols, cutting edge cryptography and open standards. Technological and social movements have come together that make SSI possible. ([Source](https://livebook.manning.com/book/self-sovereign-identity/chapter-1/v-8/14)).\
Decentralisation of the `root-of-trust` and `verifiable credentials` come into play and delivers  “user-centric identity”: more control and self-determination of individuals, individuals machines and combinations of these, that identify as one.\
_(@henkvancann)_

#### Subject
A digital subject: A person or thing represented or existing in the digital realm which is being described or dealt with. ([Source](https://www.identityblog.com/?p=352)).

#### Transfer
The process of changing the _controller_ of _cryptocurrency_, _identity_ or _verifiable credential_. MAY require the use of a _key_.

#### Transferable identifier
And identifier of which you can rotate its controlling private key. When the private key for a transferable identifier become exposed to potential compromise then control over the identifier may be transferred to a new key-pair to maintain security.

The main innovation of KERI is that it provides a universal decentralized mechanism that supports *both* non-transferable and more importantly transferable self-certifying identifiers.

#### Trust-over-IP
It's a term related to the effort of a foundation. The Trust over IP Foundation is an independent project hosted at Linux Foundation to enable the trustworthy exchange and verification of data between any two parties on the Internet. [More](https://trustoverip.org/about/faq/).

#### Validator
a _validator_ is anybody that wants to estblish control-authority over an identifier, created by the controller of the identifier. Validators verify the log, they apply duplicity detection or they leverage somebody else's duplicity detection or apply any other logic so they can say "Yes these are events I can trust".

During validation of virtual credentials for example, a `verifier` checks to see if a `verifiable credential` (VC) has been signed by the controller of this VC using the applicable verification method.

#### Verifiable Credential
VC; A data model for conveying claims made by an issuer about a subject. See [vc-data-model](https://www.w3.org/TR/vc-data-model/) for more.\
Credentials are a part of our daily lives; driver's licenses are used to assert that we are capable of operating a motor vehicle, university degrees can be used to assert our level of education, and government-issued passports enable us to travel between countries. This specification provides a mechanism to express these sorts of credentials on the Web in a way that is cryptographically secure, privacy respecting, and machine-verifiable. [Know more](https://www.w3.org/TR/vc-data-model/)

#### W3C DID
The W3C consortium Decentralized ID standardization. [More](https://w3c.github.io/did-core/).

#### (Digital Identity) Wallet
In our context it is software and sometimes hardware that serves as a key store and functionality. Keys can be private keys and public keys, hashes and pointers. Functionality can be signing, invoices (receive), send, virtual credentials, delegation, etc. This is the [`agency`](#agency) part of a wallet. \
[More about digital ID Wallets](https://www.thalesgroup.com/en/markets/digital-identity-and-security/government/identity/digital-identity-services/digital-id-wallet)\
[More about cryto Wallets](https://cryptocurrencyfacts.com/what-is-a-cryptocurrency-wallet/).
