# WGS or WES for somatic mutations on hgc shirokane
# 2025/6/16
# Masahiko Ajiro


# Mutation call
gatk Mutect2 --java-options -Xmx30G \
-R hg38_v0_Homo_sapiens_assembly38.fasta \
-I <id1>_markdup_r.bam \
-I <id2>_markdup_r.bam \
--tumor-sample <id1> \
--normal-sample <id2> \
--output <id>.vcf

## without normal control
gatk Mutect2 --java-options -Xmx30G \
-R hg38_v0_Homo_sapiens_assembly38.fasta \
-I <id>_markdup_r.bam \
--tumor_sample <id> \
--germline-regermline-resource af-only-gnomad.hg38.vcf.gz \
--output <id>.vcf


# snpEff and RefSeq annotation
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar snpEff.jar GRCh38.p13 <id>.vcf > <id>_1.vcf


# technical filtering
# "GEN[0].AF <= 0.04" is optional and may yield false negative in some cases.
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
cat <id>_1.vcf | java -jar SnpSift.jar filter \
"(GEN[*].DP >= 25) & (exists MBQ[*]) & (MBQ[*] >= 20) & (GEN[0].AF <= 0.04) & (GEN[1].AF >= 0.08)" > <id>_2.vcf


# clinvar
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar SnpSift.jar \
annotate \
clinvar_20241126.vcf.gz \
<id>_2.vcf > <id>_3.vcf

cat <id>_3.vcf | java -jar SnpSift.jar filter \
-n "(( CLNSIG has 'Likely_benign') | ( CLNSIG has 'Benign'))" > <id>_3f.vcf


# tommo 60k
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar SnpSift.jar annotate \
tommo-60kjpn-20240904-GRCh38-snvindel-af-autosome.vcf.gz \
<id>_3f.vcf > <id>_4.vcf

cat <id>_4.vcf | java -jar /home/ajiro2/tools/snpEff/SnpSift.jar \
filter "((exists AF) & (AF<0.01)|!(exists AF))" > <id>_4f.vcf


# cosmic
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar /home/ajiro2/tools/snpEff/SnpSift.jar \
annotate \
Cosmic_GenomeScreensMutant_v101_GRCh38.vcf.gz \
<id>_4f.vcf > <id>_5.vcf

cat <id>_5.vcf | java -jar /home/ajiro2/tools/snpEff/SnpSift.jar filter \
-s Cosmic_CancerGeneCensus_IG_TR_HLA_removed746.txt "ANN[*].GENE in SET[0]" > <id>_5f.vcf


# snpEff impact
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
cat <id>_5f.vcf | java -jar SnpSift.jar filter \
"(ANN[*].IMPACT == 'HIGH') | (ANN[*].IMPACT == 'MODERATE')" > <id>_6.vcf


