function tests = test_3d_projection
tests = functiontests(localfunctions);
end

function test_wall_vertex_count(testCase)
fp = mock_floor_plan();
w3 = build_3d_walls(fp);
verifyEqual(testCase, size(w3(1).verts, 1), 4);
verifyEqual(testCase, size(w3(1).verts, 2), 3);
end

function test_wall_height(testCase)
config;
fp = mock_floor_plan();
w3 = build_3d_walls(fp);
zVals = w3(1).verts(:,3);
verifyEqual(testCase, min(zVals), 0, 'AbsTol', 1e-9);
verifyEqual(testCase, max(zVals), WALL_HEIGHT_M, 'AbsTol', 1e-6);
end

function test_projection_size(testCase)
fp    = mock_floor_plan();
w3    = build_3d_walls(fp);
R     = eye(3);
t     = [0, 0, 3];
cp    = cameraIntrinsics([800 800], [320 240], [480 640]);
proj  = project_to_image(w3, R, t, cp);
verifyEqual(testCase, length(proj), length(w3));
end

function test_normal_unit_length(testCase)
fp = mock_floor_plan();
w3 = build_3d_walls(fp);
for k = 1:length(w3)
    n = w3(k).normal;
    verifyEqual(testCase, norm(n), 1.0, 'AbsTol', 1e-5);
end
end

function fp = mock_floor_plan()
fp.walls      = [0.1 0.2 0.8 0.2; 0.1 0.8 0.8 0.8];
fp.wallsPx    = fp.walls * 640;
fp.imageSize  = [480 640];
fp.nWalls     = 2;
fp.wallLengthsNorm = [0.7; 0.7];
end
