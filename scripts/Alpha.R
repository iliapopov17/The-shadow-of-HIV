#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

#main_dir <- dirname(rstudioapi::getSourceEditorContext()$path) 
#setwd(main_dir)

library(tidyverse)
library(ggtext)
library(patchwork)

#Alpha

Alpha <- read.csv("Alpha_div/alpha_div_cult.csv")
metadata <- read.csv(args[1])

names(Alpha)[1] <- "sample_id"
names(Alpha)[3] <- "chao1"
names(Alpha)[7] <- "shannon"
names(Alpha)[8] <- "eveness"
Alpha$status <- metadata$HIV_status

chao1_res <- wilcox.test(chao1 ~ status, data = Alpha)
shannon_res <- wilcox.test(shannon ~ status, data = Alpha)
eveness_res <- wilcox.test(eveness ~ status, data = Alpha)

pvals <- c(shannon_res$p.value,
           chao1_res$p.value,
           eveness_res$p.value)


#####################
###### SHANNON ######
#####################

pvals[1]


shannon <- Alpha %>%
  mutate(status=factor(status, levels=c("positive",
                                        "negative"))) %>%
  ggplot(aes(x=status, y=shannon, fill = status))+
  stat_summary(fun = median, show.legend=FALSE, geom="crossbar")+
  geom_jitter(width=0.25, size=2.5, shape=21, color="black")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  scale_fill_manual(name = "HIV status",
                    values=c("#0000FF", "#FF0000")) +
  theme(axis.text.x =element_blank(),
        axis.ticks.x=element_blank(),
        legend.key=element_blank()) + 
  theme(text = element_text(size = 14)) +
  annotate(geom="richtext", x=1.5, y=6, 
           label= "M-W, <i>p</i>-value<0.001", size=4.5, label.color = NA)+
  theme(axis.title.x=element_blank(),
        legend.text = element_markdown())+
  labs(y= "Shannon index")

####################
###### CHAO1 ######
####################

pvals[2]

chao1 <- Alpha %>%
  mutate(status=factor(status, levels=c("positive",
                                        "negative"))) %>%
  ggplot(aes(x=status, y=chao1, fill = status))+
  stat_summary(fun = median, show.legend=FALSE, geom="crossbar")+
  geom_jitter(width=0.25, size=2.5, shape=21, color="black")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  scale_fill_manual(name = "HIV status",
                    values=c("#0000FF", "#FF0000")) +
  theme(axis.text.x =element_blank(),
        axis.ticks.x=element_blank(),
        legend.key=element_blank()) + 
  theme(text = element_text(size = 14)) +
  annotate(geom="richtext", x=1.5, y=650, 
           label= "M-W, <i>p</i>-value<0.001", size=4.5, label.color = NA)+
  theme(axis.title.x=element_blank(),
        legend.text = element_markdown())+
  labs(y= "Chao1 index")

####################
###### PIELOU ######
####################

pvals[3]

pielou <- Alpha %>%
  mutate(status=factor(status, levels=c("positive",
                                        "negative"))) %>%
  ggplot(aes(x=status, y=eveness, fill = status))+
  stat_summary(fun = median, show.legend=FALSE, geom="crossbar")+
  geom_jitter(width=0.25, size=2.5, shape=21, color="black")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  scale_fill_manual(name = "HIV status",
                    values=c("#0000FF", "#FF0000", "grey")) +
  theme(axis.text.x =element_blank(),
        axis.ticks.x=element_blank(),
        legend.key=element_blank()) + 
  theme(text = element_text(size = 14)) +
  annotate(geom="richtext", x=1.5, y=1.5, 
           label= "M-W, <i>p</i>-value<0.001", size=4.5, label.color = NA)+
  theme(axis.title.x=element_blank(),
        legend.text = element_markdown())+
  labs(y= "Pielou index")

######################
###### COMBINED ######
######################

combined <- (shannon + chao1 + pielou) & theme(legend.position = "bottom") 
combined <- combined + plot_layout(guides = "collect") & plot_annotation(tag_levels = list(c("A", "B", "C")))

ggsave(args[2], plot = combined, width = 12, height = 4, dpi=600)

