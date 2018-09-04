function comparison( vitResults, barcode1, barcode2, ax )
%COMPARISON Summary of this function goes here
%   Detailed explanation goes here  
    import SVD.Core.HMM.parse_vtrace;

    if nargin > 4
        if class(ax) ~= 'matlab.graphics.axis.Axes'
            ax = gca;
        end
    else
        ax = gca;
    end
    ColOrd = get(ax, 'ColorOrder');
    barcode1 = zscore(barcode1);
    barcode2 = zscore(barcode2);
    ylmax = max(barcode1);
    ylmin = min(barcode1);
    yumax = max(barcode2+8);
    yumin = min(barcode2+8);  
    
    plot(ax, barcode1, 'Color', 'black')
    hold on;
    plot(ax, barcode2+8, 'Color', 'black');
    [res_table, ~] = parse_vtrace(vitResults);
    for i = 1:size(res_table, 1)
        pX = res_table(i, [1 1 2 2 4 4 3 3]);
        pX = pX + [-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5];
        pY = [yumin yumax yumax yumin ylmax ylmin ylmin ylmax];
        pY = pY + [0 0.5 0.5 0 0 -0.5 -0.5 0 ];
        patch(pX, pY, ColOrd(1+mod(i, 7), :), 'faceAlpha', 0.1, ...
              'edgeAlpha', 0.3, 'edgeColor', ColOrd(1+mod(i, 7), :));
    end
    hold off;
end

