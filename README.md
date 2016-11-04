# RanDAOs

## RanDAO Simple

Don't generate random number, let's brute force it.

## Idea

* **Host** think about a number and ask **Challengers** to guess the results.
* **Challengers** give **Host** the results, **Host** pick 5 best numbers.
* **Host** combine 5 numbers by using XOR operator.

## Proof of Work & Zero knowlegde

**Host** give two numbers *Diffence* & *Power*

*let Seed = block.blockhash(block.number - 1)*

**Host** pick 128 bits from *Seed* to create *Fingerprint*: *let Fingerprint = uint128(Seed)*

**Host** create a campaign for anyone to submit numbers.

**Challengers** Submit two numbers Key and Power:

*let Result = sha3^Power(Seed + Key)*

Pick 128 bits from *Result*: *set Snapshot = uint128(Result)*

*if BitCompare(Snapshot, Fingerprint) <= Diffrence then Key and Power is accepted.* 

*BitCompare()* give the number of difference bits between *Snapshot* and *Fingerprint*

Pick 5 key values from all contributors, which have geater *Power* and lower *Diff* bits: *Keys[]*

*let Random = Keys[0] ^ ... ^ Keys[5];*

Remove 128 bits fingerprint from *Random*, that will be the final result. 
