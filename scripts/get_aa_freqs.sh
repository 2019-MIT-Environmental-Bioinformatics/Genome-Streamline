for file in *.faa; do
name=$(basename $file _proteins.faa)
grep -v '^>' $file | tr -d '\n' | sed -e 's/\(.\)/\1\n/g' | sort | uniq -c | sort -rn > ${name}_AA_freqs.txt
done