function [ ccs ] = res_ccs( bc1, bc2, hits )
%HIT_CCS Summary of this function goes here
%   Detailed explanation goes here
    
    ccs{size(hits, 1)} = 0;
    
    for hit_i = 1:size(hits, 1)
        inc = 1;
        if hits(hit_i, 3) > hits(hit_i, 4)
            inc = -1;
        end
        cc = corrcoef(bc2(hits(hit_i, 1):hits(hit_i, 2)), ... 
                      bc1(hits(hit_i, 3):inc:hits(hit_i, 4)));
        ccs{hit_i} = cc(2);
    end

end

