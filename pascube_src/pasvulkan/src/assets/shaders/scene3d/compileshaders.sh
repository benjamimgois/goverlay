#!/bin/bash

################################################################################################################### 
#### This script compiles all necessary shaders for the Scene3D sub-framework-part of the PasVulkan framework. ####
###################################################################################################################

#############################################
#            Configuration code            #
#############################################

# No ZIP, since SPK has been introduced and has better compression due to no sliding window dictionary but instead full window dictionary,
# where repeated data is stored only once and referenced by pointers in a better way than inflate/deflate's sliding window dictionary
USEZIP=0 

# No bin2c, since raw resources are now used (Windows resource files, even for Linux and other *nix platforms with the help of
# FPC'S RTL-side Windows resource file support and API emulation)   
USEBIN2C=0 

# Delete the temporary files after compilation
DELETEAFTERCOMPILE=1

# Debug mode, if set to 1, debug information will generated and written into the spirv files 
DEBUG=1

#############################################
#            Initialization code            #
#############################################

# Get the number of logical CPU cores
countCPUCores=$( ls -d /sys/devices/system/cpu/cpu[[:digit:]]* | wc -w )

# Check if bash version is equal or greater then 4.1 for `wait -n` support
if [ "${BASH_VERSINFO[0]}" -gt 4 ]; then
  bashVersionEqualOrGreaterThan4_1=1
elif [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 1 ]; then
  bashVersionEqualOrGreaterThan4_1=1
else
  bashVersionEqualOrGreaterThan4_1=0  
fi

# Get our current directory
originalDirectory="$(pwd)"
if [ $? -ne 0 ]; then
  echo "Failed to get current directory"
  exit 1
fi

# Get and create a temporary directory
tempPath="$(mktemp -d)"
#tempPath="$(mktemp -d -u -p ${HOME}/.temp/)"
if [ $? -ne 0 ]; then
  echo "Failed to create temporary directory"
  exit 1
fi

#mkdir -p "${tempPath}"
#if [ $? -ne 0 ]; then
#  echo "Failed to create temporary directory"
#  exit 1
#fi

#############################################
#          Predefined shader list           #
#############################################

