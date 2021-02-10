#!/usr/bin/env R

# Author: Sean Maden
# 
# Title:
# Run the Recount Methylation Pipeline to generate data objects for the R package.
#
# Purpose:
# This script outputs versioned, timestamped database files from a set of GEO IDATs.
# It is assumed the user has run recount-methylation-server and has a structured 
# directory tree containing the sample IDAT files and the sample postprocessed metadata.
# From these files, several database files are generated. 
# 
# First, all database files for raw red and green signals are created. This approach 
# expedites database creation so full data objects can be viewed as quickly as possible.
# First, large flat tables of raw/unnormalized red and green signals are created. 
# Second, an h5 HDF5 database containing the red/grn signals and sample metadata is created
# with blocking. Third, an h5se RGChannelSet is created. Note the h5 and h5se files are
# made available at recount.bio for the recountmethylation R package.
# 
# Next, h5 and h5se objects are made for raw meth/unmeth signals and noob-normalized 
# Beta-values. These are also made available at recount.bio/data for recountmethylation. 
# First, h5 files are generated from the h5 red/grn data in blocks. Second, the h5se 
# objects are created from the corresponding h5 objects with process delay (e.g. data 
# chunk management is performed silently).
# 
# Output: 
# 1. Signal tables (raw, red/grn signal)
# 2. 3 h5 files (raw red/grn signal, raw meth/unmeth signal, noob-norm beta-values)
# 3. 3 h5se objects (raw RGChannelSet, raw MethylSet, raw RatioSet)

library(rmpipeline)

#------------------
# datasets metadata
#------------------
# set new version
newversion <- "0.0.2"
# get new datasets metadata
md <- get_metadata(title = "newrun", version = newversion)
versionfn <- md[["version"]]; timestamp <- md[["timestamp"]]


idats.path <- file.path("recount-methylation-files", "idats")
idatsv <- dt_checkidat(idatspath=idats.path, verbose = TRUE)

#--------------------------
# filter idats on file size
#--------------------------
dirpath <- file.path("recount-methylation-files", "idats")
fnv <- list.files(dir.path)
fnv <- fnv[grepl(".*idat$", fnv) & grepl(".*hlink.*", fnv)]
dat <- file.info(file.path(dirpath, fnv[1]))
fnvf <- fnv[2:length(fnv)]
for(fi in seq(fnvf)){
  dat <- rbind(dat, file.info(file.path(dirpath, fnvf[fi])))
  message(fi)
}
datf <- dat[dat$size<1.2e7,]; dim(datf)
for(r in rownames(datf)){file.remove(r)}
#file.exists(file.path(dirpath, rownames(datf)[1]))
#rownames(dat)

#----------------------
# red/grn signal data
#----------------------
# navigate to main recount-methylation dir/base dir.
# e.g. 
# > cd recount-methylation
dtables_rg_epic(versionfn, timestamp, destpath = "compilations")

# make the h5 file
# navigate to compilations dir
# e.g. 
# > cd recount-methylation/recount-methylation-analysis/files/mdata/compilations

library(rmpipeline)

read.path <- file.path("home","metamaden","recount-methylation-epic","compilations")
write.path <- file.path("eternity","recount-methylation","recount-methylation-epic")

fnl <- c("greensignal_1606324405_0-0-2.mdat.compilation",
    "redsignal_1606324405_0-0-2.mdat.compilation")

make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1589820348", mdpath = "mdpost_all-gsm-md.rda", fnpath = read.path, fnl = fnl,
    ngsm.block = 50, cmax = 1052641, rmax = 14000)

fnl <- "greensignal_1606324405_0-0-2.mdat.compilation"
make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1589820348", mdpath = "mdpost_all-gsm-md.rda", fnpath=read.path, fnl=fnl,
    ngsm.block = 50, cmax = 1052641, rmax = 14000, dsnl = "greensignal")



platform = "epic" # c("hm450k", "epic")
version = "0.0.2"
ts = 1589820348
dbn = "remethdb_1589820348_0-0-2.h5"
newfnstem = "remethdb_h5se-rg"
dsnv = c("redsignal", "greensignal")
add.metadata=FALSE
mdpath=NULL
dsn.md="mdpost"
dsn.md.cn=paste0(dsn.md,".colnames")
verbose = TRUE
replace.opt = TRUE
dsn.rnv = c(paste0(dsnv[1], ".rownames"), paste0(dsnv[2], ".rownames"))
dsn.cnv = c(paste0(dsnv[1], ".colnames"), paste0(dsnv[2], ".colnames"))
semd=list("title"="RGChannelSet HDF5-SummarizedExperiment object",
    "preprocessing"="raw")

