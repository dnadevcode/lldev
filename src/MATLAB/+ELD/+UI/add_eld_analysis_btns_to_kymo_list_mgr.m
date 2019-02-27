function [] = add_eld_analysis_btns_to_kymo_list_mgr(lm, tsELD, settings)

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(make_run_distance_analysis_btn(tsELD, settings));

    lm.add_button_sets(flmbs2);

    function [lm] = on_run_distance_analysis(lm, tsELD, settings)
        
        import ELD.UI.import_sequences;
        [theorySequence, targetSequence] = import_sequences();
    
        selectedIndices = lm.get_selected_indices();
        numSelected = length(selectedIndices);
        if numSelected < 1
            questdlg('You must select some kymographs first!', 'Not Yet!', 'OK', 'OK');
            return;
        end
        
        trueValueList = lm.get_true_value_list();
        
        hTabDistanceAnalyses = tsELD.create_tab('Distance Analyses');
        hPanelDistanceAnalyses = uipanel('Parent', hTabDistanceAnalyses);
        import Fancy.UI.FancyTabs.TabbedScreen;
        tsDA = TabbedScreen(hPanelDistanceAnalyses);
        
        import ELD.Core.dot_label_distances;
        import ELD.Core.calculate_optimal_point_distances;
        
        minOverlap = settings.minVerticalOverlap;
        confidenceInterval = settings.confidenceInterval;
                
%         theory_molecule_ends = cell(numSelected,1);
%         feature_positions_norm = cell(numSelected,1);
%         feature_position_vars_norm = cell(numSelected,1);
        resultStructs = cell(numSelected,1);
        
%         kymoIdxs = {1:numSelected};
        kymoIdxs = {sort(selectedIndices)};
        kymoIdxs = kymoIdxs{1};
%         kymoIdxs = sort(selectedIndices);
        kymoDispNames = cellfun(@(kymoIdx) lm.get_diplay_names(kymoIdx), {kymoIdxs}, 'UniformOutput', false);
%         kymoDispNames = arrayfun(@(kymoIdx) lm.get_diplay_names(kymoIdx), kymoIdxs, 'UniformOutput', false);
        kymoDispNames = kymoDispNames{1};
        
        for selectedIdxIdx = 1:numSelected
            disp(['Processing molecule ',num2str(selectedIdxIdx),'...']);
            kymoIndex = selectedIndices(selectedIdxIdx);
            kymoIndex = kymoIdxs(selectedIdxIdx);
%             kymoDispName = lm.get_diplay_names(kymoIndex);
%             kymoDispName = kymoDispName{1};
            kymoStruct = trueValueList{kymoIndex};
            unalignedKymo = kymoStruct.unalignedKymo;
               
            resultStructs{selectedIdxIdx} = dot_label_distances(unalignedKymo,...
                theorySequence,targetSequence,settings,false);

            [ resultStructs{selectedIdxIdx}.coupled_theoretical_dot_idxs, ...
                resultStructs{selectedIdxIdx}.coupled_dot_distances, ...
                resultStructs{selectedIdxIdx}.match_metric] = ...
                                    calculate_optimal_point_distances( ...
                                    resultStructs{selectedIdxIdx}.feature_positions_norm, ...
                                    resultStructs{selectedIdxIdx}.theory_dot_positions );
            %             theory_molecule_ends{selectedIdxIdx} = resultStruct(selectedIdxIdx).theory_molecule_ends;
            hTabCurrKymo = tsDA.create_tab(kymoDispNames{selectedIdxIdx});
            tsDA.select_tab(hTabCurrKymo);
            hPanelCurrKymo = uipanel('Parent', hTabCurrKymo);
            if ~isempty(resultStructs{selectedIdxIdx})

