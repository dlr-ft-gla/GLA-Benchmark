function [PIP_out] = Compute_PIP(accel_signal_cg, q_signal, t_signal)
% Calculate Percentage of Ill Passengers at three stations.  
%
% References:
% [1]L. Zuo and S. A. Nayfeh, “Low order continuous-time filters for approximation
%    of the ISO 2631-1 human vibration sensitivity weightings,” Journal of Sound and Vibration, 
%    vol. 265, no. 2, pp. 459–465, Aug. 2003, doi: 10.1016/S0022-460X(02)01567-5.
%
% [2]F. Kubica and B. Madelaine, “Passenger Comfort Improvement by Integrated Control Law Design,” 
%    presented at the RTO AVT Specialitsts’ Meeting on Structural Aspects of Flexible Aircraft Control,
%    Ottawa, Canada, Oct. 1999.
%  
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

dt_signal = t_signal(2)-t_signal(1);

% Generate fore and aft accelerations
q_signal = q_signal * pi/180; % convert from deg/s to rad/s

l_accel = 20; % [m]

q_dot_signal = gradient(q_signal,dt_signal);

% Note: q is positive pitching upwards, az is positive downwards
accel_signal_fore = accel_signal_cg - l_accel*q_dot_signal;
accel_signal_aft = accel_signal_cg + l_accel*q_dot_signal;


% Definition of PIP filter (approximating ISO2631-1, from [1]) 
PIP_filt_ct = tf([0.1457 0.2331 13.75 1.705 0.3596], [1 7.757 19.06 28.37 18.52 7.23]);

% Filter acceleration:
accel_filt_cg   = lsim(PIP_filt_ct, accel_signal_cg,   t_signal); 
accel_filt_fore = lsim(PIP_filt_ct, accel_signal_fore, t_signal); 
accel_filt_aft  = lsim(PIP_filt_ct, accel_signal_aft,  t_signal); 

% Calculate PIP: (from [2])
PIP_cg   = (1/3) * sqrt(trapz( t_signal, accel_filt_cg.^2));
PIP_fore = (1/3) * sqrt(trapz( t_signal, accel_filt_fore.^2));
PIP_aft  = (1/3) * sqrt(trapz( t_signal, accel_filt_aft.^2));

PIP_out  = [PIP_fore, PIP_cg, PIP_aft];

end

