function [ psfSigmaWidth_nm, deltaCut, pixelWidth_nm,meanBpExt_nm,yoyoConc,saltConc,temp] = get_mmt_settings(default_psfSigmaWidth_nm, default_deltaCut, default_pixelWidth_nm,default_meanBpExt_nm,default_yoyoConc,default_saltConc,default_temp)

    psfSigmaWidth_nm = default_psfSigmaWidth_nm;
    deltaCut = default_deltaCut;
    pixelWidth_nm = default_pixelWidth_nm;
    meanBpExt_nm = default_meanBpExt_nm;
    yoyoConc = default_yoyoConc;
    saltConc = default_saltConc;
    temp = default_temp;
    % Set a threshold for grouping barcodes.
    answer = inputdlg(...
        { ...
            'Point Spread Function Sigma Width (nm)', ...
            'Pixel width (nm)', ...
            'Mean bp/nm extension',...
            'Delta Cut (edge length as multiple of PSF width in pixels))' ...
            'YOYO-1 concentration', ...
            'Salt concentration', ...
            'Temperature', ...
        }, ... % prompt
        'MMT generation Parameters', ... % dialog title
        1, ... % number of lines
        { ...
            num2str(psfSigmaWidth_nm), ...
            num2str(pixelWidth_nm), ...
            num2str(meanBpExt_nm), ...
            num2str(deltaCut), ...
            num2str(yoyoConc), ...
            num2str(saltConc), ...
            num2str(temp), ...
        }... % default value
    );
    if ~isempty(answer)  
        psfSigmaWidth_nm = str2double(answer{1});
        pixelWidth_nm = str2double(answer{2});
        meanBpExt_nm = str2double(answer{3});
        deltaCut = str2double(answer{4});
        yoyoConc = str2double(answer{5});
        saltConc = str2double(answer{6});
        temp = str2double(answer{7});
    end
    
    isAcceptable = struct;
    isAcceptable.psfSigmaWidth_nm = (psfSigmaWidth_nm >= 0);
    isAcceptable.meanBpExt_nm = (meanBpExt_nm > 0);
    isAcceptable.pixelWidth_nm = (pixelWidth_nm > 0);

    isAcceptable.deltaCut = (deltaCut >= 0);
    isAcceptable.yoyoConc = (yoyoConc >= 0);
    isAcceptable.saltConc = (saltConc >= 0);
    isAcceptable.temp = (temp >= 0);

    if not(isAcceptable.psfSigmaWidth_nm)
        psfSigmaWidth_nm = default_psfSigmaWidth_nm;
        warning('Bad input for PSF width! Try again!');
    end
    if not(isAcceptable.pixelWidth_nm)
        pixelWidth_nm = default_pixelWidth_nm;
        warning('Bad input pixel width! Try again!');
    end
    if not(isAcceptable.deltaCut)
        deltaCut = default_deltaCut;
        warning('Bad input for Delta Cut! Try again!');
    end
    
    if not(isAcceptable.deltaCut)
        deltaCut = default_deltaCut;
        warning('Bad input for Delta Cut! Try again!');
    end
end