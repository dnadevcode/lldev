function [newDataArr] = rescale_arr_data_vals(oldDataArr, oldMinVal, oldMaxVal, newMinVal, newMaxVal)
    if nargin < 2
        oldMinVal = min(oldDataArr(:));
        oldMaxVal = max(oldDataArr(:));
        if (oldMaxVal == oldMinVal)
            oldMaxVal = oldMaxVal + 1;
        end
    end
    if nargin < 4
        newMinVal = 0;
        newMaxVal = 1;
    end
    validateattributes(oldDataArr, {'double'}, {'finite'}, 1);
    validateattributes(oldMinVal, {'double'}, {'finite', 'scalar'}, 2);
    validateattributes(oldMaxVal, {'double'}, {'finite', 'scalar', '>', oldMinVal}, 3);
    validateattributes(newMinVal, {'double'}, {'finite', 'scalar'}, 4);
    validateattributes(newMaxVal, {'double'}, {'finite', 'scalar', '>', newMinVal}, 5);

    newDataArr = oldDataArr;

    % update nrmDataArr mapping [nrmMinRawVal, nrmMaxRawVal] to [0, 1]
    if not(oldMinVal == 0)
        newDataArr = newDataArr - oldMinVal;
    end
    if not((oldMaxVal - oldMinVal) == 1)
        newDataArr = newDataArr ./ (oldMaxVal - oldMinVal);
    end

    % update nrmDataArr mapping [0, 1] to [nrmMin, nrmMax]
    %  (no change if already [0, 1] as is typical)
    if not((newMaxVal - newMinVal) == 1)
        newDataArr = newDataArr .* (newMaxVal - newMinVal);
    end
    if not(newMinVal == 0)
        newDataArr = newDataArr + newMinVal;
    end
end