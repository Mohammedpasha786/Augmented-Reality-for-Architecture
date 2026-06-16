# Augmented Reality for Architecture

> Enhance a photo or video of a 2D architectural floor plan with a real-time virtual 3D representation using MATLAB Computer Vision Toolbox.

## Overview

This project builds an AR pipeline that overlays a 3D architectural model onto a live or recorded video stream of a printed 2D floor plan. Using AprilTag markers for robust pose estimation, the system detects walls (via Hough line transform), extrudes them into 3D geometry, and composites the rendered mesh onto each video frame — corrected for camera perspective in real time.

---

## Project Structure

```
ar-architecture/
├── src/
│   ├── calibration/
│   │   ├── run_calibration.m          # Camera calibration workflow
│   │   └── load_camera_params.m       # Load saved calibration file
│   ├── detection/
│   │   ├── detect_apriltag.m          # AprilTag detection and ID parsing
│   │   ├── detect_walls.m             # Hough-based wall/line detection
│   │   └── parse_floor_plan.m         # Convert detected lines to wall segments
│   ├── pose/
│   │   ├── estimate_pose_apriltag.m   # Pose from AprilTag homography
│   │   ├── estimate_pose_features.m   # Pose from ORB/SURF feature matching (Advanced)
│   │   └── refine_pose.m              # Iterative pose refinement
│   ├── augmentation/
│   │   ├── build_3d_walls.m           # Extrude 2D wall segments to 3D
│   │   ├── project_to_image.m         # 3D → 2D projection with camera model
│   │   └── composite_frame.m          # Overlay 3D render onto video frame
│   ├── rendering/
│   │   ├── render_walls.m             # Draw extruded walls with depth sorting
│   │   ├── render_labels.m            # Wall length labels (Advanced)
│   │   └── adjust_lighting.m          # Environment-aware color correction (Advanced)
│   └── advanced/
│       ├── detect_features_markerless.m  # Markerless pose from SURF/ORB
│       ├── detect_doors_windows.m        # Door/window symbol detection
│       ├── transparency_render.m         # Occlusion with alpha blending
│       └── measure_walls.m              # Auto wall length measurement
├── tests/
│   ├── test_wall_detection.m
│   ├── test_pose_estimation.m
│   ├── test_3d_projection.m
│   └── test_composite.m
├── docs/
│   └── project_description.docx
├── assets/
│   ├── sample_floor_plan.png          # Reference floor plan image
│   └── camera_params.mat              # Example calibration file
├── .github/
│   └── workflows/
│       └── ci.yml
├── config.m                           # Global parameters
├── main_video.m                       # Offline video processing pipeline
├── main_realtime.m                    # Live webcam AR pipeline
├── requirements.txt
└── README.md
```

---

## Requirements

### MATLAB Toolboxes
- MATLAB R2024a or later
- Computer Vision Toolbox
- Image Processing Toolbox
- (Optional) GPU Coder / MATLAB Mobile for device deployment

### Hardware
- Webcam or smartphone camera
- Printed floor plan (A4/Letter) with AprilTag markers at corners

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ar-architecture.git
   cd ar-architecture
   ```

2. Calibrate your camera (one-time setup):
   ```matlab
   run_calibration    % Follow the Camera Calibrator App prompts
   ```

3. Run on a video file:
   ```matlab
   main_video('my_floorplan_video.mp4')
   ```

4. Run in real time from webcam:
   ```matlab
   main_realtime
   ```

---

## Pipeline Overview

```
Video Frame
    │
    ▼
detect_apriltag.m  ──────────────────► estimate_pose_apriltag.m
    │                                           │
    ▼                                           ▼
detect_walls.m                           refine_pose.m
    │                                           │
    ▼                                           │
parse_floor_plan.m                             │
    │                                           │
    └──────────────► build_3d_walls.m ◄─────────┘
                            │
                            ▼
                    project_to_image.m
                            │
                            ▼
                    render_walls.m
                            │
                            ▼
                    composite_frame.m
                            │
                            ▼
                    Output AR Frame
```

---

## Quick Example

```matlab
% Load camera calibration
cameraParams = load_camera_params('assets/camera_params.mat');

% Open video
v = VideoReader('floor_plan_video.mp4');
writer = VideoWriter('ar_output.mp4', 'MPEG-4');
open(writer);

while hasFrame(v)
    frame = readFrame(v);

    % Detect AprilTag → estimate pose
    [tagCorners, tagID] = detect_apriltag(frame);
    [R, t] = estimate_pose_apriltag(tagCorners, tagID, cameraParams);

    % Detect walls
    wallSegments = detect_walls(frame);
    walls3D      = build_3d_walls(wallSegments);

    % Project and composite
    projWalls  = project_to_image(walls3D, R, t, cameraParams);
    arFrame    = composite_frame(frame, projWalls);

    writeVideo(writer, arFrame);
end
close(writer);
```

---

## Advanced Features

| Feature | Module | Status |
|---|---|---|
| Markerless pose (SURF/ORB) | `detect_features_markerless.m` | Optional |
| Door/window detection | `detect_doors_windows.m` | Optional |
| Transparency / occlusion | `transparency_render.m` | Optional |
| Auto wall measurement | `measure_walls.m` | Optional |
| Environment lighting correction | `adjust_lighting.m` | Optional |

---

## References

1. M. Schumann et al., "Evaluation of augmented reality supported approaches for product design and production processes," *Procedia CIRP*, 2021.
2. T. Georgiou et al., "A survey of traditional and deep learning-based feature descriptors for high dimensional data in computer vision," *Int J Multimed Info Retr*, 2020.
3. MathWorks, *Computer Vision Toolbox Documentation*, R2024a.
4. MathWorks, *Augmented Reality using AprilTag markers*, Example, R2024a.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
