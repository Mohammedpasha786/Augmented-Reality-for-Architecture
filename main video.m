function main_video(videoPath)
clc; config;

if nargin < 1
    [f, p] = uigetfile({'*.mp4;*.avi;*.mov', 'Video files'}, 'Select floor-plan video');
    if isequal(f, 0), return; end
    videoPath = fullfile(p, f);
end

%% Load camera calibration
cameraParams = load_camera_params(CAMERA_PARAMS_FILE);

%% Open I/O
v       = VideoReader(videoPath);
outPath = fullfile(OUTPUT_DIR, 'ar_output.mp4');
writer  = VideoWriter(outPath, 'MPEG-4');
writer.FrameRate = v.FrameRate;
open(writer);

fig = figure('Name', 'AR Floor Plan', 'NumberTitle', 'off');
frameCount = 0;

fprintf('Processing video: %s\n', videoPath);

while hasFrame(v)
    frame = readFrame(v);
    frameCount = frameCount + 1;

    arFrame = process_frame(frame, cameraParams);

    imshow(arFrame, 'Parent', gca);
    title(sprintf('Frame %d', frameCount));
    drawnow limitrate;

    writeVideo(writer, arFrame);
end

close(writer);
fprintf('Done. AR video saved to: %s\n', outPath);
end

%% --------------------------------------------------------
function arFrame = process_frame(frame, cameraParams)
config;
arFrame = frame;

%% 1. Undistort
frame = undistortImage(frame, cameraParams);

%% 2. Detect AprilTag and estimate pose
[tagCorners, tagID, tagFound] = detect_apriltag(frame);

if ~tagFound
    if ENABLE_MARKERLESS
        [R, t, poseFound] = estimate_pose_features(frame, cameraParams);
    else
        return;
    end
else
    [R, t, poseFound] = estimate_pose_apriltag(tagCorners, tagID, cameraParams);
end

if ~poseFound, return; end

%% 3. Detect walls
wallSegments = detect_walls(frame);
if isempty(wallSegments), return; end

floorPlan = parse_floor_plan(wallSegments, size(frame));

%% 4. Build 3D wall geometry
walls3D = build_3d_walls(floorPlan);

%% 5. Project into image
projWalls = project_to_image(walls3D, R, t, cameraParams);

%% 6. Render + composite
rendered  = render_walls(frame, projWalls, walls3D);

if ENABLE_LABELS
    rendered = render_labels(rendered, projWalls, walls3D, R, t, cameraParams);
end

arFrame = composite_frame(frame, rendered);
end
