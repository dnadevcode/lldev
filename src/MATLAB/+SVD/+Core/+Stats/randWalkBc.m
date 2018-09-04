function [ randBc ] = randWalkBc( len )
    function x = rho()
        x = randi([400 700])/1000;
    end

    function x = rhol()
        if rand < 0.99
            x = 0.999;
        else
            x = 0;
        end
    end

randBc = normrnd(0, 1, 1, len);
randBcl = normrnd(0, 1, 1, len);
for i = 2:len
    randBc(i) = (randBc(i-1) * rho) + randBc(i);
    randBcl(i) = (randBcl(i-1) * rhol) + randBcl(i);
end

randBcl = zscore(imgaussfilt(randBcl, 10));
randBc = zscore(imgaussfilt(randBc+randBcl, 1.884));

end
