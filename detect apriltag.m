function [tagCorners, tagIDs, tagFound] = detect_apriltag(frame)
% detect_apriltag  Detect AprilTag markers in a video frame
%
% INPUTS:
%   frame       — H×W×3 uint8 RGB image
%
% OUTPUTS:
%   tagCorners  — Nx4x2 array of corner points per tag [tag, corner, xy]
%   tagIDs      — Nx1 integer tag IDs
%   tagFound    — logical, true if at least one tag detected

config;

gray = im2gray(frame);

% readAprilTag requires Computer Vision Toolbox R2020b+
try
    [tagIDs, tagCorners, ~] = readAprilTag(gray, APRILTAG_FAMILY, ...
        'DecimationFactor', 2);
    tagFound = ~isempty(tagIDs);
catch ME
    warning('readAprilTag failed: %s\nFalling back to no detection.', ME.message);
    tagCorners = [];
    tagIDs     = [];
    tagFound   = false;
end

if tagFound
    % Filter to expected IDs only
    validMask  = ismember(tagIDs, APRILTAG_IDS);
    tagIDs     = tagIDs(validMask);
    tagCorners = tagCorners(validMask, :, :);
    tagFound   = ~isempty(tagIDs);
end
end
