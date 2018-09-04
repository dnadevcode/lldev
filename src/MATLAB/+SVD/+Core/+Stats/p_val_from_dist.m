function [ pVal ] = p_val_from_dist( score, evParams )
%P_VAL_FROM_DIST Summary of this function goes here
%   crossCorr: The pearson cross-correlation value of the hit you want to
%              find a p-value for.
%   evParams:  A 2xdouble containing the two extreme distribution
%              parameters for the hit's null model distribution. As
%              returned by evfit().

    pVal = -expm1(-exp((-score - evParams(1))./evParams(2)));

end