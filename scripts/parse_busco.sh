for file in results/short_summary*
do
	data=$(grep -o "C:.*\%\[" $file | sed 's/C://g' | sed 's/\%\[//g') ## Greps the number of "Complete" orthologs
	db=$(grep -o "\w*.odb9" $file | uniq) ## Greps the database name
	name=$(basename $file | sed 's/short_summary_//g' | sed 's/_busco.*//g') ## Gets the ID of the assembly
	
	echo "${name},${db},${data}" >> busco_out.csv
done

