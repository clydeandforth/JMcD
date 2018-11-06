#!/bin/bash

#SBATCH -o RAY.o.%J
#SBATCH -J RAY
#SBATCH -e RAY.e.%J
#SBATCH -N 4
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=40
##SBATCH --mem-per-cpu=4000

module purge
module load Ray/2.3.1
module load seqtk/1.3

seqtk mergepe AT5_1.fastq.gz AT5_2.fastq.gz > AT5_interleaved.fastq.gz
seqtk mergepe AT8_1.fastq.gz AT8_2.fastq.gz > AT8_interleaved.fastq.gz
seqtk mergepe ROW1_1.fastq.gz ROW1_2.fastq.gz > ROW1_interleaved.fastq
seqtk mergepe ROW1_2_1.fastq.gz ROW1_2_2.fastq.gz > ROW1_2_interleaved.fastq
seqtk mergepe ROW2_1.fastq.gz ROW2_2.fastq.gz > ROW2_interleaved.fastq

#after merging to interleaved, the following command removed orphans and then split the files back to pe reads
seqtk dropse AT2_interleaved.fastq > AT2_interleaved_no_orphan.fastq && seqtk seq -1 AT2_interleaved_no_orphan.fastq > AT2_interleaved_no_orphan_1.fastq  && seqtk seq -2 AT2_interleaved_no_orphan.fastq > AT2_interleaved_no_orphan_2.fastq 

mpirun -n 40 Ray -k 51 -p AT5_interleaved_no_orphan_1.fastq AT5_interleaved_no_orphan_2.fastq -p AT8_interleaved_no_orphan_1.fastq AT8_interleaved_no_orphan_2.fastq -p ROW1_interleaved_no_orphan_1.fastq ROW1_interleaved_no_orphan_2.fastq -p ROW1_2_interleaved_no_orphan_1.fastq ROW1_2_interleaved_no_orphan_2.fastq -p ROW2_interleaved_no_orphan_1.fastq ROW2_interleaved_no_orphan_2.fastq  -o Symptomatic_RayOutput

mpirun -n 40 Ray -k 51  -p AT2_interleaved_no_orphan_1.fastq AT2_interleaved_no_orphan_2.fastq  -p AT3_interleaved_no_orphan_1.fastq AT3_interleaved_no_orphan_2.fastq -p AT4_interleaved_no_orphan_1.fastq AT4_interleaved_no_orphan_2.fastq  -o Healthy_RayOutput