#--------------
# rgchannel set
#--------------
# hdf5 db
fnl <- "redsignal_1606324405_0-0-2.mdat.compilation"
make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1589820348", mdpath = "mdpost_all-gsm-md.rda", fnpath = read.path, 
    fnl = fnl, ngsm.block = 50, cmax = 1052641, rmax = 14000, dsnl="redsignal")
fnl <- "greensignal_1606324405_0-0-2.mdat.compilation"
make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1589820348", mdpath = "mdpost_all-gsm-md.rda", fnpath=read.path, 
    fnl=fnl, ngsm.block = 50, cmax = 1052641, rmax = 14000, dsnl = "greensignal")

# h5se file
make_h5se_rg(max.sample = 12650, platform = "epic", version = "0.0.2", 
    ts = 1589820348, dbn = "remethdb_1589820348_0-0-2.h5", 
    newfnstem = "remethdb_h5se-rg")

#-------------------
# genomic methyl set
#-------------------
# hdf5 db
make_h5_gm(dbn = "remethdb_h5se-rg_epic_0-0-2_1589820348", version = "0.0.2", 
    ts = 1589820348, num.samp = 12650, blocksize = 65, platform = "epic", 
    newfnstem = "remethdb_h5-gm", verbose = TRUE, replace.opt = TRUE)

# h5se file
make_h5se_gm(dbn = "remethdb_h5-gm_epic_0-0-2_1589820348.h5", version = "0.0.2", 
    ts = 1589820348, platform = "epic", replaceopt = TRUE, verbose = TRUE, 
    add.metadata = FALSE, pdata = NULL, newdnstem = "remethdb_h5se-gm")

#------------------
# genomic ranges methylset
#------------------
# hdf5 db
make_h5_gr(dbn = "remethdb_h5se-rg_epic_0-0-2_1589820348", version = "0.0.2", 
    ts = 1589820348, num.samp = 12650, blocksize = 10, platform = "epic", 
    newfnstem = "remethdb_h5-gr", verbose = TRUE, replace.opt = TRUE)

# h5se file
make_h5se_gr(dbn = "remethdb_h5-gr_epic_0-0-2_1589820348.h5", version = "0.0.2", 
    ts = 1589820348, platform = "epic", replaceopt = TRUE, 
    verbose = TRUE, add.metadata = FALSE, pdata = NULL, 
    newdnstem = "remethdb_h5se-gr", 
  semd=list("title"="GenomicMethylSet HDF5-SummarizedExperiment object",
    "preprocessing"="Normalization with out-of-band signal (noob)"))



#--------------
# HM450K arrays
#--------------
library(rmpipeline)

# datasets metadata
platform <- "hm450k"
newversion <- "0.0.2"
md <- get_metadata(title = "newrun", version = newversion)
versionfn <- md[["version"]]; timestamp <- md[["timestamp"]]

timestamp <- ts <- 1607018051
version <- "0.0.2"

# idats paths
idats.path <- file.path("home", "metamaden", "recount-methylation-hm450k", 
    "recount-methylation-files", "idats")
idatsv <- dt_checkidat(idatspath=idats.path, verbose = TRUE)

# filter idats on file size
#dirpath <- file.path("recount-methylation-files", "idats")
#fnv <- list.files(dir.path)
#fnv <- fnv[grepl(".*idat$", fnv) & grepl(".*hlink.*", fnv)]
#dat <- file.info(file.path(dirpath, fnv[1]))
#fnvf <- fnv[2:length(fnv)]
#for(fi in seq(fnvf)){
#  dat <- rbind(dat, file.info(file.path(dirpath, fnvf[fi])))
#  message(fi)
#}
#datf <- dat[dat$size<1.2e7,]; dim(datf)
#for(r in rownames(datf)){file.remove(r)}
#file.exists(file.path(dirpath, rownames(datf)[1]))
#rownames(dat)

# red/grn signal data
writepath <- file.path("eternity", "recount-methylation", 
    "recount-methylation-hm450k")
readpath <- file.path("home", "metamaden", "recount-methylation-hm450k", 
    "recount-methylation-files", "idats")

