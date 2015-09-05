Step One 
---------

1. Load reads into a counting table 

	load-into-counting.py -x 1e8 -k 20 out.ct SRR606249_4m1.fastq 

2. Getting reads with low-abundance kmers

	run low-abundance.py:  a modified script from filt-below-abund.py 

	python low-abundance.py -C 2 out.ct  SRR606249_4m1.fastq >  abundance.low 

3. Getting reads with low coverage:  

	sandbox/slice-reads-by-coverage.py out.ct SRR606249_4m1.fastq  coverage.fa -m 20 -M 40

	grep '^\@SRR' coverage.fa | cut -c2-  >coverage.low 

4. Getting reads with high coverage representing repeats: 

	/sandbox/slice-reads-by-coverage.py out.ct SRR606249_4m1.fastq  repeats.fa -m 200

	grep '^\@SRR' repeats.fa | cut -c2-  >repeats.low 

5. Getting reads with low quality bases using phred score

	low-quality.py SRR606249_4m1.fastq > qc.low

6. Run generate rules to find rules that leads to unalignment 
	 python rules.py unalignment.fa > rules.txt  
 	 It reads  all .low file including qc.low, abundance.low, coverage.low and repeats.low
