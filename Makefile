KHMER =  /usr/local/share/khmer 
CURRENT =/mnt/research/ged/sherine/rules
DATA = /mnt/home/data/
PREFIX = SRR606249
REFERENCE = /mnt/home/data/mircea.fa.gz 
ASSEMBLER = velvet


quality-filter: ${DATA}/${PREFIX}-1.fastq.gz  ${DATA}/${PREFIX}-2.fastq.gz
	interleaving-1 \
	interleaving-2 \
	interleaving-3 \
	protocol-quality-rename-1 \
	protocol-quality-rename-2 	

interleaving-1: ${DATA}/${PREFIX}-1.fastq.gz  ${DATA}/${PREFIX}-2.fastq.gz
        java -jar ${TRIM}/trimmomatic-0.30.jar PE ${DATA}/${PREFIX}-1.fastq.gz  ${DATA}/${PREFIX}-2.fastq.gz  ${QUALITY}/s1_pe ${QUALITY}/s1_se ${QUALITY}/s2_pe ${QUALITY}/s2_se ILLUMINACLIP:/usr/local/share/adapters/TruSeq3-PE.fa:2:30:10 \
        ${KHMER}/scripts/interleave-reads.py ${QUALITY}/s1_pe ${QUALITY}/s2_pe | gzip -9c > ${QUALITY}/${PREFIX}.pe.fq.gz \
        cat ${QUALITY}/s1_se ${QUALITY}/s2_se | gzip -9c > ${QUALITY}/${PREFIX}.se.fq.gz

interleaving-2: ${QUALITY}/${PREFIX}.se.fq.gz ${QUALITY}/${PREFIX}.pe.fq.gz
        gunzip -c ${QUALITY}/${PREFIX}.pe.fq.gz | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c > ${QUALITY}/${PREFIX}.pe.qc.fq.gz \
        gunzip -c ${QUALITY}/${PREFIX}.se.fq.gz | fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c > ${QUALITY}/${PREFIX}.se.qc.fq.gz

interleaving-3: ${QUALITY}/${PREFIX}.pe.qc.fq.gz 
        cd ${QUALITY} && extract-paired-reads.py ${QUALITY}/${PREFIX}.pe.qc.fq.gz 

protocol-quality-rename-1: ${QUALITY}/${PREFIX}.pe.qc.fq.gz.pe
        cd ${QUALITY} && ./qc-rename-1.sh \
        touch protocol-quality-rename-1

protocol-quality-rename-2: ${QUALITY}/${PREFIX}.pe.qc.fq.gz.se 
        cd ${QUALITY} && ./qc-rename-2.sh \
        touch protocol-quality-rename-2

countingtable: ${CURRENT}/${PREFIX}.pe.qc.fq.gz  ${CURRENT}/${PREFIX}.se.qc.fq.gz 
	${KHMER}/scripts/load-into-counting.py -k 20 -N 4 -x 5e8 ${CURRENT}/normC5k20.kh ${CURRENT}/${PREFIX}.*.qc.fq.gz

quasting: ${REFERENCE} ${CURRENT}/${ASSEMBLER}-assembly.fa   
	python ${QUAST}/quast.py -R ${REFERENCE} -o ${CURRENT}/${ASSEMBLER}-quality-quast/ ${CURRENT}/${ASSEMBLER}-quality-assembly.fa \
	
unaligned:  ${CURRENT}/${ASSEMBLER}-assembly.fa   ${CURRENT}/${PREFIX}.pe.qc.fq.gz  
	bwa index ${CURRENT}/${ASSEMBLER}-quality-assembly.fa \
	bwa aln ${CURRENT}/${ASSEMBLER}-quality-assembly.fa ${CURRENT}/${PREFIX}.pe.qc.fq.gz   > ${CURRENT}/${ASSEMBLER}.pe.sai \
	bwa samse ${CURRENT}/${ASSEMBLER}-quality-assembly.fa ${CURRENT}/${ASSEMBLER}.pe.sai ${CURRENT}/${PREFIX}.pe.qc.fq.gz >${CURRENT}/${ASSEMBLER}.pe.sam \
	samtools faidx ${CURRENT}/${ASSEMBLER}-quality-assembly.fa \
	samtools import ${CURRENT}/${ASSEMBLER}-quality-assembly.fa.fai ${CURRENT}/${ASSEMBLER}.pe.sam ${CURRENT}/${ASSEMBLER}.pe.bam \
	python extract-unaligned.py -o ${CURRENT}/${ASSEMBLER}.pe.unaligned --format fasta ${CURRENT}/${ASSEMBLER}.pe.bam \

low-quality: ${DATA}/${PREFIX}.fastq.gz 
	python low-quality.py ${DATA}/${PREFIX}.fastq.gz > ${CURRENT}/${PREFIX}.low

low-abundance: ${DATA}/${PREFIX}.fastq.gz ${CURRENT}/normC5k20.kh 
	python low-abundance.py ${CURRENT}/normC5k20.kh  ${DATA}/${PREFIX}.fastq.gz> ${CURRENT}/${PREFIX}.abundance

rules: ${CURRENT}/${ASSEMBLER}.pe.unaligned
	python rules.py ${CURRENT}/${ASSEMBLER}.pe.unaligned > ${CURRENT}/${ASSEMBLER}.rules


