function [grayscaleVideo, rawValueRange, loadedFrameNums, srcImfInfo] = import_grayscale_tiff_video(srcTiffFilepath, maxNumFramesToLoad, fn_process_frame)
    % IMPORT_GRAYSCALE_TIFF_VIDEO - Import pages from a multipage grayscale
    %   tiff file as an MxNxO matrix where M is the height, N is the width,
    %   and O is the number of video frames (i.e. tiff pages)
    %
    % Inputs:
    %   srcTiffFilepath
    %     the filepath of the source tiff file
    %   maxNumFramesToLoad (optional; defaults to inf)
    %     the maximum number of video frames (i.e. tiff pages) to load
    %   fn_process_frame (optional; defaults to @im2double)
    %     the function that should be run on each of the frames of the
    %     video (to get it in the desired data type/scale)
    %     
    % Outputs:
    %   grayscaleVideo
    %     the MxNxO matrix where M is the height, N is the width,
    %     and O is the number of video frames (i.e. tiff pages)
    %   rawValueRange
    %     the range of values present in the raw imported video
    %   loadedFrameNums
    %     the page numbers of the frames that were loaded from the tiff
    %     file
    %   srcImfInfo
    %     information about the video graphics file
    %     
    % Authors:
    %   Saair Quaderi
    
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    
    if (nargin < 2) || isempty(maxNumFramesToLoad)
        maxNumFramesToLoad = inf;
    end
    
    if (nargin < 3) || isempty(fn_process_frame)
        fn_process_frame = @im2double;
    end

    srcImfInfo = imfinfo(srcTiffFilepath);
    frameCount = numel(srcImfInfo);
    if not(all(strcmp('grayscale', {srcImfInfo.ColorType})))
        error('Tiff frames must be grayscale');
    end
    
    frameHeights = [srcImfInfo.Height];
    frameWidths = [srcImfInfo.Width];
    frameHeight = frameHeights(1);
    frameWidth = frameWidths(1);
    
    if(any(frameHeights ~= frameHeight) || any(frameWidths ~= frameWidth))
        frameHeight = -mode(-frameHeights);
        frameWidth = -mode(-frameWidths);
        badFrameNums = find((frameHeights ~= frameHeight) | (frameWidths ~= frameWidth));
        loadedFrameNums = setdiff(1:min(maxNumFramesToLoad + numel(badFrameNums), frameCount), badFrameNums);
        warning('Inconsistent frame dimensions');
        loadedFrameNums = loadedFrameNums(1:min(length(loadedFrameNums), maxNumFramesToLoad));
    else
        loadedFrameNums = 1:min(frameCount, maxNumFramesToLoad);
    end
    
    minSampleValues = [srcImfInfo(loadedFrameNums).MinSampleValue];
    maxSampleValues = [srcImfInfo(loadedFrameNums).MaxSampleValue];
    rawValueRange = [minSampleValues(1), maxSampleValues(1)];
    if (any(minSampleValues ~= rawValueRange(1)) || any(maxSampleValues ~= rawValueRange(2)))
        error('Inconsistent potential frame value ranges');
    end
    
    numFramesToBeLoaded = numel(loadedFrameNums);
    if numFramesToBeLoaded == 0
        return;
    end
    if numFramesToBeLoaded == frameCount
        msgOnCompletion = sprintf('    Loaded all %d pages from the tiff\n', frameCount);
    else
        loadedFramesRangeStarts = loadedFrameNums([true, (diff(loadedFrameNums) ~= 1)]);
        loadedFramesRangeEnds = loadedFrameNums(fliplr([true, (diff(fliplr(loadedFrameNums)) ~= -1)]));
        loadedFramesStr = strjoin(cellfun(@(opts, isDupes) opts{1+isDupes},...
            arrayfun(@(startFrame, endFrame) {num2str(startFrame), [num2str(startFrame), '-', num2str(endFrame)]},...
                loadedFramesRangeStarts,...
                loadedFramesRangeEnds,...
                'UniformOutput', false),...
            arrayfun(@(x) x, loadedFramesRangeStarts ~= loadedFramesRangeEnds, 'UniformOutput', false),...
            'UniformOutput', false),', ');
        msgOnCompletion = sprintf('    Loaded %d of %d pages from the tiff %s\n', numFramesToBeLoaded, frameCount, loadedFramesStr);
    end

    progress_messenger = BasicTextProgressMessenger.get_instance();
    progress_messenger.init(sprintf(' Loading tiff pages from disk into grayscale movie...\n'));
    numFramesLoaded = 0;
    grayscaleVideo = zeros(frameHeight, frameWidth, 1, numFramesToBeLoaded);
    for frameNum=loadedFrameNums
        numFramesLoaded = numFramesLoaded + 1;
        readFrame = imread(srcTiffFilepath, frameNum, 'Info', srcImfInfo);
        grayscaleVideo(:, :, 1, numFramesLoaded) = fn_process_frame(readFrame);
        progress_messenger.checkin(numFramesLoaded, numFramesToBeLoaded);
    end
    progress_messenger.finalize(msgOnCompletion);
end