dtables_rg(platform = platform, version = version, timestamp = timestamp, 
    idatspath = readpath, destpath = writepath)

library(rmpipeline)

# rgsets

# h5 rgset

read.path <- write.path <- file.path(".")
fnl <- c("redsignal_1607018051_0-0-2.mdat.compilation",
    "greensignal_1607018051_0-0-2.mdat.compilation")

make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1607018051", mdpath = "mdpost_all-gsm-md.rda", fnpath = read.path, fnl = fnl,
    ngsm.block = 60, cmax = 622399, rmax = 50400)

fnl <- "greensignal_1607018051_0-0-2.mdat.compilation"
make_h5db_rg(dbfnstem = "remethdb", dbpath = write.path, version = "0.0.2", 
    ts = "1607018051", mdpath = NULL, fnpath=read.path, fnl=fnl,
    ngsm.block = 60, cmax = 622399, rmax = 50400, dsnl = "greensignal")

#-----------------
# check hdf5 files
#-----------------
library(HDF5Array); library(rhdf5)
dbn <- "remethdb_1607018051_0-0-2.h5"
rn <- h5read(dbn, "greensignal.rownames")
rnf <- rn[!rn == "" & grepl("GSM", rn)]
gsmv <- gsub("\\..*", "", rnf[c(1,2,length(rnf) - 1,length(rnf))])
rg.gds <- gds_idat2rg(gsmv)
gs <- HDF5Array(dbn, "greensignal");rs <- HDF5Array(dbn, "redsignal")

# check green
identical(gs[1,], as.numeric(getGreen(rg.gds[,1])))
identical(gs[2,], as.numeric(getGreen(rg.gds[,2])))
identical(gs[50400,], as.numeric(getGreen(rg.gds[,3])))
identical(gs[50401,], as.numeric(getGreen(rg.gds[,4])))
# check red
identical(rs[1,], as.numeric(getRed(rg.gds[,1])))
identical(rs[2,], as.numeric(getRed(rg.gds[,2])))
identical(rs[50400,], as.numeric(getRed(rg.gds[,3])))
identical(rs[50401,], as.numeric(getRed(rg.gds[,4])))

# h5se rgset
# rgset -- h5se file
make_h5se_rg(max.sample = 50400, platform = "hm450k", version = "0.0.2", 
    ts = 1607018051, dbn = "remethdb_1607018051_0-0-2.h5", 
    newfnstem = "remethdb_h5se-rg")

# check saved data
rg.h5se.name <- "remethdb_h5se-rg_hm450k_0-0-2_1607018051"
rg <- HDF5Array::loadHDF5SummarizedExperiment(rg.h5se.name)
identical(as.numeric(getRed(rg[,1])), as.numeric(getRed(rg.gds[,1])))
identical(as.numeric(getRed(rg[,50400])), as.numeric(getRed(rg.gds[,3])))
identical(as.numeric(getGreen(rg[,1])), as.numeric(getGreen(rg.gds[,1])))
identical(as.numeric(getGreen(rg[,50400])), as.numeric(getGreen(rg.gds[,3])))


# genomic methyl set -- hdf5 db
make_h5_gm(dbn = "remethdb_h5se-rg_hm450k_0-0-2_1607018051", version = "0.0.2", 
    ts = 1607018051, num.samp = 50401, blocksize = 50, platform = "hm450k", 
    newfnstem = "remethdb_h5-gm", verbose = TRUE, replace.opt = TRUE)

# check samples
library(HDF5Array); library(rhdf5)
dbn <- "remethdb_h5-gm_hm450k_0-0-2_1607018051.h5"
h5ls(dbn)
rn <- h5read(dbn, "rownames")
cn <- h5read(dbn, "colnames")
length(cn) # 50401
cnf <- cn[!cn == "" & grepl("GSM", cn)]
length(cnf) # 50400
gsmv <- gsub("\\..*", "", cnf[c(1,2,length(cnf) - 1,length(cnf))])
rg.gds <- gds_idat2rg(gsmv)
gm.gds <- preprocessRaw(rg.gds)
meths <- HDF5Array(dbn, "meth")
unmeths <- HDF5Array(dbn, "unmeth")
# check signals
identical(meths[,1], as.numeric(getMeth(gm.gds[,1])))
identical(meths[,length(cnf)], as.numeric(getMeth(gm.gds[,4])))
identical(unmeths[,1], as.numeric(getUnmeth(gm.gds[,1])))
identical(unmeths[,length(cnf)], as.numeric(getUnmeth(gm.gds[,4])))



