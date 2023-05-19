rule bowtie2_build:
    """Build bowtie2 index for the mags"""
    input:
        reference=REFERENCE / "mags.fa.gz",
    output:
        multiext(
            f"{REFERENCE}/mags",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        BOWTIE2 / "build.log",
    benchmark:
        BOWTIE2 / "build.bmk"
    conda:
        "../envs/bowtie2.yml"
    params:
        output_path=REFERENCE / "mags",
        extra=params["bowtie2"]["extra"],
    threads: 8
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {params.extra} \
            {input.reference} \
            {params.output_path} \
        2> {log} 1>&2
        """


rule bowtie2_map_one:
    """Map one library to reference genome using bowtie2"""
    input:
        forward_=STAR / "{sample}.{library}.Unmapped.out.mate1",
        reverse_=STAR / "{sample}.{library}.Unmapped.out.mate2",
        idx=multiext(
            f"{REFERENCE}/mags",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
        reference=REFERENCE / "mags.fa.gz",
    output:
        cram=protected(BOWTIE2 / "{sample}.{library}.cram"),
    log:
        BOWTIE2 / "{sample}.{library}.log",
    benchmark:
        BOWTIE2 / "{sample}.{library}.bmk"
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
        mem_mb=30000,
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
    """Run bowtie2 on all libraries"""
    input:
        [BOWTIE2 / f"{sample}.{library}.cram" for sample, library in SAMPLE_LIB],


rule bowtie2:
    """Run bowtie2 on all libraries and generate reports"""
    input:
        rules.bowtie2_map_all.input,
