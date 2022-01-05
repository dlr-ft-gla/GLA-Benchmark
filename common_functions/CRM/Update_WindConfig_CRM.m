% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [WindConfig] = Update_WindConfig_CRM(WindConfig, FlightPoint)
%Updates WindModelDef according to the information stored
%in WindConfig.

if strcmp(WindConfig.WindModelType, 'OneMinusCosineGusts')
    if ~isfield(WindConfig, 'U_ds') || (WindConfig.U_ds == -1)
        Fg = Calculate_Fg_CRM(FlightPoint.z);
        WindConfig.U_ds = CS25_341_U_ds(WindConfig.H, Fg, FlightPoint.z);
    end
    n_gusts = size(WindConfig.H,1);
    if (size(WindConfig.x_start,1) ~= n_gusts) || (size(WindConfig.U_ds,1) ~= n_gusts) ...
            || ((size(WindConfig.gust_dir,1) ~= n_gusts) && (size(WindConfig.gust_dir,1) ~= 1))
        error('Definition of multiple discrete gusts is inconsistent.');
    end
    
    WindConfig.WindModelDef(:,1) = WindConfig.x_start;
    WindConfig.WindModelDef(:,2) = WindConfig.H;
    WindConfig.WindModelDef(:,3) = abs(WindConfig.U_ds).*WindConfig.gust_dir;
    
elseif strcmp(WindConfig.WindModelType, 'ExternalWindFieldWithEquidistantGrid')
    % Assume (for now) that the basic signal itself doesn't change - only
    % the RMS wind speed can be varied.
    WindConfig.WindModelDef = [WindConfig.x_signal(:), ...
                               WindConfig.U_rms*WindConfig.w_norm(:), ...
                               zeros(length(WindConfig.x_signal), 3)];
    
end



end

