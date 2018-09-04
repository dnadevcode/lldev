function alignmentMatrix( vitResults, barcode1, barcode2, ax )
%PLOT Summary of this function goes here
%   Detailed explanation goes here
    import Barcoding.Helpers.discretize_barcodes;
    import SVD.Core.HMM.profile_build;
    import SVD.Core.HMM.parse_vtrace;
    import SVD.Core.HMM.match_matrix;

    if nargin > 3
        if class(ax) ~= 'matlab.graphics.axis.Axes'
            ax = gca;
        end
    else
        ax = gca;
    end
    
    d_bc1 = discretize_barcodes(barcode1);
    p_bc1 = profile_build(d_bc1);
    d_bc2 = discretize_barcodes(barcode2);

    [res_table, res_vectors] = parse_vtrace(vitResults);
    hmdata = match_matrix(p_bc1, d_bc2);
    imagesc(ax, power(10, hmdata'));    
    colormap(bone);
    hold(ax, 'on');
    plot(ax, 0, 0);
    for i = 1:length(res_table(:, 1))
        plot(ax, res_vectors(i).query, res_vectors(i).subject, 'LineWidth',2);
    end
    set(ax, 'XLim', [0 length(barcode2)]);
    hold(ax, 'off');
end

