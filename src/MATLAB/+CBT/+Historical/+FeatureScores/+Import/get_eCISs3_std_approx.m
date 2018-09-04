function [stdApprox] = get_eCISs3_std_approx(ratioAT)
    % Note from SQ: the results for this are based off of eCISs3,
    %   but since we don't know relevant context used to produce it
    %   like NETROPSINconc/YOYO1conc, using it may not work as
    %   intended under differing environmental conditions

    tableMinRatioVal = 0.05; % at least 5% AT
    tableMaxRatioVal = 0.95; % at most 95% AT
    tableRatioValInterval = 0.005; % every 0.5%
    tableColRatiosAT = tableMinRatioVal:tableRatioValInterval:tableMaxRatioVal;
    minIdx = 1;
    maxIdx = numel(tableColRatiosAT);

    % The following is commented out since we don't need to load
    %  this old file or recompute a curve-fitting every time
    %  if we just store the fitted curve's results
    %
    % You can find eCISs3.mat in SVN R53 in
    %   the path MeltCB/svn/InputFiles/eCISs3.mat
    % s = load('eCISs3.mat', 'eCISs3');
    % eCISs3 = s.eCISs3;
    % % eCISs3: matrix of std in the intensity of random barcodes with
    %   each row associated with a trial and each col associated with
    %   the corresponding ratioAT from tableColRatiosAT
    % % % How eCISs3 was originally produced isn't clear
    % % % but maybe something like the following:
    % % tableColRatiosAT = 0.05:0.005:0.95;
    % % numTrials = 200;
    % % genSequenceLen = 100000; % wildly speculative
    % % import CBT.Historical.FeatureScores.Export.reproduce_eCISs3;
    % % import CBT.get_default_barcode_gen_settings;
    % % barcodeGenSettings = get_default_barcode_gen_settings(); % actual settings used unknown
    % % eCISs3 = reproduce_eCISs3(tableColRatiosAT, numTrials, genSequenceLen, barcodeGenSettings);
    % polynomialDegree = 6; % selected through trial-and-error -- seemed to produce a very good fit
    % yData = mean(eCISs3);
    % yData = yData(:);
    % minIdx = 1;
    % maxIdx = numel(yData);
    % pNrm = polyfit((0:1/(maxIdx - minIdx):1)', yData, polynomialDegree);

    % Load table of std in the intensity of random barcodes with different ATc

    idxApprox = minIdx + (maxIdx - minIdx)*(ratioAT - tableMinRatioVal)/(tableMaxRatioVal - tableMinRatioVal);
    pNrm = [...
        -0.01811270792147221700000,...
         0.04229197469156554400000,...
        -0.04007936659882530700000,...
         0.01857525848522636300000,...
        -0.00191908006766777920000,...
         0.00037425900102521897000,...
         0.00000554698290002980270...
    ];
    xNrm = (idxApprox - minIdx)/(maxIdx - minIdx);
    stdApprox = polyval(pNrm, xNrm);
end