compileshaderarguments=(
  
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=0 -o ${tempPath}/downsample_r11g11b10f_level0_comp.spv"
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=1 -o ${tempPath}/downsample_r11g11b10f_level1_comp.spv"
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=2 -o ${tempPath}/downsample_r11g11b10f_level2_comp.spv"
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=0 -DMULTIVIEW -o ${tempPath}/downsample_r11g11b10f_multiview_level0_comp.spv"
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=1 -DMULTIVIEW -o ${tempPath}/downsample_r11g11b10f_multiview_level1_comp.spv"
  "-V downsample.comp -DR11G11B10F -DMIPMAPLEVEL=2 -DMULTIVIEW -o ${tempPath}/downsample_r11g11b10f_multiview_level2_comp.spv"

  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=0 -o ${tempPath}/downsample_rgba16f_level0_comp.spv"
  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=1 -o ${tempPath}/downsample_rgba16f_level1_comp.spv"
  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=2 -o ${tempPath}/downsample_rgba16f_level2_comp.spv"
  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=0 -DMULTIVIEW -o ${tempPath}/downsample_rgba16f_multiview_level0_comp.spv"
  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=1 -DMULTIVIEW -o ${tempPath}/downsample_rgba16f_multiview_level1_comp.spv"
  "-V downsample.comp -DRGBA16F -DMIPMAPLEVEL=2 -DMULTIVIEW -o ${tempPath}/downsample_rgba16f_multiview_level2_comp.spv"

  "-V cull_depth_resolve.comp -o ${tempPath}/cull_depth_resolve_comp.spv"
  "-V cull_depth_resolve.comp -DREVERSEDZ -o ${tempPath}/cull_depth_resolve_reversedz_comp.spv"
  "-V cull_depth_resolve.comp -DMSAA -o ${tempPath}/cull_depth_resolve_depth_msaa_comp.spv"
  "-V cull_depth_resolve.comp -DMSAA -DREVERSEDZ -o ${tempPath}/cull_depth_resolve_msaa_reversedz_comp.spv"
  "-V cull_depth_resolve.comp -DMULTIVIEW -o ${tempPath}/cull_depth_resolve_multiview_comp.spv"
  "-V cull_depth_resolve.comp -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/cull_depth_resolve_multiview_reversedz_comp.spv"
  "-V cull_depth_resolve.comp -DMULTIVIEW -DMSAA -o ${tempPath}/cull_depth_resolve_multiview_msaa_comp.spv"
  "-V cull_depth_resolve.comp -DMULTIVIEW -DMSAA -DREVERSEDZ -o ${tempPath}/cull_depth_resolve_multiview_msaa_reversedz_comp.spv"

  "-V downsample_culldepthpyramid.comp -DFIRSTPASS -o ${tempPath}/downsample_culldepthpyramid_firstpass_comp.spv"
  "-V downsample_culldepthpyramid.comp -DFIRSTPASS -DMULTIVIEW -o ${tempPath}/downsample_culldepthpyramid_multiview_firstpass_comp.spv"
  "-V downsample_culldepthpyramid.comp -DFIRSTPASS -DREVERSEDZ -o ${tempPath}/downsample_culldepthpyramid_reversedz_firstpass_comp.spv"
  "-V downsample_culldepthpyramid.comp -DFIRSTPASS -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_culldepthpyramid_multiview_reversedz_firstpass_comp.spv"
  "-V downsample_culldepthpyramid.comp -DREDUCTION -o ${tempPath}/downsample_culldepthpyramid_reduction_comp.spv"
  "-V downsample_culldepthpyramid.comp -DREDUCTION -DMULTIVIEW -o ${tempPath}/downsample_culldepthpyramid_multiview_reduction_comp.spv"
  "-V downsample_culldepthpyramid.comp -DREDUCTION -DREVERSEDZ -o ${tempPath}/downsample_culldepthpyramid_reversedz_reduction_comp.spv"
  "-V downsample_culldepthpyramid.comp -DREDUCTION -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_culldepthpyramid_multiview_reversedz_reduction_comp.spv"
  
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -o ${tempPath}/downsample_depth_old_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DREVERSEDZ -o ${tempPath}/downsample_depth_old_reversedz_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMSAA -o ${tempPath}/downsample_depth_old_msaa_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMSAA -DREVERSEDZ -o ${tempPath}/downsample_depth_old_msaa_reversedz_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMULTIVIEW -o ${tempPath}/downsample_depth_old_multiview_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_depth_old_multiview_reversedz_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMULTIVIEW -DMSAA -o ${tempPath}/downsample_depth_old_multiview_msaa_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=0 -DMULTIVIEW -DMSAA -DREVERSEDZ -o ${tempPath}/downsample_depth_old_multiview_msaa_reversedz_level0_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=1 -o ${tempPath}/downsample_depth_old_level1_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=1 -DMULTIVIEW -o ${tempPath}/downsample_depth_old_multiview_level1_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=1 -DREVERSEDZ -o ${tempPath}/downsample_depth_old_reversedz_level1_comp.spv"
  #"-V downsample_depth_old.comp -DMIPMAPLEVEL=1 -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_depth_old_multiview_reversedz_level1_comp.spv"
  
  "-V downsample_depth.comp -DFIRSTPASS -o ${tempPath}/downsample_depth_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DREVERSEDZ -o ${tempPath}/downsample_depth_reversedz_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMSAA -o ${tempPath}/downsample_depth_msaa_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMSAA -DREVERSEDZ -o ${tempPath}/downsample_depth_msaa_reversedz_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMULTIVIEW -o ${tempPath}/downsample_depth_multiview_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_depth_multiview_reversedz_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMULTIVIEW -DMSAA -o ${tempPath}/downsample_depth_multiview_msaa_firstpass_comp.spv"
  "-V downsample_depth.comp -DFIRSTPASS -DMULTIVIEW -DMSAA -DREVERSEDZ -o ${tempPath}/downsample_depth_multiview_msaa_reversedz_firstpass_comp.spv"
  "-V downsample_depth.comp -DREDUCTION -o ${tempPath}/downsample_depth_reduction_comp.spv"
  "-V downsample_depth.comp -DREDUCTION -DMULTIVIEW -o ${tempPath}/downsample_depth_multiview_reduction_comp.spv"
  "-V downsample_depth.comp -DREDUCTION -DREVERSEDZ -o ${tempPath}/downsample_depth_reversedz_reduction_comp.spv"
  "-V downsample_depth.comp -DREDUCTION -DMULTIVIEW -DREVERSEDZ -o ${tempPath}/downsample_depth_multiview_reversedz_reduction_comp.spv"
  
  "-V downsample_ambientocclusion_gtao_depth.comp -DFIRSTPASS -o ${tempPath}/downsample_ambientocclusion_gtao_depth_firstpass_comp.spv"
  "-V downsample_ambientocclusion_gtao_depth.comp -DFIRSTPASS -DMSAA -o ${tempPath}/downsample_ambientocclusion_gtao_depth_msaa_firstpass_comp.spv"
  "-V downsample_ambientocclusion_gtao_depth.comp -DFIRSTPASS -DMULTIVIEW -o ${tempPath}/downsample_ambientocclusion_gtao_depth_multiview_firstpass_comp.spv"
  "-V downsample_ambientocclusion_gtao_depth.comp -DFIRSTPASS -DMULTIVIEW -DMSAA -o ${tempPath}/downsample_ambientocclusion_gtao_depth_multiview_msaa_firstpass_comp.spv"
  "-V downsample_ambientocclusion_gtao_depth.comp -DREDUCTION -o ${tempPath}/downsample_ambientocclusion_gtao_depth_reduction_comp.spv"
  "-V downsample_ambientocclusion_gtao_depth.comp -DREDUCTION -DMULTIVIEW -o ${tempPath}/downsample_ambientocclusion_gtao_depth_multiview_reduction_comp.spv"

  "-V downsample_heightmap.comp -o ${tempPath}/downsample_heightmap_comp.spv"

  "-V downsample_normalmap.comp -o ${tempPath}/downsample_normalmap_comp.spv"

  "-V downsample_cubemap.comp -o ${tempPath}/downsample_cubemap_rgba8_comp.spv"
  "-V downsample_cubemap.comp -DUSE_RGB9E5 -o ${tempPath}/downsample_cubemap_rgb9e5_comp.spv"
  "-V downsample_cubemap.comp -DUSE_R11G11B10F -o ${tempPath}/downsample_cubemap_r11g11b10f_comp.spv" 
  "-V downsample_cubemap.comp -DUSE_RGBA16F -o ${tempPath}/downsample_cubemap_rgba16f_comp.spv"
  "-V downsample_cubemap.comp -DUSE_RGBA32F -o ${tempPath}/downsample_cubemap_rgba32f_comp.spv"  

  "-V downsample_3d.comp -o ${tempPath}/downsample_3d_rgba8_comp.spv"
  "-V downsample_3d.comp -DUSE_RGB9E5 -o ${tempPath}/downsample_3d_rgb9e5_comp.spv"
  "-V downsample_3d.comp -DUSE_R11G11B10F -o ${tempPath}/downsample_3d_r11g11b10f_comp.spv" 
  "-V downsample_3d.comp -DUSE_RGBA16F -o ${tempPath}/downsample_3d_rgba16f_comp.spv"
  "-V downsample_3d.comp -DUSE_RGBA32F -o ${tempPath}/downsample_3d_rgba32f_comp.spv"  
    
  "-V dof_autofocus.comp -o ${tempPath}/dof_autofocus_comp.spv"
  "-V dof_bokeh.comp -o ${tempPath}/dof_bokeh_comp.spv"
  "-V dof_prepare.frag -o ${tempPath}/dof_prepare_frag.spv"
  "-V dof_prefilter.frag -o ${tempPath}/dof_prefilter_frag.spv"
  "-V dof_blur.frag -o ${tempPath}/dof_blur_frag.spv"
  "-V dof_bruteforce.frag -o ${tempPath}/dof_bruteforce_frag.spv"
  "-V dof_postblur.frag -o ${tempPath}/dof_postblur_frag.spv"
  "-V dof_combine.frag -o ${tempPath}/dof_combine_frag.spv"
  "-V dof_gather.frag -DPASS1 -o ${tempPath}/dof_gather_pass1_frag.spv"
  "-V dof_gather.frag -DPASS2 -o ${tempPath}/dof_gather_pass2_frag.spv"
  "-V dof_resolve.frag -o ${tempPath}/dof_resolve_frag.spv"

  "-V luminance_histogram.comp -o ${tempPath}/luminance_histogram_comp.spv"
  "-V luminance_histogram.comp -DMULTIVIEW -o ${tempPath}/luminance_histogram_multiview_comp.spv"

  "-V luminance_average.comp -o ${tempPath}/luminance_average_comp.spv"

  "-V luminance_adaptation.frag -o ${tempPath}/luminance_adaptation_frag.spv" 

  "-V frustumclustergridbuild.comp -o ${tempPath}/frustumclustergridbuild_comp.spv"
  "-V frustumclustergridbuild.comp -DREVERSEDZ -o ${tempPath}/frustumclustergridbuild_reversedz_comp.spv"

  "-V frustumclustergridassign.comp -o ${tempPath}/frustumclustergridassign_comp.spv"
  
  "-V lens_upsample.comp -DR11G11B10F -o ${tempPath}/lens_upsample_r11g11b10f_comp.spv"
  "-V lens_upsample.comp -DRGBA16F -o ${tempPath}/lens_upsample_rgba16f_comp.spv"
  "-V lens_upsample.comp -DR11G11B10F -DMULTIVIEW -o ${tempPath}/lens_upsample_r11g11b10f_multiview_comp.spv"
  "-V lens_upsample.comp -DRGBA16F -DMULTIVIEW -o ${tempPath}/lens_upsample_rgba16f_multiview_comp.spv"
  "-V lens_resolve.frag -o ${tempPath}/lens_resolve_frag.spv"

  "-V lens_color.frag -o ${tempPath}/lens_color_frag.spv"
  "-V lens_dirt.frag -o ${tempPath}/lens_dirt_frag.spv"
  "-V lens_star.frag -o ${tempPath}/lens_star_frag.spv"

  "-V lens_rain.frag -o ${tempPath}/lens_rain_frag.spv"

  "-V mesh.comp -o ${tempPath}/mesh_comp.spv"
  "-V mesh.comp -DRAYTRACING -o ${tempPath}/mesh_raytracing_comp.spv"

  "-V mesh_cull.comp -DPASS=0 -o ${tempPath}/mesh_cull_pass0_comp.spv"
  "-V mesh_cull.comp -DPASS=1 -o ${tempPath}/mesh_cull_pass1_comp.spv"

  "-V mesh.vert -o ${tempPath}/mesh_vert.spv"
  "-V mesh.vert -DVELOCITY -o ${tempPath}/mesh_velocity_vert.spv"
  "-V mesh.vert -DVOXELIZATION -o ${tempPath}/mesh_voxelization_vert.spv"

  "-V gi_voxel_occlusion_transfer.comp -o ${tempPath}/gi_voxel_occlusion_transfer_comp.spv"
  "-V gi_voxel_occlusion_mipmap.comp -o ${tempPath}/gi_voxel_occlusion_mipmap_comp.spv"

  "-V gi_voxel_radiance_transfer.comp -o ${tempPath}/gi_voxel_radiance_transfer_comp.spv"
  "-V gi_voxel_radiance_transfer.comp -DUSESHADERBUFFERFLOAT32ATOMICADD -o ${tempPath}/gi_voxel_radiance_transfer_float_comp.spv"

  "-V gi_voxel_radiance_mipmap.comp -o ${tempPath}/gi_voxel_radiance_mipmap_comp.spv"
  
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=1 -o ${tempPath}/mesh_voxelization_1_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=2 -o ${tempPath}/mesh_voxelization_2_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=3 -o ${tempPath}/mesh_voxelization_3_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=4 -o ${tempPath}/mesh_voxelization_4_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=5 -o ${tempPath}/mesh_voxelization_5_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=6 -o ${tempPath}/mesh_voxelization_6_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=7 -o ${tempPath}/mesh_voxelization_7_geom.spv"
  "-V mesh_voxelization.geom -DCOUNT_CLIPMAPS=8 -o ${tempPath}/mesh_voxelization_8_geom.spv"
   
  "-V mesh_voxelization.comp -o ${tempPath}/mesh_voxelization_comp.spv"

  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=1 -o ${tempPath}/particle_voxelization_1_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=2 -o ${tempPath}/particle_voxelization_2_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=3 -o ${tempPath}/particle_voxelization_3_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=4 -o ${tempPath}/particle_voxelization_4_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=5 -o ${tempPath}/particle_voxelization_5_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=6 -o ${tempPath}/particle_voxelization_6_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=7 -o ${tempPath}/particle_voxelization_7_geom.spv"
  "-V particle_voxelization.geom -DCOUNT_CLIPMAPS=8 -o ${tempPath}/particle_voxelization_8_geom.spv"
  
  "-V mboit_resolve.frag -o ${tempPath}/mboit_resolve_frag.spv"
  "-V mboit_resolve.frag -DMSAA -o ${tempPath}/mboit_resolve_msaa_frag.spv"
  "-V mboit_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/mboit_resolve_msaa_no_msaa_water_frag.spv"
  
  "-V wboit_resolve.frag -o ${tempPath}/wboit_resolve_frag.spv"
  "-V wboit_resolve.frag -DMSAA -o ${tempPath}/wboit_resolve_msaa_frag.spv"
  "-V wboit_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/wboit_resolve_msaa_no_msaa_water_frag.spv"
  
  "-V lockoit_resolve.frag -o ${tempPath}/lockoit_resolve_frag.spv"
  "-V lockoit_resolve.frag -DREVERSEDZ -o ${tempPath}/lockoit_resolve_reversedz_frag.spv"
  "-V lockoit_resolve.frag -DMSAA -o ${tempPath}/lockoit_resolve_msaa_frag.spv"
  "-V lockoit_resolve.frag -DMSAA -DREVERSEDZ -o ${tempPath}/lockoit_resolve_reversedz_msaa_frag.spv"
  "-V lockoit_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/lockoit_resolve_msaa_no_msaa_water_frag.spv"
  "-V lockoit_resolve.frag -DMSAA -DNO_MSAA_WATER -DREVERSEDZ -o ${tempPath}/lockoit_resolve_reversedz_msaa_no_msaa_water_frag.spv"

  "-V loopoit_resolve.frag -o ${tempPath}/loopoit_resolve_frag.spv"
  "-V loopoit_resolve.frag -DREVERSEDZ -o ${tempPath}/loopoit_resolve_reversedz_frag.spv"
  "-V loopoit_resolve.frag -DMSAA -o ${tempPath}/loopoit_resolve_msaa_frag.spv"
  "-V loopoit_resolve.frag -DMSAA -DREVERSEDZ -o ${tempPath}/loopoit_resolve_reversedz_msaa_frag.spv"
  "-V loopoit_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/loopoit_resolve_msaa_no_msaa_water_frag.spv"
  "-V loopoit_resolve.frag -DMSAA -DNO_MSAA_WATER -DREVERSEDZ -o ${tempPath}/loopoit_resolve_reversedz_msaa_no_msaa_water_frag.spv"

  "-V dfaoit_resolve.frag -o ${tempPath}/dfaoit_resolve_frag.spv"
  "-V dfaoit_resolve.frag -DREVERSEDZ -o ${tempPath}/dfaoit_resolve_reversedz_frag.spv"
  "-V dfaoit_resolve.frag -DMSAA -o ${tempPath}/dfaoit_resolve_msaa_frag.spv"
  "-V dfaoit_resolve.frag -DMSAA -DREVERSEDZ -o ${tempPath}/dfaoit_resolve_reversedz_msaa_frag.spv"
  "-V dfaoit_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/dfaoit_resolve_msaa_no_msaa_water_frag.spv"
  "-V dfaoit_resolve.frag -DMSAA -DNO_MSAA_WATER -DREVERSEDZ -o ${tempPath}/dfaoit_resolve_reversedz_msaa_no_msaa_water_frag.spv"

  "-V blend_resolve.frag -o ${tempPath}/blend_resolve_frag.spv"
  "-V blend_resolve.frag -DMSAA -o ${tempPath}/blend_resolve_msaa_frag.spv"  
  "-V blend_resolve.frag -DMSAA -DNO_MSAA_WATER -o ${tempPath}/blend_resolve_msaa_no_msaa_water_frag.spv"

  "-V brdf_charlie.frag -o ${tempPath}/brdf_charlie_frag.spv"
  "-V brdf_ggx.frag -o ${tempPath}/brdf_ggx_frag.spv"
  
  "-V brdf_sheen_e.frag -o ${tempPath}/brdf_sheen_e_frag.spv"
  "-V brdf_sheen_e.frag -DFAST -o ${tempPath}/brdf_sheen_e_fast_frag.spv"
    
  "-V fullscreen.vert -o ${tempPath}/fullscreen_vert.spv"
  
  "-V cubemap.vert -o ${tempPath}/cubemap_vert.spv"
  "-V cubemap_cubemap.comp -o ${tempPath}/cubemap_cubemap_comp.spv"
  "-V cubemap_cubemap.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_cubemap_rgb9e5_comp.spv"
  "-V cubemap_cubemap.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_cubemap_r11g11b10f_comp.spv"
  "-V cubemap_cubemap.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_cubemap_rgba16f_comp.spv"
  "-V cubemap_cubemap.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_cubemap_rgba32f_comp.spv"
  "-V cubemap_cubemap.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_cubemap_rgba8_comp.spv"
  "-V cubemap_equirectangularmap.comp -o ${tempPath}/cubemap_equirectangularmap_comp.spv"
  "-V cubemap_equirectangularmap.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_equirectangularmap_rgb9e5_comp.spv"
  "-V cubemap_equirectangularmap.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_equirectangularmap_r11g11b10f_comp.spv"
  "-V cubemap_equirectangularmap.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_equirectangularmap_rgba16f_comp.spv"
  "-V cubemap_equirectangularmap.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_equirectangularmap_rgba32f_comp.spv"
  "-V cubemap_equirectangularmap.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_equirectangularmap_rgba8_comp.spv"
  "-V cubemap_octahedralmap.comp -o ${tempPath}/cubemap_octahedralmap_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_octahedralmap_rgb9e5_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_octahedralmap_r11g11b10f_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_octahedralmap_rgba16f_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_octahedralmap_rgba32f_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_octahedralmap_rgba8_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_R8_SNORM -o ${tempPath}/cubemap_octahedralmap_r8_snorm_comp.spv"
  "-V cubemap_octahedralmap.comp -DUSE_R8 -o ${tempPath}/cubemap_octahedralmap_r8_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -o ${tempPath}/cubemap_octahedralmap_planet_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_RGB9E5 -o ${tempPath}/cubemap_octahedralmap_planet_rgb9e5_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_R11G11B10F -o ${tempPath}/cubemap_octahedralmap_planet_r11g11b10f_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_RGBA16F -o ${tempPath}/cubemap_octahedralmap_planet_rgba16f_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_RGBA32F -o ${tempPath}/cubemap_octahedralmap_planet_rgba32f_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_RGBA8 -o ${tempPath}/cubemap_octahedralmap_planet_rgba8_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_R8_SNORM -o ${tempPath}/cubemap_octahedralmap_planet_r8_snorm_comp.spv"
  "-V cubemap_octahedralmap.comp -DPLANET_OCTAHEDRAL -DUSE_R8 -o ${tempPath}/cubemap_octahedralmap_planet_r8_comp.spv"
  "-V cubemap_initialization.comp -o ${tempPath}/cubemap_initialization_comp.spv"
  "-V cubemap_initialization.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_initialization_rgb9e5_comp.spv"
  "-V cubemap_initialization.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_initialization_r11g11b10f_comp.spv"
  "-V cubemap_initialization.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_initialization_rgba16f_comp.spv"
  "-V cubemap_initialization.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_initialization_rgba32f_comp.spv"
  "-V cubemap_initialization.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_initialization_rgba8_comp.spv"
  "-V cubemap_initialization.comp -DUSE_R8 -o ${tempPath}/cubemap_initialization_r8_comp.spv"
  "-V cubemap_sky.comp -o ${tempPath}/cubemap_sky_comp.spv"
  "-V cubemap_sky.comp -DFAST -o ${tempPath}/cubemap_sky_fast_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_sky_rgb9e5_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGB9E5 -DFAST -o ${tempPath}/cubemap_sky_fast_rgb9e5_comp.spv"
  "-V cubemap_sky.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_sky_r11g11b10f_comp.spv"
  "-V cubemap_sky.comp -DUSE_R11G11B10F -DFAST -o ${tempPath}/cubemap_sky_fast_r11g11b10f_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_sky_rgba16f_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA16F -DFAST -o ${tempPath}/cubemap_sky_fast_rgba16f_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_sky_rgba32f_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA32F -DFAST -o ${tempPath}/cubemap_sky_fast_rgba32f_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_sky_rgba8_comp.spv"
  "-V cubemap_sky.comp -DUSE_RGBA8 -DFAST -o ${tempPath}/cubemap_sky_fast_rgba8_comp.spv"
  "-V cubemap_sky.frag -o ${tempPath}/cubemap_sky_frag.spv"
  "-V cubemap_sky.frag -DFAST -o ${tempPath}/cubemap_sky_fast_frag.spv"
  "-V cubemap_starlight.comp -o ${tempPath}/cubemap_starlight_comp.spv"
  "-V cubemap_starlight.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_starlight_rgb9e5_comp.spv"
  "-V cubemap_starlight.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_starlight_r11g11b10f_comp.spv"
  "-V cubemap_starlight.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_starlight_rgba16f_comp.spv"
  "-V cubemap_starlight.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_starlight_rgba32f_comp.spv"
  "-V cubemap_starlight.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_starlight_rgba8_comp.spv"
  "-V cubemap_filter.comp -o ${tempPath}/cubemap_filter_comp.spv"
  "-V cubemap_filter.comp -DUSE_RGB9E5 -o ${tempPath}/cubemap_filter_rgb9e5_comp.spv"
  "-V cubemap_filter.comp -DUSE_R11G11B10F -o ${tempPath}/cubemap_filter_r11g11b10f_comp.spv"
  "-V cubemap_filter.comp -DUSE_RGBA16F -o ${tempPath}/cubemap_filter_rgba16f_comp.spv"
  "-V cubemap_filter.comp -DUSE_RGBA32F -o ${tempPath}/cubemap_filter_rgba32f_comp.spv"
  "-V cubemap_filter.comp -DUSE_RGBA8 -o ${tempPath}/cubemap_filter_rgba8_comp.spv"
    
  "-V passthrough.vert -o ${tempPath}/passthrough_vert.spv"
  
  "-V dummy.frag -o ${tempPath}/dummy_frag.spv"

  #"-V dithering.frag -o ${tempPath}/dithering_frag.spv"

  "-V debug_blit.frag -o ${tempPath}/debug_blit_frag.spv"
  
  "-V skybox.vert -o ${tempPath}/skybox_vert.spv"
  "-V skybox.frag -o ${tempPath}/skybox_frag.spv"
  
  "-V skybox_realtime.frag -o ${tempPath}/skybox_realtime_frag.spv"
  
  "-V tonemapping.frag -o ${tempPath}/tonemapping_frag.spv"
  
  "-V antialiasing_dsaa.frag -o ${tempPath}/antialiasing_dsaa_frag.spv"
  "-V antialiasing_fxaa.frag -o ${tempPath}/antialiasing_fxaa_frag.spv"
  "-V antialiasing_taa.frag -o ${tempPath}/antialiasing_taa_frag.spv"
  "-V antialiasing_none.frag -o ${tempPath}/antialiasing_none_frag.spv"

  "-V antialiasing_smaa_temporal_resolve.vert -o ${tempPath}/antialiasing_smaa_temporal_resolve_vert.spv"
  "-V antialiasing_smaa_temporal_resolve.frag -o ${tempPath}/antialiasing_smaa_temporal_resolve_frag.spv"
  
  "-V antialiasing_smaa_blend.vert -o ${tempPath}/antialiasing_smaa_blend_vert.spv"
  "-V antialiasing_smaa_blend.frag -o ${tempPath}/antialiasing_smaa_blend_frag.spv"
  "-V antialiasing_smaa_blend.frag -DSMAA_REPROJECTION=1 -o ${tempPath}/antialiasing_smaa_blend_reprojection_frag.spv"
  
  "-V antialiasing_smaa_edges.vert -o ${tempPath}/antialiasing_smaa_edges_vert.spv"
  "-V antialiasing_smaa_edges.frag -o ${tempPath}/antialiasing_smaa_edges_color_frag.spv"
  "-V antialiasing_smaa_edges.frag -DLUMA -o ${tempPath}/antialiasing_smaa_edges_luma_frag.spv"
  
  "-V antialiasing_smaa_weights.vert -o ${tempPath}/antialiasing_smaa_weights_vert.spv"
  "-V antialiasing_smaa_weights.frag -o ${tempPath}/antialiasing_smaa_weights_frag.spv"
  
  "-V blit.frag -o ${tempPath}/blit_frag.spv"

  "-V blit.frag -DMSAA -o ${tempPath}/blit_msaa_frag.spv"

  "-V framebuffer_blit.frag -o ${tempPath}/framebuffer_blit_frag.spv"

  "-V msaa_resolve.frag -o ${tempPath}/msaa_resolve_frag.spv"
  
  "-V msm_blur.frag -o ${tempPath}/msm_blur_frag.spv"
  "-V msm_blur.vert -o ${tempPath}/msm_blur_vert.spv"
  
  "-V msm_resolve.frag -o ${tempPath}/msm_resolve_frag.spv"
  "-V msm_resolve.frag -DMSAA -o ${tempPath}/msm_resolve_msaa_frag.spv"
  "-V msm_resolve.vert -o ${tempPath}/msm_resolve_vert.spv"

  "-V ambientocclusion.frag -o ${tempPath}/ambientocclusion_frag.spv"
  "-V ambientocclusion.frag -DMULTIVIEW -o ${tempPath}/ambientocclusion_multiview_frag.spv"
  "-V ambientocclusion.frag -DRAYTRACING -o ${tempPath}/ambientocclusion_raytracing_frag.spv"
  "-V ambientocclusion.frag -DRAYTRACING -DMULTIVIEW -o ${tempPath}/ambientocclusion_raytracing_multiview_frag.spv"

  "-V ambientocclusion_blur.frag -o ${tempPath}/ambientocclusion_blur_frag.spv"

  "-V contentprojection.frag -o ${tempPath}/contentprojection_frag.spv"
  "-V contentprojection.frag -DREVERSEDZ -o ${tempPath}/contentprojection_reversedz_frag.spv"

  "-V mipmap.comp -DLEVEL0 -o ${tempPath}/mipmap_level0_comp.spv"
  "-V mipmap.comp -DLEVEL1 -o ${tempPath}/mipmap_level1_comp.spv"

  "-V debug_primitive.vert -o ${tempPath}/debug_primitive_vert.spv"
  "-V debug_primitive.frag -o ${tempPath}/debug_primitive_frag.spv"
  "-V debug_primitive.geom -o ${tempPath}/debug_primitive_geom.spv"

  "-V solid_primitive.comp -o ${tempPath}/solid_primitive_comp.spv"
  "-V solid_primitive.vert -o ${tempPath}/solid_primitive_vert.spv"
  "-V solid_primitive.frag -o ${tempPath}/solid_primitive_frag.spv"

  "-V space_lines.comp -o ${tempPath}/space_lines_comp.spv"
  "-V space_lines.vert -o ${tempPath}/space_lines_vert.spv"
  "-V space_lines.frag -o ${tempPath}/space_lines_frag.spv"

  "-V particle.vert -o ${tempPath}/particle_vert.spv"
  "-V particle.vert -DVOXELIZATION -o ${tempPath}/particle_voxelization_vert.spv"
  "-V particle.vert -DRAYTRACING -o ${tempPath}/particle_raytracing_vert.spv"
  "-V particle.vert -DRAYTRACING -DVOXELIZATION -o ${tempPath}/particle_raytracing_voxelization_vert.spv"

  "-V resampling.frag -o ${tempPath}/resampling_frag.spv"
   
  "-V cubemap_sphericalharmonics.comp -o ${tempPath}/cubemap_sphericalharmonics_comp.spv"
  
  "-V cubemap_sphericalharmonics_accumulation.comp -o ${tempPath}/cubemap_sphericalharmonics_accumulation_comp.spv" 
  "-V cubemap_sphericalharmonics_accumulation.comp -DUSE_ATOMIC_FLOATS -o ${tempPath}/cubemap_sphericalharmonics_accumulation_atomicfloats_comp.spv"
  
  "-V cubemap_sphericalharmonics_normalization.comp -o ${tempPath}/cubemap_sphericalharmonics_normalization_comp.spv"

  "-V cubemap_sphericalharmonics_extract_metadata.comp -o ${tempPath}/cubemap_sphericalharmonics_extract_metadata_comp.spv"

  "-V topdownskyocclusionmap_resolve.frag -o ${tempPath}/topdownskyocclusionmap_resolve_frag.spv"

  "-V topdownskyocclusionmap_blur.frag -o ${tempPath}/topdownskyocclusionmap_blur_frag.spv"

  "-V gi_cascaded_radiance_hints_inject_cached.comp -o ${tempPath}/gi_cascaded_radiance_hints_inject_cached_comp.spv"

  "-V gi_cascaded_radiance_hints_inject_sky.comp -o ${tempPath}/gi_cascaded_radiance_hints_inject_sky_comp.spv"
  
  "-V gi_cascaded_radiance_hints_inject_rsm.comp -o ${tempPath}/gi_cascaded_radiance_hints_inject_rsm_comp.spv"

  "-V gi_cascaded_radiance_hints_bounce.comp -o ${tempPath}/gi_cascaded_radiance_hints_bounce_comp.spv"

  "-V voxel_visualization.vert -o ${tempPath}/voxel_visualization_vert.spv"
  "-V voxel_visualization.frag -o ${tempPath}/voxel_visualization_frag.spv"
  "-V voxel_visualization.frag -DUSEDEMOTE -o ${tempPath}/voxel_visualization_demote_frag.spv"

  "-V voxel_mesh_visualization.vert -o ${tempPath}/voxel_mesh_visualization_vert.spv"
  "-V voxel_mesh_visualization.vert -DUSEGEOMETRYSHADER -o ${tempPath}/voxel_mesh_visualization_geometry_vert.spv"
  "-V voxel_mesh_visualization.geom -o ${tempPath}/voxel_mesh_visualization_geom.spv"
  "-V voxel_mesh_visualization.frag -o ${tempPath}/voxel_mesh_visualization_frag.spv"

  "-V planet_water_prepass.comp -o ${tempPath}/planet_water_prepass_comp.spv"

  "-V planet_blendmap_downsample.comp -o ${tempPath}/planet_blendmap_downsample_comp.spv"

  "-V planet_blendmap_initialization.comp -o ${tempPath}/planet_blendmap_initialization_comp.spv"

  "-V planet_blendmap_modification.comp -o ${tempPath}/planet_blendmap_modification_comp.spv"

  "-V planet_grassmap_initialization.comp -o ${tempPath}/planet_grassmap_initialization_comp.spv"

  "-V planet_grassmap_modification.comp -o ${tempPath}/planet_grassmap_modification_comp.spv"

  "-V planet_precipitationmap_initialization.comp -o ${tempPath}/planet_precipitationmap_initialization_comp.spv"

  "-V planet_precipitationmap_modification.comp -o ${tempPath}/planet_precipitationmap_modification_comp.spv"

  "-V planet_atmospheremap_downsample.comp -o ${tempPath}/planet_atmospheremap_downsample_comp.spv"

  "-V planet_atmospheremap_initialization.comp -o ${tempPath}/planet_atmospheremap_initialization_comp.spv"

  "-V planet_atmospheremap_modification.comp -o ${tempPath}/planet_atmospheremap_modification_comp.spv"

  "-V planet_atmospheremap_update.comp -o ${tempPath}/planet_atmospheremap_update_comp.spv"

  "-V planet_precipitationatmospheremap.comp -o ${tempPath}/planet_precipitationatmospheremap_comp.spv"

  "-V planet_precipitationmap_simulation.comp -o ${tempPath}/planet_precipitationmap_simulation_comp.spv"

  "-V planet_precipitationmap_simulation_transfer.comp -o ${tempPath}/planet_precipitationmap_simulation_transfer_comp.spv"

  "-V planet_precipitationmap_downsample.comp -o ${tempPath}/planet_precipitationmap_downsample_comp.spv"

  "-V planet_rainstreaks_simulation.comp -o ${tempPath}/planet_rainstreaks_simulation_comp.spv"

  "-V planet_rainstreaks_meshgeneration.comp -o ${tempPath}/planet_rainstreaks_meshgeneration_comp.spv"

  "-V planet_rainstreaks.vert -o ${tempPath}/planet_rainstreaks_vert.spv"

  "-V planet_rainstreaks.frag -o ${tempPath}/planet_rainstreaks_frag.spv"

  # Screenspace wetness map compute shaders for different configurations
  "-V planet_screenspace_wetness_map.comp -o ${tempPath}/planet_screenspace_wetness_map_comp.spv"
  "-V planet_screenspace_wetness_map.comp -DMULTIVIEW -o ${tempPath}/planet_screenspace_wetness_map_multiview_comp.spv"
  "-V planet_screenspace_wetness_map.comp -DMSAA -o ${tempPath}/planet_screenspace_wetness_map_msaa_comp.spv"
  "-V planet_screenspace_wetness_map.comp -DMSAA -DMULTIVIEW -o ${tempPath}/planet_screenspace_wetness_map_msaa_multiview_comp.spv"

  "-V planet_watermap_initialization.comp -o ${tempPath}/planet_watermap_initialization_comp.spv"

  "-V planet_watermap_modification.comp -o ${tempPath}/planet_watermap_modification_comp.spv"

  "-V planet_heightmap_random_initialization.comp -o ${tempPath}/planet_heightmap_random_initialization_comp.spv"

  "-V planet_heightmap_data_initialization.comp -o ${tempPath}/planet_heightmap_data_initialization_comp.spv"
  
  "-V planet_heightmap_flatten.comp -o ${tempPath}/planet_heightmap_flatten_comp.spv"

  "-V planet_heightmap_modification.comp -o ${tempPath}/planet_heightmap_modification_comp.spv"

  "-V planet_normalmap_generation.comp -o ${tempPath}/planet_normalmap_generation_comp.spv"

  "-V planet_tiled_mesh_index_generation.comp -o ${tempPath}/planet_tiled_mesh_index_generation_comp.spv"

  "-V planet_tiled_mesh_vertex_generation.comp -o ${tempPath}/planet_tiled_mesh_vertex_generation_comp.spv"

  "-V planet_tiled_mesh_slope_generation.comp -o ${tempPath}/planet_tiled_mesh_slope_generation_comp.spv"

  "-V planet_tiled_neighbour_distance_map_generation.comp -o ${tempPath}/planet_tiled_neighbour_distance_map_generation_comp.spv"

  "-V planet_tiles_dirty_expansion.comp -o ${tempPath}/planet_tiles_dirty_expansion_comp.spv"

  "-V planet_tiles_dirty_queue_generation.comp -o ${tempPath}/planet_tiles_dirty_queue_generation_comp.spv"

  "-V planet_tiled_mesh_boundingvolumes_generation.comp -o ${tempPath}/planet_tiled_mesh_boundingvolumes_generation_comp.spv"

  "-V planet_ray_intersection.comp -o ${tempPath}/planet_ray_intersection_comp.spv"

  "-V planet_cull.comp -o ${tempPath}/planet_cull_simple_comp.spv"
  "-V planet_cull.comp -DPASS0 -o ${tempPath}/planet_cull_pass0_comp.spv"
  "-V planet_cull.comp -DPASS1 -o ${tempPath}/planet_cull_pass1_comp.spv"

  "-V planet_water_modification.comp -o ${tempPath}/planet_water_modification_comp.spv"
  
#  "-V planet_water_simulation.comp -DOUTFLOW -o ${tempPath}/planet_water_simulation_outflow_comp.spv"
#  "-V planet_water_simulation.comp -o ${tempPath}/planet_water_simulation_waterheight_comp.spv"

  "-V planet_water_simulation_outflow.comp -o ${tempPath}/planet_water_simulation_outflow_comp.spv"
  "-V planet_water_simulation_outflow.comp -DUSE_HEIGHTMAP_BUFFER -o ${tempPath}/planet_water_simulation_outflow_buffer_comp.spv"
  "-V planet_water_simulation_outflow.comp -DUSE_FP16 -o ${tempPath}/planet_water_simulation_outflow_fp16_comp.spv"
  "-V planet_water_simulation_outflow.comp -DUSE_HEIGHTMAP_BUFFER -DUSE_FP16 -o ${tempPath}/planet_water_simulation_outflow_buffer_fp16_comp.spv"
  "-V planet_water_simulation_waterheight.comp -o ${tempPath}/planet_water_simulation_waterheight_comp.spv"
  "-V planet_water_simulation_waterheight.comp -DUSE_FP16 -o ${tempPath}/planet_water_simulation_waterheight_fp16_comp.spv"
  "-V planet_water_simulation_rainfall.comp -o ${tempPath}/planet_water_simulation_rainfall_comp.spv"

  "-V planet_water_interpolation.comp -DOUTFLOW -o ${tempPath}/planet_water_interpolation_comp.spv"

  "-V planet_water_downsample.comp -o ${tempPath}/planet_water_downsample_comp.spv"
  
  "-V planet_water_downsampledtexture.comp -o ${tempPath}/planet_water_downsampledtexture_comp.spv"
  
  "-V planet_water_cull.comp -o ${tempPath}/planet_water_cull_comp.spv"
  
  "-V planet_water.vert -DTESSELLATION -o ${tempPath}/planet_water_vert.spv"
  "-V planet_water.vert -DTESSELLATION -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_water_bufref_vert.spv"
  "-V planet_water.vert -DTESSELLATION -DRAYTRACING -o ${tempPath}/planet_water_raytracing_vert.spv"

  "-V planet_water.tesc -o ${tempPath}/planet_water_tesc.spv"
  "-V planet_water.tesc -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_water_bufref_tesc.spv"
  "-V planet_water.tesc -DRAYTRACING -o ${tempPath}/planet_water_raytracing_tesc.spv"

  "-V planet_water.tese -o ${tempPath}/planet_water_tese.spv"
  "-V planet_water.tese -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_water_bufref_tese.spv"
  "-V planet_water.tese -DRAYTRACING -o ${tempPath}/planet_water_raytracing_tese.spv"

  "-V planet_water.vert -DUNDERWATER -o ${tempPath}/planet_water_underwater_vert.spv"
  "-V planet_water.vert -DUNDERWATER -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_water_underwater_bufref_vert.spv"
  "-V planet_water.vert -DUNDERWATER -DRAYTRACING -o ${tempPath}/planet_water_underwater_raytracing_vert.spv"
  
  "-V planet_water.frag -DUNDERWATER -o ${tempPath}/planet_water_underwater_frag.spv"
  "-V planet_water.frag -DUNDERWATER -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_water_underwater_bufref_frag.spv"
  "-V planet_water.frag -DUNDERWATER -DRAYTRACING -o ${tempPath}/planet_water_underwater_raytracing_frag.spv"

  "-V planet_renderpass.vert -o ${tempPath}/planet_renderpass_vert.spv"
  "-V planet_renderpass.vert -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_vert.spv"
  "-V planet_renderpass.vert -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_vert.spv"
  "-V planet_renderpass.vert -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_vert.spv"
  "-V planet_renderpass.vert -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_vert.spv"
  "-V planet_renderpass.vert -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_vert.spv"

  "-V planet_renderpass.frag -o ${tempPath}/planet_renderpass_frag.spv"
  "-V planet_renderpass.frag -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_frag.spv"
  "-V planet_renderpass.frag -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_frag.spv"
  "-V planet_renderpass.frag -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_frag.spv"
  "-V planet_renderpass.frag -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_frag.spv"
  "-V planet_renderpass.frag -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_frag.spv"
  "-V planet_renderpass.frag -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_frag.spv"
  "-V planet_renderpass.frag -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_frag.spv"
  "-V planet_renderpass.frag -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_frag.spv"
  "-V planet_renderpass.frag -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_frag.spv"
  "-V planet_renderpass.frag -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_frag.spv"
  "-V planet_renderpass.frag -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_renderpass_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_rsm_frag.spv"
  "-V planet_renderpass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_rsm_frag.spv"
   
  # MSM
  "-V planet_renderpass.frag -DMSM -o ${tempPath}/planet_renderpass_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_msm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_renderpass_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_msm_rsm_frag.spv"
  "-V planet_renderpass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_msm_rsm_frag.spv"
  
  # PCFPCSS
  "-V planet_renderpass.frag -DPCFPCSS -o ${tempPath}/planet_renderpass_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_renderpass_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_renderpass_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_renderpass_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_wireframe_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_renderpass_bufref_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_renderpass_bufref_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_bufref_wireframe_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_renderpass_raytracing_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_renderpass_raytracing_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_renderpass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_renderpass_raytracing_wireframe_velocity_pcfpcss_rsm_frag.spv"

  # Grass on planets
  
  #"-V planet_grass_cull_and_mesh_generation.comp -o ${tempPath}/planet_grass_cull_and_mesh_generation_comp.spv"

  #"-V planet_grass.comp -o ${tempPath}/planet_grass.spv"

  "-V planet_grass.task --target-env vulkan1.2 -o ${tempPath}/planet_grass_task.spv"
  "-V planet_grass.task --target-env vulkan1.2 -DVELOCITY -o ${tempPath}/planet_grass_velocity_task.spv"
  "-V planet_grass.task --target-env vulkan1.2 -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_task.spv"
  "-V planet_grass.task --target-env vulkan1.2 -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_task.spv"
  "-V planet_grass.task --target-env vulkan1.2 -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_task.spv"
  "-V planet_grass.task --target-env vulkan1.2 -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_task.spv"

  "-V planet_grass.mesh --target-env vulkan1.2 -o ${tempPath}/planet_grass_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DVELOCITY -o ${tempPath}/planet_grass_velocity_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -o ${tempPath}/planet_grass_multiview_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -DVELOCITY -o ${tempPath}/planet_grass_velocity_multiview_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_multiview_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_multiview_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_multiview_mesh.spv"
  "-V planet_grass.mesh --target-env vulkan1.2 -DMULTIVIEW -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_multiview_mesh.spv"

  # The mesh shader emulation variants, forced to be compiled as pure compute shaders
  "-V planet_grass.task -DMESH_SHADER_EMULATION --target-env vulkan1.2 -S comp -o ${tempPath}/planet_grass_task_comp.spv"
  "-V planet_grass.mesh -DMESH_SHADER_EMULATION --target-env vulkan1.2 -S comp -o ${tempPath}/planet_grass_mesh_comp.spv"

  "-V planet_grass.vert -o ${tempPath}/planet_grass_vert.spv"
  "-V planet_grass.vert -DVELOCITY -o ${tempPath}/planet_grass_velocity_vert.spv"
  "-V planet_grass.vert -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_vert.spv"
  "-V planet_grass.vert -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_vert.spv"
  "-V planet_grass.vert -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_vert.spv"
  "-V planet_grass.vert -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_vert.spv"

  "-V planet_grass.frag -o ${tempPath}/planet_grass_frag.spv"
  "-V planet_grass.frag -DVELOCITY -o ${tempPath}/planet_grass_velocity_frag.spv"
  "-V planet_grass.frag -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_frag.spv"
  "-V planet_grass.frag -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_frag.spv"
  "-V planet_grass.frag -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_frag.spv"
  "-V planet_grass.frag -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_frag.spv"
  "-V planet_grass.frag -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_frag.spv"
  "-V planet_grass.frag -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_frag.spv"
  "-V planet_grass.frag -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_frag.spv"
  "-V planet_grass.frag -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_frag.spv"
  "-V planet_grass.frag -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_frag.spv"
  "-V planet_grass.frag -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_grass_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_grass_velocity_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_rsm_frag.spv"
  "-V planet_grass.frag -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_rsm_frag.spv"

  # MSM
  "-V planet_grass.frag -DMSM -o ${tempPath}/planet_grass_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DVELOCITY -o ${tempPath}/planet_grass_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_msm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_grass_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_grass_velocity_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_msm_rsm_frag.spv"
  "-V planet_grass.frag -DMSM -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_msm_rsm_frag.spv"

  # PCFPCSS
  "-V planet_grass.frag -DPCFPCSS -o ${tempPath}/planet_grass_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DVELOCITY -o ${tempPath}/planet_grass_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_pcfpcss_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -o ${tempPath}/planet_grass_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DVELOCITY -o ${tempPath}/planet_grass_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -o ${tempPath}/planet_grass_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_wireframe_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -o ${tempPath}/planet_grass_bufref_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DVELOCITY -o ${tempPath}/planet_grass_bufref_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -o ${tempPath}/planet_grass_bufref_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DUSE_BUFFER_REFERENCE -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_bufref_wireframe_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -o ${tempPath}/planet_grass_raytracing_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DVELOCITY -o ${tempPath}/planet_grass_raytracing_velocity_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -o ${tempPath}/planet_grass_raytracing_wireframe_pcfpcss_rsm_frag.spv"
  "-V planet_grass.frag -DPCFPCSS -DREFLECTIVESHADOWMAPOUTPUT -DRAYTRACING -DWIREFRAME -DVELOCITY -o ${tempPath}/planet_grass_raytracing_wireframe_velocity_pcfpcss_rsm_frag.spv"

  # Atmosphere
  "-V atmosphere_map_scan.comp -o ${tempPath}/atmosphere_map_scan_comp.spv"
  "-V atmosphere_transmittancelut.comp -o ${tempPath}/atmosphere_transmittancelut_comp.spv"
  "-V atmosphere_multiscattering.comp -o ${tempPath}/atmosphere_multiscattering_comp.spv"
  "-V atmosphere_skyviewlut.comp -o ${tempPath}/atmosphere_skyviewlut_comp.spv"
  "-V atmosphere_skyluminancelut.comp -o ${tempPath}/atmosphere_skyluminancelut_comp.spv"                                                      
  "-V atmosphere_cameravolume.comp -o ${tempPath}/atmosphere_cameravolume_comp.spv"
  "-V atmosphere_cubemap.comp -o ${tempPath}/atmosphere_cubemap_comp.spv"
  "-V atmosphere_cubemap.comp -DUSE_RGBA8 -o ${tempPath}/atmosphere_cubemap_rgba8_comp.spv"
  "-V atmosphere_cubemap.comp -DUSE_RGB9E5 -o ${tempPath}/atmosphere_cubemap_rgb9e5_comp.spv"
  "-V atmosphere_cubemap.comp -DUSE_RGBA16F -o ${tempPath}/atmosphere_cubemap_rgba16f_comp.spv"
  "-V atmosphere_cubemap.comp -DUSE_RGBA32F -o ${tempPath}/atmosphere_cubemap_rgba32f_comp.spv"
  "-V atmosphere_raymarch.frag -o ${tempPath}/atmosphere_raymarch_frag.spv"
  "-V atmosphere_raymarch.frag -DMSAA -o ${tempPath}/atmosphere_raymarch_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DDUALBLEND -o ${tempPath}/atmosphere_raymarch_dualblend_frag.spv"
  "-V atmosphere_raymarch.frag -DDUALBLEND -DMSAA -o ${tempPath}/atmosphere_raymarch_dualblend_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DDUALBLEND -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_dualblend_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DDUALBLEND -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_dualblend_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -o ${tempPath}/atmosphere_raymarch_shadows_msm_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_msm_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_msm_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_msm_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DDUALBLEND -o ${tempPath}/atmosphere_raymarch_shadows_msm_dualblend_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DDUALBLEND -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_msm_dualblend_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DDUALBLEND -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_msm_dualblend_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DMSM -DDUALBLEND -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_msm_dualblend_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DDUALBLEND -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_dualblend_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DDUALBLEND -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_dualblend_msaa_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DDUALBLEND -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_dualblend_multiview_frag.spv"
  "-V atmosphere_raymarch.frag -DSHADOWS -DPCFPCSS -DDUALBLEND -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_pcfpcss_dualblend_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_msaa_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_multiview_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_multiview_msaa_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DDUALBLEND -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_dualblend_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DDUALBLEND -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_dualblend_msaa_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DDUALBLEND -DMULTIVIEW -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_dualblend_multiview_frag.spv"
  "-V atmosphere_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DDUALBLEND -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_raymarch_shadows_raytracing_dualblend_multiview_msaa_frag.spv"
  
  # Clouds noise
  "-V atmosphere_clouds_noise_curl.comp -o ${tempPath}/atmosphere_clouds_noise_curl_comp.spv"
  "-V atmosphere_clouds_noise_detail.comp -o ${tempPath}/atmosphere_clouds_noise_detail_comp.spv"
  "-V atmosphere_clouds_noise_shape.comp -o ${tempPath}/atmosphere_clouds_noise_shape_comp.spv"

  # Clouds weather map
  "-V atmosphere_clouds_weathermap.comp -o ${tempPath}/atmosphere_clouds_weathermap_comp.spv"

  # Clouds rendering
  "-V atmosphere_clouds_raymarch.frag -o ${tempPath}/atmosphere_clouds_raymarch_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DMULTIVIEW -o ${tempPath}/atmosphere_clouds_raymarch_multiview_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_multiview_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DMSM -o ${tempPath}/atmosphere_clouds_raymarch_shadows_msm_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DMSM -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_msm_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DMSM -DMULTIVIEW -o ${tempPath}/atmosphere_clouds_raymarch_shadows_msm_multiview_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DMSM -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_msm_multiview_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DPCFPCSS -o ${tempPath}/atmosphere_clouds_raymarch_shadows_pcfpcss_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DPCFPCSS -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_pcfpcss_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DPCFPCSS -DMULTIVIEW -o ${tempPath}/atmosphere_clouds_raymarch_shadows_pcfpcss_multiview_frag.spv"
  "-V atmosphere_clouds_raymarch.frag -DSHADOWS -DPCFPCSS -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_pcfpcss_multiview_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -o ${tempPath}/atmosphere_clouds_raymarch_shadows_raytracing_frag.spv"
  "-V atmosphere_clouds_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_raytracing_msaa_frag.spv"
  "-V atmosphere_clouds_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMULTIVIEW -o ${tempPath}/atmosphere_clouds_raymarch_shadows_raytracing_multiview_frag.spv"
  "-V atmosphere_clouds_raymarch.frag --target-env vulkan1.2 -DSHADOWS -DRAYTRACING -DMULTIVIEW -DMSAA -o ${tempPath}/atmosphere_clouds_raymarch_shadows_raytracing_multiview_msaa_frag.spv"

  # Clouds shadow map
  "-V atmosphere_clouds_raymarch.frag -DSHADOWMAP -o ${tempPath}/atmosphere_clouds_raymarch_shadowmap_frag.spv" # Fragment shader variant
  "-S comp -V atmosphere_clouds_raymarch.frag -DSHADOWMAP -DCOMPUTE_SHADER -o ${tempPath}/atmosphere_clouds_raymarch_shadowmap_comp.spv" # Compute shader variant

)

