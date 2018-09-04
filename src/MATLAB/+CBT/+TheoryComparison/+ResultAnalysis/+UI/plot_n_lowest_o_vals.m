function [] = plot_n_lowest_o_vals(axLowestOvals, numEntries, outlierScoresMatrixLowest, nLowest, alpha)
    if nargin < 5
        alpha = [];
    end
    colors = flipud(permute(hsv(nLowest), [1, 3, 2]));
    xs = repmat((1:numEntries), nLowest, 1);
    group = repmat((1:nLowest)', 1, numEntries);
    axes(axLowestOvals);
    gscatter(xs(:), outlierScoresMatrixLowest(:), group(:), colors, '.', [], 'off');
    xlim(axLowestOvals, [1, numEntries]);
    set(axLowestOvals, 'yscale', 'log') 
    if not(isempty(alpha))
        hold(axLowestOvals, 'on');
        plot(axLowestOvals, get(gca, 'xlim'), [alpha; alpha], 'k--');
    end
end
