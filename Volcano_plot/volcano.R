main_dir <- dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(main_dir)

library(tidyverse)
library(ggrepel)
library(ggtext)

#####################
###### SPECIES ######
#####################

DAA_species <- read.csv("../MaAsLin2_results/species/significant_results.tsv", sep = "")

DAA_species$diffabund <- "NO"
DAA_species$diffabund[DAA_species$coef > 1 & DAA_species$qval < 0.05 & DAA_species$metadata == "HIV_status"] <- "NN_plus"
DAA_species$diffabund[DAA_species$coef < -1 & DAA_species$qval < 0.05 & DAA_species$metadata == "HIV_status"] <- "NN_minus"
DAA_species$feature[DAA_species$diffabund == "NO"] <- NA
DAA_species$label <- NA
top_red <- DAA_species[DAA_species$coef < -1 & DAA_species$qval < 0.05 & DAA_species$metadata == "HIV_status", ]
top_red <- top_red[order(top_red$qval), ][1:5, ]
DAA_species$label[DAA_species$feature %in% top_red$feature] <- DAA_species$feature[DAA_species$feature %in% top_red$feature]
DAA_species$label[DAA_species$coef > 1 & DAA_species$qval < 0.05 & DAA_species$metadata == "HIV_status"] <- DAA_species$feature[DAA_species$coef > 1 & DAA_species$qval < 0.05 & DAA_species$metadata == "HIV_status"]

volcano_plot_genus <- ggplot(data = DAA_species, aes(x = coef, y = -log10(qval), label = feature, col = diffabund)) +
  geom_point(size = 2) +
  theme_bw() +
  geom_vline(xintercept = c(-1, 1), col = "gray", linetype = 'dashed') +
  geom_hline(yintercept = c(-log10(0.05)), col = "gray", linetype = 'dashed') +
  geom_text_repel(data = subset(DAA_species, !is.na(label)),
                  aes(label = label),
                  size = 2,
                  box.padding = 1,
                  point.padding = 0.5,
                  max.overlaps = 10,
                  nudge_x = 1.5,
                  nudge_y = 4,
                  force = 10) +
  scale_color_manual(name = NULL,
                     values = c("#FF0000", '#0000FF', "grey"),
                     labels = c("<strong>HIV status (negative):</strong><br>q-value<0.05 & Log2fc<-1", 
                                "<strong>HIV status (positive):</strong><br>q-value<0.05 & Log2fc>1",
                                "<strong>Not significant:</strong><br>q-value>0.05 & –1<Log2fc<1")) +
  labs(x = "Log2fc") +
  theme(plot.title = element_text(size=22),
        legend.text = element_markdown(size=14),
        plot.caption = element_text(size=22),
        axis.text = element_text(size=14),
        axis.title = element_text(size=16, vjust = 0)) + 
  guides(colour = guide_legend(override.aes = list(size=3.5)))

ggsave("volcano_plot_species.png", plot = volcano_plot_genus, width = 10, height = 6, dpi = 600)


###################
###### GENUS ######
###################

DAA_genus <- read.csv("../MaAsLin2_results/genus/all_results.tsv", sep = "")

DAA_genus$diffabund <- "NO"
DAA_genus$diffabund[DAA_genus$coef > 1 & DAA_genus$qval < 0.05 & DAA_genus$metadata == "HIV_status"] <- "NN_plus"
DAA_genus$diffabund[DAA_genus$coef < -1 & DAA_genus$qval < 0.05 & DAA_genus$metadata == "HIV_status"] <- "NN_minus"
DAA_genus$feature[DAA_genus$diffabund == "NO"] <- NA
DAA_genus$label <- NA
top_red <- DAA_genus[DAA_genus$coef < -1 & DAA_genus$qval < 0.05 & DAA_genus$metadata == "HIV_status", ]
top_red <- top_red[order(top_red$qval), ][1:5, ]
DAA_genus$label[DAA_genus$feature %in% top_red$feature] <- DAA_genus$feature[DAA_genus$feature %in% top_red$feature]
DAA_genus$label[DAA_genus$coef > 1 & DAA_genus$qval < 0.05 & DAA_genus$metadata == "HIV_status"] <- DAA_genus$feature[DAA_genus$coef > 1 & DAA_genus$qval < 0.05 & DAA_genus$metadata == "HIV_status"]

