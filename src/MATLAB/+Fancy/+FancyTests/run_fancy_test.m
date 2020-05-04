function [] = run_fancy_test()
    % run fancy test
    
    % this runs fancy list manager and tests if the functions are behaving
    % as expected
    
    % create a simple figure, does not matter too much what
    h = figure()
	import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(h);
    lm.make_ui_items_listbox();
    
    names = {'A','B'};
    structs{1}.one = 1;
    structs{1}.two = 'bla';
    structs{2}.one = 1;
    structs{2}.two = 'bla';    

    lm.add_list_items(names, structs);
    
    % now change some values. Make sure this just not add new item
%     names2 ={'A'};
    structs{1}.one = 2;
    structs{1}.two = 'bla'; 
    lm.set_list_items(names, structs);

    
end

