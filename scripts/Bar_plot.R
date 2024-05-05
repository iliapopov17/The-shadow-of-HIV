#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

library(tidyverse)
library(ggtext)
library(patchwork)
library(paletteer)
library(data.table)
library(tibble)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)


#################################
##########Taxa_bar_plots#########
#################################

metadata <- read.csv(args[1])

#####################
###### SPECIES ######
#####################

data_species <- read.csv(args[2], check.names = F)
merged_data_species <- merge(data_species, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_species <- pivot_longer(merged_data_species, 
                                cols = -c(Sample_id, HIV_status), 
                                names_to = "taxon", 
                                values_to = "abundance")
long_data_species <- select(long_data_species, HIV_status, taxon, abundance)

summarized_data_species <- long_data_species %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_species <- summarized_data_species %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 2, "Other (< 2%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_species$taxon <- factor(data_species$taxon, levels = c("Other (< 2%)", unique(data_species$taxon[data_species$taxon != "Other (< 2%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 2%)" = "#837b8d", 
                   #"Bradyrhizobium sp. BTAi1" = "#ce3d32",
                   #"Candidatus Kaistella beijingensis" = "#f0e685",
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_species$taxon))-1),
                            unique(data_species$taxon[data_species$taxon != "Other (< 2%)"])))

# Plotting with refined grid settings
species <- ggplot(data_species, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Species") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "species") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/species.png", species, width=8.5, height=4, dpi = 600)

###################
###### GENUS ######
###################

data_genus <- read.csv(args[3], check.names = F)
merged_data_genus <- merge(data_genus, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_genus <- pivot_longer(merged_data_genus, 
                                  cols = -c(Sample_id, HIV_status), 
                                  names_to = "taxon", 
                                  values_to = "abundance")
long_data_genus <- select(long_data_genus, HIV_status, taxon, abundance)

summarized_data_genus <- long_data_genus %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_genus <- summarized_data_genus %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 2, "Other (< 2%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_genus$taxon <- factor(data_genus$taxon, levels = c("Other (< 2%)", unique(data_genus$taxon[data_genus$taxon != "Other (< 2%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 2%)" = "#837b8d", 
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_genus$taxon))-1),
                            unique(data_genus$taxon[data_genus$taxon != "Other (< 2%)"])))

# Plotting with refined grid settings
genus <- ggplot(data_genus, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Genus") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "Genus") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/genus.png", genus, width=8.5, height=4, dpi = 600)

####################
###### FAMILY ######
####################

data_family <- read.csv(args[4], check.names = F)
merged_data_family <- merge(data_family, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_family <- pivot_longer(merged_data_family, 
                                cols = -c(Sample_id, HIV_status), 
                                names_to = "taxon", 
                                values_to = "abundance")
long_data_family <- select(long_data_family, HIV_status, taxon, abundance)

summarized_data_family <- long_data_family %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_family <- summarized_data_family %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 2, "Other (< 2%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_family$taxon <- factor(data_family$taxon, levels = c("Other (< 2%)", unique(data_family$taxon[data_family$taxon != "Other (< 2%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 2%)" = "#837b8d", 
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_family$taxon))-1),
                            unique(data_family$taxon[data_family$taxon != "Other (< 2%)"])))

# Plotting with refined grid settings
family <- ggplot(data_family, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Family") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "family") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/family.png", family, width=8.5, height=4, dpi = 600)

###################
###### CLASS ######
###################

data_class <- read.csv(args[5], check.names = F)
merged_data_class <- merge(data_class, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_class <- pivot_longer(merged_data_class, 
                                 cols = -c(Sample_id, HIV_status), 
                                 names_to = "taxon", 
                                 values_to = "abundance")
long_data_class <- select(long_data_class, HIV_status, taxon, abundance)

summarized_data_class <- long_data_class %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_class <- summarized_data_class %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 1, "Other (< 1%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_class$taxon <- factor(data_class$taxon, levels = c("Other (< 1%)", unique(data_class$taxon[data_class$taxon != "Other (< 1%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 1%)" = "#837b8d", 
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_class$taxon))-1),
                            unique(data_class$taxon[data_class$taxon != "Other (< 1%)"])))

