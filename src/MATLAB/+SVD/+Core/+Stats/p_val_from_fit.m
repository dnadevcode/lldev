function [ pVal ] = p_val_from_fit( score, fit, length )
%P_VAL_FROM_FIT Summary of this function goes here
%   Detailed explanation goes here
    
    evParams = [polyval(fit{1}, length) polyval(fit{2}, length)];
    pVal = StructVar.Stats.p_val_from_dist(score, evParams);
    

end

