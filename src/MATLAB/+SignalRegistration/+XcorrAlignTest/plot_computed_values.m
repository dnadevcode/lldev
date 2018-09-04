function [] = plot_computed_values(scores, xcorrs, coverageLens, maxPossibleCoverageLen)
    hFig = figure();
    subplot(2, 3, 1);
    colormap('hot');
    imagesc(permute(xcorrs(1,:,:), [2 3 1]));
    title('no flip - xcorrs');

    subplot(2, 3, 2);
    colormap('hot');
    imagesc(permute(coverageLens(1,:,:)/maxPossibleCoverageLen, [2 3 1]));
    title('no flip - coverage lens');

    subplot(2, 3, 3);
    colormap('hot');
    imagesc(permute(scores(1,:,:), [2 3 1]));
    title('no flip - weighted scores');

    subplot(2, 3, 4);
    colormap('hot');
    imagesc(permute(xcorrs(2,:,:), [2 3 1]));
    title('flip - xcorrs');

    subplot(2, 3, 5);
    colormap('hot');
    imagesc(permute(coverageLens(2,:,:)/maxPossibleCoverageLen, [2 3 1]));
    title('flip - coverage lens');

    subplot(2, 3, 6);
    colormap('hot');
    imagesc(permute(scores(2,:,:), [2 3 1]));
    title('flip - weighted scores');
end