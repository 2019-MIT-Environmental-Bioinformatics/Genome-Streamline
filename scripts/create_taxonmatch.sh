#!/bin/bash

rm /vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/notes/ngermolus/taxon_match.csv

echo "SAG_ID,TAXON" > /vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/notes/ngermolus/taxon_match.csv

for file in $(ls /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/*.faa)
	do echo -e "$(basename $file _proteins.faa)\t" >> /vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/notes/ngermolus/taxon_match.csv
	done