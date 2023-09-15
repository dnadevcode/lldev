% Plot all barcodes in a single line plot
% Need the ETE and all CBC output files in the same folder

clear,clc

%%  Change parameters here !!!  --------------- 

refBarcodeIndex = 1;  % identify which barcode as reference
barcode_to_plot = [1 2]; %10 8 12 11 13 1];  % [1 2 3];

yShift = 5; % vertical shift barcodes

gCircShift = 50;  % global circular shift to all barcodes
default_annotation_loc = []; % text for labeling each curve

%% import data

[file_name, path_name] = uigetfile;
ETE_file = fullfile(path_name, file_name);
%ETE_file = '/Users/yiilih/data/2019-03 Iranian ndm1 and oxa48/Iran ETE with the same sizes MMT_ETE session.mat';
%ETE_file = '/Users/yiilih/data/2019-03 Iranian ndm1 and oxa48/Iran ETE with respective sizes MMT_ETE session 2019-03-16_00_14_19_2019-03-16_09_16_52.mat';
load(ETE_file)

% Extract variables from structural array (eteSessionStruct)
fns = fieldnames(eteSessionStruct);

for i = 1:numel(fns)
    eval([fns{i}, ' = eteSessionStruct.', fns{i}, ';']);
end

nBarcodes = numel(stretchedConsensusBarcodes);

%% load CBC data.  Get the cut positions
folder = fileparts(ETE_file);
cuttingSites = cell(nBarcodes,1);
for i = 1:nBarcodes
    CBC_file = fullfile(folder, [consensusBarcodeNames{i}, '.mat']);

    % Get the cut positions in CBC
    try
        [posEndCounts, posEndCountsPreCut] = get_cut_positions(CBC_file);
        [~,index] = max(posEndCountsPreCut);
    
        % Sizes and stretches
        size_in_CBC = length(posEndCountsPreCut);
        size_in_ETE = length(stretchedConsensusBarcodes{i});
        index = round(index * (size_in_ETE / size_in_CBC));

        % assign the cut position
        tempCuttingSite = zeros(1,size_in_ETE);
        tempCuttingSite(index) = 1;
        cuttingSites{i} = tempCuttingSite;
    catch
        try
            load(CBC_file);
            [a,idx] = max(clusterConsensusData.bindingBarcode);
            
            
            cuttingSites{i} = zeros(1,length(clusterConsensusData.bindingBarcode));
            cuttingSites{i}(idx)=1;
        catch
            disp(['Were not able to find cut positions in file => ',consensusBarcodeNames{i}, '.mat'])
        end
    end
end

%% Choose the reference barcode . (Must choose the longest & consensus one!)
refBarcodeName = consensusBarcodeNames{refBarcodeIndex};
refBarcode = stretchedConsensusBarcodes{refBarcodeIndex};
refBarcodeLen = length(refBarcode);

%% Stretch the barcode
barcodes = cell(nBarcodes,1);
barcodeLens = zeros(nBarcodes,1);

for i = 1:nBarcodes
    oldBarcode = stretchedConsensusBarcodes{i};
    oldBarcodeLen = length(oldBarcode);
    newBarcodeLen = round(stretchFactorsMat(i,refBarcodeIndex)*oldBarcodeLen);
    barcodes{i} = interp1(oldBarcode,linspace(1,oldBarcodeLen,newBarcodeLen));
    barcodeLens(i) = newBarcodeLen;
    
    if ~isempty(cuttingSites{i})
        cuttingSites{i} = interp1(cuttingSites{i},linspace(1,oldBarcodeLen,newBarcodeLen));
    end
    
end

