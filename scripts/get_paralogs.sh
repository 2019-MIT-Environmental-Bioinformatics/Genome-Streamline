for file in ./*.out; do
	name=$(basename ${file} _proteins_blastclust.out)

	num_clusts=$(wc -l < $file)	## Each line of BlastClust output is one cluster
	num_genes=$(wc -w < $file)	## Each word in file is one contig/protein
 
	num_in_clusts=$(awk '!($2=="")' $file | wc -w) ## This is the number of contigs ("words") that are in a cluster of at least n=2 (second column is non-empty). 

	genes_in_paras=$( bc <<< "scale=5; ${num_in_clusts} / ${num_genes}" ) ## Performs arithmetic in bash to 5 significant figures

	echo "${name} ${genes_in_paras}" >> paralog_stats.txt ## Appends to output file
done

for file in ./cultures/*.out; do
	name=$(basename ${file} _proteins_blastclust.out)

	num_clusts=$(wc -l < $file)
	num_genes=$(wc -w < $file)

	num_in_clusts=$(awk '!($2=="")' $file | wc -w)

	genes_in_paras=$( bc <<< "scale=5; ${num_in_clusts} / ${num_genes}" )

	echo "${name} ${genes_in_paras}" >> paralog_stats.txt
done
