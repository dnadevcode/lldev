function alignment( vitResults, barcode1, barcode2, ax )
%ALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
    import SVD.Core.HMM.parse_vtrace;

    if nargin > 3
        if class(ax) ~= 'matlab.graphics.axis.Axes'
            ax = gca;
        end
    else
        ax = gca;
    end
            
    [res_table, res_vectors] = parse_vtrace(vitResults);
    plot(ax, barcode2, 'color', 'black');
    hold(ax, 'on');
    for i = 1:length(res_table(:, 1))
        plot(ax, res_table(i, 1):res_table(i, 2), barcode1(res_vectors(i).subject), 'LineWidth',2);
    end
    set(ax, 'XLim', [0 length(barcode2)]);
    hold(ax, 'off');

end

