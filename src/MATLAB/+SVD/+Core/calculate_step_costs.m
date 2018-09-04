function [stepCosts] = calculate_step_costs(accumulatedDistMat, optimalPath)
    optPathAccumCosts = arrayfun(@(idxX, idxY) accumulatedDistMat(idxX, idxY), optimalPath(:,1), optimalPath(:,2));
    stepCosts = flipud(-1*diff(optPathAccumCosts));
end