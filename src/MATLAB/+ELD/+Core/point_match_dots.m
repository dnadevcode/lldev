function [ pairArray, distanceArray, matchMetric ] = point_match_dots( dataSetA, dataSetB )

    dataSetA = [1, 2, 2, 3, 3.5, 7, 8, 10, 11, 102, 102];
    dataSetB = [2.5, 3.5 6 8, 10.505];
%     dataSetB = [dataSetB, 9, 8.1];
%     dataSetB = fliplr(dataSetB);

%     dataSetA = dataSetA(1:end-25);
%     dataSetB = dataSetB(1:end-25); 

%     dataSetA(dataSetA==0) = dataSetA(dataSetA==0)+0.0001;
%     dataSetB(dataSetB==0) = dataSetB(dataSetB==0)+0.0001;
    
    
    numPointsA = numel(dataSetA);
    numPointsB = numel(dataSetB);
%     n;
    
    
    if numPointsA > numPointsB %-- dataSetA must be the smaller set
        [dataSetA,dataSetB] = deal(dataSetB,dataSetA);
        [numPointsA,numPointsB] = deal(numPointsB,numPointsA);
%         reversed = true;
%         n = n1;
%     else
% %         reversed = false;
%         n = n1;
    end
    numRemainingPoints = numPointsA;
%     ab = sqrt(sum((dataSetA - dataSetB(3:end)).^2));
%     bb = sqrt(sum((dataSetA - dataSetB(1:end-2)).^2));
%     cb = sqrt(sum((dataSetA - dataSetB(2:end-1)).^2));

  
%     if n1<n2 
%         n=n1;
%     else
%         n=n2;
%     end
    
% 
%   -- initialize dual variables
    minDistsFromA = inf(numPointsA,1);
    backDists = zeros(numPointsB,1);
    pointDists = inf(numPointsA,numPointsB);

    for pointInA=1:numPointsA
        for pointInB=1:numPointsB
            pointDists(pointInA,pointInB) = abs(dataSetA(pointInA)-dataSetB(pointInB));
            minDistsFromA(pointInA) = min(minDistsFromA(pointInA),pointDists(pointInA,pointInB));
%             if c(i,j)<u[i] 
%                 u[i] = dataSetA[i]-dataSetB[j];
%             end
        end
    end
%     for j=1:n2
%         v[j]=0;
%     end
% 
%   -- reduced costs are c(i,j)-u(i)-v(j) in the forward direction.
%     My = {}
%     Mx = {} %-- matching partners
% 
% --- FUNCTION to print reduced cost table for DEBUGGING
% --[[
% local function printsol() -- (model,n1,n2,u,v,My,Mx)
%    local str = "u\\v:"
%    for j = 1,n2 do
%       str = str .. string.format(" %4d",v[j])
%    end
%    str = str .. "\n"
% 
%    for i = 1,n1 do
%      str = str .. string.format("%4d |",u[i])
%      for j = 1,n2 do
%        str = str .. string.format(" %4d",c(i,j)-u[i]-v[j])
%        if j == My[i] then
%           str = str.."*"
%        else
%           str = str.." "
%        end
%      end
%      str = str .. "\n"
%    end
%    model:warning("compute matching", str)  -- or print (str) to the terminal
% end
% --]]
% --- END DEBUGGING FUNCTION
% --  printsol = function() end -- disable debugging output
% 
% --  printsol() -- print initial cost matrix
% 
%     T = {} %-- set of remaining vertices
%     dy,dx,pred,comp,tmin,i,i0,j,j0
% 
%     My = [];
%     Mx = [];
    connToA = nan(numPointsA,1);
    connToB = nan(numPointsB,1);

    while numRemainingPoints>0 && (numel(connToA) < numPointsA || ...
            all(isnan(connToA)) || (find(~isnan(connToA),1,'last') < numPointsA))
%         dx = [];
        reducedDistToA = nan(numPointsA,1);
%         dy = [];
        reducedDistToB = nan(numPointsB,1);
