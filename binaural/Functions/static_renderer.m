function [y, ang] = static_renderer (input_file, Az, El, A)
%STATIC_RENDERER Render source at a fixed spatial position using HRIRs.
%
% This implementation is adapted from teaching materials and example code
% provided by Dr. Frank Stevens (University of York).
%
% The function performs *static binaural rendering* by convolving a mono
% input signal with a pair of Head-Related Impulse Responses (HRIRs)
% corresponding to a given azimuth and elevation.
%
% The source can be provided either as:
%   - a filename (string or char), in which case the audio is loaded from disk, or
%   - a vector already in memory (assumed to be a mono signal).
%
% INPUTS:
%   input_file : audio filename OR mono signal vector
%   Az         : desired azimuth in degrees
%   El         : desired elevation in degrees
%   A          : linear gain applied after rendering
%
% OUTPUTS:
%   y   : stereo binaural signal [left right]
%   ang : index of the HRIR direction selected for plotting (closest match)
%
% The function:
%   1) Loads the HRIR dataset and metadata
%   2) Reads or accepts the input signal
%   3) Finds the closest HRIR direction to (Az, El)
%   4) Convolves the signal with the left and right HRIRs
%   5) Normalises the output to avoid clipping    
%--------------------------------------------------------------------------

    % Load BRIR/HRIR data
    load('BRIR_parse.mat', 'HRIR_set_L', 'HRIR_set_R', 'fs', 'az_el_angles');
   
    % If the input is a filename, read the audio from disk
    if ischar(input_file) || isstring(input_file)
        % Load the audio source
        [x, wav_Fs] = audioread(input_file);
    
        % --- Signal preparation and validation ---
        % Check that the sampling rates match
        if wav_Fs ~= fs
            error('Sampling rates must match. wav_Fs: %d, fs: %d', wav_Fs, fs);
        end
        
    else
        % Otherwise, assume the input is already a signal in memory
        x = input_file;
    end

    % Find the closest available HRIR for the requested azimuth/elevation
    ang = closestHRIR(Az, El, az_el_angles);

    % Extract left and right HRIRs for that direction
    left_ch  = HRIR_set_L(ang, :);
    right_ch = HRIR_set_R(ang, :);

    % Convolve the mono source with the HRIRs
    l_conv = conv(x, left_ch);
    r_conv = conv(x, right_ch);

    % Build stereo output
    y = [l_conv, r_conv];

    % Normalise 
    y = A .* y ./ max(max(abs(y)));

end
