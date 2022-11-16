//
// Align reads to a reference genome
// note that this can be parameterized -- could put $param.aligner
// in the include ... from ... path below
//

include { SAMTOOLS_INDEX } from "${projectDir}/modules/nf-core/samtools/index/main"
include { BWAMEM2_MEM    } from "${projectDir}/modules/nf-core/bwamem2/mem/main"

workflow ALIGN {
    take:
    reads           // channel: [ val(meta), [ reads ] ]
    bwamem2_index         // channel: file(fasta)

    main:

    // NOTE: when adding an aligner, make sure the output is sorted and indexed.

    ch_versions = Channel.empty()
    ch_bam      = Channel.empty()

    if(params.aligner == 'bwamem2') {
        sort_bam = true
        BWAMEM2_MEM (
            reads,
            bwamem2_index,
            sort_bam
        )
        ch_versions = ch_versions.mix(BWAMEM2_MEM.out.versions)

        SAMTOOLS_INDEX(
            BWAMEM2_MEM.out.bam
        )

        // TODO figure out how to mix without using a tmp ch
        BWAMEM2_MEM.out.bam
            .join(SAMTOOLS_INDEX.out.bai)
            .set{ ch_tmp }

        ch_bam = ch_bam.mix(ch_tmp)

    } else {
        exit 1, "No aligner specified in params OR aligner: ${params.aligner} is not recognized. "
    }

    emit:
    bam       = ch_bam      // channel: [ val(meta), path(bam), path(bai) ]
    versions  = ch_versions // channel: [ versions.yml ]
}
