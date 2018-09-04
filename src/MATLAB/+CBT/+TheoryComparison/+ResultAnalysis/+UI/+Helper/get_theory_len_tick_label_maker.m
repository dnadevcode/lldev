function [fn_theory_len_tick_labeler] = get_theory_len_tick_label_maker(theoryLengths_bp)
    fn_theory_len_tick_labeler = @(idx) sprintf('%d kbp', round(theoryLengths_bp(idx)/1000));
end