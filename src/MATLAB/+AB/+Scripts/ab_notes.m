% begin by loading default settings

[sets] = AB.Scripts.ab_sets();

idx = 1; % only one movie
sets.moviefilefold{idx} = '/home/albyback/rawData/dnaData/autobarcodingData/exp/2plex/';
sets.filenames{idx} = '2plex_block1_pt2_tile1.tif';

% load one of the movies
import AB.Processing.load_movie;
movie = load_movie(sets.moviefilefold{idx},sets.filenames{idx});

% scale to correct range, or keep the original?
movie3d = double(cat(3, movie{:}));
movie3d = uint16(((movie3d - min(movie3d(:)))./max(movie3d(:)))*(2^16-1));

%plot the slice
k=1;
slice = movie3d(:,:,k);
figure,imshow(slice);
% save the tif slice
imwrite(slice,strcat([sets.moviefilefold{idx} 'slice.tif' ]));        


% process movie by detecting the angle, rotating, detecting the
% background mask, connected components, and use this to extract 
import AB.Processing.preprocess_movie_for_kymo_extraction;
[kymosMolEdgeIdxs, movieRot, rRot, cRot, ccIdxs, ccStructNoEdgeAdj, rotationAngle] = preprocess_movie_for_kymo_extraction(movie3d, sets.preprocessing);

        