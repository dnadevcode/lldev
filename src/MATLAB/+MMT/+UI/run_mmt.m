function [cache] = run_mmt(tsMM,cache)
    if nargin < 2
    	cache = containers.Map();
        mmtSessionStruct = struct();
        cache('mmtSessionStruct') = mmtSessionStruct;
    else
        mmtSessionStruct = cache('mmtSessionStruct');
    end

    % This is for generating an MMT
    
    % run import theory template
    import Fancy.UI.Templates.launch_theory_ui;
    lm = launch_theory_ui(tsMM);

    import MMT.UI.compute_theory_ui;
    [lm,cache] = compute_theory_ui(lm,tsMM,cache);

	assignin('base','cache',cache)

end