function [rawDataArr, rawValRange, gsMovC] = import_single_unbroken_tiff_vid_segment(srcTiffFilepath)
    itemSelectionTime = clock();
    import Microscopy.Import.import_grayscale_tiff_video;
    [ ...
        fullRawDataArr, ...
        rawValRange, ...
        srcFrameIdxs ...
        ] = import_grayscale_tiff_video(srcTiffFilepath, [], @(x) x);

    itemImportTime = clock();
    
    if not(isa(fullRawDataArr, 'double'))
        fullRawDataArr = double(fullRawDataArr);
    end
    rawValRange = double(rawValRange);

    import Microscopy.Utils.segment_nonadj_data;
    [~, frameIdxRangesMat] = segment_nonadj_data(srcFrameIdxs);
    rangeLens = diff(frameIdxRangesMat, [], 2) + 1;
    [~, maxRangeLenIdx] = max(rangeLens);

    maxLenFrameRange = frameIdxRangesMat(maxRangeLenIdx, 1:2);


    % if frame pages were skipped for some reason, this gets the
    % largest contiguous block of movie data with no skipped frames
    rowRange = [1, size(fullRawDataArr, 1)];
    colRange = [1, size(fullRawDataArr, 2)];
    rawDataArr = fullRawDataArr(...
        rowRange(1):rowRange(2), ...
        colRange(1):colRange(2), ...
        1, ...
        maxLenFrameRange(1):maxLenFrameRange(2));
    frameRange = maxLenFrameRange;
    import Microscopy.MovieCropping;
    cropContext = MovieCropping(rowRange, colRange, frameRange);


    import Fancy.AppMgr.ImportItemContext;
    importItemContext = ImportItemContext(srcTiffFilepath, itemSelectionTime, [], itemImportTime);
    import Microscopy.GrayscaleMovieContext;
    gsMovC = GrayscaleMovieContext(importItemContext, cropContext);
end