% Run genome pipeline.
% use settings from DBMnew.ini
userDir = '/proj/snic2022-5-384/users/x_albdv/data/bargrouping/ecoli/ecoli_2_new/1219/';

import DBM4.GenomAs.run_genome_assembly_pipeline;
[barcodeGen,barGenMerged,kymoStructs] = run_genome_assembly_pipeline(userDir);