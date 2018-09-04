function [] = add_mmt_ui(hMenuParent, tsMM)
	%cache = containers.Map();
%     mmtSessionStruct = struct();
%     cache('mmtSessionStruct') = mmtSessionStruct;

    hMenuMeltingMap = uimenu(hMenuParent, 'Label', 'Melting Maps');
  
    % run MMT generation
    import MMT.UI.run_mmt;
    uimenu(hMenuMeltingMap, ...
        'Label', 'Run MMT generation', ...
        'Callback', @(~, ~) run_mmt(tsMM));
  
    import MMT.UI.run_mmt_comparison;
    uimenu(hMenuMeltingMap, ...
        'Label', 'Run MMT comparison basic', ...
        'Callback', @(~, ~) run_mmt_comparison(tsMM));
    
    
    import MMT.UI.run_mmt_comparison_full;
    uimenu(hMenuMeltingMap, ...
        'Label', 'Run MMT comparison full (todo)', ...
        'Callback', @(~, ~) run_mmt_comparison_full(tsMM));
    
    
    % load MMT results
    import MMT.Import.load_mmt_results;
    uimenu(hMenuMeltingMap,'Label', 'Load MMT Results (todo)', 'Callback', @(~, ~) load_mmt_results(tsMM));

end