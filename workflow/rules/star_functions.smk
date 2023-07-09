def get_star_out_prefix(wildcards):
    """Get the star output folder from the library wildcards"""
    return STAR / f"{wildcards.sample}.{wildcards.library}."


def get_star_output_r1(wildcards):
    """Get the forward read output from the library wildcards"""
    return STAR / f"{wildcards.sample}.{wildcards.library}.Unmapped.out.mate1"


def get_star_output_r2(wildcards):
    """Get the reverse read output from the library wildcards"""
    return STAR / f"{wildcards.sample}.{wildcards.library}.Unmapped.out.mate2"
