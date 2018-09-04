function [] = toggle_pcc_usage(hSource, hCheckboxUseNeighbors, hNeighborWeightEdit, hNeighborWeightTextLabel)
    if (hSource.Value == 1) && (hCheckboxUseNeighbors.Value == 0)
        set(hCheckboxUseNeighbors, 'Value', 1);
        set(hNeighborWeightEdit, 'Visible', 'on');
        set(hNeighborWeightTextLabel, 'Visible', 'on');
    end
end
