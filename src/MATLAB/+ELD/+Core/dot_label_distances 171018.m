function [ resultStruct ] = dot_label_distances(kymo,minOverlap,confidenceInterval,theorySequence,matchSequence,settings,backgroundSubtraction)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%     import dotkymoAlignment.*

    if nargin < 1 || isempty(kymo)
%         [kymoFilenames, dirpath] = uigetfile('*.tif', 'Select mat-file with unaligned kymograph(s)', 'Multiselect', 'off');
%         aborted = isequal(dirpath, 0);
%         if aborted
%             return;
%         end
%    
%         kymoFilepath = fullfile(dirpath, kymoFilenames);

        import ELD.Import.import_tiff_img
        kymo = import_tiff_img();
        
%         input = load(kymoFilepath);
%         input = input.processedKymo;
%         kymoImgArrs = arrayfun(@(input) input.kymo_dynamicMeanSubtraction,input,'uniformoutput',false);
%         kymoImgArrs = arrayfun(@(input) input.kymo_noSubtraction,input,'uniformoutput',false);
    
%     else
%         if isstruct(input)
%             input = input.processedKymo;
%             kymoImgArrs = arrayfun(@(input) input.kymo_dynamicMeanSubtraction,input,'uniformoutput',false);
%         else
%             kymoImgArrs = input;
%         end
    end
    
%     disp([num2str(length(kymoImgArrs)) ' molecules detected.']);
    
    if nargin < 2 || isempty(minOverlap)
        minOverlap = 5;
    end
    
    if nargin < 3 || isempty(confidenceInterval)
        confidenceInterval = 2;
    end
    
    if nargin < 4 || isempty(theorySequence)

%         [theoryFilename, dirpath] = uigetfile({'*.mat;*.fasta','Sequence files (*.mat, *.fasta)';...
%             '*.mat','.MAT-files (*.mat)','*.fasta','FASTA-files (*.fasta)'},...
%             'Select file with theoretical sequence', 'Multiselect', 'off');
        [theoryFilename, dirpath] = uigetfile( ...
        {  '*.mat;*.fasta','Sequence files (*.mat, *.fasta)'; ...
           '*.mat','MAT-files (*.mat)'; ...
           '*.fasta', 'FASTA-files (*.fasta)'}, ...
           'Select file with theoretical sequence', ...
           'MultiSelect', 'off');
        
        aborted = isequal(dirpath, 0);
        if aborted
            return;
        end
    %     if not(iscell(kymoFilenames))
    %         kymoFilenames = {kymoFilenames};
    %     end
        dot = regexp(theoryFilename,'\.');
        switch(theoryFilename(dot+1:end))
            
        case 'mat'
            theoryFilepath = fullfile(dirpath, theoryFilename);

            theoryData = load(theoryFilepath);
            theoryData = theoryData.theoreticalData;

            theorySequence = theoryData.completeDNASequence;
            
        case 'fasta'
            theoryFilepath = fullfile(dirpath, theoryFilename);
            [MoleculeHeader, theorySequence] = fastaread(theoryFilepath);
            
            otherwise
            disp('Cannot process file type. Please use a .mat or .fasta file.')
        end
    
%         theoryFilepath = fullfile(dirpath, theoryFilename);
% 
%         input = load(theoryFilepath);
%         input = input.theoreticalData;
%         
%         theorySequence = input.completeDNASequence;

%     else
%         if isstruct(kymo)
%             kymo = kymo.theoreticalData;
%             theorySequence = kymo.completeDNASequence;
%         else
%             theorySequence = kymo;
%         end
%         
    end
    
    if nargin < 5 || isempty(matchSequence)
        
        prompt = {'Enter the target sequence:'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'TCGA'};
        matchSequence = inputdlg(prompt,dlg_title,num_lines,defaultans);
        matchSequence = matchSequence{1};
             
    end
    
    if nargin < 6 || isempty(settings)
        import ELD.Import.load_eld_kymo_align_settings;
        settings = load_eld_kymo_align_settings();
    end
    
    for bp = 1:length(matchSequence)
        if matchSequence(bp) ~= 'A' && matchSequence(bp) ~= 'T' && ...
                matchSequence(bp) ~= 'C' && matchSequence(bp) ~= 'G'
            disp('Incorrect Target Sequence.');
            return;
        end
    end
    
%     numKymos = length(kymoImgArrs);
%     numKymos = 1;
    
%     kymoImgArrs = kymoImgArrs(2);

    import ELD.Core.get_feature_distances;
%     
    [featuresCellArray_ordered, feature_distances, feature_distance_variances] = get_feature_distances(kymo,minOverlap,confidenceInterval,settings,backgroundSubtraction);
    
    if isempty(featuresCellArray_ordered)
        resultStruct = [];
        return;
    end
    
    import ELD.Core.get_color_map;
    colorImgs = get_color_map(featuresCellArray_ordered, size(kymo));
%     for kymo = 1:numKymos
%         figure, imagesc(colorImgs{kymo});
%     end
    
%     featureWidth = 7;
    
%     featureIntensityTraces = get_feature_intensity_traces( kymoImgArrs , featuresCellArray_ordered , featureWidth );
    