%                 feature_positions_norm{selectedIdxIdx} = resultStructs{selectedIdxIdx}.feature_positions_norm;
%                 feature_position_vars_norm{selectedIdxIdx} = resultStructs{selectedIdxIdx}.feature_position_vars_norm;

                hAxesCurrA = axes(hPanelCurrKymo, ...
                    'Units', 'normalized', ...
                    'Position', [0.5 0 0.5 1]);
    %             distances = rand(size(unalignedKymo, 1), 1); %TODO: update
                imagesc(hAxesCurrA, resultStructs{selectedIdxIdx}.kymo_colormap);
    %             plot(hAxesCurrA, distances);

                hAxesCurrB = axes(hPanelCurrKymo, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 0.5 1]);
                imagesc(hAxesCurrB, unalignedKymo);
                colormap(hAxesCurrB, gray());
            else
                hAxesCurrA = axes(hPanelCurrKymo, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                text(0.5, 0.5, 'No feature map could be computed.', 'FontSize',20, 'Color','k', ...
                    'HorizontalAlignment','Center', 'VerticalAlignment','Middle');
                axis off;
            end
            
            disp(['Molecule ',num2str(selectedIdxIdx),' processed.']);
        end
        
        emptyCells = cellfun(@isempty,resultStructs);
        successfulCells = arrayfun(@(idx) not(all(isnan(resultStructs{idx}.feature_distances))), 1:numSelected, 'Uniformoutput', false);
        successfulCells = cell2mat(successfulCells);
        if ~all(emptyCells) && any(successfulCells)
        
            import ELD.UI.draw_comparison_plot;
    %         comparisonPlot = draw_comparison_plot(resultStructs{1}.theory_dot_positions,resultStructs{1}.theory_molecule_ends,feature_positions_norm,feature_position_vars_norm);
            comparisonPlot = draw_comparison_plot({resultStructs{successfulCells}},{kymoDispNames{successfulCells}});
            hTabComparisonPlot = tsELD.create_tab('Comparison Plot');
            tsELD.select_tab(hTabComparisonPlot);
            hPanelComparisonPlot = uipanel('Parent', hTabComparisonPlot);
            
            tsCP = TabbedScreen(hPanelComparisonPlot);
            
            for selectedIdxIdx = 1:numSelected
                
                disp(['Displaying data for molecule ',num2str(selectedIdxIdx),'...']);
                kymoIndex = selectedIndices(selectedIdxIdx);
                kymoIndex = kymoIdxs(selectedIdxIdx);
%                 kymoDispName = lm.get_diplay_names(kymoIndex);
%                 kymoDispName = kymoDispName{1};
%                 kymoStruct = trueValueList{kymoIndex};
%                 unalignedKymo = kymoStruct.unalignedKymo;
                
                hTabCurrKymoComp = tsCP.create_tab(kymoDispNames{selectedIdxIdx});
                hPanelCurrKymoComp = uipanel('Parent', hTabCurrKymoComp);

                hAxesCurrA = axes(hPanelCurrKymoComp, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 0.5 1]);
        %             distances = rand(size(unalignedKymo, 1), 1); %TODO: update
                comparisonFrame = getframe(comparisonPlot);
                imagesc(hAxesCurrA, comparisonFrame.cdata);

                
                hPanelFeatureTable = uipanel('Parent', hPanelCurrKymoComp,'Position', [0.5 0 0.5 1]);
%                 hAxesCurrB = axes(hPanelFeatureTable, ...
%                         'Units', 'normalized', ...
%                         'Position', [0 0 1 1]);
                    
%                 h = image('visible','off');
%                 set(gca,'Parent',hPanelFeatureTable);
%                 s = uicontrol('Style','Slider','Parent',hPanelCurrKymoComp,...
%                       'Units','normalized','Position',[0.98 0 0.02 1],...
%                       'Value',1,'Callback',{@slider_callback1,hPanelFeatureTable});

%                 hAxesCurrB = axis('Parent',hPanelFeatureTable);
%                 tableFig = figure('visible','off');
%                 
%                 set(gca,'Parent',hPanelFeatureTable);
%                 set(tableFig,'Parent',hPanelFeatureTable);
%                 set(findobj(gcf, 'type','axes'), 'Visible','off');
%                 set(gca,'xtick',[],'ytick',[]);
%                 varTable = uitable(tableFig);
%                 varTable = uitable(tableFig);

                panPos = getpixelposition(hPanelFeatureTable);
                panPosSize = panPos(3:4);

%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[0 0 1 1]);
                
%                 tabPos = getpixelposition(varTable);
                
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[0.5 0.5 0.1 0.1]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[-0.5 -0.5 0.1 0.1]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[-1 -1 1 1]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[-1 -1 100 100]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[0 0 100 100]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',[0 0 10 10]);
%                 varTable = uitable('Parent',hPanelFeatureTable,'Position',panPos);
                varTable = uitable('Parent',hPanelFeatureTable,'Position',[1 1 panPosSize]);
%                 tabPos1 = getpixelposition(varTable);
%                 varTable = uitable('Parent',hPanelFeatureTable);
%                 tabPos2 = getpixelposition(varTable);
%                 varTable.RowName = {'Feature Index',...
%                     'Feature Index',...
%                     'Fluorophore Position',...
%                     'Fluorophore Position (normalized)'};
                varTable.ColumnName = {'Fluorophore Index' 'Theoretical Positions' 'Experimental Positions'};
                
                tableData = (1:numel(resultStructs{selectedIdxIdx}.theory_dot_positions))';
                tableData = [tableData,resultStructs{selectedIdxIdx}.theory_dot_positions];
%                 tableData = [tableData,resultStructs{selectedIdxIdx}.feature_positions'];
                set(varTable,'Data',tableData);
%                 set(tableFig, 'Visible', 'on');
                
%                 tableFig = figure(hAxesCurrB,varTable);
%                 varTable.Data = tableData;
%                 comparisonFrame = getframe(tableFig);
%                 imagesc(hAxesCurrB, comparisonFrame.cdata);
%                 imagesc(hPanelFeatureTable, comparisonFrame.cdata);
%                 tableFig = imagesc(comparisonFrame.cdata);
%                 set(gca,'Parent',hPanelFeatureTable);
            end

    %             figure(comparisonPlot);
        end
        
        
    end
    
    function [btnEnsureAlignment] = make_run_distance_analysis_btn(tsELD, settings)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Run Distance Analysis', ...
            @(~, ~, lm) on_run_distance_analysis(lm, tsELD, settings));
    end

    function slider_callback1(src,eventdata,arg1)
        val = get(src,'Value');
        set(arg1,'Position',[0.5 -val 0.5 2]);
    end

end