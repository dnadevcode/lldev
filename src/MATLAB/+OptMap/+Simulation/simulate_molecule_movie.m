function [ movie ] = simulate_molecule_movie( sets )
    % simulate_molecule_movie for tool testing
    %
    % :param settings: input parameter.
    % :returns: output
    
    % rewritten by Albertas Dvirnas
    
    sets.angle = 75.8; % general angle in the movie
    sets.anglevariance = 0; % should all molecules have the same angle?
    
    sets.xdim = 512; % xdimension, i.e. columns
    sets.ydim = 512;  % ydim, i.e. rows
    
	sets.framenum = 20;  % number of frames
    sets.framemov = 2; % maximal molecule movement between frames
    
    sets.stretch = 0.05; % +- this percentage of stretching 
	sets.length = 100; % +- this percentage of stretching 
	sets.psf = 300/130; % +- this percentage of stretching 
    
    sets.nummols = 10; 
    
    sets.varsignal = (0.5/3).^2; % variance signal
	sets.varnoise = sets.varsignal;  % variance noise. how good signal to noise we want?

    snr = sets.varsignal/sets.varnoise ;
    
    movie = zeros(sets.ydim,sets.xdim,sets.framenum );
    
    sets.zeros = 10;
    
    sets.channeldif = 10; % minimum px distance between channels
    
    % Gaussian filter
    N = 11; %// Define size of Gaussian mask
    sigma = sets.psf  ; %// Define sigma here

    %// Generate Gaussian mask
    ind = -floor(N/2) : floor(N/2);
    [X Y] = meshgrid(ind, ind);
    h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
    h = h / sum(h(:));
    %// Convert filter into a column vector
    h = h(:);
        
    % transformation by an angle
    R = [cosd(sets.angle) sind(sets.angle) 0;-sind(sets.angle) cosd(sets.angle) 0;0 0 1];
    tform_r = affine2d(R);
    
    posx = zeros(1,sets.nummols);
    randv = cell(1,sets.nummols);
    
    % actual theory barcode. here random
    rv = normrnd(0.5,sqrt(sets.varsignal), 1,sets.length);
    
    % y position
    posy = sets.channeldif*randperm(round(sets.ydim/sets.channeldif),sets.nummols);
        
    for j=1:sets.nummols
        % x position
        posx(j) = randi( sets.xdim ,1);
        % actual molecule before applying filter
        randv{j} = [zeros(1,sets.zeros) rv zeros(1,sets.zeros)];
    end
    
    mv = cell(1,sets.framenum);
    
    for i=1:sets.framenum 
        i
        % compute the random barcode using 
        img = zeros(sets.ydim,sets.xdim);
        for j=1:sets.nummols
            % newpos
            posx(j) = max(1,posx(j)+randi(2*sets.framemov)-sets.framemov-1);
            % new strfac
            strfac = 0.1*rand-0.05;
            vq = interp1(1:length(randv{j}),randv{j},1:1/(1+strfac):length(randv{j}));

            img(posy(j),posx(j):min(posx(j)+length(vq)-1,sets.xdim)) = vq(1:length(posx(j):min(posx(j)+length(vq)-1,sets.xdim)));
        end
        
        %// Filter our image
        I_pad = padarray(img, [floor(N/2) floor(N/2)]);
        C = im2col(I_pad, [N N], 'sliding');
        C_filter = sum(bsxfun(@times, C, h), 1);
        out = col2im(C_filter, [N N], size(I_pad), 'sliding')*max(img(:))/max(C_filter(:));


        [mv{i},out_ref] = imwarp(out,tform_r);
        mv{i} = mv{i}+normrnd(0.4,sqrt(sets.varnoise), size(mv{i},1),size(mv{i},2));
    end  
    
    ff = '/home/albyback/git/rawData/AB/sim/';
   % ff = '/media/albyback/My Passport/DATA/AB_Testing/sim/';
  %  figure,imshow(mv{4},[])
    
    foldful = strcat( [ ff num2str(snr) '_' num2str(randi(100)) '_movie.tif']);
    imwrite(mv{1},foldful)
    for i =2:length(mv)
        imwrite(mv{i},foldful,'WriteMode','append');
    end

    


end