# genomic methyl set -- h5se file
make_h5se_gm(dbn = "remethdb_h5-gm_hm450k_0-0-2_1607018051.h5", version = "0.0.2", 
    ts = 1607018051, platform = "hm450k", replaceopt = TRUE, verbose = TRUE, 
    add.metadata = FALSE, pdata = NULL, newdnstem = "remethdb_h5se-gm")

# test gm h5se
gm.fn <- "remethdb_h5se-gm_hm450k_0-0-2_1607018051"
gm <- HDF5Array::loadHDF5SummarizedExperiment(gm.fn)
identical(as.numeric(getMeth(gm[,1])), as.numeric(getMeth(gm.gds[,1])))
identical(as.numeric(getMeth(gm[,50400])), as.numeric(getMeth(gm.gds[,4])))
identical(as.numeric(getUnmeth(gm[,1])), as.numeric(getUnmeth(gm.gds[,1])))
identical(as.numeric(getUnmeth(gm[,50400])), as.numeric(getUnmeth(gm.gds[,4])))




# genomic ranges set -- hdf5 db
make_h5_gr(dbn = "remethdb_h5se-rg_hm450k_0-0-2_1607018051", version = "0.0.2", 
    ts = 1607018051, num.samp = 50401, blocksize = 20, platform = "hm450k", 
    newfnstem = "remethdb_h5-gr", verbose = TRUE, replace.opt = TRUE)

# note -- fix colnames write for h5 gr data

make_h5se_gr(dbn = "remethdb_h5-gr_hm450k_0-0-2_1607018051.h5", version = "0.0.2", 
    ts = 1607018051, platform = "hm450k", replaceopt = TRUE, verbose = TRUE, 
    add.metadata = FALSE, pdata = NULL, newdnstem = "remethdb_h5se-gr")

# check h5db values
dbn <- "remethdb_h5se-gr_hm450k_0-0-2_1607018051"
gr <- HDF5Array::loadHDF5SummarizedExperiment(dbn)
colnames(gr)[1:ncol(rg)] <- colnames(rg)[1:ncol(rg)]
gsmv <- colnames(gr)[c(1,2,ncol(gr)-2,ncol(gr)-1)]
gsmv <- gsub("\\..*", "", gsmv)
rg.gds <- gds_idat2rg(gsmv)
gr.gds <- preprocessNoob(rg.gds)
identical(as.numeric(getBeta(gr[,1])), as.numeric(getBeta(gr.gds[,1])))
identical(as.numeric(getBeta(gr[,2])), as.numeric(getBeta(gr.gds[,2])))
identical(as.numeric(getBeta(gr[,ncol(gr)-2])), as.numeric(getBeta(gr.gds[,3])))
identical(as.numeric(getBeta(gr[,ncol(gr)-1])), as.numeric(getBeta(gr.gds[,4])))

# fix colnames write from h5 gr to h5se gr
library(rhdf5)
library(HDF5Array)
dbn.rg <- "remethdb_h5se-rg_hm450k_0-0-2_1607018051"
rg <- HDF5Array::loadHDF5SummarizedExperiment(dbn.rg)
dbn.gr = "remethdb_h5-gr_hm450k_0-0-2_1607018051.h5"
cnames <- h5read(dbn.gr, "colnames")
cnames.rg <- as.character(colnames(rg))
rhdf5::h5write(cnames.rg, file = dbn, name = "colnames",
    index = list(1:length(cnames.rg)))

cnames <- h5read(dbn.gr, "colnames")[1:50400]
rnames <- h5read(dbn, "rownames")
nb <- HDF5Array(dbn, "noobbeta")
anno <- annotation(rg)

dbn <- "remethdb_h5se-gr_hm450k_0-0-2_1607018051"
nb.write <- as.matrix(nb[,c(1:50400)])
colnames(nb.write) <- cnames
rownames(nb.write) <- rnames
gr <- GenomicRatioSet(Beta = nb, annotation = anno)
HDF5Array::saveHDF5SummarizedExperiment(gr, dir = dbn, replace = TRUE)


