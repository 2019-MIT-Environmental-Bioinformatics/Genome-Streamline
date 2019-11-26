for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/ -name *.fna.gz); do
name=$(basename ${file} .fna.gz)

echo "${name} $( zcat $file | grep -v ">" | wc | awk '{print $3-$1}' )" >> gen_sizes.txt
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/cultures/ -name *.fna.gz); do
name=$(basename ${file} .fna.gz)

echo "${name} $( zcat $file | grep -v ">" | wc | awk '{print $3-$1}' )" >> gen_sizes.txt
done









