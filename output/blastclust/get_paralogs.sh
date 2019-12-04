for file in ./*.out; do
name=$(basename ${file} _proteins_blastclust.out)

num_clusts=$(wc -l < $file)
num_genes=$(wc -w < $file)
 
num_in_clusts=$(awk '!($2=="")' $file | wc -w)

genes_in_paras=$( bc <<< "scale=5; ${num_in_clusts} / ${num_genes}" )

echo "${name} ${genes_in_paras}" >> paralog_stats.txt
done

for file in ./cultures/*.out; do
name=$(basename ${file} _proteins_blastclust.out)

num_clusts=$(wc -l < $file)
num_genes=$(wc -w < $file)

num_in_clusts=$(awk '!($2=="")' $file | wc -w)

genes_in_paras=$( bc <<< "scale=5; ${num_in_clusts} / ${num_genes}" )

echo "${name} ${genes_in_paras}" >> paralog_stats.txt
done
