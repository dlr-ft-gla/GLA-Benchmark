function [varIdxs] = dl2idx(list, varNames, col)

%Function to convert a cell matrix of names from the model description list into their respective indexes.
% Inputs: -list:     Lowest substructure of model description list struct, e.g model_description.MDL_Outputs
%         -varNames: Matrix containing strings of names corresponding to the chosen column in the description list
%         -col:      (Optional)Desired column index in description list. If
%                    unspecified, column 1 is set by default.
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 


if nargin  < 3
    col = 1;
end

[nbRows, nbCols] = size(varNames);
varIdxs = zeros(nbRows, nbCols);
for in = 1:nbRows
    for jn = 1:nbCols
        match_tmp = find(strcmp(varNames(in,jn), list(:,col)));
        if size(match_tmp,1) == 1
            varIdxs(in,jn) = match_tmp;
        else
            error('Requested MDL term is not unique!');
        end
    end
end