#############################################
#               Helper functions            #
#############################################

addShader(){
  compileshaderarguments+=("$1")
}

#############################################
#               Particle shaders            #
#############################################

addParticleFragmentShader(){
  addShader "-V particle.frag ${2} -o ${tempPath}/${1}_frag.spv"
}

# Add particle fragment shader variants with different transparency techniques (if any)
addParticleFragmentShadingTransparencyVariants(){

  # Standard alpha blending
  addParticleFragmentShader "${1}_blend" "$2 -DBLEND"

  # WBOIT (Weighted-Blended Order Independent Transparency)
  addParticleFragmentShader "${1}_wboit" "$2 -DWBOIT"

  # MBOIT (Moment-Based order independent transparency)
  addParticleFragmentShader "${1}_mboit_pass1" "$2 -DMBOIT -DMBOITPASS1"
  addParticleFragmentShader "${1}_mboit_pass2" "$2 -DMBOIT -DMBOITPASS2"

  # LoopOIT (Multi-pass order independent transparency)
  addParticleFragmentShader "${1}_loopoit_pass1" "$2 -DLOOPOIT -DLOOPOIT_PASS1 -DDEPTHONLY"
  addParticleFragmentShader "${1}_loopoit_pass2" "$2 -DLOOPOIT -DLOOPOIT_PASS2"

  # LockOIT (Order independent transparency with spinlock/interlock, depending on the GPU capabilities)
  addParticleFragmentShader "${1}_spinlock_lockoit" "$2 -DLOCKOIT -DSPINLOCK"
  addParticleFragmentShader "${1}_interlock_lockoit" "$2 -DLOCKOIT -DINTERLOCK"

  # DFAOIT (Neural network based order independent transparency)
  addParticleFragmentShader "${1}_spinlock_dfaoit" "$2 -DDFAOIT -DSPINLOCK"
  addParticleFragmentShader "${1}_interlock_dfaoit" "$2 -DDFAOIT -DINTERLOCK"

}

