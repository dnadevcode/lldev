function [lm,cache] = compute_theory_ui(lm,ts,cache)
  % compute theory UI
    if nargin < 3   % but no reason this should be the case
        cache = containers.Map();
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet; 
    flmbs5 = FancyListMgrBtnSet();

    flmbs5.NUM_BUTTON_COLS = 1;

    flmbs5.add_button(select_theory(ts));

     function [btnAddKymos] =select_theory(ts)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            btnAddKymos = FancyListMgrBtn(...
                'Compute theory barcodes for sequences', ...
                @(~, ~, lm) on_select_theory(lm, ts));


            function [] = on_select_theory(lm, ts)
                [selectedItems, ~] = get_selected_list_items(lm);

                % load settings
                sets = cache('sets');
                if ~sets.skipBarcodeGenSettings
                    import CBT.Hca.UI.comparison_settings;
                    sets.barcodeGenSettings = comparison_settings(); %
                end

                if sets.barcodeGenSettings.computeFreeConcentrations
                    tic
                    disp('Computing free concentrations');
                    seq = fastaread('sequence.fasta'); % ref sequence - lambda;
                    rs = seq.Sequence;
                    % put this in a function
                    import CBT.BC.Core.choose_model;
                    model = choose_model(sets.barcodeGenSettings.model);
                    probsBinding1 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature(rs, x(2),x(1),model.yoyo1BindingConstant,model.netropsinBindingConstant, 1000);
                    probsBinding2 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature_netropsin(rs, x(2),x(1),model.yoyo1BindingConstant,model.netropsinBindingConstant, 1000);
                    %probsBinding3 = @(x) CA.CombAuc.Core.Cbt.cb_transfer_matrix_none(rs, x(2),x(1),model.yoyo1BindingConstant,model.netropsinBindingConstant, 1000);

                    x0 = [sets.barcodeGenSettings.concYOYO1_molar sets.barcodeGenSettings.concNetropsin_molar];

                    fun = @(x) x0-x-[mean(probsBinding1(x)) mean(probsBinding2(x))]*sets.barcodeGenSettings.concDNA*0.25;

                    % we minimise the sum square
                    fun2 = @(x) sum(fun(x).^2);

                    % using fminsearch
                    [xNew] = fminsearch(fun2,x0);

    %                 fun3 = @(x) x-[mean(probsBinding1(x)) mean(probsBinding2(x))]*sets.barcodeGenSettings.concDNA*0.25;
    %                 fun3(x0) % if one of the values is negative, it means that not all can bind - therefore we might 
                    % need to reduce the concentration of yoyo, netropsin, or
                    % both.
                    sets.barcodeGenSettings.concYOYO1_molar = xNew(1);
                    sets.barcodeGenSettings.concNetropsin_molar = xNew(2);
                    toc
                    disp('Finished computing free concentrations');

                end

    %             if ~iscell(selectedItems)
    %                 selectedItems = {selectedItems};
    %                 sequencePath = {sequencePath};
    %             end

                for i=1:size(selectedItems,1)
                    FASTAData = fastaread(selectedItems{i,2});
                    seq = FASTAData(1).Sequence;
                    name = FASTAData(1).Header;

                    import CBT.Hca.Core.compute_hca_theory_barcode;
                    [theorySeq,bitmask] = compute_hca_theory_barcode(seq,sets.barcodeGenSettings);
                    theoryGen.theoryBarcodes{i} = theorySeq;
                    theoryGen.theoryNames{i} = name;
                    theoryGen.bitmask{i} = bitmask;
                    theoryGen.bpNm{i} = sets.barcodeGenSettings.meanBpExt_nm/sets.barcodeGenSettings.psfSigmaWidth_nm;

                 end
                    theoryGen.sets = sets.barcodeGenSettings;

                    hcaSessionStruct = cache('hcaSessionStruct');
                    hcaSessionStruct.theoryGen = theoryGen;
                    cache('hcaSessionStruct') = hcaSessionStruct;
                    cache('sets') = sets;
                end
     end
     lm.add_button_sets(flmbs5);
end