dbn = "remethdb_h5-gr_hm450k_0-0-2_1607018051.h5"
version = "0.0.2"
ts = 1607018051
platform = "hm450k"
replaceopt = TRUE
verbose = TRUE
add.metadata = FALSE
pdata = NULL
newdnstem = "remethdb_h5se-gr"
num.samp = 50400

make_h5se_gr(dbn = dbn, 
    version = version, 
    ts = ts, 
    platform = platform,
    replaceopt = replaceopt,
    verbose = verbose,
    add.metadata = add.metadata,
    pdata = pdata,
    newdnstem = newdnstem,
    num.samp = num.samp)

# test new data object
dbn <- "remethdb_h5se-gr_hm450k_0-0-2_1607018051"
gr <- loadHDF5SummarizedExperiment(dbn)

# epic
dbn = "remethdb_h5-gr_epic_0-0-2_1589820348.h5"
version = "0.0.2"
ts = "1607018051"
platform = "epic"
replaceopt = TRUE
verbose = TRUE
add.metadata = FALSE
pdata = NULL
newdnstem = "remethdb_h5se-gr"
num.samp = 12650

make_h5se_gr(dbn = dbn, 
    version = version, 
    ts = ts, 
    platform = platform,
    replaceopt = replaceopt,
    verbose = verbose,
    add.metadata = add.metadata,
    pdata = pdata,
    newdnstem = newdnstem,
    num.samp = num.samp)

#------------------------------------
# append pdata to h5 and h5se objects
#------------------------------------
library(minfi)
library(HDF5Array)
mdpath <- file.path("md_final.rda")
mdfin <- get(load(mdpath))

# add metadata to h5se objects
rg.path <- "remethdb_h5se-rg_epic_0-0-2_1589820348" # "remethdb_h5se-rg_hm450k_0-0-2_1607018051"
gr.path <- "remethdb_h5se-gr_epic_0-0-2_1607018051" # "remethdb_h5se-gr_hm450k_0-0-2_1607018051"
gm.path <- "remethdb_h5se-gm_epic_0-0-2_1589820348" # "remethdb_h5se-gm_hm450k_0-0-2_1607018051"
pathv <- c(rg.path, gr.path, gm.path)

append_h5se <- function(h5se.path, mdfin, cname.gsm = "gsm", 
    append.mna = TRUE, verbose = TRUE){
    if(verbose){message("Loading h5se data...")}
    h5se <- loadHDF5SummarizedExperiment(h5se.path)
    colnamesv <- colnames(h5se);gsmv <- gsub("\\..*", "", colnamesv)
    gsmint <- intersect(gsmv, mdfin[,cname.gsm])
    mdff <- mdfin[mdfin$gsm %in% gsmint,]
    if(verbose){message("Checking for missing GSM IDs...")}
    if(length(gsmint) < length(colnamesv)){gsmout.filt <- which(!gsmv%in%gsmint)
        if(verbose){message("Found ",length(gsmout.filt), " missing GSM IDs.")}
        if(append.mna){if(verbose){message("Appending NA matrix...")}
            gsmout <- gsmv[gsmout.filt];rnameout <- colnamesv[gsmout.filt]
            m1 <- matrix(gsub("\\..*", "", gsmout), ncol = 1)
            m2 <- matrix(rep(rep("NA", ncol(mdfin) - 1), length(gsmout)), 
                nrow = length(gsmout))
            mna <- cbind(m1, m2);rownames(mna) <- rnameout
            colnames(mna) <- colnames(mdff);mdff <- rbind(mdff, mna)
        } else{
            stop("Error, some GSM IDs are missing from mdfin. ",
                "Append NAs by setting `append.mna` to TRUE.")
        }
    }
    mdff <- mdff[order(match(as.character(mdff[,cname.gsm]), gsmv)),]
    cond1 <- identical(as.character(mdff[,cname.gsm]), gsmv)
    if(cond1){if(verbose){message("Appending metadata to h5se object...")}
      rownames(mdff) <- colnamesv;pData(h5se) <- DataFrame(mdff)
      if(verbose){message("Saving h5se data with appended metadata...")}
      quickResaveHDF5SummarizedExperiment(x = h5se)
      h5se <- loadHDF5SummarizedExperiment(h5se.path)
      pdat <- try(as.data.frame(pData(h5se)))
      gsm.mdff<-as.character(mdff[,cname.gsm]);gsm.pdat<-as.character(pdat[,1])
      cond2 <- identical(gsm.mdff, gsm.pdat)
      if(cond2){message("Metadata successfully added.")} else{
        stop("Error comparing pdata vs. mdff, did pdata addition succeed?")
      }
    }else{stop("Error matching mdfin$gsm and gsmv from rgset.")}
    return(NULL)
}

