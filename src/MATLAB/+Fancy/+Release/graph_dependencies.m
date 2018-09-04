function [] = graph_dependencies(varargin)
    if not(exist('digraph', 'class'))
        error('digraph is necessary to show dependencies');
    end
    
   import Fancy.Release.graph_dependencies
   nVarargs = length(varargin);
   switch nVarargs
       case 0
           prompt = 'Enter a command to get dependencies for: ';
           startEntryCommand = input(prompt, 's');
           startEntryCommand = strtrim(startEntryCommand);
           graph_dependencies(startEntryCommand);
       case 1
            startEntryCommand = varargin{1};
            if not(exist(startEntryCommand, 'file')) && ...
                   not(exist(startEntryCommand, 'class')) && ...
                   isempty(which(startEntryCommand))
               error('Could not find ''%s''', startEntryCommand);
            end
            import Fancy.Release.get_dependency_data;
            [depFilePaths, depSparseMatrix, pathToProductDepsMap] = get_dependency_data(startEntryCommand);
            graph_dependencies(depFilePaths, depSparseMatrix);
       case 2
            depFilePaths = varargin{1};
            depSparseMatrix = varargin{2};

            depGraph = digraph(depSparseMatrix, depFilePaths, 'OmitSelfLoops');
            import Fancy.Release.simplify_node_names;
            nodeLabels = simplify_node_names(depGraph.Nodes.Name);

            hFig = figure();
            hPanel = uipanel('Parent', hFig);
            hAxis = axes('Parent', hPanel);
            plot(hAxis, depGraph, ...
                'NodeLabel', nodeLabels, ...
                'Layout', 'layered');
   end
end