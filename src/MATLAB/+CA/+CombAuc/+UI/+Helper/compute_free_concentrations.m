function [sets] = compute_free_concentrations( sets, model )
    %compute_free_concentrations
    
    % input 
    % sets, model
    
    % output
    % sets
    
    
    YOYO1conc = sets.defaultBarcodeGenSettings.concYOYO1_molar;
    NETROPSINconc = sets.defaultBarcodeGenSettings.concNetropsin_molar;
    concDNA = sets.defaultBarcodeGenSettings.concDNA;
    K = sets.defaultBarcodeGenSettings.yoyo;
    
    lambdaSeq = uigetdir(pwd,'lambda sequence');
    addpath(genpath(lambdaSeq));
    listing = dir(lambdaSeq);
    lambdaSequence = fastaread(listing(3).name);
    
    x0 = [YOYO1conc NETROPSINconc];

    % make them bot with the same function..
    if isequal(model.name,'literature')
        probsBinding1 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature(lambdaSequence, x(2),x(1),K,model.netropsinBindingConstant, 1000);
        probsBinding2 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature_netropsin(lambdaSequence, x(2),x(1),K,model.netropsinBindingConstant, 1000);
    else
        oMat = diag([0,0,0,0,0,1,1,1,1]);
        probsBinding1 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_editable(lambdaSequence, x(2),x(1),K,model.netropsinBindingConstant, 1000,oMat);
         oMat = diag([0,1,1,1,1,0,0,0,0]);
        probsBinding2 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_editable(lambdaSequence, x(2),x(1),K,model.netropsinBindingConstant, 1000,oMat);
     
    end
    
    fun = @(x) x0-x-[mean(probsBinding1(x)) mean(probsBinding2(x))]*concDNA*0.25;


    fun2 = @(x) sum(fun(x).^2);

    [xNew] = fminsearch(fun2,x0);
    
    % free concentrations
    sets.defaultBarcodeGenSettings.concNetropsin_molar =xNew(2);
    sets.defaultBarcodeGenSettings.concYOYO1_molar = xNew(1);
end

