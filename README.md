# recountmethylation_instance

[![DOI]()]()

Authors: Sean Maden, Abhi Nellore

Set up and maintain an instance, or synchronization, of public DNAm arrays from 
the Gene Expression Omnibus (GEO). 

# Tutorial

This tutorial shows how to set up and initiate synchronization of public DNA methylation array data.

## Setup

First clone the latest version of the `recountmethylation_instance` repo from GitHub.

```
git clone https://github.com/metamaden/recountmethylation_instance
```

For this example, DNAm array data run using the Illumina Infinium HumanMethylation 450K array platform will be considered.
Rename the cloned repo to reflect this.

```
mv recountmethylation_instance recountmethylation_instance_hm450k
cd recountmethylation_instance_hm450k
```
Several setup options have been provided, so that you may select the best option for your OS environment.

### Setup with sh script

For setup with `sh`, run the provided script `setup_instance.sh`:

```
sh setup_instance.sh
```

### Setup with conda

For setup using virtual environments with `conda`, you may run the script `anaconda_setup.sh`:

```
sh anaconda_setup.sh
```

Alternatively, create the environment from the provided `.yml` file:

```
conda env create -f environment_rmi.yml
```

## Starting a first-time server run
 
Workflow functions may be accessed using snakemake and the provided `Snakefile` script.
Run this script as follows:

### Excluding existing samples

You may wish to exclude samples from you instance. This could for, for instance, to target
only newly available samples, or samples not included in available data freezes.


