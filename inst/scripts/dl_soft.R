dfp <- "temp/gse_temp"
base.url <- "ftp://ftp.ncbi.nlm.nih.gov/geo/series"
# get paths
eq.fname <- "gsequery_filt.1665946384"
eq.dirpath <- file.path("equery")
idat.dirpath <- file.path("idats")
soft.dirpath <- file.path("gse_soft")
# get id vectors
rl <- readLines(file.path(eq.dirpath, eq.fname))
idv <- unlist(strsplit(rl, " "))
which.gse <- grepl("GSE", idv)
gsev <- idv[which.gse]
length(gsev) # [1] 362
gsmv <- idv[!which.gse]
length(gsmv) # [1] 34995
# get id diffs
idat.fn.dlv <- unique(gsub("\\..*", "", list.files(idat.dirpath)))
gsmvf <- gsmv[!gsmv %in% idat.fn.dlv]
soft.fn.dlv <- unique(gsub("\\..*", "", list.files(soft.dirpath)))
gsevf <- gsev[!gsev %in% soft.fn.dlv]
for(gsei in gsevf){
  # gsei <- "GSE161485"
  # get download url
  gse.strv <- unlist(strsplit(gsei, ""))
  gse.dir.str <- paste0(gse.strv[1:(length(gse.strv)-3)], collapse = "")
  gse.dir.str <- paste0(gse.dir.str, paste0(rep("n", 3), collapse = ""))
  soft.fname <- paste0(gsei, "_family.soft.gz")
  dl.url <- file.path(base.url, gse.dir.str, gsei, "soft", soft.fname)
  # try download
  fn <- RCurl::getURL(dl.url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  dest.fpath <- file.path(dfp, soft.fname)
  utils::download.file(dl.url, dest.fpath)
}