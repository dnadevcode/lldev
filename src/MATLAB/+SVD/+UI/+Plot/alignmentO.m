function [] = plot_alignment(hAxis, alignedSeq, refSeqForAlignment, refSeqLegendText)
    %Plots the longest barcode repeated twice together with the
    % second barcode stretched according to the alignment path in the axes
    % provided
    if nargin < 4
        refSeqLegendText = 'Reference Sequence';
    end
    
    plot(hAxis, refSeqForAlignment);
    hold(hAxis, 'on');
    plot(hAxis, alignedSeq, 'LineWidth', 1.5);
    legend(hAxis, refSeqLegendText, 'Aligned Sequence');
    ylabel(hAxis, 'Intensity')
    xlabel(hAxis, 'Index')
    title(hAxis, 'Aligned Sequences')
    hold(hAxis, 'off');
    xlim(hAxis, [0 length(refSeqForAlignment)]);
end