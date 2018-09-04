function [] = plot_kymo_time_averages(dbmODW, hParent)
    % PLOT_KYMO_TIME_AVERAGES - Takes aligned kymographs and makes 
    %   1D intensity profiles from them
    % 
    % Authors:
    %   Saair Quaderi

    import OldDBM.Kymo.DataBridge.create_and_set_all_missing_fg_kymo_time_avgs;
    create_and_set_all_missing_fg_kymo_time_avgs(dbmODW);
    
    import OldDBM.Kymo.UI.show_aligned_kymo_time_avgs;
    show_aligned_kymo_time_avgs(dbmODW, hParent);
end    