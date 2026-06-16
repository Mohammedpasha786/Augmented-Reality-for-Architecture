function main_realtime()
clc; config;

cameraParams = load_camera_params(CAMERA_PARAMS_FILE);

%% Open webcam
cam = webcam(CAMERA_INDEX);
cam.Resolution = sprintf('%dx%d', FRAME_WIDTH, FRAME_HEIGHT);

fig = figure('Name', 'AR Floor Plan — Live', 'NumberTitle', 'off', ...
    'KeyPressFcn', @(~,~) close(gcf));
fprintf('AR running. Press any key in figure to quit.\n');

frameCount = 0; t0 = tic;

while ishandle(fig)
    frame = snapshot(cam);
    frameCount = frameCount + 1;

    arFrame = process_frame_rt(frame, cameraParams);

    % FPS overlay
    fps = frameCount / toc(t0);
    arFrame = insertText(arFrame, [10 10], sprintf('FPS: %.1f', fps), ...
        'FontSize', 16, 'BoxColor', 'black', 'TextColor', 'white');

    imshow(arFrame, 'Parent', gca);
    drawnow limitrate;
end

clear cam;
fprintf('Webcam released.\n');
end

%% --------------------------------------------------------
function arFrame = process_frame_rt(frame, cameraParams)
config;
arFrame = frame;

frame = undistortImage(frame, cameraParams);

[tagCorners, tagID, tagFound] = detect_apriltag(frame);
if ~tagFound, return; end

[R, t, poseFound] = estimate_pose_apriltag(tagCorners, tagID, cameraParams);
if ~poseFound, return; end

wallSegments = detect_walls(frame);
if isempty(wallSegments), return; end

floorPlan = parse_floor_plan(wallSegments, size(frame));
walls3D   = build_3d_walls(floorPlan);
projWalls = project_to_image(walls3D, R, t, cameraParams);
rendered  = render_walls(frame, projWalls, walls3D);
arFrame   = composite_frame(frame, rendered);
end
