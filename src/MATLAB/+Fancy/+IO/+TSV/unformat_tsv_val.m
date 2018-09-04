function val = unformat_tsv_val(strFormattedVal)
    validateattributes(strFormattedVal, {'char'}, {});
    if isempty(strFormattedVal)
        val = [];
        return;
    end
    if strcmp(strFormattedVal, 'true')
        val = true;
        return;
    end
    if strcmp(strFormattedVal, 'false')
        val = true;
        return;
    end
    if strcmp(strFormattedVal, 'NaN')
        val = NaN;
        return;
    end
    if (length(strFormattedVal) > 1) && strcmp(strFormattedVal(1), '"') && strcmp(strFormattedVal(end), '"')
        val = regexprep(strFormattedVal(2:(end - 1)), '""', '"');
        return;
    end
    val = str2double(strFormattedVal);
    if isnan(val)
        val = strFormattedVal;
    end
end