# Genome-Streamline
The Official (?) repo for Zac, Cory, and Noah

## Part 0: General Notes
Noah: Protein annotation and functional biosynthesis mapping

Zac: Metagenome/SAG Comparison

Cory: Paralogs. Also, downloading the data.

We performed computational tasks using WHOI's Poseidon HPC---all shell scripts contained in the `scripts/` directory call resources specific to the structure of this cluster, and present a fundamental barrier to anyone else repeating our analysis. 

Additionally, while there are scripts (`scripts/SRA_download.sh` and `scripts/HF10_download`) for downloading the metagenomic data, these rely on a conda environment ("downloading") that resides in the `/envs` directory. The SAG downloading was done manually, and because all raw data for this project takes up substantial storage space, it does not reside in the repo. Scripts to run analyses often point to the `../data` superdirectory outside this one. 

## Part 1: Notes on Protein Annotation and Functional Mapping
For the 56 SAGs analyzed by Swan et al., we used Prodigal to identify protein-coding genes as the authors did, the script for doing so is `scripts/Prodigal-1.sh`. 

The authors utilized several utilities for mapping functional genes: the NCBI nonredundant database (nr), UniProt, TIGRfam, Pfam, KEGG, COG, and InterPro. We used the BLASTp utility to find functional orthologs in nr, as well as a utility (eggNOG v2.0) for functional mapping that did not exist at the time of publication.