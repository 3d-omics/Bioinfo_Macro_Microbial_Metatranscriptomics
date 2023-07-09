rule kraken2_assign_one:
    """Run kraken2 over one library

    The database must be provided by the user in the config file.
    """
    input:
        forward_=FASTP / "{sample}.{library}_1.fq.gz",
        reverse_=FASTP / "{sample}.{library}_2.fq.gz",
        database=features["kraken2_db"],
    output:
        out_gz=KRAKEN2 / "{sample}.{library}.out.gz",
        report=KRAKEN2 / "{sample}.{library}.report",
    log:
        log=KRAKEN2 / "{sample}.{library}.log",
    conda:
        "../envs/kraken2.yml"
    threads: 24
    resources:
        mem_mb=eval(params["kraken2"]["mem_mb"]),
        runtime=60,
    shell:
        """
        kraken2 \
            --db {input.database} \
            --threads {threads} \
            --paired \
            --gzip-compressed \
            --output >(pigz -11 > {output.out_gz}) \
            --report {output.report} \
            {input.forward_} \
            {input.reverse_} \
        > {log} 2>&1
        """


rule kraken2_assign_all:
    """Run kraken2 over all libraries"""
    input:
        [KRAKEN2 / f"{sample}.{library}.report" for sample, library in SAMPLE_LIB],


rule kraken2_report_one:
    """Generate a report for one library

    Equivalent to just runing kraken2.
    """
    input:
        rules.kraken2_assign_one.output.report,


rule kraken2_report_all:
    """Generate all the reports"""
    input:
        rules.kraken2_assign_all.input,


rule kraken2:
    """Run the kraken2 subworkflow"""
    input:
        rules.kraken2_assign_all.input,
        rules.kraken2_report_all.input,