addParticleFragmentShadingAntialiasingVariants(){
  
  # No antialiasing or temporal antialiasing
  addParticleFragmentShadingTransparencyVariants "${1}" "$2"

  # MSAA (Multi-sample anti-aliasing)
  addParticleFragmentShadingTransparencyVariants "${1}_msaa" "$2 -DMSAA"  

}

# Add particle fragment shader variants with different Z direction
addParticleFragmentZVariants(){
  
  # Normal Z direction
  addParticleFragmentShadingAntialiasingVariants "$1" "$2"
  
  # Reversed Z direction
  addParticleFragmentShadingAntialiasingVariants "${1}_reversedz" "$2 -DREVERSEDZ"
 
 
}

# Add particle fragment shader variants with different voxelization modes 
addParticleFragmentVoxelizationVariants(){
    
  # Voxelization
  addParticleFragmentShader "${1}_voxelization" "$2 -DVOXELIZATION"
    
}

# Add particle fragment shader variants with different techniques (if any)
addParticleFragmentVariants(){
  
  addParticleFragmentZVariants "${1}" "$2"

  addParticleFragmentZVariants "${1}_raytracing" "$2 -DRAYTRACING" # Raytracing

  addParticleFragmentVoxelizationVariants "${1}" "$2"

  addParticleFragmentVoxelizationVariants "${1}_raytracing" "$2 -DRAYTRACING" # Raytracing
  
}

