% AB_Run. Runs auto-barcoding without ever going into GUI windows.

% Written by Albertas Dvirnas

% load settings
[sets] = AB.Scripts.ab_sets();
sets.moviefilefold{1} = '/home/albyback/git/Projects/hca/hca_tests/test_things/data/';
sets.filenames{1} = 'P18_170607_OD4_100msExp_28.tif';

 %% load movie
 tic
 import AB.Processing.load_movie;
 movie = load_movie(sets.moviefilefold{1},sets.filenames{1});  
 %mm = cell2mat(movie);
 toc
%  
%  %% process this movie
%  
% % do we want to save this as an object? Might be nicer way to access things,
% % but very hard for readability and probably overcomplicating things. 
% % still, keep in mind having class for this.
% import AB.Processing.graymovie;
% gsMovObj = graymovie(movie);
            

%% NORMALIZE
% why would we need to normalize the movie, what do we mean by normalizing?

%% PREPROCESS
import AB.Processing.preprocess_movie_for_kymo_extraction;
[kymosMolEdgeIdxs, movieRot, rRot, cRot, ccIdxs, ccStructNoEdgeAdj, rotationAngle] = preprocess_movie_for_kymo_extraction(double(cat(3, movie{:})), sets.preprocessing);

fprintf('Translating kymograph edge coordinates\n');

% coordinates in the original movie
import AB.Processing.translate_kymos_edge_coords;
kymosEdgePts = translate_kymos_edge_coords(kymosMolEdgeIdxs, rRot, cRot);

    

import AB.Processing.extract_kymos;
[layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(double(cat(3, movie{:})), rRot, cRot, kymosMolEdgeIdxs,sets.kymo.avgL);

flattenedKymos = cell(length(layeredKymos), 1);
for tmp_kymoIdx = 1:length(layeredKymos)
    tmp_layeredKymo = layeredKymos{tmp_kymoIdx};
    tmp_flatKymo = mean(tmp_layeredKymo, 3);
    flattenedKymos{tmp_kymoIdx} = tmp_flatKymo;
end

    
    
 % normalized movie
import AB.Core.run_movie_processing;
[tsCurrMov, barcodes, barcodeDisplayNames, mprs] = run_movie_processing(tsAB, movieDisplayName, gsMovObj, settings);
            
    
    %%
 
import AB.Core.run_movie_processing;
[tsCurrMov, barcodes, barcodeDisplayNames, mprs] = run_movie_processing(tsAB, movieDisplayName, gsMovObj, settings);
           
            
import AB.UI.get_valid_settings;
[successTF, settings] = get_valid_settings(settings);