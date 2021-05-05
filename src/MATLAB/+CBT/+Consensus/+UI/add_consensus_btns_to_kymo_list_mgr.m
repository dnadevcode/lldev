function [] = add_consensus_btns_to_kymo_list_mgr(lm, ts, cache)
    if nargin < 3
        cache = containers.Map();
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(make_ensure_alignment_for_selected_kymos_btn(ts));
    flmbs2.add_button(make_generate_barcodes_for_selected_kymos_btn());
    flmbs2.add_button(make_consensus_btn(ts));
%     flmbs2.add_button(make_consensus_btn(ts));

    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 2;
    flmbs3.add_button(make_on_plot_kymos_btn(ts));
    flmbs3.add_button(make_on_plot_alignment_for_selected_kymos_btn(ts));
    
    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 2;
  
    flmbs4.add_button(make_on_plot_bars_kymos(ts));

    flmbs4.add_button(make_on_plot_barcodes(ts));


    flmbs5 = FancyListMgrBtnSet();
    flmbs5.NUM_BUTTON_COLS = 1;
  
    flmbs5.add_button(make_on_close_and_clear(ts));

%     flmbs2.add_button(make_on_plot_alignment_for_selected_kymos_btn()); % plot aligned kymos

%     flmbs2.add_button(get_unaligned_kymos_tab(ts));


    lm.add_button_sets(flmbs2,flmbs3,flmbs4,flmbs5);

    function [hTabSelectedAlignedKymos] = get_aligned_selected_kymos_tab(ts)
        persistent localhTabSelectedAlignedKymos;
        if isempty(localhTabSelectedAlignedKymos) || not(isvalid(localhTabSelectedAlignedKymos))
            hTabSelectedAlignedKymos = ts.create_tab('Selected Aligned Kymos');
            localhTabSelectedAlignedKymos = hTabSelectedAlignedKymos;
        else
            hTabSelectedAlignedKymos = localhTabSelectedAlignedKymos;
        end
    end


    function [hTabSelectedunAlignedKymos] = get_unaligned_selected_kymos_tab(ts)
        persistent localhTabSelectedunAlignedKymos;
        if isempty(localhTabSelectedunAlignedKymos) || not(isvalid(localhTabSelectedunAlignedKymos))
            hTabSelectedunAlignedKymos = ts.create_tab('Selected Unaligned Kymos');
            localhTabSelectedunAlignedKymos = hTabSelectedunAlignedKymos;
        else
            hTabSelectedunAlignedKymos = localhTabSelectedunAlignedKymos;
        end
    end


    function [hTabSelectedBarcodes] = get_barcodes_tab(ts)
        persistent localhTabSelectedBarcodes;
        if isempty(localhTabSelectedBarcodes) || not(isvalid(localhTabSelectedBarcodes))
            hTabSelectedBarcodes = ts.create_tab('Selected Barcodes');
            localhTabSelectedBarcodes = hTabSelectedBarcodes;
        else
            hTabSelectedBarcodes = localhTabSelectedBarcodes;
        end
    end


    function [hTabSelectedBarcodes] = get_barcodekym_tab(ts)
        persistent localhTabSelectedBarcodes;
        if isempty(localhTabSelectedBarcodes) || not(isvalid(localhTabSelectedBarcodes))
            hTabSelectedBarcodes = ts.create_tab('Selected kymos with edge');
            localhTabSelectedBarcodes = hTabSelectedBarcodes;
        else
            hTabSelectedBarcodes = localhTabSelectedBarcodes;
        end
    end



    function [lm] = on_ensure_alignment_for_selected_kymos(lm, ts)
        import CBT.Consensus.Import.Helper.ensure_alignment_for_selected_kymos;
        [lm, kymoNames, alignedKymos] = ensure_alignment_for_selected_kymos(lm);
        
    end


    function [btnEnsureAlignment] = make_ensure_alignment_for_selected_kymos_btn(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Ensure Alignment of Selected Kymographs', ...
            @(~, ~, lm) on_ensure_alignment_for_selected_kymos(lm, ts));
    end

    function [btnEnsureAlignment] = make_generate_barcodes_for_selected_kymos_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        import CBT.Consensus.Import.Helper.generate_barcodes_for_selected_kymos;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Generate Barcodes from Selected Kymographs', ...
            @(~, ~, lm) generate_barcodes_for_selected_kymos(lm));
    end


    function [btOut] = make_on_plot_kymos_btn(ts)
        % plots aligned kymographs
        function on_plot_selected_kymos(lm, ts)
            
            selectedIndices = lm.get_selected_indices();
            trueValueList = lm.get_true_value_list();
            
            numSelected = length(selectedIndices);

            kymoStruct = cell(1,numSelected);
            for i=1:numSelected
                kymoStruct{i} = trueValueList{selectedIndices(i)};
            end
                
            kymoNames = lm.get_diplay_names(selectedIndices);
            unalignedKymos = cellfun(@(x) x.unalignedKymo,kymoStruct,'un',false);
            hTabSelectedunAlignedKymos = get_unaligned_selected_kymos_tab(ts);
            hPanelunAlignedKymos = uipanel('Parent', hTabSelectedunAlignedKymos);
            delete(allchild(hPanelunAlignedKymos));
            import OldDBM.Kymo.UI.show_kymos_in_grid;
            show_kymos_in_grid(hPanelunAlignedKymos, unalignedKymos, kymoNames);
        end
        
            
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btOut = FancyListMgrBtn(...
            'Plot unaligned kymographs', ...
            @(~, ~, lm) on_plot_selected_kymos(lm, ts));
    end

    function [btOut] = make_on_plot_alignment_for_selected_kymos_btn(ts)
        % plots aligned kymographs
        function on_plot_alignment_for_selected_kymos(lm, ts)
            
            selectedIndices = lm.get_selected_indices();
            trueValueList = lm.get_true_value_list();
            
            numSelected = length(selectedIndices);

            kymoStruct = cell(1,numSelected);
            for i=1:numSelected
                kymoStruct{i} = trueValueList{selectedIndices(i)};
            end
                
            kymoNames = lm.get_diplay_names(selectedIndices);
            alignedKymos = cellfun(@(x) x.alignedKymo,kymoStruct,'un',false);
            hTabSelectedAlignedKymos = get_aligned_selected_kymos_tab(ts);
            hPanelAlignedKymos = uipanel('Parent', hTabSelectedAlignedKymos);
            delete(allchild(hPanelAlignedKymos));
            import OldDBM.Kymo.UI.show_kymos_in_grid;
            show_kymos_in_grid(hPanelAlignedKymos, alignedKymos, kymoNames);
        end
        
            
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btOut = FancyListMgrBtn(...
            'Plot aligned kymographs', ...
            @(~, ~, lm) on_plot_alignment_for_selected_kymos(lm, ts));
    end



   function [btOut] = make_on_plot_bars_kymos(ts)
        % plots aligned kymographs
        function on_plot_selected_kymos(lm, ts)
            
            selectedIndices = lm.get_selected_indices();
            trueValueList = lm.get_true_value_list();
            
            numSelected = length(selectedIndices);

            kymoStruct = cell(1,numSelected);
            for i=1:numSelected
                kymoStruct{i} = trueValueList{selectedIndices(i)};
            end
                
            kymoNames = lm.get_diplay_names(selectedIndices);
            barcodeGen = cellfun(@(x) x.barcodeGen,kymoStruct,'un',false);
            
            rawBarcodes = cellfun(@(x) x.rawBarcode,barcodeGen,'un',false);

            lE = cellfun(@(x) x.leftEdgeIdxs,barcodeGen,'un',false);
            rE = cellfun(@(x) x.rightEdgeIdxs,barcodeGen,'un',false);
            alignedKymo = cellfun(@(x) x.alignedKymo,kymoStruct,'un',false);


            % plot barcodes in grid
            hTabSelectedBarcodes = get_barcodekym_tab(ts);
            hPanelBarcodes = uipanel('Parent', hTabSelectedBarcodes);
            delete(allchild(hPanelBarcodes));
            import OldDBM.Kymo.UI.show_kymobars_in_grid;
            show_kymobars_in_grid(hPanelBarcodes, alignedKymo,lE,rE, kymoNames);
        end
        
            
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btOut = FancyListMgrBtn(...
            'Plot kymos with edges', ...
            @(~, ~, lm) on_plot_selected_kymos(lm, ts));
   end



   function [btOut] = make_on_plot_barcodes(ts)
        % plots aligned kymographs
        function on_plot_selected_kymos(lm, ts)
            
            selectedIndices = lm.get_selected_indices();
            trueValueList = lm.get_true_value_list();
            
            numSelected = length(selectedIndices);

            kymoStruct = cell(1,numSelected);
            for i=1:numSelected
                kymoStruct{i} = trueValueList{selectedIndices(i)};
            end
                
            kymoNames = lm.get_diplay_names(selectedIndices);
            barcodeGen = cellfun(@(x) x.barcodeGen,kymoStruct,'un',false);
            
            rawBarcodes = cellfun(@(x) x.rawBarcode,barcodeGen,'un',false);
            % plot barcodes in grid
            hTabSelectedBarcodes = get_barcodes_tab(ts);
            hPanelBarcodes = uipanel('Parent', hTabSelectedBarcodes);
            delete(allchild(hPanelBarcodes));
            import OldDBM.Kymo.UI.show_bars_in_grid;
            show_bars_in_grid(hPanelBarcodes, rawBarcodes, kymoNames);
        end
        
            
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btOut = FancyListMgrBtn(...
            'Plot barcodes', ...
            @(~, ~, lm) on_plot_selected_kymos(lm, ts));
    end

    function [btnGenerateConsensus] = make_consensus_btn(ts)
        function on_make_consensus(lm, ts)
            
