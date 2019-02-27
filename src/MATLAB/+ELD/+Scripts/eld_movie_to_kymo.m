% We begin by running ELD Movie to kymo

folder = '/home/albyback/git/Projects/ELD/Tif files - FSHD fluctuations in nanochannels/Original crops/';

%folder = '/home/albyback/git/Projects/ELD/Tif files - FSHD fluctuations in nanochannels/Corrected crops/';


% import Microscopy.cleanup_movie;
% [tmp_movie.cleaned, details.cleanup] = cleanup_movie(double(A{1}.img));



%% MOVIE TO KYMOGRAPH

%% Load settings
kymoFold = '/home/albyback/git/Projects/ELD/Tif files - FSHD fluctuations in nanochannels/Original crops/';
[ sets ] = ELD.Scripts.eld_sets(kymoFold);
%% Load movies
loadedMovies =  ELD.Import.import_movies( sets.kymoFold );
%% Correct movies for hot and dead pixels
[correctedMovies,movieMasks] = cellfun(@(x) ELD.Processing.correct_movies(x.img,sets), loadedMovies,'UniformOutput',false);
% https://stackoverflow.com/questions/29833068/filter-image-that-contains-nans-in-matlab
% perhaps relevant?

fold = '/home/albyback/git/Projects/ELD/';
cellfun(@(x) ELD.Export.export_movie(x,fold),correctedMovies);

montageArray =  [correctedMovies{1}(:,:,1); zeros(1,size(correctedMovies{1},2)); correctedMovies{1}(:,:,250) ;zeros(1,size(correctedMovies{1},2)) ;correctedMovies{1}(:,:,500) ;zeros(1,size(correctedMovies{1},2));correctedMovies{1}(:,:,750)];
%montageArray =  correctedMovies{1}(:,:,1);
montage(montageArray);
 fig=gcf;ax=fig.CurrentAxes;fig.Color='w';fig.OuterPosition=fig.InnerPosition;
 set(gca,'position',[0 0 1 1],'units','normalized')
%% Rotate movies
  [rotatedMovie,rotatedAmp, movieAngle] =  cellfun(@(x) ELD.Processing.rotate_movie(x,sets), correctedMovies,'UniformOutput',false);
  
%% Detect channels. Only one per movie. Could change this with allowing user to select how many?
  [channelLabeling] =  cellfun(@(x) ELD.Processing.extract_channels(x,sets), rotatedAmp,'UniformOutput',false);

 %% Extract channel kymo/ background
 ff = '/home/albyback/git/Projects/ELD/kymo_nr_';
 [kymos, background, kymosAmp] =  ELD.Processing.extract_kymos(channelLabeling,rotatedMovie,rotatedAmp,ff );

% kymos = background;
%% Preprocess kymograph - matched filter
 %https://se.mathworks.com/help/phased/ug/matched-filtering.html
[filteredKymos] =  cellfun(@(x) ELD.Processing.match_filter_kymo(x,sets), kymos,'UniformOutput',false);
for i=1:length(filteredKymos)
    kymoo =uint16(filteredKymos{i});
    fold = strcat([ff 'filtered_' num2str(i) '.tif']);
    imwrite(im2uint16(kymoo),fold);
end
% 
% idx=1;
% idx2= 6;
% figure,
% plot(kymos{idx2}(idx,: ))
% hold on
% plot(filteredKymos{idx2}(idx,:))
% xlabel('Pixel index')
% ylabel('Pixel intensity')
% 
% figure,plot(kymosAmp{5}(1,:))

%     
% fold = '/home/albyback/git/Projects/ELD/filt';
% cellfun(@(x) ELD.Export.export_movie(x,fold),filteredKymos);

 %% Import sequences
 theorySeq = fastaread('/home/albyback/git/Projects/ELD/sequenceDot.fasta' );
 
 % find sequence matches
import ELT.Core.find_sequence_matches;
[bindingExpectedMask, numberOfBindings] = find_sequence_matches(sets.targetSequence, theorySeq.Sequence);

% length of kernel
hsize = size(bindingExpectedMask,2);

sigma =130/0.3;
% kernel
ker = circshift(images.internal.createGaussianKernel(sigma, hsize),round(hsize/2));   

% conjugate of kernel in phase space
multF=conj(fft(ker'));

% convolved with sequence ->
outpMap = ifft(fft(bindingExpectedMask).*multF); 

figure,plot(outpMap)
figure,plot(filteredKymos{1}(1,:))
figure,plot(fliplr(filteredKymos{4}(1,:)))

%% Peak detection
%[filteredKymos] =  cellfun(@(x) ELD.Processing.match_filter_kymo(x,sets), kymos,'UniformOutput',false);
%[ peakMap ] = cellfun(@(x) ELD.Labelling.run_peak_detection( x ), filteredKymos,'UniformOutput',false);
 %
 %% Labelling
 bcgr = cell(1,2);
bcgr{1} =mean(background{1}');
bcgr{2} = std(double(background{1}'));
  ELD.Processing.extract_labels( filteredKymos{1},bcgr,sets );
 [featuresCellArray_processed, fD,fdV ] =  cellfun(@(x) ELD.Processing.extract_labels( x,sets ), filteredKymos,'UniformOutput',false);

 
%         
% import ELD.Core.find_dot_positions_on_sequence;
% dotPositionsTheory = find_dot_positions_on_sequence(theorySeq.Sequence,sets.targetSequence);


% sigma = [2,2];
% volSmooth = imgaussfilt(correctedMovies{1}(:,:,1), sigma);
% figure,imshow(volSmooth,[])
% 
% waveform = phased.LinearFMWaveform('PulseWidth',1e-4,'PRF',5e3,...
%     'SampleRate',1e6,'OutputFormat','Pulses','NumPulses',1,...
%     'SweepBandwidth',1e5);
% wav = getMatchedFilter(waveform);
% filter = phased.MatchedFilter('Coefficients',wav);
% taylorfilter = phased.MatchedFilter('Coefficients',wav,...
%     'SpectrumWindow','Taylor');