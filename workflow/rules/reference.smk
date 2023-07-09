rule reference_set_dna:
    """Link the reference genome to the results directory"""
    input:
        fa=features["host"]["dna"],
    output:
        fa=REFERENCE / "genome.fa",
    log:
        REFERENCE / "genome.log",
    conda:
        "../envs/empty.yml"
    shell:
        "gzip --decompress --stdout {input.fa} > {output.fa} 2> {log}"


rule reference_set_gtf:
    """Link the reference annotation to the results directory"""
    input:
        gtf=features["host"]["gtf"],
    output:
        gtf=REFERENCE / "annotation.gtf",
    log:
        REFERENCE / "annotation.log",
    conda:
        "../envs/empty.yml"
    shell:
        "gzip --decompress --stdout {input.gtf} > {output.gtf}"


rule reference_set_mags:
    """Recpmpress the MAGs into the results directory"""
    input:
        fna=features["mags"],
    output:
        fna=REFERENCE / "mags.fa.gz",
    log:
        REFERENCE / "mags.log",
    conda:
        "../envs/samtools.yml"
    threads:
        24
    shell:
        """
        (gzip -dc {input.fna} \
        | bgzip \
            -@ {threads} \
            -l 9 \
        > {output.fna}) 2> {log}
        """


rule reference:
    input:
        rules.reference_set_dna.output.fa,
        rules.reference_set_gtf.output.gtf,
        rules.reference_set_mags.output.fna,
