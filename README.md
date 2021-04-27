# recountmethylation_instance

[![DOI]()]()

Authors: Sean Maden, Abhi Nellore

Set up and maintain an instance, or synchronization, of public DNAm arrays from the Gene Expression Omnibus 
(GEO). Workflow functions may be accessed using the provided snakemake `Snakefile` script.

# Dependencies

Several dependencies are required to run all features of an instance. These include R, Python 3, Python 2, MongoDB, SQLite3, and the RabbitMQ broker. The instance has been confirmed to work with the following versions:

|Dependency|         Type         |  Version  | Required? |
|----------|----------------------|-----------|-----------|
| Python   | programming language |  >=3.7.3  |     yes   |
| R        | programming language |  >=3.6.0  |     yes   |
| RabbitMQ |    broker            |   3.8.11  |     yes   |
| MongoDB  |   db_syntax          |   4.4.3   |     yes   |
| SQLite   |   db_syntax          |   3.30.1  |     yes   |
| Python   | programming_language | 2.7.5     |     no    |



# Tutorial

This tutorial shows how to set up and initiate synchronization of public DNA methylation array data.

## 1. Setup

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

### 1a. Setup with sh script

For setup with `sh`, run the provided script `setup_instance.sh`:

```
sh setup_instance.sh
```

### 1b. Setup with conda

For setup using virtual environments with `conda`, you may run the script `anaconda_setup.sh`:

```
sh anaconda_setup.sh
```

Alternatively, create the environment from the provided `.yml` file:

```
conda env create -f environment_rmi.yml
```

## 2. Configuring the instance
 
Next, we need to configure the instance, including specifying the array platform to target, and 
specifying sample IDs to exclude.

### 2a. Specify target platform

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

### 2b. Run a new EDirect query

Data files are recognized by queries to the GEO DataSets API using EDirect software. Running a fresh query
will identify all valid data files for the targeted platform. To do this, enter:

```
snakemake --cores 1 new_eqd
```

### 2c. Exclude freeze sample IDs

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

## 3. Running the server

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

If this rule hangs, you may alternatively call the script manually:

```
python3 ./recountmethylation_server/src/server.py
```

The `server.py` script process will systematically target and download study SOFT files and sample IDAT files, 
according to the contents of the filtered EDirect query files.

Note, you may need to restart the server process periodically if your connection is interrupted, the MongoDB service 
stops, etc. To avoid repeated hanging on corrupt or malformed files, target study/GSE ids are shuffled for
each `server.py` run.

## 4. Reformatting and compiling data files

Once data files have been downloaded, they can be prepared for compilation.

### 4a. Sample IDATs

The sample IDATs are paired files containing red and green signals from the array runs. Thus, two 
valid IDATs are expected per sample/GSM id, where their filenames end as `.*_Red.idat.*` and `.*_Grn.idat.*`.

Since we download the IDATs as compressed `.gz` files, we need to expand them.

```
snakemake --cores 1 unzip_idats
```

Because paired IDATs may have distinct filename timestamps, it is necessary to create hardlinks to ensure 
timestamps match for sample IDAT pairs.

```
snakemake --cores 1 make_idat_hlinks
```

Once the IDATs have been prepared, we can begin to compile them into various database file types.
The rules to do this include: 

1. `get_rg_compilations`: Make flat tables containing the Red and Green signal intensities. 
2. `get_h5db_rg`: Make an HDF5 database `.h5` file containing the Red and Green signal intensities. 
3. `get_h5se_rg`: Make an HDF5-SummarizedExperiment `h5se` file containing the Red and Green signal intensities
4. `get_h5db_gm`: Make an HDF5 database `.h5` file containing the Methylated and Unmethylated signals.
5. `get_h5se_gm`: Make an HDF5-SummarizedExperiment `h5se` file containing the Methylated and Unmethylated signals.
6. `get_h5db_gr`: Make an HDF5 database `.h5` file containing the Beta-values (DNAm fractions).
7. `get_h5se_gr`: Make an HDF5-SummarizedExperiment `h5se` file containing the Beta-values (DNAm fractions).

Note, you can retain any subset of these database files, but you should generally run them successively, 
as certain database files (e.g. the `RGChannelSet` `h5` and `h5se` files) are required to prepare the 
other files (e.g. `MethylSet` `h5` and `h5se` files, and `GenomicMethylSet` `h5` and `h5se` files). In 
other words, regardless of which file type you ultimately use, you'll need to start by preparing the 
`RGChannelSet` files as follows:

```
snakemake --cores 1 get_rg_compilations
snakemake --cores 1 get_h5db_rg
snakemake --cores 1 get_h5se_rg
```

For convenience, all of the data compilation steps may be executed successively using the 
`run_dnam_pipeline` rule.

```
snakemake --cores 1 run_dnam_pipeline
```

### 4b. Study SOFT files

Sample metadata is contained in the SOFT files. After expanding the `.gz` compressed SOFT files, we need to 
extract the sample-specific metadata into `.json` files before mapping with either MetaSRA-pipeline or the 
included mapping scripts. After extraction, the `.json` files are further filtered to remove study-specific 
metadata.

```
snakemake --cores 1 process_soft
snakemake --cores 1 apply_jsonfilt
```

Once the `.json` files containing sample-specific metadata have been prepared, you have the option of running
all or only some of the available metadata processing rules. Available rules include:

* `do_mdmap`: Map and harmonize metadata using the provided scripts. These scripts use regular expressions to 
            automatically detect and categorize tags in `.json` files, and then to uniformly format and 
            annotate metadata terms under several columns, including "disease" (e.g. disease condition or 
            experiment group), "tissue" (e.g. tissue of origin), "age" (chronological age), and "sex" 
            (provided sex information).
* `run_msrap`: Run the MetaSRA-pipeline. This produces sample type predictions, as well as ENCODE ontology terms 
             from several major ontology dictionaries.
* `do_dnam_md`: Get DNAm-derived metadata, including model-based predictions for age, sex, and blood cell type   
              fractions, and quality metrics, including BeadArray controls and median log2 methylated and    
              unmethylated signals. This should be run after IDAT compilations are complete.
              
Once one or all of these rules have been successfully run, compile and append the harmonized metadata to the available DNAm data compilations:

```
snakemake --cores 1 make_md_final
snakemake --cores 1 append_md
```
