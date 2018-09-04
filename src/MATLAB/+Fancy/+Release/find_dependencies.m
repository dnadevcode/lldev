function [allValidImportPaths] = find_dependencies(filepath
)
    function [directFileDeps] = get_direct_file_deps(filepath)
        [directFileDeps, ~] = matlab.codetools.requiredFilesAndProducts(filepath, 'toponly');
        directFileDeps = directFileDeps(:);
    end
    function [allProductDeps] = get_all_product_deps(filepath)
        [~, allProductDeps] = matlab.codetools.requiredFilesAndProducts(filepath);
        allProductDeps = struct2table(allProductDeps(:));
    end
    
end