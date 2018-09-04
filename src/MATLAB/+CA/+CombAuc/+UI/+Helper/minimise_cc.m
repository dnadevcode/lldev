function [ value,xx ,valueV,xxV,mol2] = minimise_cc( kk,K,mol2,sets,model,seq,xNewMat )

    NETROPSINconc = sets.defaultBarcodeGenSettings.concNetropsin_molar;
    YOYO1conc = sets.defaultBarcodeGenSettings.concYOYO1_molar;
    concDNA = sets.defaultBarcodeGenSettings.concDNA;
    F = 400;

    if nargin <7


        % % first recompute free concentrations
        [~, xNew,~ ] = titration_function_full(seq,kk*K, F,YOYO1conc,NETROPSINconc,concDNA,model );


        NETROPSINconc =xNew(2);
        YOYO1conc = xNew(1);
    else
        NETROPSINconc =xNewMat(kk,2);
        YOYO1conc = xNewMat(kk,1);
    end

    for i=1:length(mol2)        
      %  K = 100;
        [prob] = without_titration_function_full(mol2{i}.sequence,kk*K, F,YOYO1conc,NETROPSINconc,concDNA,model );
        import CA.CombAuc.Core.Cbt.compute_theory_barcode;
        sets.meanBpExt_nm = mol2{i}.meanBpExt_nm;
        [mol2{i}.theorySeq,mol2{i}.bitmask] = compute_theory_barcode(prob,sets);      
    end
 
for i=1:length(mol2)
    sets.meanBpExt_nm = mol2{i}.meanBpExt_nm;
    import CA.CombAuc.UI.compare_theory_to_exp;
    mol2{i} = compare_theory_to_exp(mol2{i},sets);
end

mm = cell2mat(cellfun(@(x) x.comparisonStructure{end}.maxcoef(1),mol2,'UniformOutput',false));
value = mean(mm(1:end));
valueV = mm;

xx = [];
for i=1:length(mol2)
	xx =[xx mean(cell2mat(cellfun(@(x) x.maxcoef(1),mol2{i}.comparisonStructure,'UniformOutput',false)) )];
end
xxV = xx;
xx = mean(xx);


end

