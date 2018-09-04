function [ probVec, probNums ] = get_binding_probs( seqq,shortestSeq,concYOYO1_molar,YOYO1conc )
 %30/11/16

%seqq = IMPORT.read_fasta('plasmid.1.1.genomic.fna');
set = {};
probNums = [];

for i=1:size(seqq,2)
    
    if size(seqq{i},2)> shortestSeq 
        set = [set seqq{i}];
        probNums = [probNums i];
    end
end

%xx = CBT.gen_zscaled_cbt_barcodes(set{1},settings);

% compute binding probs

nNum = size(set,2);

%nNum = size(seqq,2);

probVec = cell(1,nNum);

import CA.CombAuc.Core.Cbt.cb_transfer_matrix2; % this should be changable via settings to whichever method we want to use.

for j=1:nNum
   j
   hSet = cb_transfer_matrix2(set{j} );
   %hSet = Cbt.cb_transfer_matrix_editable(set{j});

   %hSet = CBT.cb_netropsin_vs_yoyo1_plasmid(set{j},concYOYO1_molar,YOYO1conc,1000,true);
   probVec{j} = hSet;
end

end

