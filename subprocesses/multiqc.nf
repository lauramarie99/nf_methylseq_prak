params.outdir = "${projectDir}/results"
ch_fastqc_results_for_multiqc = Channel.fromPath('/home/ec2-user/praktikum/nf_methylseq_prak/data/*')
ch_multiqc_config = Channel.fromPath('/home/ec2-user/praktikum/nf_methylseq_prak/assets/multiqc_config.yaml', checkIfExists: true)
params.run_name = "laura_run1"
/*
 * STEP 10 - MultiQC
 */
process multiqc {
    publishDir "${params.outdir}/MultiQC", mode: 'copy'
    conda "/home/ec2-user/anaconda3/envs/nf-core-methylseq-1.6.1"

    input:
    file (multiqc_config) from ch_multiqc_config
    file ('fastqc/*') from ch_fastqc_results_for_multiqc.collect().ifEmpty([])

    output:
    file "*multiqc_report.html" into ch_multiqc_report
    file "*_data"
    file "*_plots"

    script:
    rtitle = ''
    rfilename = ''
    //rtitle = "--title \"laura_run1\""
    //rfilename = "--filename laura_run1_multiqc_report"
    rtitle = "--title \"${workflow.runName}\""
    rfilename = "--filename " + workflow.runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report"

    """
    multiqc -f $rtitle $rfilename . \\
        -m custom_content -m picard -m qualimap -m bismark -m samtools -m preseq -m cutadapt -m fastqc
    """
}
