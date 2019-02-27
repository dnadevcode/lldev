function [peakMap, peakLocs ,peakHeightsMap , peakHeights ] = run_peak_detection_TA( kymo, background, sets )
%RUN_PEAK_DETECTION 
% [PKS,LOCS,W, P] = FINDPEAKS(...) returns the width, W, of each peak by
%   linear interpolation of the left- and right- intercept points to the
%   reference defined by 'WidthReference', the prominence, P, of each
%   peak.
%


	bcgr = cell(1,2);
    bcgr{1} = mean(background');
    bcgr{2} = std(double(background'));

% MPH - minpeakhight, based on background kymograph+3sigma
	peakMap=zeros(size(kymo));
    peakLocs = cell(1,size(kymo,1)); 
    
    peakHeightsMap=zeros(size(kymo));
    peakHeights = cell(1,size(kymo,1));
   
    
    for k1 = 1:size(kymo,1)
        %[PKS,LOCS,W,P] = findpeaks(double(kymo(k1,:)));
        %[PKS,LOCS,W,P] = findpeaks(double(kymo(k1,:)),'MinPeakHeight',bcgr{1}(k1)+3*bcgr{2}(k1));
        [PKS,LOCS,W,P] = findpeaks(double(kymo(k1,:)),'MinPeakHeight',bcgr{1}(k1)+2*bcgr{2}(k1));
               
        peakMap(k1,LOCS) = 1;
        peakLocs{k1} = LOCS;
          
        peakHeightsMap(k1,LOCS) = PKS;
        peakHeights{k1} = PKS;
       
        
    end
    
 

%% Faster alternative for detecting peaks
% 
% tic
% BW = imregionalmax(kymo);
% toc

end

