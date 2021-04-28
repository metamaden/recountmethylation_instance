# recountmethylation_instance

[![DOI]()]()

Authors: Sean Maden, Reid Thompson, Kasper Hansen, Abhi Nellore

Set up and maintain an instance, or synchronization, of public DNAm arrays from the [Gene Expression Omnibus 
(GEO)](https://www.ncbi.nlm.nih.gov/geo/). The `recountmethylation_instance` resource provides the means of 
setting up an environment for synchronization, including all steps to create harmonized HDF5 `.h5` and 
HDF5-SummarizedExperiment `h5se` database files. Workflow functions may be accessed using `snakemake` 
rules defined in the provided `Snakefile` script.

# Dependencies

Dependencies to run an instance are shown in the below tables. The provided setup scripts help with
automatic dependency installations (Tutorial, below). 

Tables show the dependency name (column 1), type (column 2), confirmed version (column 3), and 
requirement (column 4). Instances were confirmed to work with the indicated versions (column 2), and in 
many cases can work with more recent versions. Several dependencies are optional to run specific 
features of an instance, as indicated in the "Required?" column.

Main software and programming language dependencies:

|Dependency        |         Type         |  Version  | Required? |
|------------------|----------------------|-----------|-----------|
|  [Python 3](https://www.python.org/downloads/)      | programming language |  >=3.7.3  |    yes    |
|     [R](https://cran.r-project.org/)        | programming language |  >=3.6.0  |    yes    |
| [RabbitMQ](https://www.rabbitmq.com/)     |        broker        |   3.8.11  |    yes    |
|  [MongoDB](https://www.mongodb.com/2)     |      db syntax       |   4.4.3   |    yes    |
|  [SQLite](https://www.sqlite.org/download.html)      |      db syntax       |   3.30.1  |    yes    |
| [Entrez Utilities](https://www.ncbi.nlm.nih.gov/books/NBK25500/) | NCBI/GEO API utils   |   10.9    |    yes    |
|  [Python 2](https://www.python.org/downloads/)      | programming language |   2.7.5   |    no     |

The following Python 3 libraries are required or recommended. Note packages 
`dash` and `plotly` are only required to run the optional server dashboard utility:

|  Library  |  Type  | Version | Required? |
|-----------|----|---------|-----------|
| [snakemake](https://pypi.org/project/snakemake/) |  Python 3 library |  6.1.2  |  yes  |
|   [pandas](https://pypi.org/project/pandas/)  |  Python 3 library |  0.25.1 |  yes  |
|   [celery](https://pypi.org/project/celery/)  |  Python 3 library |  4.2.1  |  yes  |
|  [pymongo](https://pypi.org/project/pymongo/)  |  Python 3 library |  3.7.2  |  yes  |
|    [dash](https://pypi.org/project/dash/)   |  Python 3 library |  1.20.0 |  no  |
|   [plotly](https://pypi.org/project/plotly/)  |  Python 3 library |  4.14.3 |  no  |

The following R libraries are required or recommended. Note the 
`ewastools` library is only required for optional genotype-based shared 
identity analyses, which are made as part of the calculated DNAm-based metadata.

|   Library   |  Type  | Version |  Required?  |
|-------------|--------|---------|-------------|
|    [minfi](https://bioconductor.org/packages/release/bioc/html/minfi.html) | R library |  1.32.0 |    yes   |
|    [rhdf5](https://www.bioconductor.org/packages/release/bioc/html/rhdf5.html)    | R library |  2.30.1 |   yes |
| [DelayedArray](https://www.bioconductor.org/packages/release/bioc/html/DelayedArray.html)| R library |  0.12.3 |   yes |
|  [HDF5Array](https://www.bioconductor.org/packages/release/bioc/html/HDF5Array.html)  | R library |  1.14.4 |  yes |
|  [ewastools]()  |  R library |   1.7   |  no  |

Python 2 is only required if you intend to run the `MetaSRA-pipeline`. For this, 
the following libraries are recommended:

|    Library   |  Type   | Version   | Required? |
|--------------|---------|-----------|-----------|
|    [numpy](https://pypi.org/project/numpy/)     |  Python 2 library  | 1.15.4  |  no  |
|    [scipy](https://pypi.org/project/scipy/)     |  Python 2 library  | 1.1.0  |  no  |
| [scikit-learn](https://pypi.org/project/scikit-learn/) |  Python 2 library  | 0.20.1  |  no  |
|  [setuptools](https://pypi.org/project/setuptools/)  |  Python 2 library  |  0.9.8  |  no  |
|  [marisa-trie](https://pypi.org/project/marisa-trie/) |  Python 2 library  |  0.7.5  |  no  |
|     [dill](https://pypi.org/project/dill/)    |  Python 2 library  | 0.2.8.2 |  no  |
|     [nltk](https://pypi.org/project/nltk/)     |  Python 2 library  |   3.4   |  no  |

# Tutorial

This tutorial shows how to set up and initiate synchronization of public DNA methylation array data. 
Note that most steps involve calling `snakemake`rules defined in the provided `Snakefile` script. Logs, 
including stdout, for each rule called are stored by default in the "snakemakelogs" subdirectory.

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

### 2d. Initialize the instance metadata

Use the following rule to initialize the metadata, including timestamp and version, for this instance:

```
snakemake --cores 1 new_instance_md
```

This creates a new subdirectory containing the instance metadata. This is also where the newly
generated metadata files will be stored, including metadata mapped from GSM JSON files and 
DNAm model-based predicted metadata.

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

As the server process runs, you may monitor progress. Check the total study SOFT and sample IDAT files downloaded with:

```
ls -l recount-methylation-files/gse_soft/ | wc -l
ls -l recount-methylation-files/idats/ | wc -l
```

For added convenience, a server dashboard utility has been provided. This displays the instance files over time, and allows
you to track the addition of new files over time. Run the dashboard with:

```
snakemake --cores 1 server_dash
```

This should open a new browser window with the following:



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
