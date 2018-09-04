function [layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movieArr, kymosEdgePts)
    numKymos = length(kymosEdgePts);
    layeredKymos = cell(numKymos, 1);
    kymosMasks = cell(numKymos, 1);
    kymosCenterXYCoords = cell(numKymos, 1);
    kymosEdgeCentersOffsets = cell(numKymos, 1);
    
    % kymosXYStepPerDist = cell(numKymos, 1);
    
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    progress_messenger = BasicTextProgressMessenger.get_instance();
    msgOnInit = sprintf(' Extracting %d kymos with interpolation from raw video...\n', numKymos);
    progress_messenger.init(msgOnInit);
    
    tryAvoidInterpTF = true;
    
    import OptMap.KymoAlignment.nearest_nonnan;
    for kymoNum = 1:numKymos
        kymoEdgePts = kymosEdgePts{kymoNum};
        
        numFrames = size(kymoEdgePts, 1);
        numCoordsPerPoint = size(kymoEdgePts, 2);
        numPoints = size(kymoEdgePts, 3); % Currently only two points are supported
        if numCoordsPerPoint ~= 2
            error('Unsupported number of dimensions');
        end
        if numPoints ~= 2
            error('Unsupported number of edge points');
        end
        quitRoundTF = false;
        for pointsCoordNum = 1:numCoordsPerPoint
            for pointNum = 1:numPoints
                [kymoEdgePts(:, pointsCoordNum, pointNum), quitRoundTF] = nearest_nonnan(kymoEdgePts(:, pointsCoordNum, pointNum));
                if quitRoundTF
                    break;
                end
            end
            if quitRoundTF
                break;
            end
        end
        if quitRoundTF
            progress_messenger.checkin(kymoNum, numKymos);
            continue;
        end
        

        
        kymoCenterXYCoords = fliplr(mean(kymoEdgePts, 3));
        xyDeltas = fliplr(diff(kymoEdgePts, 1, 3));
        dists = sqrt(sum(xyDeltas .^ 2, 2));
        kymoXYUnitStepPerDist = xyDeltas./repmat(dists, [1, size(xyDeltas, 2)]);
        if tryAvoidInterpTF && ...
                (((kymoCenterXYCoords(1, 1) == round(kymoCenterXYCoords(1, 1))) && ... % (first x center is integer AND
                    all(kymoCenterXYCoords(:, 1) == kymoCenterXYCoords(1, 1)) && ... % all x centers are constant AND
                    all(kymoXYUnitStepPerDist(:, 1) == 0) && ... % all x steps are zero AND
                    all(kymoXYUnitStepPerDist(:, 2) == round(kymoXYUnitStepPerDist(:, 2)))) ... % all y steps are integer)
                || ... % OR
                    ((kymoCenterXYCoords(1, 2) == round(kymoCenterXYCoords(1, 2))) && ... % (first y center is integer AND
                    all(kymoCenterXYCoords(:, 2) == kymoCenterXYCoords(1, 2)) && ... % all y centers are constant AND
                    all(kymoXYUnitStepPerDist(:, 2) == 0) && ... % all y steps are zero AND
                    all(kymoXYUnitStepPerDist(:, 1) == round(kymoXYUnitStepPerDist(:, 1))))) % all x steps are integer)
            % we can round centers to avoid having to interpolate!
            kymoCenterXYCoords2 = kymoCenterXYCoords;
            kymoCenterXYCoords = ceil(kymoCenterXYCoords);
            kymoEdgeCentersOffsets = kymoCenterXYCoords - kymoCenterXYCoords2;
        else
            kymoEdgeCentersOffsets = zeros(size(kymoCenterXYCoords));
        end
        kymosEdgeCentersOffsets{kymoNum} = kymoEdgeCentersOffsets;
        
        maxDist = max(dists);
        
        % todo: consider using interp3 to improve speed
        %  https://se.mathworks.com/help/matlab/ref/interp3.html
        
        numSamplesEachSide = ceil(maxDist);
        numSamples = (2 * numSamplesEachSide) + 1; %note: this will cause every row to contain an odd number of pixels (mask will be rounded up to include "half" pixels on each side)
        kymoImg = NaN(numFrames, numSamples);
        kymoMask = false(numFrames, numSamples);
        import AB.Core.img_profile;
        for frameNum = 1:numFrames
            xyStep = kymoXYUnitStepPerDist(frameNum, :);

            layerOffsetStep = fliplr(xyStep) .* [1, -1];
            for layer = -1:1
                xyCoords = kymoCenterXYCoords(frameNum, :);
                if not(any(isnan(xyCoords)))
                    xyCoords = xyCoords + layerOffsetStep.*layer;
                    xyCoords = repmat(xyCoords, [2 1]);

                    offsets = xyStep.*numSamplesEachSide;
                    xyCoords = xyCoords + [offsets; -offsets];
                    img = movieArr(:, :, 1, frameNum);
                    [interpVals, ~] = img_profile(img, xyCoords, numSamples);
                    kymoImg(frameNum, :, layer + 2) = interpVals;
                    molDist = round(dists(frameNum));
                    kymoMask(frameNum, floor((numSamples - molDist)/2) + (1:molDist)) = true;
                end
            end
        end
        layeredKymos{kymoNum} = kymoImg;
        kymosMasks{kymoNum} = kymoMask;
        kymosCenterXYCoords{kymoNum} = kymoCenterXYCoords;
        % kymosXYStepPerDist{kymoNum} = kymoXYStepPerDist;
        progress_messenger.checkin(kymoNum, numKymos);
    end
    msgOnCompletion = sprintf('    Finished extracting %d kymos from raw video\n', numKymos);
    progress_messenger.finalize(msgOnCompletion);
end