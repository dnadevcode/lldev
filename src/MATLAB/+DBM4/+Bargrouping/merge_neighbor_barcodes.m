function [barGenMerged,posMulti,cnt_unique] = merge_neighbor_barcodes(barcodeGen)

minOverlap = 300; 
% kymoStructs
pxMask = 10;

% put this in merge_barcodes function
% merge barcodes that come from the same molecule: fomrat mol-X-N mol-X-N
barName = zeros(1,length(barcodeGen)+1);
curBar = zeros(1,length(barcodeGen)+1);
for i=1:length(barcodeGen)
    name = strsplit(barcodeGen{i}.name,'mol-');
    name1=strsplit(name{2},'_molecule');
    nameFinal = strsplit(name1{1},'-');
    barName(i+1) = str2num(nameFinal{1});
    if length(nameFinal) >1 &&  barName(i+1)== barName(i) 
        curBar(i+1) = curBar(i);
    else
        curBar(i+1) =i;
    end
end

%% merge
sF = 1;
% minOverlap = 300;
tic
oSneighbor = [];
uniqueBars = unique(curBar(2:end));
[cnt_unique, unique_a] = hist(curBar(2:end),unique(curBar(2:end)));

posMulti = find(cnt_unique>=2);


timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');

import Core.calc_overlap_pcc_sort_m;


bgfov = cell(1,length(posMulti));
oSneighbor = cell(1,length(posMulti));
for i=1:length(posMulti)
    uE = unique_a(posMulti(i));
    cE = cnt_unique(posMulti(i));
    % from the same movie, keep only the longer molecule. / maybe this
    % information should be kept already in the kymoStructs, so we don't
    % need to call it back here
    
    bgfov{i}.bars = barcodeGen(uE:uE+cE-1);
    % use MP overlap
    [oSneighbor{i}] = calc_overlap_mp(bgfov{i}.bars,sF, minOverlap,timestamp);
%     [oSneighbor{i}] = calc_overlap_pcc_sort_m(bgfov{i}.bars, sF,minOverlap);
end

%% Todo: deal with multi-mols from the same sample

%%
posSingle = unique_a(find(cnt_unique==1));
barGenMerged = cell(1,length(posSingle)+length(posMulti));

for j=1:length(posSingle)
    barGenMerged{j}.rawBarcode = barcodeGen{posSingle(j)}.rawBarcode;%mean(kymoStructs{posSingle(j)}.alignedKymo,1);
    barGenMerged{j}.rawBitmask = barcodeGen{posSingle(j)}.rawBitmask;%logical(~isnan(  barGenMerged{j}.rawBarcode));
	barGenMerged{j}.data =  barcodeGen{posSingle(j)};
    barGenMerged{j}.idx = posSingle(j);
end
% 

