### Assembeely
# Bumble Bee Genome Assembly Project - IU Fall 2021 INFO I519

Assembeely is an effort to compare read error rates for DNA sequencing with de novo assembly. 

## Installation
To run Assembeely, one needs only have [Singularity](https://sylabs.io/guides/3.0/user-guide/installation.html) installed. Once installed, one can run the program with
```
./assembeely
``` 

To uncover the specifics of each step, one could manually run the steps in `workflow.sh` and then `main.py`

## Data

Assembeely will randomly sequence reads with error rates 0.01, 0.05, 0.1, and 0.15 from a bumble bee genome reference and attempts to build a scaffold for each error rate. Afterwards, the best alignments against the reference genome and the scaffold are found and statistics are extracted for comparison.

## Output
The output is a multi-index pandas data frame sent to `results.csv`
