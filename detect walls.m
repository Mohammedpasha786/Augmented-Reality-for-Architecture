function wallSegments = detect_walls(frame)
% detect_walls  Detect wall line segments using Canny + Hough transform
%
% INPUTS:
%   frame        — H×W×3 uint8 RGB image
%
% OUTPUT:
%   wallSegments — Mx4 array of [x1 y1 x2 y2] pixel coordinates

config;

gray  = im2gray(frame);
edges = edge(gray, 'Canny', CANNY_THRESH);

[H, T, R] = hough(edges, 'Theta', -90:HOUGH_THETA_RES:89, ...
                         'RhoResolution', HOUGH_RHO_RES);

peaks = houghpeaks(H, HOUGH_NUM_PEAKS, 'Threshold', 0.3 * max(H(:)));

lines = houghlines(edges, T, R, peaks, ...
    'FillGap', HOUGH_FILL_GAP, 'MinLength', HOUGH_MIN_LENGTH);

if isempty(lines)
    wallSegments = [];
    return;
end

wallSegments = zeros(length(lines), 4);
for k = 1:length(lines)
    wallSegments(k,:) = [lines(k).point1, lines(k).point2];
end

% Remove near-duplicate segments (merge lines within 5 px of each other)
wallSegments = merge_close_segments(wallSegments, 5);
end

%% --------------------------------------------------------
function segs = merge_close_segments(segs, tol)
% Simple greedy merge: if midpoints are within tol pixels, keep the longer one
if size(segs, 1) < 2, return; end

keep = true(size(segs, 1), 1);
midX = (segs(:,1) + segs(:,3)) / 2;
midY = (segs(:,2) + segs(:,4)) / 2;
len  = hypot(segs(:,3)-segs(:,1), segs(:,4)-segs(:,2));

for i = 1:size(segs,1)
    if ~keep(i), continue; end
    for j = i+1:size(segs,1)
        if ~keep(j), continue; end
        dist = hypot(midX(i)-midX(j), midY(i)-midY(j));
        if dist < tol
            if len(i) >= len(j)
                keep(j) = false;
            else
                keep(i) = false;
                break;
            end
        end
    end
end
segs = segs(keep, :);
end
