function [] = show_aligned_kymo_time_avgs(dbmODW, hParent)

    [fgKymoTimeAvgs, fgKymoTimeAvgFileIdxs, fgKymoTimeAvgFileMoleculeIdxs] = dbmODW.get_all_existing_fg_kymo_time_avgs();

    [alignedKymos, ~, ~] = dbmODW.get_aligned_kymos(fgKymoTimeAvgFileIdxs, fgKymoTimeAvgFileMoleculeIdxs);
    
    numAlignedKymos = numel(alignedKymos);
    
    if numAlignedKymos < 1
        fprintf('Aligned kymographs must be generated before their averages can be plotted\n');
    end
    
    kymoTimeAvgs = cellfun(@(alignedKymo) nanmean(alignedKymo, 1), alignedKymos, 'UniformOutput', false);
    kymoTimeStds = cellfun(@(alignedKymo) std(alignedKymo, 0, 1, 'omitnan'), alignedKymos, 'UniformOutput', false);
    numsKymoFrames = cellfun(@(alignedKymo) size(alignedKymo, 1), alignedKymos);
    fgStartIdxs = cellfun(@(kymoTimeAvg, fgKymoTimeAvg) find_vect(kymoTimeAvg, fgKymoTimeAvg), kymoTimeAvgs, fgKymoTimeAvgs);
    fgEndIdxs = fgStartIdxs - 1 + cellfun(@length, fgKymoTimeAvgs);

    [kymoSrcFilenames] = dbmODW.get_molecule_src_filenames(fgKymoTimeAvgFileIdxs);
    
    import OldDBM.General.UI.Helper.get_header_texts;
    [headerTexts] = get_header_texts(fgKymoTimeAvgFileIdxs, fgKymoTimeAvgFileMoleculeIdxs, kymoSrcFilenames);


    import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
    hFgKymoTimeAvgAxes = generate_axes_grid(hParent, numAlignedKymos);
    
    import OldDBM.Kymo.UI.plot_aligned_kymo_time_avgs;
    plot_aligned_kymo_time_avgs(hFgKymoTimeAvgAxes, headerTexts, fgStartIdxs, fgEndIdxs, kymoTimeAvgs, kymoTimeStds, numsKymoFrames);


    function [startIdx] = find_vect(haystackVect, needleVect)
        if any(isnan(needleVect))
            startIdx = NaN;
            return;
        end
        % Todo: clean up, there's probably a much simpler/faster way
        haystackVect = haystackVect(:);
        needleVect = needleVect(:);
        needleLen = length(needleVect);
        [xcorrs, lags] = xcorr(haystackVect, needleVect);
        nanmask = isnan(xcorrs);
        xcorrs(nanmask) = -inf;
        [~, bestMatchIdx] = max(xcorrs);
        % xcorrs(nanmask) = NaN;
        offset = lags(bestMatchIdx);
        haystackMatchVect = haystackVect((1:needleLen) + offset);
        if not(isequal(haystackMatchVect, needleVect))
            startIdx = NaN;
        else
            startIdx = 1 + offset;
        end
    end
end