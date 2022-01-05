%% Set Matlab paths for CRM Benchmark.
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

origin_path = pwd();                          % Save original directory

init_path = fileparts(mfilename('fullpath')); % Obtain path to this file
cd(init_path);                                % Move to this file's directory (workbench folder)
                 
main_dir_path = '../../';                     % Path to main directory

% Remove other workbenches and add current workbench folder and subfolders
warning('off','MATLAB:rmpath:DirNotFound');
rmpath(genpath([main_dir_path, 'workbenches']));
warning('on','MATLAB:rmpath:DirNotFound');

addpath(genpath(init_path)); 

% Add shared folders
addpath([main_dir_path, 'common_functions']);
addpath([main_dir_path, 'common_functions/CRM']);
addpath([main_dir_path, 'common_functions/Turbulence_generation']);
addpath(genpath([main_dir_path,'libraries']))
addpath(genpath([main_dir_path,'initialization/CRM']));
addpath(genpath([main_dir_path,'initialization/Lidar']));


% Return to original directory
cd(origin_path)

clear origin_path main_dir_path