% average the multi-frame barcodes
for i=1:length(posMulti)
    numAvgBars = size(oSneighbor{i},2);
    
    % todo: number is lower if there are multi ones in the same, so check
    % if there is mol 1/2
    shift = zeros(2,numAvgBars-1); % could copy something similar to this/but simplified that is bargrouping code..
    twoBars = cell(1,numAvgBars-1);
    curSc = [];
    for j=1:numAvgBars-1
        pB = oSneighbor{i}(j,j+1).pA;
        pA = oSneighbor{i}(j,j+1).pB;
        lenA = length(bgfov{i}.bars{j}.rawBarcode);
        lenB = length(bgfov{i}.bars{j+1}.rawBarcode);

        stIdx = min(pA,pB);
        pA  = pA-stIdx+1;
        pB = pB-stIdx+1;
        stopIdx =max(pA+lenA-1,pB+lenB-1);

        % 
        twoBars{j} = nan(2,stopIdx-stIdx+1);

        tmpBar = bgfov{i}.bars{j}.rawBarcode;
        tmpBar2 = bgfov{i}.bars{j+1}.rawBarcode;
        tmpBar(~bgfov{i}.bars{j}.rawBitmask) = nan;
        tmpBar2(~ bgfov{i}.bars{j+1}.rawBitmask) = nan;
        twoBars{j}(1,pA:pA+lenA-1)= tmpBar;
        twoBars{j}(2,pB:pB+lenB-1)= tmpBar2;

        shift(:,j) = [pA;pB];
        curSc = [curSc oSneighbor{i}(j,j+1).score];

    end
    
    pAFinal = shift(1,1);
    
    pBFinal = [];
    pBFinal(1) = shift(2,1);
    for j=2:numAvgBars-1
        pBFinal(j) = -shift(1,j)+ pBFinal(j-1)+shift(2,j);
    end

    lenbar = zeros(numAvgBars,1);
   for j=1:numAvgBars
        lenbar(j) = length(bgfov{i}.bars{j}.rawBarcode);
   end
   
   allSt = [pAFinal pBFinal];
   allSt = allSt-min(allSt)+1;
   
   stopIdx =max([allSt+lenbar'-1]);

   finalBar = nan(numAvgBars,stopIdx);
%     pMin = min(shift(:,1));
    for j=1:numAvgBars
        tmpBar = bgfov{i}.bars{j}.rawBarcode;
        tmpBar(~bgfov{i}.bars{j}.rawBitmask) = nan;
        finalBar(j,allSt(j):allSt(j)+lenbar(j)-1)= tmpBar;
    end
     barGenMerged{length(posSingle)+i}.rawBarcode = nanmean(finalBar);
     barGenMerged{length(posSingle)+i}.rawBitmask = ~isnan(barGenMerged{length(posSingle)+i}.rawBarcode);
	barGenMerged{length(posSingle)+i}.rawBarcode(isnan( barGenMerged{length(posSingle)+i}.rawBarcode)) = min( barGenMerged{length(posSingle)+i}.rawBarcode);

    barGenMerged{length(posSingle)+i}.alignedBars = finalBar;
    
    % just save info about original barcodes from bargen
    uE = unique_a(posMulti(i));
    cE = cnt_unique(posMulti(i));

    barGenMerged{length(posSingle)+i}.idx = uE:uE+cE-1;
    barGenMerged{length(posSingle)+i}.score = curSc;

%          barGenMerged{length(posSingle)+i}.data =  kymoStructs{posSingle(j)};

end
        
    

end

% %%
% i = 13 ;
% uE = unique_a(posMulti(i));
% cE = cnt_unique(posMulti(i))
% 
% % cE = cnt_unique(posMulti(i));
% 
% barStruct = cell2struct([cellfun(@(x) double(x.rawBarcode),bgfov{i}.bars,'un',false);...
%     cellfun(@(x) x.rawBitmask,bgfov{i}.bars,'un',false)]',{'rawBarcode','rawBitmask'},2);
% % 
% % % plot mp result
% % import Core.plot_match_pcc;
% % [f] = plot_match_pcc(barStruct, oSneighbor{i},1, 2,barStruct,nan);
% ii= 1;
% import Core.plot_match_simple;
% [f] = plot_match_simple(barStruct, oSneighbor{i},ii,ii+1);
% 
% % [f] = plot_match_simple(barStruct, oSneighbor{i},3,5);
% 
% cellfun(@(x) length(x.rawBarcode),barGenMerged)
%     
% % plot lengths
% figure, plot(cellfun(@(x) length(x.rawBarcode),barGenMerged))
% figure,plot(barGenMerged{length(posSingle)+10}.alignedBars')
% 
% % maxInt = cellfun(@(x) max(x.data.unalignedKymo(:)),barGenMerged(1:length(posSingle)));
% % minInt = cellfun(@(x) min(x.data.unalignedKymo(:)),barGenMerged(1:length(posSingle)));
% 
% % figure 
% % plot(pA:pA+lenA-1,barcodeGen{i}.rawBarcode)
% % hold on
% % plot(pB:pB+lenB-1,barcodeGen{i+1}.rawBarcode)
% 
% % figure,plot(twoBars{1}')
% % newBar = nanmean(twoBars);
% % newBit = isnan(newBar);
% %    end     
%         
% 
