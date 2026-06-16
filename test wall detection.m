function tests = test_wall_detection
tests = functiontests(localfunctions);
end

function test_detects_horizontal_line(testCase)
frame = make_frame_with_lines('horizontal');
segs  = detect_walls(frame);
verifyNotEmpty(testCase, segs, 'No horizontal wall detected');
end

function test_detects_vertical_line(testCase)
frame = make_frame_with_lines('vertical');
segs  = detect_walls(frame);
verifyNotEmpty(testCase, segs, 'No vertical wall detected');
end

function test_output_columns(testCase)
frame = make_frame_with_lines('box');
segs  = detect_walls(frame);
verifyEqual(testCase, size(segs, 2), 4, 'Segments must be Mx4');
end

function test_parse_normalisation(testCase)
frame = make_frame_with_lines('horizontal');
segs  = detect_walls(frame);
if isempty(segs), return; end
fp = parse_floor_plan(segs, size(frame));
verifyGreaterThanOrEqual(testCase, min(fp.walls(:)), 0);
verifyLessThanOrEqual(testCase,    max(fp.walls(:)), 1);
end

function test_wall_count_reasonable(testCase)
frame = make_frame_with_lines('box');
segs  = detect_walls(frame);
verifyLessThanOrEqual(testCase, size(segs,1), 50, 'Too many spurious walls');
end

%% Helpers
function frame = make_frame_with_lines(type)
frame = 255 * ones(480, 640, 3, 'uint8');
switch type
    case 'horizontal'
        frame(240, 100:540, :) = 0;
    case 'vertical'
        frame(100:380, 320, :) = 0;
    case 'box'
        frame(100, 100:540, :) = 0;
        frame(380, 100:540, :) = 0;
        frame(100:380, 100, :) = 0;
        frame(100:380, 540, :) = 0;
end
end
