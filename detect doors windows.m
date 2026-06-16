function features = detect_doors_windows(frame, wallSegments)
% detect_doors_windows  Detect door/window symbols in the floor plan
%
% Implements Advanced Feature: include markers for windows/doors.
% Strategy:
%   Doors   — small arc symbols (circle segment near a wall break)
%   Windows — three parallel lines crossing a wall segment
%
% OUTPUT:
%   features — struct array with fields:
%                .type     'door' | 'window'
%                .wallIdx  index of associated wall segment
%                .posNorm  [x,y] normalised position in image

config;

gray     = im2gray(frame);
features = struct('type', {}, 'wallIdx', {}, 'posNorm', {});

H = size(frame,1); W = size(frame,2);

%% Door detection: look for small circular arcs (Hough circles)
try
    circles = imfindcircles(gray, [10 40], 'ObjectPolarity', 'dark', ...
        'Sensitivity', 0.88, 'EdgeThreshold', 0.1);
catch
    circles = [];
end

if ~isempty(circles)
    for i = 1:size(circles, 1)
        cx = circles(i,1); cy = circles(i,2);
        % Find nearest wall
        wIdx = nearest_wall(cx, cy, wallSegments);
        if wIdx > 0
            features(end+1) = struct('type', 'door', 'wallIdx', wIdx, ...
                'posNorm', [cx/W, cy/H]); %#ok<AGROW>
        end
    end
end

%% Window detection: triple-line pattern perpendicular to walls
% (Simplified: look for short line clusters at right angles to wall direction)
edges = edge(gray, 'Canny', CANNY_THRESH);
[H_hough, T, R] = hough(edges, 'Theta', -90:1:89, 'RhoResolution', 1);
peaks = houghpeaks(H_hough, 20, 'Threshold', 0.2*max(H_hough(:)));
lines = houghlines(edges, T, R, peaks, 'FillGap', 5, 'MinLength', 15);

for j = 1:length(lines)
    len = hypot(diff([lines(j).point1(1), lines(j).point2(1)]), ...
                diff([lines(j).point1(2), lines(j).point2(2)]));
    if len < 15 || len > 50, continue; end

    midX = (lines(j).point1(1) + lines(j).point2(1)) / 2;
    midY = (lines(j).point1(2) + lines(j).point2(2)) / 2;
    wIdx = nearest_wall(midX, midY, wallSegments);
    if wIdx > 0 && isPerpendicularToWall(lines(j), wallSegments(wIdx,:))
        features(end+1) = struct('type', 'window', 'wallIdx', wIdx, ...
            'posNorm', [midX/W, midY/H]); %#ok<AGROW>
    end
end
end

%% --------------------------------------------------------
function idx = nearest_wall(px, py, wallSegments)
idx = 0;
if isempty(wallSegments), return; end
dists = zeros(size(wallSegments,1),1);
for k = 1:size(wallSegments,1)
    dists(k) = point_to_segment_dist(px, py, wallSegments(k,:));
end
[minD, idx] = min(dists);
if minD > 20, idx = 0; end
end

function d = point_to_segment_dist(px, py, seg)
x1=seg(1); y1=seg(2); x2=seg(3); y2=seg(4);
dx=x2-x1; dy=y2-y1;
t = max(0, min(1, ((px-x1)*dx + (py-y1)*dy) / (dx^2+dy^2+eps)));
d = hypot(px-(x1+t*dx), py-(y1+t*dy));
end

function yes = isPerpendicularToWall(line, wallSeg)
wallAngle = atan2d(wallSeg(4)-wallSeg(2), wallSeg(3)-wallSeg(1));
lineAngle  = atan2d(line.point2(2)-line.point1(2), line.point2(1)-line.point1(1));
angleDiff  = abs(mod(abs(wallAngle - lineAngle), 180) - 90);
yes = angleDiff < 15;
end
