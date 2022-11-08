#!/usr/bin/env R
# Author: Sean Maden
#
# Download remaining IDATs using a diff from currently available files.
#
#

# params/new function args
rename <- TRUE
ext <- "gz"
expand <- FALSE
verbose <- TRUE
dfp <- "idats_temp2"
burl <-  paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/samples/")
idat.dirpath <- file.path("idats")
eq.dirpath <- file.path("equery")
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

# get id diffs
idat.fn.dlv <- unique(gsub("\\..*", "", list.files(idat.dirpath)))
gsmvf <- gsmv[!gsmv %in% idat.fn.dlv]

# check destination directory for new idats
if(verbose){message("Checking download destination directory (dfp)...")}
if(!dir.exists(dfp)){
  message("Making new dest dir dfp.");tdir <- try(dir.create(dfp))
  if(!tdir){
    stop("Error, there was an issue making the new dest dir dfp.")}}

# download new idats by iterating on filtered gsm id list
gsmvi <- gsmvf
fnv.dl <- c()
for(gsmi in gsmvi){
  # get available file metadata from server query, skipping to next GSM id if 
  # query unsuccessful
  url <- paste0(burl, substr(gsmi, 1, nchar(gsmi) - 3), 
               paste(rep("n", 3), collapse = ""), "/", gsmi, "/suppl/")
  fn <- try(RCurl::getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE))
  if(is(fn, "try-error")){message("Error querying server. Skipping."); next}
  # begin idat filename strings check -- check paired idats exist at supplement
  fn <- gsub("\\\r", "", unlist(strsplit(fn, "\n")))
  idat.str <- paste0("\\.idat\\.", ext)
  idat.catch <- grepl(idat.str, fn)
  fn <- unlist(fn)[idat.catch]
  check.cond <- length(fn) == 2
  fn.grn <- fn[grepl(paste0(".*Grn.idat\\.", ext, "($)"), fn)]
  fn.red <- fn[grepl(paste0(".*Red.idat\\.", ext, "($)"), fn)]
  check.cond <- c(check.cond, length(fn.grn) > 0, length(fn.red) > 0)
  if(check.cond[1] & check.cond[2] & check.cond[3]){
    # begin iterations on confirmed idats
    idatl <- unique(gsub("_Red.*|_Grn.*", "", fn))
    for(f in fn){
      # try idat download, and parse options for expand, rename
      url.dlpath <- paste(url, f, sep = "")
      dest.fpath <- file.path(dfp, f)
      trydl <- try(utils::download.file(url.dlpath, dest.fpath))
      if(is(trydl, "try-error")){message("Error trying IDAT download. Skipping."); break}
      fnv.dl <- c(fnv.dl, f)
      if(expand){
        if (verbose) {message("Expanding compressed file...")}
        tcond <- try(R.utils::gunzip(dest.fpath))
        if(is(tcond, "try-error")){
          message("Error expanding file ", dest.fpath, ". Skipping"); break} 
        else{
          f <- gsub(paste0("\\.", ext), "", f);dest.fpath <- file.path(dfp, f)
        }
      }
      if(rename){
        if(file.exists(dest.fpath)){
          new.fname <- paste0(c(gsmi,ts.str,f), collapse = ".")
          file.rename(dest.fpath, file.path(dfp, new.fname))
        } else{
          message("Couldn't find file to rename.")
        }
      }
      message(f)
    }
  }
  else{
    if(verbose){
      message("Query didn't identify", " red and grn IDATs for ",gsmi)
    }
  }
  if(verbose){
    message("Finished query for: ", gsmi, "\n")
    message("Finished with GSM ", which(gsmvi == gsmi), " of ", length(gsmvi))
  }
}

message("From input of ",length(gsmvi),
        " GMS IDs, finished successful download of ", 
        length(fnv.dl), " IDATs.")
