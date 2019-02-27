function output = ELD_Gui(sets)
    % ELD_Gui  Enzymatic Labeling Distances
    %
    % :param settings: input parameter.
    % :returns: output
    
    % rewritten by Albertas Dvirnas
    
    %ELD: Enzymatic Labeling Distances
    output = [];
    
    if nargin < 1
        [sets] = ELD.Scripts.eld_sets();
    end
    
	% load all the required settings
    sets = ELD.UI.get_user_settings(sets);
    
    import ELD.Processing.process_movie;
    output = process_movie(sets);
    
    
%             import ELD.Import.load_eld_kymo_align_settings;
%         settings = load_eld_kymo_align_settings();
%         
       
figure,subplot(2,1,1)
  im1 = output.kymo{1}(1:50,:);
  im2 = output.peakMap(1:50,:);
  imshowpair(im1,im2)
  subplot(2,1,2)
  im1 = output.kymo{1}(500:550,:);
  im2 = output.peakMap(500:550,:);
  imshowpair(im1,im2)
    
%     import ELD.UI.add_eld_menu;
%     add_eld_menu(hMenuParent, tsELD, settings);
end