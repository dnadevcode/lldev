function [kymoIdxs, leftIdxs, rightIdxs, frameIdxs, intensitySums, intensityVars] = kymo_fragmentation_summary(kymoImgs, kymoFgMasks)
    
    % Author: Saair Quaderi
    % Time: Spring 2016
    %
    %  Note current implementation is not memory-friendly and not in use
    %  Practically speaking outputs should be written out of memory
    %  and buffered into disk destination/database
    %
    %  This was just proof-of-concept demo code that I made 
    %  while discussing putting MeltMap Theory Nicking Dataset
    %  from Jonas Tegenfeldt 's group that
    %  Dung Nguy?n Thùy <thuydung7120@gmail.com>,
    %  was working with in a relational database format

    numKymos = length(kymoImgs);
    kymoIdxs = cell(numKymos, 1);
    leftIdxs = cell(numKymos, 1);
    rightIdxs = cell(numKymos, 1);
    frameIdxs = cell(numKymos, 1);
    intensitySums = cell(numKymos, 1);
    intensityVars = cell(numKymos, 1);
    for kymoIdx = 1:numKymos
        kymoImg = kymoImgs{kymoIdx};
        kymoFgMask = kymoFgMasks{kymoIdx};
        
        numFrames = size(kymoImg, 1);

        kymoLeftIdxs = cell(numFrames, 1);
        kymoRightIdxs = cell(numFrames, 1);
        kymoFrameIdxs = cell(numFrames, 1);
        kymoIntensitySums = cell(numFrames, 1);
        kymoIntensityVars = cell(numFrames, 1);
        for kymoFrameIdx=1:numFrames
            kymoImgRow = kymoImg(kymoFrameIdx, :);
            fgKymoMaskRow = kymoFgMask(kymoFrameIdx, :);
            tmpMaskDiff = diff([0, fgKymoMaskRow, 0]);
            kymoLeftIdxs{kymoFrameIdx} = find(tmpMaskDiff == 1)';
            kymoRightIdxs{kymoFrameIdx} = find(tmpMaskDiff == -1)' - 1;
            kymoIntensitySums{kymoFrameIdx} = arrayfun(@(leftIdx, rightIdx) sum(kymoImgRow(leftIdx:rightIdx)), kymoLeftIdxs, kymoRightIdxs);
            kymoIntensityVars{kymoFrameIdx} = arrayfun(@(leftIdx, rightIdx) var(kymoImgRow(leftIdx:rightIdx)), kymoLeftIdxs, kymoRightIdxs);
            numFragments = length(kymoLeftIdxs{kymoFrameIdx});
            kymoFrameIdxs{kymoFrameIdx} = repmat(kymoFrameIdx, numFragments, 1);
        end
        kymoLeftIdxs = vertcat(kymoLeftIdxs{:});
        kymoRightIdxs = vertcat(kymoRightIdxs{:});
        kymoFrameIdxs = vertcat(kymoFrameIdxs{:});
        kymoIntensitySums = vertcat(kymoIntensitySums{:});
        kymoIntensityVars = vertcat(kymoIntensityVars{:});
        numFragmentFrameEntries = length(kymoFrameIdxs);
        
        kymoIdxs{kymoIdx}= repmat(kymoIdx, numFragmentFrameEntries, 1);
        leftIdxs{kymoIdx} = kymoLeftIdxs;
        rightIdxs{kymoIdx} = kymoRightIdxs;
        frameIdxs{kymoIdx} = kymoFrameIdxs;
        intensitySums{kymoIdx} = kymoIntensitySums;
        intensityVars{kymoIdx} = kymoIntensityVars;
    end
    
    kymoIdxs = vertcat(kymoIdxs{:});
    leftIdxs = vertcat(kymoLeftIdxs{:});
    rightIdxs = vertcat(kymoRightIdxs{:});
    frameIdxs = vertcat(kymoFrameIdxs{:});
    intensitySums = vertcat(kymoIntensitySums{:});
    intensityVars = vertcat(kymoIntensityVars{:});
end