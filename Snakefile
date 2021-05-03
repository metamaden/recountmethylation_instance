#!/usr/bin/env snakemake

# Author: Sean Maden
#
# Description:
# This script describes the workflow processes to create and manage an 
# instance of recountmethylation with logging. This includes management of the
# target platform accession ID, the `recount-methylation-files` directory tree,
# acquision/download of files from GEO, reporting on the status of various file
# types, compilation of DNAm data into databases, and mapping sample metadata.
# 
# Setup:
# There are 2 principal ways to start and manage a recountmethylation instance:
# 
# * Containerization : Use the docker image and docker compose to rapidly set up
#   an instance, with automatic download and install of major dependencies
# 
# * Local use : Manage a local instance without containerization. This entails 
#   that you follow the setup instructions and manage dependency access for your
#   particular system.
# 
# Quick start:
# You may optionally set the platform accession ID as follows. Otherwise, the 
# instance defaults to targeting all available samples for the HM450K platform:
# 
# > snakemake --cores 1 set_acc
# 
# From a nix console, you may start the instance by running `server.py` using: 
# 
# > snakemake --cores 1 run_server
# 
# You may now monitor the progress of the server from a new terminal. To aid 
# with instance monitoring, run the script `serverdash.py` to initialize a 
# dashboard:
# 
# > snakemake --cores 1 server_dash
# 
# This will update automatically with current information about files in the
# instance.
# 

#------------------------------
# Set dependencies, paths, etc.
#------------------------------
import os, sys, random, string
# Set scripts path
server_repo_name = "recountmethylation_server"
server_repo_path = os.path.join(server_repo_name)
if os.path.isdir(server_repo_path):
    print("Found server repo path.")
    srcpath = os.path.join(server_repo_path, "src")
    if os.path.isdir(srcpath):
        print("Found server src path.")
    else:
        print("Error, couldn't find server src dir at path "+srcpath)
else:
    print("Error, couldn't find server repo at path "+server_repo_path)
# add server src to path
sys.path.insert(0, srcpath); from utilities import gettime_ntp
# pipeline repo
rmp_path = os.path.join("recountmethylation.pipeline", "inst", "snakemake")
# research synth resources repo
# rsynth_path = os.path.join("recount.synth", "inst", "scripts", "snakemake")
# logs info
logsfn = "snakemakelogs"; logspath = os.path.join(logsfn)

#---------------
# Manage logging
#---------------
if not os.path.isdir(logsfn):
    os.mkdir(logsfn)
if len(os.listdir(logspath)) > 0:
    print("Found "+str(len(os.listdir(logspath)))+" files in logs dir "+
        logspath)
    accopt = str(input("(Y/N) Do you want to clear existing logs from the "+
        "logs dir?\n"))
    if accopt in ["y", "Y", "yes", "Yes", "YES"]:
        print("Removing old log files...")
        for file in os.listdir(logspath):
            os.remove(os.path.join(logspath, file))
    elif accopt in ["n", "N", "no", "No", "NO"]:
        print("Skipping logs dir cleanup...")
    else:
        print("Error, invalid input. Skipping logs dir cleanup...")

#---------------
# Get timestamps
#---------------
ts = gettime_ntp(); print("New timestamp for run: "+ts)

#-------------------
# Workflow processes
#-------------------
# Server processes
# NOTE: Rules to handle file acquisition and formatting from GEO.

# Set the target platform accession for the instance
rule set_acc:
    input: os.path.join(srcpath, "set_acc.py")
    log: os.path.join(logspath, "set_acc_"+ts+".log")
    shell: "python3 {input} > {log}"

# Query the GEO DataSets API for samples, studies for the indicated platform
rule new_eqd:
    input: os.path.join(srcpath, "edirect_query.py")
    log: os.path.join(logspath, "eqd_"+ts+".log")
    shell: "python3 {input} > {log}"

# Exclude samples included in the most recent freeze located at 
# ./inst/freeze_gsmv
rule exclude_gsm:
    input: os.path.join(srcpath, "gsm_exclude.py")
    log: os.path.join(logspath, "gsm_exclude_"+ts+".log")
    shell: "python3 {input} > {log}"

# Run the server process to download study SOFT files and sample IDAT files
rule run_server:
    input: os.path.join(srcpath, "server.py")
    log: os.path.join(logspath, "run_server_"+ts+".log")
    shell: "python3 {input} > {log}"

# Run the server dashboard utility. View by opening a browser window at the 
# indicated IP address
rule server_dash:
    input: os.path.join(srcpath, "serverdash.py")
    log: os.path.join(logspath, "serverdash_"+ts+".log")
    shell: "python3 {input} > {log}"

