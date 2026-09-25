function idx = closestHRIR(targetAz, targetEl, az_el_angles)
%CLOSESTHRIR Find the nearest HRIR direction to a target azimuth/elevation.
%
% This function searches a discrete set of measured HRIR directions and
% returns the index of the entry that is angularly closest to the desired
% target direction. The distance between directions is computed on the
% unit sphere using the haversine formula (great-circle distance).
%
% INPUTS:
%   targetAz     : desired azimuth (degrees)
%   targetEl     : desired elevation (degrees)
%   az_el_angles : [N x 2] table of available directions
%                  [azimuth_deg, elevation_deg]
%
% OUTPUT:
%   idx          : index of the closest HRIR in az_el_angles
% ------------------------------------------------------------------------

    N = size(az_el_angles, 1);   % number of HRIR measurement positions
    dist = zeros(N, 1);          % preallocate distance vector

    % Loop over all HRIR measurement directions
    for i = 1:N
        az_i = az_el_angles(i, 1);   % azimuth of entry i
        el_i = az_el_angles(i, 2);   % elevation of entry i

        % Compute spherical (great-circle) distance to the target
        dist(i) = haversine(targetEl, targetAz, el_i, az_i);
    end

    % Find the index corresponding to the minimum angular distance
    [~, idx] = min(dist);
end
