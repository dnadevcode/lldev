classdef comparison_settings < handle
    % updated 25/09/16
    % Settings
    
    % This file will contain default values for the calculations.
    % However the values can be changed either here (permament changes) or 
    % in the GUI (temporary changes)
    properties
        meanBpExt_nm  = 0.225;
        pixelWidth_nm = 130;
        concNetropsin_molar;
        concYOYO1_molar;
        concDNA;
        psfSigmaWidth_nm;
        deltaCut;
        isLinearTF;
        widthSigmasFromMean;
        computeFreeConcentrations;
        model;
    end
    
    methods
        function settings = comparison_settings(isDefault)
       
             import CBT.Hca.UI.get_comparison_settings;
                [ settings.meanBpExt_nm,settings.concNetropsin_molar,settings.concYOYO1_molar,settings.concDNA,settings.psfSigmaWidth_nm,settings.pixelWidth_nm,settings.deltaCut,settings.isLinearTF,settings.widthSigmasFromMean,settings.computeFreeConcentrations,settings.model] = get_comparison_settings(); 
        end

    end
    
end

