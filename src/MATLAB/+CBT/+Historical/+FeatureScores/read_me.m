function read_me()
    % UNTRUSTWORTHY utility functions related to
    %    the computation of "feature scores" for competitive-binding
    %    theory barcodes from theoretical sequences
    %
    % Note from SQ: 
    % DO NOT BLINDLY TRUST THESE FUNCTIONS TO GIVE MEANINGFUL RESULTS!
    %  This code has been put together in an attempt to preserve a
    %   semi-restored version of historical functionality as a potential
    %   draft for bringing back feature scores
    %  The core functionality for feature scores is from
    %  what used to be in Erik's code back in SVN R53. Specifically:
    %     CBT_MatchtoExperimentAndTheories.cb_find_fs_theory
    %     CompetitiveBindingTheory.cb_calcinfotheory_fs
    %  which depended on what was then:
    %     CMN_HelperFunctions.robustextrema
    %  Not sure anyone cares about any of this functionality anymore,
    %     but values may not be totally backwards-compatible with those
    %     generated preceding March 2015. Moreover, the conditions under
    %     which the eCISs3 data were produced were not documented so it's 
    %     unclear whether the resulting values are still applicable
    % 
    % Authors:
    %  Saair Quaderi
    %   (Scavenged scattered code, fixed some obvious bugs, and
    %      refactored the functionality)
    %  Erik Lagerstedt
    %    (Listed as author for much of the original feature-score related code)
    
    fprintf('[\b%s]\b\n', ...
        strrep( ...
            strrep(...
                feval( ...
                    @(s) s(min(strfind(s, sprintf('\n')) - 1):(max(strfind(s, sprintf('\n    fprintf'))))),...
                    fileread([mfilename('fullpath'), '.m'])), ...
                sprintf('\r\n'), ...
                sprintf('\n')), ...
        sprintf('\n    %%'), ...
        sprintf('\n ')));
end
