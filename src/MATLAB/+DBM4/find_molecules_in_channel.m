function [moleculeEdgeIdxs, channelMoleculeLabeling, closestFits] = find_molecules_in_channel(channelIntensityCurve, foregroundI, sets)
    % FIND_MOLECULES_IN_CHANNEL - given a 1D intensity curve (curve), and a threshold
    %	(signalThreshold), detects a molecule (assumed to be a continuous bright
    %	region which is brighter 'on average' than the signalTreshold.
    %
    % Inputs:
    %   channelIntensityCurve
    %     vector containing the intensity profile along the channel
    %   signalThreshold
    %     the intensity threshold for a region to be considered a
    %     molecule
    %   filterEdgeMolecules
    %     true if molecules closer than colSidePadding should be removed
    %
    % Outputs: 
    %	moleculeEdgeIdxs
    %     Nx2 matrix where N is the number of molecules found and not
    %     filtered out and first column provides the start indices
    %     for the molecules and the second column provides the end
    %     indices for the molecules
    %	channelMoleculeLabeling
    %	  label matrix (similar to what one might get from bwlabel)
    %   closestFits
    %     cell array with closest fits of function for each of the labels
    %     
    % Authors:
    %   Charleston Noble
    %   Saair Quaderi

    if nargin < 3
        signalThreshold = 0;
    end
    
% 
%     curveLen = length(channelIntensityCurve);
%     channelIntensityCurve(isnan(channelIntensityCurve)) = 0;
%     posCurve = foregroundI;

%     channelIntensityCurve(~posCurve) = 0;
    
    % quick method: just use first approximation
    import Microscopy.Utils.segment_nonadj_data;
    [~, moleculeEdgeIdxs_firstApprox] = segment_nonadj_data(find(foregroundI));
    
    moleculeEdgeIdxs = moleculeEdgeIdxs_firstApprox;
    
    %%? do we need this
    channelMoleculeLabeling = zeros(size(channelIntensityCurve));
    closestFits =[];
    
    % slower method: compute tanh/sigmoid fits. Does not need this in case
    % the edges are detected later (in HCA i.e.)
%     
%     lens_firstApprox = diff(moleculeEdgeIdxs_firstApprox, 1, 2) + 1;
%     
%     firstApproxCount = size(moleculeEdgeIdxs_firstApprox, 1);
%     [lens_firstApproxSorted, idxsSorted] = sort(lens_firstApprox, 'descend');
%     
%     
%     import OptMap.MoleculeDetection.EdgeDetection.Fit.fit_sigmoid;
%     ft = fittype('a + b*normcdf(x,mu,sig)','indep','x');
% 
%     
% %     
% %     xIdxs = 1:curveLen;
% %     fn_make_fit = @(fitObject, x) (fitObject.a + fitObject.f * (tanh( (x - fitObject.b) ) - tanh( (x - fitObject.c) )));
% %     aFittype = fittype('a + f * (tanh((x - b) ) - tanh((x - c) ))');
% %     
% %     closestFits = [];
% %     moleculeEdgeIdxs = [];
% %     moleculeLocs = []; % locations of molecules, so that they would be in correct order
%     remainderCurve = channelIntensityCurve;
% %     channelMoleculeLabeling = zeros(size(channelIntensityCurve));
% %     
%     curveLabelNum = 0;
%     for firstApproxNum = 1:firstApproxCount
% %         
% %     fitsLeft(1,:) =;
% 
%      [a,b] = find(~isnan(remainderCurve),1);
%     remainderCurve(isnan(remainderCurve)) = remainderCurve(b);
% 
%     Fopts.StartPoint =  [remainderCurve(moleculeEdgeIdxs_firstApprox(1)-1),mean(remainderCurve(moleculeEdgeIdxs_firstApprox(1):moleculeEdgeIdxs_firstApprox(2))) ];
% 
%     [mdlF, gofStruct, outputStruct, Fopts] = fit_sigmoid(remainderCurve',ft,Fopts);
%     
% %             [mdlF, gofStruct, outputStruct, Fopts] = fit_sigmoid(remainderCurve',ft);
% 
%         [mdlF, ~, ~, ~] = fit_sigmoid(remainderCurve',ft,Fopts);
% 
%             
%         currIdx = idxsSorted(firstApproxNum);
%         startEdgeFirstApprox = moleculeEdgeIdxs_firstApprox(currIdx, 1);
%         endEdgeFirstApprox = moleculeEdgeIdxs_firstApprox(currIdx, 2);
% %         if (startEdgeFirstApprox == 1) || (endEdgeFirstApprox == curveLen)
% %             remainderCurve(startEdgeFirstApprox:endEdgeFirstApprox) = 0;
% %             continue;
% %         end
%         
%         tmpCurve = remainderCurve;
%         tmpCurve(1:(startEdgeFirstApprox - 1)) = 0;
%         tmpCurve((endEdgeFirstApprox + 1):end) = 0;
%         
%         
%         % Make a guess as to where the region starts and ends.
%         b0 = startEdgeFirstApprox;
%         c0 = endEdgeFirstApprox;
% 
%         % Starting point for the model fitting.
%         p0 = [0, b0, c0, 0];
%         fitObject = fit((1:curveLen)', tmpCurve, aFittype, 'StartPoint', p0);      
%         closestCurrFit = fn_make_fit(fitObject, xIdxs);
%         
%         newestEdgeIdxs = [ceil(fitObject.b), floor(fitObject.c)];
%         newestEdgeIdxs = sort(newestEdgeIdxs);
%         
%         
%         % Get the coordinates back from the fitted model.
%         signalAboveNoise = fitObject.f;
% 
%         % If there are inconsistencies in the region finding,
%         % or the signal is too small then terminate 
%         % the molecule detection method
% 
%         badRegionStart = newestEdgeIdxs(1) < 1;
%         badRegionEnd = newestEdgeIdxs(2) > curveLen;
%         thresholdDeficit = max(0, signalThreshold - signalAboveNoise);
%         if badRegionStart || badRegionEnd || (thresholdDeficit > 0)
%             remainderCurve(startEdgeFirstApprox:endEdgeFirstApprox) = 0;
%             continue;
%         end
%         
%         % Extend the coordinates forward and backward until we hit a zero
%         newestEdgeIdxs(1) = min(newestEdgeIdxs(1), startEdgeFirstApprox);
%         newestEdgeIdxs(2) = max(newestEdgeIdxs(2), endEdgeFirstApprox);
%         
%         currIdxs = newestEdgeIdxs(1):newestEdgeIdxs(2);
%         curveLabelNum = curveLabelNum +  1;
%         channelMoleculeLabeling(currIdxs) = curveLabelNum;
%         closestFits = [closestFits; {closestCurrFit}];
%         moleculeEdgeIdxs = [moleculeEdgeIdxs; newestEdgeIdxs]; %#ok<AGROW>
%         moleculeLocs = [moleculeLocs currIdx];
%         remainderCurve(currIdxs) = 0;
%     end
%     % now keep the proper sorting of the molecules, so switch back based on
%     % moleculeLocs
%     try
%         [a,b] = sort(moleculeLocs);
%         moleculeEdgeIdxs(a,:) = moleculeEdgeIdxs(b,:);
%         channelMoleculeLabeling(a,:) = channelMoleculeLabeling(b,:);
%         closestFits(a,:) = closestFits(b,:);
%     end
   
end