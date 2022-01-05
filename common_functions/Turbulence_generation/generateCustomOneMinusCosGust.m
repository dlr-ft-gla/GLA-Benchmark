% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

function [t_signal, w_gust] = generateCustomOneMinusCosGust(Vinf, amp, h, dt, t_start)

if nargin < 5
    t_start = 0;
end

%% Gust velocity vector

gust_t  = 2 * h / Vinf; %Gust duration (s)
t_signal = (0:dt:gust_t)';
w_gust   = (amp/2) * (1-cos(pi*Vinf*t_signal/h));

t_signal = (0:dt:(gust_t+t_start))';
w_gust = [zeros(round(t_start/dt),1); w_gust];

