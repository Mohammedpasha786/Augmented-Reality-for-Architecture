function walls3D = build_3d_walls(floorPlan)
% build_3d_walls  Extrude 2D wall segments into 3D geometry
%
% Each wall segment becomes a rectangular face (quad) with:
%   bottom edge on Z = 0  (floor plane)
%   top    edge on Z = WALL_HEIGHT_M
%
% INPUTS:
%   floorPlan  — struct from parse_floor_plan
%
% OUTPUT:
%   walls3D    — struct array (one per wall):
%                  .verts   4×3  quad vertices [x y z] world coords
%                  .normal  1×3  outward face normal
%                  .lengthM scalar wall length in metres
%                  .midPt   1×3  midpoint of bottom edge

config;

segs  = floorPlan.walls;    % normalised [0,1] coords
nW    = floorPlan.nWalls;
walls3D(nW) = struct('verts', [], 'normal', [], 'lengthM', [], 'midPt', []);

for k = 1:nW
    x1n = segs(k,1); y1n = segs(k,2);
    x2n = segs(k,3); y2n = segs(k,4);

    % Map normalised image coords to world metres (Z=0 floor plane)
    x1 = x1n * floorPlan.imageSize(2) * FLOOR_PLAN_SCALE;
    y1 = y1n * floorPlan.imageSize(1) * FLOOR_PLAN_SCALE;
    x2 = x2n * floorPlan.imageSize(2) * FLOOR_PLAN_SCALE;
    y2 = y2n * floorPlan.imageSize(1) * FLOOR_PLAN_SCALE;

    % Four vertices of the extruded quad (CCW order viewed from outside)
    %   v1 — bottom-left   v2 — bottom-right
    %   v4 — top-left      v3 — top-right
    H  = WALL_HEIGHT_M;
    v1 = [x1, y1, 0];
    v2 = [x2, y2, 0];
    v3 = [x2, y2, H];
    v4 = [x1, y1, H];

    walls3D(k).verts   = [v1; v2; v3; v4];
    walls3D(k).lengthM = hypot(x2-x1, y2-y1);
    walls3D(k).midPt   = [(x1+x2)/2, (y1+y2)/2, H/2];

    % Outward normal (perpendicular to wall, in XY plane)
    dx = x2 - x1; dy = y2 - y1;
    n  = [-dy, dx, 0];
    walls3D(k).normal = n / (norm(n) + eps);
end
end
