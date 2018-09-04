function [] = load_ca_results( tsHCA, hcaSessionStruct )
   if nargin < 2
        import CBT.Hca.Import.load_hca_struct;
        hcaSessionStruct = load_hca_struct();
        if isempty(hcaSessionStruct)
            return;
        end
    end
    if isempty(hcaSessionStruct)
        return;
    end

   % assignin('base', 'hcaSessionStruct', hcaSessionStruct);
    import CBT.Hca.UI.display_results_ui;

    cache = containers.Map();
    cache('hcaSessionStruct') = hcaSessionStruct;
    display_results_ui(tsHCA, cache);
    fprintf('Finished loading HCA session results \n');

    import CBT.Hca.UI.display_additional_results_ui;
    display_additional_results_ui(tsHCA, cache);

end