addParticleFragmentVariants "particle" ""

#############################################
#           Planet water shaders            #
#############################################

addPlanetWaterFragmentShader(){
  addShader "-V planet_water.frag ${2} -o ${tempPath}/${1}_frag.spv"
}

# Add planet water fragment shader variants with different discard techniques (if any)
addPlanetWaterFragmentShadingDiscardVariants(){
  
  # No antialiasing or temporal antialiasing
  addPlanetWaterFragmentShader "${1}" "$2"

  # MSAA (Multi-sample anti-aliasing)
  addPlanetWaterFragmentShader "${1}_demote" "$2 -DUSEDEMOTE"

}

# Add planet water fragment shader variants with different transparency techniques (if any)
addPlanetWaterFragmentShadingAntialiasingVariants(){
  
  # No antialiasing or temporal antialiasing
  addPlanetWaterFragmentShadingDiscardVariants "${1}" "$2"

  # MSAA (Multi-sample anti-aliasing)
  addPlanetWaterFragmentShadingDiscardVariants "${1}_msaa" "$2 -DMSAA"  

  # MSAA (Multi-sample anti-aliasing)
  addPlanetWaterFragmentShadingDiscardVariants "${1}_msaa_fast" "$2 -DMSAA -DMSAA_FAST"  

}

