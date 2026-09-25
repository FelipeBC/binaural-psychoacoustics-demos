function d = haversine(el1, az1, el2, az2)
%HAVERSINE Angular distance between two directions on a sphere.
%
% This function computes the great-circle (angular) distance between two
% points on a unit sphere, given by their elevation and azimuth angles
% in degrees. It is based on the classical *haversine formula*, widely used
% in spherical geometry.
%
% INPUTS:
%   el1, az1 : elevation and azimuth of the first point (degrees)
%   el2, az2 : elevation and azimuth of the second point (degrees)
%
% OUTPUT:
%   d        : angular distance between the two points (radians)
%
% This metric is used to quantify how far two spatial directions are on the
% sphere, and is suitable for selecting the closest HRIR direction in a
% discrete azimuth/elevation grid.
%--------------------------------------------------------------------------

    % Convert angles from degrees to radians
    el1 = deg2rad(el1);
    az1 = deg2rad(az1);
    el2 = deg2rad(el2);
    az2 = deg2rad(az2);

    % Angular differences
    dEl = el2 - el1;
    dAz = az2 - az1;

    % Haversine formula for spherical distance
    a = sin(dEl/2).^2 + cos(el1).*cos(el2).*sin(dAz/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));

    d = c;   % angular distance (radians)
end
