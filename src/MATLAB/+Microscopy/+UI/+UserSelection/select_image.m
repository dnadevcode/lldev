function varargout = select_image(tiffs,ii,dim1,dim2)
    h=figure('CloseRequestFcn',@my_closereq)
    iiSt = 1;

    try
        h1 = [];
        for idx = 1:dim1
            for jdx = 1:dim2
                subplot(dim1,dim2,iiSt);
                h1(iiSt) = imagesc(imread(tiffs{iiSt+ii-1}));
                colormap gray

                set(h1(iiSt), 'buttondownfcn', {@loads_of_stuff,iiSt+ii-1});
                iiSt = iiSt+1;
            end
        end
    catch
    end
    uiwait()
    

    function loads_of_stuff(src,eventdata,x)
        if get(src,'UserData')
            set(src,'UserData',0)
            title('');
        else
            set(src,'UserData',1)
            title('Selected');
        end
%         fprintf('%s\n',num2str(x));
%         C = get(h, 'UserData')
    
    end
%     
function my_closereq(src,callbackdata)
% Close request function 
% to display a question dialog box 
    try
    varargout{1} = find(cellfun(@(x) ~isempty(x),get(h1,'Userdata')));
    catch
    end
    delete(h)
%     uiresume() 

end

end
