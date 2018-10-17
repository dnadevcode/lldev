function [cache] = display_additional_results_ui(ts,cache)
    if nargin < 2
        cache = containers.Map();
    end
    
    hcaSessionStruct = cache('hcaSessionStruct') ;
    sets = cache('sets') ;
    len1=length(hcaSessionStruct.comparisonStructure);

    if sets.barcodeConsensusSettings.aborted==0
        len1=len1-1;
    end
    
	tabTitle = 'Additional results';
    [hTabTheoryImport] = ts.create_tab(tabTitle);
    hPanelTheoryImport = uipanel(hTabTheoryImport);
    ts.select_tab(hTabTheoryImport);

	import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hPanelTheoryImport);
    lm.make_ui_items_listbox();
     
    % Change to filtered and unfiltered names..
  	if sets.barcodeConsensusSettings.aborted == 0
        lm.add_list_items([hcaSessionStruct.names, 'consensus'], [hcaSessionStruct.names, 'consensus'] );
    else
    	lm.add_list_items(hcaSessionStruct.names, hcaSessionStruct.names);
    end
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(plot_comp(ts));
    flmbs1.add_button(plot_comp_filt(ts));
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;
	flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());
 
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 2;
	flmbs3.add_button(plot_one_vs_others(ts));
    flmbs3.add_button(plot_one_vs_others_filtered(ts));

    flmbs31 = FancyListMgrBtnSet();
    flmbs31.NUM_BUTTON_COLS = 2;
	flmbs31.add_button(plot_kymo(ts));
    flmbs31.add_button(plot_infoscore(ts));
    
    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 3;
	flmbs4.add_button(plot_max_cc(ts,'Plot max cc'));
    flmbs4.add_button(plot_max_cc(ts,'Plot max cc filtered'));
    flmbs4.add_button(plot_cc(ts,'Plot individual cc'));

    
    % plots p-values
    flmbs5 = FancyListMgrBtnSet();
    flmbs5.NUM_BUTTON_COLS = 2;
	flmbs5.add_button(compute_p_plot(ts,'Compute p-values'));
	flmbs5.add_button(plot_p_plot(ts,'Plot p-values'));
     % plots p-values, order statistics
    flmbs7 = FancyListMgrBtnSet();
    flmbs7.NUM_BUTTON_COLS = 1;
	flmbs7.add_button(true_positive_statistics(ts,'True positive statistics'));

    
    % Plot comparison between experiments and theory function
    function [btnAddKymos] =plot_comp(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot comparison(s)', ...
            @(~, ~, lm) on_plot_comp(lm, ts));
        
        
        function [] = on_plot_comp(lm, ts)
             [~, selectedIndices] = get_selected_list_items(lm);
             
             %savetxt = sets.exportSettings.savePlotTxt;
             savetxt = 1; % choose if want to save barcodes as txt
             import CBT.Hca.Export.plot_comparison_vs_theory;
             plot_comparison_vs_theory(len1,selectedIndices,hcaSessionStruct.theoryGen,hcaSessionStruct.comparisonStructure, hcaSessionStruct.names, 'Unfiltered comparison',savetxt )
        end
        
       
    end


  function [btnAddKymos] =plot_comp_filt(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot filtered comparison(s)', ...
            @(~, ~, lm) on_plot_comp_filt(lm, ts));
        
        
        function [] = on_plot_comp_filt(lm, ts)
        	 [~, selectedIndices] = get_selected_list_items(lm);

            if sets.filterSettings.filter==1             
                 import CBT.Hca.Export.plot_comparison_vs_theory;
                 plot_comparison_vs_theory(len1,selectedIndices,hcaSessionStruct.theoryGen,hcaSessionStruct.comparisonStructureFiltered, hcaSessionStruct.names, 'Filtered comparison'  )
            else
                disp('Filtering option was not selected for this experiment')
            end
        end
  end


     function [btnAddKymos] = plot_one_vs_others(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot one barcode vs another', ...
            @(~, ~, lm) on_plot_one_vs_others(lm, ts));
        
        
        function [] = on_plot_one_vs_others(lm, ts)
             [~, selectedIndices] = get_selected_list_items(lm);
             % todo - allow stretching here
             import CBT.Hca.Export.plot_comparison_exp_vs_exp;
             plot_comparison_exp_vs_exp(selectedIndices,hcaSessionStruct)
       
        end
       
    end
    
   

     function [btnAddKymos] = plot_one_vs_others_filtered(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot one barcode vs another filtered', ...
            @(~, ~, lm) on_plot_one_vs_others_filtered(lm, ts));
        
        
        function [] = on_plot_one_vs_others_filtered(lm, ts)
             [~, selectedIndices] = get_selected_list_items(lm);
             
             if sets.filterSettings.filter==1     
                 import CBT.Hca.Export.plot_comparison_exp_vs_exp;
                 plot_comparison_exp_vs_exp(selectedIndices,hcaSessionStruct.comparisonStructureFiltered)
             else
                disp('Filtering option was not selected for this experiment')
             end
       

        end
       
     end
 
 
  
    %flmbs1.add_button(make_add_experimental_barcodes(tsCBC));
       % add barcodes
    function [btnAddKymos] =plot_kymo(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot kymo(s)', ...
            @(~, ~, lm) on_plot_kymo(lm, ts));
        
        
        function [] = on_plot_kymo(lm, ts)
             [~, selectedIndices] = get_selected_list_items(lm);

            for ii=selectedIndices

                figure,hold on

                subplot(2,2,1)
                imshow(hcaSessionStruct.unalignedKymos{ii},[])
                subplot(2,2,2)
                imshow(hcaSessionStruct.alignedKymo{ii},[]) 
                subplot(2,2,[3 4])
                plot(hcaSessionStruct.rawBarcodes{ii})
                hold on
                plot(find(hcaSessionStruct.rawBitmasks{ii}),hcaSessionStruct.rawBarcodes{ii}(hcaSessionStruct.rawBitmasks{ii}))
                xlabel('pixel')
                ylabel('intensity')
            end
        end
        
       
    end

    function [btnAddKymos] =plot_infoscore(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Plot infoscore(s)', ...
            @(~, ~, lm) on_plot_infoscore(lm, ts));
        
        
        function [] = on_plot_infoscore(lm, ts)
            figure,
            subplot(2,2,1)
            plot(cellfun(@(x) x.mean, hcaSessionStruct.informationScores),'*')
            xlabel('bar nr')
            title('Mean')
            subplot(2,2,2)
            plot(cellfun(@(x) x.std, hcaSessionStruct.informationScores),'*')
            xlabel('bar nr')
            title('std. deviation')

            subplot(2,2,3)
            plot(cellfun(@(x) x.score, hcaSessionStruct.informationScores),'*')
            xlabel('bar nr')
            title('info score')
            
            defaultMatFilename ='saveinfoscoreshere';
            [~, matDirpath] = uiputfile('*.txt', 'Save infoscore data as', defaultMatFilename);
            CBT.Hca.Export.export_infoscores_txt(hcaSessionStruct.informationScores,matDirpath)

        end
        
       
    end

   function [btnAddKymos] = plot_max_cc(ts,title)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            title, ...
            @(~, ~, lm) on_plot_max_cc(lm, ts,title));
        
        
        function [] = on_plot_max_cc(lm, ts,title)

            if isequal(title,'Plot max cc')
                maxcoef = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparisonStructure,'UniformOutput',0));
                pos = cell2mat(cellfun(@(x) x.pos,hcaSessionStruct.comparisonStructure,'UniformOutput',0));
                orientation = cell2mat(cellfun(@(x) x.or,hcaSessionStruct.comparisonStructure,'UniformOutput',0));
            else
                if sets.filterSettings.filter == 1
                    maxcoef = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
                    pos = cell2mat(cellfun(@(x) x.pos,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
                    orientation = cell2mat(cellfun(@(x) x.or,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
                else
                    return;
                end
            end
            markers = ['o';'s';'x'];
            fig1 = figure;

            p = plot(maxcoef,1:size(maxcoef,1),'ob');

            p(1).Marker = markers(1);
            p(2).Marker = markers(2);
            p(3).Marker = markers(3);

            ylabel('Barcode nr.','Interpreter','latex')
            xlabel('max match score','Interpreter','latex')
            xlim([0.5 1])
            legend({'$\hat C$','$C_2$','$C_3$'},'Location','sw','Interpreter','latex')
            assignin('base','hcaSessionStruct',hcaSessionStruct)
            
            saveccvals=1;
            if saveccvals==1
                defaultMatFilename ='saveccvalshere';
                [~, matDirpath] = uiputfile('*.txt', 'Save chosen ccvals data as', defaultMatFilename);
                CBT.Hca.Export.export_ccvals_txt(maxcoef(:,1),matDirpath)
            end
        
        
        
        end
       
   end
   function [btnAddKymos] = plot_cc(ts,title)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            title, ...
            @(~, ~, lm) on_plot_cc(lm, ts,title));
        
        
        function [] = on_plot_cc(lm, ts,title)
            defaultMatFilename ='saveccvalshere';
            [~, matDirpath] = uiputfile('*.txt', 'Save chosen ccvals data as', defaultMatFilename);
      
            if size(hcaSessionStruct.theoryGen.theoryNames,2)>size(hcaSessionStruct.theoryGen.theoryNames,1)
                fasta = hcaSessionStruct.theoryGen.theoryNames';
            else
                fasta = hcaSessionStruct.theoryGen.theoryNames;
            end
            
            T = table(fasta);
            %T = hcaSessionStruct.theoryGen.theoryNames;
            
            for i=1:length(hcaSessionStruct.comparedStructure{1})
                maxccoef = cell2mat(cellfun(@(x) x{i}.maxcoef(1), hcaSessionStruct.comparedStructure,'UniformOutput',0));
                lengthPx = cell2mat(cellfun(@(x) length(x{i}.bestStretchedBar),hcaSessionStruct.comparedStructure,'UniformOutput',0));
                pos = cell2mat(cellfun(@(x) x{i}.pos(1), hcaSessionStruct.comparedStructure,'UniformOutput',0));
                stretch =  cell2mat(cellfun(@(x) x{i}.bestBarStretch,hcaSessionStruct.comparedStructure,'UniformOutput',0));
                for j=1:length(pos)
                   if pos(j)<= 0
                       pos(j) = pos(j)+length(hcaSessionStruct.theoryGen.theoryBarcodes{j});
                   end
                end
                maxcc =maxccoef;
                
                N = matlab.lang.makeValidName(hcaSessionStruct.names{i});
                if length(hcaSessionStruct.comparedStructure) == 1

                    for j =1:length(maxcc)
                        N = matlab.lang.makeValidName(hcaSessionStruct.names{j});
                        T2 = table(maxcc(j),lengthPx(j), pos(j), stretch(j) ,'VariableNames',{N ,strcat(['len_'  num2str(j)]),strcat(['pos_'  num2str(j)])});
                        T = [T T2];
                    end
                else
                    T2 = table(maxcc',lengthPx', pos',stretch' ,'VariableNames',{N,strcat(['len_'  num2str(i)]),strcat(['pos_'  num2str(i)]),strcat(['stretch_'  num2str(i)])});
                    T = [T T2];
                end
            end
            CBT.Hca.Export.export_cc(T, matDirpath)
            %https://se.mathworks.com/help/matlab/ref/writetable.html
            
%              LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
%             Age = [38;43;38;40;49];
%             Height = [71;69;64;67;64];
%             Weight = [176;163;131;133;119];
%             BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
% 
%             T = table(Age,Height,Weight,BloodPressure,...
%                 'RowNames',LastName)

        
        end
       
   end

   function [btnAddKymos] = compute_p_plot(ts,title)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(title,@(~, ~, lm) on_compute_p_plot(lm, ts,title));
        
        function [] = on_compute_p_plot(lm, ts,title)
        
        
            try 
                [file,path] = uigetfile({'*.txt'},'load pre-computed p-value file');
                fullPath = strcat([path,file]);  
                addpath(genpath(path));
                import CBT.Hca.Import.load_pval_struct;
                [ pvalData.len1, pvalData.data ] = load_pval_struct(fullPath);
            catch
                 disp('No pre-computed p-value database chosen. Running precompute method... ');
                 import CBT.Hca.Core.Pvalue.pregenerate_pvalue_db;
                 pregenerate_pvalue_db('pval.txt',pwd);
            end
            

            hcaSessionStruct.sets = sets;
            import CBT.Hca.Core.Pvalue.compute_p_val;
            [ hcaSessionStruct ] = compute_p_val(pvalData, hcaSessionStruct );
         
            cache('hcaSessionStruct') =hcaSessionStruct ;
            assignin('base','hcaSessionStruct',hcaSessionStruct)
        end
   end

   function [btnAddKymos] = plot_p_plot(ts,title)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(title, @(~, ~, lm) on_plot_p_plot(lm, ts,title));
      
        function [] = on_plot_p_plot(lm, ts,title)
        pvals = hcaSessionStruct.pValueResults.pValueMatrix;
        savePvals=1;
        if savePvals==1
            defaultMatFilename ='savepvalshere';
            [~, matDirpath] = uiputfile('*.txt', 'Save pvals data as', defaultMatFilename);
            CBT.Hca.Export.export_pvals_txt(hcaSessionStruct.pValueResults,pvals,matDirpath)
        end
        
        fig1 = figure;
        plot(pvals,1:length(pvals),'rx')
        hold on

        if sets.filterSettings.filter==1
            pvalsFiltered = hcaSessionStruct.pValueResults.pValueMatrixFiltered;
            plot(pvalsFiltered,1:length(pvalsFiltered),'bo')
        end
        
        ylabel('Barcode nr.','Interpreter','latex')
        xlabel('p-value','Interpreter','latex')
        legend({'Unfiltered p-value','Filtered p-value'},'Interpreter','latex')
      
        cache('hcaSessionStruct') =hcaSessionStruct ;

        assignin('base','hcaSessionStruct',hcaSessionStruct)
        end
   end

   function [btnAddKymos] = true_positive_statistics(ts,title)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            title, ...
            @(~, ~, lm) on_true_positive_statistics(lm, ts,title));
        
        function [] = on_true_positive_statistics(lm, ts,title)
            
            defaultPlace = 0;
            defaultError = 20;
            defaultChromosome = 1;
           % defaultThresh = 0.01;
            titleText = 'Correct place';
            import CBT.Hca.UI.choose_correct_place;
            [ sets.correctChromosome, sets.correctPlace,sets.allowedError,sets.pvaluethresh] = choose_correct_place(defaultChromosome,defaultPlace,defaultError,sets.pvaluethresh,titleText); 

            import CBT.Hca.UI.compute_true_positives;
            hcaSessionStruct = compute_true_positives(hcaSessionStruct, sets);
            
            cache('hcaSessionStruct') =hcaSessionStruct ;

            assignin('base','hcaSessionStruct',hcaSessionStruct)

        end
   end

    lm.add_button_sets(flmbs1,flmbs2,flmbs3,flmbs31,flmbs4,flmbs5,flmbs7);
  
    cache('hcaSessionStruct') = hcaSessionStruct;
end