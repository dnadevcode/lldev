function [ model ] = choose_model( name )
   % choose a model for competitive binding
   
   % model name
   model.name = name;

   switch name
        case 'simple'
            model.netropsinBindingConstant = [ 0.5 1E2 ];
        case 'product'      
            W = 100.0;
            S = 8.0;
            model.netropsinBindingConstant = [S^4 W*S^3 (S^2)*(W^2) S*W^3 W^4]./1E6;
            model.yoyo1BindingConstant = 26;
        case 'literature'
            import CBT.get_binding_constant_rules;
            competitors.Netropsin.bindingConstantRules = get_binding_constant_rules('Netropsin');
            % 
            import CBT.Core.gen_binding_constants_mat;
            values = gen_binding_constants_mat(competitors.Netropsin.bindingConstantRules );

            model.netropsinBindingConstant = 0.4*values./1E6;
            model.yoyo1BindingConstant = 26;
        otherwise
            disp('No model selected');
    end


end