# Plotting with refined grid settings
class <- ggplot(data_class, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Class") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "class") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/class.png", class, width=8.5, height=4, dpi = 600)

###################
###### ORDER ######
###################

data_order <- read.csv(args[6], check.names = F)
merged_data_order <- merge(data_order, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_order <- pivot_longer(merged_data_order, 
                                cols = -c(Sample_id, HIV_status), 
                                names_to = "taxon", 
                                values_to = "abundance")
long_data_order <- select(long_data_order, HIV_status, taxon, abundance)

summarized_data_order <- long_data_order %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_order <- summarized_data_order %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 1, "Other (< 1%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_order$taxon <- factor(data_order$taxon, levels = c("Other (< 1%)", unique(data_order$taxon[data_order$taxon != "Other (< 1%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 1%)" = "#837b8d", 
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_order$taxon))-1),
                            unique(data_order$taxon[data_order$taxon != "Other (< 1%)"])))

# Plotting with refined grid settings
order <- ggplot(data_order, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Order") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "order") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/order.png", order, width=8.5, height=4, dpi = 600)

####################
###### PHYLUM ######
####################

data_phylum <- read.csv(args[7], check.names = F)
merged_data_phylum <- merge(data_phylum, metadata, by.x = "Sample_id", by.y = "sample_id")
long_data_phylum <- pivot_longer(merged_data_phylum, 
                                cols = -c(Sample_id, HIV_status), 
                                names_to = "taxon", 
                                values_to = "abundance")
long_data_phylum <- select(long_data_phylum, HIV_status, taxon, abundance)

summarized_data_phylum <- long_data_phylum %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_abundance = sum(abundance, na.rm = TRUE),
            .groups = 'drop')


# Preprocess data to calculate percentages and filter based on conditions
data_phylum <- summarized_data_phylum %>%
  group_by(HIV_status) %>%
  mutate(total_abundance_group = sum(total_abundance)) %>%
  ungroup() %>%
  mutate(percentage = (total_abundance / total_abundance_group) * 100) %>%
  filter(!(HIV_status == "positive" & total_abundance < 1)) %>%
  mutate(taxon = ifelse(percentage < 1, "Other (< 1%)", as.character(taxon))) %>%
  group_by(HIV_status, taxon) %>%
  summarize(total_percentage = sum(percentage), .groups = 'drop') %>%
  arrange(HIV_status, desc(total_percentage))

data_phylum$taxon <- factor(data_phylum$taxon, levels = c("Other (< 1%)", unique(data_phylum$taxon[data_phylum$taxon != "Other (< 1%)"])))

# Set specific colors for each taxon
color_palette <- c("Other (< 1%)" = "#837b8d", 
                   setNames(paletteer_d("ggsci::default_igv", n = length(unique(data_phylum$taxon))-1),
                            unique(data_phylum$taxon[data_phylum$taxon != "Other (< 1%)"])))

# Plotting with refined grid settings
phylum <- ggplot(data_phylum, aes(x = HIV_status, y = total_percentage, fill = taxon)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = color_palette, name = "Phylum") +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_discrete(breaks=c("positive", "negative"),
                   labels=c("Positive", "Negative"))+
  scale_y_continuous(expand=c(0, 0)) +
  labs(x = "HIV Status",
       y = "Mean Relative Abundance (%)",
       fill = "phylum") +
  theme_classic() +
  theme(legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"),
        axis.text.x = ggtext::element_markdown())

# Save the plot
ggsave("Bar_plots/phylum.png", phylum, width=8.5, height=4, dpi = 600)

######################
###### COMBINES ######
######################

combined <- (phylum + class + order) / (family + genus + species) + plot_annotation(tag_levels = list(c("A", "B", "C", "D", "E", "F")))

ggsave("Bar_plots/combined.png", plot = combined, width = 14, height = 8, dpi=600)
