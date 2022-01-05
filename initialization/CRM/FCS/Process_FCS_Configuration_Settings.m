% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [FCS] = Process_FCS_Configuration_Settings(FCS)

    nb_configurations = length(FCS.Configurations);
    nb_controllers    = length(FCS.Controllers);
    
    for i_FCS_config=1:nb_configurations        
        list_of_config_identifier{i_FCS_config} = FCS.Configurations(i_FCS_config).Identifier;
    end
    
    if ~(size(unique(list_of_config_identifier(:)),1) == nb_configurations)
        error('Defined controller configuration identifiers are not unique!');  
    end
    
    for i_FCS_controller=1:nb_controllers        
        list_of_controller_identifier{i_FCS_controller} = FCS.Controllers(i_FCS_controller).Identifier;
    end
    if ~(size(unique(list_of_controller_identifier(:)),1) == nb_controllers)
        error('Defined controller identifiers are not unique!');  
    end    
    
    for i_FCS_config=1:nb_configurations 
        FCS.Configurations(i_FCS_config).Active_Controllers = []; % (just for safety: we remove all potential previous fields in "Active_Controllers")
        for i_FCS_controller=1:nb_controllers % by default the controllers are inactive
            FCS.Configurations(i_FCS_config).Active_Controllers.(FCS.Controllers(i_FCS_controller).Identifier) = 0;
        end
        nb_active_controllers = length(FCS.Configurations(i_FCS_config).Active_Controller_Names);
        for i_active_controller=1:nb_active_controllers % now we put the flags for the active controllers (of the current configuration) to 1
            FCS.Configurations(i_FCS_config).Active_Controllers.(FCS.Configurations(i_FCS_config).Active_Controller_Names{i_active_controller}) = 1;            
        end
    end


end