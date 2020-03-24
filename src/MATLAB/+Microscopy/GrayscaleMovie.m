classdef GrayscaleMovie < handle
    properties (Constant)
        Version = [0, 0, 1];
        
        DefaultStorageMode = Microscopy.GrayscaleMovieStorageMode.get_default_storage_mode();
        DefaultStaySlim = false;
        DefaultNrmMin = 0;
        DefaultNrmMax = 1;
        DefaultNrmMinRawVal = 0;
        DefaultNrmMaxRawVal = inf;
    end
    properties(SetAccess = private)
        
        % Since storing the data in both raw and normalized modes can be
        %  quite memory intensive, we can choose just one and use
        %  StorageMode to remember which version we are working with
        % GrayscaleMovieStorageMode:
        %   Raw: store accurate data in RawDataArr as non-negative integers
        %           (e.g. photon counts)
        %   Nrm: store accurate data in NrmDataArr as doubles in the range
        %            [GrayscaleMovie.NrmMin, GrayscaleMovie.NrmMax]
        %           mapping linearly to the range
        %            [NrmMinRawVal, NrmMaxRawVal]
        %           in the RawDataArr
        Context = [];
        
        StorageMode = Microscopy.GrayscaleMovie.DefaultStorageMode;
        
        StaySlim = Microscopy.GrayscaleMovie.DefaultStaySlim;

        NrmMin = Microscopy.GrayscaleMovie.DefaultNrmMin;
        NrmMax = Microscopy.GrayscaleMovie.DefaultNrmMax;
        NrmMinRawVal =  Microscopy.GrayscaleMovie.DefaultNrmMinRawVal;
        NrmMaxRawVal = Microscopy.GrayscaleMovie.DefaultNrmMaxRawVal;
        
        OutOfRangeIdxs = []; % linearized idxs for vals outside range specified by min and max
        
        RawDataArr = [];
        NrmDataArr = [];
    end
    methods
        function [gsMovObj] = GrayscaleMovie(gsMovC, rawDataArr, rawValRange)
            validateattributes(gsMovC, {'Microscopy.GrayscaleMovieContext'}, {'scalar'}, 1);
            
            try
                validateattributes(rawDataArr, {'double'}, {'ndims', 4, 'size', [NaN, NaN, 1, NaN], 'nonempty'}, 2);
            catch
                validateattributes(rawDataArr, {'double'}, {'ndims', 2, 'size', [NaN, NaN, 1, NaN], 'nonempty'}, 2);
            end
            
            if nargin < 3
                rawValRange = [];
            else
                validateattributes(rawValRange, {'numeric'}, {'increasing', 'nonnegative', 'integer', 'numel', 2}, 3);
            end
            if isempty(rawValRange)
                rawValRange = [min(rawDataArr(:)), max(rawDataArr(:))];
            end
            
            nrmMinRawVal = rawValRange(1);
            nrmMaxRawVal = rawValRange(2);
            
            outOfRangeIdxs = find(isnan(rawDataArr) | (rawDataArr < nrmMinRawVal) | (rawDataArr > nrmMaxRawVal));
            
            import Microscopy.GrayscaleMovieStorageMode;
            storageMode = GrayscaleMovieStorageMode.RawPure;
            
            gsMovObj.Context = gsMovC;
            gsMovObj.NrmMinRawVal = nrmMinRawVal;
            gsMovObj.NrmMaxRawVal = nrmMaxRawVal;
            gsMovObj.RawDataArr = rawDataArr;
            gsMovObj.OutOfRangeIdxs = outOfRangeIdxs;
            gsMovObj.StorageMode = storageMode;
        end
        
        function [storageMode] = get_storage_mode(gsMovObj)
            storageMode = gsMovObj.StorageMode;
        end
        
        function [] = normalize_storage(gsMovObj, nrmMin, nrmMax)
            if nargin < 2
                nrmMin = [];
            end
            if nargin < 3
                nrmMax = [];
            end
            
            import Microscopy.GrayscaleMovie;
            import Microscopy.GrayscaleMovieStorageMode;
            
            
            newStorageMode = GrayscaleMovieStorageMode.Normalized;
            oldStorageMode = gsMovObj.get_storage_mode();
            if (oldStorageMode == newStorageMode)
                return;
            end
            
            [~, rawDataArr, outOfRangeIdxs] = gsMovObj.try_get_data(GrayscaleMovieStorageMode.RawApprox);
            
            
            if isempty(nrmMin)
                nrmMin = gsMovObj.NrmMin;
            end
            if isempty(nrmMax)
                nrmMax = gsMovObj.NrmMax;
            end
            
            if not(isfinite(gsMovObj.NrmMinRawVal))
                nrmMinRawVal = min(rawDataArr(:));
            else
                nrmMinRawVal = gsMovObj.NrmMinRawVal;
            end
            if not(isfinite(gsMovObj.NrmMaxRawVal))
                nrmMaxRawVal = max(rawDataArr(:));
            else
                nrmMaxRawVal = gsMovObj.NrmMaxRawVal;
            end
            if not(nrmMaxRawVal > nrmMinRawVal)
                nrmMinRawVal = min(rawDataArr(:));
                nrmMaxRawVal = max(rawDataArr(:));
                if (nrmMaxRawVal == nrmMinRawVal)
                    nrmMaxRawVal = nrmMinRawVal + 1;
                end
            end
            
            import Microscopy.rescale_arr_data_vals
            nrmDataArr = rescale_arr_data_vals(rawDataArr, nrmMinRawVal, nrmMaxRawVal, nrmMin, nrmMax);
            
            playItSafe = (1 == 1);
            if playItSafe
                % don't think this property's value should change,
                %  but just in case there's some weird edge case in the future:
                outOfRangeIdxs = find(isnan(nrmDataArr) | (nrmDataArr < nrmMin) | (nrmDataArr > nrmMax));
            end
            
            gsMovObj.NrmDataArr = nrmDataArr;
            gsMovObj.NrmMin = nrmMin;
            gsMovObj.NrmMax = nrmMax;
            gsMovObj.NrmMinRawVal = nrmMinRawVal;
            gsMovObj.NrmMaxRawVal = nrmMaxRawVal;
            gsMovObj.StorageMode = newStorageMode;
            gsMovObj.OutOfRangeIdxs = outOfRangeIdxs;
            
            if gsMovObj.StaySlim
                % slim down the memory usage (at cost of retrieval speed if
                %  accessing data of a different storage mode, and/or
                %  accessibility of non-approximate pure raw data)
                gsMovObj.slimify(); 
            end
        end
        
        function [] = disable_stay_slim(gsMovObj)
            gsMovObj.StaySlim = false;
        end
        
        function [] = enable_stay_slim(gsMovObj)
            gsMovObj.slimify();
            gsMovObj.StaySlim = true;
        end
        
        function [] = slimify(gsMovObj)
            if not(isempty(gsMovObj.NrmDataArr)) && not(isempty(gsMovObj.RawDataArr))
                if (gsMovObj.StorageMode.is_normalized_mode())
                    gsMovObj.RawDataArr = NaN([0, 0, 1, 0]); %save memory, can get approximate raw data by denormalizing later
                elseif (gsMovObj.StorageMode.is_raw_mode())
                    gsMovObj.NrmDataArr = NaN([0, 0, 1, 0]); %save memory, can normalizing later when necessary
                end
            end
        end
        
        function [failMsg, boundedDataArr, actualDiffArr] = try_get_bounded_data(gsMovObj, storageModeDesired)
            
            if (nargin < 2)
                storageModeDesired = [];
            end
            if isempty(storageModeDesired)
                storageModeDesired = gsMovObj.StorageMode;
            end
            [failMsg, dataArr, outOfRangeIdxs] = gsMovObj.try_get_data(storageModeDesired);
            if any(failMsg)
                boundedDataArr = [];
                actualDiffArr = [];
                return;
            end
            if storageModeDesired.is_normalized_mode()
                boundedModeMin = gsMovObj.NrmMin;
                boundedModeMax = gsMovObj.NrmMax;
            else
                boundedModeMin = gsMovObj.NrmMinRawVal;
                boundedModeMax = gsMovObj.NrmMaxRawVal;
            end
            
            boundedDataArr = dataArr;
            boundedDataArr(outOfRangeIdxs) = max(boundedDataArr(outOfRangeIdxs), boundedModeMin);
            boundedDataArr(outOfRangeIdxs) = min(boundedDataArr(outOfRangeIdxs), boundedModeMax);
            actualDiffArr = dataArr - boundedDataArr;
        end
        
        function [] = try_play_ui(gsMovObj)
            import Microscopy.GrayscaleMovieStorageMode;
            [~, dataArr, ~] = gsMovObj.try_get_bounded_data(GrayscaleMovieStorageMode.Normalized);
            implay(dataArr);
        end
        
        function [failMsg, desiredDataArr, outOfRangeIdxs] = try_get_data(gsMovObj, storageModeDesired)
            if (nargin < 2)
                storageModeDesired = [];
            end
            if isempty(storageModeDesired)
                storageModeDesired = gsMovObj.StorageMode;
            else
                validateattributes(storageModeDesired, {'Microscopy.GrayscaleMovieStorageMode'}, {'scalar'}, 2);
            end
            
            failMsg = false;
            if storageModeDesired.is_normalized_mode()
                if gsMovObj.StorageMode.is_normalized_mode()
                    nrmDataArr = gsMovObj.NrmDataArr;
                    outOfRangeIdxs = gsMovObj.OutOfRangeIdxs;
                    
                    desiredDataArr = nrmDataArr;
                    return;
                end
                if gsMovObj.StorageMode.is_raw_mode()
                    rawDataArr = gsMovObj.RawDataArr;
                    nrmMinRawVal = gsMovObj.NrmMinRawVal;
                    nrmMaxRawVal = gsMovObj.NrmMaxRawVal;
                    nrmMin = gsMovObj.NrmMin;
                    nrmMax = gsMovObj.NrmMax;
                    
                    import Microscopy.rescale_arr_data_vals
                    nrmDataArr = rescale_arr_data_vals(double(rawDataArr), nrmMinRawVal, nrmMaxRawVal, nrmMin, nrmMax);
                    outOfRangeIdxs = find(isnan(nrmDataArr) | (nrmDataArr < nrmMin) | (nrmDataArr > nrmMax));
                    
                    desiredDataArr = nrmDataArr;
                    return;
                end
            end
            if storageModeDesired.is_pure_raw_mode()
                if gsMovObj.StorageMode.is_pure_raw_mode()
                    rawDataArr = gsMovObj.RawDataArr;
                    outOfRangeIdxs = gsMovObj.OutOfRangeIdxs;
                    
                    desiredDataArr = rawDataArr;
                    return;
                end
                % possible failure case where pure raw data is no longer
                % available but is requested specifically
                % note that if approx raw data is requested instead that
                % should succeed)
                failMsg = 'Pure raw data is not available (only approximate raw data can be provided)';
                desiredDataArr = [];
                outOfRangeIdxs = [];
                return;
            end
            if storageModeDesired.is_approx_raw_mode()
                if gsMovObj.StorageMode.is_raw_mode()
                    rawDataArr = gsMovObj.RawDataArr;
                    outOfRangeIdxs = gsMovObj.OutOfRangeIdxs;
                    
                    desiredDataArr = rawDataArr;
                    return;
                end
                if gsMovObj.StorageMode.is_normalized_mode()
                    nrmDataArr = gsMovObj.NrmDataArr;
                    nrmMinRawVal = gsMovObj.NrmMinRawVal;
                    nrmMaxRawVal = gsMovObj.NrmMaxRawVal;
                    nrmMin = gsMovObj.NrmMin;
                    nrmMax = gsMovObj.NrmMax;
                    import Microscopy.rescale_arr_data_vals
                    denrmDataArr = rescale_arr_data_vals(nrmDataArr, nrmMin, nrmMax, nrmMinRawVal, nrmMaxRawVal);
                    outOfRangeIdxs = find(isnan(denrmDataArr) | (denrmDataArr < nrmMinRawVal) | (denrmDataArr > nrmMaxRawVal));
                    
                    desiredDataArr = denrmDataArr;
                    return;
                end
            end
            % all potential cases should have been handled by now
            %  so this should be impossible to reach:
            failMsg = 'Unexpected case caused by some programming bug';
            desiredDataArr = [];
            outOfRangeIdxs = [];
            return;
        end
        
    end
end