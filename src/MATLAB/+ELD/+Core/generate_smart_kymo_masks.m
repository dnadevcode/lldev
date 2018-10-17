function [ signalBitmask , backgroundBitmask , effectiveness] = generate_smart_kymo_masks( kymoImg, psfWidth, maxGapLen, minSegmentLen, dilationFactor, numThresholds )

figure;
imagesc(kymoImg);

nanMask = isnan(kymoImg);
kymoImg(nanMask) = 0;

[thresh , effectiveness] = multithresh(kymoImg, numThresholds);
quantImg = imquantize(kymoImg, thresh) - 1;

figure;
imagesc(quantImg);

signalBitmask = quantImg > 0;
% figure;
% imagesc(signalBitmask);

signalBitmask = imclose(signalBitmask, ones(max(1,1+maxGapLen),2));
% figure;
% imagesc(signalBitmask);

signalBitmask = imopen(signalBitmask, ones(max(1,1+minSegmentLen),1+round(psfWidth-1)));
% figure;
% imagesc(signalBitmask);

signalBitmask = imdilate(signalBitmask, ones(1,max(3,1+2*round(psfWidth/2*dilationFactor))));
% figure;
% imagesc(signalBitmask);

signalBitmask = imclose(signalBitmask, ones(2,2));
% figure;
% imagesc(signalBitmask);

signalBitmask(nanMask) = 0;

backgroundBitmask = ~quantImg.*~signalBitmask;
figure;
imagesc(backgroundBitmask);

backgroundBitmask(nanMask) = 0;

end

