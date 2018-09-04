classdef MainPhoneDataAppState < handle
    % MAINPHONEDATAAPPSTATE - Class to manage stat of phone data app
    %
    % Authors:
    %   Saair Quaderi
    
    properties
        dispImg
        coordsMap
        colorsMap
        barcodesMap
    end
    
    methods
        function [mpdas] = MainPhoneDataAppState()
            mpdas.set_to_init_state();
        end
        function mpdas = set_to_init_state(mpdas)
            mpdas.dispImg = [];
            mpdas.coordsMap = containers.Map();
            mpdas.colorsMap = containers.Map();
            mpdas.barcodesMap = containers.Map();
        end
        function [htmlStrCoords] = add_line_coords_to_state(mpdas, colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color)
            import PD.MainPhoneDataAppState;
            htmlStrCoords = MainPhoneDataAppState.html_stringify_colored_line_coords(colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color);
            mpdas.coordsMap(htmlStrCoords) = [colStartIdx, rowStartIdx, colEndIdx, rowEndIdx];
            mpdas.colorsMap(htmlStrCoords) = color;
            layerOffsets = -1:1;
            import Microscopy.Utils.get_rgb_data;
            mpdas.barcodesMap(htmlStrCoords) = get_rgb_data(mpdas.dispImg, colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, layerOffsets);
        end
        function [linesCoords, linesBgColor, linesBarcodesArr] = get_lines(mpdas, selectionHtmls)
            linesCoords = cellfun(@(selectionHtml) mpdas.coordsMap(selectionHtml), selectionHtmls, 'UniformOutput', false);
            linesBgColor = cellfun(@(selectionHtml) mpdas.colorsMap(selectionHtml), selectionHtmls, 'UniformOutput', false);
            linesBarcodesArr = cellfun(@(selectionHtml) mpdas.barcodesMap(selectionHtml), selectionHtmls, 'UniformOutput', false);
        end
    end
    methods (Static)
        function str = html_stringify_colored_line_coords(colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, color)
            str = sprintf('[(%d, %d) - (%d, %d)]', colStartIdx, rowStartIdx, colEndIdx, rowEndIdx);
            colorHex = sprintf('#%s', sprintf('%02X',round(color*255).')); 
            str = sprintf('<HTML><FONT color="%s">%s</FONT></HTML>', colorHex, str);
        end
    end
end