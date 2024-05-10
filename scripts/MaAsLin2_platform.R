#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

library(Maaslin2)

metadata <- read.table(args[1], 
                       sep=',', comment='', head=T)

rownames(metadata) <- metadata[,1]

counts <- read.csv(args[2])

rownames(counts) <- counts[,1]

counts <- subset(counts, select = -Sample_id)

fit_data = Maaslin2(input_data     = counts, 
                    input_metadata = metadata, 
                    min_prevalence = 0.01,
                    normalization  = "TSS",
                    output         = args[5],
                    analysis_method = "LM",
                    max_significance = 0.05,
                    correction = "BH",
                    plot_heatmap = TRUE,
                    plot_scatter = TRUE,
                    random_effects = c(args[3]),
                    fixed_effects  = c(args[4]))

