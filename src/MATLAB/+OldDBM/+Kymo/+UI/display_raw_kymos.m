function [] = display_raw_kymos(dbmODW, hParent)
    % DISPLAY_RAW_KYMOS - Generates kymographs from movies and displays
    % them
    %
    % Authors:
    %   Saair Quaderi
    %   Charleston Noble (previous version)
    %


    dbmODW.verify_thresholds();
    
    import OldDBM.Kymo.DataBridge.create_and_set_all_missing_raw_kymos;
    create_and_set_all_missing_raw_kymos(dbmODW);
    
    import OldDBM.Kymo.UI.show_raw_kymos;
    show_raw_kymos(dbmODW, hParent);
end