function [y] = delay(input, time,attFac,fs)
%DELAY Simple feedforward delay effect implemented via convolution with an impulse response.
%
% This implementation is adapted from teaching materials and example code
% provided by Dr. Frank Stevens (University of York).
%
% This function creates a delay impulse response (IR) consisting of:
%   - a direct-path impulse at n = 1, and
%   - a series of delayed, attenuated impulses spaced by "time" seconds.
%
% The delayed taps form a repeating echo pattern, with an attenuation factor
% attFac applied per repetition. Alternating taps are set to negative
% polarity to introduce a phase-inverted echo pattern (as in the teaching example)
%
% INPUTS:
%   x      : audio filename OR mono signal vector
%   time   : delay time in seconds (spacing between echoes)
%   attFac : attenuation factor per repetition (0 < attFac < 1)
%   fs     : sampling rate in Hz (used to convert time -> samples)
%
% OUTPUT:
%   y      : delayed output signal (same length as the original input)
%
% METHOD:
%   1) Compute the number of repetitions until the echo amplitude falls below 1e-3.
%   2) Create an impulse response with taps at multiples of the delay in samples.
%   3) Convolve input x with the delay IR.
%   4) Truncate to the original input length.

    % Read input audio 
   if ischar(input) || isstring(input)
        % Load audio source from file
        x = audioread(input);
    else
        % Otherwise, assume the input is already a mono signal in memory
        x = input;
   end

    % Compute how many repetitions are needed (cut-off at magnitude 1e-3)
    numReps = ceil(log(1e-03) / log(attFac));

    % Convert delay time (s) to delay in samples
    delSamps = round(time * fs);

    % Create delay impulse response buffer
    delayIR = zeros(delSamps * (numReps), 1);

    % Direct sound (unit impulse)
    delayIR(1) = 1;

    % Generate attenuated impulses for each repetition
    % (alternating polarity: +, -, +, -, ...)
    for i = 1:numReps
        delAtt = attFac^i .* ((-1).^(i-1));
        delayIR(i * delSamps) = delAtt;
    end

    % Apply the delay via convolution and truncate to original length
    xdel = conv(delayIR, x);
    L = length(x);
    y = xdel(1:L); % Padding length 

end
