classdef DataBED < handle
    %DATABED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
        HeaderOptions = {
            'useScore' %relevant if NumFields>=5
            };
        
        FieldNames = {...
            'chrom';...
            'chromStart';...
            'chromEnd';...
            'name';...
            'score';...
            'strand';...
            'thickStart';...
            'thickEnd';...
            'itemRgb';...
            'blockCount';...
            'blockSizes';...
            'blockStarts'...
        }
        FieldTypes = {
            {'String'};...
            {'Integer'; '>='; 0};...
            {'Integer'; '>='; 'chromEnd'};...
            {'String'};...
            {'Integer'; '>='; 0; '<='; 1000};...
            {'String:+/-'};...
            {'Integer'; '>='; 'chromStart'; '<='; 'chromEnd'};...
            {'Integer'; '>='; 'thickStart'; '<='; 'chromEnd'};...
            {'String:Integer,Integer,Integer'; ',-Delimited'; 'Each'; '>='; 0; 'Each'; '<='; 255};...
            {'Integer'; '>='; 0};... %<= number of exons possible in seq of length chromEnd - chromStart
            {'String:Integer,...,Integer'; ',-delimited'; '#entries'; '='; 'blockCount'};...
            {'String:Integer,...,Integer'; ',-delimited'; '#entries'; '='; 'blockCount'};...
         };
    end
    properties
        NumFields
        HeaderLines
        HeaderLineTypes
        Delimiter
    end
    
    methods
        function [db] = DataBED(fileStr)

            fieldEntries = vertcat(fieldEntries{:});
            for fieldNum=1:numFields
                fieldName = DataBED.FieldNames{fieldNum};
                
            end
            
            numFields = size(dataCells, 2);
            db.HeaderLines = headerLines;
            db.Delimiter = delimiter;
            db.NumFields = numFields;
        end
    end
    
    methods (Static)
        function [errMsg, headerLines, fieldEntries] = parse_bed_file_str(fileStr)
            
            fileLines = textscan(fileStr,'%s','Delimiter','\n');
            numLines = length(fileLines);
            isHeaderLine = true;
            lineNum = 1;
            while isHeaderLine && (lineNum <= numLines)
                strLine = fileLines{lineNum};
                [isHeaderLine, headerLineType] = DataBED.is_header_line(strLine);
                lineNum = lineNum + 1;
            end
            headerLines = fileLines(1:(lineNum - 1));
            bodyLines = fileLines(lineNum:end);
            
            fieldEntries = [];
            
            if lineNum > numLines
                errMsg = 'No BED data lines';
                return;
            end
            
            fieldEntriesStrs = cellfun(@(fileLine) textscan(fileLine,'%s'), bodyLines, 'UniformOutput', false);
            numFieldsInLines = cellfun(@length, fieldEntriesStrs);
            numFields = numFieldsInLines(1);
            if numFields < 3
                errMsg = 'Missing required fields';
                return;
            end
            if any(numFields ~= numFieldsInLines)
                errMsg = 'Inconsisent number of fields';
                return;
            end
            fieldEntries = fieldEntriesStrs;
            fieldEntries(:, 2) = cellfun(@(chromStartStr) str2num(['uint64(', chromStartStr, ')']), fieldEntriesStrs(:, 2), 'UniformOutput', false);
            if  not(isequal(fieldEntriesStrs(:, 2), cellfun(@num2str, fieldEntries(:, 2), 'UniformOutput', false)))
                errMsg = 'Invalid entries for chromStart';
                return;
            end
            fieldEntries(:, 3) = cellfun(@(chromEnd) str2num(['uint64(', chromEnd, ')']), fieldEntriesStrs(:, 3), 'UniformOutput', false);
            if  not(isequal(fieldEntriesStrs(:, 3), cellfun(@num2str, fieldEntries(:, 3), 'UniformOutput', false)))
                errMsg = 'Invalid entries for chromEnd';
                return;
            end
            
            chromStarts = cell2mat(fieldEntries(:, 2));
            chromEnds = cell2mat(fieldEntries(:, 3));
            
            if any(chromEnds <= chromStarts)
                errMsg = 'Inconsistency between entries for chromStart and chromEnd';
                return;
            end
            
            if numFields >= 5
                fieldEntries(:, 5) = cellfun(@(score) str2double(score), fieldEntriesStrs(:, 5), 'UniformOutput', false);

                scores = cell2mat(fieldEntries(:, 5));
                if any(isnan(scores)) || any(scores < 0) || any(scores > 1000) || any(cellfun(@isempty, fieldEntries(:, 5)))
                    errMsg = 'Invalid entries for score';
                    return;
                end
            end
            
            if numFields >= 6
                fieldEntries(:, 6) = cellfun(@(strand) strcmp(strand, '+'), fieldEntriesStrs(:, 6), 'UniformOutput', false);

                if not(isequal(fieldEntriesStrs(:, 6), cellfun(@(tf) char(tf*-2 + 45), fieldEntries(:, 6), 'UniformOutput', false)))
                    errMsg = 'Invalid entries for strand';
                    return;
                end
            end
            
            if numFields >= 7
                fieldEntries(:, 7) = cellfun(@(thickStart) str2num(['uint16(', thickStart, ')']), fieldEntriesStrs(:, 7), 'UniformOutput', false);

                thickStarts = cell2mat(fieldEntries(:, 7));
                if  not(isequal(fieldEntriesStrs(:, 7), cellfun(@num2str, fieldEntries(:, 7), 'UniformOutput', false))) || (thickStarts < chromStarts) || (thickStarts > chromEnds - 1)
                    errMsg = 'Invalid entries for thickStart';
                    return;
                end
            end
            
            
            
            if numFields >= 8
                fieldEntries(:, 8) = cellfun(@(thickEnd) str2num(['uint16(', thickEnd, ')']), fieldEntriesStrs(:, 8), 'UniformOutput', false);

                thickEnds = cell2mat(fieldEntries(:, 8));
                if  not(isequal(fieldEntriesStrs(:, 8), cellfun(@num2str, fieldEntries(:, 8), 'UniformOutput', false))) || (thickEnds < thickStarts) || (thickEnds > chromEnds)
                    errMsg = 'Invalid entries for thickStart';
                    return;
                end
            end
            
            if numFields >= 9
                fieldEntries(:, 9) = cellfun(@(itemRgb) str2num(strjoin(strcat('uint8(', strsplit(itemRgb,','), ')'), ',')), fieldEntriesStrs(:, 9), 'UniformOutput', false);
                
                if any(cellfun(@length, fieldEntries(:, 9)) ~= 3) || not(isequal(cellfun(@(itemRgb) strjoin(arrayfun(@num2str, itemRgb, 'UniformOutput', false), ','), fieldEntries(:, 9), 'UniformOutput', false)))
                    errMsg = 'Invalid entries for itemRgb';
                end
            
            end
            
            if numFields >= 10
                fieldEntries(:, 10) = cellfun(@(blockCount) str2num(['uint16(', blockCount, ')']), fieldEntriesStrs(:, 10), 'UniformOutput', false);
            end
            if numFields >= 11
                fieldEntries(:, 11) = cellfun(@(blockSizes) str2num(['uint16(', blockSizes, ')']), fieldEntriesStrs(:, 11), 'UniformOutput', false);
            end
            if numFields == 12
                fieldEntries(:, 12) = cellfun(@(blockStarts) str2num(['uint16(', blockStarts, ')']), fieldEntriesStrs(:, 12), 'UniformOutput', false);
            end
            
        end
        function [isHeaderLine, headerLineType] = is_header_line(strLine)
            headerLineStartStrs = {'#'; 'browser'; 'track'};
            isHeaderLine = false;
            headerLineType = 'n/a';
            numHeaderLineStartTypes = length(headerLineStartStrs);
            for headerLineStartTypeNum = 1:numHeaderLineStartTypes
                headerLineStart = headerLineStartStrs{headerLineStartTypeNum};
                if (length(strLine) >= length(headerLineStart)) && strcmp(strLine(1:(length(headerLineStart))), headerLineStart)
                     isHeaderLine = true;
                     headerLineType = headerLineStart;
                end
            end
        end
    end
end

