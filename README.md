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

## First time setup
 
Workflow functions may be accessed using snakemake and the provided `Snakefile` script.

### Specify target platform

The HM450K platform is presently targeted by default, but this may change. To explicitly set
the platform to target, run the following:

```
snakemake --cores 1 set_acc
```

This produces the dialogue:

```
(Y/N) Current target platform accession ID is GPL13534.
Do you want to change the target platform?
```

Entering `Y` returns:

```
(1/2/3) Enter the number of the platform to target:
 1. HM450K (GPL13534)
 2. EPIC/HM850K (GPL21145)
 3. HM27K (GPL8490)
```

Type `1` to specify the HM450K platform.

### Run a new EDirect query

Data files are recognized by queries to the GEO DataSets API using EDirect software. Running a fresh query
will identify all valid data files for the targeted platform. To do this, enter:

```
snakemake --cores 1 new_eqd
```

### Exclude freeze sample IDs

The sample/GSM IDs for the most recently available data freezes are included at `./inst/freeze_gsmv/`.
Excluding these GSM IDs for this instance will allow us to synchronize the subset of samples available 
since the latest data freeze (currently: November 7, 2020).

```
snakemake --cores 1 exclude_gsm
```

For this example instance, the rule generated the following output:

```
Starting with latest detected filter file: recount-methylation-files/equery/gsequery_filt.1618960590
Applying filter...
After filter, retained 72 studies.
Writing new filter file:  recount-methylation-files/equery/gsequery_filt.1619031416
```

Functions downstream will now recognize and use the newer version of the file `gsequery_filt.*` according 
to the newer applied timestamp `1619031416`.

## Running the server

Before we can start downloading public data, we need to run the MongoDB service with sudo access. 
This can be done with either:

```
service mongod start
```

or

```
sudo service mongod start
```

Once MongoDB is running, we can initialize the server with:

```
snakemake --cores 1 run_server
```

This process should systematically target and download study SOFT files and sample IDAT files, 
according to the contents of the filtered EDirect query files. Note, you may need to restart the 
server process periodically if your connection is interrupted, the MongoDB service stops, etc.

