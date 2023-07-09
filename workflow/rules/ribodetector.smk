rule ribodetector_filter_one:
    """Run ribodetector on one library

    ribodetector filters out rRNA reads from a library
    """
    input:
        forward_=FASTP / "{sample}.{library}_1.fq.gz",
        reverse_=FASTP / "{sample}.{library}_2.fq.gz",
    output:
        forward_=temp(RIBODETECTOR / "{sample}.{library}_1.fq.gz"),
        reverse_=temp(RIBODETECTOR / "{sample}.{library}_2.fq.gz"),
    log:
        RIBODETECTOR / "{sample}.{library}.log",
    threads: 24
    params:
        average_length=params["ribodetector"]["average_length"],
        chunk_size=params["ribodetector"]["chunk_size"],
    conda:
        "../envs/ribodetector.yml",
    resources:
        mem_mb=32 * 1024,
        runtime= 6 * 60,
    shell:
        """
        ribodetector_cpu \
            --input \
                {input.forward_} \
                {input.reverse_} \
            --output \
                {output.forward_} \
                {output.reverse_} \
            --len {params.average_length} \
            --ensure rrna \
            --threads {threads} \
            --chunk_size {params.chunk_size} \
        2> {log} 1>&2
        """


rule ribodetector_find_all:
    """Run ribodetector_find_one over all libraries"""
    input:
        [
            RIBODETECTOR / f"{sample}.{library}_{end}.fq.gz"
            for sample, library  in SAMPLE_LIB
            for end in ["1", "2"]
        ]


rule ribodetector_fastqc_all:
    """Run fastqc over all libraries"""
    input:
        [
            RIBODETECTOR / f"{sample}.{library}_{end}_fastqc.{extension}"
            for sample, library in SAMPLE_LIB
            for end in ["1", "2"]
            for extension in ["html", "zip"]
        ],


rule ribodetector:
    """Run ribodetector and generate reports for all libraries"""
    input:
        rules.ribodetector_find_all.input,
        rules.ribodetector_fastqc_all.input,
