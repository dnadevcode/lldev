function [flattenedKymos, layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movieArr, rRot, cRot, kymoMolEdgeIdxs,avgL, sets)
    % extract_kymos

    % Input:
    % kymoMolEdgeIdxs{n}(i,j,k) - kymo edge indices on the rotated movie.
    % For the n'th kymograph, i is timeframe,  j is row (1) or column (2)
    % k is beginning or end (1,2). 
    %
    % Output: layeredKymos, kymosMasks, kymosCenterXYCoords

    % rewritten by Albertas Dvirnas

    fprintf('Extracting kymos...\n');
    
    % number of kymographs
    nK = length(kymoMolEdgeIdxs);
 
    % initialization of kymos, masks, center coords, center offsets
    layeredKymos = cell(nK, 1);
    kymosMasks = cell(nK, 1);
    
    % try to get this much of pixels to the left and the right of
    % kymograph. If not possible, add noise
    sideDist = sets.preprocessing.kymoEdgeDetection.sideDist;
   % bgDist = sets.preprocessing.kymoEdgeDetection.bgDist;
    bgDistL = 3; % left
	bgDistR = 3; % right

      
    % store flattened kymo's
    flattenedKymos = cell(nK, 1);
       
    % how many columns to consider. Typically avgL=2 but could be
    % different. 
    kymoCols = [(-(avgL)-bgDistL-1:-(avgL)-1) -(avgL):(avgL) (avgL+1:avgL+bgDistR)] ;
   
    % number of timeframes
    numFrames = size(movieArr,3);
    
    kymosCenterXYCoords = cell(nK,1);
    
    % now go through kymographs
    for kymoNum = 1:nK
        % mean column for the kymograph
        meanCol = mean(mean(kymoMolEdgeIdxs{kymoNum}(:,2,:)));
        
        % the timeframe where kymo starts
        minRow = min(kymoMolEdgeIdxs{kymoNum}(:,1,1));
        % the timeframe where kymo ends
        maxRow = max(kymoMolEdgeIdxs{kymoNum}(:,1,2));
        
    
            
        % here if minRow-sideDist < 1 or maxRow+sideDist>1, we we should
        % add noise
        coordsRow = ((minRow-sideDist):(maxRow+sideDist));
        
        % compute the bitmask, this might shift a little left or right from
        % frame to frame
        
        % for each frame, transform left and right edges based on minRow

        % the bitmask will be of the length maxRow-minRow+1+2*sideDist. 
        bitRow = zeros(numFrames,maxRow-minRow+1+2*sideDist);
        
        % just store row indexes
        rowIdx = zeros(numFrames,2);
        
        for j=1:numFrames
           % left and right row indices
           rowIdx(j,:) =  kymoMolEdgeIdxs{kymoNum}(j,1,:);
           bitRow(j,(rowIdx(j,1):rowIdx(j,2))-minRow+sideDist+1) = 1;
           
           % center coordinates
           xyC = round([mean(kymoMolEdgeIdxs{kymoNum}(j,1,:)),mean(kymoMolEdgeIdxs{kymoNum}(j,2,:))]);
           
           % have to still convert these to original movie. Why do we flip
           % x and y places?
           kymosCenterXYCoords{kymoNum}(j,:) = fliplr([rRot(xyC(1),xyC(2)),cRot(xyC(1),xyC(2))]);

        end
        kymosMasks{kymoNum} = bitRow;
        
        % this saved layered kymos
        layeredKymos{kymoNum} = nan(numFrames, length(minRow:maxRow),length(kymoCols));
        
        % go through snapshots of the molecule in the direction
        for j=1:length(kymoCols)
            % take column by column. there are |kymoCols| in total
            curCol = meanCol + kymoCols(j);
            coords = [coordsRow', repmat(curCol,maxRow-minRow+1+2*sideDist,1)];
            for i =1:size(coords,1)
                % store the coordinates.
                try
                    coords(i,:) = [rRot(coords(i,1), coords(i,2)), cRot(coords(i,1), coords(i,2))];
                catch
                    % if this goes out of range, this is a stored as nan.
                    coords(i,:) = nan;
                end
            end
            
            % go through the number of frames
            for fN=1:numFrames
                for t=1:size(coords,1)
                    try
                        layeredKymos{kymoNum}(fN,t,j) = movieArr(coords(t,1),coords(t,2),fN);
                    catch
                        layeredKymos{kymoNum}(fN,t,j) = nan;
                    end
                end    
            end
            
        end
        
        
        % rows to consider for noise is ones just before and after the
        % taken rows
        %rowForNoise = [meanCol-avgL-1 meanCol+avgL+1];
        
        % compute the nanmean of the layered kymographs
        flattenedKymos{kymoNum} = nanmean(layeredKymos{kymoNum}(:,:,bgDistL+1:end-bgDistR),3);  % changed
        % background kymo is taken from two adjacent rows which are
        % non-zero
        %bgrKymos{kymoNum} = nanmean(layeredKymos{kymoNum}(:,:,[1,end]),3);
        
        % in case not enough rows, this would gives us trouble?
        bgrKymos{kymoNum} = nanmean(layeredKymos{kymoNum}(:,:,[1:avgL+1,end-avgL+1:end]),3);
        randVals = bgrKymos{kymoNum}(find(~isnan(bgrKymos{kymoNum})));
        
        [a,b]=find(isnan(flattenedKymos{kymoNum}));
        
        % take random values (probably want to fix the ring
        currRng = rng();
        rng(rng(0, 'twister'));  
        rV = randi(length(randVals),1,length(a));
        for rr=1:length(a)
            flattenedKymos{kymoNum}(a(rr),b(rr)) = randVals(rV(rr));
        end
        rng(currRng);
        
    end
            
    fprintf('Extracted kymos\n');

end