%     featureIntensityTraces = cell(numKymos,1);
    
%     for kymo = 1:numKymos
%         for feature = 1:length(featuresCellArray_ordered{kymo})
%             featureImg = zeros(size(kymoImgArrs{kymo}));
%             for row = 1:size(featuresCellArray_ordered{kymo}{feature},1)
%                 featureImg(featuresCellArray_ordered{kymo}{feature}(row,1),featuresCellArray_ordered{kymo}{feature}(row,2)) = 1;
%             end
%             featureImg = imdilate(featureImg,ones(1,7));
%             featureImg = kymoImgArrs{kymo}.*featureImg;
%             
%             featureImg(featureImg == 0) = NaN;
%             featureIntensityTraces{kymo}{feature} = nanmean(featureImg,2);
%             
%             figure, plot(featureIntensityTraces{kymo}{feature});
%         end
%     end

%     dotWidthsTheory = 1;
%     barcodeLength = 500;
%     maxNumExcludedFluorophores = 2;

    dotWidthsTheory = settings.theoryDotWidth;
    barcodeLength = settings.theoreticalBarcodeLength;
    maxNumExcludedFluorophores = settings.maxNumExcludedFluorophores;

%     molecule_ends = [0 500];
    
    import ELD.Core.find_dot_positions_on_sequence;
    dotPositionsTheory = find_dot_positions_on_sequence(theorySequence,matchSequence);
    
%     [dotPositionsTheoryShifted , stretchFactor] = calculate_shifted_dot_positions_with_margins(dotPositionsTheory,barcodeLength);
%     theoreticalDotBarcode = generate_barcode_from_dot_positions(dotPositionsTheoryShifted,dotWidthsTheory,[0 barcodeLength]);
    
    molecule_ends = [0 length(theorySequence)];
%     dotPositionsTheory = [ 0 dotPositionsTheory  length(theorySequence)];
%     dotPositionsTheory = (dotPositionsTheory - dotPositionsTheory(2)) * stretchFactor + dotPositionsTheoryShifted(1);
        
%     theoreticalDotBarcode = generate_theoretical_dot_barcode(theorySequence,matchSequence,dotWidth,barcodeLength);
    
%     figure, plot(theoreticalDotBarcode);
    

%     feature_positions = cell(numKymos,1);
%     feature_position_variances = cell(numKymos,1);
%     dot_barcode = cell(numKymos,1);
    
%     for kymo = 1:numKymos
        import ELD.Core.calculate_label_positions;
        [feature_positions, feature_position_variances] = calculate_label_positions( feature_distances, feature_distance_variances );
%         [feature_positions{kymo}, stretchFactor] = calculate_shifted_dot_positions_with_margins(feature_positions{kymo},barcodeLength);
        
%         feature_position_variances{kymo} = feature_position_variances{kymo} * stretchFactor;
        
%         dot_barcode{kymo} = generate_barcode_from_dot_positions(feature_positions{kymo},sqrt(feature_position_variances{kymo}),[0 barcodeLength]);
        
%         figure, plot(dot_barcode{kymo});
        
%         flippedBarcode = fliplr(dot_barcode{kymo}');
        
        import ELD.Core.find_optimal_dot_barcode_orientation;
        [feature_positions_norm, feature_position_variances_norm, dotPositionsTheory, molecule_ends, flipped] = find_optimal_dot_barcode_orientation( ...
            dotPositionsTheory,molecule_ends,dotWidthsTheory,feature_positions,feature_position_variances, ...
            barcodeLength,maxNumExcludedFluorophores);
        
%         corrUnflipped = xcorr(theoreticalDotBarcode',dot_barcode{kymo}',0);
%         corrFlipped = xcorr(theoreticalDotBarcode',flippedBarcode,0);
%         
%         [~,best_idx{kymo}] = max([corrUnflipped corrFlipped]);
        
%         if best_idx{kymo} == 2
%             dot_barcode{kymo} = flippedBarcode;
%             feature_positions{kymo} = barcodeLength - feature_positions{kymo}';
%             feature_position_variances{kymo} = fliplr(feature_position_variances{kymo}');
%         else
%             feature_positions{kymo} = feature_positions{kymo}';
%             feature_position_variances{kymo} = feature_position_variances{kymo}';
%         end
        
%     end
    
    
    
    resultStruct = struct();
    resultStruct.feature_distances = feature_distances;
    resultStruct.feature_distance_vars = feature_distance_variances';
    resultStruct.feature_positions = feature_positions;
    resultStruct.feature_position_vars = feature_position_variances;
    resultStruct.feature_positions_norm = feature_positions_norm;
    resultStruct.feature_position_vars_norm = feature_position_variances_norm;    
    resultStruct.kymo_colormap = colorImgs;
    resultStruct.theory_dot_positions = dotPositionsTheory';
    resultStruct.theory_molecule_ends = molecule_ends;
%     resultStruct.comparison_fig = comparisonPlot;
    resultStruct.molecule_flip = flipped;
    
    if exist('MoleculeHeader')
        resultStruct.molecule_header = MoleculeHeader;
    end
    
    
    
end

