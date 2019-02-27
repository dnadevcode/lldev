function [ kymoDisplayNames,barcodeDisplayNames ] = calc_disp_names(tmp_numKymos, kymosCenterXYCoords )

  % compute rounded center coordinates
    tmp_roundedStartCenterCoords  = cellfun(@AB.Processing.Helper.calc_approx_start_center, ...
        kymosCenterXYCoords, 'UniformOutput', false);
    

    % display names
    tmp_kymoNameFormatStr = 'k_%03d_[%04d_%04d]';
    kymoDisplayNames = arrayfun(@(kymoNum) ...
        sprintf(tmp_kymoNameFormatStr, kymoNum, tmp_roundedStartCenterCoords{kymoNum}(1), tmp_roundedStartCenterCoords{kymoNum}(2)), ...
        (1:tmp_numKymos)', ...
        'UniformOutput', false);
    tmp_barcodeNameFormatStr = 'b_%03d_[%04d_%04d]';
    barcodeDisplayNames = arrayfun(@(kymoNum) ...
        sprintf(tmp_barcodeNameFormatStr, kymoNum, tmp_roundedStartCenterCoords{kymoNum}(1), tmp_roundedStartCenterCoords{kymoNum}(2)), ...
        (1:tmp_numKymos)', ...
        'UniformOutput', false);

    


end