%% Shift and flip
finalBarcodes = cell(nBarcodes,1);
NanRefBarcode = nan([1,refBarcodeLen]); 
finalCuttingsites= cell(nBarcodes,1);
for i = 1:nBarcodes
    
    tempBarcode = barcodes{i};
    tempBarcodeLen = length(tempBarcode);
    
    % the cutting sites
    tempCuttingSite = cuttingSites{i};
            
    %-- if it is the reference Barcode
    if i == refBarcodeIndex
        lenDifference = 0;
        tempBarcode = refBarcode;

    %-- if longer than reference barcode ( DO NOTHING )
    elseif barcodeLens(i) > refBarcodeLen
        lenDifference = barcodeLens(i) - refBarcodeLen;
        % --- Do nothing!!! ---

    elseif barcodeLens(i) == refBarcodeLen

        % short shift
        tempBarcode = circshift(tempBarcode, shortShiftMat(i,refBarcodeIndex));
        tempCuttingSite = circshift(tempCuttingSite, shortShiftMat(i,refBarcodeIndex));

        % flip
        if flipMat(i,refBarcodeIndex) == 1
            tempBarcode = fliplr(tempBarcode);
            tempCuttingSite = fliplr(tempCuttingSite);
        end

        lenDifference = 0;

    %-- if shorter than reference barcode
    else
        lenDifference = barcodeLens(i) - refBarcodeLen;

        % short shift
        tempBarcode = [tempBarcode(shortShiftMat(i,refBarcodeIndex)+1:end),...
            tempBarcode(1:shortShiftMat(i,refBarcodeIndex))];

        if ~isempty(tempCuttingSite)  % if CBC_output is generated from a Fasta file. Skip it. 
            tempCuttingSite = [tempCuttingSite(shortShiftMat(i,refBarcodeIndex)+1:end),...
                tempCuttingSite(1:shortShiftMat(i,refBarcodeIndex))];
        end
        % flip
        if flipMat(i,refBarcodeIndex) == 1
            tempBarcode = fliplr(tempBarcode);
            tempCuttingSite = fliplr(tempCuttingSite);
        end

        % long shift
        tempBarcode = [NaN(1,longShiftMat(i,refBarcodeIndex)-1),tempBarcode];
        if ~isempty(tempCuttingSite)
            tempCuttingSite = [zeros(1,longShiftMat(i,refBarcodeIndex)-1),tempCuttingSite];
        end

        % long shift if overall shift exceeds the refBarcodes
        if length(tempBarcode) > refBarcodeLen

            move_to_front = tempBarcode(refBarcodeLen+1:end);
            tempBarcode(1:length(move_to_front)) = move_to_front;
            tempBarcode = tempBarcode(1:refBarcodeLen);
            
            if ~isempty(tempCuttingSite)
                move_to_front = tempCuttingSite(refBarcodeLen+1:end);
                tempCuttingSite(1:length(move_to_front)) = move_to_front;
                tempCuttingSite = tempCuttingSite(1:refBarcodeLen);
            end
        end

    end

    tempBarcode = circshift(tempBarcode,gCircShift);
    tempCuttingSite = circshift(tempCuttingSite,gCircShift);
    
    finalBarcodes{i} = tempBarcode;
    finalCuttingsites{i} = tempCuttingSite;
    
    % show parameters
    fileName = consensusBarcodeNames{i};
    name = fileName; %get_ethiopian_sample_names(fileName);
    dispParams(i,name, refBarcodeIndex,longShiftMat, flipMat,shortShiftMat, lenDifference)
end

%% Plotting order by similarity (P-value table)
similarity = sum(pValMat<0.01);
[~,similarityOrder] = sort(similarity,'descend');

%% Plot

figure(2)
clf
hold on

if isempty(barcode_to_plot)
    barcode_to_plot = 1:nBarcodes;
end 

if max(barcode_to_plot) > nBarcodes
    fprintf('\n====================================================================\n\n')
    disp('The index to plot is bigger than the total number of barcodes')
    disp(['Number of barcodes in ETE: ', num2str(nBarcodes)])
    disp(['The assigned barcode_to_plot are:', mat2str(barcode_to_plot)])
    fprintf('\n====================================================================\n\n')
end

