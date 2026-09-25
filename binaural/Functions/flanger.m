function [y] = flanger(x,fs,f,tmax,fback)
%FLANGER Simple flanger effect using a sinusoidally modulated delay line with feedback.
%
% This implementation is adapted from teaching materials and example code
% provided by Dr. Frank Stevens (University of York).
% It is also inspired in part by the MATLAB Central example:
% https://uk.mathworks.com/matlabcentral/fileexchange/43404-audio-flanger
%
% This function implements a classic flanger by mixing the dry input with a
% time-varying delayed version of itself. The delay time is modulated by a
% sinusoid (LFO), producing a comb-filter that sweeps over time. A feedback
% term reinjects part of the delayed signal back into the delay line to
% increase resonance and depth.
%
% INPUTS:
%   x     : input audio *filename* (string/char). The file is read using audioread.
%           (Note: in this implementation, x is treated as a filepath, not a signal vector.)
%   fs    : sampling rate in Hz
%   f     : flanger modulation rate (Hz) for the sinusoidal LFO
%   tmax  : maximum delay time (seconds) of the flanger
%   fback : feedback gain (typically 0..<1). Higher values increase resonance.
%
% OUTPUT:
%   y     : flanged output signal (mono)
%
% METHOD:
%   1) Convert tmax to a maximum delay in samples.
%   2) Create an LFO-controlled delay index sinDel(i) that varies from 1 to tmaxS+1.
%   3) Maintain a delay line buffer of length tmaxS+1.
%   4) For each sample:
%        - output = dry + delayed
%        - update delay line with dry + feedback*delayed

    % Load input audio from file
    x = audioread(x);

    % Maximum delay in samples
    tmaxS = round(tmax * fs);

    % Signal length and time axis for the LFO
    N = length(x);
    T = 1/fs;
    timeVector = 0:T:(N-1)*T;

    % Sinusoidal delay control (in samples), range: 1 .. tmaxS+1
    sinDel = round(tmaxS * (0.5*sin(2*pi*f*timeVector) + 0.5) + 1);

    % Delay line buffer (circular buffer not used here; shift-register style)
    delayLine = zeros(tmaxS+1, 1);

    % Output buffer
    y = zeros(length(x), 1);

    % Sample-by-sample processing
    for i = 1:length(x)
        % Mix dry signal with the current delayed tap
        y(i) = x(i) + delayLine(sinDel(i));

        % Update delay line:
        % - write current input sample plus feedback from the tapped delay
        % - shift the rest of the delay line down by one sample
        delayLine = [x(i) + fback*delayLine(sinDel(i)); delayLine(1:end-1)];
    end
end
