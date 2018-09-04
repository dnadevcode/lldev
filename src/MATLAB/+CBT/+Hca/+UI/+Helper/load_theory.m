function [ hcaSessionStruct ] = load_theory( filePath,hcaSessionStruct )
    barcodeData = load(filePath);
    
    numFiles = length(barcodeData.hcaSessionStruct.theoryBarcodes);

    theoryBarcodes = cell(1,length(barcodeData.hcaSessionStruct.theoryBarcodes));
    nameSequence = cell(1,length(barcodeData.hcaSessionStruct.theoryBarcodes));
    bitmask = cell(1,length(barcodeData.hcaSessionStruct.theoryBarcodes));
    bpNm =  cell(1,length(barcodeData.hcaSessionStruct.theoryBarcodes));
    
    for i=1:numFiles
        theoryBarcodes{i} = barcodeData.hcaSessionStruct.theoryBarcodes{i};
        nameSequence{i} = barcodeData.hcaSessionStruct.theoryNames{i};
        bpNm{i} =barcodeData.hcaSessionStruct.bpNm{i} ;
        bitmask{i} =barcodeData.hcaSessionStruct.bitmask{i};
        sets = barcodeData.hcaSessionStruct.sets;
    end

    hcaSessionStruct.theoryGen.theoryBarcodes = theoryBarcodes;
    hcaSessionStruct.theoryGen.theoryNames = nameSequence;
    hcaSessionStruct.theoryGen.bpNm = bpNm{1};
    hcaSessionStruct.theoryGen.sets = sets;

    hcaSessionStruct.theoryGen.bitmask = bitmask;


end

