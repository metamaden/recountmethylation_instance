
#-----------
# h5se rgset
#-----------
h5se.path <- "remethdb_h5se-rg_hm450k_0-0-2_1607018051" # "remethdb_h5se-rg_epic_0-0-2_1589820348"
rg <- loadHDF5SummarizedExperiment(h5se.path)

head(pData(rg))

# compare idats
gsmv <- gsub("\\..*", "", colnames(rg[,c(1:2,50399:50400)]))
rg.gds <- gds_idat2rg(gsmv)
#bnv <- c("GSM2178224_184AA3", "GSM2178225_184AA2", "GSM4804350_202232290144_R07C01",
#    "GSM4804351_202232290144_R08C01");bnv <- paste0("idats/", bnv)
#rg.gds <- read.metharray(bnv, force = TRUE)
summary(as.numeric(getBeta(rg.gds[,1])))
summary(as.numeric(getBeta(rg[,1])))
m1 <- as.matrix(getBeta(rg.gds))
m2 <- as.matrix(getBeta(rg[,c(1:2,50399:50400)]))
identical(m1, m2)
head(m1); head(m2)
tail(m1); tail(m2)

#-----------
# h5se gmset
#-----------
h5se.path <- "remethdb_h5se-gm_hm450k_0-0-2_1607018051" # "remethdb_h5se-gm_epic_0-0-2_1589820348"
gm <- loadHDF5SummarizedExperiment(h5se.path)
gm.gds <- preprocessRaw(rg.gds)

which.samp <- which(grepl(paste(gsmv, collapse = "|"), colnames(gm)))
m1 <- as.matrix(getMeth(gm[,which.samp]))
m2 <- as.matrix(getMeth(gm.gds))
tail(m1)
tail(m2)
identical(m1, m2)

m1 <- as.matrix(getUnmeth(gm[,which.samp]))
m2 <- as.matrix(getUnmeth(gm.gds))
tail(m1)
tail(m2)

#-----------
# h5se grset
#-----------
h5se.path <- "remethdb_h5se-gr_hm450k_0-0-2_1607018051" # "remethdb_h5se-gr_epic_0-0-2_1607018051"
gr <- loadHDF5SummarizedExperiment(h5se.path)
gr.gds <- preprocessNoob(rg.gds)
which.samp <- which(grepl(paste(gsmv, collapse = "|"), colnames(gr)))
m1 <- getBeta(gr[,which.samp])
m2 <- getBeta(gr.gds)
head(m1)
head(m2)
tail(m1)
tail(m2)





