function rendered = render_walls(frame, projWalls, walls3D)
% render_walls  Draw 3D wall quads onto the video frame with depth sorting
%
% Uses painter's algorithm: draws far walls first, near walls on top.
% Supports per-face alpha blending for transparency.

config;

rendered = frame;
H = size(frame, 1);
W = size(frame, 2);

% Filter visible walls and sort back-to-front (painter's algorithm)
visIdx = find([projWalls.visible]);
if isempty(visIdx), return; end

depths = [projWalls(visIdx).depth];
[~, sortOrd] = sort(depths, 'descend');
drawOrder = visIdx(sortOrd);

% Convert to double for alpha blending
canvas = double(rendered);
wallClr = WALL_COLOR * 255;
edgeClr = EDGE_COLOR * 255;

for k = drawOrder
    pts = projWalls(k).pts2D;   % 4×2

    % Clip to image bounds
    pts(:,1) = max(1, min(W, pts(:,1)));
    pts(:,2) = max(1, min(H, pts(:,2)));

    % Create binary mask for this quad
    mask = poly2mask(pts(:,1)', pts(:,2)', H, W);

    if ~any(mask(:)), continue; end

    % Alpha blend fill
    alpha = WALL_ALPHA;
    for ch = 1:3
        layer = canvas(:,:,ch);
        layer(mask) = (1 - alpha) * layer(mask) + alpha * wallClr(ch);
        canvas(:,:,ch) = layer;
    end

    % Draw edges (solid lines)
    rendered = uint8(canvas);
    nPts = size(pts, 1);
    for e = 1:nPts
        p1 = round(pts(e, :));
        p2 = round(pts(mod(e, nPts)+1, :));
        rendered = insertShape(rendered, 'Line', [p1(1) p1(2) p2(1) p2(2)], ...
            'Color', round(edgeClr), 'LineWidth', 2);
    end
    canvas = double(rendered);
end

rendered = uint8(canvas);
end
