#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

library(vegan)

data_cult <- read.csv(args[1])

rownames(data_cult) <- data_cult[,1]

data_cult <- subset(data_cult, select = -Sample_id)

data_richness <- estimateR(data_cult)

data_eveness <- diversity(data_cult) / log(specnumber(data_cult))

data_shannon <- diversity(data_cult, index = "shannon")

data_alphadiv <- cbind(t(data_richness), data_shannon, data_eveness)

write.csv(data_alphadiv, "Alpha_div/alpha_div_cult.csv")
