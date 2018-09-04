function [ maxcoef,pos,or ] = get_best_parameters( xcorrs,lenC)
    % get_best_parameters
    
    % input xcorrs
    % output rezMax

    % f gives the max over the two rows, s gives the indice of
    % which row has the max (1 or 2)
    [f,s] =max(xcorrs);

    % sort the max scores, ix stores the original indices
    [ b, ix ] = sort( f(:), 'descend' );

    % choose the best three scores. (change this in the future?)
    indx = b(1:3)' ;

    % save the best three max score, and their orientation
    maxcoef = indx;
    or = s(ix(1:3)');

    % finally, save the position. This can have two cases,
    % depending on the value of s
     if s(ix(1:3)') == 1
        pos = ix(1:3)';
     else
        pos = ix(1:3)'-lenC; % todo: double check this if barC is longer than the theory barcode!
     end

    
    


end

