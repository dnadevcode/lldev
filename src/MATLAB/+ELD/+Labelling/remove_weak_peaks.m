function [ output_bitmask ] = remove_weak_peaks( kymograph, input_bitmask )
    % remove_weak_peaks
    % input  kymograph, input_bitmask
    % output output_bitmask
    
    % divide the kymograph by the maximum value, i.e. normalise
    kymograph = kymograph/(max(kymograph(:)));

    % compute a global threshold using Otsu method
    thresholdVal = graythresh(kymograph);
    
    % Keep only the values greater than the threshold+ a little extra (so
    % thresh/2?
    threshImg = kymograph >= thresholdVal; 
        
    output_bitmask = threshImg.*input_bitmask;

end

