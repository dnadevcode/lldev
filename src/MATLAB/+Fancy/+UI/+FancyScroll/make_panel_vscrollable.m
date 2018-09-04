function data = make_panel_vscrollable(hPanel)
    handles.panel = hPanel;
    handles.parent = get(handles.panel, 'Parent');
    handles.figure = ancestor(handles.parent, 'figure', 'toplevel');
    % set(handles.figure, 'Renderer', 'painters');

    figureUserData = get(handles.figure, 'UserData');
    parentUserData = get(handles.parent, 'UserData');
    if isempty(figureUserData)
        figureUserData = struct;
    elseif not(isstruct(figureUserData))
        error('Scrollability is not supported for panels in figures with UserData if the data is not organized in a struct');
    end

    if isempty(get(handles.panel, 'Tag'))
        tags.panel = char(java.util.UUID.randomUUID);
    else
        tags.panel = get(handles.panel, 'Tag');
    end
    tags.viewportPanel = [tags.panel, '!-VP'];
    tags.viewportWrappingPanel = [tags.panel, '!-VWP'];
    tags.slider =  [tags.panel, '!-S'];
    handles.viewportWrappingPanel = uipanel(handles.parent, 'Units', get(handles.panel, 'Units'), 'Position', get(handles.panel, 'Position'), 'Tag', tags.viewportWrappingPanel);
    handles.viewportPanel = uipanel(handles.viewportWrappingPanel, 'Tag', tags.viewportPanel);
    set(handles.panel, 'Parent', handles.viewportPanel, 'Units', 'pixels', 'Tag', tags.panel);
    handles.slider = uicontrol(handles.viewportWrappingPanel, 'Style', 'Slider', 'Value', 1.0, 'Tag', tags.slider);
    iptaddcallback(handles.slider, 'Callback', @(~, ~) on_slider_change(handles.slider, handles.panel, false));
    iptaddcallback(handles.panel, 'SizeChangedFcn', @(~, ~) on_slider_change(handles.slider, handles.panel, true));
    iptaddcallback(handles.viewportPanel, 'SizeChangedFcn', @(~, ~) on_slider_change(handles.slider, handles.panel, true));
    iptaddcallback(handles.viewportWrappingPanel, 'SizeChangedFcn', {@onResizeCallback, handles.viewportWrappingPanel,});
    data.tags = tags;
    data.handles = handles;
    data.settings.SCROLLBAR_WIDTH_PX = 20;
    data.tags = tags;
    data.handles = handles;
    data.settings.SCROLLBAR_WIDTH_PX = 20;
    onResizeCallback(handles.viewportWrappingPanel, {}, handles.viewportWrappingPanel);

    hadWheelScrollingSupport = isfield(figureUserData, 'supportsWheelScrolling') && not(isempty(figureUserData.supportsWheelScrolling));
    if not(hadWheelScrollingSupport)
        figureUserData.supportsWheelScrolling = iptaddcallback(handles.figure, 'WindowScrollWheelFcn', {@onWheelScrollCallback});
    end
    set(handles.figure, 'UserData', figureUserData);

    function on_slider_change(mySliderHandle, myPanelHandle, shouldUpdateScrollbarStep)
        import Fancy.UI.FancyScroll.vscroll_panel;
        
        if nargin < 3
            shouldUpdateScrollbarStep = false;
        end
        vscroll_panel(myPanelHandle, get(mySliderHandle, 'Value'), @(posPx) posPx, shouldUpdateScrollbarStep, mySliderHandle);
    end
    function onResizeCallback(~, ~, handle)
        import Fancy.UI.FancyPositioning.get_pixel_height;
        import Fancy.UI.FancyPositioning.set_at_pos_nrm_in_px;
        import Fancy.UI.FancyScroll.get_vert_pos_px_range;
        import Fancy.UI.FancyPositioning.float_with_fixed_length;

        hPanelViewportWrapper = findobj(handle, 'flat', 'Type', 'uipanel','-regexp', 'Tag', '.+\!-VWP$');
        if isempty(hPanelViewportWrapper)
            return;
        end
        SCROLLBAR_WIDTH_PX = 20;
        tag = get(hPanelViewportWrapper, 'Tag');
        panelTag = tag(1:end-5);
        viewportPanelTag = [panelTag, '!-VP'];
        sliderTag = [panelTag, '!-S'];

        hSliderA = findobj(hPanelViewportWrapper, '-depth', 1, 'Tag', sliderTag);
        if (isempty(hSliderA))
            return;
        end

        myViewportPanelHandle = findobj(hPanelViewportWrapper, '-depth', 1, 'Tag', viewportPanelTag);
        if (isempty(myViewportPanelHandle))
            return;
        end

        hPanelA = findobj(myViewportPanelHandle, '-depth', 1, 'Tag', panelTag);
        if (isempty(hPanelA))
            return;
        end
        set_at_pos_nrm_in_px(myViewportPanelHandle, [0, 0, 1, 1], @(posPx) float_with_fixed_length('L', posPx, posPx(3) - SCROLLBAR_WIDTH_PX));
        set_at_pos_nrm_in_px(hSliderA, [1, 0, 0, 1],  @(posPx) float_with_fixed_length('R', posPx, SCROLLBAR_WIDTH_PX));
        panelHeightPx = max(diff(get_vert_pos_px_range(allchild(hPanelA))), get_pixel_height(myViewportPanelHandle));
        set_at_pos_nrm_in_px(hPanelA, [0, 1, 1, 0], @(posPx) (posPx .* [1, 1, 1, 0]) + (max(posPx(4), panelHeightPx) .* [0, -1, 0, 1]));
        on_slider_change(hSliderA, hPanelA, true);
    end
    function onWheelScrollCallback(~, callbackData)
        import Fancy.Utils.FancyStrUtils.str_ends_with;
        
        verticalScrollCount = callbackData.VerticalScrollCount;
        hPanelCurr = ancestor(gco, 'uipanel');
        while not(isempty(hPanelCurr))
            tag = get(hPanelCurr, 'Tag');
            if (str_ends_with(tag, '!-VWP'))
                hPanelViewportWrapper = hPanelCurr;
                panelTag = tag(1:end-5);
                sliderTag = [panelTag, '!-S'];
                hPanelA = findobj(hPanelViewportWrapper, '-depth', 2, 'Tag', panelTag);
                if (isempty(hPanelA))
                    continue;
                end
                hSliderA = findobj(hPanelViewportWrapper, '-depth', 1, 'Tag', sliderTag);
                if (isempty(hSliderA))
                    continue;
                end
                stepSize = get(hSliderA, 'SliderStep');
                set(hSliderA, 'Value', min(1, max(0, get(hSliderA, 'Value') - verticalScrollCount*max(stepSize.*[1,.2]))));
                on_slider_change(hSliderA, hPanelA, false);
                return;
            end
            hPanelCurr = ancestor(hPanelCurr.Parent, 'uipanel');
        end
    end
end
