#!/bin/bash

soap=soapdenovo2-63mer

dir="err"
errRates=(0.01 0.05 0.1 0.15)

for i in "${errRates[@]}"
do
	echo "Generating reads with error rate $i..."
	mkdir $dir$i
	chmod 777 $dir$i
 	wgsim -1 150 -2 150 -N 100000 -e $i genome.fa $dir$i/read1.fq $dir$i/read2.fq &> /dev/null
	echo "Done"

	echo "Assembling..."
	cp soap.config $dir$i
	sed -i "s+dir+$PWD/$dir$i+g" $dir$i/soap.config

	cd $dir$i
	echo "Set up"
	$soap pregraph -s soap.config -K 63 -R -o soapAssGraph 1> pregraph.log 2> pregraph.err
	echo "Contigs"
	$soap contig -g soapAssGraph -R 1>contig.log 2>contig.err
	echo "Read maps"
	$soap map -s soap.config -g soapAssGraph 1>map.log 2>map.err
	echo "Scaffolds"
	$soap scaff -g soapAssGraph -F 1>scaff.log 2>scaff.err
	echo "Done"

	echo "Mapping reads..."
	echo "Index"
	bowtie2-build ../genome.fa reference &> /dev/null
	bowtie2-build soapAssGraph.scafSeq scaffold &> /dev/null

	echo "Alignment"
	bowtie2 -p 8 -t -k 1 -x reference --very-fast -1 read1.fq -2 read2.fq -S bowRefFast.sam > bowRefFast.out 2> bowRefFast.err
	bowtie2 -p 8 -t -k 1 -x scaffold --very-fast -1 read1.fq -2 read2.fq -S bowScafFast.sam > bowScafFast.out 2> bowScafFast.err
	
	bowtie2 -p 8 -t -k 1 -x reference --very-sensitive -1 read1.fq -2 read2.fq -S bowRefSlow.sam > bowRefSlow.out 2> bowRefSlow.err
        bowtie2 -p 8 -t -k 1 -x scaffold --very-sensitive -1 read1.fq -2 read2.fq -S bowScafSlow.sam > bowScafSlow.out 2> bowScafSlow.err

	echo "Statistics"
	bows=("bowRefFast" "bowRefSlow" "bowScafFast" "bowScafSlow")
	for bowName in "${bows[@]}"
	do
		sed -En "s/(.*)% overall alignment rate/\1/p" $bowName.err >> $bowName.rate.stats
		samtools sort -o $bowName.bam $bowName.sam &> /dev/null
		samtools coverage $bowName.bam > $bowName.sam.stats
		samtools fasta $bowName.bam > $bowName.fa 
		assembly_stats $bowName.fa > $bowName.ass.stats
	done

	echo "Done"

	cd ..

done
