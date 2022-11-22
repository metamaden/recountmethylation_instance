#!/usr/bin/env R


# Author: Sean Maden
#
# Download GSE SOFT files using a diff from currently available files.
#
#

# params/new function args
base.url <- "ftp://ftp.ncbi.nlm.nih.gov/geo/series"
base.fpath <- "recount-methylation-files"
dfp <- file.path(base.fpath, "temp", "gse_temp")
eq.dirpath <- file.path(base.fpath, "equery")
idat.dirpath <- file.path(base.fpath, "idats")
soft.dirpath <- file.path(base.fpath, "gse_soft")
rename <- TRUE
verbose <- TRUE
eq.str <- "gsequery_filt"

# get new timestamp
ts.str <- gsub("\\..*", "", as.character(as.numeric(Sys.time())))

# get gsequery_filt latest
lfv <- list.files(eq.dirpath)
lfvf <- lfv[grepl(paste0(eq.str, ".*"), lfv)]
tsv <- as.numeric(gsub(".*\\.", "", lfvf))
which.latest <- tsv==max(tsv)
eq.fname <- lfvf[which.latest]

# get id vectors
rl <- readLines(file.path(eq.dirpath, eq.fname))
idv <- unlist(strsplit(rl, " "))
which.gse <- grepl("GSE", idv)
gsev <- idv[which.gse]
gsmv <- idv[!which.gse]

# check destination directory for new idats
if(verbose){message("Checking download destination directory (dfp)...")}
if(!dir.exists(dfp)){
  message("Making new dest dir dfp.");tdir <- try(dir.create(dfp))
  if(!tdir){
    stop("Error, there was an issue making the new dest dir dfp.")}}

# get id diffs
#idat.fn.dlv <- unique(gsub("\\..*", "", list.files(idat.dirpath)))
#gsmvf <- gsmv[!gsmv %in% idat.fn.dlv]
soft.fn.dlv <- unique(gsub("\\..*", "", list.files(soft.dirpath)))
gsevf <- gsev[!gsev %in% soft.fn.dlv]
fnv.dl <- c()
for(gsei in gsevf){
  # gsei <- "GSE161485"
  # get download url
  gse.strv <- unlist(strsplit(gsei, ""))
  gse.dir.str <- paste0(gse.strv[1:(length(gse.strv)-3)], collapse = "")
  gse.dir.str <- paste0(gse.dir.str, paste0(rep("n", 3), collapse = ""))
  soft.fname <- paste0(gsei, "_family.soft.gz")
  dl.url <- file.path(base.url, gse.dir.str, gsei, "soft", soft.fname)
  # try to ping server for valid filename
  server.check.fn <- try(RCurl::getURL(dl.url, ftp.use.epsv = FALSE, dirlistonly = TRUE))
  if(is(server.check.fn, "try-error")){message("Error querying server. Skipping."); next}
  # try download
  dest.fpath <- file.path(dfp, soft.fname)
  trydl <- try(utils::download.file(dl.url, dest.fpath))
  if(is(trydl, "try-error")){message("Error on SOFT download. Skipping."); next}
  fnv.dl <- c(fnv.dl, soft.fname)
  # try rename
  if(rename){
    if(file.exists(dest.fpath)){
      new.fname <- paste0(c(gsei,ts.str,soft.fname), collapse = ".")
      file.rename(dest.fpath, file.path(dfp, new.fname))
    } else{
      message("Couldn't find file to rename.")
    }
  }
}

message("From input of ",length(gsevf),
        " GSE IDs, finished successful download of ", 
        length(fnv.dl), " SOFT files.")