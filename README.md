# RanDAOs

## RanDAO Simple

Don't generate random number, let's brute force it.

## Idea

* **Host** think about a number and ask **Challengers** to guess the results.
* **Challengers** give **Host** the results, **Host** pick 5 best numbers.
* **Host** combine 5 numbers by using XOR operator.

## Proof of Work & Zero knowledge

### Create fingerprint

Block hash is computed by miner and he have no idea what it is, until he found it.

```javascript
let Seed = block.blockhash(block.number - 1)
```

**Host** pick 128 bits from *Seed* to create *Fingerprint*:

```javascript
let Fingerprint = uint128(Seed)
```

All of above make sure that noone know about the Fingerprint.

### Difficulty calculation

*Difficulty* was calculated by.

```javascript
let Difficulty = Power << 128 |128 - Difference // Power shift left 128 bits OR with (128 - Difference)
```
It's mean *Power* is more effect to  *Difficulty* value.

### Process

**Host** create a campaign for anyone to submit numbers.

**Host** give two numbers *Difference* & *Power*

```javascript
let Result = sha3(sha3(sha3(sha3(sha3(....sha3(Seed + Key)))))) // Sha3 Power times
```

**Challengers** need to brute force *Key* and *Power* values.

Pick 128 bits from *Result*:

```javascript
set Snapshot = uint128(Result)
```

```javascript
if BitCompare(Snapshot, Fingerprint) <= Diffrence // Then Key and Power is accepted.
``` 

*BitCompare()* give the number of difference bits between *Snapshot* and *Fingerprint*

Pick 5 key values from all contributors, (which have geater *Power* and lower *Diff* bits): *Keys[]*

```javascript
let Random = Keys[0] ^ Keys[1] ^ Keys[2] ^ Keys[3] ^ Keys[4] ^ Keys[5];
```

Remove 128 bits fingerprint from *Random*, that will be the final result. 
