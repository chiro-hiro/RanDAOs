# RanDAOs

## RanDAO Simple

Don't generate random number, let's brute force it.

## Idea

* **Host** think about a number, he will describe the number and ask **Challengers** to guess the result.
* **Host** take result from **Challengers** and remove previous description to make new description.
* Another **Challengers** will try to guess new result.
* **Host** pick 5 best results and combine them by using XOR operator.

## Proof of Work & Zero-knowledge Proof

### Create fingerprint

Blockhash is computed by miners and they have no idea what is it, until block has been found.

**Host** pick 128 bits from blockhash to create *Fingerprint*:

```javascript
let Fingerprint = uint128(block.blockhash(block.number - 1))
```

All of above make sure that no one know about the *Fingerprint* before new block found.

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

**Host** create a campaign for anyone to submit answers.

*RequireDifference* & *RequirePower* is the requisites to the contributor submission effective ( accepted).

```javascript
let Result = sha3(sha3(sha3(sha3(sha3(....sha3(Fingerprint + Key)))))) // Sha3 Power times
```

**Challengers** need to brute force *Key* and *Power* values.

Pick 128 bits from *Result* as a *Snapshot*:

```javascript
set Snapshot = uint128(Result)
```
Compare *Snapshot* and current *Fingerprint*:

```javascript
BitCompare(Snapshot, Fingerprint) <= RequireDiffrence && Power > RequirePower // Key and Power are accepted if following conditions are satisfy.
``` 

*BitCompare()* is the operation that comparing how many difference bits?.

We are try to find a half collision (the half-same numbers).

### Challenger success to submit his submission 

**Challengers** are need to deposit 10% of prize pool. 

*Fingerprint* will be changed, after his submission is accepted.

```javascript
let Fingerprint = Key >> FINGERPRINT_LEN // Remove old Fingerprint from new Fingerprint, last 128 bits
```

*Difficulty* will be increased to new *Difficulty* of submission.

```javascript
let Difficulty = DifficultyCalculate(Power, difference)
```

No one able to predict because of the new *Fingerprint* is dependent on the results of previous calculations.

### End

Pick 5 *Key*s from all contributors having highest *Difficulty* (which have geater *Power* and lower *Difference* bits): *Keys[]*

```javascript
let Random = Keys[0] ^ Keys[1] ^ Keys[2] ^ Keys[3] ^ Keys[4] ^ Keys[5];
Random = Random >> FINGERPRINT_LEN;
```

Remove 128 bits of Fingerprint from *Random*, that will be the final result. 
