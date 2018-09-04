
  
    % loads figure window
    hFig = figure(...
        'Name', 'CB HCA tool', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    hMenuParent = hFig;
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
   
    import CBT.Hca.UI.launch_theory_ui;
    lm = launch_theory_ui(ts);

%     import CBT.Hca.UI.load_theory_ui;
%     [lm,cache] = load_theory_ui(lm,ts);

            
     % load default settings
    import CBT.Hca.Import.set_default_settings;
    sets = set_default_settings();
    %sets.barcodeGenSettings.yoyo1BindingConstant = 26;
    cache = containers.Map();
    cache('sets') = sets;
    hcaSessionStruct = struct();
    hcaSessionStruct.names=[];
    hcaSessionStruct.barcodeGen=[];
    hcaSessionStruct.lengths=[];
    hcaSessionStruct.rawBarcodesFiltered=[];
    hcaSessionStruct.rawBitmasksFiltered=[];
    hcaSessionStruct.rawBitmasks=[];
    hcaSessionStruct.consensusStruct=[];
    hcaSessionStruct.theoryGen = [];
    hcaSessionStruct.comparisonStructure = [];

    
    cache('hcaSessionStruct') = hcaSessionStruct;

    import CBT.Hca.UI.compute_theory_ui;
    [lm,cache] = compute_theory_ui(lm,ts,cache);


    import CBT.Hca.UI.launch_export_ui;
    cache = launch_export_ui(ts, cache);

            
%     import Fancy.UI.FancyList.FancyListMgrBtnSet;
%     flmbs4 = FancyListMgrBtnSet();
%     flmbs4.NUM_BUTTON_COLS = 1;
%     flmbs4.add_button(make_theory(ts));
%     lm.add_button_sets(flmbs4);

