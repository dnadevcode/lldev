function [] = toggle_neighbor_usage(hEditNeighborWeight, hNeighborWeightTextLabel, hCheckboxUsePCC)
    if strcmp(hEditNeighborWeight.Visible, 'off')
        set(hEditNeighborWeight, 'Visible', 'on');
        set(hNeighborWeightTextLabel, 'Visible', 'on');
    else
        set(hCheckboxUsePCC, 'Value', 0);
        set(hEditNeighborWeight, 'Visible', 'off');
        set(hNeighborWeightTextLabel, 'Visible', 'off');
    end
end