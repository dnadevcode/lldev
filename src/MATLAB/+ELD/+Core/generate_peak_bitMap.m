function peakBitMap=generate_peak_bitMap(imgArr)
peakInfo=generatePeakInfo(imgArr);
peakBitMap=zeros(size(imgArr));
for i=1:size(peakInfo,1)
    peakBitMap(i,peakInfo{i,2})=1;
end

    function peakInfo=generatePeakInfo(imgArr)
        [rows,~]=size(imgArr);
        peakInfo=cell(rows,4);
        for j=1:rows
            [a,b,c,d]=findpeaks(imgArr(j,:));
            peakInfo{j,1}=a;
            peakInfo{j,2}=b;
            peakInfo{j,3}=c;
            peakInfo{j,4}=d;
        end
    end

end
