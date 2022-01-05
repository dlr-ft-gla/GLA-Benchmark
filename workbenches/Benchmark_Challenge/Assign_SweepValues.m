function [] = Assign_SweepValues(sweepPoint_tmp, sweepNames_tmp)
% Assigns sweepPoint values to workspace variables.
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

n_sweep_par = length(sweepPoint_tmp);

for ii=1:n_sweep_par
    sweepName_curr = sweepNames_tmp{ii};
    
    if ~iscell(sweepName_curr) %Is it a cell or a string/char?
        sweepName_curr = {sweepName_curr}; %By default, redefine it as a cell/cell array.
    end   
    
    for jj = 1:numel(sweepName_curr)
        [sweepName_split, sweepName_delim] = split(sweepName_curr(jj), '.');
        if isempty(sweepName_delim)
            assignin('base', char(sweepName_curr(jj)), sweepPoint_tmp(ii));
        else
            struct_tmp = sweepPoint_tmp(ii);
            for in = size(sweepName_delim,1):-1:1
                struct_tmp_old = struct_tmp;
                field_name_tmp = sweepName_split{in+1};
                struct_name_tmp = char(join(sweepName_split(1:in,1), '.'));
                struct_tmp = setfield(evalin('base',struct_name_tmp), field_name_tmp, struct_tmp_old);
            end
            assignin('base', struct_name_tmp, struct_tmp);
        end

    end
end


end

