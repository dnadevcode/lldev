classdef settings < handle
    % updated 25/09/16
    % Settings
    
    % This file will contain default values for the calculations.
    % However the values can be changed either here (permament changes) or 
    % in the GUI (temporary changes)
    properties
        temp = 80;
        saltConc = 0.05;
        deltaCut = 3;
        
        concYOYO1_molar = 4E-8;
        psfSigmaWidth_nm = 300;  % in nm
        pixelWidth_nm =192; 
        meanBpExt_nm = 0.294;
        
        kbpPerPixel = 600;
        
        promtToZscore = 1;
% 
%         psfWidth = 301; %nm point spread function, 
%         bpPerNm = 3.719; % base pairs per nanometer, how was this gotten
%         camRes = 159.2; %nm/pixel  / these depend on the experiment
%   

    end
    
    methods
        function settings = settings(isDefault)
       
             import MMT.Core.Consensus.get_mmt_settings;
                [ settings.psfSigmaWidth_nm, settings.deltaCut, settings.pixelWidth_nm,settings.meanBpExt_nm,settings.concYOYO1_molar,settings.saltConc,settings.temp] = get_mmt_settings(...
                       settings.psfSigmaWidth_nm, ...
                        settings.deltaCut, ...
                        settings.pixelWidth_nm,...
                        settings.meanBpExt_nm,...
                        settings.concYOYO1_molar,...
                        settings.saltConc,...
                        settings.temp ...
            ); 
        end

    end
    
end

