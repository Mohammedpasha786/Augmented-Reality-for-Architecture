%% Camera
CAMERA_INDEX        = 1;          % webcam device index
FRAME_WIDTH         = 1280;
FRAME_HEIGHT        = 720;
CAMERA_PARAMS_FILE  = fullfile('assets', 'camera_params.mat');

%% AprilTag
APRILTAG_FAMILY     = 'tag36h11';
APRILTAG_SIZE_M     = 0.05;       % physical tag side length in metres
APRILTAG_IDS        = [0, 1, 2, 3]; % expected tag IDs at floor-plan corners

%% Wall Detection (Hough)
HOUGH_THETA_RES     = 1;          % degrees
HOUGH_RHO_RES       = 1;          % pixels
HOUGH_NUM_PEAKS     = 50;
HOUGH_FILL_GAP      = 20;         % px  — gap to bridge in houghlines
HOUGH_MIN_LENGTH    = 40;         % px  — minimum wall segment length
CANNY_THRESH        = [0.05 0.15];

%% 3D Extrusion
WALL_HEIGHT_M       = 2.8;        % metres
FLOOR_PLAN_SCALE    = 0.001;      % px → metres (1 px = 1 mm at 1:1 print)

%% Rendering
WALL_COLOR          = [0.25 0.55 0.85];   % RGB 0-1
WALL_ALPHA          = 0.70;
FLOOR_COLOR         = [0.90 0.88 0.82];
EDGE_COLOR          = [0.10 0.20 0.40];
LABEL_FONT_SIZE     = 14;

%% Advanced
ENABLE_MARKERLESS   = false;
ENABLE_TRANSPARENCY = true;
ENABLE_LABELS       = true;
ENABLE_LIGHTING     = true;
LIGHTING_HIST_BINS  = 64;

%% Output
OUTPUT_DIR = fullfile(pwd, 'outputs');
if ~exist(OUTPUT_DIR, 'dir'), mkdir(OUTPUT_DIR); end
