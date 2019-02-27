function [ edges, cc, mx,connectedComp ] = generate_peak_graph(sizef, peaklocs, localFluctuationWindow,minConC)
    % generate_peak_graph
    %
    % :param peaklocs: peak locations.
	% :param localFluctuationWindow: max distance between peaks.

    % :returns: edges
    
    % written by Albertas Dvirnas
    
    % row i will be parent
    % row i+1 will be daughter
    
    % EXAMPLE: special case
    % Note that in theory there could be a child with two parents
    % sizef = [2,16];
    % peaklocs{1} = [4 6 10 15];
    % peaklocs{2} = [5 11 16];
    % peaklocs{3} = [4 6 10 15];

    
    edges = cell(1,length(peaklocs)-1);
    connectedComp = zeros(sizef(1),sizef(2));
	connectedComp(1,peaklocs{1}) = 1:length(peaklocs{1});

    %https://se.mathworks.com/help/matlab/ref/digraph.html ?
    for i=1:length(peaklocs)-1
        % choose parents and daughters
        parents = peaklocs{i};
        daughters = peaklocs{i+1};

        % find closest indexes. if two are the same, it will return the
        % leftmost. TODO: maybe add both, and remove one of them in
        % post-processing? 
        [c, index] = arrayfun(@(x) min(abs(daughters-x)),parents);
        % save the edges to the structure
        edges{i} = [parents(c <= localFluctuationWindow);...
            daughters(index(c <= localFluctuationWindow))];
        
        % what features do the parents belong to? 
        oldFeatures = connectedComp(i,parents);
        
        % some parents were not assigned to any features / alt some
        % daughters
        zerofeatures = oldFeatures == 0;
        % those parents that didn't have any features asigned to them, get
        % a new feature started
        mx = max(connectedComp(:));
        oldFeatures(zerofeatures) = (mx+1):(mx+sum(zerofeatures));

        % We save the old features
        connectedComp(i,parents) = oldFeatures;
        
        % Children get feature names from their parents. 
    
        % in case of a double parent, more correct to choose it based on
        % distance. But this won't happen many times
        connectedComp(i+1,edges{i}(2,:)) = oldFeatures(c <= localFluctuationWindow);
    end
    % to the last one, assign labels for yet unasigned children
    oldFeatures = connectedComp(end,peaklocs{end});
	zerofeatures = oldFeatures == 0;
    mx = max(connectedComp(:));
    connectedComp(end,zerofeatures) =  (mx+1):(mx+sum(zerofeatures));
    
    % first find amount of pixels in each feature
    % TODO: faster would be to look at min and max row idx
    amnt = zeros(1,max(connectedComp(:)));
    for i=1:max(connectedComp(:))
        amnt(i) = sum(connectedComp(:)==i); 
    end

    % select only those that pass threshold
    vals = find(amnt > minConC);

    % save feature indices into a cell
	cc = cell(1,length(vals));
    for i=1:length(vals)
        [I,J] = find(connectedComp==vals(i));
        cc{i} = sortrows([I J],1);
        %cc(connectedComp==vals(i)) = i;
    end
    
    mx = max(connectedComp(:));

end

