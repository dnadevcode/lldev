function [ curve_pxRes ] = pixelate(curve_bpRes, bpsPerPixel)
    bpsPerPixel = floor(bpsPerPixel) ;
    curveLen_bps = length(curve_bpRes) ;
    curveLen_pxs = floor(curveLen_bps/bpsPerPixel);
    remainder_bps = curveLen_bps - curveLen_pxs*bpsPerPixel;
    m1 = (remainder_bps + mod(remainder_bps,2))/2 ;
    m2 = (remainder_bps - mod(remainder_bps,2))/2 ;
    curve_pxRes = zeros([1 curveLen_pxs+2]) ;
    curve_pxRes(1) = mean(curve_bpRes(1:m1)) ;
    curve_pxRes(curveLen_pxs+2) = mean(curve_bpRes((m1+curveLen_pxs*bpsPerPixel+1):(m1+curveLen_pxs*bpsPerPixel+m2))) ;
    for k = 2:(curveLen_pxs+1)
        curve_pxRes(k) = mean(curve_bpRes((m1+bpsPerPixel*(k-2)+1):(m1+bpsPerPixel*(k-1)))) ;
    end
end