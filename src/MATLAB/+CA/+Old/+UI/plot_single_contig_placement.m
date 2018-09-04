function [] = plot_single_contig_placement(hAxis, placedContigBarcode, rescaledConcensusBarcode, consensusBarcodeName, bestCC, mirrorContigTF)
    if nargin < 6
        mirrorContigTF = false;
    end
    
    titleStr = sprintf('Best place for contig on %s', consensusBarcodeName);
    xlabelStr = sprintf('Best CC=%g', bestCC);

    if mirrorContigTF
        xlabelStr = sprintf('%s, (The contig is mirrored)', xlabelStr);
    end

    hold(hAxis, 'on');
    plot(hAxis, rescaledConcensusBarcode,'r-.','linewidth',2);
    plot(hAxis, placedContigBarcode,'linewidth',2);
    hold(hAxis, 'off');


    title(hAxis, titleStr, 'interpreter', 'none');
    xlabel(hAxis, xlabelStr, 'interpreter', 'none');
end