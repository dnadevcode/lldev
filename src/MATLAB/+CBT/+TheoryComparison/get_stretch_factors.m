function stretchFactors = get_stretch_factors(thyCurveLen_bp, otherCurveLen_pixels, meanBpExt_pixels, stretchStrategy, noOfStretchings, optInterval, lengthConstraint)
    thyCurveLen_pixels = length(1:round(1/meanBpExt_pixels):thyCurveLen_bp);
    stretchFactorForEqualLen = otherCurveLen_pixels/thyCurveLen_pixels;
    switch stretchStrategy
        case 1 % leave alone, but convert to pixel resolution
            stretchFactors = 1; %leave alone in bp resolution
            if lengthConstraint && (stretchFactors < stretchFactorForEqualLen)
                %warning('Length constraint was ignored for the current stretch method and the circular theory curve is shorter than the other curve');
            end
        case 2 % stretch to equal lengths
            stretchFactors = stretchFactorForEqualLen;
        case 3 % noOfStretchings stretch factors spread linearly from (-optInterval:optInterval) away from 1 (not stretching)
            stretchFactors = 1;
            if noOfStretchings > 1
                stretchFactors = stretchFactors + ((-1:(2/(noOfStretchings - 1)):1)*optInterval);
            end
            if lengthConstraint
                stretchFactors = stretchFactors(stretchFactors >= stretchFactorForEqualLen);
                if isempty(stretchFactors)
                    % warning('No stretch factors fit the constraint for the current stretch method');
                end
            end
        case 4 % noOfStretchings stretch factors spread linearly from (-optInterval:optInterval) away from stretchfactor from method 2 (stretching to equal lengths)
            stretchFactors = stretchFactorForEqualLen;
            if noOfStretchings > 1
                stretchFactors = stretchFactors + ((-1:(2/(noOfStretchings- 1)):1)*optInterval);
            end
            if lengthConstraint
                stretchFactors = stretchFactors(stretchFactors >= stretchFactorForEqualLen);
            end
    end
end