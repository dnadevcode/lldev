function [ abStruct] = generate_kymos_from_movie(movie3d, kymoMolEdgeIdxs, rRot, cRot, movieFold, kymo, filename,sets )
% generate_kymos_from_movie

% :param movie3d: input movie, should be 3d array
% :param kymoMolEdgeIdxs: setting to process the movie
%
% :returns: kymos

% rewritten by Albertas Dvirnas
    
    %kymos = [];
 
    % unit test for extracting kymos
    
    % extracting kymos
    import AB.Processing.extract_kymos;
    [flattenedKymos,layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movie3d, rRot, cRot, kymoMolEdgeIdxs,kymo.avgL, sets);
    tmp_numKymos = length(layeredKymos);

        
   % end
    
	import AB.Processing.Helper.calc_disp_names;
   [ kymoDisplayNames,barcodeDisplayNames ] = calc_disp_names(tmp_numKymos, kymosCenterXYCoords);
     
    % Here we include barcode sorter, which tells us if the barcode was
    % good or bad

    % aligning flattened kymos
    fprintf('Aligning flattened kymos...\n');
    import AB.Processing.Helper.align_flattened_kymos;
    [ flattenedKymosAligned, kymoMasksAligned, stretchFactorsMats, alignmentSuccessTFs] = align_flattened_kymos( tmp_numKymos, flattenedKymos, kymosMasks  );
   
    % Saving kymos to a folder
    for i=1:length(flattenedKymos )
        fold = strcat([movieFold  kymoDisplayNames{i} '_' filename]); 
        flattenedKymos{i}(isnan(flattenedKymos{i})) = 0;
        AMIN = min(flattenedKymos{i}(:));
        AMAX = max(flattenedKymos{i}(:));
        image8Bit = uint8(255 * mat2gray(flattenedKymos{i},[AMIN AMAX]));  
        image8Bit(isnan(flattenedKymos{i})) = 0;
        
        %         % TODO: this is temporary hack to add noise to left and right. later change hca
%         % so that we don't need to detect edges there!
%         currRng = rng(); % so that current rng state can be restored
%         % temporarily set to produce predictable pseudorandom values for reproducibility
%         rng(rng(0, 'twister'));  
%         randVals = randn([size(abStruct.flattenedKymos{1},1), 50]) .*3* nanstd(movieRot(:)) + nanmean(movieRot(:));
%         rng(currRng); % restore rng state
%         for i=1:length(abStruct.flattenedKymos)
%             abStruct.flattenedKymos{i} = [randVals abStruct.flattenedKymos{i} randVals];
%         end
     %   image8Bit= [zeros(size(image8Bit,1),50) image8Bit zeros(size(image8Bit,1),50)];

        imwrite(image8Bit,fold);
    end
    
    
    fprintf('Generating aligned kymo stats and barcodes...\n');
    tic
    import AB.Processing.Helper.aligned_kymo_stats;
    [ meanAlignedKymos,stdAlignedKymos ,meanAlignedMask,barcodeEdges, barcodes, backgrounds ] = aligned_kymo_stats(flattenedKymosAligned,kymoMasksAligned, tmp_numKymos );
	fprintf('Generated aligned kymo stats and barcodes\n');
    toc
    
    fprintf('Saving results to workspace...\n');
    tic

    %--------- FORMAT RESULTS
    import Fancy.Utils.var2struct;
    % Hack to save all variables in current workspace as fields in a struct
    vars_to_save = feval(@(allvars) allvars(~strncmp('tmp_', allvars, 4)), who());
    abStruct = eval(['var2struct(', strjoin(vars_to_save, ', '),');']);
	%assignin('base','abStruct',abStruct)

    %#ok<*ASGLU>
    
    toc

end

