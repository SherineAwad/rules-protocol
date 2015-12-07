DATA = /mnt/research/ged/sherine/data
WORKDIR = /mnt/research/ged/sherine/rules-protocol
MYSCRIPTS = /mnt/research/ged/sherine/rules-protocol/myscripts
NUCMER = contigs_reports/nucmer_output
PREFIX = ecoli
N-READS-PER-FILE = 5536289548
mc= 0 250 500 750 1000 2000
KSIZE = 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51
KAK=kak
MEGAHIT=/mnt/home/mahmoud4/megahit
TRIM = /opt/software/Trimmomatic/0.32
TOOLKIT =/opt/software/FASTX/0.0.14--GCC-4.4.5/bin/
SANDBOX = /opt/software/khmer/khmer-1.4/sandbox
SCRIPTS =/opt/software/khmer/khmer-1.4/scripts
QUAST = ~/quast-2.3

#------------------------------------------------------DOWNLOAD ECOLI SINGLE CELL DATA AND PREPROCESS---------------------------------------------------------
download-ecoli-ref:
	#cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_ref.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_ref.fastq.bz2  

download-ecoli:
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane1.fastq.bz2 
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane2.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane3.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane4.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane5.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane6.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane7.fastq.bz2
	cd ${DATA} && wget --user single-cell  --password  SanDiegoCA http://bix.ucsd.edu/projects/singlecell/nbt_data/ecoli_mda_lane8.fastq.bz2
	cd ${DATA} && bzip2 -d ecoli_mda_lane1.fastq.bz2
	cd ${DATA} && bzip2 -d ecoli_mda_lane2.fastq.bz2  
	cd ${DATA} && bzip2 -d ecoli_mda_lane3.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_mda_lane4.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_mda_lane5.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_mda_lane6.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_mda_lane7.fastq.bz2 
	cd ${DATA} && bzip2 -d ecoli_mda_lane8.fastq.bz2 
	cd ${DATA} && cat ecoli*lane*.fastq > ecoli.fastq	
         	
split-ecoli: ${DATA}/ecoli.fastq
	#cd ${DATA} && split-paired-reads.py ${DATA}/ecoli.fastq 
	mv ${DATA}/ecoli.fastq.1 ${DATA}/ecoli-1.fastq 
	mv ${DATA}/ecoli.fastq.2 ${DATA}/ecoli-2.fastq 
	gzip -c ${DATA}/ecoli-1.fastq >${DATA}/ecoli-1.fastq.gz 
	gzip -c ${DATA}/ecoli-2.fastq >${DATA}/ecoli-2.fastq.gz 
#-------------------------------------------------------------ECOLI REQUIRED STATS----------------------------------------------------------------------------
count-table: ${DATA}/ecoli.fastq 
	load-into-counting.py -k 20 -x 1e9  ${WORKDIR}/ecoli.ct  ${DATA}/ecoli.fastq	
low-abundance: ${WORKDIR}/ecoli.ct 
	python ${MYSCRIPTS}/low-abundance.py ­C 2 ${WORKDIR}/ecoli.ct ${DATA}/ecoli.fastq > ${WORKDIR}/ecoli.abundance.low 

low-coverage: ${WORKDIR}/ecoli.ct 
	python ${SANDBOX}/slice-reads-by-coverage.py ${WORKDIR}/ecoli.ct ${DATA}/ecoli.fastq ${WORKDIR}/ecoli.coverage.fa ­m 20 ­M 40
	grep '^\@EAS' ${WORKDIR}/ecoli.coverage.fa | cut ­c2­ > ${WORKDIR}/ecoli.coverage.low

repeats: ${WORKDIR}/ecoli.ct 	
	python ${SANDBOX}/slice-reads-by-coverage.py ${WORKDIR}/ecoli.ct ${DATA}/ecoli.fastq ${WORKDIR}/ecoli.repeats.fa ­m 200
	grep '^\@EAS' ${WORKDIR}/ecoli.repeats.fa | cut ­c2­ >${WORKDIR}/ecoli.repeats

low-quality: ${WORKDIR}/ecoli.ct  
	${SCRIPTS}/low­quality.py ${DATA}/ecoli.fastq > ${WORKDIR}/ecoli.quality.low
#----------------------------------------------------------------QUALITY STARTS-------------------------------------------------------------------------------
interleaving-1: ${DATA}/${PREFIX}-1.fastq.gz  ${DATA}/${PREFIX}-2.fastq.gz
	cd quality && java -jar ${TRIM}/trimmomatic-0.32.jar PE ${DATA}/${PREFIX}-1.fastq.gz  ${DATA}/${PREFIX}-2.fastq.gz  s1_pe s1_se s2_pe s2_se ILLUMINACLIP:${TRIM}/adapters/TruSeq2-PE.fa:2:30:12 
	${SCRIPTS}/interleave-reads.py s1_pe s2_pe | gzip -9c > ${WORKDIR}/quality/${PREFIX}.pe.fq.gz
	cd quality && cat s1_se s2_se | gzip -9c > ${WORKDIR}/quality/${PREFIX}.se.fq.gz

interleaving-2: ${WORKDIR}/quality/${PREFIX}.se.fq.gz ${WORKDIR}/quality/${PREFIX}.pe.fq.gz
	cd quality && gunzip -c ${WORKDIR}/quality/${PREFIX}.pe.fq.gz | ${TOOLKIT}/fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c > ${WORKDIR}/quality/${PREFIX}.pe.qc.fq.gz 
	cd quality && gunzip -c ${WORKDIR}/quality/${PREFIX}.se.fq.gz | ${TOOLKIT}/fastq_quality_filter -Q33 -q 30 -p 50 | gzip -9c > ${WORKDIR}/quality/${PREFIX}.se.qc.fq.gz