for(path in pathv){
    append_h5se(h5se.path = path, mdfin = mdfin)
    message("Finished object at path ", path)
}

# add metadata to h5 object

mdpath = mdpath
dbn = "remethdb_h5-rg_epic_0-0-2_1589820348.h5"
verbose = TRUE
dsn = "mdpost"
cnn = paste(dsn, "colnames", sep = ".")
dsn.read <- "greensignal"

h5_addmd = function(dbn, mdpath, append.mna = TRUE, cname.gsm = "gsm", 
    dsn.read = "greensignal", dsn = "mdpost", verbose = TRUE){
    if(verbose){message("Reading in h5 rownames for sample IDs...")}
    db.rownames <- h5read(file = dbn, name = paste0(dsn.read, ".rownames"))
    db.rownames<-db.rownames[grepl("^GSM.*", db.rownames)]
    gsmv<-gsub("\\..*","",db.rownames)
    mdfin <- get(load(mdpath));gsmint <- intersect(gsmv, mdfin[,cname.gsm])
    mdff <- mdfin[mdfin[,cname.gsm] %in% gsmint,]
   if(verbose){message("Checking for missing GSM IDs...")}
   if(length(gsmint) < length(db.rownames)){gsmout.filt <- which(!gsmv%in%gsmint)
        if(verbose){message("Found ",length(gsmout.filt), " missing GSM IDs.")}
        if(append.mna){if(verbose){message("Appending NA matrix...")}
            gsmout <- gsmv[gsmout.filt];rnameout <- db.rownames[gsmout.filt]
            m1 <- matrix(gsub("\\..*", "", gsmout), ncol = 1)
            m2 <- matrix(rep(rep("NA", ncol(mdfin) - 1), length(gsmout)), 
            nrow = length(gsmout))
            mna <- cbind(m1, m2);rownames(mna) <- rnameout
            colnames(mna) <- colnames(mdff);mdff <- rbind(mdff, mna)
        } else{
            stop("Error, some GSM IDs are missing from mdfin. ",
                "Append NAs by setting `append.mna` to TRUE.")
        }
    }
    mdff <- mdff[order(match(mdff[,cname.gsm,], gsmv)),]
    if(identical(as.character(gsmv), as.character(mdff[,cname.gsm]))){
        rownames(mdff) <- db.rownames
    } else{stop("Error, couldn't match metadata to db.rownames.")}

  mmf <- as.matrix(mdff); class(mmf) <- "character"
  mmf.colnames <- colnames(mmf); mmf.rownames = rownames(mmf)
  cnn=paste(dsn,"colnames",sep=".");rnn<-paste(dsn,"rownames",sep=".")
  if(verbose){message("Making new entities for HDF5 db...")}
  rhdf5::h5createDataset(dbn, dsn, dims = c(nrow(mmf), ncol(mmf)),
                  maxdims = c(rhdf5::H5Sunlimited(), rhdf5::H5Sunlimited()),
                  storage.mode="character",level=5,chunk=c(10,16),size=256)
  rhdf5::h5createDataset(dbn, cnn, dims = length(mmf.colnames),
                  maxdims = c(rhdf5::H5Sunlimited()),storage.mode="character",
                  level = 5, chunk = c(5), size = 256)
  rhdf5::h5createDataset(dbn, rnn, dims = length(mmf.rownames),
                  maxdims = c(rhdf5::H5Sunlimited()),storage.mode="character",
                  level = 5, chunk = c(5), size = 256)
  if(verbose){message("Populating new HDF5 entities...")}
  rhdf5::h5write(mmf, file = dbn, name = dsn,
          index = list(1:nrow(mmf), 1:ncol(mmf)))
  rhdf5::h5write(mmf.colnames, file = dbn, name = cnn,
          index = list(1:length(mmf.colnames)))
  rhdf5::h5write(mmf.rownames, file = dbn, name = rnn,
          index = list(1:length(mmf.rownames)))
  if(verbose){message("Finished adding metadata.")}; rhdf5::h5closeAll()
  return(NULL)
}

h5_addmd(dbn = dbn, mdpath = mdpath)





