function [seq] = generate_a_test_sequence(seqLen)
    seq = rand(1, seqLen) - 0.5;

    % Another approach to make sequences with underlying patterns
%             if ((seqLen < 1) || (seqLen > 1000))
%                 error('Size must be between 1 and 1000.');
%             end
%             seq = (smooth(sum(idinput([1200 10 1],'sine',[],[]), 2), 100, 'moving'));
%             seq = seq(100:(end - 100))';
%             seq = seq - min(seq);
%             seq = seq/max(seq);
%             seq = seq - 0.5;
%             seq = interp1(seq, 1:1000/seqLen:1000);
end