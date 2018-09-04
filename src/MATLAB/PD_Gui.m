function [] = PD_Gui()
    import PD.MainPhoneDataAppState;
    mpdas = MainPhoneDataAppState();
    
    hFig = figure(...
        'Name', 'Phone Data GUI', ...
        'Units', 'normalized', ...
        'OuterPosition', [0.05 0.05 0.9 0.9], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none' ...
    );

    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);

    hTabPD = ts.create_tab('Phone Data');
    ts.select_tab(hTabPD);
    hPanelPD = uipanel('Parent', hTabPD);

    hAxisPanelPD = uipanel( ...
        'Parent', hPanelPD, ...
        'Units', 'normalized', ...
        'Position', [0.2 0 0.8 1] ...
    );
    
    hAxisPD = axes( ...
        'Parent', hAxisPanelPD, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'XTick', [], ...
        'YTick', [] ...
    );

    hOverviewPanelParent = uipanel( ...
        'Parent', hPanelPD, ...
        'Units', 'normalized', ...
        'Position', [0 0.225 0.2 0.35] ...
    );

    hLbxCoords = uicontrol( ...
        'Parent', hPanelPD, ...
        'Style', 'listbox', ...
        'Units', 'normalized', ...
        'Max', Inf, ...
        'Min', -Inf, ...
        'Position', [0 0.6 0.2 0.4] ...
    );

    hBtnPlot = uicontrol( ...
        'Parent', hPanelPD, ...
        'Style', 'pushbutton', ...
        'String', 'Plot Selected Lines', ...
        'Units', 'normalized', ...
        'Position', [0 0.15 0.2 0.05], ...
        'Callback', @(~, ~) on_btn_plot_lines(ts, mpdas, hLbxCoords) ...
    );

    hBtnReset = uicontrol( ...
        'Parent', hPanelPD, ...
        'Style', 'pushbutton', ...
        'String', 'Reset', ...
        'Units', 'normalized', ...
        'Position', [0 0.075 0.2 0.05], ...
        'Callback', @(~, ~) on_reset(mpdas, hLbxCoords, hAxisPD) ...
    );

    hBtnImportImg = uicontrol( ...
        'Parent', hPanelPD, ...
        'Style', 'pushbutton', ...
        'String', 'Import Image', ...
        'Units', 'normalized', ...
        'Position', [0 0 0.2 0.05], ...
        'Callback', @(~, ~) on_btn_import_img_click(mpdas, hPanelPD, hOverviewPanelParent, hAxisPD, make_on_line_selection_cb(mpdas, hLbxCoords)) ...
    );

    function fn_on_line_selection = make_on_line_selection_cb(mpdas, hLbxCoords)
        function on_line_selection(colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color)
            htmlStrCoords = mpdas.add_line_coords_to_state(colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color);
            add_line_coords_to_listbox(hLbxCoords, htmlStrCoords);
        end
        fn_on_line_selection = @on_line_selection;
    end

    on_reset(mpdas, hLbxCoords, hAxisPD);
    function on_reset(mpdas, hLbxCoords, hAxisPD)
        mpdas.set_to_init_state();
        set(hLbxCoords, 'String', {});
        set(hLbxCoords, 'Value', 1);
        delete(allchild(hAxisPD));
    end
    
    function [selectionHtmls] = get_list_selection_htmls(hLbxCoords)
        selectionHtmls = get(hLbxCoords, 'String');
        if isempty(selectionHtmls)
            selectionHtmls = {};
        else
            selectedIdxs = get(hLbxCoords, 'Value');
            selectionHtmls = selectionHtmls(selectedIdxs);
        end
    end

    function on_btn_plot_lines(ts, mpdas, hLbxCoords)
        selectionHtmls = get_list_selection_htmls(hLbxCoords);
        [linesCoords, linesBgColor, linesBarcodesArr] = mpdas.get_lines(selectionHtmls);
        numSelections = length(linesBgColor);
        for selectionNum = 1:numSelections
            lineCoords = linesCoords{selectionNum};
            lineBgColor = linesBgColor{selectionNum};
            lineBarcodesArr = linesBarcodesArr{selectionNum};
            selectionHtml = selectionHtmls{selectionNum};
            rowStartIdx = lineCoords(1);
            colStartIdx = lineCoords(2);
            rowEndIdx = lineCoords(3);
            colEndIdx = lineCoords(4);
            plaintextStr = sprintf('[(%d, %d) - (%d, %d)]', rowStartIdx, colStartIdx, rowEndIdx, colEndIdx);
            hTabCurr = ts.create_tab(['Plot ', plaintextStr]);
            ts.select_tab(hTabCurr);
            hPanelCurr = uipanel('Parent', hTabCurr);
            uipanel('Parent', hPanelCurr, ...
                'Units', 'normalized', ...
                'BackgroundColor', lineBgColor, ...
                'Position', [0.05 0.925 0.9 0.5] ...
            );
            hAxisCurr = axes('Parent', hPanelCurr, ...
                'Units', 'normalized', ...
                'Position', [0.3 0.1 0.6 0.8] ...
            );
            hBtnCurr = uicontrol( ...
                'Parent', hPanelCurr, ...
                'Style', 'pushbutton', ...
                'String', 'Save to workspace', ...
                'Units', 'normalized', ...
                'Position', [0 0 0.2 0.05], ...
                'Callback', @(h, ~) on_save_barcode(mpdas, selectionHtml, plaintextStr) ...
            );
       
        
            numSamples = size(lineBarcodesArr, 1);
            numLayers = size(lineBarcodesArr, 2);
            numChannels = size(lineBarcodesArr, 3);
            channelColors = {[0.5 0.5 0.5]};

            if numChannels == 3
                channelColors = {[1 0 0]; [0 1 0]; [0 0 1]};
            end
            
            for channelNum = 1:numChannels %red, gren, blue
                for layerIdx = 1:numLayers
                    currLine = lineBarcodesArr(:, layerIdx, channelNum); 
                    plot(hAxisCurr, currLine, ':', 'color', channelColors{channelNum});
                    hold(hAxisCurr, 'on');
                end
                meanChannelBarcode = mean(lineBarcodesArr(:, :, channelNum), 2, 'omitnan');
                plot(hAxisCurr, meanChannelBarcode, '-', 'color', channelColors{channelNum});
                hold(hAxisCurr, 'on');
            end
            % ylim = get(hAxisCurr, 'YLim');
            % ylim(1) = min(0, ylim(1));
            % set(hAxisCurr, 'YLim', ylim);
            set(hAxisCurr, 'XLim', [1 numSamples]);
        end

    end

    function on_save_barcode(mpdas, selectionHtml, plaintextStr)
        lineBarcodesArr = mpdas.barcodesMap(selectionHtml);
        numChannels = size(lineBarcodesArr, 3);
        layerMeans = mean(lineBarcodesArr, 2, 'omitnan');
        s = struct();
        s.barcodeImg = lineBarcodesArr;
        if numChannels == 3
            s.barcodeR = layerMeans(:, 1)';
            s.barcodeG = layerMeans(:, 2)';
            s.barcodeB = layerMeans(:, 3)';
        end
        s.barcode = mean(layerMeans, 3, 'omitnan')';
        
        name = matlab.lang.makeValidName([ 'barcode_', plaintextStr]);
        assignin('base', name, s);
        fprintf('Saved barcode info (''%s'') to workspace...\n', name);
    end

    function [] = add_line_coords_to_listbox(hLbxCoords, htmlStrCoords)
        coords = get(hLbxCoords, 'String');
        coords = [coords; {htmlStrCoords}];
        set(hLbxCoords, 'String', coords);
        set(hLbxCoords, 'Value', length(coords));
    end
    function on_btn_import_img_click(mpdas, hPanelPD, hOverviewPanelParent, hAxisPD, fn_on_line_selection)
        import Microscopy.Import.import_an_image;
        dispImg = import_an_image();
        mpdas.dispImg = dispImg;
        
        on_load_img(hPanelPD, hOverviewPanelParent, hAxisPD, dispImg, fn_on_line_selection)
    end
    function on_load_img(hPanelPD, hOverviewPanelParent, hAxisPD, dispImg, fn_on_line_selection)
        if isempty(dispImg)
            return;
        end
        dispImgSz = size(dispImg);
        if length(dispImgSz) == 2
            dispImgSz = [dispImgSz, 1];
        end
        hImg = imagesc(hAxisPD, dispImg);
        if dispImgSz(3) == 1
            colormap(hAxisPD, 'gray');
        end
        import PD.AnnotatedImgScreenState;
        aiss = AnnotatedImgScreenState(dispImg);
        hScrollPanelParent = get(hAxisPD, 'Parent');
        hScrollPanel = imscrollpanel(hScrollPanelParent, hImg);
        scrollApi = iptgetapi(hScrollPanel);
        
        hMagBox = immagbox(hPanelPD, hImg);
        set(hMagBox, 'Units', 'normalized');
        magBoxPos = get(hMagBox, 'Position');
        set(hMagBox, 'Position', [0 0.225 magBoxPos(3) magBoxPos(4)])
        
        hOverviewPanel = imoverviewpanel(hOverviewPanelParent, hImg);
        
        axis(hAxisPD, 'equal');
        set(hAxisPD, ...
            'XTick', [], ...
            'YTick', [] ...
        );
        set(hImg, ...
            'ButtonDownFcn', @(~, e) aiss.on_img_click(hAxisPD, hImg, fn_on_line_selection));
    end

end