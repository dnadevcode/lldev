function [ mol2 ] = choose_test_barcodes(mol2, indices)
   mol2(indices) = [];
   for i=1:length(mol2)
       mol2{i}.rawBarcodes = [];
       mol2{i}.rawBitmasks = [];
       mol2{i}.rawBarcodes{1} = mol2{i}.consensusStruct.barcode;
       mol2{i}.rawBitmasks{1} =  mol2{i}.consensusStruct.bitmask;
   end
end

