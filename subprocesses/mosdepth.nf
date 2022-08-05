// Channels and Parameters
ch_bed_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bed_files/Twist_Alliance_Pan-cancer_Methylation_Panel_covered_targets_hg38.bed") 
ch_bam_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bam_files/653-2022_R1_001.sorted.markDups.bam")
ch_bam_index_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bam_files/653-2022_R1_001.sorted.markDups.bam.bai")
params.outdir = "${projectDir}/results"
params.publish_dir_mode = "copy"
params.name = "laura_test"

// Process Mosdepth
process mosdepth {
    
    publishDir "${params.outdir}/Mosdepth", mode: params.publish_dir_mode
    conda "/home/ec2-user/anaconda3/envs/mosdepth"

    input:
    path bed_file from ch_bed_for_mosdepth
    path bam_file from ch_bam_for_mosdepth
    path bam_index from ch_bam_index_for_mosdepth

    output:
    file "*" into ch_mosdepth_results_for_multiqc

    script:
    """
    mosdepth -n -x \\
    --by ${bed_file} \\
    ${params.name} \\
    ${bam_file}
    """
}