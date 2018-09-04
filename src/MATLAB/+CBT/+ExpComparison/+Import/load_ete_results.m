function [] = load_ete_results( tsETE, eteSessionStruct )
   if nargin < 2
        import CBT.ExpComparison.Import.load_ete_struct;
        eteSessionStruct = load_ete_struct();
        if isempty(eteSessionStruct)
            return;
        end
    end
    if isempty(eteSessionStruct)
        return;
    end



    assignin('base', 'eteSessionStruct', eteSessionStruct);

    
%     import CBT.ExpComparison.UI.generate_ete_ui_bitmasked;
%     generate_ete_ui_bitmasked(tsETE, eteSessionStruct);
%     
    import CBT.ExpComparison.UI.generate_ete_ui;
    generate_ete_ui(tsETE, eteSessionStruct);
    
    fprintf('Finished running saved session result display \n');


end

