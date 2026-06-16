function measurements = measure_walls(floorPlan, scaleFactor)
% measure_walls  Compute physical wall lengths from normalised floor plan
%
% INPUTS:
%   floorPlan    — struct from parse_floor_plan
%   scaleFactor  — metres per normalised unit (default: FLOOR_PLAN_SCALE * imageWidth)
%
% OUTPUT:
%   measurements — Nx1 struct with .wallIdx, .lengthM, .lengthFt

config;

if nargin < 2
    scaleFactor = FLOOR_PLAN_SCALE * floorPlan.imageSize(2);
end

segs = floorPlan.walls;
nW   = floorPlan.nWalls;
measurements(nW) = struct('wallIdx', 0, 'lengthM', 0, 'lengthFt', 0);

for k = 1:nW
    dx = segs(k,3) - segs(k,1);
    dy = segs(k,4) - segs(k,2);
    lenNorm = hypot(dx, dy);
    lenM    = lenNorm * scaleFactor;

    measurements(k).wallIdx  = k;
    measurements(k).lengthM  = lenM;
    measurements(k).lengthFt = lenM * 3.28084;
end

fprintf('\n--- Wall Measurements ---\n');
for k = 1:nW
    fprintf('  Wall %2d: %.2f m (%.1f ft)\n', k, ...
        measurements(k).lengthM, measurements(k).lengthFt);
end
end
