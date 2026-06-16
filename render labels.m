function frame = render_labels(frame, projWalls, walls3D, R, t, cameraParams)
% render_labels  Overlay wall length measurements on each visible wall
%
% Implements Advanced Feature: Automatically measure and display wall lengths.
% Scale factor = FLOOR_PLAN_SCALE (config.m): 1 pixel = 1 mm at 1:1 print.

config;

for k = 1:length(projWalls)
    if ~projWalls(k).visible, continue; end

    lengthM   = walls3D(k).lengthM;
    labelStr  = sprintf('%.2f m', lengthM);

    % Project midpoint of wall top edge to image
    midPt3D   = walls3D(k).midPt;
    midPt2D   = worldToImage(cameraParams, R, t, midPt3D);
    midPt2D   = round(midPt2D);

    H = size(frame,1); W = size(frame,2);
    if midPt2D(1) < 1 || midPt2D(1) > W || midPt2D(2) < 1 || midPt2D(2) > H
        continue;
    end

    frame = insertText(frame, midPt2D, labelStr, ...
        'FontSize', LABEL_FONT_SIZE, ...
        'BoxColor', [0 0 0], 'BoxOpacity', 0.5, ...
        'TextColor', [255 255 255]);
end
end
