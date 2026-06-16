% run_calibration.m — Camera calibration using the Camera Calibrator App
% AR for Architecture | SR University | Mohammed Afreed Pasha
%
% USAGE:
%   run_calibration()           — launches Camera Calibrator App interactively
%   run_calibration(imageDir)   — batch calibrate from checkerboard images in imageDir
%
% OUTPUT:
%   Saves cameraParams to assets/camera_params.mat

function run_calibration(imageDir)
config;

if nargin < 1 || isempty(imageDir)
    fprintf('Opening Camera Calibrator App...\n');
    fprintf('Steps:\n');
    fprintf('  1. Add checkerboard images (20-30 images, varied angles)\n');
    fprintf('  2. Set square size in mm\n');
    fprintf('  3. Click Calibrate\n');
    fprintf('  4. Export as "cameraParams" to workspace\n');
    fprintf('  5. This script will auto-save after you export.\n\n');

    cameraCalibrator;

    % Wait for user to export
    input('Press Enter after exporting cameraParams to workspace... ');

    if evalin('base', 'exist(''cameraParams'',''var'')')
        cameraParams = evalin('base', 'cameraParams');
        if ~exist('assets', 'dir'), mkdir('assets'); end
        save(CAMERA_PARAMS_FILE, 'cameraParams');
        fprintf('Saved to %s\n', CAMERA_PARAMS_FILE);
        fprintf('Reprojection error: %.4f px\n', cameraParams.MeanReprojectionError);
    else
        warning('cameraParams not found in workspace. Run calibration first.');
    end
else
    %% Batch calibration from image folder
    images = imageDatastore(imageDir, 'FileExtensions', {'.png','.jpg','.jpeg'});
    squareSizeMM = input('Enter checkerboard square size (mm): ');
    [imagePoints, boardSize] = detectCheckerboardPoints(images.Files);
    worldPoints = generateCheckerboardPoints(boardSize, squareSizeMM);
    I0 = readimage(images, 1);
    imageSize = [size(I0,1), size(I0,2)];
    cameraParams = estimateCameraParameters(imagePoints, worldPoints, ...
        'ImageSize', imageSize, 'EstimateSkewness', false, ...
        'EstimateTangentialDistortion', false, 'NumRadialDistortionCoefficients', 2);

    fprintf('Mean reprojection error: %.4f px\n', cameraParams.MeanReprojectionError);
    if ~exist('assets', 'dir'), mkdir('assets'); end
    save(CAMERA_PARAMS_FILE, 'cameraParams');
    fprintf('Saved to %s\n', CAMERA_PARAMS_FILE);
end
end