interleaving-3: ${WORKDIR}/quality/${PREFIX}.pe.qc.fq.gz
	cd quality && extract-paired-reads.py ${WORKDIR}/quality/${PREFIX}.pe.qc.fq.gz 

protocol-quality-rename-1: ${WORKDIR}/quality/${PREFIX}.pe.qc.fq.gz.pe
	cd quality && ./qc-rename-1.sh 
	cd quality && touch protocol-quality-rename-1


protocol-quality-rename-2: ${WORKDIR}/quality/${PREFIX}.pe.qc.fq.gz.se
	cd quality && ./qc-rename-2.sh 
	cd quality && touch protocol-quality-rename-2

#--------------------------------------------------------------SPADES QUALITY---------------------------------------------------------------------------------
spades-quality-1: ${WORKDIR}/${PREFIX}.pe.qc.fq.gz
	./spades-qc.sh \
	touch spades-quality-1

spades-quality-2:  ${WORKDIR}/${PREFIX}.pe.qc.fq.gz
	/usr/bin/time -a -o ${WORKDIR}/sqc.txt spades.py --sc --pe1-12 ${WORKDIR}/${PREFIX}.pe.qc.fq.gz -o ${WORKDIR}/${PREFIX}.spades.d 

finalize-spades-quality: ${WORKDIR}/${PREFIX}.spades.d/contigs.fasta
	python ${SANDBOX}/sandbox/calc-best-assembly.py ${WORKDIR}/${PREFIX}.spades.d/contigs.fasta -o ${WORKDIR}/spades-quality-best.fa
	python ${SANDBOX}/sandbox/multi-rename.py assembly ${WORKDIR}/spades-quality-best.fa > ${WORKDIR}/spades-quality-assembly.fa
#------------------------------------------------------------------IDBA QUALITY-------------------------------------------------------------------------------
idba-quality-1: ${WORKDIR}/${PREFIX}.pe.qc.fq.gz
	./idba-qc.sh && touch idba-quality-1

idba-quality-2: ${WORKDIR}/${PREFIX}.pe.fa
	/usr/bin/time -a -o ${WORKDIR}/iqc.txt idba_ud --pre_correction -r ${WORKDIR}/${PREFIX}.pe.fa -o ${WORKDIR}/${PREFIX}.idba.d.qc 

finalize-idba-quality: ${WORKDIR}/${PREFIX}.idba.d.qc/scaffold.fa
	python ${SANDBOX}/sandbox/calc-best-assembly.py ${WORKDIR}/${PREFIX}.idba.d.qc/scaffold.fa -o ${WORKDIR}/idba-quality-best.fa 
	python ${SANDBOX}/sandbox/multi-rename.py assembly ${WORKDIR}/idba-quality-best.fa > ${WORKDIR}/idba-quality-assembly.fa

#----------------------------------------------------------------Megahit Quality------------------------------------------------------------------------------
megahit-qc-1: ${WORKDIR}/${PREFIX}.pe.qc.fq.gz ${WORKDIR}/${PREFIX}.se.qc.fq.gz
	/usr/bin/time  -a  -o ${WORKDIR}/megqc.txt python ${MEGAHIT}/megahit -l 101 -m 1e+10 --cpu-only -r ${WORKDIR}/${PREFIX}.pe.qc.fq.gz -o ${WORKDIR}/megahit.qc.pe \
	/usr/bin/time  -a  -o ${WORKDIR}/megqc.txt python ${MEGAHIT}/megahit -l 101 -m 1e+10 --cpu-only -r ${WORKDIR}/${PREFIX}.se.qc.fq.gz -o ${WORKDIR}/megahit.qc.se
finalize-megahit-quality:  ${WORKDIR}/megahit.qc.pe/final.contigs.fa ${WORKDIR}/megahit.qc.se/final.contigs.fa
	python ${SANDBOX}/sandbox/calc-best-assembly.py ${WORKDIR}/megahit.qc.?e/final.contigs.fa -o ${WORKDIR}/megahit-quality-best.fa
	python ${SANDBOX}/sandbox/multi-rename.py assembly ${WORKDIR}/megahit-quality-best.fa > ${WORKDIR}/megahit-quality-assembly.fa        
#-------------------------------------------------------------------QUASTING----------------------------------------------------------------------------------
quasting-vqc: ${WORKDIR}/velvet-quality-assembly.fa ${DATA}/ecoli_ref.fastq 
	python ${QUAST}/quast.py -R ${DATA}/ecoli_ref.fastq -o quast-vqc ${WORKDIR}/velvet-quality-assembly.fa 

quasting-iqc: ${WORKDIR}/idba-quality-assembly.fa ${DATA}/ecoli_ref.fastq 
	python ${QUAST}/quast.py -R ${DATA}/ecoli_ref.fastq -o quast-iqc ${WORKDIR}/idba-quality-assembly.fa 

quasting-sqc: ${WORKDIR}/spades-quality-assembly.fa ${DATA}/ecoli_ref.fastq 
	python ${QUAST}/quast.py -R ${DATA}/ecoli_ref.fastq -o quast-sqc ${WORKDIR}/spades-quality-assembly.fa 

quasting-mqc:  ${WORKDIR}/megahit-quality-assembly.fa ${DATA}/ecoli_ref.fastq
	python ${QUAST}/quast.py -R ${DATA}/ecoli_ref.fastq -o quast-mqc ${WORKDIR}/megahit-quality-assembly.fa 
#----------------------------------------------------------------------Mapping-------------------------------------------------------------------------------
	