%         pred = [];
        removedEdge = nan(numPointsB,1);
        for pointInA = 1:numPointsA
            if numel(connToA) < pointInA || isempty(connToA(pointInA)) || isnan(connToA(pointInA)) %-- i0 is a potential start vertex
                reducedDistToA(pointInA) = 0;
                for pointInB = 1:numPointsB
                    reducedDist = pointDists(pointInA,pointInB)-minDistsFromA(pointInA)-backDists(pointInB);
                    if numel(reducedDistToB) < pointInB || isempty(reducedDistToB(pointInB)) || isnan(reducedDistToB(pointInB)) || reducedDist<reducedDistToB(pointInB)
                        reducedDistToB(pointInB) = reducedDist;
                        removedEdge(pointInB) = pointInA;
                    end
                end
            end
        end
    %     for j=1:n2
    %         T[j]=true
    %     end
        T = true(numPointsB,1);

        %         -- look for shortest path
        while true
            tmin = inf;
            for pointInB = 1:numel(T) %pairs(T)
                if isempty(tmin) || reducedDistToB(pointInB)<tmin
                    j0 = pointInB;
                    tmin = reducedDistToB(pointInB);
                end
            end
            if numel(connToB) < j0 || isempty(connToB(j0)) || isnan(connToB(j0))
                break;
            end %-- found an unmatched vertex
            T(j0) = []; %-- remove j0
            pointInA = connToB(j0);
            if pointInA < 1
                break;
            end
            reducedDistToA(pointInA) = tmin;
            for pointInB = 1:numel(T) %pairs(T)
                if reducedDistToB(pointInB) > tmin + pointDists(pointInA,pointInB)-minDistsFromA(pointInA)-backDists(pointInB);
                    reducedDistToB(pointInB) = tmin + pointDists(pointInA,pointInB)-minDistsFromA(pointInA)-backDists(pointInB);
                    removedEdge(pointInB) = pointInA;
                end
            end
        end
        
        if pointInA < 1
            break;
        end

        %                 -- update dual variables, using dx,dy
        %                 -- optimality proof (for the case n2>=n1):
        %             --     v[j]<=0, and v[j]<0 only if j is matched
        for pointInA = 1:numel(reducedDistToA) %,d in pairs(dx)
            d = reducedDistToA(pointInA);
            if d<tmin
                minDistsFromA(pointInA) = minDistsFromA(pointInA) + tmin-d;
            end
        end
        for pointInB = 1:numel(reducedDistToB) %,d in pairs(dy)
            d = reducedDistToB(pointInB);
            if d<tmin
                backDists(pointInB) = backDists(pointInB) - (tmin-d);
            end
        end
        %                     -- update matching:
        while j0
            connToB(j0) = removedEdge(j0);
            if numel(connToA) < removedEdge(j0) || isempty(connToA(removedEdge(j0))) || isnan(connToA(removedEdge(j0)))
                connToA(removedEdge(j0)) = j0;
                j0 = [];
            else
                [j0,connToA(removedEdge(j0))] = deal(connToA(removedEdge(j0)),j0);
            end
        end
        %                     -- printsol() -- debugging output
        numRemainingPoints = numRemainingPoints-1;
    end
    
    
    
    pairArray = connToA;
    distanceArray = dataSetA - dataSetB(connToA);
    matchMetric = sqrt(sum(distanceArray.^2));
    
% 
%   -- now draw the resulting edges
%   local object = {}
%   local cost = 0
%   local seg
%   for i,j in pairs(My) do
%     cost = cost + c(i,j)
%     if reversed then
%       seg = {type="segment",dataSetB[j],dataSetA[i]}
%     else
%       seg = {type="segment",dataSetA[i],dataSetB[j]}
%     end
%     object[#object+1] =
%      ipe.Path(model.attributes, {{type="curve",closed=false, seg}})
%   end
%   local grp = ipe.Group(object)
%   model:creation(objective_function_name .." matching, cost="..cost, grp)
% 

end

% function  = c(i,j)
%     dif = dataSetA[i]-dataSetB[j]
% end