# Add planet water fragment shader variants with different Z direction
addPlanetWaterFragmentZVariants(){
  
  # Normal Z direction
  addPlanetWaterFragmentShadingAntialiasingVariants "$1" "$2"
  
  # Reversed Z direction
  addPlanetWaterFragmentShadingAntialiasingVariants "${1}_reversedz" "$2 -DREVERSEDZ"
 
 
}

# Add planet water fragment shader variants with different shadow techniques (if any)
addPlanetWaterFragmentShadingShadowVariants(){

  # No shadows
  addPlanetWaterFragmentZVariants "${1}" "$2"

  # MSM (Moment shadow mapping)
  addPlanetWaterFragmentZVariants "${1}_msm" "$2 -DMSM"

  # PCF (Percentage closer filtering) / PCSS (Percentage closer soft shadows) / DPCF (a PCF variant)
  addPlanetWaterFragmentZVariants "${1}_pcfpcss" "$2 -DPCFPCSS"
}

# Add planet water fragment shader variants with different techniques (if any)
addPlanetWaterFragmentVariants(){
  
  addPlanetWaterFragmentShadingShadowVariants "${1}" "$2"

  addPlanetWaterFragmentShadingShadowVariants "${1}_raytracing" "$2 -DRAYTRACING" # Raytracing
  
}

addPlanetWaterFragmentVariants "planet_water" "-DTESSELLATION"

#############################################
#               Mesh shaders                #
#############################################

addMeshFragmentShader(){
  addShader "-V mesh.frag ${2} -o ${tempPath}/${1}_frag.spv"
}

# Add mesh fragment shader variants with different alpha test techniques (if any)
addMeshFragmentShadingAlphaTestVariants(){
  addMeshFragmentShader "$1" "$2"
  addMeshFragmentShader "${1}_alphatest" "$2 -DALPHATEST"
  addMeshFragmentShader "${1}_alphatest_demote" "$2 -DALPHATEST -DUSEDEMOTE"
  addMeshFragmentShader "${1}_alphatest_nodiscard" "$2 -DALPHATEST -DNODISCARD"
}

# Add mesh fragment shader variants with or without velocity output (if any)
addMeshFragmentShadingVelocityVariants(){
  addMeshFragmentShadingAlphaTestVariants "$1" "$2"
  addMeshFragmentShadingAlphaTestVariants "${1}_velocity" "$2 -DVELOCITY"
}

# Add mesh fragment shader variants with different alpha test techniques (if any)
addMeshFragmentShadingOITAlphaTestVariants(){
  addMeshFragmentShader "$1" "$2"
  addMeshFragmentShader "${1}_alphatest" "$2 -DALPHATEST"
}

