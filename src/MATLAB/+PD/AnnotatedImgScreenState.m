classdef AnnotatedImgScreenState < handle
    % ANNOTATEDIMGSCREENSTATE - Class to manage an annotated screen
    %
    % Authors:
    %   Saair Quaderi
    
    properties
        dispImgSz
        dispLineImg
        nextColorIdx
        numColors
        colorsArr
        inSelectionModeTF
    end
    
    methods
        function [aiss] = AnnotatedImgScreenState(dispImg)
            dispLineImg = dispImg;
            dispLineImg = im2double(dispLineImg);
            dispLineImg = dispLineImg - min(dispLineImg(:));
            dispLineImg = dispLineImg./max(dispLineImg(:));
            if size(dispLineImg, 3) == 1
                dispLineImg = repmat(dispLineImg, [1 1 3]);
            end
            
            dispImgSz = size(dispImg);
            aiss.dispImgSz = dispImgSz;
            
            aiss.dispLineImg = dispLineImg;
            aiss.nextColorIdx = 1;
            aiss.numColors = 30;
            import ThirdParty.DistinguishableColors.distinguishable_colors;
            aiss.colorsArr = distinguishable_colors(aiss.numColors, [0 0 0]);
            aiss.inSelectionModeTF = false;
        end
        
        function on_img_click(aiss, hAxisPD, hImg, fn_on_line_selection)
            dispImgSz = aiss.dispImgSz;
            if aiss.inSelectionModeTF
                return;
            end
            selectedAction = 'Select line to sample';

            switch selectedAction
                case 'Select line to sample'
                    aiss.inSelectionModeTF = true;
                    maxRowIdx = dispImgSz(1);
                    maxColIdx = dispImgSz(2);
                    minRowIdx = min(1, maxRowIdx);
                    minColIdx = min(1, maxColIdx);
                    
                    axes(hAxisPD);
                    [colStartIdx, rowStartIdx, leftClickTF] = ginput(1);
                    colStartIdx = round(colStartIdx);
                    rowStartIdx = round(rowStartIdx);
                    colStartIdx = min(max(colStartIdx, minColIdx), maxColIdx);
                    rowStartIdx = min(max(rowStartIdx, minRowIdx), maxRowIdx);
                    
                    leftClickTF = (leftClickTF == 1);
                    if not(leftClickTF)
                        aiss.inSelectionModeTF = false;
                        return;
                    end
                    color = aiss.colorsArr(aiss.nextColorIdx, :);
                    dispImgTmp = insertShape(aiss.dispLineImg, 'circle',[colStartIdx rowStartIdx 5], 'LineWidth', 2, 'Color', color);
                    set(hImg, 'CData', dispImgTmp);
                    
                    axes(hAxisPD);
                    [colEndIdx, rowEndIdx, leftClickTF] = ginput(1);
                    colEndIdx = round(colEndIdx);
                    rowEndIdx = round(rowEndIdx);
                    colEndIdx = min(max(colEndIdx, minColIdx), maxColIdx);
                    rowEndIdx = min(max(rowEndIdx, minRowIdx), maxRowIdx);
                    
                    if not(leftClickTF)
                        aiss.inSelectionModeTF = false;
                        return;
                    end
                    
                    aiss.dispLineImg = insertShape(aiss.dispLineImg, 'Line',[colStartIdx rowStartIdx, colEndIdx rowEndIdx], 'LineWidth', 3, 'Color', color);
                    set(hImg, 'CData', aiss.dispLineImg);
                    drawnow();
                    
                    aiss.inSelectionModeTF = false;
                    
                    if(not(colEndIdx == colStartIdx) || not(rowEndIdx == rowStartIdx))
                        fn_on_line_selection(colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color);
                        aiss.nextColorIdx = mod(aiss.nextColorIdx, aiss.numColors) + 1;
                    end
            end
        end
    end
end