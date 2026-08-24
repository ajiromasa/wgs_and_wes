# alignment for WGS or WES on hgs shirokane
# 2025/6/16
# Masahiko Ajiro


# bwa and bqsr
module use /usr/local/package/modulefiles
module load bwa/0.7.17

bwa mem \
-t <int> \
-R '@RG\tID:<id>\tLB:lib1\tPL:illumina\tSM:<id>\tPU:<id>' \
hg38_v0_Homo_sapiens_assembly38.fasta \
<id>_1.fq.gz \
<id>_2.fq.gz \
> <id>.sam

samtools sort \
-@ <int> \
<id>.sam \
-o <id>.bam

gatk MarkDuplicates --java-options -Xmx16G \
-I <id>.bam \
-O <id>_markdup.bam \
-M <id>_metrics.txt

gatk BaseRecalibrator --java-options -Xmx16G \
--input <id>_markdup.bam --output <id>_recal.txt \
--known-sites hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz \
--known-sites hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf.gz \
--reference hg38_v0_Homo_sapiens_assembly38.fasta

gatk ApplyBQSR --java-options -Xmx16G \
-R hg38_v0_Homo_sapiens_assembly38.fasta \
-I <id>_markdup.bam \
--bqsr-recal-file <id>_recal.txt \
-O <id>_markdup_2.bam

samtools index -@ <int> <id>_markdup.bam

