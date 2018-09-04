function [] = launch_experiment_curve_import_ui(ts, theoryDisplayNames, fn_on_compare_theories_vs_experiments)
    % launch_experiment_curve_import_ui -
    %   adds a tab with list management UI/functionality  for
    %    experiment curves
    %  ts: tabbed screen handle
    
    

    function [btnCompareAgainstTheories] = make_compare_against_theories_button_template(ts, theoryDisplayNames, fn_on_compare_theories_vs_experiments)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnCompareAgainstTheories = FancyListMgrBtn('Compare against theories', @(~, ~, eclm) try_compare_against_theories(eclm, ts, theoryDisplayNames, fn_on_compare_theories_vs_experiments));
        function [] = try_compare_against_theories(eclm, ts, theoryDisplayNames, fn_on_compare_theories_vs_experiments)
            selectedItems = eclm.get_selected_list_items();

            lenExperiments = size(selectedItems, 1);
            if lenExperiments < 1
                questdlg('You must select some experiment curves first!', 'Not Yet!', 'OK', 'OK');
                return;
            end

            % Handle response
            switch questdlg(...
                    sprintf('Calculate cross-correlation stats for previously selected theories  against %d experiments?', lenExperiments), ...
                    'Calculation Confirmation', 'Continue', 'Continue')
                case 'Continue'
                    experimentNames = selectedItems(:, 1);
                    experimentCurveStructs = selectedItems(:, 2);
                    fn_on_compare_theories_vs_experiments(ts, experimentNames, experimentCurveStructs, theoryDisplayNames);
            end
        end
    end
    
    import CBT.ExpComparison.UI.ExpCurveImportScreen;
    [ecis] = ExpCurveImportScreen(ts);
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs = FancyListMgrBtnSet();
    flmbs.NUM_BUTTON_COLS = 1;
    flmbs.add_button(make_compare_against_theories_button_template(ts, theoryDisplayNames, fn_on_compare_theories_vs_experiments));
    
    eclm = ecis.ExpCurveListManager;
    eclm.add_button_sets(flmbs);
    
end