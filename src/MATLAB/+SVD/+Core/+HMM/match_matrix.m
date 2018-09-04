function [ out_matrix ] = match_matrix( hmm_profile, sequence)
%HMM_MATCH_MATRIX Summary of this function goes here
%   Detailed explanation goes here

out_matrix = zeros(length(sequence), size(hmm_profile.Em.Mf, 1) - 1);

for i = 1:length(sequence)
    for j = 1:size(hmm_profile.Em.Mf, 1)-1
        out_matrix(i, j) = hmm_profile.Em.Mf(j+1, sequence(i)); 
    end
    
end
end

