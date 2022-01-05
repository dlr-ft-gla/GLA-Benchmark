function indexes = find_str_in_cell_array(searched_string,cell_array,varargin)
% indexes = find_str_in_cell_array(searched_string,cell_array,varargin)
%
% Function searching a given string (char array) in a cell array. It looks
% for a perfect match and take care of checking the number of results obtained
% if specified. The options are:
%     - 'all'
%       No particular check is made.
%
%     - 'error_if_empty'
%       Does not tolerate not to find any result, but more than one is fine.
%       
%     - 'warn_if_empty'
%       Same but only a warning.
%       
%     - 'error_if_multiple_matches'
%       Does not tolerate having more than one result, but 0 or 1 result is fine.
%       
%     - 'warn_if_multiple_matches'
%       Same than previous option but only as a warning.
%       
%     - 'empty_if_not_unique'
%       Tolerates having more than one result, but returns an empty index list when
%       this happens.
%       
%     - 'error_if_not_unique'
%       Probably the most used option. Throw an error if there are no result or 
%       more than one => a unique match is required.
%       
%     - 'warn_if_not_unique'
%       Same but only a warning.
%
%
% Author: Nicolas Fezans 2021.
%
% License: MIT





% string not accepted yet to remain compatible with older MATLAB versions
% if ~(isstring(searched_string)||ischar(searched_string))
%     error('First argument must be a string or char array!');
% end

if ~(ischar(searched_string))
    error('First argument must be a char array!');
end
if ~iscell(cell_array)
    error('Second argument must be a cell array');
end
    
if nargin<3
    indexes = find(strcmp(cell_array,searched_string));
elseif nargin==3
    if ~ischar(varargin{1})
        error('Third argument (options) expected to be a char array!');
    end
    indexes = find(strcmp(cell_array,searched_string));

    switch lower(varargin{1})
        case 'all' % we simply do not care how many results we obtain
        case 'error_if_empty'
            error(['Error: no string ''' searched_string ''' found in the cell array.']);
        case 'warn_if_empty'
            warn(['Error: no string ''' searched_string ''' found in the cell array.']);
        case 'error_if_multiple_matches'
            error(['Error: string ''' searched_string ''' has been found multiple times (' num2str(N) ') in the cell array.']);
        case 'warn_if_multiple_matches'
            warn(['Error: string ''' searched_string ''' has been found multiple times (' num2str(N) ') in the cell array.']);
        case 'empty_if_not_unique'
            if length(indexes) ~= 1
                indexes = [];
            end
        case 'error_if_not_unique'
            if isempty(indexes)
                error(['Error: no string ''' searched_string ''' found in the cell array.']);
            elseif length(indexes) ~= 1
                error(['Error: string ''' searched_string ''' has been found multiple times (' num2str(N) ') in the cell array.']);
            end
        case 'warn_if_not_unique'
            if isempty(indexes)
                warn(['Error: no string ''' searched_string ''' found in the cell array.']);
            elseif length(indexes) ~= 1
                warn(['Error: string ''' searched_string ''' has been found multiple times (' num2str(N) ') in the cell array.']);
            end
        otherwise
            error(['Unrecognized option ''',varargin(1),''' provided!']);
    end
else
    error('Invalid number of arguments! Expected syntax ''find_str_in_cell_array(searched_string,cell_array [,options])'.'');
end

end
   
