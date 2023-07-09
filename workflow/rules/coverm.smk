rule coverm_cram_to_bam:
    input:
        cram=BOWTIE2 / "{sample}.{library}.cram",
        reference=REFERENCE / "mags.fa.gz",
    output:
        bam=temp(COVERM / "bams/{sample}.{library}.bam"),
    log:
        COVERM / "bams/{sample}.{library}.log",
    conda:
        "../envs/coverm.yml"
    threads: 4
    resources:
        runtime=60,
        mem_mb=32 * 1024
    shell:
        """
        samtools view \
            --threads {threads} \
            --reference {input.reference} \
            --output-fmt BAM \
            --threads {threads} \
            --output {output.bam} \
            {input.cram} \
        2> {log} 1>&2
        """


rule coverm_genome:
   """calculation of mag-wise coverage"""
    input:
        bams=[COVERM / f"bams/{sample}.{library}.bam" for sample, library in SAMPLE_LIB],
    output:
        COVERM / "coverm_genome.tsv",
    log:
        COVERM / "coverm_genome.log",
    conda:
        "../envs/coverm.yml"
    params:
        methods=params["coverm"]["genome"]["methods"],
        min_covered_fraction=params["coverm"]["genome"]["min_covered_fraction"],
    threads: 24
    resources:
        runtime=24 * 60,
        mem_mb=32 * 1024
    shell:
        """
        coverm genome \
            --bam-files {input.bams} \
            --methods {params.methods} \
            --separator "^" \
            --threads {threads} \
            --min-covered-fraction {params.min_covered_fraction} \
        > {output} \
        2> {log}
        """


rule coverm_contig:
   """calculation of contig-wise coverage"""
    input:
        bams=[COVERM / f"bams/{sample}.{library}.bam" for sample, library in SAMPLE_LIB],
    output:
        COVERM / "coverm_contig.tsv",
    log:
        COVERM / "coverm_contig.log",
    conda:
        "../envs/coverm.yml"
    params:
        methods=params["coverm"]["contig"]["methods"],
    threads: 24
    resources:
        runtime=24 * 60,
        mem_mb=32 * 1024
    shell:
        """
        coverm contig \
            --bam-files {input.bams} \
            --methods {params.methods} \
            --proper-pairs-only \
        > {output} \
        2> {log}
        """


rule coverm:
    input:
        rules.coverm_genome.output,
        rules.coverm_contig.output,
