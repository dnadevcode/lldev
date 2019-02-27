function [ fD, fV , fO] = calculate_feature_distances( fA, sets)
    % calculate_feature_distances
    % this distance calculation is only for overlapping rows
    %
    %
    % :param fA: input features.
    % :param sets: settings.

    % :returns: fD, fV , fO
    
    % rewritten by: Albertas Dvirnas
    % parameter initialization
    fD = nan(length(fA),length(fA)); % feature distances
    fO = zeros(length(fA),length(fA)); % feature overlaps
    fV = nan(length(fA),length(fA)); % features calculated
    fsD = nan(length(fA),length(fA));
    
    % run over all pairs of features. TODO : vectorize
    for i = 1:(length(fA)-1)
        for j = (i+1):length(fA)
            % check for overlapping rows
            [~,rowsInJ] = ismember(fA{i}(:,1),fA{j}(:,1));
            % f1 row indices
            f1rows = find(rowsInJ~=0);
            % f2 row indices
            f2rows = nonzeros(rowsInJ);
            fD(i,j) = 0;
            fsD(i,j) = 0;

            fO(i,j) = length(f1rows);
            if fO(i,j) > sets.minVertOverlap
                % loop over such rows
                for k = 1:length(f1rows)
                    fD(i,j) = fD(i,j)+abs(fA{j}(f2rows(k),2)-fA{i}(f1rows(k),2));
                    fsD(i,j) = fsD(i,j) + (fA{j}(f2rows(k),2) - fA{i}(f1rows(k),2)).^2;
                end
            end
        end
    end

    % compute distances, squared distances, variance
    fD = fD ./ fO;
    fsD = fsD ./ fO;
    fV = fsD - fD.^2;

    %TODO: check if nothing more needs to be done

    %% now we compute  optimal estimator distance, since we didn't compute it yet for some
    % copy here from merge_features



end