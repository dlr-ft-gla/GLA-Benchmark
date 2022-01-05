% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [WindConfig] = Compute_ContTurbCS25_CRM(alt, VTAS, SimConfig, rnd_seed)
	% alt : Flight altitude (m).
	% VTAS : true air speed (m/s).
    % SimConfig : Simulation Configuration struct.
	% rnd_seed : random number seed. Optional input.

	% Initialize random numbers generation
    if nargin < 4
%         rnd_seed = 'shuffle';
        rnd_seed = 'default';
    end
    
    t_start = SimConfig.StartTime - 10;
    t_end = SimConfig.EndTime + 10; % Extra 10 seconds to ensure turbulence field is present through end of simulation.
    dt = SimConfig.SampleTime;
    
    t_signal = t_start:dt:t_end;
    
    % Initialize time vector:
    [x_signal, w_norm] = generateNormalizedVonKarmanTurbulence(VTAS, t_signal, rnd_seed);
    
    % Calculate the RMS for the corresponding altitude
    U_sigma_ref = CS25_341_U_sigma_ref(alt);
    F_g = Calculate_Fg_CRM(alt); % Flight profile alleviation factor
    U_sigma = F_g * U_sigma_ref;
    
    U_rms = 0.4*U_sigma;
    
    w_turb = U_rms * w_norm; 
    
    %% Assign output
    
    WindConfig = [];
    WindConfig.WindModelType = 'ExternalWindFieldWithEquidistantGrid';
    WindConfig.WindModelDef = [x_signal(:), w_turb(:), zeros(length(t_signal), 3)];
    WindConfig.x_signal = x_signal;
    WindConfig.w_norm   = w_norm;
    WindConfig.U_rms    = U_rms;
    
end