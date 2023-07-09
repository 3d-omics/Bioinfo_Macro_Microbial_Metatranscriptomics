rule bowtie2_build:
    """Build bowtie2 index for the mags"""
    input:
        reference=REFERENCE / "mags.fa.gz",
    output:
        prefix = touch(REFERENCE / "mags")
    log:
        BOWTIE2 / "build.log",
    conda:
        "../envs/bowtie2.yml"
    params:
        extra=params["bowtie2"]["extra"],
    threads: 8
    resources:
        mem_mb=32 * 1024,
        runtime=6 * 60,
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {params.extra} \
            {input.reference} \
            {output.prefix} \
        2> {log} 1>&2
        """


rule bowtie2_map_one:
    """Map one library to reference genome using bowtie2

    Output SAM file is piped to samtools sort to generate a CRAM file.
    """
    input:
        forward_=STAR / "{sample}.{library}.Unmapped.out.mate1",
        reverse_=STAR / "{sample}.{library}.Unmapped.out.mate2",
        idx=REFERENCE / "mags",
        reference=REFERENCE / "mags.fa.gz",
    output:
        cram=BOWTIE2 / "{sample}.{library}.cram",
    log:
        BOWTIE2 / "{sample}.{library}.log",
    params:
        index_prefix=REFERENCE / "mags",
        extra=params["bowtie2"]["extra"],
        samtools_mem=params["bowtie2"]["samtools"]["mem_per_thread"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
    threads: 24
    conda:
        "../envs/bowtie2.yml"
    resources:
        mem_mb=32 * 1024,
        runtime=1440,
    shell:
        """
        (bowtie2 \
            -x {params.index_prefix} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            --threads {threads} \
            --rg-id '{params.rg_id}' \
            --rg '{params.rg_extra}' \
            {params.extra} \
        | samtools sort \
            -l 9 \
            -M \
            -m {params.samtools_mem} \
            -o {output.cram} \
            --reference {input.reference} \
            --threads {threads} \
        ) 2> {log} 1>&2
        """


rule bowtie2_map_all:
    """Collect the results of `bowtie2_map_one` for all libraries"""
    input:
        [BOWTIE2 / f"{sample}.{library}.cram" for sample, library in SAMPLE_LIB],


rule bowtie2_report_all:
    """Generate bowtie2 reports for all libraries:
    - samtools stats
    - samtools flagstats
    - samtools idxstats
    """
    input:
        [
            BOWTIE2 / f"{sample}.{library}.{report}"
            for sample, library in SAMPLE_LIB
            for report in BAM_REPORTS
        ],


rule bowtie2:
    """Run bowtie2 on all libraries and generate reports"""
    input:
        rules.bowtie2_map_all.input,
        rules.bowtie2_report_all.input,
