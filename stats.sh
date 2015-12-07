#PBS -A ged
#PBS -l nodes=1:ppn=3
#PBS -l walltime=160:00:00
#PBS -l mem=75GB
#PBS -N ecoli-split


cd /mnt/research/ged/sherine/rules-protocol
module load Trimmomatic
module swap GNU GNU/4.8.2
module load khmer


make split-ecoli









