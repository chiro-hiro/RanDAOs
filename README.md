# RanDAOs

## RanDAO Simple

Don't generate random number, let's brute force it.

## Idea

* **A** think about a number and ask **B** to guess the result.
* **B** give **A** the results, **A** pick 6 best numbers.
* **A** combine 6 numbers and [The Divine](https://github.com/tad88dev/thedivine)'s power by using XOR operator.

## Proof of Work & Zero knowlegde

**A** give a number *Diff*

*let Seed = TheDivine.GetPower()*

**A** pick 8 bytes from *Seed* create *Fingerprint*: *let Fingerprint = uint64(Seed)*

**A** create a campaign for anyone to submit numbers.

**B** Submit two numbers Key and Pow:

*let Result = sha3^Pow(Seed + Key)*

Pick 8 bytes from Result: *set Snapshot = uint64(Result)*

*if BitCompare(Snapshot, Fingerprint) < Diff then Key and Pow is accepted.* 

*BitCompare()* give the number of difference bits between *Snapshot* and *Fingerprint*

Pick 6 key values from all contributors, which have geater Pow and lower difference bits: *Commits[]*

*let Random = TheDivine.GetPower() ^ Commits[0] ^ ... ^ Commits[5];*

*Random* is final result. 
