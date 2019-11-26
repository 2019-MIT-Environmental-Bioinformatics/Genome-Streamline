for file in ../metagenomes_filtered/*.fa.gz; do 
name=$(basename ${file} .fa.gz)
GC_num=$(zcat $file | grep -o '[GC]' | wc -l)
nuc_num=$(zcat $file | grep -o '[ATGC]' | wc -l)

GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" )

echo $GC > ./metagenomes/${name}_GC_meta.txt
echo $GC >> ALL_GC_meta.txt
done