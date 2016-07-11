# RanDAOs
RanDAO Simple, don't generate random number. Let's brute force it.

## Idea

A think about a number and ask B to guess the result.
B give A the results, A pick 6 best numbers.
A combine 6 numbers by using XOR operator and [TheDivine](https://github.com/tad88dev/thedivine)'s power.

## Proof of Work & Zero knowlegde

A give a number *Diff*
*Let Seed = TheDivine.GetPower() ^ block.blockhash*
A pick 8 bytes from Seed: *let Lock = uint64(Seed)*

A open a campaign for anyone to submit numbers.

B Submit two numbers Key and Pow:
*Let Result = sha3^Pow(Seed + Key)*
Pick 8 bytes from Result: *set Part = uint64(Result)*

*BitCompare(Part, Lock) < Diff* //BitCompare() give the number of difference bits between Part and Lock

Pick 6 values from all commitments, which have geater Pow and lower difference bits: *Commits[]*

*Let Random = TheDivine.GetPower() ^ Commits[0] ^ ... ^ Commits[5];*

*Random* is final result. 