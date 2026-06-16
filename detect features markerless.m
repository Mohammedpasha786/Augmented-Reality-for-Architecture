function [R, t, poseFound] = estimate_pose_features(frame, cameraParams)
% estimate_pose_features  Markerless pose estimation using SURF features
%                          matched against a reference floor-plan image
%
% Requires: Computer Vision Toolbox (detectSURFFeatures, matchFeatures)
% This implements Advanced Work 1.
%
% INPUTS:
%   frame        — H×W×3 uint8 current video frame
%   cameraParams — cameraParameters object
%
% OUTPUTS:
%   R, t, poseFound

persistent refPoints refFeatures refImg refPoints3D

R = eye(3); t = zeros(1,3); poseFound = false;

%% Load reference floor plan on first call
if isempty(refImg)
    refPath = fullfile('assets', 'sample_floor_plan.png');
    if ~isfile(refPath)
        warning('Reference floor plan not found at %s', refPath);
        return;
    end
    refImg     = imread(refPath);
    refGray    = im2gray(refImg);
    refPoints  = detectSURFFeatures(refGray, 'MetricThreshold', 500);
    [~, refFeatures] = extractFeatures(refGray, refPoints);

    % Assign 3D coords: floor plan is on Z=0 plane; scale px→metres
    config;
    pts = refPoints.Location;
    refPoints3D = [pts * FLOOR_PLAN_SCALE, zeros(size(pts,1), 1)];
end

%% Detect features in current frame
gray = im2gray(frame);
pts  = detectSURFFeatures(gray, 'MetricThreshold', 500);
if pts.Count < 10, return; end

[~, feats] = extractFeatures(gray, pts);
indexPairs = matchFeatures(refFeatures, feats, 'MaxRatio', 0.75, 'Unique', true);

if size(indexPairs, 1) < 8, return; end

matched3D = refPoints3D(indexPairs(:,1), :);
matched2D = pts.Location(indexPairs(:,2), :);

try
    [R, t, ~] = estimateWorldCameraPose(matched2D, matched3D, cameraParams, ...
        'MaxReprojectionError', 4, 'Confidence', 99);
    poseFound = true;
catch
    poseFound = false;
end
end
