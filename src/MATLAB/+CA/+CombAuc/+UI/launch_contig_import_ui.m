function [lmTheory,tsCA] = launch_contig_import_ui(tsCA, lmConsensus)
    % launch_consensus_import_ui -
    %   adds a tab with list management UI/functionality  for
    %    kymographs
    
    [selectedItems, selectedIndices] = get_selected_list_items(lmConsensus);
    %selectedItems

    % title
    tabTitle = 'Contig import';

    % create a tab for importing consensus
    hTabConsensusImport = tsCA.create_tab(tabTitle);
    hPanelConsensusImport = uipanel(hTabConsensusImport);
    tsCA.select_tab(hTabConsensusImport);

    
    import Fancy.UI.FancyList.FancyListMgr;
    lmTheory = FancyListMgr();
    lmTheory.set_ui_parent(hPanelConsensusImport);
    lmTheory.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_sequences(tsCA));
    flmbs1.add_button(make_remove_sequences());
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;


    flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());
   
    
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(compute_contig_barcodes(tsCA,lmConsensus));

    
%     flmbs4 = FancyListMgrBtnSet();
%     flmbs4.NUM_BUTTON_COLS = 1;
%     
%     flmbs4.add_button(compare_experimental_barcodes_to_theory(tsCA));

    lmTheory.add_button_sets(flmbs1,flmbs2,flmbs3);

    % add barcodes
    function [btnAddKymos] =make_add_sequences(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Add contig(s)', ...
            @(~, ~, lmTheory) on_add_consensus_directly(lmTheory, ts));
        
        
        function [] = on_add_consensus_directly(lmTheory, ts)
            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.fasta;'}, ...
                'Select contig(s) to import', ...
                pwd, ...
                'MultiSelect','on');
        
            FASTAData = fastaread(strcat(barcodeFilenamesDirpath,barcodeFilenames));
            
            numFiles = size(FASTAData,1);

            theoreticalSequence = cell(1,size(FASTAData,1));
            nameSequence = cell(1,size(FASTAData,1));
            for i=1:numFiles
                theoreticalSequence{i} =  FASTAData(i).Sequence;
                nameSequence{i} = FASTAData(i).Header;
            end


            lmTheory.add_list_items(nameSequence, theoreticalSequence);
        end
    end
   


    function [btnAddKymos] = compute_contig_barcodes(ts,lmConsensus)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Compute contig barcodes', ...
            @(~, ~, lm) compute_directly(lmTheory, ts));
        

 		function [] = compute_directly(lmTheory, ts)
            %[selectedItems, selectedIndices] = get_selected_list_items(lmTheory);
            
            import CA.UI.contig_barcodes_ui;
            [lmTheory,tsCA] = contig_barcodes_ui(ts,lmTheory,lmConsensus);
            
%             sequences = {};
%             for i=1:size(selectedItems,1)
%                 seq = selectedItems(i,2);
%                 sequences{i} = seq{1};
%             end
%           
%             %             [txtFilenames, txtFilenamesDirpath] = uigetfile(...
% %                 {'*.ini;'}, ...
% %                 'Select settings file for contig barcode generation', ...
% %                 pwd, ...
% %                 'MultiSelect','off');
%             
% 
%             import CA.Core.Settings.settings;
%             sets = settings(); % 
% 
% 
%             import CA.Core.Comparison.gen_contig_barcodes;
%             contigBarcodes  = gen_contig_barcodes(sequences,sets);
%             
%                 % title
%             tabTitle = 'Contig barcodes';
% 
%             % create a tab for importing consensus
%             [hTabConsensusImport2, tabNumConsensusImport2] = tsCA.create_tab(tabTitle);
%             hPanelConsensusImport2 = uipanel(hTabConsensusImport2);
%             tsCA.select_tab(tabNumConsensusImport2);
% 
%     
%             import Fancy.UI.FancyList.FancyListMgr;
%             lmB = FancyListMgr();
%             lmB.set_ui_parent(hPanelConsensusImport2);
%             lmB.make_ui_items_listbox();
%             
%             nameB = {};
%             for i=1:length(contigBarcodes)
%                 nameB{i} = contigBarcodes{i}.name;
%             end
%             lmB.add_list_items(nameB,contigBarcodes);

        end

    end

    function [btnAddKymos] =compare_experimental_barcodes_to_theory(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Place contigs on the consensus barcode', ...
            @(~, ~, lm) on_add_barcodes_directly(lm, ts));
        

 		function [] = on_add_barcodes_directly(lm, ts)
            [selectedItems, selectedIndices] = get_selected_list_items(lm);
            
%             
%             import CA.UI.launch_contig_import_ui;
%             lm = launch_consensus_import_ui(tsCA);
%     
%                 import MMT.GUI.launch_theory_ui;
% %             lm = launch_theory_ui(tsCBC,selectedItems);
        end

    end

    function [btnRemoveConsensus] = make_remove_sequences()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected barcode(s)', ...
            @(~, ~, lm) on_remove_selected_consensus(lm));
        function [] = on_remove_selected_consensus(lm)
            lm.remove_selected_items();
        end
    end

end