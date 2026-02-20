#!/bin/bash

#B2B Vil alignment (paired-end, 1x flow cell)

#SBATCH --job-name=kallisto
#SBATCH --output=/work/giembycz_lab/B2B_Form-Salm-Vil-Ind_comparison/logs/_%j_vil_kallisto.out
#SBATCH --error=/work/giembycz_lab/B2B_Form-Salm-Vil-Ind_comparison/logs/_%j_vil_kallisto.err

#SBATCH --time=03:00:00
#SBATCH --mem=8GB
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1

module load kallisto/0.46.1

samp=$1

start=$(date "+%Y-%m-%d %H:%M:%S")

cd /work/giembycz_lab/B2B_tbv_analysis/fastq/${samp}

index=/work/giembycz_lab/ag_tools/kallisto_index_cdna_GRCh38_p13
fq1=./*_R1*.fastq.gz
fq2=./*_R2*.fastq.gz
outdir=/work/giembycz_lab/B2B_Form-Salm-Vil-Ind_comparison/vil_kallisto/${samp}/
mkdir -p $outdir

kallisto quant -i $index \
    -o $outdir \
    $fq1 $fq2 \
    --threads 4 \
    -b 100 \
    &> ${outdir}/log.txt

end=$(date "+%Y-%m-%d %H:%M:%S")

echo "==========================================================="
echo "Job ID: $SLURM_JOBID"
echo "Job name: $SLURM_JOBNAME"
echo "Sample: $samp"
echo "Start: $start"
echo "End: $end"

