classdef settings < handle
    % updated 25/09/16
    % Settings
    
    % This file will contain default values for the calculations.
    % However the values can be changed either here (permament changes) or 
    % in the GUI (temporary changes)
    properties
        
        pValueThresh = 0.01;
        
        contigLen = 50000;
        shiftBp = 20000;
       % uncReg  = 3347;
        allowedOverlap = 2;
        uncReg  = 3347;
        
        contigSizeAllPos =  25000:2000:70000;
        shiftBpAllPos = 10000:1000:40000;

        
        concNetropsin_molar = 6E-6;
        concYOYO1_molar = 4E-8;

        shortestSeq = 20000; % we want to put a bound on how small the sequences we can consider
     %   longestSeq = 130000;
        
       psfSigmaWidth = 1.1157e+03;
       % psfSigmaWidth = 1500;
        %         maxLenSeq = 100000; % change this in the future to number of minLen
%         minLenSeq =  2*80000;
%         numPlasmids = 5082;
%         
        lengthThreshold = 0;
        lengthBarcode = 372;
        numberContigs = 10;

        contigSize = 40;
        longerSize = 25;
        method = 'fisher'
%         data = 'Unknown';
        
        nRandom = 1000;
        %allowedOverlap = 2;
        contigLengths = [40];
        
        psfWidth = 300; %nm point spread function, 
        bpPerNm = 3.719; % base pairs per nanometer, how was this gotten
     %   bpPerNm = 3.642;
        camRes = 159.2; %nm/pixel  / these depend on the experiment

        NETROPSINconc = 6E-6; %
        YOYO1conc = 4E-8; %
        
        netropsinBindingConstant = [ 500000 100000000 ];  
        yoyo1BindingConstant = 1*(10^10);
        % overlapLim = 2; overlap is not used when calculating p-values, at
        % least not for this method
        
        % forcePlace = false; doesnt make sense
        

        kbpPerPixel = 3.719*159.2/1000; %depends on others
        %kbpPerPixel = 3.442*159.2/1000;
        %shortestSeq
        
        % allowOverlap = true; unimportant at the moment.
        randomBarcodes = 1000; %number of randomised barcodes, need to explain why it should be 1000
        maxLen = 0;
        
%         flipAllowed = true;
%         formatNames = true;
        
        %pValueThresh = 0.01;
        sigmaWidth = 4;

        nonzeroKernelLen;
        typeZeroModel = 1; % we could also use markov
        typeEVD = 1;  %gev, gumbel, etc.
        zeroModel;
        
        competitors = struct ;
        

    end
    
    methods
        function settings = settings(isDefault)
            % Constructor. 
%             if nargin == 0
%                 isDefault = true;
%                 refCurve = [];
%             end
%             if ~isDefault
%                 prompt = {'Name of sample:','Base-pairs per µm:','Allowed overlap (px):','Force place contigs:','Shortest seq (bp):','Netropsin conc:','YOYO-1 conc:','Camera resolution (nm/pixel):','Format names:'};
%                 defaultVals = {'Unknown','3719','2','No','7000','6E-6','4E-8','159.2','Yes'};
%                 dlg_title = 'Input settings';
%                 num_lines = 1;
%                 answer = inputdlg(prompt,dlg_title,num_lines,defaultVals);
%                 
%                 %---Input settings dialog---
%                 settings.data = answer{1};
%                 settings.bpPerNm = str2double(answer{2})/1000;
%                 settings.overlapLim = str2double(answer{3});
%                 settings.forcePlace = ~strcmp(answer{4}(1),'N')||strcmp(answer{4}(1),'n');
%                 settings.shortestSeq = round(max(4*settings.psfWidth*settings.bpPerNm,str2double(answer{5})));
%                 settings.NETROPSINconc = str2double(answer{6});
%                 settings.YOYO1conc = str2double(answer{7});
%                 settings.camRes = str2double(answer{8});
%                 settings.formatNames = strcmp(answer{9}(1),'Y')||strcmp(answer{9}(1),'y');
%                 settings.kbpPerPixel = settings.bpPerNm*settings.camRes/1000;
%                 settings.allowOverlap = settings.overlapLim > 0;
%             end
            settings.calc_constants();
        end
        
        function calc_constants(settings)
            settings.nonzeroKernelLen =8925; %settings.sigmaWidth*2*settings.psfWidth*bpPerNm;
            
            settings.competitors.Netropsin.bindingConstantRules = {...
                'NNNN', 5*(10^5);...
                'WWWW', 1*(10^8)...
            };
        
            settings.competitors.Yoyo1.bindingConstantRules = {...
                'NNNN', 1*(10^11)...
             };
            % Calculates constants derived from input parameters
%             if settings.flipAllowed
%                 settings.maxLen = 2*length(refCurve);
%             else
%                 settings.maxLen = length(refCurve);
%             end
%             if ~settings.forcePlace
%                 settings.maxLen = settings.maxLen + 1;
%             end
            %settings.kbpPerPixel = settings.bpPerNm * settings.camRes/1000;
            %settings.shortestSeq = 4 * settings.psfWidth * settings.bpPerNm;

            %settings.removePvalue = min(0.5,settings.pThreshold-0.01);  %
            %do not remove p-values
            %settings.clusterThreshold = (2*log(settings.removePvalue))^2;
            % do not cluster
        end
    end
    
end

