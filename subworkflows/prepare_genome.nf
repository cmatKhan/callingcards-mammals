//
// Index the reference genome and align reads
//

include { BWAMEM2_INDEX } from  "${projectDir}/modules/nf-core/bwamem2/index/main"
include { SAMTOOLS_FAIDX } from "${projectDir}/modules/nf-core/samtools/faidx/main"

workflow PREPARE_GENOME {
    take:
    fasta   // path(genome)

    main:

    ch_versions = Channel.empty()
    ch_bwamem2_index = Channel.empty()

    if (!params.bwamem2_index){
        BWAMEM2_INDEX ( fasta.map{it -> ["", it]}  )
        ch_bwamem2_index = BWAMEM2_INDEX.out.index
        ch_versions = ch_versions.mix(BWAMEM2_INDEX.out.versions)
    } else{
        ch_bwamem2_index = Channel.of(["",params.bwamem2_index]).collect()
    }

    if (!params.fasta_index){
        SAMTOOLS_FAIDX ( fasta.map{it -> ["", it]} )
        ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)
        ch_fasta_index = SAMTOOLS_FAIDX.out.fai
    } else {
        ch_fasta_index = Channel.of(["",params.fasta_index]).collect()
    }

    emit:
    fai           = ch_fasta_index          // channel: path(*.fai)
    bwamem2_index = ch_bwamem2_index        // bwamem2
    versions      = ch_versions             // channel: [ versions.yml ]
}