# Add mesh fragment shader variants with different transparency techniques (if any)
addMeshFragmentShadingTransparencyVariants(){

  # No blending   
  addMeshFragmentShadingVelocityVariants "$1" "$2"

  if [[ $2 != *"ENVMAP"* ]]; then

    # Standard alpha blending
    addMeshFragmentShadingAlphaTestVariants "${1}_blend" "$2 -DBLEND"

    # WBOIT (Weighted-Blended Order Independent Transparency)
    addMeshFragmentShadingOITAlphaTestVariants "${1}_wboit" "$2 -DWBOIT"

    # MBOIT (Moment-Based order independent transparency)
    addMeshFragmentShadingOITAlphaTestVariants "${1}_mboit_pass1" "$2 -DMBOIT -DMBOITPASS1"
    addMeshFragmentShadingOITAlphaTestVariants "${1}_mboit_pass2" "$2 -DMBOIT -DMBOITPASS2" 

    # LoopOIT (Multi-pass order independent transparency)
    addMeshFragmentShadingOITAlphaTestVariants "${1}_loopoit_pass1" "$2 -DLOOPOIT -DLOOPOIT_PASS1 -DDEPTHONLY"
    addMeshFragmentShadingOITAlphaTestVariants "${1}_loopoit_pass2" "$2 -DLOOPOIT -DLOOPOIT_PASS2"

    # LockOIT (Order independent transparency with spinlock/interlock, depending on the GPU capabilities)  
    addMeshFragmentShadingOITAlphaTestVariants "${1}_spinlock_lockoit" "$2 -DLOCKOIT -DSPINLOCK"
    addMeshFragmentShadingOITAlphaTestVariants "${1}_interlock_lockoit" "$2 -DLOCKOIT -DINTERLOCK"

    # DFAOIT (Neural network based order independent transparency)
    addMeshFragmentShadingOITAlphaTestVariants "${1}_spinlock_dfaoit" "$2 -DDFAOIT -DSPINLOCK"
    addMeshFragmentShadingOITAlphaTestVariants "${1}_interlock_dfaoit" "$2 -DDFAOIT -DINTERLOCK"

  fi  

}

# Add mesh fragment shader variants with different shadow techniques (if any)
addMeshFragmentShadingShadowVariants(){

  # No shadows
  #addMeshFragmentShadingTransparencyVariants "${1}" "$2"

  # MSM (Moment shadow mapping)
  addMeshFragmentShadingTransparencyVariants "${1}_msm" "$2 -DMSM"

  # PCF (Percentage closer filtering) / PCSS (Percentage closer soft shadows) / DPCF (a PCF variant)
  addMeshFragmentShadingTransparencyVariants "${1}_pcfpcss" "$2 -DPCFPCSS"
}

# Add mesh fragment shader variants either with or without wetness map usage
addMeshFragmentShadingWetnessVariants(){
  
  # No usage of wetness map
  addMeshFragmentShadingShadowVariants "${1}" "$2"

  if [[ $2 != *"ENVMAP"* ]]; then

    # Usage of wetness map
    addMeshFragmentShadingShadowVariants "${1}_wetness" "$2 -DWETNESS"  

  fi
  
}

# Add mesh fragment shader variants with different antialiasing techniques (if any)
addMeshFragmentShadingAntialiasingVariants(){
  
  # No antialiasing or temporal antialiasing
  addMeshFragmentShadingWetnessVariants "${1}" "$2"

  if [[ $2 != *"ENVMAP"* ]]; then

    # MSAA (Multi-sample anti-aliasing)
    addMeshFragmentShadingWetnessVariants "${1}_msaa" "$2 -DMSAA"  

  fi
  
}

# Add mesh fragment shader variants with different global illumination techniques (if any)
addMeshFragmentShadingGlobalIlluminationVariants(){
  
  # No global illumination
  addMeshFragmentShadingAntialiasingVariants "${1}" "$2"

  # Cascaded radiance hints
  addMeshFragmentShadingAntialiasingVariants "${1}_globalillumination_cascaded_radiance_hints" "$2 -DGLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS"
  
  # Cascaded voxel cone tracing
  addMeshFragmentShadingAntialiasingVariants "${1}_globalillumination_cascaded_voxel_cone_tracing" "$2 -DGLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING"
  
}

# Add mesh fragment shader depth only with different alphatest variants 
addMeshFragmentDepthOnlyAlphaTestVariants(){
  
  # No alpha test
  addMeshFragmentShader "${1}" "$2"

  # Alpha test
  addMeshFragmentShader "${1}_alphatest" "$2 -DALPHATEST"
  
  # Alpha test with demote
  addMeshFragmentShader "${1}_alphatest_demote" "$2 -DALPHATEST -DUSEDEMOTE"

  # Alpha test without discard
  addMeshFragmentShader "${1}_alphatest_nodiscard" "$2 -DALPHATEST -DNODISCARD"

}

# Add mesh fragment shader depth only variants
addMeshFragmentDepthOnlyVariants(){

  # Depth only
  addMeshFragmentDepthOnlyAlphaTestVariants "${1}" "$2"

}

# Add mesh fragment shader variants with different alpha test techniques (if any)
addMeshFragmentReflectiveShadowMapVariants(){
  addMeshFragmentShader "$1" "$2"
  addMeshFragmentShader "${1}_alphatest" "$2 -DALPHATEST"
  addMeshFragmentShader "${1}_alphatest_demote" "$2 -DALPHATEST -DUSEDEMOTE"
  addMeshFragmentShader "${1}_alphatest_nodiscard" "$2 -DALPHATEST -DNODISCARD"
}

# Add mesh fragment shader variants with different alpha test techniques (if any)
addMeshFragmentVoxelizationAlphaVariants(){
  addMeshFragmentShader "$1" "$2"
  addMeshFragmentShader "${1}_alphatest" "$2 -DALPHATEST"
  addMeshFragmentShader "${1}_alphatest_demote" "$2 -DALPHATEST -DUSEDEMOTE"
  addMeshFragmentShader "${1}_alphatest_nodiscard" "$2 -DALPHATEST -DNODISCARD"
}

# Add mesh fragment shader variants with different temporary voxel storage techniques 
addMeshFragmentVoxelizationVariants(){  
  addMeshFragmentVoxelizationAlphaVariants "$1" "$2" 
}  

# Add mesh fragment shader variants with different pass targets
addMeshFragmentPassTargetVariants(){
  
  # Depth only stuff
  addMeshFragmentDepthOnlyVariants "${1}_depth" "$2 -DDEPTHONLY"  

  # -DFRUSTUMCLUSTERGRID -DLIGHTCLUSTERS

  # The reflective shadow map stuff
  addMeshFragmentReflectiveShadowMapVariants "${1}_rsm" "$2 -DDECALS -DLIGHTS -DSHADOWS -DREFLECTIVESHADOWMAPOUTPUT"  

  # The voxelization stuff
  addMeshFragmentVoxelizationVariants "${1}_voxelization" "$2 -DVOXELIZATION"  

  # The actual shading stuff
  addMeshFragmentShadingGlobalIlluminationVariants "${1}_shading" "$2 -DDECALS -DLIGHTS -DSHADOWS"  
    
  # The environment map stuff
  #addMeshFragmentShadingGlobalIlluminationVariants "${1}_envmap" "$2 -DDECALS -DLIGHTS -DSHADOWS -DENVMAP"

}

# Add mesh fragment shader variants with different Z direction
addMeshFragmentZVariants(){

  # Normal Z direction
  addMeshFragmentPassTargetVariants "${1}" "$2"

  # Reversed Z direction
  addMeshFragmentPassTargetVariants "${1}_reversedz" "$2 -DREVERSEDZ"

}

# Add mesh fragment shader variants with different material source
addMeshFragmentMaterialSourceVariants(){
  
  # Material access per SSBO => the old-school way for older GPUs
  addMeshFragmentZVariants "${1}_matssbo" "$2 -DUSE_MATERIAL_SSBO"

  # Material access per buffer references (pointer-like raw access inside shaders) => the more modern way for newer GPUs
  addMeshFragmentZVariants "${1}_matbufref" "$2 -DUSE_MATERIAL_BUFFER_REFERENCE"

  # Material access per buffer references (pointer-like raw access inside shaders) => the more modern way for newer GPUs
  # with raytracing support
  addMeshFragmentZVariants "${1}_matbufref_raytracing" "$2 -DUSE_MATERIAL_BUFFER_REFERENCE -DRAYTRACING"

} 

addMeshFragmentMaterialSourceVariants "mesh" ""

#############################################
#              Resource files               #
#############################################

cp -f "${originalDirectory}/bluenoise_1024x1024_rgba8.raw" "${tempPath}/bluenoise_1024x1024_rgba8.raw" || exit 1

cp -f "${originalDirectory}/rain_512.raw" "${tempPath}/rain_512.raw" || exit 1

cp -f "${originalDirectory}/rain_normal_512.raw" "${tempPath}/rain_normal_512.raw" || exit 1

cp -f "${originalDirectory}/rain_streaks_normal_512.raw" "${tempPath}/rain_streaks_normal_512.raw" || exit 1

#############################################
#   Deduplication code for shader binaries  # 
#############################################

deduplicate_spv_files() {

  # Go to the temporary directory
  cd "${tempPath}"

  # Initialize an associative array to store checksums
  declare -A checksums

  # Create a new virtualsymlinks.json
  echo -n "{" > "${tempPath}/virtualsymlinks.json"

  # Flag to check if this is the first entry in the virtualsymlinks.json
  is_first_entry=1

  # Iterate over each *.spv file
  for file in *.spv; do

    # Calculate the SHA256 checksum for the file
    checksum=$(sha256sum "$file" | awk '{print $1}')

    # Check if this checksum is already in the array
    if [[ -z "${checksums[$checksum]}" ]]; then

      # If not, store the filename with this checksum
      checksums[$checksum]="$file"

    else

      # If the checksum matches, do a byte-for-byte comparison using cmp, for safety in case of hash collisions
      if cmp -s "$file" "${checksums[$checksum]}"; then

        # Add "," to the virtualsymlinks.json if not the first entry
        if [ $is_first_entry -eq 0 ]; then
          echo -n "," >> "${tempPath}/virtualsymlinks.json"
        else
          is_first_entry=0 
        fi
        
        # Escape special JSON characters in filenames (basic version, might need enhancement based on filename specifics)
        json_key=$(echo "$file" | sed 's/"/\\"/g')
        json_value=$(echo "${checksums[$checksum]}" | sed 's/"/\\"/g')

        # Files are identical, so we consider $file as a duplicate and add a virtual symlink to the original file for the PasVulkan Scene3D asset manager
        echo -n "\"$json_key\":\"$json_value\"" >> "${tempPath}/virtualsymlinks.json"

        # Delete the duplicate file
        rm "$file"
      
      fi
    fi
  done

  # Finish the virtualsymlinks.json
  echo -n "}" >> "${tempPath}/virtualsymlinks.json"

  # Go back to the original directory
  cd "${originalDirectory}"

}