volcano_plot_genus <- ggplot(data = DAA_genus, aes(x = coef, y = -log10(qval), label = feature, col = diffabund)) +
  geom_point(size = 2) +
  theme_bw() +
  geom_vline(xintercept = c(-1, 1), col = "gray", linetype = 'dashed') +
  geom_hline(yintercept = c(-log10(0.05)), col = "gray", linetype = 'dashed') +
  geom_text_repel(data = subset(DAA_genus, !is.na(label)),
                  aes(label = label),
                  size = 2,
                  box.padding = 1,
                  point.padding = 0.5,
                  max.overlaps = 10,
                  nudge_x = 2,
                  nudge_y = 0,
                  force = 10) +
  scale_color_manual(name = NULL,
                     values = c("#FF0000", '#0000FF', "grey"),
                     labels = c("<strong>HIV status (negative):</strong><br>q-value<0.05 & Log2fc<-1", 
                                "<strong>HIV status (positive):</strong><br>q-value<0.05 & Log2fc>1",
                                "<strong>Not significant:</strong><br>q-value>0.05 & –1<Log2fc<1")) +
  labs(x = "Log2fc") +
  theme(plot.title = element_text(size=22),
        legend.text = element_markdown(size=14),
        plot.caption = element_text(size=22),
        axis.text = element_text(size=14),
        axis.title = element_text(size=16, vjust = 0)) + 
  guides(colour = guide_legend(override.aes = list(size=3.5)))

ggsave("volcano_plot_genus.png", plot = volcano_plot_genus, width = 10, height = 6, dpi = 600)


####################
###### FAMILY ######
####################

DAA_family <- read.csv("../MaAsLin2_results/family/all_results.tsv", sep = "")

DAA_family$diffabund <- "NO"
DAA_family$diffabund[DAA_family$coef > 1 & DAA_family$qval < 0.05 & DAA_family$metadata == "HIV_status"] <- "NN_plus"
DAA_family$diffabund[DAA_family$coef < -1 & DAA_family$qval < 0.05 & DAA_family$metadata == "HIV_status"] <- "NN_minus"
DAA_family$feature[DAA_family$diffabund == "NO"] <- NA
DAA_family$label <- NA
top_red <- DAA_family[DAA_family$coef < -1 & DAA_family$qval < 0.05 & DAA_family$metadata == "HIV_status", ]
top_red <- top_red[order(top_red$qval), ][1:5, ]
DAA_family$label[DAA_family$feature %in% top_red$feature] <- DAA_family$feature[DAA_family$feature %in% top_red$feature]
DAA_family$label[DAA_family$coef > 1 & DAA_family$qval < 0.05 & DAA_family$metadata == "HIV_status"] <- DAA_family$feature[DAA_family$coef > 1 & DAA_family$qval < 0.05 & DAA_family$metadata == "HIV_status"]

volcano_plot_family <- ggplot(data = DAA_family, aes(x = coef, y = -log10(qval), label = feature, col = diffabund)) +
  geom_point(size = 2) +
  theme_bw() +
  geom_vline(xintercept = c(-1, 1), col = "gray", linetype = 'dashed') +
  geom_hline(yintercept = c(-log10(0.05)), col = "gray", linetype = 'dashed') +
  geom_text_repel(data = subset(DAA_family, !is.na(label)),
                  aes(label = label),
                  size = 2,
                  box.padding = 1,
                  point.padding = 0.5,
                  max.overlaps = 10,
                  nudge_x = 2,
                  nudge_y = 0,
                  force = 10) +
  scale_color_manual(name = NULL,
                     values = c("#FF0000", '#0000FF', "grey"),
                     labels = c("<strong>HIV status (negative):</strong><br>q-value<0.05 & Log2fc<-1", 
                                "<strong>HIV status (positive):</strong><br>q-value<0.05 & Log2fc>1",
                                "<strong>Not significant:</strong><br>q-value>0.05 & –1<Log2fc<1")) +
  labs(x = "Log2fc") +
  theme(plot.title = element_text(size=22),
        legend.text = element_markdown(size=14),
        plot.caption = element_text(size=22),
        axis.text = element_text(size=14),
        axis.title = element_text(size=16, vjust = 0)) + 
  guides(colour = guide_legend(override.aes = list(size=3.5)))

ggsave("volcano_plot_family.png", plot = volcano_plot_family, width = 10, height = 6, dpi = 600)
