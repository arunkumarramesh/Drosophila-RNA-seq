## Index genome using STAR aligner
STAR --runMode genomeGenerate --genomeDir STARindex/ --genomeFastaFiles dmel-all-chromosome-r6.28.fasta --sjdbGTFfile dmel-all-r6.28.gtf --sjdbOverhang 49 --runThreadN 20

## Trim RNA-seq reads
for file in *3.r_1.fq.gz; do java -jar trimmomatic-0.36.jar SE -phred33 $file ${file/3.r_1.fq.gz/3.r_trim_1.fq.gz} ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -threads 25; done
 
## Align reads using STAR
for file in *.s_3.r_trim_1.fq.gz; do STAR --runMode alignReads --genomeDir STARindex/ --readFilesIn $file --readFilesCommand zcat --outFileNamePrefix ${file/.s_3.r_trim_1.fq.gz/rRNA/} --outFilterMultimapNmax 10000000000 --outReadsUnmapped Fastx --outSAMtype BAM SortedByCoordinate --twopassMode Basic --runThreadN 35; done

## Mapped BAM quality check
java -Xmx4G -jar QoRTs.jar --singleEnded –maxReadLength 50 --seqReadCt 8967167 --generatePlots Aligned.sortedByCoord.out.bam dmel-all-r6.28.gtf QC/
qualimap rnaseq -outdirresults/ -bam Aligned.sortedByCoord.out.bam -gtf dmel-all-r6.28.gtf --java-mem-size=8G
 
## Count reads using featureCounts
featureCounts -t gene -a dmel-all-r6.28.gtf -Q 10 -o gene_count_mq10.txt -T 15 *.out.bam
