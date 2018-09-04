function [ prevInd, dd ] = trace_back_to_feasible_item(prevInd, gg,kk )
% traces back to feasible bid
   dd = kk;

   if prevInd >= gg(1)
        dd = 1;
        while(gg(dd+1)< prevInd)
            dd = dd+1;
        end
        prevInd = gg(dd); 
   end


end

