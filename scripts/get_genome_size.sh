## This scripts loops through every SAG and culture genome and counts the number of nucleotides

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/ -name *.fna.gz); do
	name=$(basename ${file} .fna.gz)
	
	# unzips the file, greps every sequence (non-header) line, and prints the caracter count minus the line count (this works because wc -c counts newlines as characters).
	# Then it appends all of this to the output file.
	echo "${name} $( zcat $file | grep -v ">" | wc | awk '{print $3-$1}' )" >> gen_sizes.txt
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/cultures/ -name *.fna.gz); do
	name=$(basename ${file} .fna.gz)
	echo "${name} $( zcat $file | grep -v ">" | wc | awk '{print $3-$1}' )" >> gen_sizes.txt
done









