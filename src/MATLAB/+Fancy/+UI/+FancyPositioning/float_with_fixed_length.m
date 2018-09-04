function posPx = float_with_fixed_length(dir, posPx, fixedLengthPx)
    if ((dir == 'L') || (dir == 'R'))
        if (dir == 'R')
            posPx(1) = posPx(1) + posPx(3) - fixedLengthPx;
        end
        posPx(3) = fixedLengthPx;
    elseif ((dir == 'T') || (dir == 'B'))
        if (dir == 'T')
            posPx(2) = posPx(2) + posPx(4) - fixedLengthPx;
        end
        posPx(4) = fixedLengthPx;
    end
end