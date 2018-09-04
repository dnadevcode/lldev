function [amplificationFilterKernel] = get_amplification_filter_kernel()
    % square without center
    amplificationFilterKernel = ones(3,3);
    amplificationFilterKernel(floor((end +1)/2),floor((end +1)/2)) = 0;
    amplificationFilterKernel = amplificationFilterKernel./sum(amplificationFilterKernel(:));
end