function [] = plot_hists(hAxis, histS)

    colorTriplets = [...
        0 0 1; ... % blue
        0 0.5 0; ... % green
        1 0 0; ... % red
        1 0 1; ... % magenta
        0 0.7 0.8; ... % iris blue
        0.9 0.7 0.3; ... % orange-yellow, ronchi
        0 0 0; ... % black
        0.5 0.5 0.5 ... % gray
    ];
    hold(hAxis, 'on');
    nextColorIdx = 1;
    legendHist = cell(1,length(histS(1,:)));
    for idxHist = 1:size(histS, 2)
        sTotVal = num2str(round(10000*histS(3,idxHist))/10000);
        coverage = histS(4,idxHist);
        bar(hAxis, histS(1,idxHist), ...
            'FaceColor', colorTriplets(nextColorIdx,:));
        nextColorIdx = 1 + mod(nextColorIdx, length(triplet));
        legendHist{idxHist} = sprintf('s-value: %g, coverage: %g %%', sTotVal, coverage);
    end
    legend(hAxis, legendHist, 'Location', 'eastoutside');
    xlabel(hAxis, 'Branch index');
    ylabel(hAxis, 'Number of identical branches');
    set(hAxis, 'YTick',round(linspace(0,max(histS(1,:)),11)*10)/10);
    set(hAxis, 'XTickLabel',histS(2,:));
    set(hAxis, 'XTick',1:numel(histS(2,:)));
    xlim(hAxis, [0.5 numel(histS(2,:))+0.5]);
    ylim(hAxis, [0 max(histS(1,:))]);
end