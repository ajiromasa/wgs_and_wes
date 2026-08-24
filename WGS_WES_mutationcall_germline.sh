# WGS or WES for germline mutations on hgc shirokane
# 2025/6/16
# Masahiko Ajiro


# Mutation call
gatk HaplotypeCaller --java-options -Xmx30G \
-R hg38_v0_Homo_sapiens_assembly38.fasta \
-I <id>_markdup_r.bam \
-O <id>.vcf.gz \
-bamout <id>_markdup_r_hc.bam

# clinver
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar SnpSift.jar \
annotate \
clinvar_20241126.vcf.gz \
<id>.vcf.gz > <id>_1.vcf


# snpEff and RefSeq annotation and filtering
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar snpEff.jar GRCh38.p13 <id>_1.vcf > <id>_2.vcf
cat <id>_2.vcf |
java -jar SnpSift.jar filter \
"(GEN[*].DP >= 10) & (exists MQ[*]) & (MQ[*] >= 20)" > <id>_2f.vcf


# tommmo
export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
java -jar SnpSift.jar \
annotate \
tommo-60kjpn-20240904-GRCh38-snvindel-af-autosome.vcf.gz \
<id>_2f.vcf > <id>_3.vcf

export JAVA_TOOL_OPTIONS='-XX:+UseSerialGC -Xmx64G -Xms24G'
cat <id>_3.vcf | java -jar SnpSift.jar \
filter "((exists AF_XX) & (AF_XX<0.01)|!(exists AF_XX))" > <id>_3x.vcf
cat <id>_3x.vcf | java -jar SnpSift.jar \
filter "((exists AF_XY) & (AF_XY<0.01)|!(exists AF_XY))" > <id>_3y.vcf

