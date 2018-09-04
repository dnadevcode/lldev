function [ cache ] = on_run_similarity_analysis(lm,ts,cache )
     if nargin < 3
        cache = containers.Map();
     end
    

    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(run_comparison(ts));

    lm.add_button_sets(flmbs3);
    
    function [btnGenerateConsensus] = run_comparison(ts)
        
        function on_run_comparison(lm, ts)
               % selected items
            [selectedItems, ~] = get_selected_list_items(lm);

            % put the selected items in a structure
            consensusBitmasks = cell(1,size(selectedItems,1));
            consensusBarcodes =  cell(1,size(selectedItems,1));
            consensusBarcodeNames =  cell(1,size(selectedItems,1));

            for it=1:size(selectedItems,1)   
                barStr = selectedItems{it,2};
                consensusBitmasks{it} = barStr.stretchedConsensusBitmasks;
                consensusBarcodes{it} = barStr.stretchedConsensusBarcodes;
                consensusBarcodeNames{it} =  selectedItems{it,1};
            end
            
            [FileName,PathName] = uigetfile('*.mat','Select the theory file');
            ss = load(strcat([PathName FileName]));
            barcodePxRes = ss.mmtSessionStruct.theoryBarcodes{1};
            sets=ss.sets;
            mmtSessionStruct = ss.mmtSessionStruct;
            bitmask = mmtSessionStruct.bitmask{1};
            % convert the experiment to the same length as theory
            import CBT.Consensus.Core.convert_barcodes_to_common_length;
            [barcodes] = convert_barcodes_to_common_length(consensusBarcodes, length(barcodePxRes));
            import CBT.Consensus.Core.convert_bitmasks_to_common_length;
            [bitmasks] = convert_bitmasks_to_common_length(consensusBitmasks, length(barcodePxRes));
         
            % should run a similar analysis here to ETE, contig..
            stretchFactors = cellfun(@length,consensusBarcodes)/length(barcodePxRes);

            bsosStruct = cell(1,length(barcodes));
            figure
            for i=1:length(barcodes)
                import CBT.Consensus.Core.calc_best_synced_orientation_similarity;
                bsosStruct{i} = calc_best_synced_orientation_similarity(barcodes{i}, barcodePxRes, bitmasks{i},bitmask);
                
                subplot(round(length(barcodes)/2),round(length(barcodes)/2)+1,i)
                import MMT.UI.add_plot_tab;
                add_plot_tab(barcodes{i},barcodePxRes,bsosStruct{i},sets) 

            end
 

%             mmtSessionStruct = struct();
      %      mmtSessionStruct.resultStruct =bsosStruct
%             mmtSessionStruct.stats = bsosStruct;
%             mmtSessionStruct.original = bar;
%             mmtSessionStruct.barcode = barcodes{1};
%             mmtSessionStruct.theoryBarcode = barcodePxRes;
%             mmtSessionStruct.stretchFactor = length(bar)/length(barcodePxRes);
%             mmtSessionStruct.timestamp = datetime;
%             mmtSessionStruct.settings = sets;
         
      
     
%             import MMT.UI.launch_export_ui;
%             launch_export_ui(ts, {'Melting map session files'}, mmtSessionStruct)

            end  
        
       import Fancy.UI.FancyList.FancyListMgrBtn;
        btnGenerateConsensus = FancyListMgrBtn(...
            'Run MMT comparison on selected barcodes', ...
            @(~, ~, lm) on_run_comparison(lm, ts));
    end
end

