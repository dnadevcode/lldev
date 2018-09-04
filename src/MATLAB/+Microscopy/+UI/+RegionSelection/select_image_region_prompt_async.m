function [hButtonContinue] = select_image_region_prompt_async(dispImg, hPanel, callback_fn)

    function croppingDetails = get_cropping_struct(dispImgSz, rect)
        if nargin < 2
            rect = [0, 0, inf, inf];
        end
        minRowIdx = 1;
        maxRowIdx = dispImgSz(1);
        minColIdx = 1;
        maxColIdx = dispImgSz(2);
        
        rowStartIdx = max(floor(rect(2)), minRowIdx);
        colStartIdx = max(floor(rect(1)), minColIdx);
        rowEndIdx = min(floor(rect(2) + rect(4)), maxRowIdx);
        colEndIdx = min(floor(rect(1) + rect(3)), maxColIdx);
        
        croppingDetails.rowStartIdx = rowStartIdx;
        croppingDetails.rowEndIdx = rowEndIdx;
        croppingDetails.colStartIdx = colStartIdx;
        croppingDetails.colEndIdx = colEndIdx;
    end

    function show_selection_ui(dispImg, hAxis, croppingDetails)
        croppedRowIdxs = croppingDetails.rowStartIdx:croppingDetails.rowEndIdx;
        croppedColIdxs = croppingDetails.colStartIdx:croppingDetails.colEndIdx;
        invImg = imcomplement(dispImg);
        invImg(croppedRowIdxs, croppedColIdxs, :, :) = dispImg(croppedRowIdxs, croppedColIdxs, :, :);
        axes(hAxis);
        imshow(invImg);
    end
    

    validateattributes(dispImg, {'numeric', 'logical'}, {'nonempty', 'real', '3d'}, 1);
    validateattributes(hPanel, {'matlab.ui.container.Panel'}, {'scalar'}, 2);
    validateattributes(callback_fn, {'function_handle'}, {}, 3);
    hButtonReset = uicontrol(hPanel, 'Style','pushbutton',...
            'String', 'Reset',...
            'Units', 'normal', 'Position', [0 0 0.5 0.1]);
    hButtonContinue = uicontrol(hPanel, 'Style','pushbutton',...
            'String', 'Continue (Accept Current Crop)',...
            'Units', 'normal', 'Position', [0.5 0 0.5 0.1]);

    hAxis = axes('Units', 'normal', 'Position', [0.15 0.15 0.7 0.7], 'Parent', hPanel);
    dispImgSz = size(dispImg);
    croppingDetails = get_cropping_struct(dispImgSz);
    resetButton_Callback([], [], []);

    function resetButton_Callback(~, ~, ~)
        croppingDetails = get_cropping_struct(dispImgSz);
        show_selection_ui(dispImg, hAxis, croppingDetails);
        rect = [];
        try
            set(hButtonReset, 'enable', 'off');
            set(hButtonContinue, 'enable', 'off');
            rect = getrect(hAxis);
            set(hButtonReset, 'enable', 'on');
            set(hButtonContinue, 'enable', 'on');
        catch
            warning('Skipped cropping');
            try
                delete(hButtonReset);
            catch
            end
            callback_fn(croppingDetails);
        end
        if not(isempty(rect))
            croppingDetails = get_cropping_struct(dispImgSz, rect);
            show_selection_ui(dispImg, hAxis, croppingDetails);
        end
    end
    
    function continueButton_Callback(~, ~, ~)
        area = (croppingDetails.rowEndIdx + 1 - croppingDetails.rowStartIdx)*(croppingDetails.colEndIdx + 1 - croppingDetails.colStartIdx);
        if (area == 0)
            errordlg('The area selected must not be empty','Bad selection');
            croppingDetails = get_cropping_struct(dispImgSz);
            show_selection_ui(dispImg, hAxis, croppingDetails);
            resetButton_Callback([], [], []);
        else
            delete(hButtonReset);
            callback_fn(croppingDetails);
        end
    end
    try
        set(hButtonReset, 'Callback', @resetButton_Callback);
        set(hButtonContinue, 'Callback', @continueButton_Callback);
    catch
    end
end