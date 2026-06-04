# This script assigns OpenGL-style CubeMap matrices to cameras in Blender
# and exports 4096x4096 PNG images for each camera view.
# The script assumes that the cameras are already created and named accordingly.
# The script also assumes that the cameras are already positioned at the origin.

import bpy
import mathutils
import os

# OpenGL-Style CubeMap matrices (Column-Major)
CubeMapMatrices = [
    # pos x
    ((0.0, 0.0, -1.0, 0.0), (0.0, -1.0, 0.0, 0.0), (-1.0, 0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
    # neg x
    ((0.0, 0.0, 1.0, 0.0), (0.0, -1.0, 0.0, 0.0), (1.0, 0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
    # pos y
    ((1.0, 0.0, 0.0, 0.0), (0.0, 0.0, -1.0, 0.0), (0.0, 1.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
    # neg y
    ((1.0, 0.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0), (0.0, -1.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
    # pos z
    ((1.0, 0.0, 0.0, 0.0), (0.0, -1.0, 0.0, 0.0), (0.0, 0.0, -1.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
    # neg z
    ((-1.0, 0.0, 0.0, 0.0), (0.0, -1.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0)),
]

# Camera names in Blender (name your cameras accordingly)
camera_names = ["camera_pos_x", "camera_neg_x", "camera_pos_y", "camera_neg_y", "camera_pos_z", "camera_neg_z"]

# Ensure that there are exactly 6 cameras
if len(camera_names) != len(CubeMapMatrices):
    raise ValueError("The number of cameras does not match the CubeMap matrices.")

# Output directory for PNG exports
output_dir = "C:/path/to/your/output/directory"
os.makedirs(output_dir, exist_ok=True)

# Set render resolution
bpy.context.scene.render.resolution_x = 4096
bpy.context.scene.render.resolution_y = 4096
bpy.context.scene.render.image_settings.file_format = 'PNG'

# Set FOV to 90 degrees
for camera_name in camera_names:
    camera = bpy.data.objects.get(camera_name)
    if not camera or not camera.data.type == 'CAMERA':
        continue
    camera.data.type = 'PERSP'
    camera.data.angle = mathutils.radians(90)

# Matrix assignment and rendering
for i, matrix in enumerate(CubeMapMatrices):
    # Get the camera
    camera = bpy.data.objects.get(camera_names[i])
    if not camera:
        raise ValueError(f"Kamera '{camera_names[i]}' nicht gefunden!")

    # Transpose the OpenGL matrix (Column-Major -> Row-Major for Blender)
    blender_matrix = mathutils.Matrix(matrix).transposed()

    # Apply matrix to the camera
    camera.matrix_world = blender_matrix
    print(f"Matrix for camera {camera_names[i]} applied.")

    # Set the active camera
    bpy.context.scene.camera = camera

    # Set output file path
    output_file = os.path.join(output_dir, f"{camera_names[i]}.png")
    bpy.context.scene.render.filepath = output_file

    # Render the scene
    bpy.ops.render.render(write_still=True)
    print(f"Rendered and saved: {output_file}")

print("All cameras processed and images saved.")
