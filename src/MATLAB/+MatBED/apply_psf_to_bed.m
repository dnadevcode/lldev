function [] = apply_psf_to_bed(pixelWidth_nm, psfSigmaWidth_nm, dnaStretchingFactor)
    % bedgraph format description:
    %  https://genome.ucsc.edu/goldenpath/help/bedgraph.html


    if nargin < 1
        pixelWidth_nm = 1000
    end
    if nargin < 2
        psfSigmaWidth_nm = 300
    end
    if nargin < 3
        dnaStretchingFactor = 0.85
    end
    
    
    [filenameBED, dirpath] = uigetfile({'*.bed'},'Select BED files', 'Multiselect', 'off');
    if isequal(dirpath, 0)
        error('Expected a BED file');
    end
    filepathBED = fullfile(dirpath, filenameBED);
        
    
    [fileErrMsg, fileContents] = get_BED_data(filepathBED);
    if not(isempty(fileErrMsg))
        error(fileErrMsg);
    end

    seqLength = get_seq_length(minLength);
    probSeq = get_probs(fileContents, seqLength);
    bpLength_nm = 0.34 * dnaStretchingFactor;
    psfSigmaWidth_bp = psfSigmaWidth_nm/bpLength_nm;
    amplitudeModulation_bpRes = apply_point_spread_function(probSeq, psfSigmaWidth_bp);
    bpLength_pixels = (bpLength_nm/pixelWidth_nm);
    [amplitudeModulation_pixelRes] = apply_stretching(amplitudeModulation_bpRes, bpLength_pixels);
    
    
    
    function seqLength = get_seq_length(minLength)
        isValid = false;
        while not(isValid) 
            seqLength = str2double(input(...
                sprintf('Please enter the number of basepairs in the sequence (integer >= %d): ', minLength),...
                's'));
            isValid = (fix(seqLength) ~= seqLength) || length(seqLength) ~= 1 || (seqLength < minLength);
        end
    end
    
    function get_probs(fileContents, seqLength)
        fileBodyTable = fileContents{1, 'bodyData'};
        fileBodyTable = fileBodyTable{1};
        chromStarts = fileBodyTable.chromStarts;
        chromEnds = fileBodyTable.chromEnds;
        
        idxsStart = chromStarts + 1; %zero-indexed to one-indexed
        idxsEnd = chromEnds; %already one-indexed
    end


    function [fileErrMsg, fileContents] = get_BED_data(filepathBED)
        fid = fopen(filepathBED, 'r');
        fileLines = textscan(fid,'%s','Delimiter','\n');
        fileLines = fileLines{1};
        fclose(fid);

        numLines = length(fileLines);
        inHeader = true;
        lineNum = 1;
        while inHeader && (lineNum <= numLines)
            strLine = fileLines{lineNum};
            [isHeaderLine, headerLineType] = is_header_line(strLine);
            inHeader = isHeaderLine;
            lineNum = lineNum + 1;
        end
        fileHeaderLines = fileLines(1:(lineNum - 1));
        bodyLines = fileLines(lineNum:end);
        fileBodyTable = table([], [], [],...
            'VariableNames',{'chrom', 'chromStarts', 'chromEnds'});

        fieldEntriesStrs = regexp(bodyLines, {'\s'}, 'split');
        numFieldsInLines = cellfun(@length, fieldEntriesStrs);
        numFields = numFieldsInLines(1);
        fileErrMsg = [];
        chrom = cell(0, 1);
        chromStarts = NaN(0, 1);
        chromEnds = NaN(0, 1);
        if numFields < 3
            fileErrMsg = 'Missing required fields';
        elseif any(numFields ~= numFieldsInLines)
            fileErrMsg = 'Inconsisent number of fields';
        elseif numFields > 3
            fileErrMsg = 'This program does not yet support more than the three required fields';
        else
            fieldEntriesStrs = vertcat(fieldEntriesStrs{:});
            fieldEntries = fieldEntriesStrs;
            chrom = fieldEntries(:, 1);
            fieldEntries(:, 2) = cellfun(@(chromStartStr) uint64(str2double(chromStartStr)), fieldEntriesStrs(:, 2), 'UniformOutput', false);
            if  not(isequal(fieldEntriesStrs(:, 2), cellfun(@num2str, fieldEntries(:, 2), 'UniformOutput', false)))
                fileErrMsg = 'Invalid entries for chromStart';
            else
                fieldEntries(:, 3) = cellfun(@(chromEndStr) uint64(str2double(chromEndStr)), fieldEntriesStrs(:, 3), 'UniformOutput', false);
                if  not(isequal(fieldEntriesStrs(:, 3), cellfun(@num2str, fieldEntries(:, 3), 'UniformOutput', false)))
                    fileErrMsg = 'Invalid entries for chromEnd';
                else

                    chromStarts = cell2mat(fieldEntries(:, 2));
                    chromEnds = cell2mat(fieldEntries(:, 3));

                    if any(chromEnds <= chromStarts)
                        chrom = cell(0, 1);
                        chromStarts = NaN(0, 1);
                        chromEnds = NaN(0, 1);
                        fileErrMsg = 'Inconsistency between entries for chromStart and chromEnd';
                    end

                    if any(chromEnds >= uint64(flintmax('double')))
                        fileErrMsg = ['This program does not support integer values larger than ', num2str(flintmax('double') - 1)];
                    end
                end
            end
            
            fileBodyTable = table(chrom, chromStarts, chromEnds,...
                'VariableNames',{'chrom', 'chromStarts', 'chromEnds'});
        end
        fileContents= table(...
            {filepathBED},...
            {fileErrMsg},...
            {fileHeaderLines},...
            {fileBodyTable},...
            'VariableNames',...
            {'filepath'; 'errMsgs'; 'headerLines'; 'bodyData'});
    end



    function [vectOut] = sample_interp_to_len(vectIn, vectOutLen, interpMethod)
        % SAMPLE_INTERP_TO_LEN - interpolates the vector such that the output
        %   vector is of a specified length and has the same first and last
        %   data points
        %
        % Inputs:
        %   vectIn
        %     input vector of real finite numbers to be interpolated
        %   vectOutLen
        %     the length of the output vector (must be > 1)
        %   interpMethod (optional, defaults to 'linear')
        %     the interpolation method for interp1
        %     the available methods are:
        %  
        %        'linear'   - (default) linear interpolation
        %        'nearest'  - nearest neighbor interpolation
        %        'next'     - next neighbor interpolation
        %        'previous' - previous neighbor interpolation
        %        'spline'   - piecewise cubic spline interpolation (SPLINE)
        %        'pchip'    - shape-preserving piecewise cubic interpolation
        %        'cubic'    - same as 'pchip'
        %        'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
        %                     extrapolate and uses 'spline' if X is not equally
        %                     spaced.
        % 
        % Outputs:
        %   vectOut
        %     the output vector of length vectOutLen containing the
        %     interpolation of the input vector
        %
        % Authors:
        %   Saair Quaderi

        validateattributes(vectIn, {'numeric'}, {'vector', 'real', 'finite'}, 1);
        vectInLen = length(vectIn);
        if vectInLen < 2
            error('Input vector must contain at least two datapoints');
        end
        validateattributes(vectOutLen, {'numeric'}, {'scalar', 'integer', '>', 1}, 2);
        if nargin < 3
            interpMethod = 'linear';
        end
        if vectOutLen == vectInLen
            vectOut = vectIn;
        else
            vectOut = interp1(vectIn, linspace(1, vectInLen, vectOutLen), interpMethod);
        end
    end
    
    function [vectOut, stretchFactor] = apply_stretching(vectIn, approxStretchFactor)
        % APPLY_STRETCHING - interpolates the vector such that the output
        %   vector is of a length that is of the integer length closest to the 
        %   input vector's length multiplied by an approximate stretch factor
        % 
        % Inputs:
        %   vectIn
        %     input vector of real finite numbers to be interpolated
        %   approxStretchFactor
        %     the factor by which to stretch the vector's length to after
        %     rounding the output vector length to the nearest integer
        %     
        % Outputs:
        %   vectOut
        %     the output vector of length vectOutLen containing the
        %     interpolation of the input vector
        %   stretchFactor
        %     the actual ratio between the output vector's length and the input
        %     vector's length
        %
        % Authors:
        %   Saair Quaderi

        oldVectLen = length(vectIn);
        newVectLen = round(oldVectLen*approxStretchFactor);
        vectOut = sample_interp_to_len(vectIn, newVectLen);
        stretchFactor = newVectLen/oldVectLen;
    end
    
    function [probPostPSF] = apply_point_spread_function(probSeq, psfSigmaWidth)
        % APPLY_POINT_SPREAD_FUNCTION - Performs convolution of a
        %   one-dimensional probability curve with a one-dimensional gaussian
        %   filter kernel representing the camera's point spread function
        %
        % Inputs:
        %   probSeq
        %     Probability values from 0 to 1 for the presence of fluorescence
        %     coming from the one-dimensional position
        %     (e.g. probability of YOYO1 binding to a given basepair along a
        %     linearized DNA sequence)
        %   psfSigmaWidth
        %     The width of a single sigma (mean to a standard deviation from
        %     the mean) of the one-dimensional gaussian distribution that the
        %     probSeq is to beconvolved with.
        %     The unit-length is defined as equivalent to the positional
        %     difference between adjacent values in the probSeq
        %
        % Outputs:
        %   probPostPSF
        %     the convolution of the probability sequence with the point spread
        %     function
        %
        % Authors:
        %   Saair Quaderi
        
        probSeq = probSeq(:)';

        % psfStdWidth must be at same resolution as
        %  indices of probCurvePrePSF (e.g. basepair resolution)

        %%%%% Perform Gaussian convolution on the theory curve.
        widthSigmasFromMean = 4; %+/- 4 standard deviations from mean
        nonzeroKernelLen = widthSigmasFromMean*2*psfSigmaWidth;
        nonzeroKernelLen = round((nonzeroKernelLen - 1)/2)*2 + 1; % round to nearest odd integer

        probSeqLen = length(probSeq);
        % Zero-pad sequence probabilities to prevent wrap-around influence
        % from circular convolution
        probSeq = padarray(probSeq, [0, nonzeroKernelLen]);

        curveLength = length(probSeq);

        % create point spread function kernel
        psfKernel = zeros(size(probSeq));
        psfKernel(ceil((curveLength - nonzeroKernelLen)/2) + (1:nonzeroKernelLen)) = fspecial('gaussian', [1, nonzeroKernelLen], psfSigmaWidth);

        % shift 50% so that the first and last index are at the peak of the gaussian
        psfKernel = fftshift(psfKernel);

        % Compute results from circular convolution
        probPostPSF = cconv(probSeq, psfKernel, curveLength);

        % Extract results out of padded results
        probPostPSF = probPostPSF(nonzeroKernelLen + (1:probSeqLen));
    end
    
    
    
end