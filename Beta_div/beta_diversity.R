main_dir <- dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(main_dir)

library(tidyverse)
library(ggtext)
library(patchwork)
library(vegan)
library(glue)


metadata <- read.table('../metadata.csv', 
                       sep=',', comment='', head=T)%>%
  mutate(status = factor(HIV_status),
         status = fct_relevel(HIV_status, "positive",
                             "negative"))

taxon_counts <- read.table('../counts/counts_species_filtered.csv', sep=',', comment='', head=T, row.names=1)

#####################
###### Bray №1 ######
#####################

bray <- avgdist(taxon_counts, dmethod="bray", sample=10)%>%
  as.matrix()%>%
  as_tibble(rownames = "sample_id")

metadata <- subset(metadata, sample_id!="20220313_424")
metadata <- subset(metadata, sample_id!="20220423_698")
metadata <- subset(metadata, sample_id!="20220601_973")
metadata <- subset(metadata, sample_id!="20220601_979")
metadata <- subset(metadata, sample_id!="20220604_994")


bray_dist_matrix <- bray %>%
  pivot_longer(cols=-sample_id, names_to="b", values_to="distances") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  dplyr::inner_join(., metadata, by=c("b" = "sample_id")) %>%
  dplyr::select(sample_id, b, distances) %>%
  pivot_wider(names_from="b", values_from="distances") %>%
  dplyr::select(-sample_id) %>%
  as.dist()

adonis2(as.dist(bray_dist_matrix)~metadata$status, method = "bray")

#Plot

pcoa_bray <- cmdscale(bray_dist_matrix, eig=TRUE, add=TRUE)

positions_bray <- pcoa_bray$points
colnames(positions_bray) <- c("pcoa1", "pcoa2")

percent_explained_bray <- 100 * pcoa_bray$eig / sum(pcoa_bray$eig)

pretty_pe_bray <- format(round(percent_explained_bray, digits =1), nsmall=1, trim=TRUE)

labels_bray <- c(glue("PCo Axis 1 ({pretty_pe_bray[1]}%)"),
                 glue("PCo Axis 2 ({pretty_pe_bray[2]}%)"))

PCOA_bray_plot <- positions_bray %>%
  as_tibble(rownames = "sample_id") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  ggplot(aes(x=pcoa1, y=pcoa2, color=status)) +
  geom_point() +
  labs(x=labels_bray[1], y=labels_bray[2])+
  scale_color_manual(name="HIV status", 
                     breaks=c("positive",
                              "negative"),
                     labels=c("Positive",
                              "Negative"),
                     values=c("#0000FF", "#FF0000", "gray"))+
  stat_ellipse(show.legend=FALSE)+
  annotate(geom='richtext', x=0, y=0.8, 
           label= "PERMANOVA<br><i>p</i>-value<0.001", 
           size=4, fill = NA, label.color = NA)+
  theme_classic()+
  theme(legend.text = element_markdown(),
        legend.position="bottom")+ 
  theme(text = element_text(size = 16))+
  ylim(-1.0, 1.1)

PCOA_bray_plot

# It overlaps... This cannot do! Let us use axis 2 and axis 3!

#####################
###### Bray №2 ######
#####################

pcoa_bray <- cmdscale(bray_dist_matrix, k=3, eig=TRUE, add=TRUE)
positions_bray <- pcoa_bray$points[, c(2, 3)]  # Select 2 and 3 axes
colnames(positions_bray) <- c("pcoa2", "pcoa3")
percent_explained_bray <- 100 * pcoa_bray$eig / sum(pcoa_bray$eig)
pretty_pe_bray <- format(round(percent_explained_bray, digits =1), nsmall=1, trim=TRUE)

labels_bray <- c(glue("PCo Axis 2 ({pretty_pe_bray[2]}%)"), 
                 glue("PCo Axis 3 ({pretty_pe_bray[3]}%)"))

PCOA_bray_plot <- positions_bray %>%
  as_tibble(rownames = "sample_id") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  ggplot(aes(x=pcoa2, y=pcoa3, color=status)) +
  geom_point() +
  labs(title="Bray-Curtis dissimilarity",
       x=labels_bray[1],
       y=labels_bray[2]) +
  scale_color_manual(name="HIV status", 
                     breaks=c("positive", "negative"),
                     labels=c("Positive", "Negative"),
                     values=c("#0000FF", "#FF0000")) +
  stat_ellipse(show.legend=FALSE) +
  annotate(geom='richtext', x=-0.1, y=0.8, 
           label= "PERMANOVA<br><i>p</i>-value<0.001", 
           size=4, fill = NA, label.color = NA) +
  theme_classic() +
  theme(legend.text = element_markdown(),
        legend.position="bottom") + 
  theme(text = element_text(size = 16)) +
  ylim(-1.0, 1.1)


