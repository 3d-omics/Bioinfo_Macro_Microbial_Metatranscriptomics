rule star_index:
    """Index the genome for STAR"""
    input:
        dna=REFERENCE / "genome.fa",
        gtf=REFERENCE / "annotation.gtf",
    output:
        folder=directory("results/star/index"),
    params:
        sjdbOverhang=params["star"]["index"]["sjdbOverhang"],
    conda:
        "../envs/star.yml"
    log:
        REFERENCE / "index.log",
    threads: 24
    resources:
        mem_mb=32 * 1024,
        runtime=24 * 60,
    shell:
        """
        STAR \
            --runMode genomeGenerate \
            --runThreadN {threads} \
            --genomeDir {output.folder} \
            --genomeFastaFiles {input.dna} \
            --sjdbGTFfile {input.gtf} \
            --sjdbOverhang {params.sjdbOverhang} \
        2> {log} 1>&2
        """


rule star_align_one:
    """Align one library to the host genome with STAR to discard host RNA"""
    input:
        r1=RIBODETECTOR / "{sample}.{library}_1.fq.gz",
        r2=RIBODETECTOR / "{sample}.{library}_2.fq.gz",
        index=STAR / "index",
    output:
        bam=temp(STAR / "{sample}.{library}.Aligned.sortedByCoord.out.bam"),
        u1=temp(STAR / "{sample}.{library}.Unmapped.out.mate1"),
        u2=temp(STAR / "{sample}.{library}.Unmapped.out.mate2"),
        report=STAR / "{sample}.{library}.Log.final.out",
        counts=STAR / "{sample}.{library}.ReadsPerGene.out.tab",
    log:
        STAR / "{sample}.{library}.log",
    params:
        out_prefix=get_star_out_prefix,
    conda:
        "../envs/star.yml"
    threads: 24
    resources:
        mem_mb = 32 * 1024,
        runtime=24 * 60,
    shell:
        """
        ulimit -n 90000 2> {log} 1>&2

        STAR \
            --runMode alignReads \
            --runThreadN {threads} \
            --genomeDir {input.index} \
            --readFilesIn \
                {input.r1} \
                {input.r2} \
            --outFileNamePrefix {params.out_prefix} \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMunmapped Within KeepPairs \
            --outReadsUnmapped Fastx \
            --readFilesCommand "gzip -cd" \
            --quantMode GeneCounts \
        2>> {log} 1>&2
        """


rule star_align_all:
    input:
        [
            STAR / f"{sample}.{library}.ReadsPerGene.out.tab"
            for sample, library in SAMPLE_LIB
        ],


rule star_cram_one:
    """Convert to cram one library

    Note: we use samtools sort when it is already sorted because there is no
    other way to use minimizers on the unmapped fraction.
    """
    input:
        bam=STAR / "{sample}.{library}.Aligned.sortedByCoord.out.bam",
        reference=REFERENCE / "genome.fa",
    output:
        cram=STAR / "{sample}.{library}.cram",
        crai=STAR / "{sample}.{library}.cram.crai",
    log:
        STAR / "{sample}.{library}.Aligned.sortedByCoord.out.cram.log",
    conda:
        "../envs/star.yml"
    threads: 24
    resources:
        mem_mb=24 * 1024,
        runtime=24 * 60,
    shell:
        """
        samtools sort \
            -l 9 \
            -m 1G \
            -M \
            -o {output.cram} \
            --output-fmt CRAM \
            --reference {input.reference} \
            -@ {threads} \
            --write-index \
            {input.bam} \
        2> {log} 1>&2
        """


rule star_cram_all:
    """Convert to cram all libraries"""
    input:
        [
            STAR / f"{sample}.{library}.cram"
            for sample, library in SAMPLE_LIB
        ],


rule star_report_all:
    """Collect star reports"""
    input:
        [STAR / f"{sample}.{library}.Log.final.out" for sample, library in SAMPLE_LIB],


rule star:
    """Run all the elements in the star subworkflow"""
    input:
        rules.star_align_all.input,
        rules.star_cram_all.input,
        rules.star_report_all.input,
