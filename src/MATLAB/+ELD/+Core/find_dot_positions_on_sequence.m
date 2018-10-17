function [ dotPositions ] = find_dot_positions_on_sequence(theoreticalSequence,targetSequence)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    targetLength = length(targetSequence);
    targetIdxs = strfind(theoreticalSequence,targetSequence);
    dotPositions = targetIdxs + targetLength/2.0 - 1;
    
end