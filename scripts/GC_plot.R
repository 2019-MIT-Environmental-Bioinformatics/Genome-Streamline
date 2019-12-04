library(reshape2)
library(ggplot2)
library(plyr)
library(dplyr)


## Reads in the lists of GC content for the 5 different groupss
cds <- read.table("ALL_GC_coding.txt") 
cds_cult <- read.table("ALL_GC_cult_coding.txt")
cults <- read.table("ALL_GC_cultures.txt")
sags <- read.table("ALL_GC_genomic.txt")
metas <- read.table("ALL_GC_meta.txt")

## Combines the lists into one data frame
df_list <- c(cds, cds_cult, cults, sags, metas)
names(df_list) = c("cds", "cult_cds", "cults", "sags", "metas")

## For plotting purposes, makes a two-column data frame where 'value' is the GC content and 'L1' is the group to which it belongs
df <- melt(df_list)

## Sets the order in which the groups should be plotted
df$L1 <- factor(df$L1, levels = c("cults", "sags", "metas", "cult_cds", "cds"))


## Makes 5 boxplots with GC content on the y axis
a <- ggplot(df, aes(y=value, fill=L1, x=L1)) + geom_boxplot() + theme_minimal() + ylab("GC content") + theme(axis.title.x=element_blank(), axis.text.x=element_text(size=12), legend.position = "none") + scale_fill_manual(values = c("cornflowerblue", "lightcoral", "grey90", "cornflowerblue", "lightcoral")) + ylim(c(0.2, 0.8)) + scale_x_discrete(labels=c("Cultures", "SAG's", "Metagenomes", "Cultures coding", "SAG's coding"))

## Saves as high-res .png file
png("GC_plot.png", units = 'in', res = 300, width=8, height=6)
a
dev.off()

## Performs t-tests to check for significant differences in GC conent between groups:
## SAG coding regions have significantly lower GC content than cultured codign regions, 
## and both metagenomes and SAG genomes have significantly lower GC content than cultured genomes
t.test(filter(df, L1=="cds")$value, filter(df, L1=="cult_cds")$value)
t.test(filter(df, L1=="cults")$value, filter(df, L1=="sags")$value)
t.test(filter(df, L1=="cults")$value, filter(df, L1=="metas")$value)