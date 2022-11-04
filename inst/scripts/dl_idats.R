#!/usr/bin/env R
# Author: Sean Maden
#
# Download remaining IDATs using a diff from currently available files.
#
#

gds_idatquery <- function(gsmvi, ext = "gz", expand = TRUE, verbose = FALSE, dfp = "idats", 
                          burl = paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/samples/")){
  bnv <- fnv <- c()
  if(verbose){message("Checking dest dir dfp.")}
  if(!dir.exists(dfp)){
    message("Making new dest dir dfp.");tdir <- try(dir.create(dfp))
    if(!tdir){
      stop("Error, there was an issue making the new dest dir dfp.")}}
  for(gsmi in gsmvi){
    url = paste0(burl, substr(gsmi, 1, nchar(gsmi) - 3), 
                 paste(rep("n", 3), collapse = ""), "/", gsmi, "/suppl/")
    fn = RCurl::getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    fn <- gsub("\\\r", "", unlist(strsplit(fn, "\n")))
    idat.str <- paste0("\\.idat\\.", ext)
    idat.catch <- grepl(idat.str, fn)
    fn <- unlist(fn)[idat.catch]
    check.cond <- length(fn) == 2
    fn.grn <- fn[grepl(paste0(".*Grn.idat\\.", ext, "($)"), fn)]
    fn.red <- fn[grepl(paste0(".*Red.idat\\.", ext, "($)"), fn)]
    check.cond <- c(check.cond, length(fn.grn) > 0, length(fn.red) > 0)
    if(check.cond[1] & check.cond[2] & check.cond[3]){
      idatl <- unique(gsub("_Red.*|_Grn.*", "", fn))
      bnv = c(bnv, file.path(dfp, idatl))
      for(f in fn){
        url.dlpath <- paste(url, f, sep = "")
        dest.fpath <- file.path(dfp, f)
        utils::download.file(url.dlpath, dest.fpath)
        fnv <- c(fnv, dest.fpath)
        if(expand){if (verbose) {message("Expanding compressed file...")}
          tcond <- try(R.utils::gunzip(dest.fpath))
          if(is(tcond, "try-error")){message("Error expanding file ", dest.fpath)}}
        message(f)}}
    else{
      if(verbose){
        message("Query didn't identify", " red and grn IDATs for ",gsmi)}}
    if(verbose){message("Finished query for: ", gsmi)}}
  return(list(basenames = bnv, filenames = fnv))
}
# get paths
eq.fname <- "gsequery_filt.1665945193"
eq.dirpath <- file.path("equery")
idat.dirpath <- file.path("idats")
# get id vectors
rl <- readLines(file.path(eq.dirpath, eq.fname))
idv <- unlist(strsplit(rl, " "))
which.gse <- grepl("GSE", idv)
gsev <- idv[which.gse]
gsmv <- idv[!which.gse]
# get id diffs
idat.fn.dlv <- unique(gsub("\\..*", "", list.files(idat.dirpath)))
gsmvf <- gsmv[!gsmv %in% idat.fn.dlv]
# download remaining idats to temp
dl <- gds_idatquery(gsmvf, expand = FALSE, verbose = TRUE, dfp = "temp/idats_temp/")