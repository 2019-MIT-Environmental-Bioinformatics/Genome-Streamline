library(reshape2)
library(ggplot2)
library(plyr)
library(dplyr)

## Loads in the genome sizes and BlastClust paralog statistics
sizes=read.table("gen_sizes.txt")
colnames(sizes) <- c("Assembly", "size")
paras=read.table("paralog_stats.txt")
colnames(paras) <- c("Assembly", "paras")

## Loads in the sizes and paralog stats for the "extra" cultured genomes
extra_sizes=read.table("cory_sizes.txt")
colnames(extra_sizes) <- c("Assembly", "size")
extra_paras=read.table("cory_paralogs.txt")
colnames(extra_paras) <- c("Assembly", "paras")

## combines the sizes and paralog stats into one data frame
df <- join(sizes, paras, by="Assembly", type="left")

## Adds in the "extra" cultures
df_plus_extra <- rbind(df, join(extra_sizes, extra_paras, by="Assembly", type="left"))

## Adds a column indicating either SAG or Culture
df$type <- c(rep("SAG", 56), rep("Culture", 38))
df_plus_extra$type = c(rep("SAG", 56), rep("Culture", 58))

## For SAG's, adds a column indicating family
df$family <- c(rep('Arctic96BD-19', 4), rep('SAR86', 7), rep('SAR92', 2), rep('Verrucomicrobia', 15), rep('MGA', 5), rep('Roseobacter', 5), rep('SAR116', 9), rep('Actinobacteria', 2), rep('Bacteroidetes', 7), rep("Culture", 38))

## Saves vector of colours as used in Swan et al. figure 2. 
cols <- c('grey60', 'darkgreen', 'blue', 'black', 'orange', 'yellow', 'skyblue', 'red', 'brown', 'purple')

##I will just use bacteria_odb9 protein because I think this is more fair

## Reads in BUSCO statistics
busco <- read.csv("busco_stats.csv")

## Reads in size and assembly completeness stats from Swan et al.
stats <- read.table("si_paper_stats.txt")
recovery_stats <- stats[,c(1,6,7)]
names(recovery_stats) <- c("Assembly", "Percent recovery", "est size")

## Combines these into one data frame.
busco <- join(busco, recovery_stats, type="left", by="Assembly")

## I decided to only use the BUSCO results with the Bacteria database and not more-specific sub-databases.
## This seems less biased because otherwise the results will be sensitive to which taxa have better BUSCO databases.
## Plus, the results obtained this way were closer to the values reported in Swan et al. 
busco_bacts <- filter(busco, DB=="bacteria_odb9")

## I further decided to use the protein rather than nucleotide results (I'm fairly sure COG, used in Swan et al., works on proteins).
## However, in cases where the BUSCO protein results were NA for whatever reason, I substituted the nucleotide results
busco_bacts[is.na(busco_bacts$prot),]$prot = busco_bacts[is.na(busco_bacts$prot),]$nuc

## Creates a single data frame, estimating SAG genome size as the size of the assembly divided by the percent BUSCO recovery, in Mbp.
df <- join(df, busco_bacts, type='left', by='Assembly')
df$my_size = df$size/(df$prot/100)/1000000

df_plus_extra <- join(df_plus_extra, busco_bacts, type='left', by='Assembly')
df_plus_extra$my_size = df_plus_extra$size/(df_plus_extra$prot/100)/1000000

## If est. size is NA (for Cultured genomes), just use the actual assembly size in Mbp.
df[is.na(df$my_size),]$my_size = df[is.na(df$my_size),]$size/1000000
df_plus_extra[is.na(df_plus_extra$my_size),]$my_size = df_plus_extra[is.na(df_plus_extra$my_size),]$size/1000000


## Plots estimated genome size against paralog content, colouring SAG's by family
p <- ggplot(df_plus_extra[-32,], aes(x=my_size, y=paras*100, colour=type, shape=as.factor(type))) + geom_point(size=3) + theme_bw() + xlab("Genome Size (Mbp)") + ylab("% genes in paralog families") + scale_shape_manual(values=c(1,19), guide='none') + scale_color_manual(values=cols)

## Plots estimated genome size against paralog content, showing regression lines for cultures and SAG's.
q <- ggplot(df_plus_extra[-32,], aes(x=my_size, y=paras*100, colour=type, shape=as.factor(type))) + geom_point(size=3) + theme_bw() + xlab("Genome Size (Mbp)") + ylab("% genes in paralog families") + geom_smooth(method='lm', se = FALSE) + scale_shape_manual(values=c(1,19),guide='none')

## Uses ANOVA to test whether the two regression lines have different slopes (they do).
mod1 <- aov(paras~my_size+type, data=df) ## This fits a linear model with paralog frequency as a response variable and genome size and type (culture/SAG) as predictors.
mod2 <- aov(paras~my_size*type, data=df) ## This model includes an interaction between genome size and type
anova(mod1, mod2) ## This tests whether the model with the interaction is a better fit

mod_p1 <- aov(paras~my_size+type, data=df_plus_extra) # This does the same as above including the 'extra' cultures
mod_p2 <- aov(paras~my_size*type, data=df_plus_extra)
aa <- anova(mod_p1, mod_p2)