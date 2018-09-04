function [ hsps_table, hsps_vectors ] = parse_vtrace( vtrace )
%P1_PARSE_p1_vtrace Summary of this function goes here
%   Detailed explanation goes here
vtrace = flipud(vtrace);
hsps_table = [];
prev_st = vtrace(1, 2);
hsps_table(1, 1) = vtrace(1, 1);
hsps_table(1, 3) = vtrace(1, 3);

function fill_table(j)
    hsps_table(end, 2)      = vtrace(j - 1, 1);
    hsps_table(end, 4)      = vtrace(j - 1, 3);
    hsps_table(end + 1, 1)  = vtrace(j, 1);
    hsps_table(end, 3)      = vtrace(j, 3);
end

for i = 2:size(vtrace, 1)
    switch vtrace(i, 2)
        case 11
            if prev_st == 11
                if vtrace(i-1, 3) + 1 ~= vtrace(i, 3)
                    fill_table(i);
                end
            else
                fill_table(i);
            end
        case 12
            if prev_st == 12
                if vtrace(i-1, 3) - 1 ~= vtrace(i, 3)
                    fill_table(i);
                end
            else
                fill_table(i);
        end
    case {9, 10}
        if (prev_st == 11 || prev_st == 12)
            fill_table(i-1);
        end
    case 3
        if (vtrace(i+1, 2) == 11 || vtrace(i+1, 2) == 12)
            hsps_table(1, 1) = vtrace(i+1, 1);
            hsps_table(1, 3) = vtrace(i+1, 3);
        end
    case 4
        hsps_table(end, 2)      = vtrace(i - 1, 1);
        hsps_table(end, 4)      = vtrace(i - 1, 3);
        break;
    end 
    prev_st = vtrace(i, 2);
end
if (vtrace(end, 2) == 11 || vtrace(end, 2) == 12)
    hsps_table(end, 2) = vtrace(end, 1);
    hsps_table(end, 4) = vtrace(end, 3);
end

hsps_table(any([hsps_table == 0]'), :) = [];

hsps_vectors.query      = [];
hsps_vectors.subject    = [];

for i = 1:size(hsps_table, 1)
    hsps_vectors(i).query   = vtrace(hsps_table(i, 1):hsps_table(i, 2), 1);
    hsps_vectors(i).subject = vtrace(hsps_table(i, 1):hsps_table(i, 2), 3);
end

end

