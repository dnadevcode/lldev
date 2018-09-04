function [] = on_selected_method_change(eventData, hMVMParamSubPanel, hLCMAParamSubPanel)
    if eventData.NewValue.Tag == '2'
        set(hMVMParamSubPanel, 'Visible', 'on');
        set(hLCMAParamSubPanel, 'Visible', 'off');
    elseif eventData.NewValue.Tag == '3'
        set(hMVMParamSubPanel, 'Visible', 'off');
        set(hLCMAParamSubPanel, 'Visible', 'on');
    else
        set(hMVMParamSubPanel, 'Visible', 'off');
        set(hLCMAParamSubPanel, 'Visible', 'off')
    end
end