# Wait until there are less than $1 jobs running in parallel
function pwait() {
  if [ ${bashVersionEqualOrGreaterThan4_1} -eq 1 ]; then
    if [ $(jobs -p -r | wc -l) -ge $1 ]; then
      wait -n # Wait for any job to finish
    fi
  else  
    while [ $(jobs -p -r | wc -l) -ge $1 ]; do
      sleep 0.01s
    done
  fi
}

# Wait until there are less than the number of logical CPU cores jobs running in parallel
function throttleWait() {
  # If there are more than a CPU core
  if [ ${countCPUCores} -gt 1 ]; then
    # A bit less than the number of logical CPU cores to leave some room for other processes
    pwait $((${countCPUCores}-1)) 
  else
    # If there is only one logical CPU core, wait just for any job to finish
    wait
  fi
}

#############################################
#                Main code                  #
#############################################

glslangValidatorPath=$(which glslangValidator)
spirvOptPath=$(which spirv-opt)

# Use a trap to kill all child processes when an error occurs
trap 'kill 0' ERR

# Compile all shaders

echo "Compiling . . ."

#pids=()

for index in ${!compileshaderarguments[@]}; do
  parameters=${compileshaderarguments[$index]}
  # echo "Processing $parameters . . ."
  (     
    # Add -g to the parameters if DEBUG is set to 1, for to add debug information to the shader binary
    if [ $DEBUG -eq 1 ]; then    
      parameters="-g $parameters"
    fi
    # If -DRAYTRACING is in the parameters, add --target-env vulkan1.2 to the parameters 
    if [[ $parameters == *"-DRAYTRACING"* ]]; then
      # but not for mesh.comp, due to a bug in the NVIDIA driver while GPU-assisted validation is enabled (it crashes the driver then) 
      if [[ $parameters != *"mesh.comp"* ]]; then
        parameters="$parameters --target-env vulkan1.2"
      fi
    fi
    ${glslangValidatorPath} $parameters #--target-env spirv1.5 >/dev/null
    if [ $? -ne 0 ]; then
      echo "Compiling: ${glslangValidatorPath} -g $parameters"
      echo "Error encountered. Stopping compilation."
      kill -s TERM 0
      exit 1
    fi     
  ) & 
  #pids+=("$!")
  throttleWait
done

wait 

# Optimize all shaders

#echo "Optimizing . . ."

#for index in ${!compileshaderarguments[@]}; do
#   (
#     ${spirvOptPath} -O ${compileshaderarguments[$index]} -o ${compileshaderarguments[$index]}.opt
     #>/dev/null
#   ) & 
#done

# Deduplicate possible duplicate shader binaries

deduplicate_spv_files

# Pack all shaders into a zip file

echo "Packing . . ."

#cp -f *.spv ../../../assets/shaders/

rm -f scene3dshaders.zip
rm -f scene3dshaders.spk

cd ../../../

# Build the packscene3dshaders tool if it does not exist
#rm -f packscene3dshaders
if [ ! -f "packscene3dshaders" ]; then
  fpc -Sd -B -gw2 packscene3dshaders.dpr -opackscene3dshaders
fi

# Copy the packscene3dshaders tool to the temporary directory
cp packscene3dshaders "${tempPath}/packscene3dshaders"

# Go to the temporary directory
cd "${tempPath}"

# Get a sorted list of .spv files, bluenoise_1024x1024_rgba8.raw and virtualsymlinks.json without their full paths
toCompressFiles=( $((ls *.spv; echo virtualsymlinks.json; echo bluenoise_1024x1024_rgba8.raw; echo rain_512.raw; echo rain_normal_512.raw; echo rain_streaks_normal_512.raw) | sort) ) # find "${tempPath}" -maxdepth 1 -type f -name "*.c" -printf "%f\n"

if [ $USEZIP -eq 1 ]; then

  # Check if zipmerge is installed
  if command -v zipmerge &> /dev/null; then

    # Create another temporary directory for the intermediate zip files
    zip_temp_dir=$(mktemp -d)
    if [ $? -ne 0 ]; then
      echo "Error creating temporary directory. Stopping compilation."
      exit 1
    fi

    # Parallel compression of each file in toCompressFiles array
    for file in "${toCompressFiles[@]}"; do
      ( 
        zip -9 "${zip_temp_dir}/${file}.zip" "${file}"
      ) &
      throttleWait
    done

    # Wait for all background jobs to complete
    wait

    # Get a sorted list of .zip files in zip_temp_dir with their full paths
    zip_files=( $(find "${zip_temp_dir}" -type f -name "*.zip" | sort) )

    # Create the zip archive using the zip files from zip_temp_dir
    zipmerge "${tempPath}/scene3dshaders.zip" "${zip_files[@]}"

    # Delete the temporary ZIP directory
    rm -rf "${zip_temp_dir}"

  else

    # Create the zip archive with virtualsymlinks.json as the first entry
    zip -m9 scene3dshaders.zip "${toCompressFiles[@]}"

  fi
 
else

  # Write toCompressFiles to a temporary file line-wise
  tempListFile=$(mktemp)
  if [ $? -ne 0 ]; then
    echo "Error creating temporary file. Stopping compilation."
    exit 1
  fi
  for f in "${toCompressFiles[@]}"; do
    echo "${f}" >> "${tempListFile}"
  done

  ./packscene3dshaders "${originalDirectory}/scene3dshaders.spk" "${tempListFile}"

fi

cd "${originalDirectory}"

if [ $USEZIP -eq 1 ]; then

  # Delete the old zip archive if it exists
  if [ -f "${originalDirectory}/scene3dshaders.zip" ]; then
    rm -f "${originalDirectory}/scene3dshaders.zip"
  fi

  # Copy the zip archive to the current directory
  cp -f "${tempPath}/scene3dshaders.zip" "${originalDirectory}/scene3dshaders.zip"

fi

if [ $USEBIN2C -eq 1 ]; then

  # Compile bin2c
  clang ./bin2c.c -o "${tempPath}/bin2c"

  if [ $USEZIP -eq 1 ]; then

    # ZIP code path

    # Convert the zip archive to a C header file
    "$tempPath/bin2c" scene3dshaders.zip pasvulkan_scene3dshaders_zip "${tempPath}/scene3dshaders_zip.c"

    # Compile the C header file for all platforms in parallel

    # Compile for x86-32 Linux
    clang -c -target i386-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_32_linux.o &
    throttleWait

    # Compile for x86-64 Linux
    clang -c -target x86_64-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_64_linux.o & 
    throttleWait

    # Compile for x86-32 Windows
    clang -c -target i386-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_32_windows.o &
    throttleWait

    # Compile for x86-64 Windows
    clang -c -target x86_64-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_64_windows.o &
    throttleWait

    # Compile for AArch64 Windows
    clang -c -target aarch64-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_aarch64_windows.o &
    throttleWait

    # Compile for ARM32 Linux
    clang -c -target armv7-linux -mfloat-abi=hard -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_arm32_linux.o &
    throttleWait

    # Compile for AArch64 Linux
    clang -c -target aarch64-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_aarch64_linux.o &
    throttleWait

    # Compile for x86-32 Android
    clang -c -target i386-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_32_android.o &
    throttleWait

    # Compile for x86-64 Android
    clang -c -target x86_64-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_x86_64_android.o &
    throttleWait

    # Compile for ARM32 Android
    clang -c -target armv7-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_arm32_android.o &
    throttleWait

    # Compile for AArch64 Android
    clang -c -target aarch64-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_zip.c" -o scene3dshaders_zip_aarch64_android.o &
    throttleWait

  else

    # SPK code path

    # Convert the spk archive to a C header file
    "$tempPath/bin2c" scene3dshaders.spk pasvulkan_scene3dshaders_spk "${tempPath}/scene3dshaders_spk.c"

    # Compile the C header file for all platforms in parallel

    # Compile for x86-32 Linux
    clang -c -target i386-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_32_linux.o &
    throttleWait

    # Compile for x86-64 Linux
    clang -c -target x86_64-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_64_linux.o & 
    throttleWait

    # Compile for x86-32 Windows
    clang -c -target i386-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_32_windows.o &
    throttleWait

    # Compile for x86-64 Windows
    clang -c -target x86_64-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_64_windows.o &
    throttleWait

    # Compile for AArch64 Windows
    clang -c -target aarch64-windows -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_aarch64_windows.o &
    throttleWait

    # Compile for ARM32 Linux
    clang -c -target armv7-linux -mfloat-abi=hard -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_arm32_linux.o &
    throttleWait

    # Compile for AArch64 Linux
    clang -c -target aarch64-linux -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_aarch64_linux.o &
    throttleWait

    # Compile for x86-32 Android
    clang -c -target i386-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_32_android.o &
    throttleWait

    # Compile for x86-64 Android
    clang -c -target x86_64-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_x86_64_android.o &
    throttleWait

    # Compile for ARM32 Android
    clang -c -target armv7-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_arm32_android.o &
    throttleWait

    # Compile for AArch64 Android
    clang -c -target aarch64-linux-android -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O0 "${tempPath}/scene3dshaders_spk.c" -o scene3dshaders_spk_aarch64_android.o &
    throttleWait
    
  fi  

  # Wait for all compilation jobs to finish
  wait

else

  # If the bin2c tool is not used, just compile the scene3dshaders.spk as windows resource file with scene3dshaders.rc as the resource script.
  # This is the default case now, for all the platforms, not only for Windows. Since Free Pascal does support the resource files on all
  # unix-like platforms as well, it is better to use this method for all platforms for to reduce the disk space usage of unnecessary .o files.

  # Compiling .res file
  windres -J rc -O res scene3dshaders.rc scene3dshaders.res

fi
 
# Delete the temporary directory
if [ $DELETEAFTERCOMPILE -eq 1 ]; then
  echo "Deleting temporary directory ${tempPath} . . ."
  rm -rf "${tempPath}" # what actually deletes also thefiles in it
else
  echo "Temporary directory ${tempPath} is not deleted, because DELETEAFTERCOMPILE is set to 0."
fi

# Done!

echo "Done!"

# And exit!

exit 0

# That's all!