%             % should be faster method computing the same CBC
%             import CBT.Consensus.UI.Helper.generate_consensus_for_selected_hca;
%             [consensusStruct, cache] = generate_consensus_for_selected_hca(lm, cache);
 
            import CBT.Consensus.UI.Helper.generate_consensus_for_selected;
            [consensusStruct, cache] = generate_consensus_for_selected(lm, cache);
            
            if ~iscell(consensusStruct)
                consensusStruct ={consensusStruct};
            end
            
            for i=1:length(consensusStruct)
                if ~isempty(consensusStruct{i}.barsInClusters) 
                    if i >= 2
                        hPanel =figure;
                        import Fancy.UI.FancyTabs.TabbedScreen;
                        ts = TabbedScreen(hPanel);
                    end
                    import CBT.Consensus.Import.load_consensus_results;
                    load_consensus_results(ts, consensusStruct{i});
                end
            end

%             import CBT.Consensus.Import.load_consensus_results;
%             load_consensus_results(ts, consensusStruct);
        end

        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnGenerateConsensus = FancyListMgrBtn(...
            'Generate Consensus from Selected Kymographs', ...
            @(~, ~, lm) on_make_consensus(lm, ts));
    end


    % close any open tabs and clear generated data
   function [btOut] = make_on_close_and_clear(ts)
        % plots aligned kymographs
        function on_clear_data(lm, ts)
            
            selectedIndices = lm.get_all_indices();
            allItemsPairs = lm.get_all_list_items;
            allItems = allItemsPairs(:,2);
            
            for i=1:length(allItems)
                fields = {'alignedKymo','barcodeGen'};
                if ~isfield(allItems{i},'alignedKymo')
                    fields{1} = [];
                end
                if ~isfield(allItems{i},'barcodeGen')
                    fields{2} = [];
                end

                allItems{i} = rmfield(allItems{i},fields);
            end
