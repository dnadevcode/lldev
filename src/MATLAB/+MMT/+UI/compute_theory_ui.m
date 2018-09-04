function [lm,cache] = compute_theory_ui(lm,ts,cache)
    if nargin < 3
        cache = containers.Map();
        cache('mmtSessionStruct') = struct();
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
            mmtSessionStruct = cache('mmtSessionStruct');

            % select barcode generation settings
            import MMT.Core.Settings.settings;
            sets = settings(); % 
             for i=1:size(selectedItems,1)
                FASTAData = fastaread(selectedItems{i,2});
                seq = FASTAData(1).Sequence;
                name = FASTAData(1).Header;
                 
                import MMT.Core.create_ps_barcode;
                [theorySeq,bitmask] = create_ps_barcode(seq,sets);
               
                mmtSessionStruct.theoryBarcodes{i} = theorySeq;
                mmtSessionStruct.theoryNames{i} = name;
                mmtSessionStruct.bitmask{i} = bitmask;
             end
    
             time =datestr(datetime);
             str  = strcat(['mmtTheory ' time '.mat']);
            [file,path] = uiputfile(str,'Save Theory Barcode as'); 
            
            save(strcat([path,file]),'mmtSessionStruct','sets','-v7.3');
            cache('mmtSessionStruct') = mmtSessionStruct;
            cache('sets') = sets;
            assignin('base','mmtSessionStruct',mmtSessionStruct)
            assignin('base','sets',sets)

        end
    end
    lm.add_button_sets(flmbs5);
end