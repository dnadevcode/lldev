
function [b,c]=find_in_sorted_vector(x,range)
%
% Fast binary search replacement for ismember(A,B) for the
% special case where the first input argument is sorted.
% [Original function name: FindInSorted.m]
%
% Input:
%   x =sorted vector.
%   range = range of value [from,to], or a single value, to be located in x
%  
% Output:
%   b = first index of occurance
%   c = last index of occurance
% 
% Example:
%   
% vecA= [1.1 2.4 3.5 4.4 5.5 5.5 5.5 5.5 6.6 7.7 8.8]
% [b c] = find_in_sorted_vector(vecA,[1.9 , 5.5])
% gives b = 2 and c = 8. Hence, 
% vecA(b:c) = [2.4 3.5 4.4 5.5 5.5 5.5 5.5] 
% gives all elements which are in the range [1.9,5.5]
%
%  Daniel Roeske <danielroeske.de>
%

    A=range(1);
    B=range(end);
    a=1;
    b=numel(x);
    c=1;
    d=numel(x);
    if A<=x(1)
       b=a;
    end
    if B>=x(end)
        c=d;
    end
    while (a+1<b)
        lw=(floor((a+b)/2));
        if (x(lw)<A)
            a=lw;
        else
            b=lw;
        end
    end
    while (c+1<d)
        lw=(floor((c+d)/2));
        if (x(lw)<=B)
            c=lw;
        else
            d=lw;
        end
    end
end
