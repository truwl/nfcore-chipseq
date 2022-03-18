version 1.0

workflow chipseq {
	input{
		File samplesheet
		Boolean? single_end
		Int? fragment_size
		String? seq_center
		String outdir = "./results"
		String? email
		String? genome
		File? fasta
		String? gtf
		String? bwa_index
		String? gene_bed
		String? macs_gsize
		String? blacklist
		Boolean? save_reference
		String igenomes_base = "s3://ngi-igenomes/igenomes/"
		Boolean? igenomes_ignore
		Int? clip_r1
		Int? clip_r2
		Int? three_prime_clip_r1
		Int? three_prime_clip_r2
		Int? trim_nextseq
		Boolean? skip_trimming
		Boolean? save_trimmed
		Boolean? keep_dups
		Boolean? keep_multi_map
		Int? bwa_min_score
		Boolean? save_align_intermeds
		String bamtools_filter_pe_config = "$baseDir/assets/bamtools_filter_pe.json"
		String bamtools_filter_se_config = "$baseDir/assets/bamtools_filter_se.json"
		Boolean? narrow_peak
		Float broad_cutoff = 0.1
		Float? macs_fdr
		Float? macs_pvalue
		Int min_reps_consensus = 1
		Boolean? save_macs_pileup
		Boolean? skip_peak_qc
		Boolean? skip_peak_annotation
		Boolean? skip_consensus_peaks
		Boolean? deseq2_vst
		Boolean? skip_diff_analysis
		Boolean? skip_fastqc
		Boolean? skip_picard_metrics
		Boolean? skip_preseq
		Boolean? skip_plot_profile
		Boolean? skip_plot_fingerprint
		Boolean? skip_spp
		Boolean? skip_igv
		Boolean? skip_multiqc
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		Int fingerprint_bins = 500000
		String publish_dir_mode = "copy"
		String? name
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		String? clusterOptions

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			single_end = single_end,
			fragment_size = fragment_size,
			seq_center = seq_center,
			outdir = outdir,
			email = email,
			genome = genome,
			fasta = fasta,
			gtf = gtf,
			bwa_index = bwa_index,
			gene_bed = gene_bed,
			macs_gsize = macs_gsize,
			blacklist = blacklist,
			save_reference = save_reference,
			igenomes_base = igenomes_base,
			igenomes_ignore = igenomes_ignore,
			clip_r1 = clip_r1,
			clip_r2 = clip_r2,
			three_prime_clip_r1 = three_prime_clip_r1,
			three_prime_clip_r2 = three_prime_clip_r2,
			trim_nextseq = trim_nextseq,
			skip_trimming = skip_trimming,
			save_trimmed = save_trimmed,
			keep_dups = keep_dups,
			keep_multi_map = keep_multi_map,
			bwa_min_score = bwa_min_score,
			save_align_intermeds = save_align_intermeds,
			bamtools_filter_pe_config = bamtools_filter_pe_config,
			bamtools_filter_se_config = bamtools_filter_se_config,
			narrow_peak = narrow_peak,
			broad_cutoff = broad_cutoff,
			macs_fdr = macs_fdr,
			macs_pvalue = macs_pvalue,
			min_reps_consensus = min_reps_consensus,
			save_macs_pileup = save_macs_pileup,
			skip_peak_qc = skip_peak_qc,
			skip_peak_annotation = skip_peak_annotation,
			skip_consensus_peaks = skip_consensus_peaks,
			deseq2_vst = deseq2_vst,
			skip_diff_analysis = skip_diff_analysis,
			skip_fastqc = skip_fastqc,
			skip_picard_metrics = skip_picard_metrics,
			skip_preseq = skip_preseq,
			skip_plot_profile = skip_plot_profile,
			skip_plot_fingerprint = skip_plot_fingerprint,
			skip_spp = skip_spp,
			skip_igv = skip_igv,
			skip_multiqc = skip_multiqc,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			help = help,
			fingerprint_bins = fingerprint_bins,
			publish_dir_mode = publish_dir_mode,
			name = name,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			clusterOptions = clusterOptions,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-chipseq/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		Boolean? single_end
		Int? fragment_size
		String? seq_center
		String outdir = "./results"
		String? email
		String? genome
		File? fasta
		String? gtf
		String? bwa_index
		String? gene_bed
		String? macs_gsize
		String? blacklist
		Boolean? save_reference
		String igenomes_base = "s3://ngi-igenomes/igenomes/"
		Boolean? igenomes_ignore
		Int? clip_r1
		Int? clip_r2
		Int? three_prime_clip_r1
		Int? three_prime_clip_r2
		Int? trim_nextseq
		Boolean? skip_trimming
		Boolean? save_trimmed
		Boolean? keep_dups
		Boolean? keep_multi_map
		Int? bwa_min_score
		Boolean? save_align_intermeds
		String bamtools_filter_pe_config = "$baseDir/assets/bamtools_filter_pe.json"
		String bamtools_filter_se_config = "$baseDir/assets/bamtools_filter_se.json"
		Boolean? narrow_peak
		Float broad_cutoff = 0.1
		Float? macs_fdr
		Float? macs_pvalue
		Int min_reps_consensus = 1
		Boolean? save_macs_pileup
		Boolean? skip_peak_qc
		Boolean? skip_peak_annotation
		Boolean? skip_consensus_peaks
		Boolean? deseq2_vst
		Boolean? skip_diff_analysis
		Boolean? skip_fastqc
		Boolean? skip_picard_metrics
		Boolean? skip_preseq
		Boolean? skip_plot_profile
		Boolean? skip_plot_fingerprint
		Boolean? skip_spp
		Boolean? skip_igv
		Boolean? skip_multiqc
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		Int fingerprint_bins = 500000
		String publish_dir_mode = "copy"
		String? name
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		String? clusterOptions

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /chipseq-1.2.2  -profile truwl,nfcore-chipseq  --input ~{samplesheet} 	~{"--samplesheet '" + samplesheet + "'"}	~{true="--single_end  " false="" single_end}	~{"--fragment_size " + fragment_size}	~{"--seq_center '" + seq_center + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--genome '" + genome + "'"}	~{"--fasta '" + fasta + "'"}	~{"--gtf '" + gtf + "'"}	~{"--bwa_index '" + bwa_index + "'"}	~{"--gene_bed '" + gene_bed + "'"}	~{"--macs_gsize '" + macs_gsize + "'"}	~{"--blacklist '" + blacklist + "'"}	~{true="--save_reference  " false="" save_reference}	~{"--igenomes_base '" + igenomes_base + "'"}	~{true="--igenomes_ignore  " false="" igenomes_ignore}	~{"--clip_r1 " + clip_r1}	~{"--clip_r2 " + clip_r2}	~{"--three_prime_clip_r1 " + three_prime_clip_r1}	~{"--three_prime_clip_r2 " + three_prime_clip_r2}	~{"--trim_nextseq " + trim_nextseq}	~{true="--skip_trimming  " false="" skip_trimming}	~{true="--save_trimmed  " false="" save_trimmed}	~{true="--keep_dups  " false="" keep_dups}	~{true="--keep_multi_map  " false="" keep_multi_map}	~{"--bwa_min_score " + bwa_min_score}	~{true="--save_align_intermeds  " false="" save_align_intermeds}	~{"--bamtools_filter_pe_config '" + bamtools_filter_pe_config + "'"}	~{"--bamtools_filter_se_config '" + bamtools_filter_se_config + "'"}	~{true="--narrow_peak  " false="" narrow_peak}	~{"--broad_cutoff " + broad_cutoff}	~{"--macs_fdr " + macs_fdr}	~{"--macs_pvalue " + macs_pvalue}	~{"--min_reps_consensus " + min_reps_consensus}	~{true="--save_macs_pileup  " false="" save_macs_pileup}	~{true="--skip_peak_qc  " false="" skip_peak_qc}	~{true="--skip_peak_annotation  " false="" skip_peak_annotation}	~{true="--skip_consensus_peaks  " false="" skip_consensus_peaks}	~{true="--deseq2_vst  " false="" deseq2_vst}	~{true="--skip_diff_analysis  " false="" skip_diff_analysis}	~{true="--skip_fastqc  " false="" skip_fastqc}	~{true="--skip_picard_metrics  " false="" skip_picard_metrics}	~{true="--skip_preseq  " false="" skip_preseq}	~{true="--skip_plot_profile  " false="" skip_plot_profile}	~{true="--skip_plot_fingerprint  " false="" skip_plot_fingerprint}	~{true="--skip_spp  " false="" skip_spp}	~{true="--skip_igv  " false="" skip_igv}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{"--custom_config_version '" + custom_config_version + "'"}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--hostnames '" + hostnames + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{true="--help  " false="" help}	~{"--fingerprint_bins " + fingerprint_bins}	~{"--publish_dir_mode '" + publish_dir_mode + "'"}	~{"--name '" + name + "'"}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{"--clusterOptions '" + clusterOptions + "'"}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-chipseq:1.2.2_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    