# Unzip .gz compressed IDAT files
rule unzip_idats:
    input: os.path.join(srcpath, "process_idats.py")
    log: os.path.join(logspath, "unzip_idats_"+ts+".log")
    shell: "python3 {input} > {log}"

# Make new IDAT hardlinks with identical basenames (e.g. same timestamps)
rule make_idat_hlinks:
    input: os.path.join(srcpath, "rsheet.py")
    log: os.path.join(logspath, "rsheet_"+ts+".log")
    shell: "python3 {input} > {log}"

# Expand study SOFT files, extract sample metadata, and store as 
# sample-specific files
rule process_soft:
    input: os.path.join(srcpath, "process_soft.py")
    log: os.path.join(logspath, "process_soft_"+ts+".log")
    shell: "python3 {input} > {log}"

# Convert SOFT-derived sample metadata to JSON format, then further sample JSON
# data to remove any study-specific metadata fields
rule apply_jsonfilt:
    input: os.path.join(srcpath, "jsonfilt.R")
    log: os.path.join(logspath, "apply_jsonfilt_"+ts+".log")
    shell: "Rscript {input} > {log}"

#rule soft_cleanup:
#    input: os.path.join(srcpath, "process_soft.py")
#    log: os.path.join(logspath, "soft_cleanup_"+ts+".log")
#    shell: "python3 {input} --cleanup True  > {log}"

# Generate a report summarizing the current instance files
rule report:
    input: os.path.join(srcpath, "report.py")
    log: os.path.join(logspath, "report_"+ts+".log")
    shell: "python3 {input} > {log}"

#---------------------------
# DNAm database compilations
#---------------------------
# NOTE: Rules to form the initial compilation files

# Gets input for instance version, timestamp, etc.
rule new_instance_md:
    input: os.path.join(rmp_path, "new_instance_md.R")
    log: os.path.join(logspath, "new_instance_md_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Run the full pipeline (makes h5 and h5se files in 3 formats)
rule run_dnam_pipeline:
    input: os.path.join(rmp_path, "run_dnam_pipeline.R")
    log: os.path.join(logspath, "run_dnam_pipeline_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Compile the red/green signal data table files
rule get_rg_compilations:
    input: os.path.join(rmp_path, "get_rg_compilations.R")
    log: os.path.join(logspath, "get_rg_compilations_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5 rg database
rule get_h5db_rg:
    input: os.path.join(rmp_path, "get_h5db_rg.R")
    log: os.path.join(logspath, "get_h5db_rg_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5se rg database
rule get_h5se_rg:
    input: os.path.join(rmp_path, "get_h5se_rg.R")
    log: os.path.join(logspath, "get_h5se_rg_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5 gm database
rule get_h5db_gm:
    input: os.path.join(rmp_path, "get_h5db_gm.R")
    log: os.path.join(logspath, "get_h5db_gm_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5 gm database
rule get_h5se_gm:
    input: os.path.join(rmp_path, "get_h5se_gm.R")
    log: os.path.join(logspath, "get_h5se_gm_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5 gr database
rule get_h5db_gr:
    input: os.path.join(rmp_path, "get_h5db_gr.R")
    log: os.path.join(logspath, "get_h5db_gr_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Make the h5se gr database
rule get_h5se_gr:
    input: os.path.join(rmp_path, "get_h5se_gr.R")
    log: os.path.join(logspath, "get_h5se_gr_"+ts+".log")
    shell: "Rscript {input} > {log}"

#------------------------
# Process sample metadata
#------------------------
# NOTE: Rules to extract and map sample metadata

# Run the MetaSRA-pipeline
rule run_msrap:
    input: os.path.join(srcpath, "run_msrap.R")
    log: os.path.join(logspath, "run_msrap_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Map and harmonize metadata from filtered JSON files
rule do_mdmap:
    input: os.path.join(rmp_path, "do_mdmap.R")
    log: os.path.join(logspath, "do_mdmap_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Get DNAm-derived md and qc metrics
rule do_dnam_md:
    input: os.path.join(rmp_path, "do_dnam_md.R")
    log: os.path.join(logspath, "do_dnam_md_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Get composite md from mdfinal, mdpred, mdqc
rule make_md_final:
    input: os.path.join(rmp_path, "make_md_final.R")
    log: os.path.join(logspath, "make_md_final_"+ts+".log")
    shell: "Rscript {input} > {log}"

# Append updated md to available compilation files
rule append_md:
    input: os.path.join(rmp_path, "append_md.R")
    log: os.path.join(logspath, "append_md_"+ts+".log")
    shell: "Rscript {input} > {log}"
