# RanDAOs

## RanDAO Simple

Don't generate random number, let's brute force it.

## Idea

* **Host** think about a number, He will describe the number and ask **Challengers** to guess the result.
* **Challengers** give **Host** the result, **Host** pick 5 best numbers.
* **Host** combine 5 numbers by using XOR operator.

## Proof of Work & Zero knowledge

### Create fingerprint

Block hash is computed by miners and they have no idea what it is, until it will be found.

```javascript
let Seed = block.blockhash(block.number - 1)
```

**Host** pick 128 bits from *Seed* to create *Fingerprint*:

```javascript
let Fingerprint = uint128(Seed)
```

All of above make sure that noone know about the *Fingerprint* before new block found.

### Difficulty calculation

*Difficulty* was calculated by.

```javascript
/*
Power shift left 16 bits OR with FINGERPRINT_LEN - Difference
The number with higher difference is a worst value.
FINGERPRINT_LEN equal to 128 bits
*/
let Difficulty = Power << 16 |FINGERPRINT_LEN - Difference 
```
It's mean *Power* is more effect to  *Difficulty* value.

### Process

**Host** create a campaign for anyone to submit numbers.

**Host** give two numbers *RequireDifference* & *RequirePower*

```javascript
let Result = sha3(sha3(sha3(sha3(sha3(....sha3(Seed + Key)))))) // Sha3 Power times
```

**Challengers** need to brute force *Key* and *Power* values.

Pick 128 bits from *Result* as a *Snapshot*:

```javascript
set Snapshot = uint128(Result)
```
Compare to current fingerprint:

```javascript
if BitCompare(Snapshot, Fingerprint) <= RequireDiffrence && Power > RequirePower // Then Key and Power is accepted.
``` 

*BitCompare()* give the number of difference bits between *Snapshot* and *Fingerprint*
We are try to find a half collision.

### Challenger success to submit his submission 

**Challengers** are need to deposit 10% of prize pool. 

*Seed* will be changed, after his submission is received. It's mean, *Fingerprint* is also changed

```javascript
let Seed = sha3(Seed, Key)
```

*Difficulty* will be increased to new *Difficulty* of submission.

```javascript
let Difficulty = DifficultyCalculate(Power, difference)
```

No one able to predict because *Seed* is dependence to unknow value.

### End

Pick 5 key values from all contributors, (which have geater *Power* and lower *Diff* bits): *Keys[]*

```javascript
let Random = Keys[0] ^ Keys[1] ^ Keys[2] ^ Keys[3] ^ Keys[4] ^ Keys[5];
```

Remove 128 bits fingerprint from *Random*, that will be the final result. 
