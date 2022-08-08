// Channels and Parameters
ch_bed_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bed_files/Twist_Alliance_Pan-cancer_Methylation_Panel_covered_targets_hg38.bed") 
ch_bam_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bam_files/KoM103B_R1_001.sorted.markDups.bam")
ch_bam_index_for_mosdepth = Channel.fromPath("/home/ec2-user/praktikum/testdata/bam_files/KoM103B_R1_001.sorted.markDups.bam.bai")
ch_multiqc_config = Channel.fromPath('/home/ec2-user/praktikum/nf_methylseq_prak/assets/multiqc_config.yaml', checkIfExists: true)
params.outdir = "${projectDir}/results"
params.publish_dir_mode = "copy"
params.name = "laura_test"
params.run_name = "laura_run1"

// Process Mosdepth
process mosdepth {
    
    publishDir "${params.outdir}/Mosdepth", mode: params.publish_dir_mode
    conda "/home/ec2-user/anaconda3/envs/mosdepth"

    input:
    file bed_file from ch_bed_for_mosdepth
    file bam_file from ch_bam_for_mosdepth
    file bam_index from ch_bam_index_for_mosdepth

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

// Process Multi-QC
process multiqc {
    publishDir "${params.outdir}/MultiQC", mode: params.publish_dir_mode
    conda "/home/ec2-user/anaconda3/envs/nf-core-methylseq-1.6.1"

    input:
    file (multiqc_config) from ch_multiqc_config
    file ('*') from ch_mosdepth_results_for_multiqc.collect().ifEmpty([])

    output:
    file "*multiqc_report.html" into ch_multiqc_report
    file "*_data"
    file "*_plots"

    script:
    rtitle = ''
    rfilename = ''
    rtitle = "--title \"${workflow.runName}\""
    rfilename = "--filename " + workflow.runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report"
    """
    multiqc -f $rtitle $rfilename . \\
        -m custom_content -m picard -m qualimap -m bismark -m samtools -m preseq -m cutadapt -m fastqc -m mosdepth
    """
}