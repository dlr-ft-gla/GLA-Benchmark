function [x_signal, w, w_dot, w_ddot, w_dddot] = generateNormalizedVonKarmanTurbulence(VTAS, t, rnd_seed)
% function [x_signal, w, w_dot, w_ddot, w_dddot] = generateNormalizedVonKarmanTurbulence(VTAS, t, rnd_seed)
%
% Returns a normalized turbulent vertical wind with von-Kármán spectrum as
% defined in EASA CS 25.341(b), normalized to obtain 1 m/s standard deviation
%
% 22.11.2021    German Aerospace Center (DLR), Institute of Flight Systems
%               Daniel Kiehn (daniel.kiehn@dlr.de)
%
% Inputs:
% VTAS      True airspeed in meters per second
% t         Time vector in seconds
% rnd_seed  Random seed (optional input), valid for Matlab versions R2011a
%           and newer. Refer to the documentation of rng() for details.
%
% Outputs:
% x         x coordinates in geodetic space in m
% w         Wind speed vector in m/s
% w_dot     First derivative of the wind speed in m/s^2
% w_ddot    Second derivative of the wind speed in m/s^3
% w_dddot   Third derivative of the wind speed in m/s^4
%
%
% Notes:
% The "easy access" EASA certification specifications can be found under:
% https://www.easa.europa.eu/document-library/easy-access-rules/easy-access-rules-large-aeroplanes-cs-25
%
% Copyright (c) 2022 Deutsches Zentrum fuer Luft- und Raumfahrt e.V. (DLR / German Aerospace Center). 
% Released under MIT License. 

%% Main function

% Initialize random numbers generation: only effective if the user specified
% a random seed. Note: the rng command was introduced in MATLAB R2011a (7.12)
if (~verLessThan('matlab','7.12')) && (nargin > 2)
    rng(rnd_seed); 
end

% Assemble the frequency vector
fs = 1 / (t(2) - t(1)); % Sampling frequency
n = length(t);          % Total number of points
f_ref = fs*(0:n-1)/n;   % Reference frequency vector in Hz

% Create a (one-sided) von Kármán PSD with unit standard deviation, cut-off frequency at fs/2
fc = fs/2;
oneSidedVonKarmanPSD = calculateNormalizedVonKarmanPSD(VTAS, f_ref, fc);

% Obtain Fourier transform from PSD
spec = getTwoSidedSpectrumFromOneSidedPSD(oneSidedVonKarmanPSD, f_ref);

% Derive the signal
w = 2*pi*f_ref;
spec_der = 1j*w .* spec;       % First derivative
spec_der2 = -(w.^2) .* spec;   % Second derivative
spec_der3 = (1j*w).^3 .* spec; % Third derivative

% Get the time signal for this spectrum
[tmp, w]       = createTimeSignalFromFourierTransform(spec,      f_ref); %#ok<ASGLU>
[tmp, w_dot]   = createTimeSignalFromFourierTransform(spec_der,  f_ref); %#ok<ASGLU>
[tmp, w_ddot]  = createTimeSignalFromFourierTransform(spec_der2, f_ref); %#ok<ASGLU>
[tmp, w_dddot] = createTimeSignalFromFourierTransform(spec_der3, f_ref); %#ok<ASGLU>

x_signal = VTAS*t;

end


%% Subfunctions

% Returns the one-sided PSD of the von Kármán spectrum over the requested frequencies.
% The PSD is defined with respect to f. Unit of the resulting PSD: (m/s)^2 / Hz
function oneSidedPSD = calculateNormalizedVonKarmanPSD(V, f, fc)
    % V:  true airspeed in m/s
    % f:  frequency vector of the PSD in Hz
    % fc: cutoff frequency of the spectrum

    L = 762;        	% Scale length in m, equals 2500 ft - CS25.341(b)(2)
    Omega = 2*pi*f/V;   % Spatial frequency: Omega = omega/V = 2*pi*f/V

    % Normalized one-sided von Kármán spectrum (unit standard deviation),
    % scaled for integration with respect to f.
    oneSidedPSD = (2*L/V) * (1+ 8/3*(1.339*Omega*L).^2) ./ (1+ (1.339*Omega*L).^2).^(11/6);
    % Equation: see F. Hoblit: "Gust Loads on Aircraft: Concepts and
    % Applications", (page 42). AIAA Education Series, 1988. doi: 10.2514/4.861888

    oneSidedPSD(1) = 0; % Remove power at zero frequency (constant offset)

    % Cut off at/above the cutoff frequency
    oneSidedPSD(f >= fc) = 0.0;
end


% Generate the two-sided Fourier transform for a one-sided PSD
function twoSidedSpectrum = getTwoSidedSpectrumFromOneSidedPSD(oneSidedPSD, f)
    % oneSidedPSD: one-sided power spectral density in [unit]^2 / Hz
    % f:           frequency vector in Hz

    df = f(2) - f(1); % Frequency resolution

    % Transform from one-sided PSD to two-sided amplitude
    amplitude = (oneSidedPSD/2 / df).^0.5;

    % Create a random phase
    phase = 2*pi*rand(1, length(f)); % Assemble random phase shift
    phase(1) = 0.0; % Set the phase shift of the first term to zero

    % Assemble the complex spectrum
    twoSidedSpectrum = amplitude .* exp(1j*phase);
end


% Returns the time signal associated with a given Fourier spectrum.
function [t, x] = createTimeSignalFromFourierTransform(twoSidedSpectrum, f_ref)
    % twoSidedSpectrum: two-sided amplitude spectrum of the signal
    % f_ref:            frequency vector in Hz

    % Get the target size of the time vectors
    n_target = length(f_ref);

	% Symmetrize the spectrum
    if mod(n_target, 2) == 1
        n_split = (n_target-1)/2 + 1;

        twoSidedSpectrum = twoSidedSpectrum(1: n_split); % Cut the input spectrum
		flip_spectrum = conj(fliplr(twoSidedSpectrum));  % Obtain the frequency vector

        % Assemble them in correct order
        complete_fft = [twoSidedSpectrum(1, :), flip_spectrum(1, 1:end-1)];
	else
        n_split = n_target/2 + 1;

        twoSidedSpectrum = twoSidedSpectrum(1:n_split);      % Cut the input spectrum
        twoSidedSpectrum(end) = real(twoSidedSpectrum(end));

		flip_spectrum = conj(fliplr(twoSidedSpectrum));      % Obtain the frequency vector

        % Assemble them in correct order
        complete_fft = [twoSidedSpectrum(1, :), flip_spectrum(1, 2:end-1)];
    end

    % Obtain the IFFT
    [t, x] = getIFFT(complete_fft, f_ref);
end


% Returns the inverse FFT from a scaled FFT to obtain the continuous signal
function [t, x] = getIFFT(x_fft, f)
    % x_fft: complex Fourier spectrum
    % f:     frequency vector

    n = length(x_fft);
    del_f = f(2) - f(1);    % Frequency resolution
    del_t = 1/(n*del_f);    % Time resolution

    x = ifft(x_fft)/del_t;	% Scale to conserve the amplitude
    t = del_t * (0:n-1);	% Assemble time vector
end