k = 1;
for i = barcode_to_plot
    %disp([num2str(i),'...',num2str(barcodeLens(i))]);
    % Barcode
    xData = linspace(0,length(finalBarcodes{i})*stretchedKbpsPerPixel,length(finalBarcodes{i}));
    yData = finalBarcodes{i} + k*yShift;

    % Cut position
    %[yValue,~] = max(yData .* finalCuttingsites{i)};
    [~,xIndex] = max(finalCuttingsites{i});
    xCut = xData(xIndex);
    yCut = yData(xIndex);
    %disp(xCut)
    
    % Remove the flat barcode regions
    yData = finalBarcodes{i} + k*yShift;
    yData(yData==k*yShift)=nan;
    
    % plot
%     if mod(k,2)==1
%         color = [.3 .7 .3];
%     else 
%         color = [.3 .3 .7];
%     end 
    color = [.3 .3 .3];
    plot(xData,yData,'-','linewidth',2,'color',color);
    scatter(xCut, yCut, 'filled')
    
    % label
    fileName = consensusBarcodeNames{i};
    name = fileName;
    
    if isempty(default_annotation_loc) || default_annotation_loc == 0
        text_location = max(xData);
    else
        text_location = default_annotation_loc;
    end
    
    text(text_location, yShift*k + 1, name,'fontsize',10,'color',[.3 .3 .45]);

    k = k+1;

end
hold off

%xlim([0, 240]);% text_location+14])
%ylim([0, (length(barcode_to_plot)+1)*yShift])
xlabel('Position (kbp)','FontSize',10)
ylabel('Shifted Intensity','FontSize',10)
set(gca,'FontSize',12)

%--------------------------------------------------------------------------
%% Define functions
% Get the cut positions from CBC, and stretch barcoee to match ETE result
% (Functions copied from The Barcode Analysis code)
%--------------------------------------------------------------------------

% Show parameteres in the command window
function dispParams(i,name, refBarcodeIndex,longShiftMat, flipMat,shortShiftMat,lenDifference)
    if lenDifference == 0
        string = ' This is the Reference.';
    elseif lenDifference > 0
        string = ' -Longer than Ref.';
    else
        string = ' ---Shorter than Ref.';
    end
    
    disp([fprintf('%02d', i),...
        name,...
        string,...
        '  Longshift=',num2str(longShiftMat(i,refBarcodeIndex)),...
        '...flip=', num2str(flipMat(i,refBarcodeIndex)),...
        '...shortshift=',num2str(shortShiftMat(i,refBarcodeIndex))])
end
 
function [posEndCounts, posEndCountsPreCut] = get_cut_positions(consensusMatFilepath)
    
    clusterConsensusData = feval(@(tmp) tmp.clusterConsensusData, load(consensusMatFilepath));
    [posEndCounts, posEndCountsPreCut] = count_cut_positions_for_cluster(clusterConsensusData);
end

function [posEndCounts, posEndCountsPreCut] = count_cut_positions_for_cluster(clusterConsensusData)
    clusterResultStruct = clusterConsensusData.clusterResultStruct;
    barcodeLens = cellfun(@length, clusterResultStruct.barcodes);
    barcodeFlipTFs = clusterResultStruct.flipTFs;
    barcodeCircShifts = clusterResultStruct.circShifts;
    
    [posEndCounts, posEndCountsPreCut] = count_cut_positions(barcodeLens, barcodeFlipTFs, barcodeCircShifts);
end

function [posEndCounts, posEndCountsPreCut] = count_cut_positions(barcodeLens, barcodeFlipTFs, barcodeCircShifts)
    alignedPosVectCells = arrayfun(...
        @(barcodeLen, flipTF, circShift) ...
            flip(circshift(linspace(0, 1, barcodeLen), circShift, 2), flipTF + 1),...
        barcodeLens,...
        barcodeFlipTFs,...
        barcodeCircShifts,...
        'UniformOutput', false);
    alignedPosMat = cell2mat(alignedPosVectCells);
    endsMat = (alignedPosMat == 0) | (alignedPosMat == 1);
    posEndCounts = sum(endsMat)';
    posEndCountsPreCut = sum(circshift(endsMat, -1, 2) & endsMat)';
end


