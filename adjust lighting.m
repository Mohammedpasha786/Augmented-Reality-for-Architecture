function arFrame = adjust_lighting(originalFrame, renderedFrame)
% adjust_lighting  Match AR rendering brightness/colour to scene lighting
%
% Implements Advanced Feature: Automatic colour correction to match environment.
% Strategy: measure the luminance histogram of the original frame's background
% and apply a linear gain to the rendered AR overlay to match.

config;

origGray = im2gray(originalFrame);
rndGray  = im2gray(renderedFrame);

% Sample brightness from corners of the frame (assumed to be background)
H = size(originalFrame, 1); W = size(originalFrame, 2);
margin = round(min(H,W) * 0.05);
bgPatch = [origGray(1:margin, 1:margin); ...
           origGray(1:margin, end-margin+1:end); ...
           origGray(end-margin+1:end, 1:margin); ...
           origGray(end-margin+1:end, end-margin+1:end)];

bgMean = double(mean(bgPatch(:))) / 255;
rndMean = double(mean(rndGray(:))) / 255 + eps;

gain = bgMean / rndMean;
gain = max(0.5, min(2.0, gain));  % clamp gain to safe range

% Apply gain only where the rendered frame differs from original
diffMask = any(renderedFrame ~= originalFrame, 3);

arFrame = renderedFrame;
for ch = 1:3
    layer = double(arFrame(:,:,ch));
    layer(diffMask) = min(255, layer(diffMask) * gain);
    arFrame(:,:,ch) = uint8(layer);
end
end
