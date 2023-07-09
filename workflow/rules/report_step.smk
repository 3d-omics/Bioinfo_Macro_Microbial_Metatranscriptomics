rule report_step_reads:
    """Collect all reports for the reads step"""
    input:
        rules.reads_fastqc_all.input,
    output:
        html=REPORT_STEP / "reads.html",
    log:
        REPORT_STEP / "reads.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --filename reads \
            --title reads \
            --force \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step_fastp:
    """Collect all reports for the fastp step"""
    input:
        rules.fastp_report_all.input,
    output:
        html=REPORT_STEP / "fastp.html",
    log:
        REPORT_STEP / "fastp.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --title fastp \
            --force \
            --filename fastp \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step_ribodetector:
    """Collect all reports for the ribodetector step"""
    input:
        rules.ribodetector_fastqc_all.input,
    output:
        html=REPORT_STEP / "ribodetector.html",
    log:
        REPORT_STEP / "ribodetector.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --title ribodetector \
            --force \
            --filename ribodetector \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step_kraken2:
    """Collect all reports for the fastp step"""
    input:
        rules.kraken2_report_all.input,
    output:
        html=REPORT_STEP / "kraken2.html",
    log:
        REPORT_STEP / "kraken2.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --title kraken2 \
            --force \
            --filename kraken2 \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step_star:
    """Collect all reports for the star step"""
    input:
        rules.star_report_all.input,
    output:
        html=REPORT_STEP / "star.html",
    log:
        REPORT_STEP / "star.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --title star \
            --force \
            --filename star \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step_bowtie2:
    """Collect all reports for the bowtie2 step"""
    input:
        rules.bowtie2_report_all.input,
    output:
        html=REPORT_STEP / "bowtie2.html",
    log:
        REPORT_STEP / "bowtie2.log",
    conda:
        "../envs/report.yml"
    params:
        dir=REPORT_STEP,
    shell:
        """
        multiqc \
            --title bowtie2 \
            --force \
            --filename bowtie2 \
            --outdir {params.dir} \
            {input} \
        2> {log} 1>&2
        """


rule report_step:
    """Collect all per step reports for the pipeline"""
    input:
        rules.report_step_reads.output,
        rules.report_step_fastp.output,
        rules.report_step_kraken2.output,
        rules.report_step_star.output,
        rules.report_step_bowtie2.output,


localrules:
    report_step_reads,
    report_step_fastp,
    report_step_kraken2,
    report_step_ribodetector,
    report_step_star,
    report_step_bowtie2,
