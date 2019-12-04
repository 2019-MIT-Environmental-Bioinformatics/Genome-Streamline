#!/bin/bash
# This should quickly process all the eggNOG outputs in such a way that the _kegg files can be thrown into KEGG and visualized as pathways.

cd /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/eggNOGged
for file in $(ls /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/eggNOGged/*annotations)
	do name=$(basename $file _proteins_maNOG.txt.emapper.annotations)
	rm ${name}/*
	rmdir ${name}
	mkdir ${name}
	head -n 3 ${file} > ${name}/${name}_head.txt
	tail -n 3 ${file} > ${name}/${name}_tail.txt
	tail -n +4 ${file} | head -n -3 > ${name}/${name}_cut.txt
	echo -e "#query_name\tKEGG_ko\tKEGG_Pathway\tKEGG_Module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\tBiGG_Reaction\ttaxonomic scope
" > ${name}/${name}_kegg.txt
	awk -v OFS="\t" '{print $1OFS$9OFS$10OFS$11OFS$12OFS$13OFS$14OFS$15OFS$16OFS$17OFS$18}' ${name}/${name}_cut.txt | grep -E "ko[0-9]+" >> ${name}/${name}_kegg.txt
	done