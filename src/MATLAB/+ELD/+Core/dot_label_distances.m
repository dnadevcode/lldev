function [ resultStruct ] = dot_label_distances(kymo,theorySequence,matchSequence,settings,backgroundSubtraction)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 1 || isempty(kymo)

        import ELD.Import.import_tiff_img
        kymo = import_tiff_img();
        
    end
    
%     if nargin < 2 || isempty(minOverlap)
%         minOverlap = 5;
%     end
%     
%     if nargin < 3 || isempty(confidenceInterval)
%         confidenceInterval = 2;
%     end
    
    if nargin < 2 || isempty(theorySequence)

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
    
    end
    
    if nargin < 3 || isempty(matchSequence)
        
        prompt = {'Enter the target sequence:'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'TCGA'};
        matchSequence = inputdlg(prompt,dlg_title,num_lines,defaultans);
        matchSequence = matchSequence{1};
             
    end
    
    if nargin < 4 || isempty(settings)
        import ELD.Import.load_eld_kymo_align_settings;
        settings = load_eld_kymo_align_settings();
    end
    
    if nargin < 5 || isempty(backgroundSubtraction)
        backgroundSubtraction = false;
    end
    
    for bp = 1:length(matchSequence)
        if matchSequence(bp) ~= 'A' && matchSequence(bp) ~= 'T' && ...
                matchSequence(bp) ~= 'C' && matchSequence(bp) ~= 'G'
            disp('Incorrect Target Sequence.');
            return;
        end
    end

    import ELD.Core.get_feature_distances;
    [featuresCellArray_ordered, feature_distances, feature_distance_variances] = get_feature_distances(kymo,settings,backgroundSubtraction);
    
    if isempty(featuresCellArray_ordered)
        resultStruct = [];
        return;
    end
    
    import ELD.Core.get_color_map;
    colorImgs = get_color_map(featuresCellArray_ordered, size(kymo));

    dotWidthsTheory = settings.theoryDotWidth;
    barcodeLength = settings.theoreticalBarcodeLength;
    maxNumExcludedFluorophores = settings.maxNumExcludedFluorophores;

    import ELD.Core.find_dot_positions_on_sequence;
    dotPositionsTheory = find_dot_positions_on_sequence(theorySequence,matchSequence);
    
    molecule_ends = [0 length(theorySequence)];

    import ELD.Core.calculate_label_positions;
    [feature_positions, feature_position_variances] = calculate_label_positions( feature_distances, feature_distance_variances );


    import ELD.Core.find_optimal_dot_barcode_orientation;
    [feature_positions_norm, feature_position_variances_norm, dotPositionsTheory, molecule_ends, flipped] = find_optimal_dot_barcode_orientation( ...
        dotPositionsTheory,molecule_ends,dotWidthsTheory,feature_positions,feature_position_variances, ...
        barcodeLength,maxNumExcludedFluorophores);
        
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
    resultStruct.molecule_flip = flipped;
    
    if exist('MoleculeHeader')
        resultStruct.molecule_header = MoleculeHeader;
    end
    
end

