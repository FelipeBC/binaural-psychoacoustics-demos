function [V, F] = readObj(filename)
%READOBJ  Minimal Wavefront OBJ reader (vertices + triangular faces).
%
% This helper function loads a 3D mesh from a Wavefront .obj file and returns:
%   - V: an [N x 3] array of vertex coordinates (x, y, z)
%   - F: an [M x 3] array of face indices (triangles), referencing rows of V
%
% Parsing rules / limitations (by design, for simplicity):
%   - Only lines starting with 'v ' (vertices) and 'f ' (faces) are parsed.
%   - Comments (# ...) and empty lines are ignored.
%   - Face definitions can be either:
%         f i j k
%     or the common OBJ format with slashes:
%         f i/j/k  j/j/k  k/j/k
%     In both cases, only the vertex index (the part before '/') is used.
%   - Faces with more than 3 vertices are truncated to the first 3 indices.
%     (i.e., this function does NOT triangulate polygons properly; it simply
%     keeps the first triangle and ignores the remaining vertices.)
%
% Example:
%   [V, F] = readObj('skull.obj');
%--------------------------------------------------------------------------

    fid = fopen(filename,'r');
    if fid == -1
        error('Cannot open OBJ file: %s', filename);
    end

    V = [];
    F = [];

    while true
        line = fgetl(fid);
        if ~ischar(line)
            break;   % end of file
        end

        line = strtrim(line);
        if isempty(line) || startsWith(line,'#')
            continue;    % skip comments / empty lines
        end

        % Vertex line: v x y z
        if strncmp(line,'v ',2)
            vals = sscanf(line(3:end),'%f');
            if numel(vals) >= 3
                V(end+1,1:3) = vals(1:3).'; %#ok<AGROW>
            end

        % Face line: f i j k  OR  f i/j/k ...
        elseif strncmp(line,'f ',2)
            tokens = strsplit(strtrim(line(3:end)));
            idx = zeros(1, numel(tokens));
            for k = 1:numel(tokens)
                parts = strsplit(tokens{k},'/');
                idx(k) = str2double(parts{1});   % vertex index only
            end
            if numel(idx) >= 3
                % Keep a single triangle (first 3 vertices)
                F(end+1,1:3) = idx(1:3); %#ok<AGROW>
            end
        end
    end

    fclose(fid);
end
