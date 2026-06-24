## 1. PasCube Screen Setup and Fields

- [x] 1.1 Add fRenderWidth, fRenderHeight, and fGPU360pFallback fields to TPasCubeScreen class in UnitPasCubeScreen.pas.
- [x] 1.2 Initialize fRenderWidth to 1920, fRenderHeight to 1080, and fGPU360pFallback to false in TPasCubeScreen constructor or initialization block.
- [x] 1.3 Configure fVulkanGraphicsPipeline and fSkyGraphicsPipeline to support dynamic viewport and scissor states at creation time in UnitPasCubeScreen.pas.

## 2. Dynamic Viewport and Blit Scaling

- [x] 2.1 Invoke CmdSetViewport and CmdSetScissor dynamically during command buffer recording in TPasCubeScreen.Draw.
- [x] 2.2 Update the swapchain blit call in UnitTextOverlay.pas to dynamically reference the screen's fRenderWidth and fRenderHeight fields.

## 3. Fallback Trigger and Score Adjustment

- [x] 3.1 Implement the FPS check at the end of the first GPU iteration in NextPhase. If average FPS is below 10, set fGPU360pFallback to true, update render size to 640x360, and reset the phase iteration.
- [x] 3.2 Adjust the final score and FPS calculation in CalculateScore by dividing by a scaling factor (e.g. 5.0) if fGPU360pFallback is active.

## 4. Verification

- [x] 4.1 Compile the codebase and verify the pascube binary builds successfully.
- [x] 4.2 Verify the fallback functionality works by testing under low FPS conditions (e.g. forcing software rendering or artificially throttling).
