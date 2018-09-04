function [ p1_profile ] = profile_build( discrete_barcode, varargin )
%% P1_PROFILE Builds a 'plan-1' profile for structural variation detection in barcodes.
% Builds a profile with only match states, but with both forward and reverse search

%     function match_emissions = match_pdf( pixel_intensity, flat_scale )
%         % Creates a vector with 60 elements. It creates a normal distribution
%         % around the pixel intensity, and rescales to 1 if required.
%         pd = makedist('Normal', pixel_intensity, 2);
%         match_emissions = pdf(pd, 1:60);
%         flat(1:60) = 1/60;
%         match_emissions = ((match_emissions*(1-flat_scale)) + (flat*flat_scale));
%         if sum(match_emissions) ~= 1
%             match_emissions = match_emissions / sum(match_emissions);
%         end
%     end

    distfun = @( px ) normpdf(1:60, px, 2)';
    flatfun = @( pxpdf ) ((pxpdf*1) + (0/600));
    sum1fun = @( pxpdf ) pxpdf/sum(pxpdf);

    linear = 0;

    %% Setup/value initialisation
    seqlen = length(discrete_barcode);
 
    p_FR = 0.5;         % Probability of moving from Jf to Jr
    p_RF = 0.5;         % Probability of moving from Jr to Jf

    p_ME = 1/(seqlen);
    p_MM = 1 - p_ME;

    p_EfC   = 1/3;
    p_EfJf  = (1 - p_EfC) * (1 - p_FR);
    p_EfJr  = (1 - p_EfC) * p_FR;
    p_ErC   = 1/3;
    p_ErJr  = (1 - p_ErC) * (1 - p_RF);
    p_ErJf  = (1 - p_ErC) * p_RF;


    p_JfJf = 1/20;
    p_JfBf = (1 - p_JfJf);
    p_JrJr = 1/20;
    p_JrBr = (1 - p_JrJr);
    p_NN = 1/20;
    p_NBf = (1 - p_NN) / 2;
    p_NBr = p_NBf;
    p_CC = 1/20;
    p_CT = 1 - p_CC;

    %%
    p1_profile = struct;
    p1_profile.len = seqlen;
    p1_profile.Em.Mf = zeros(seqlen + 1, 60);
    p1_profile.Em.Mr = zeros(seqlen + 1, 60);

    p1_profile.Tr.Mf = zeros(seqlen + 1, 2);
    p1_profile.Tr.Mr = zeros(seqlen + 1, 2);
    
% now vectorized/uses cellfun    
%     for i = 1:seqlen
%         p1_profile.Em.Mf(i+1, :) = match_pdf(discrete_barcode(i), 0.25);
%     end
    
    p1_profile.Em.Mf(2:end, :) = log10(cell2mat(cellfun(sum1fun, ...
                                                cellfun(flatfun, ...
                                               arrayfun(distfun, discrete_barcode, 'UniformOutput', 0), 'UniformOutput', 0), 'UniformOutput', 0))');

    p1_profile.Em.Mr(2:end, :) = flipud(p1_profile.Em.Mf(2:end, :));
    
    p1_profile.Tr.Mf(:, 1) = log10(p_MM);
    p1_profile.Tr.Mr(:, 1) = log10(p_MM);
    p1_profile.Tr.Mf(:, 2) = log10(p_ME);
    p1_profile.Tr.Mr(:, 2) = log10(p_ME);
    
    if linear
        p1_profile.Tr.Mf(end, 2) = log10(1);
        p1_profile.Tr.Mr(end, 2) = log10(1);
    end

    p1_profile.Tr.Bf    = repmat(log10(1/seqlen), 1, seqlen);
    p1_profile.Tr.Br    = repmat(log10(1/seqlen), 1, seqlen);
    p1_profile.Tr.Ef    = log10([p_EfJf p_EfJr p_EfC]);
    p1_profile.Tr.Er    = log10([p_ErJr p_ErJf p_ErC]);
    p1_profile.Tr.N     = log10([p_NBf p_NBr p_NN]);
    p1_profile.Tr.Jf    = log10([p_JfBf p_JfJf]);
    p1_profile.Tr.Jr    = log10([p_JrBr p_JrJr]);
    p1_profile.Tr.C     = log10([p_CT p_CC]);
 
end
