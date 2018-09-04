function [] = add_consensus_btns_to_kymo_list_mgr(lm, ts, cache)
    if nargin < 3
        cache = containers.Map();
    end

    import FancyGUI.FancyList.FancyListMgrBtnSet;
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(make_ensure_alignment_for_selected_kymos_btn());
    flmbs2.add_button(make_generate_barcodes_for_selected_kymos_btn());
    flmbs2.add_button(make_consensus_btn(ts));

    lm.add_button_sets(flmbs2);

    function [btnEnsureAlignment] = make_ensure_alignment_for_selected_kymos_btn()
        import FancyGUI.FancyList.FancyListMgrBtn;
        import CBT.Consensus.Import.Helper.ensure_alignment_for_selected_kymos;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Ensure Alignment of Selected Kymographs', ...
            @(~, ~, lm) ensure_alignment_for_selected_kymos(lm));
    end

    function [btnEnsureAlignment] = make_generate_barcodes_for_selected_kymos_btn()
        import FancyGUI.FancyList.FancyListMgrBtn;
        import CBT.Consensus.Import.Helper.generate_barcodes_for_selected_kymos;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Generate Barcodes from Selected Kymographs', ...
            @(~, ~, lm) generate_barcodes_for_selected_kymos(lm));
    end

    function [btnGenerateConsensus] = make_consensus_btn(ts)
        function on_make_consensus(lm, ts)
            import CBT.Consensus.UI.Helper.generate_consensus_for_selected;
            [consensusStruct, cache] = generate_consensus_for_selected(lm, cache);
            
            import CBT.Consensus.Import.load_consensus_results;
            load_consensus_results(ts, consensusStruct);
        end

        import FancyGUI.FancyList.FancyListMgrBtn;
        btnGenerateConsensus = FancyListMgrBtn(...
            'Generate Consensus from Selected Kymographs', ...
            @(~, ~, lm) on_make_consensus(lm, ts));
    end
end