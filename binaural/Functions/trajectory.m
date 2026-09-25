function [FrameAngle, azPath, elPath, tFrames] = ...
            trajectory(Nframes, step_size, fs, ...
                          tStart, tEnd, ...
                          az_ini, el_ini, ...
                          az_end, el_end, ...
                          az_el_angles)
%TRAJECTORY Generate a discrete azimuth/elevation path and corresponding HRIR indices.
%
% This function defines a linear spatial trajectory for a moving sound source
% over a given number of processing frames. It returns:
%   - the azimuth and elevation values per frame,
%   - the time stamp of each frame,
%   - and the corresponding HRIR index for each frame.
%
% The motion is defined by:
%   - a start time (tStart) and end time (tEnd) in seconds,
%   - initial and final azimuth/elevation angles.
%
% Outside the motion interval, the source remains fixed at the initial
% (before tStart) or final (after tEnd) position.
%
% INPUTS:
%   Nframes       : total number of processing frames
%   step_size     : hop size between frames (samples)
%   fs            : sampling rate (Hz)
%   tStart, tEnd  : start and end time of the movement (seconds)
%   az_ini, el_ini: initial azimuth and elevation (degrees)
%   az_end, el_end: final azimuth and elevation (degrees)
%   az_el_angles  : [M x 2] table of available HRIR directions
%
% OUTPUTS:
%   FrameAngle : HRIR index selected for each frame
%   azPath     : azimuth value per frame (degrees)
%   elPath     : elevation value per frame (degrees)
%   tFrames    : time of each frame (seconds)
%--------------------------------------------------------------------------

    % 1) Time stamp of each processing frame
    tFrames = ((0:Nframes-1) * step_size) / fs;

    % 2) Find start and end frame indices based on time
    nStart = find(tFrames >= tStart, 1, 'first');
    nEnd   = find(tFrames <= tEnd,   1, 'last');

    % 3) Build azimuth trajectory
    azPath = zeros(1, Nframes);
    azPath(1:Nframes) = az_ini;  % initial value
    azPath(nStart:nEnd) = round(linspace(az_ini, az_end, nEnd - nStart + 1));
    azPath(nEnd:end) = az_end;   % final value

    % 4) Build elevation trajectory
    elPath = zeros(1, Nframes);
    elPath(1:Nframes) = el_ini;
    elPath(nStart:nEnd) = round(linspace(el_ini, el_end, nEnd - nStart + 1));
    elPath(nEnd:end) = el_end;

    % 5) Convert (azimuth, elevation) pairs to HRIR indices
    FrameAngle = zeros(1, Nframes);
    for n = 1:Nframes
        FrameAngle(n) = closestHRIR(azPath(n), elPath(n), az_el_angles);
    end
end
