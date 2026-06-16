function arFrame = composite_frame(frame, rendered)
% composite_frame  Final composite of original frame and rendered AR layer
%
% Currently a pass-through since render_walls already blends in-place,
% but kept as a hook for global post-processing (colour grading, vignette).

config;

if ENABLE_LIGHTING
    arFrame = adjust_lighting(frame, rendered);
else
    arFrame = rendered;
end
end
