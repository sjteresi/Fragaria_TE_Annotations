# scripts for running rice synteny TE Density examples
# __file__ Makefile
# __author__ Scott Teresi

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DEV_GFF_READ_EXECUTABLE := /home/scott/Documents/Uni/Research/gffread
# DEV_GFF_READ_EXECUTABLE := /mnt/research/edgerpat_lab/Scotty/gffread  # HPCC path
# NB I have had trouble running the GFFRead step on the HPCC so I am just going with local machine
DEV_DATA := $(realpath $(ROOT_DIR)/data)

.PHONY: create_CDS fix_fasta_names fix_CDS_names

sync_to_local:
	@echo
	@echo Syncing remote data and result files TO local
	bash $(ROOT_DIR)/src/sync_remote_to_local.sh

sync_to_remote:
	@echo
	@echo Syncing local data and result files TO remote
	bash $(ROOT_DIR)/src/sync_local_to_remote.sh



# The following commands should be run in the order they are written
# if you want to recreate the analysis
create_CDS:
	@echo
	@echo Creating CDS from GFF and fasta file for 502
	$(DEV_GFF_READ_EXECUTABLE)/gffread -x $(DEV_DATA)/Fragaria_502_CDS.fasta -g $(DEV_DATA)/502.ragtag.scaffolds.renamed.fasta $(DEV_DATA)/maker_annotation.502.gff_sorted.gff
	@echo
	@echo Creating CDS from GFF and fasta file for sativa
	$(DEV_GFF_READ_EXECUTABLE)/gffread -x $(DEV_DATA)/Fragaria_562.fasta -g $(DEV_DATA)/562.ragtag.scaffolds.renamed.fasta $(DEV_DATA)/maker_annotation.562.gff_sorted.gff


fix_fasta_names:
	@echo
	@echo Fixing the fasta names for 502 so that they are not too long for EDTA
	python $(ROOT_DIR)/src/fix_fasta_names.py $(DEV_DATA)/502.ragtag.scaffolds.renamed.fasta 502
	@echo Fixing the fasta names for 562 so that they are not too long for EDTA
	python $(ROOT_DIR)/src/fix_fasta_names.py $(DEV_DATA)/562.ragtag.scaffolds.renamed.fasta 562
	@echo

fix_CDS_names:
	@echo
	@echo Fixing the CDS fasta names for 502 so that they are not too long for EDTA
	python $(ROOT_DIR)/src/fix_cds_names.py $(ROOT_DIR)/results/502_NewNames.fasta 502
	@echo Fixing the CDS fasta names for 562 so that they are not too long for EDTA
	python $(ROOT_DIR)/src/fix_cds_names.py $(ROOT_DIR)/results/562_NewNames.fasta 562
	@echo

run_EDTA_HPCC:
	@echo Running EDTA for 502
	sbatch $(ROOT_DIR)/src/Annotate_Fragaria_502.sb
	@echo Running EDTA for 562
	sbatch $(ROOT_DIR)/src/Annotate_Fragaria_562.sb