%                 if isfield(allItems{i},'alignedKymo')
%                     rmield(allItems{1},'alignedKymo')
                    
%             items = allItems{:,2};
            lm.update_list_items( lm.get_diplay_names(fliplr(selectedIndices)), allItems);

            % remove: aligned kymographs, barcodeGen, 
            
%             
%             numSelected = length(selectedIndices);
% 
%             kymoStruct = cell(1,numSelected);
%             for i=1:numSelected
%                 kymoStruct{i} = trueValueList{selectedIndices(i)};
%             end
%                 
%             kymoNames = lm.get_diplay_names(selectedIndices);
%             barcodeGen = cellfun(@(x) x.barcodeGen,kymoStruct,'un',false);
%             
%             rawBarcodes = cellfun(@(x) x.rawBarcode,barcodeGen,'un',false);
%             % plot barcodes in grid
%             hTabSelectedBarcodes = get_barcodekym_tab(ts);
%             hPanelBarcodes = uipanel('Parent', hTabSelectedBarcodes);
%             delete(allchild(hPanelBarcodes));
%             import OldDBM.Kymo.UI.show_bars_in_grid;
%             show_bars_in_grid(hPanelBarcodes, rawBarcodes, kymoNames);
        end
        
            
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btOut = FancyListMgrBtn(...
            'Clear data', ...
            @(~, ~, lm) on_clear_data(lm, ts));
   end


end