ggsave('bray_plot_2x3.png', plot = PCOA_bray_plot, width = 6, height = 4, dpi=600)

########################
###### Jaccard №1 ######
########################

jaccard <- avgdist(taxon_counts, dmethod="jaccard", sample=10)%>%
  as.matrix()%>%
  as_tibble(rownames = "sample_id")

jaccard_dist_matrix <- jaccard %>%
  pivot_longer(cols=-sample_id, names_to="b", values_to="distances") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  dplyr::inner_join(., metadata, by=c("b" = "sample_id")) %>%
  dplyr::select(sample_id, b, distances) %>%
  pivot_wider(names_from="b", values_from="distances") %>%
  dplyr::select(-sample_id) %>%
  as.dist()

adonis2(as.dist(jaccard_dist_matrix)~metadata$status, method = "jaccard")

pcoa_jaccard <- cmdscale(jaccard_dist_matrix, eig=TRUE, add=TRUE)

positions_jaccard <- pcoa_jaccard$points
colnames(positions_jaccard) <- c("pcoa1", "pcoa2")

percent_explained_jaccard <- 100 * pcoa_jaccard$eig / sum(pcoa_jaccard$eig)

pretty_pe_jaccard <- format(round(percent_explained_jaccard, 
                                  digits =1), 
                            nsmall=1, trim=TRUE)

labels_jaccard <- c(glue("PCo Axis 1 ({pretty_pe_jaccard[1]}%)"),
                 glue("PCo Axis 2 ({pretty_pe_jaccard[2]}%)"))

PCOA_jaccard_plot <- positions_jaccard %>%
  as_tibble(rownames = "sample_id") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  ggplot(aes(x=pcoa1, y=pcoa2, color=status)) +
  geom_point() +
  labs(x=labels_bray[1], y=labels_bray[2])+
  scale_color_manual(name="HIV status", 
                     breaks=c("positive",
                              "negative"),
                     labels=c("Positive",
                              "Negative"),
                     values=c("#0000FF", "#FF0000", "gray"))+
  stat_ellipse(show.legend=FALSE)+
  annotate(geom='richtext', x=0.15, y=0.19, 
           label= "PERMANOVA<br><i>p</i>-value<0.001", 
           size=4, fill = NA, label.color = NA)+
  theme_classic()+
  theme(legend.text = element_markdown(),
        legend.position="bottom")+ 
  theme(text = element_text(size = 16))

PCOA_jaccard_plot

# It overlaps... Again... This cannot do! Let us use axis 2 and axis 3!

########################
###### Jaccard №2 ######
########################

pcoa_jaccard <- cmdscale(jaccard_dist_matrix, k=3, eig=TRUE, add=TRUE)
positions_jaccard <- pcoa_jaccard$points[, c(2, 3)]  # Select 2 and 3 axes
colnames(positions_jaccard) <- c("pcoa2", "pcoa3")
percent_explained_jaccard <- 100 * pcoa_jaccard$eig / sum(pcoa_jaccard$eig)
pretty_pe_jaccard <- format(round(percent_explained_jaccard, 
                                  digits =1), 
                            nsmall=1, trim=TRUE)

labels_jaccard <- c(glue("PCo Axis 2 ({pretty_pe_jaccard[2]}%)"),
                    glue("PCo Axis 3 ({pretty_pe_jaccard[3]}%)"))

PCOA_jaccard_plot <- positions_jaccard %>%
  as_tibble(rownames = "sample_id") %>%
  dplyr::inner_join(., metadata, by="sample_id") %>%
  ggplot(aes(x=pcoa2, y=pcoa3, color=status)) +
  geom_point() +
  labs(title="Jaccard similarity",
       x=labels_jaccard[1],
       y=labels_jaccard[2])+
  scale_color_manual(name="HIV status", 
                     breaks=c("positive",
                              "negative"),
                     labels=c("Positive",
                              "Negative"),
                     values=c("#0000FF", "#FF0000", "gray"))+
  stat_ellipse(show.legend=FALSE)+
  annotate(geom='richtext', x=0.25, y=0.16, 
           label= "PERMANOVA<br><i>p</i>-value<0.001", 
           size=4, fill = NA, label.color = NA)+
  theme_classic()+
  theme(legend.text = element_markdown(),
        legend.position="bottom")+ 
  theme(text = element_text(size = 16))


ggsave('jaccard_plot_2x3.png', plot = PCOA_jaccard_plot, width = 6, height = 5, dpi=600)

######################
###### COMBINED ######
######################

combined <- (PCOA_bray_plot + PCOA_jaccard_plot) + plot_annotation(tag_levels = list(c("A", "B")))

ggsave("combined.png", plot = combined, width = 12, height = 5, dpi=600)
