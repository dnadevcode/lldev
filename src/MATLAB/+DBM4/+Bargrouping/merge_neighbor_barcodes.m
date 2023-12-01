function [barGenMerged, posMulti, cnt_unique] = merge_neighbor_barcodes(barcodeGen, minOverlap, sF, minMergeScore)
%   Merge neighbour barcodes
%
%   Args:
%       barcodeGen - cell structure with barcodes
%       minOverlap - minimum overlap length
%       minMergeScore - min score to merge barcodes
%       sF - how much rescalling to allow for neighbouring barcodes
%   Returns:
%       barGenMerged - cell structure with merged barcodes
%       posMulti - start positions of multi-frame barcodes
%       cnt_unique - counts for each barcode
    if nargin < 3 % todo: implement using this score
        sF = 1; % no re-scaling
        minMergeScore = 0.6; % minimum score for merging overlapping featues
    end
% minOverlap = 300; % minimum overlap between barcodes
% kymoStructs
% pxMask = 10;

% put this in merge_barcodes function
% merge barcodes that come from the same molecule: fomrat mol-X-N mol-X-N
barName = zeros(1,length(barcodeGen)+1);
curBar = zeros(1,length(barcodeGen)+1);
for i=1:length(barcodeGen)
    try
        name = strsplit(barcodeGen{i}.name,'mol-');
        name1=strsplit(name{2},'_molecule');
        nameFinal = strsplit(name1{1},'-');
        barName(i+1) = str2num(nameFinal{1});
        if length(nameFinal) >1 &&  barName(i+1)== barName(i) 
            curBar(i+1) = curBar(i);
        else
            curBar(i+1) =i;
        end
    catch
        curBar(i+1) = i; % bad format, so keep same
    end
end

%% merge
% minOverlap = 300;
tic
oSneighbor = [];
uniqueBars = unique(curBar(2:end));
[cnt_unique, unique_a] = hist(curBar(2:end),unique(curBar(2:end)));

posMulti = find(cnt_unique>=2);

timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');

%% Todo: deal with multi-mols from the same sample

%%
posSingle = unique_a(find(cnt_unique==1));
barGenMerged = cell(1,length(posSingle)+length(posMulti));

for j=1:length(posSingle)
    barGenMerged{j}.rawBarcode = barcodeGen{posSingle(j)}.rawBarcode;%mean(kymoStructs{posSingle(j)}.alignedKymo,1);
    barGenMerged{j}.rawBitmask = barcodeGen{posSingle(j)}.rawBitmask;%logical(~isnan(  barGenMerged{j}.rawBarcode));
    barGenMerged{j}.name =  barcodeGen{posSingle(j)}.name;
	barGenMerged{j}.data =  barcodeGen{posSingle(j)};
    barGenMerged{j}.idx = posSingle(j);
end
% 

% import Core.calc_overlap_pcc_sort_m;


for i=1:length(posMulti)

    % from the same movie, keep only the longer molecule. / maybe this
    % information should be kept already in the kymoStructs, so we don't
    % need to call it back here
    
    % use MP overlap
%     [oSneighbor{i}] = calc_overlap_pcc_sort_m(bgfov{i}.bars, sF,minOverlap);
end


bgfov = cell(1,length(posMulti));
oSneighbor = cell(1,length(posMulti));

import DBM4.Bargrouping.merge_two;
import DBM4.Bargrouping.merge_final;

% average the multi-frame barcodes
for i=1:length(posMulti)
    uE = unique_a(posMulti(i));
    cE = cnt_unique(posMulti(i));

    numAvgBars = cE-1;
    shift = zeros(2,numAvgBars-1); % could copy something similar to this/but simplified that is bargrouping code..
    twoBars = cell(1,numAvgBars-1);
    curSc = zeros(1,numAvgBars-1);
        curScOverlap = zeros(1,numAvgBars-1);

    curFlip = 0;
    curSF = 1; % in case length re-scaling is being used
    for j=1:numAvgBars
        bars = barcodeGen(uE+j-1:uE+j); % two neighbour barcodes
        [oSneighbor{i}{j}] = calc_overlap_mp(bars,sF, minOverlap,timestamp); % overlap for two neighbour barcodes
        % merge two
        [twoBars{j},shift(:,j),curSc(j),curScOverlap(j), curFlip,curSF ] = merge_two(oSneighbor{i}{j},bars);
        if curFlip == 1; % flip for next comparison
            barcodeGen{uE+j}.rawBarcode = fliplr(barcodeGen{uE+j}.rawBarcode);
            barcodeGen{uE+j}.rawBitmask = fliplr(barcodeGen{uE+j}.rawBitmask);
        end
            lBar = length(barcodeGen{uE+j}.rawBarcode);
            
            barcodeGen{uE+j}.rawBarcode = imresize(barcodeGen{uE+j}.rawBarcode,[1,lBar*curSF] );
            barcodeGen{uE+j}.rawBitmask = imresize(barcodeGen{uE+j}.rawBitmask,[1,lBar*curSF] );
%         % Visualize
%         barStruct = cell2struct([cellfun(@(x) double(x.rawBarcode),bars,'un',false);...
%         cellfun(@(x) x.rawBitmask,bars,'un',false)]',{'rawBarcode','rawBitmask'},2);
%         import Core.plot_match_simple;
%         [f] = plot_match_simple(barStruct, oSneighbor{i}{j},2,1);
        barGenMerged{length(posSingle)+i}.pairBars{j} = bars;
        barGenMerged{length(posSingle)+i}.name =  [barcodeGen{uE+j}.name,'merged'];


    end
    
    finalBar = merge_final(barcodeGen(uE:uE+cE-1),shift,cE);

    barGenMerged{length(posSingle)+i}.rawBarcode = nanmean(finalBar);
    barGenMerged{length(posSingle)+i}.rawBitmask = ~isnan(barGenMerged{length(posSingle)+i}.rawBarcode);
    barGenMerged{length(posSingle)+i}.rawBarcode(isnan( barGenMerged{length(posSingle)+i}.rawBarcode)) = min( barGenMerged{length(posSingle)+i}.rawBarcode);
    barGenMerged{length(posSingle)+i}.overlapStruct = oSneighbor{i};
    barGenMerged{length(posSingle)+i}.alignedBars = finalBar;
    
    % just save info about original barcodes from bargen
    uE = unique_a(posMulti(i));
    cE = cnt_unique(posMulti(i));

    barGenMerged{length(posSingle)+i}.idx = uE:uE+cE-1;
    barGenMerged{length(posSingle)+i}.score = curSc;
    barGenMerged{length(posSingle)+i}.scoreFull = curScOverlap;

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
% [f] = plot_match_simple(barStruct, oSneighbor{i},3,5);
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
