function [  ] = plot_comparison_vs_theory(len1,selectedIndices,theoryGen,comparisonStructure, names, titleT,savetxt )
    %plot_comparison_vs_theory
    
    % input len1,selectedIndices,theoryGen,comparisonStructure, names, titleT, savetxt 
    % output ??
    if nargin < 7
        savetxt = 0;
    end

    if savetxt == 1
        defaultMatFilename ='saveplotshere';
        [~, matDirpath] = uiputfile('*.txt', 'Save chosen settings data as', defaultMatFilename);
    end
            
    maxcoef = cell2mat(cellfun(@(x) x.maxcoef,comparisonStructure,'UniformOutput',0));
    pos = cell2mat(cellfun(@(x) x.pos,comparisonStructure,'UniformOutput',0));
    orientation = cell2mat(cellfun(@(x) x.or,comparisonStructure,'UniformOutput',0));

             
 if length(selectedIndices) >= 1

     for ii=selectedIndices
%          
%         bar = theoryGen.theoryBarcodes{1};
%         barBit =theoryGen.bitmask{1};
        if size(theoryGen.theoryBarcodes,2)>size(theoryGen.theoryBarcodes,1)
            bar = cell2mat(theoryGen.theoryBarcodes);
            barBit = cell2mat(theoryGen.bitmask);
        else
            bar = cell2mat(theoryGen.theoryBarcodes');
            barBit = cell2mat(theoryGen.bitmask');          
        end
        figure, hold on
    
        b1 = comparisonStructure{ii}.bestStretchedBar;
        b1Bit =comparisonStructure{ii}.bestStretchedBitmask;
        
        % if theory is shorter than exp, call a different function for
        % plotting
        if length(bar) < length(b1)
            if ii > length(names)
                name = 'consensus';
            else
                name = names{ii};
            end
            %plot_comparison(ii,dd,len1,pos,orientation,b1, b1Bit,bar,barBit,hcaSessionStruct )
            CBT.Hca.Export.plot_theory_vs_experiment(bar,barBit,b1,b1Bit,orientation(ii,1),pos(ii,1),maxcoef(ii,1),theoryGen.theoryNames{1},name,titleT)
        %    fitPositions = pos(ii,1):pos(ii,1)+length(bar)-1;
        else


            if orientation(ii,1) == 2
                b1 = fliplr(b1);
                b1Bit = fliplr(b1Bit);
            end

            fitPositions = pos(ii,1):pos(ii,1)+length(b1)-1;
            
%             if has0 == 1;
%                 [a,b] = find(fitPositions == 1);
%                 fitPositions = [fitPositions(1:b-1) NaN fitPositions(b:end)];
%                 b1 = [b1(1:b-1) NaN b1(b:end)];
%                 barFit = [barFit(1:b-1) NaN barFit(b:end)];
%             end
%     
        
            if sum(fitPositions<=0) > 1
                indx = find(fitPositions<=0);
                indx = length(bar)-fliplr(indx);
                fitPositions(find(fitPositions<=0)) = indx;
%                fitPositions(find(fitPositions<=0)) = indx;
               % fitPositions = fitPositions(1:min(end,length(bar)));
            end
            
           % a = find(fitPositions>length(bar));
            
            fitPositions(find(fitPositions>length(bar))) = fitPositions(find(fitPositions>length(bar))) -length(bar);

            barFit = bar(fitPositions);
            barBit = barBit(fitPositions);
            
            m1 = mean(barFit(logical(b1Bit)));
            s1= std(barFit(logical(b1Bit)));

            m2 = mean(b1(logical(b1Bit)));
            s2= std(b1(logical(b1Bit)));
            
            firstBarcode = ((b1-m2)/s2) *s1+m1;
            
            [a,b] = find(fitPositions == 1);
            if ~isempty(a);
                fitPositions = [fitPositions(1:b-1) NaN fitPositions(b:end)];
                firstBarcode = [firstBarcode(1:b-1) NaN firstBarcode(b:end)];
                barFit = [barFit(1:b-1) NaN barFit(b:end)];
            end
    
    
            plot(fitPositions,firstBarcode)
            hold on
            plot(fitPositions,barFit)
            xlim([min(fitPositions) max(fitPositions) ])
            xlabel('pixel nr.')
            ylabel('Rescaled to theoretical intesity')
            if ii <= len1
                name = strcat([names{ii}]);
            else
                name = 'consensus';
            end
            name = strrep(name,'_',' ');
            name = strrep(name,'kymograph.tif','');

           % title(strcat(['Molecule ' name ]));
            title(titleT,'Interpreter','latex')
            legend({strcat(['$\hat C=$' num2str(maxcoef(ii,1),'%0.2f')]),comparisonStructure{ii}.name},'Interpreter','latex')

        end  
        fitPositions = pos(ii,1):pos(ii,1)+length(b1)-1;

        if savetxt == 1
            if ii > length(names)
                name = 'consensus';
            else
                name = names{ii};
            end
            CBT.Hca.Export.export_plots_txt(ii,fitPositions,b1,bar,name,theoryGen.theoryNames{1},matDirpath)
        end
     end

 end
      
 
 %% Here we write updated code for this:

end

