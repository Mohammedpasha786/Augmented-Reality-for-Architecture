function tests = test_pose_estimation
tests = functiontests(localfunctions);
end

function test_load_default_params(testCase)
cp = load_camera_params('nonexistent_file.mat');
verifyNotEmpty(testCase, cp);
verifyClass(testCase, cp, 'cameraIntrinsics');
end

function test_apriltag_returns_struct_on_failure(testCase)
frame = 128 * ones(480, 640, 3, 'uint8');
[corners, ids, found] = detect_apriltag(frame);
verifyFalse(testCase, found);
verifyEmpty(testCase, ids);
end

function test_pose_identity_no_tag(testCase)
frame = 128 * ones(480, 640, 3, 'uint8');
cp = load_camera_params('nonexistent_file.mat');
[R, t, poseFound] = estimate_pose_apriltag([], [], cp);
verifyFalse(testCase, poseFound);
verifyEqual(testCase, R, eye(3), 'AbsTol', 1e-10);
end
