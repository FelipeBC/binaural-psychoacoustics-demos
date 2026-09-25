function plotTrajectoryHRTF(FrameAngle, az_el_angles, labels)
%plotTrajectoryHRTF Visualise one or multiple HRTF trajectories on a head model.
%
% This figure shows:
%   1) All available HRIR measurement directions (azimuth/elevation grid)
%   2) One or more trajectories (as sequences of HRIR indices, "FrameAngle")
%   3) A head mesh for spatial reference (skull.obj)
%
% USAGE:
%   plotTrajectoryHRTF(FrameAngle, az_el_angles)
%   plotTrajectoryHRTF({FrameAngle1, FrameAngle2, ...}, az_el_angles)
%   plotTrajectoryHRTF({FrameAngle1, FrameAngle2, ...}, az_el_angles, {'Door','Steps',...})
%
% INPUTS:
%   FrameAngle   : vector of HRIR indices OR a cell array of such vectors
%   az_el_angles : [M x 2] directions [azimuth_deg, elevation_deg]
%   labels       : (optional) cell array of labels for each trajectory
%
% NOTES:
% - FrameAngle values must be valid indices into az_el_angles.
% - The view is set to top-down (view(0,90)) to match a polar/top layout.

    % -------------------------------------------------------------
    % 1) Allow single or multiple trajectories
    % -------------------------------------------------------------
    if ~iscell(FrameAngle)
        FrameAngle = {FrameAngle};
    end

    % Create default labels if none provided
    if nargin < 3 || isempty(labels)
        labels = cell(1, numel(FrameAngle));
        for k = 1:numel(FrameAngle)
            labels{k} = sprintf('Trajectory %d', k);
        end
    end

    % Ensure labels length matches number of trajectories
    if numel(labels) ~= numel(FrameAngle)
        error('labels must have the same number of entries as FrameAngle trajectories.');
    end

    % -------------------------------------------------------------
    % 2) Load and prepare the head mesh (skull.obj)
    % -------------------------------------------------------------
    [V, F] = readObj('skull.obj');

    % Centre the mesh at the origin
    center = mean(V, 1);
    V = V - center;

    % Normalise mesh size to a target radius (for consistent plotting)
    targetRadius = 0.7; % head size
    r = sqrt(sum(V.^2, 2));
    V = V * (targetRadius / max(r));

    % Fixed rotation to match plotting orientation
    angX = 90;  % degrees
    angY = 0;
    angZ = 180;

    ax = deg2rad(angX);
    ay = deg2rad(angY);
    az = deg2rad(angZ);

    Rx = [1 0 0;
          0 cos(ax) -sin(ax);
          0 sin(ax)  cos(ax)];

    Ry = [ cos(ay) 0 sin(ay);
           0       1      0;
          -sin(ay) 0 cos(ay)];

    Rz = [cos(az) -sin(az) 0;
          sin(az)  cos(az) 0;
          0        0       1];

    R = Rz * Ry * Rx;
    V = (R * V.').';

    % -------------------------------------------------------------
    % 3) Convert ALL available HRIR directions to Cartesian coordinates
    % -------------------------------------------------------------
    az_rad = deg2rad(az_el_angles(:,1));
    el_rad = deg2rad(az_el_angles(:,2));

    x_all = cos(el_rad) .* cos(az_rad);
    y_all = cos(el_rad) .* sin(az_rad);
    z_all = sin(el_rad);

    % -------------------------------------------------------------
    % 4) Base plot: reference sphere, head mesh, HRIR grid
    % -------------------------------------------------------------
    figure; hold on; axis equal;

    [sx, sy, sz] = sphere(40);
    surf(sx, sy, sz, 'FaceAlpha', 0.07, 'EdgeAlpha', 0.15);

    h_head = patch('Faces', F, 'Vertices', V, ...
        'FaceColor', [0.9 0.8 0.7], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 1);

    camlight headlight;
    lighting gouraud;

    h_hrtf = scatter3(x_all, y_all, z_all, 28, 'b', 'filled', 'MarkerFaceAlpha', 0.5);

    % -------------------------------------------------------------
    % 5) Plot trajectories (same symbol, different colours) + start/end markers
    % -------------------------------------------------------------
    K = numel(FrameAngle);

    % Use MATLAB's default qualitative colormap (gives distinct colours)
    colors = lines(K);

    trajHandles = gobjects(1, K);

    for k = 1:K
        fa = FrameAngle{k}(:);

        % Index validation
        if any(fa < 1) || any(fa > size(az_el_angles,1))
            error('FrameAngle{%d} contains indices outside valid range [1..%d].', ...
                  k, size(az_el_angles,1));
        end

        az_real = az_el_angles(fa, 1);
        el_real = az_el_angles(fa, 2);

        az_real_rad = deg2rad(az_real);
        el_real_rad = deg2rad(el_real);

        % coordinate mapping 
        x_real = cos(el_real_rad) .* sin(az_real_rad);
        y_real = cos(el_real_rad) .* cos(az_real_rad);
        z_real = sin(el_real_rad);

        c = colors(k,:);

        % Trajectory: same '.-' style, distinct colour per source
        trajHandles(k) = plot3(x_real, y_real, z_real, '.-', ...
            'Color', c, 'LineWidth', 2, 'MarkerSize', 10, ...
            'DisplayName', labels{k});

        % Start: filled circle (same colour)
        scatter3(x_real(1), y_real(1), z_real(1), 90, c, 'o', 'filled');

        % End: filled square (same colour)
        scatter3(x_real(end), y_real(end), z_real(end), 90, c, 's', 'filled');
    end

    % -------------------------------------------------------------
    % 6) Plot cosmetics and legend
    % -------------------------------------------------------------
    xlabel('X'); ylabel('Y'); zlabel('Z');
    % title('Binaural Field');
    grid on;

    % Dummy handles for "Start" and "End" legend entries (style only)
    h_start = scatter3(NaN, NaN, NaN, 90, 'k', 'o', 'filled');
    h_end   = scatter3(NaN, NaN, NaN, 90, 'k', 's', 'filled');

    legend([h_hrtf, trajHandles, h_start, h_end, h_head], ...
           [{'HRIR positions'}, labels, {'Start', 'End', 'Head model'}], ...
           'Location', 'bestoutside');

    % Top-down view
    view(0, 90);
end
