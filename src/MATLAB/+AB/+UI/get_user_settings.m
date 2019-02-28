function [ sets ] = get_user_settings( sets )
    % get_user_settings
    %
    % :param sets: input settings.
    % :returns: sets
    
    % rewritten by Albertas Dvirnas

    if sets.moviesets.askformovie
        import Fancy.UI.Templates.create_figure_window;
        [ hMenuParent, tsAB ] = create_figure_window( 'AutoBarcoder GUI', 'AutoBarcoder' );

        import Fancy.UI.Templates.create_movie_import_tab;
        cache = create_movie_import_tab(hMenuParent,tsAB,'AB movie import tab');
        uiwait(gcf);  
        
        dd = cache('selectedItems');
        sets.filenames = dd(1:end/2);
        sets.moviefilefold = dd((end/2+1):end);
    end
    
      
    if sets.chooseSettings
        prompt = {'Compute consensus for clusters(beta)','Prompt consensus settings'};
        title = 'Input';
        dims = [1 35];
        definput = {'0','0'};
        answer = inputdlg(prompt,title,dims,definput);
        
        sets.consensus.generate = logical(str2double(answer{1}));
        sets.consensus.promtsetsconsensus = logical(str2double(answer{1}));
    end 
    
    
    if sets.promtsetsconsensus
        prompt = {'Point spread function sigma width','Pixel width', 'Delta cut', 'Consensus threshold'};
        title = 'Input';
        dims = [1 35];
        definput = {'300','130','3','0.75'};
        answer = inputdlg(prompt,title,dims,definput);
        
        sets.consensus.psf = str2double(answer{1});
        sets.consensus.pxnm = str2double(answer{2});
        sets.consensus.dc = str2double(answer{3});
        sets.consensus.ct = str2double(answer{4});

    end
%     
%     if sets.promtsetspreprocessing
%         prompt = {'Point spread function sigma width','Pixel width', 'Delta cut', 'Consensus threshold'};
%         title = 'Input';
%         dims = [1 35];
%         definput = {'300','130','3','0.75'};
%         answer = inputdlg(prompt,title,dims,definput);
%         
%         sets.consensus.psf = str2double(answer{1});
%         sets.consensus.pxnm = str2double(answer{2});
%         sets.consensus.dc = str2double(answer{3});
%         sets.consensus.ct = str2double(answer{4});
% 
%     end
    


    
end

