% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [Controllers,Configurations] = Load_Controller_and_ControllerConfigurations(model_name,varargin)

    db_Controllers = [];

    ii = 1;
%     db_Controllers(ii).Identifier       = 'Baseline';
%     db_Controllers(ii).Init_Function    = TBD;
%     db_Controllers(ii).Block_Path       = [model_name,'/Controllers/Basis_Controller'];
%     ii = ii + 1;
    db_Controllers(ii).Identifier       = 'CRM_FFGLA_Default';
    db_Controllers(ii).Init_Function    = 'Init_Standard_GLA_Controller';
    db_Controllers(ii).Block_Path       = [model_name,'/Controllers/Default_GLA_Controller'];
    ii = ii + 1;
    db_Controllers(ii).Identifier       = 'CRM_FFGLA_Test';
    db_Controllers(ii).Init_Function    = 'Init_Standard_GLA_Controller';
    db_Controllers(ii).Block_Path       = [model_name,'/Controllers/Standard_GLA_Controller_Testbench'];
%     ii = ii + 1;    
%     db_Controllers(ii).Identifier       = 'GLA_Feedback';
%     db_Controllers(ii).Init_Function    = TBD; 
%     db_Controllers(ii).Block_Path       = [model_name,'/Controllers/TBD'];

    clear ii

    db_Configurations = [];
    jj = 1;
    db_Configurations(jj).Identifier              = 'Controller_Config__OL';
    db_Configurations(jj).Description             = 'Open loop';
    db_Configurations(jj).Active_Controller_Names = {};
    jj = jj + 1;
%     db_Configurations(jj).Identifier              = 'Controller_Config__Baseline';
%     db_Configurations(jj).Description             = 'Only baseline controller';
%     db_Configurations(jj).Active_Controller_Names = {'Baseline'};
%     jj = jj + 1;
    db_Configurations(jj).Identifier              = 'Controller_Config__FFGLA_Default';
    db_Configurations(jj).Description             = 'Default lidar-based preview controller';
    db_Configurations(jj).Active_Controller_Names = {'CRM_FFGLA_Default'};
    jj = jj + 1;
    db_Configurations(jj).Identifier              = 'Controller_Config__FFGLA_Test';
    db_Configurations(jj).Description             = 'Test lidar-based preview controller';
    db_Configurations(jj).Active_Controller_Names = {'CRM_FFGLA_Test'};
    
%     db_Configurations(jj).Identifier              = 'Controller_Config__Baseline_DLR_FT_Preview';
%     db_Configurations(jj).Description             = 'Baseline Controller + DLR-FT lidar-based preview controller';
%     db_Configurations(jj).Active_Controller_Names = {...
%                                                     'Baseline';...
%                                                     'CRM_FFGLA_Default'...
%                                                    };      
    jj = jj + 1;
    
    clear jj
    
    Controllers = db_Controllers;

    if nargin == 2        
        list_of_controller_configurations_to_be_investigated = varargin{1};
        pp=1;
        for ii=1:(size(list_of_controller_configurations_to_be_investigated,1))      
            for jj=1:(length(db_Configurations)) 
                if strcmp(list_of_controller_configurations_to_be_investigated{ii,1},db_Configurations(jj).Identifier) == 1 
                    Configurations(pp) = db_Configurations(jj);
                    pp=pp+1;
                end                    
            end               
        end        
    else       
        Configurations = db_Configurations;  % if no selection is made (nargin<2) we take all configurations      
    end

    
end