unit UnitScreenExampleGUI;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

interface

uses SysUtils,
     Classes,
     Math,
     UnitRegisteredExamplesList,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.GUI,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont,
     PasVulkan.TextEditor,
     UnitModel;

type TScreenExampleGUIFillLayoutExampleWindow=class(TpvGUIWindow)
      private
       fGUILabel0:TpvGUILabel;
       fGUILabel1:TpvGUILabel;
       fGUIPopupMenuButton0:TpvGUIPopupMenuButton;
       fGUIPopupButton0:TpvGUIPopupButton;
       fGUIPopupButton1:TpvGUIPopupButton;
       fGUIPopupButton2:TpvGUIPopupButton;
       fGUIPopupButton3:TpvGUIPopupButton;
       fGUIScrollBar0:TpvGUIScrollBar;
       fGUISlider0:TpvGUISlider;
       fGUIProgressBar0:TpvGUIProgressBar;
       fGUIScrollBar1:TpvGUIScrollBar;
       fGUISlider1:TpvGUISlider;
       fGUIProgressBar1:TpvGUIProgressBar;
       fGUIListBox0:TpvGUIListBox;
       fGUIComboBox0:TpvGUIComboBox;
       fTime:TpvDouble;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
       procedure Update; override;
     end;

     TScreenExampleGUITabPanelExampleWindow=class(TpvGUIWindow)
      private
       fTabPanel0:TpvGUITabPanel;
       fPanel0:TpvGUIPanel;
       fButton0:TpvGUIButton;
       fScrollBar0:TpvGUIScrollBar;
       fPanel1:TpvGUIPanel;
       fButton1:TpvGUIButton;
       fPanel2:TpvGUIPanel;
       fScrollPanel0:TpvGUIScrollPanel;
       fToggleButton0:TpvGUIToggleButton;
       fPanel3:TpvGUIPanel;
       fSplitterPanel0:TpvGUISplitterPanel;
       fSplitterPanel1:TpvGUISplitterPanel;
       fPanel4:TpvGUIPanel;
       fScrollPanel1:TpvGUIScrollPanel;
       fToggleButton1:TpvGUIToggleButton;
       fPanel5:TpvGUIPanel;
       fButton2:TpvGUIButton;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TScreenExampleGUIMultiLineTextEditWindow=class(TpvGUIWindow)
      private
       fMultiLineTextEdit0:TpvGUIMultiLineTextEdit;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TpvGUIVulkanCanvasCube=class(TpvGUIVulkanCanvas)
      private
       type TScreenExampleCubeUniformBuffer=record
             ModelViewProjectionMatrix:TpvMatrix4x4;
             ModelViewNormalMatrix:TpvMatrix4x4; // actually TpvMatrix3x3, but it would have then a TMatrix3x4 alignment, according to https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#interfaces-resources-layout
            end;
            PScreenExampleCubeUniformBuffer=^TScreenExampleCubeUniformBuffer;
            TScreenExampleCubeState=record
             Time:TpvDouble;
             AnglePhases:array[0..1] of TpvFloat;
            end;
            PScreenExampleCubeState=^TScreenExampleCubeState;
            TScreenExampleCubeStates=array[0..MaxInFlightFrames-1] of TScreenExampleCubeState;
            PScreenExampleCubeStates=^TScreenExampleCubeStates;
            TVertex=record
             Position:TpvVector3;
             Tangent:TpvVector3;
             Bitangent:TpvVector3;
             Normal:TpvVector3;
             TexCoord:TpvVector2;
            end;
            PVertex=^TVertex;
       const CubeVertices:array[0..23] of TVertex=
              (// Left
               (Position:(x:-1;y:-1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:0)),
               (Position:(x:-1;y: 1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:1)),
               (Position:(x:-1;y: 1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:1)),
               (Position:(x:-1;y:-1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:0)),

               // Right
               (Position:(x: 1;y:-1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:0)),
               (Position:(x: 1;y: 1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:1)),
               (Position:(x: 1;y: 1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:1)),
               (Position:(x: 1;y:-1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:0)),

               // Bottom
               (Position:(x:-1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:0)),
               (Position:(x:-1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:1)),
               (Position:(x: 1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:1)),
               (Position:(x: 1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:0)),

               // Top
               (Position:(x:-1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:0)),
               (Position:(x: 1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:1)),
               (Position:(x: 1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:1)),
               (Position:(x:-1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:0)),

               // Back
               (Position:(x: 1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:0)),
               (Position:(x: 1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:1)),
               (Position:(x:-1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:1)),
               (Position:(x:-1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:0)),

               // Front
               (Position:(x:-1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:0)),
               (Position:(x:-1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:1)),
               (Position:(x: 1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:1)),
               (Position:(x: 1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:0))

              );
             CubeIndices:array[0..35] of TpvInt32=
              ( // Left
                0, 1, 2,
                0, 2, 3,

                // Right
                4, 5, 6,
                4, 6, 7,

                // Bottom
                8, 9, 10,
                8, 10, 11,

                // Top
                12, 13, 14,
                12, 14, 15,

                // Back
                16, 17, 18,
                16, 18, 19,

                // Front
                20, 21, 22,
                20, 22, 23);
             Offsets:array[0..0] of TVkDeviceSize=(0);
      private
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fCubeVertexShaderModule:TpvVulkanShaderModule;
       fCubeFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCubeVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageCubeFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanVertexBuffer:TpvVulkanBuffer;
       fVulkanIndexBuffer:TpvVulkanBuffer;
       fVulkanUniformBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanCommandPool:TpvVulkanCommandPool;
//     fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fUniformBuffer:TScreenExampleCubeUniformBuffer;
       fBoxAlbedoTexture:TpvVulkanTexture;
       fState:TScreenExampleCubeState;
       fStates:TScreenExampleCubeStates;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update; override;
       procedure UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
       procedure DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
     end;

     TScreenExampleGUICube=class(TpvGUIWindow)
      private
       fVulkanCanvasCube:TpvGUIVulkanCanvasCube;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TpvGUIVulkanCanvasDragon=class(TpvGUIVulkanCanvas)
      private
       type TScreenExampleDragonUniformBuffer=record
             ModelViewMatrix:TpvMatrix4x4;
             ModelViewProjectionMatrix:TpvMatrix4x4;
             ModelViewNormalMatrix:TpvMatrix4x4; // actually TpvMatrix3x3, but it would have then a TMatrix3x4 alignment, according to https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#interfaces-resources-layout
            end;
            PScreenExampleDragonUniformBuffer=^TScreenExampleDragonUniformBuffer;
            TScreenExampleDragonState=record
             Time:TpvDouble;
             AnglePhases:array[0..1] of TpvFloat;
            end;
            PScreenExampleDragonState=^TScreenExampleDragonState;
            TScreenExampleDragonStates=array[0..MaxInFlightFrames-1] of TScreenExampleDragonState;
            PScreenExampleDragonStates=^TScreenExampleDragonStates;
       const Offsets:array[0..0] of TVkDeviceSize=(0);
      private
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fDragonVertexShaderModule:TpvVulkanShaderModule;
       fDragonFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageDragonVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDragonFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanModel:TVulkanModel;
       fVulkanUniformBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanCommandPool:TpvVulkanCommandPool;
//     fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fUniformBuffer:TScreenExampleDragonUniformBuffer;
       fBoxAlbedoTexture:TpvVulkanTexture;
       fState:TScreenExampleDragonState;
       fStates:TScreenExampleDragonStates;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update; override;
       procedure UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
       procedure DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
     end;

     TScreenExampleGUIDragon=class(TpvGUIWindow)
      private
       fScrollPanel:TpvGUIScrollPanel;
       fVulkanCanvasDragon:TpvGUIVulkanCanvasDragon;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TScreenExampleGUIColorPicker=class(TpvGUIWindow)
      private
       fBoxLayout:TpvGUIBoxLayout;
       fColorPicker:TpvGUIColorPicker;
       fModePanel:TpvGUIPanel;
       fModePanelLabel:TpvGUILabel;
       fModePanelGroupLayout:TpvGUIGroupLayout;
       fLinearRGBModeRadioCheckBox:TpvGUIRadioCheckBox;
       fSRGBModeRadioCheckBox:TpvGUIRadioCheckBox;
       procedure LinearRGBOrSRGBModeRadioCheckBoxOnChange(const aSender:TpvGUIObject);
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TScreenExampleGUITreeView=class(TpvGUIWindow)
      private
       fFillLayout:TpvGUIFillLayout;
       fTreeView:TpvGUITreeView;
      public
       constructor Create(const aParent:TpvGUIObject); override;
       destructor Destroy; override;
     end;

     TScreenExampleGUI=class(TpvApplicationScreen)
      private
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanCommandPool:TpvVulkanCommandPool;
       fVulkanRenderCommandBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanCommandBuffer;
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
       fVulkanCanvas:TpvCanvas;
       fScreenToCanvasScale:TpvVector2;
       fGUIInstance:TpvGUIInstance;
       fGUIWindow:TpvGUIWindow;
       fGUILabel:TpvGUILabel;
       fGUIButton:TpvGUIButton;
       fGUITextEdit:TpvGUITextEdit;
       fGUIOtherWindow:TpvGUIWindow;
       fGUIYetOtherWindow:TpvGUIWindow;
       fLastMousePosition:TpvVector2;
       fLastMouseButtons:TpvApplicationInputPointerButtons;
       fReady:boolean;
       fSelectedIndex:TpvInt32;
       fStartY:TpvFloat;
       fTime:TpvDouble;
       procedure Button0OnClick(const aSender:TpvGUIObject);
      public

       constructor Create; override;

       destructor Destroy; override;

       procedure Show; override;

       procedure Hide; override;

       procedure Resume; override;

       procedure Pause; override;

       procedure Resize(const aWidth,aHeight:TpvInt32); override;

       procedure AfterCreateSwapChain; override;

       procedure BeforeDestroySwapChain; override;

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;

       function CanBeParallelProcessed:boolean; override;

       procedure Check(const aDeltaTime:TpvDouble); override;

       procedure Update(const aDeltaTime:TpvDouble); override;

       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;

     end;

implementation

uses UnitApplication,UnitTextOverlay,UnitScreenMainMenu;

const FontSize=3.0;

constructor TScreenExampleGUIFillLayoutExampleWindow.Create(const aParent:TpvGUIObject);
var MenuItem:TpvGUIMenuItem;
    PopupMenu:TpvGUIPopupMenu;
begin
 inherited Create(aParent);

 Left:=750;
 Top:=200;
 Title:='Window with FlowLayout';
//Content.Layout:=TpvGUIBoxLayout.Create(Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,8.0);
 Content.Layout:=TpvGUIFlowLayout.Create(Content,
                                         TpvGUILayoutOrientation.Horizontal,
                                         8.0,
                                         300.0,
                                         0.0,
                                         4.0,
                                         4.0,
                                         TpvGUIFlowLayoutDirection.LeftToRight,
                                         TpvGUIFlowLayoutAlignment.Middle,
                                         TpvGUIFlowLayoutAlignment.Middle,
                                         true);
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 fGUILabel0:=TpvGUILabel.Create(Content);
 fGUILabel0.Caption:='An other example label';
 fGUILabel0.Cursor:=TpvGUICursor.Busy;

 fGUILabel1:=TpvGUILabel.Create(Content);
 fGUILabel1.Caption:='An another example label';
 fGUILabel1.Cursor:=TpvGUICursor.Unavailable;

 fGUIPopupMenuButton0:=TpvGUIPopupMenuButton.Create(Content);
 fGUIPopupMenuButton0.Caption:='Popup menu';
 fGUIPopupMenuButton0.Enabled:=true;
 TpvGUIMenuItem.Create(fGUIPopupMenuButton0.PopupMenu).Caption:='Test 1';
 MenuItem:=TpvGUIMenuItem.Create(fGUIPopupMenuButton0.PopupMenu);
 MenuItem.Caption:='Test 2';
 PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
 TpvGUIMenuItem.Create(PopupMenu).Caption:='Test A';
 TpvGUIMenuItem.Create(PopupMenu).Caption:='Test B';
 MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
 MenuItem.Caption:='Test C';
 PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
 TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 1';
 TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 2';
 TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 3';
 TpvGUIMenuItem.Create(fGUIPopupMenuButton0.PopupMenu).Caption:='Test 3';

 fGUIPopupButton0:=TpvGUIPopupButton.Create(Content);
 fGUIPopupButton0.Caption:='Popup';
 fGUIPopupButton0.Enabled:=true;
 fGUIPopupButton0.Popup.AnchorSide:=TpvGUIPopupAnchorSide.Top;

 fGUIPopupButton1:=TpvGUIPopupButton.Create(Content);
 fGUIPopupButton1.Caption:='Popup';
 fGUIPopupButton1.Enabled:=true;
 fGUIPopupButton1.Popup.AnchorSide:=TpvGUIPopupAnchorSide.Bottom;

 fGUIPopupButton2:=TpvGUIPopupButton.Create(Content);
 fGUIPopupButton2.Caption:='Popup';
 fGUIPopupButton2.Enabled:=true;
 fGUIPopupButton2.Popup.AnchorSide:=TpvGUIPopupAnchorSide.Left;

 fGUIPopupButton3:=TpvGUIPopupButton.Create(Content);
 fGUIPopupButton3.Caption:='Popup';
 fGUIPopupButton3.Enabled:=true;
 fGUIPopupButton3.Popup.AnchorSide:=TpvGUIPopupAnchorSide.Right;

 fGUIScrollBar0:=TpvGUIScrollBar.Create(Content);
 fGUIScrollBar0.Orientation:=TpvGUIScrollBarOrientation.Horizontal;
 fGUIScrollBar0.MinimumValue:=0;
 fGUIScrollBar0.MaximumValue:=100;
 fGUIScrollBar0.ThumbButtonSize:=24.0;
 fGUIScrollBar0.FixedWidth:=256.0;

 fGUISlider0:=TpvGUISlider.Create(Content);
 fGUISlider0.Orientation:=TpvGUISliderOrientation.Horizontal;
 fGUISlider0.FixedWidth:=256.0;

 fGUIProgressBar0:=TpvGUIProgressBar.Create(Content);
 fGUIProgressBar0.Orientation:=TpvGUIProgressBarOrientation.Horizontal;
 fGUIProgressBar0.MinimumValue:=0;
 fGUIProgressBar0.MaximumValue:=100;
 fGUIProgressBar0.Value:=75;
 fGUIProgressBar0.FixedWidth:=256.0;

 fGUIScrollBar1:=TpvGUIScrollBar.Create(Content);
 fGUIScrollBar1.Orientation:=TpvGUIScrollBarOrientation.Vertical;
 //fGUIScrollBar1.SliderButtonSize:=24.0;
 fGUIScrollBar1.MaximumValue:=2;
 fGUIScrollBar1.FixedHeight:=128.0;

 fGUISlider1:=TpvGUISlider.Create(Content);
 fGUISlider1.Orientation:=TpvGUISliderOrientation.Vertical;
 fGUISlider1.FixedHeight:=128.0;

 fGUIProgressBar1:=TpvGUIProgressBar.Create(Content);
 fGUIProgressBar1.Orientation:=TpvGUIProgressBarOrientation.Vertical;
 fGUIProgressBar1.MinimumValue:=0;
 fGUIProgressBar1.MaximumValue:=100;
 fGUIProgressBar1.Value:=25;
 fGUIProgressBar1.FixedHeight:=64.0;

 fGUIListBox0:=TpvGUIListBox.Create(Content);
 fGUIListBox0.MultiSelect:=true;
 fGUIListBox0.Items.Add('Item 1');
 fGUIListBox0.Items.Add('Item 2');
 fGUIListBox0.Items.Add('Item 3');
 fGUIListBox0.Items.Add('Item 4');
 fGUIListBox0.Items.Add('Item 5');
 fGUIListBox0.Items.Add('Item 6');
 fGUIListBox0.Items.Add('Item 7');
 fGUIListBox0.Items.Add('Item 8');
 fGUIListBox0.Items.Add('Item 9');
 fGUIListBox0.Items.Add('Item 10');

 fGUIComboBox0:=TpvGUIComboBox.Create(Content);
 fGUIComboBox0.Items.Add('Item 1');
 fGUIComboBox0.Items.Add('Item 2');
 fGUIComboBox0.Items.Add('Item 3');
 fGUIComboBox0.Items.Add('Item 4');
 fGUIComboBox0.Items.Add('Item 5');
 fGUIComboBox0.Items.Add('Item 6');
 fGUIComboBox0.Items.Add('Item 7');
 fGUIComboBox0.Items.Add('Item 8');
 fGUIComboBox0.Items.Add('Item 9');
 fGUIComboBox0.Items.Add('Item 10');
 fGUIComboBox0.ItemIndex:=0;

 fTime:=0.0;

end;

destructor TScreenExampleGUIFillLayoutExampleWindow.Destroy;
begin
 inherited Destroy;
end;

procedure TScreenExampleGUIFillLayoutExampleWindow.Update;
begin

 fGUIProgressBar0.Value:=round(fGUIProgressBar0.MinimumValue+((fGUIProgressBar0.MaximumValue-fGUIProgressBar0.MinimumValue)*frac(fTime)));

 fGUIProgressBar1.Value:=round(fGUIProgressBar1.MinimumValue+((fGUIProgressBar1.MaximumValue-fGUIProgressBar1.MinimumValue)*frac(fTime)));

 fTime:=fTime+Instance.DeltaTime;

 inherited Update;

end;

constructor TScreenExampleGUITabPanelExampleWindow.Create(const aParent:TpvGUIObject);
var MenuItem:TpvGUIMenuItem;
    PopupMenu:TpvGUIPopupMenu;
begin

 inherited Create(aParent);

 Left:=450;
 Top:=200;
 Title:='Window with TabPanel';
 Content.Layout:=TpvGUIFillLayout.Create(Content,4.0);
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 fTabPanel0:=TpvGUITabPanel.Create(Window.Content);

 begin

  fPanel0:=TpvGUIPanel.Create(fTabPanel0.Content);
  fPanel0.Layout:=TpvGUIFlowLayout.Create(fPanel0,
                                          TpvGUILayoutOrientation.Horizontal,
                                          8.0,
                                          300.0,
                                          0.0,
                                          4.0,
                                          4.0,
                                          TpvGUIFlowLayoutDirection.LeftToRight,
                                          TpvGUIFlowLayoutAlignment.Middle,
                                          TpvGUIFlowLayoutAlignment.Middle,
                                          true);
  fTabPanel0.Tabs.Add('A tab').Content:=fPanel0;

  fButton0:=TpvGUIButton.Create(fPanel0);
  fButton0.Caption:='Button';
  fButton0.Enabled:=true;

  fScrollBar0:=TpvGUIScrollBar.Create(fPanel0);
  fScrollBar0.Enabled:=true;

 end;

 begin

  fPanel1:=TpvGUIPanel.Create(fTabPanel0.Content);
  fPanel1.Layout:=TpvGUIFlowLayout.Create(fPanel1,
                                          TpvGUILayoutOrientation.Horizontal,
                                          8.0,
                                          300.0,
                                          0.0,
                                          4.0,
                                          4.0,
                                          TpvGUIFlowLayoutDirection.LeftToRight,
                                          TpvGUIFlowLayoutAlignment.Leading,
                                          TpvGUIFlowLayoutAlignment.Leading,
                                          true);
  fTabPanel0.Tabs.Add('An another tab').Content:=fPanel1;

  fButton1:=TpvGUIPopupMenuButton.Create(fPanel1);
  fButton1.Caption:='Popup menu';
  fButton1.Enabled:=true;
  TpvGUIMenuItem.Create(TpvGUIPopupMenuButton(fButton1).PopupMenu).Caption:='Test 1';
  MenuItem:=TpvGUIMenuItem.Create(TpvGUIPopupMenuButton(fButton1).PopupMenu);
  MenuItem.Caption:='Test 2';
  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  TpvGUIMenuItem.Create(PopupMenu).Caption:='Test A';
  TpvGUIMenuItem.Create(PopupMenu).Caption:='Test B';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Test C';
  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 1';
  TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 2';
  TpvGUIMenuItem.Create(PopupMenu).Caption:='Test 3';
  TpvGUIMenuItem.Create(TpvGUIPopupMenuButton(fButton1).PopupMenu).Caption:='Test 3';

 end;

 begin

  fPanel2:=TpvGUIPanel.Create(fTabPanel0.Content);
  fPanel2.Layout:=TpvGUIFillLayout.Create(fPanel0,0.0);
  fTabPanel0.Tabs.Add('An yet another tab').Content:=fPanel2;

  fScrollPanel0:=TpvGUIScrollPanel.Create(fPanel2);
  fScrollPanel0.Content.Layout:=TpvGUIBoxLayout.Create(fScrollPanel0.Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,8.0);

  fToggleButton0:=TpvGUIToggleButton.Create(fScrollPanel0.Content);
  fToggleButton0.Caption:='Toggle button';
  fToggleButton0.FixedWidth:=480;
  fToggleButton0.FixedHeight:=240;

 end;

 begin

  fPanel3:=TpvGUIPanel.Create(fTabPanel0.Content);
  fPanel3.Layout:=TpvGUIFillLayout.Create(fPanel3,4.0);
  fTabPanel0.Tabs.Add('An also yet another tab').Content:=fPanel3;

  fSplitterPanel0:=TpvGUISplitterPanel.Create(fPanel3);
  fSplitterPanel0.Orientation:=TpvGUISplitterPanelOrientation.Horizontal;

  fSplitterPanel0.LeftTopPanel.Background:=true;

  fSplitterPanel0.RightBottomPanel.Background:=false;

  fSplitterPanel0.RightBottomPanel.Layout:=TpvGUIFillLayout.Create(fSplitterPanel0.RightBottomPanel,0.0);

  fSplitterPanel1:=TpvGUISplitterPanel.Create(fSplitterPanel0.RightBottomPanel);
  fSplitterPanel1.Orientation:=TpvGUISplitterPanelOrientation.Vertical;

  fSplitterPanel1.LeftTopPanel.Background:=true;

  fSplitterPanel1.LeftTopPanel.Layout:=TpvGUIFillLayout.Create(fSplitterPanel1.LeftTopPanel,4.0);

  fPanel4:=TpvGUIPanel.Create(fSplitterPanel1.LeftTopPanel);

  fPanel4.Layout:=TpvGUIFillLayout.Create(fPanel4,0.0);

  fScrollPanel1:=TpvGUIScrollPanel.Create(fPanel4);
  fScrollPanel1.Content.Layout:=TpvGUIBoxLayout.Create(fScrollPanel1.Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,4.0);

  fToggleButton1:=TpvGUIToggleButton.Create(fScrollPanel1.Content);
  fToggleButton1.Caption:='Toggle button';
  fToggleButton1.FixedWidth:=320;
  fToggleButton1.FixedHeight:=180;

  fSplitterPanel1.RightBottomPanel.Background:=true;

  fSplitterPanel1.RightBottomPanel.Layout:=TpvGUIFillLayout.Create(fSplitterPanel1.RightBottomPanel,4.0);

  fPanel5:=TpvGUIPanel.Create(fSplitterPanel1.RightBottomPanel);

  fPanel5.Layout:=TpvGUIBoxLayout.Create(fPanel5,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,0.0);

  fButton2:=TpvGUIButton.Create(fPanel5);
  fButton2.Caption:='Button';
  fButton2.FixedWidth:=160;
  fButton2.FixedHeight:=90;
  fButton2.Enabled:=true;

 end;

 fTabPanel0.TabIndex:=0;

end;

destructor TScreenExampleGUITabPanelExampleWindow.Destroy;
begin
 inherited Destroy;
end;

constructor TScreenExampleGUIMultiLineTextEditWindow.Create(const aParent:TpvGUIObject);
const NewLine=#13#10;
begin

 inherited Create(aParent);

 Left:=250;
 Top:=200;
 Title:='Window with MultiLineTextEdit';
 Content.Layout:=TpvGUIFillLayout.Create(Content,4.0);
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 AutoSize:=false;

 Width:=550;
 Height:=350;

 fMultiLineTextEdit0:=TpvGUIMultiLineTextEdit.Create(Content);

 fMultiLineTextEdit0.TextEditor.SyntaxHighlighting:=TpvTextEditor.TSyntaxHighlighting.GetSyntaxHighlightingClassByFileExtension('.pas').Create(fMultiLineTextEdit0.TextEditor);

 fMultiLineTextEdit0.TextEditor.TabWidth:=2;

 fMultiLineTextEdit0.LineWrap:=false;

 fMultiLineTextEdit0.Text:='program Test;'+NewLine+
                           '{$ifdef fpc}'+NewLine+
                           #9'{$mode delphi}'+NewLine+
                           '{$endif}'+NewLine+
                           'var'+NewLine+
                           #9'a: integer; // A comment'+NewLine+
                           #9'b: integer; { An another comment }'+NewLine+
                           #9'c: single;  (* An yet another comment *)'+NewLine+
                           'begin'+NewLine+
                           #9'a := 1;'+NewLine+
                           #9'b := 3;'+NewLine+
                           #9'c := 4.0e+0;'+NewLine+
                           #9'if ((a + b) = c) and true then'+NewLine+
                           #9'begin'+NewLine+
                           #9#9'WriteLn(''Yay!''#$20''1 + 3 is 4 (hopefully)'');'+NewLine+
                           #9'end;'+NewLine+
                           'end.';

 fMultiLineTextEdit0.TextEditor.DetectEndOfLineMode;

end;

destructor TScreenExampleGUIMultiLineTextEditWindow.Destroy;
begin
 inherited Destroy;
end;

constructor TpvGUIVulkanCanvasCube.Create(const aParent:TpvGUIObject);
var Index:TpvInt32;
    Stream:TStream;
begin

 inherited Create(aParent);

 fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanGraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanGraphicsCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanTransferCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.TransferQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanTransferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                 pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                 TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 Stream:=pvApplication.Assets.GetAssetStream('shaders/cube/cube_vert.spv');
 try
  fCubeVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvApplication.Assets.GetAssetStream('shaders/cube/cube_frag.spv');
 try
  fCubeFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fBoxAlbedoTexture:=TpvVulkanTexture.CreateDefault(pvApplication.VulkanDevice,
                                                   pvApplication.VulkanDevice.GraphicsQueue,
                                                   fVulkanGraphicsCommandBuffer,
                                                   fVulkanGraphicsCommandBufferFence,
                                                   pvApplication.VulkanDevice.TransferQueue,
                                                   fVulkanTransferCommandBuffer,
                                                   fVulkanTransferCommandBufferFence,
                                                   TpvVulkanTextureDefaultType.Checkerboard,
                                                   512,
                                                   512,
                                                   0,
                                                   0,
                                                   1,
                                                   true,
                                                   true,
                                                   true);{}

 fBoxAlbedoTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToEdge;
 fBoxAlbedoTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToEdge;
 fBoxAlbedoTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
 fBoxAlbedoTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
 fBoxAlbedoTexture.UpdateSampler;

 fVulkanPipelineShaderStageCubeVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fCubeVertexShaderModule,'main');

 fVulkanPipelineShaderStageCubeFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fCubeFragmentShaderModule,'main');

 fVulkanGraphicsPipeline:=nil;

 fVulkanVertexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                             SizeOf(CubeVertices),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
 fVulkanVertexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                fVulkanTransferCommandBuffer,
                                fVulkanTransferCommandBufferFence,
                                CubeVertices,
                                0,
                                SizeOf(CubeVertices),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 fVulkanIndexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                            SizeOf(CubeIndices),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                           );
 fVulkanIndexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence,
                               CubeIndices,
                               0,
                               SizeOf(CubeIndices),
                               TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanUniformBuffers[Index]:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                                       SizeOf(TScreenExampleCubeUniformBuffer),
                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                       [],
                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       [TpvVulkanBufferFlag.PersistentMapped]
                                                      );
  fVulkanUniformBuffers[Index].UploadData(pvApplication.VulkanDevice.TransferQueue,
                                          fVulkanTransferCommandBuffer,
                                          fVulkanTransferCommandBufferFence,
                                          fUniformBuffer,
                                          0,
                                          SizeOf(TScreenExampleCubeUniformBuffer),
                                          TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);
 end;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       MaxInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,MaxInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,MaxInFlightFrames);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                              fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                    [],
                                                    [fVulkanUniformBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false
                                                   );
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(1,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                    [fBoxAlbedoTexture.DescriptorImageInfo],
                                                    [],
                                                    [],
                                                    false
                                                   );
  fVulkanDescriptorSets[Index].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;

end;

destructor TpvGUIVulkanCanvasCube.Destroy;
var Index:TpvInt32;
begin
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanUniformBuffers[Index]);
 end;
 FreeAndNil(fVulkanIndexBuffer);
 FreeAndNil(fVulkanVertexBuffer);
 FreeAndNil(fVulkanGraphicsPipeline);
 FreeAndNil(fVulkanPipelineShaderStageCubeVertex);
 FreeAndNil(fVulkanPipelineShaderStageCubeFragment);
 FreeAndNil(fCubeFragmentShaderModule);
 FreeAndNil(fCubeVertexShaderModule);
 FreeAndNil(fBoxAlbedoTexture);
 for Index:=0 to MaxInFlightFrames-1 do begin
// FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  FreeAndNil(fVulkanRenderSemaphores[Index]);
 end;
 FreeAndNil(fVulkanCommandPool);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 FreeAndNil(fVulkanTransferCommandPool);
 FreeAndNil(fVulkanGraphicsCommandBufferFence);
 FreeAndNil(fVulkanGraphicsCommandBuffer);
 FreeAndNil(fVulkanGraphicsCommandPool);
 inherited Destroy;
end;

procedure TpvGUIVulkanCanvasCube.AcquireVolatileResources;
begin

 inherited AcquireVolatileResources;

 FreeAndNil(fVulkanGraphicsPipeline);

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                           pvApplication.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanPipelineLayout,
                                                           Instance.VulkanRenderPass,
                                                           0,
                                                           nil,
                                                           0);

 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageCubeVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageCubeFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TVertex),VK_VERTEX_INPUT_RATE_VERTEX);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Position)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Tangent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Bitangent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Normal)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(4,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.TexCoord)));

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.DynamicViewPorts:=true;

 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);
 fVulkanGraphicsPipeline.ViewPortState.DynamicScissors:=true;

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
 fVulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
 fVulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

 fVulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
 fVulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.DynamicState.AddDynamicStates([VK_DYNAMIC_STATE_VIEWPORT,
                                                        VK_DYNAMIC_STATE_SCISSOR]);

 fVulkanGraphicsPipeline.Initialize;

 fVulkanGraphicsPipeline.FreeMemory;

end;

procedure TpvGUIVulkanCanvasCube.ReleaseVolatileResources;
begin
 FreeAndNil(fVulkanGraphicsPipeline);
 inherited ReleaseVolatileResources;
end;

procedure TpvGUIVulkanCanvasCube.Update;
const f0=1.0/(2.0*pi);
      f1=0.5/(2.0*pi);
begin
 fState.Time:=fState.Time+Instance.DeltaTime;
 fState.AnglePhases[0]:=frac(fState.AnglePhases[0]+(Instance.DeltaTime*f0));
 fState.AnglePhases[1]:=frac(fState.AnglePhases[1]+(Instance.DeltaTime*f1));
 fStates[pvApplication.UpdateInFlightFrameIndex]:=fState;
 inherited Update;
end;

procedure TpvGUIVulkanCanvasCube.UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
begin
end;

procedure TpvGUIVulkanCanvasCube.DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
var ViewPort:TVkViewPort;
    ScissorRect:TVkRect2D;
    ClearAttachments:array[0..1] of TVkClearAttachment;
    ClearRects:array[0..1] of TVkClearRect;
    ModelMatrix:TpvMatrix4x4;
    ViewMatrix:TpvMatrix4x4;
    ProjectionMatrix:TpvMatrix4x4;
    State:PScreenExampleCubeState;
    p:pointer;
begin

 if assigned(fVulkanGraphicsPipeline) then begin

  ViewPort.x:=aDrawRect.Left;
  ViewPort.y:=aDrawRect.Top;
  ViewPort.width:=aDrawRect.Width;
  ViewPort.height:=aDrawRect.Height;
  ViewPort.minDepth:=0.0;
  ViewPort.maxDepth:=1.0;

  ScissorRect:=aClipRect;

  State:=@fStates[pvApplication.DrawInFlightFrameIndex];

  ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
               TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));
  ViewMatrix:=TpvMatrix4x4.CreateTranslation(0.0,0.0,-6.0);
  ProjectionMatrix:=TpvMatrix4x4.CreatePerspective(45.0,aDrawRect.Width/aDrawRect.Height,1.0,128.0);

  fUniformBuffer.ModelViewProjectionMatrix:=(ModelMatrix*ViewMatrix)*ProjectionMatrix;
  fUniformBuffer.ModelViewNormalMatrix:=TpvMatrix4x4.Create((ModelMatrix*ViewMatrix).ToMatrix3x3.Inverse.Transpose);

  p:=fVulkanUniformBuffers[pvApplication.DrawInFlightFrameIndex].Memory.MapMemory(0,SizeOf(TScreenExampleCubeUniformBuffer));
  if assigned(p) then begin
   try
    Move(fUniformBuffer,p^,SizeOf(TScreenExampleCubeUniformBuffer));
   finally
    fVulkanUniformBuffers[pvApplication.DrawInFlightFrameIndex].Memory.UnmapMemory;
   end;
  end;

  ClearRects[0].rect:=ScissorRect;
  ClearRects[0].baseArrayLayer:=0;
  ClearRects[0].layerCount:=1;

  ClearRects[1].rect:=ScissorRect;
  ClearRects[1].baseArrayLayer:=0;
  ClearRects[1].layerCount:=1;

  ClearAttachments[0].aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ClearAttachments[0].colorAttachment:=0;
  ClearAttachments[0].clearValue.color.float32[0]:=0.0;
  ClearAttachments[0].clearValue.color.float32[1]:=0.0;
  ClearAttachments[0].clearValue.color.float32[2]:=0.0;
  ClearAttachments[0].clearValue.color.float32[3]:=1.0;

  ClearAttachments[1].aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  ClearAttachments[1].colorAttachment:=0;
  ClearAttachments[1].clearValue.depthStencil.depth:=1.0;
  ClearAttachments[1].clearValue.depthStencil.stencil:=0;

  aVulkanCommandBuffer.CmdSetViewport(0,1,@ViewPort);
  aVulkanCommandBuffer.CmdSetScissor(0,1,@ScissorRect);
  aVulkanCommandBuffer.CmdClearAttachments(2,@ClearAttachments[0],2,@ClearRects[0]);
  aVulkanCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,1,@fVulkanDescriptorSets[pvApplication.DrawInFlightFrameIndex].Handle,0,nil);
  aVulkanCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
  aVulkanCommandBuffer.CmdBindVertexBuffers(0,1,@fVulkanVertexBuffer.Handle,@Offsets);
  aVulkanCommandBuffer.CmdBindIndexBuffer(fVulkanIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);
  aVulkanCommandBuffer.CmdDrawIndexed(length(CubeIndices),1,0,0,0);

 end;

end;

constructor TScreenExampleGUICube.Create(const aParent:TpvGUIObject);
begin

 inherited Create(aParent);

 Left:=350;
 Top:=225;
 Title:='Window with VulkanCanvas';
 Content.Layout:=TpvGUIFillLayout.Create(Content,4.0);
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 AutoSize:=false;

 Width:=550;
 Height:=350;

 fVulkanCanvasCube:=TpvGUIVulkanCanvasCube.Create(Content);

end;

destructor TScreenExampleGUICube.Destroy;
begin
 inherited Destroy;
end;

constructor TpvGUIVulkanCanvasDragon.Create(const aParent:TpvGUIObject);
var Index:TpvInt32;
    Stream:TStream;
begin

 inherited Create(aParent);

 fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanGraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanGraphicsCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanTransferCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.TransferQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanTransferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                 pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                 TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 Stream:=pvApplication.Assets.GetAssetStream('shaders/dragon/dragon_vert.spv');
 try
  fDragonVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvApplication.Assets.GetAssetStream('shaders/dragon/dragon_frag.spv');
 try
  fDragonFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fBoxAlbedoTexture:=TpvVulkanTexture.CreateDefault(pvApplication.VulkanDevice,
                                                   pvApplication.VulkanDevice.GraphicsQueue,
                                                   fVulkanGraphicsCommandBuffer,
                                                   fVulkanGraphicsCommandBufferFence,
                                                   pvApplication.VulkanDevice.TransferQueue,
                                                   fVulkanTransferCommandBuffer,
                                                   fVulkanTransferCommandBufferFence,
                                                   TpvVulkanTextureDefaultType.Checkerboard,
                                                   512,
                                                   512,
                                                   0,
                                                   0,
                                                   1,
                                                   true,
                                                   false,
                                                   true);{}

 fBoxAlbedoTexture.WrapModeU:=TpvVulkanTextureWrapMode.WrappedRepeat;
 fBoxAlbedoTexture.WrapModeV:=TpvVulkanTextureWrapMode.WrappedRepeat;
 fBoxAlbedoTexture.WrapModeW:=TpvVulkanTextureWrapMode.WrappedRepeat;
 fBoxAlbedoTexture.BorderColor:=VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
 fBoxAlbedoTexture.UpdateSampler;

 fVulkanPipelineShaderStageDragonVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fDragonVertexShaderModule,'main');

 fVulkanPipelineShaderStageDragonFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fDragonFragmentShaderModule,'main');

 fVulkanGraphicsPipeline:=nil;

 fVulkanModel:=TVulkanModel.Create(pvApplication.VulkanDevice);

 Stream:=pvApplication.Assets.GetAssetStream('models/dragon.mdl');
 try
  fVulkanModel.LoadFromStream(Stream);
  fVulkanModel.Upload(pvApplication.VulkanDevice.TransferQueue,
                      fVulkanTransferCommandBuffer,
                      fVulkanTransferCommandBufferFence);
 finally
  Stream.Free;
 end;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanUniformBuffers[Index]:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                                       SizeOf(TScreenExampleDragonUniformBuffer),
                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                       [],
                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       0,
                                                       [TpvVulkanBufferFlag.PersistentMapped]
                                                      );
  fVulkanUniformBuffers[Index].UploadData(pvApplication.VulkanDevice.TransferQueue,
                                          fVulkanTransferCommandBuffer,
                                          fVulkanTransferCommandBufferFence,
                                          fUniformBuffer,
                                          0,
                                          SizeOf(TScreenExampleDragonUniformBuffer),
                                          TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);
 end;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       MaxInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,MaxInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,MaxInFlightFrames);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                              fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                    [],
                                                    [fVulkanUniformBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false
                                                   );
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(1,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                    [fBoxAlbedoTexture.DescriptorImageInfo],
                                                    [],
                                                    [],
                                                    false
                                                   );
  fVulkanDescriptorSets[Index].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;

end;

destructor TpvGUIVulkanCanvasDragon.Destroy;
var Index:TpvInt32;
begin
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanUniformBuffers[Index]);
 end;
 FreeAndNil(fVulkanModel);
 FreeAndNil(fVulkanGraphicsPipeline);
 FreeAndNil(fVulkanPipelineShaderStageDragonVertex);
 FreeAndNil(fVulkanPipelineShaderStageDragonFragment);
 FreeAndNil(fDragonFragmentShaderModule);
 FreeAndNil(fDragonVertexShaderModule);
 FreeAndNil(fBoxAlbedoTexture);
 for Index:=0 to MaxInFlightFrames-1 do begin
// FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  FreeAndNil(fVulkanRenderSemaphores[Index]);
 end;
 FreeAndNil(fVulkanCommandPool);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 FreeAndNil(fVulkanTransferCommandPool);
 FreeAndNil(fVulkanGraphicsCommandBufferFence);
 FreeAndNil(fVulkanGraphicsCommandBuffer);
 FreeAndNil(fVulkanGraphicsCommandPool);
 inherited Destroy;
end;

procedure TpvGUIVulkanCanvasDragon.AcquireVolatileResources;
begin

 inherited AcquireVolatileResources;

 FreeAndNil(fVulkanGraphicsPipeline);

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(pvApplication.VulkanDevice,
                                                           pvApplication.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanPipelineLayout,
                                                           Instance.VulkanRenderPass,
                                                           0,
                                                           nil,
                                                           0);

 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDragonVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDragonFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TVulkanModelVertex),VK_VERTEX_INPUT_RATE_VERTEX);
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PVulkanModelVertex(nil)^.Position)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R16G16B16A16_SNORM,TVkPtrUInt(pointer(@PVulkanModelVertex(nil)^.QTangent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PVulkanModelVertex(nil)^.TexCoord)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32_UINT,TVkPtrUInt(pointer(@PVulkanModelVertex(nil)^.Material)));

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.DynamicViewPorts:=true;

 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);
 fVulkanGraphicsPipeline.ViewPortState.DynamicScissors:=true;

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
 fVulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
 fVulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

 fVulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
 fVulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.DynamicState.AddDynamicStates([VK_DYNAMIC_STATE_VIEWPORT,
                                                        VK_DYNAMIC_STATE_SCISSOR]);

 fVulkanGraphicsPipeline.Initialize;

 fVulkanGraphicsPipeline.FreeMemory;

end;

procedure TpvGUIVulkanCanvasDragon.ReleaseVolatileResources;
begin
 FreeAndNil(fVulkanGraphicsPipeline);
 inherited ReleaseVolatileResources;
end;

procedure TpvGUIVulkanCanvasDragon.Update;
const f0=1.0/(2.0*pi);
      f1=0.5/(2.0*pi);
begin
 fState.Time:=fState.Time+Instance.DeltaTime;
 fState.AnglePhases[0]:=frac(fState.AnglePhases[0]+(Instance.DeltaTime*f0));
 fState.AnglePhases[1]:=frac(fState.AnglePhases[1]+(Instance.DeltaTime*f1));
 fStates[pvApplication.UpdateInFlightFrameIndex]:=fState;
 inherited Update;
end;

procedure TpvGUIVulkanCanvasDragon.UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
begin
end;

procedure TpvGUIVulkanCanvasDragon.DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
var ViewPort:TVkViewPort;
    ScissorRect:TVkRect2D;
    ClearAttachments:array[0..1] of TVkClearAttachment;
    ClearRects:array[0..1] of TVkClearRect;
    ModelMatrix:TpvMatrix4x4;
    ViewMatrix:TpvMatrix4x4;
    ProjectionMatrix:TpvMatrix4x4;
    State:PScreenExampleDragonState;
    p:pointer;
begin

 if assigned(fVulkanGraphicsPipeline) then begin

  ViewPort.x:=aDrawRect.Left;
  ViewPort.y:=aDrawRect.Top;
  ViewPort.width:=aDrawRect.Width;
  ViewPort.height:=aDrawRect.Height;
  ViewPort.minDepth:=0.0;
  ViewPort.maxDepth:=1.0;

  ScissorRect:=aClipRect;

  State:=@fStates[pvApplication.DrawInFlightFrameIndex];

  ModelMatrix:=TpvMatrix4x4.CreateRotate(State^.AnglePhases[0]*TwoPI,TpvVector3.Create(0.0,0.0,1.0))*
               TpvMatrix4x4.CreateRotate(State^.AnglePhases[1]*TwoPI,TpvVector3.Create(0.0,1.0,0.0));
  ViewMatrix:=TpvMatrix4x4.CreateTranslation(0.0,0.0,-32.0);
  ProjectionMatrix:=TpvMatrix4x4.CreatePerspective(45.0,aDrawRect.Width/aDrawRect.Height,1.0,1024.0);

  fUniformBuffer.ModelViewMatrix:=ModelMatrix*ViewMatrix;
  fUniformBuffer.ModelViewProjectionMatrix:=fUniformBuffer.ModelViewMatrix*ProjectionMatrix;
  fUniformBuffer.ModelViewNormalMatrix:=TpvMatrix4x4.Create(fUniformBuffer.ModelViewMatrix.ToMatrix3x3.Inverse.Transpose);

  p:=fVulkanUniformBuffers[pvApplication.DrawInFlightFrameIndex].Memory.MapMemory(0,SizeOf(TScreenExampleDragonUniformBuffer));
  if assigned(p) then begin
   try
    Move(fUniformBuffer,p^,SizeOf(TScreenExampleDragonUniformBuffer));
   finally
    fVulkanUniformBuffers[pvApplication.DrawInFlightFrameIndex].Memory.UnmapMemory;
   end;
  end;

  ClearRects[0].rect:=ScissorRect;
  ClearRects[0].baseArrayLayer:=0;
  ClearRects[0].layerCount:=1;

  ClearRects[1].rect:=ScissorRect;
  ClearRects[1].baseArrayLayer:=0;
  ClearRects[1].layerCount:=1;

  ClearAttachments[0].aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ClearAttachments[0].colorAttachment:=0;
  ClearAttachments[0].clearValue.color.float32[0]:=0.0;
  ClearAttachments[0].clearValue.color.float32[1]:=0.0;
  ClearAttachments[0].clearValue.color.float32[2]:=0.0;
  ClearAttachments[0].clearValue.color.float32[3]:=1.0;

  ClearAttachments[1].aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  ClearAttachments[1].colorAttachment:=0;
  ClearAttachments[1].clearValue.depthStencil.depth:=1.0;
  ClearAttachments[1].clearValue.depthStencil.stencil:=0;

  aVulkanCommandBuffer.CmdSetViewport(0,1,@ViewPort);
  aVulkanCommandBuffer.CmdSetScissor(0,1,@ScissorRect);
  aVulkanCommandBuffer.CmdClearAttachments(2,@ClearAttachments[0],2,@ClearRects[0]);
  aVulkanCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,1,@fVulkanDescriptorSets[pvApplication.DrawInFlightFrameIndex].Handle,0,nil);
  aVulkanCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
  fVulkanModel.Draw(aVulkanCommandBuffer);

 end;

end;

constructor TScreenExampleGUIDragon.Create(const aParent:TpvGUIObject);
begin

 inherited Create(aParent);

 Left:=500;
 Top:=100;
 Title:='Window with VulkanCanvas in a ScrollPanel';
 Content.Layout:=TpvGUIFillLayout.Create(Content,0.0);
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 AutoSize:=false;

 Width:=550;
 Height:=350;

 fScrollPanel:=TpvGUIScrollPanel.Create(Content);
 fScrollPanel.Content.Layout:=TpvGUIBoxLayout.Create(fScrollPanel.Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,4.0);

 fVulkanCanvasDragon:=TpvGUIVulkanCanvasDragon.Create(fScrollPanel.Content);
 fVulkanCanvasDragon.FixedWidth:=640;
 fVulkanCanvasDragon.FixedHeight:=480;

end;

destructor TScreenExampleGUIDragon.Destroy;
begin
 inherited Destroy;
end;

constructor TScreenExampleGUIColorPicker.Create(const aParent:TpvGUIObject);
begin

 inherited Create(aParent);

 Left:=100;
 Top:=100;
 Title:='Window with ColorPicker';
 fBoxLayout:=TpvGUIBoxLayout.Create(Content,
                                    TpvGUILayoutAlignment.Middle,
                                    TpvGUILayoutOrientation.Horizontal,
                                    4.0,
                                    0.0);
 Content.Layout:=fBoxLayout;
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 AutoSize:=true;

 Width:=550;
 Height:=350;

 fColorPicker:=TpvGUIColorPicker.Create(Content);

 fModePanel:=TpvGUIPanel.Create(Content);
 fModePanel.Background:=true;

 fModePanelGroupLayout:=TpvGUIGroupLayout.Create(fModePanel,
                                                 16.0,
                                                 8.0,
                                                 8.0,
                                                 8.0);
 fModePanel.Layout:=fModePanelGroupLayout;

 fModePanelLabel:=TpvGUILabel.Create(fModePanel);
 fModePanelLabel.Caption:='Mode';
 fModePanelLabel.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

 fLinearRGBModeRadioCheckBox:=TpvGUIRadioCheckBox.Create(fModePanel);
 fLinearRGBModeRadioCheckBox.Caption:='Linear RGB';
 fLinearRGBModeRadioCheckBox.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 fLinearRGBModeRadioCheckBox.OnChange:=LinearRGBOrSRGBModeRadioCheckBoxOnChange;

 fSRGBModeRadioCheckBox:=TpvGUIRadioCheckBox.Create(fModePanel);
 fSRGBModeRadioCheckBox.Caption:='sRGB';
 fSRGBModeRadioCheckBox.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 fSRGBModeRadioCheckBox.Checked:=true;
 fLinearRGBModeRadioCheckBox.OnChange:=LinearRGBOrSRGBModeRadioCheckBoxOnChange;

end;

destructor TScreenExampleGUIColorPicker.Destroy;
begin
 inherited Destroy;
end;

procedure TScreenExampleGUIColorPicker.LinearRGBOrSRGBModeRadioCheckBoxOnChange(const aSender:TpvGUIObject);
begin
 fColorPicker.SRGB:=fSRGBModeRadioCheckBox.Checked;
end;

type { TScreenExampleGUITreeViewWidgetTreeNode }
     TScreenExampleGUITreeViewWidgetTreeNode=class(TpvGUITreeNode)
      protected
       procedure CreateGUIObjects; override;
       procedure DestroyGUIObjects; override;
       procedure UpdateGUIObjects; override;
     end;

{ TScreenExampleGUITreeViewWidgetTreeNode }

procedure TScreenExampleGUITreeViewWidgetTreeNode.CreateGUIObjects;
var Button:TpvGUIButton;
begin

 inherited CreateGUIObjects;

 if assigned(TreeView) then begin

  Button:=TpvGUIButton.Create(TreeView.Content);
  try
   Button.AutoSize:=true;
   Button.Caption:='Hello';
  finally
   GUIObjects.Add(Button);
  end;

 end;

end;

procedure TScreenExampleGUITreeViewWidgetTreeNode.DestroyGUIObjects;
begin

 if assigned(TreeView) then begin

 end;

 inherited DestroyGUIObjects;

end;

procedure TScreenExampleGUITreeViewWidgetTreeNode.UpdateGUIObjects;
begin

 inherited UpdateGUIObjects;

 if assigned(TreeView) then begin

 end;

end;

constructor TScreenExampleGUITreeView.Create(const aParent:TpvGUIObject);
var TreeNodeA,TreeNodeB,TreeNodeC:TpvGUITreeNode;
begin

 inherited Create(aParent);

 Left:=150;
 Top:=150;
 Title:='Window with TreeView';
 fFillLayout:=TpvGUIFillLayout.Create(Content,4.0);
 Content.Layout:=fFillLayout;
 AddMinimizationButton;
 AddMaximizationButton;
 AddCloseButton;

 AutoSize:=false;

 Width:=350;
 Height:=350;

 fTreeView:=TpvGUITreeView.Create(self);

 TreeNodeA:=TpvGUITreeNode.Create(fTreeView.Root);
 TreeNodeA.Caption:='Test A1';

 TreeNodeB:=TScreenExampleGUITreeViewWidgetTreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B1';

 TreeNodeB:=TpvGUITreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B2';

 TreeNodeA:=TpvGUITreeNode.Create(fTreeView.Root);
 TreeNodeA.Caption:='Test A2';

 TreeNodeA:=TpvGUITreeNode.Create(fTreeView.Root);
 TreeNodeA.Caption:='Test A3';

 TreeNodeB:=TpvGUITreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B1';
 TreeNodeB.Icon:=Skin.IconContentPaste;

 TreeNodeC:=TpvGUITreeNode.Create(TreeNodeB);
 TreeNodeC.CheckBox:=true;
 TreeNodeC.Checked:=true;
 TreeNodeC.Caption:='Test C1';

 TreeNodeC:=TpvGUITreeNode.Create(TreeNodeB);
 TreeNodeC.Caption:='Test C2';
 TreeNodeC.Icon:=Skin.IconContentCopy;

 TreeNodeC:=TpvGUITreeNode.Create(TreeNodeB);
 TreeNodeC.Caption:='Test C3';
 TreeNodeC.Icon:=Skin.IconContentCopy;

 TreeNodeB:=TpvGUITreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B2';
 TreeNodeB.Icon:=Skin.IconContentCopy;

 TreeNodeB:=TpvGUITreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B3 with a really very long text for testing';
 TreeNodeB.CheckBox:=true;
 TreeNodeB.Icon:=Skin.IconContentCopy;

 TreeNodeA:=TpvGUITreeNode.Create(fTreeView.Root);
 TreeNodeA.Caption:='Test A4';

 TreeNodeB:=TScreenExampleGUITreeViewWidgetTreeNode.Create(TreeNodeA);
 TreeNodeB.Caption:='Test B1';
 TreeNodeB.Icon:=Skin.IconContentPaste;

// TreeNodeA.Remove(TreeNodeB);

 fTreeView.Root.ExpandAll;

end;

destructor TScreenExampleGUITreeView.Destroy;
begin
 inherited Destroy;
end;

constructor TScreenExampleGUI.Create;
begin
 inherited Create;
 fSelectedIndex:=-1;
 fReady:=false;
 fTime:=0.48;
 fLastMousePosition:=TpvVector2.Null;
 fLastMouseButtons:=[];
end;

destructor TScreenExampleGUI.Destroy;
begin
 inherited Destroy;
end;

procedure TScreenExampleGUI.Button0OnClick(const aSender:TpvGUIObject);
begin

 TpvGUIMessageDialog.Create(fGUIInstance,
                            'Question',
                            'Do you like this GUI?',
                            [TpvGUIMessageDialogButton.Create(0,'Yes',KEYCODE_RETURN,fGUIInstance.Skin.IconThumbUp,24.0),
                             TpvGUIMessageDialogButton.Create(1,'No',KEYCODE_ESCAPE,fGUIInstance.Skin.IconThumbDown,24.0)],
                            fGUIInstance.Skin.IconDialogQuestion);

end;

procedure TScreenExampleGUI.Show;
var Index:TpvInt32;
    WindowMenu:TpvGUIWindowMenu;
    MenuItem:TpvGUIMenuItem;
    PopupMenu:TpvGUIPopupMenu;
//    Popup:TpvGUIPopup;
    Panel:TpvGUIPanel;
    Window:TpvGUIWindow;
    IntegerEdit:TpvGUIIntegerEdit;
    FloatEdit:TpvGUIFloatEdit;
    ScrollBar:TpvGUIScrollBar;
    Slider:TpvGUISlider;
    ScrollPanel:TpvGUIScrollPanel;
    TabPanel:TpvGUITabPanel;
begin

 inherited Show;

 pvApplication.VisibleMouseCursor:=false;

 fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanGraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanGraphicsCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanTransferCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                         pvApplication.VulkanDevice.TransferQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanTransferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);

 fVulkanCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                 pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                 TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  fVulkanRenderSemaphores[Index]:=TpvVulkanSemaphore.Create(pvApplication.VulkanDevice);
 end;

 fVulkanRenderPass:=nil;

 fVulkanCanvas:=TpvCanvas.Create(pvApplication.VulkanDevice,
                                 pvApplication.VulkanPipelineCache,
                                 MaxInFlightFrames);

 fGUIInstance:=TpvGUIInstance.Create(pvApplication.VulkanDevice,fVulkanCanvas);

 fGUIInstance.Width:=pvApplication.Width;
 fGUIInstance.Height:=pvApplication.Height;

 begin
  WindowMenu:=fGUIInstance.AddMenu;

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='File';

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Open';
  TpvGUIMenuItem.Create(TpvGUIPopupMenu.Create(MenuItem)).Caption:='Test';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Save';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Edit';
  MenuItem.Enabled:=false;

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Undo';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Redo';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Settings';

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Audio';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Video';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Help';

 end;

 fGUIWindow:=TpvGUIWindow.Create(fGUIInstance);
 fGUIWindow.Left:=50;
 fGUIWindow.Top:=400;
 fGUIWindow.Title:='Window with GridLayout';
 fGUIWindow.Content.Layout:=TpvGUIBoxLayout.Create(fGUIWindow.Content,TpvGUILayoutAlignment.Fill,TpvGUILayoutOrientation.Vertical,8.0,8.0);
 fGUIWindow.AddMinimizationButton;
 fGUIWindow.AddMaximizationButton;
 fGUIWindow.AddCloseButton;

 begin
  WindowMenu:=fGUIWindow.AddMenu;

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='File';

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='New';
  MenuItem.ShortcutHint:='Ctrl-N';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='-';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Open';
  MenuItem.ShortcutHint:='Ctrl-O';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Open recent';
  MenuItem.ShortcutHint:='Shift-Ctrl-O';
  TpvGUIMenuItem.Create(TpvGUIPopupMenu.Create(MenuItem)).Caption:='Test';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='-';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Save';
  MenuItem.ShortcutHint:='Ctrl-S';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Save as';
  MenuItem.ShortcutHint:='Shift-Ctrl-S';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='-';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Exit';
  MenuItem.ShortcutHint:='Alt+F4';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Edit';
  MenuItem.Enabled:=false;

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Undo';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Redo';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Settings';

  PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Audio';
  MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
  MenuItem.Caption:='Video';

  MenuItem:=TpvGUIMenuItem.Create(WindowMenu);
  MenuItem.Caption:='Help';
 end;

 Panel:=TPvGUIPanel.Create(fGUIWindow.Content);
 Panel.Layout:=TpvGUIGridLayout.Create(Panel,4,TpvGUILayoutAlignment.Leading,TpvGUILayoutAlignment.Middle,TpvGUILayoutOrientation.Horizontal,0.0,8.0,8.0);

 fGUILabel:=TpvGUILabel.Create(Panel);
 fGUILabel.Caption:='An example label';
 fGUILabel.Cursor:=TpvGUICursor.Link;

{fGUIButton:=TpvGUIButton.Create(fGUIWindow.ButtonPanel);
 fGUIButton.Caption:=TpvRawByteString(#$e2#$80#$a6);}

 fGUIButton:=TpvGUIButton.Create(Panel);
 fGUIButton.Caption:='An example button';
 fGUIButton.OnClick:=Button0OnClick;

 fGUIButton:=TpvGUIToggleButton.Create(Panel);
 fGUIButton.Caption:='An example toggle button';

 fGUIButton:=TpvGUIButton.Create(Panel);
 fGUIButton.Caption:='An example disabled button';
 fGUIButton.Enabled:=false;

 fGUITextEdit:=TpvGUITextEdit.Create(fGUIWindow.Content);
 fGUITextEdit.Text:='An example text edit';
 fGUITextEdit.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 fGUITextEdit.MinimumWidth:=320;
 fGUITextEdit.MinimumHeight:=32;
 fGUITextEdit.Enabled:=true;

 IntegerEdit:=TpvGUIIntegerEdit.Create(fGUIWindow.Content);
 IntegerEdit.Value:=1337;
 IntegerEdit.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 IntegerEdit.MinimumWidth:=320;
 IntegerEdit.MinimumHeight:=32;
 IntegerEdit.Enabled:=true;

 FloatEdit:=TpvGUIFloatEdit.Create(fGUIWindow.Content);
 FloatEdit.Value:=PI;
 FloatEdit.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 FloatEdit.MinimumWidth:=320;
 FloatEdit.MinimumHeight:=32;
 FloatEdit.Enabled:=true;

{Popup:=TpvGUIPopup.Create(fGUITextEdit);
 Popup.FixedSize.Vector:=TpvVector2.Create(160,100);
 Popup.AnchorSide:=TpvGUIPopupAnchorSide.Bottom;}

 fGUIOtherWindow:=TpvGUIWindow.Create(fGUIInstance);
 fGUIOtherWindow.Left:=550;
 fGUIOtherWindow.Top:=50;
 fGUIOtherWindow.Title:='Window with BoxLayout';
 fGUIOtherWindow.Content.Layout:=TpvGUIBoxLayout.Create(fGUIOtherWindow.Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,8.0);
 fGUIOtherWindow.AddMinimizationButton;
 fGUIOtherWindow.AddMaximizationButton;
 fGUIOtherWindow.AddCloseButton;

 Panel:=TPvGUIPanel.Create(fGUIOtherWindow.Content);
 Panel.Layout:=TpvGUIGridLayout.Create(Panel,4,TpvGUILayoutAlignment.Leading,TpvGUILayoutAlignment.Middle,TpvGUILayoutOrientation.Horizontal,0.0,8.0,8.0);

 fGUILabel:=TpvGUILabel.Create(Panel);
 fGUILabel.Caption:='An other example label';
 fGUILabel.Cursor:=TpvGUICursor.Busy;

 fGUILabel:=TpvGUILabel.Create(Panel);
 fGUILabel.Caption:='An another example label';
 fGUILabel.Cursor:=TpvGUICursor.Unavailable;

 fGUILabel:=TpvGUILabel.Create(Panel);
 fGUILabel.Caption:='Yet another example label';
 fGUILabel.Cursor:=TpvGUICursor.Pen;

 fGUILabel:=TpvGUILabel.Create(Panel);
 fGUILabel.Caption:='Again another example label';
 fGUILabel.Cursor:=TpvGUICursor.Link;

 TpvGUICheckBox.Create(Panel).Caption:='Check box';

 TpvGUIRadioCheckBox.Create(Panel).Caption:='Radio check box (0)';

 TpvGUIRadioCheckBox.Create(Panel).Caption:='Radio check box (1)';

 TpvGUIRadioCheckBox.Create(Panel).Caption:='Radio check box (2)';

 fGUIButton:=TpvGUIRadioButton.Create(Panel);
 fGUIButton.Caption:='Radio button (0)';

 fGUIButton:=TpvGUIRadioButton.Create(Panel);
 fGUIButton.Caption:='Radio button (1)';

 fGUIButton:=TpvGUIRadioButton.Create(Panel);
 fGUIButton.Caption:='Radio button (2)';

 fGUIButton:=TpvGUIRadioButton.Create(Panel);
 fGUIButton.Caption:='Radio button (3)';

 fGUIYetOtherWindow:=TpvGUIWindow.Create(fGUIInstance);
 fGUIYetOtherWindow.Left:=750;
 fGUIYetOtherWindow.Top:=350;
 fGUIYetOtherWindow.Title:='Window with FillLayout and ScrollPanel';
 fGUIYetOtherWindow.Content.Layout:=TpvGUIFillLayout.Create(fGUIOtherWindow.Content,0.0);
 fGUIYetOtherWindow.AddMinimizationButton;
 fGUIYetOtherWindow.AddMaximizationButton;
 fGUIYetOtherWindow.AddCloseButton;

 ScrollPanel:=TpvGUIScrollPanel.Create(fGUIYetOtherWindow.Content);
 ScrollPanel.Content.Layout:=TpvGUIBoxLayout.Create(ScrollPanel.Content,TpvGUILayoutAlignment.Leading,TpvGUILayoutOrientation.Vertical,8.0,8.0);

 fGUIButton:=TpvGUIToggleButton.Create(ScrollPanel.Content);
 fGUIButton.Caption:='Toggle button';
 fGUIButton.FixedWidth:=480;
 fGUIButton.FixedHeight:=240;

 fGUIYetOtherWindow:=TScreenExampleGUIFillLayoutExampleWindow.Create(fGUIInstance);

 Window:=TpvGUIWindow.Create(fGUIInstance);
 Window.Left:=150;
 Window.Top:=200;
 Window.Title:='Window with AdvancedGridLayout';
 Window.Content.Layout:=TpvGUIAdvancedGridLayout.Create(Window.Content,8.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Rows.Add(50.0,0.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Rows.Add(1.0,1.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Rows.Add(50.0,0.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Columns.Add(100.0,0.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Columns.Add(1.0,1.0);
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Columns.Add(100.0,0.0);
 Window.AddMinimizationButton;
 Window.AddMaximizationButton;
 Window.AddCloseButton;

 fGUIButton:=TpvGUIPopupButton.Create(Window.Content);
 fGUIButton.Caption:='Popup';
 fGUIButton.Enabled:=true;
 TpvGUIPopupButton(fGUIButton).Popup.AnchorSide:=TpvGUIPopupAnchorSide.Left;
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Anchors[fGUIButton]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,0,1,1,2.0,2.0,2.0,2.0);

 fGUIButton:=TpvGUIPopupButton.Create(Window.Content);
 fGUIButton.Caption:='Popup';
 fGUIButton.Enabled:=true;
 TpvGUIPopupButton(fGUIButton).Popup.AnchorSide:=TpvGUIPopupAnchorSide.Top;
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Anchors[fGUIButton]:=TpvGUIAdvancedGridLayoutAnchor.Create(1,0,1,1,2.0,2.0,2.0,2.0);

 fGUIButton:=TpvGUIPopupButton.Create(Window.Content);
 fGUIButton.Caption:='Popup';
 fGUIButton.Enabled:=true;
 TpvGUIPopupButton(fGUIButton).Popup.AnchorSide:=TpvGUIPopupAnchorSide.Right;
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Anchors[fGUIButton]:=TpvGUIAdvancedGridLayoutAnchor.Create(2,0,1,1,2.0,2.0,2.0,2.0);

 fGUIButton:=TpvGUIPopupButton.Create(Window.Content);
 fGUIButton.Caption:='Popup';
 fGUIButton.Enabled:=true;
 TpvGUIPopupButton(fGUIButton).Popup.AnchorSide:=TpvGUIPopupAnchorSide.Right;
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Anchors[fGUIButton]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,1,3,1,2.0,2.0,2.0,2.0);

 fGUIButton:=TpvGUIPopupButton.Create(Window.Content);
 fGUIButton.Caption:='Popup';
 fGUIButton.Enabled:=true;
 TpvGUIPopupButton(fGUIButton).Popup.AnchorSide:=TpvGUIPopupAnchorSide.Bottom;
 TpvGUIAdvancedGridLayout(Window.Content.Layout).Anchors[fGUIButton]:=TpvGUIAdvancedGridLayoutAnchor.Create(1,2,2,1,2.0,2.0,2.0,2.0);

 TScreenExampleGUITabPanelExampleWindow.Create(fGUIInstance);

 TScreenExampleGUIMultiLineTextEditWindow.Create(fGUIInstance);

 TScreenExampleGUICube.Create(fGUIInstance);

 TScreenExampleGUIDragon.Create(fGUIInstance);

 TScreenExampleGUIColorPicker.Create(fGUIInstance);

 TScreenExampleGUITreeView.Create(fGUIInstance);

end;

procedure TScreenExampleGUI.Hide;
var Index:TpvInt32;
begin
 FreeAndNil(fGUIInstance);
 FreeAndNil(fVulkanCanvas);
 FreeAndNil(fVulkanRenderPass);
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  FreeAndNil(fVulkanRenderSemaphores[Index]);
 end;
 FreeAndNil(fVulkanCommandPool);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 FreeAndNil(fVulkanTransferCommandPool);
 FreeAndNil(fVulkanGraphicsCommandBufferFence);
 FreeAndNil(fVulkanGraphicsCommandBuffer);
 FreeAndNil(fVulkanGraphicsCommandPool);
 pvApplication.VisibleMouseCursor:=true;
 inherited Hide;
end;

procedure TScreenExampleGUI.Resume;
begin
 inherited Resume;
end;

procedure TScreenExampleGUI.Pause;
begin
 inherited Pause;
end;

procedure TScreenExampleGUI.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
end;

procedure TScreenExampleGUI.AfterCreateSwapChain;
var Index:TpvInt32;
begin

 inherited AfterCreateSwapChain;

 FreeAndNil(fVulkanRenderPass);

 fVulkanRenderPass:=TpvVulkanRenderPass.Create(pvApplication.VulkanDevice);

 fVulkanRenderPass.AddSubpassDescription(0,
                                         VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         [],
                                         [fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                              pvApplication.VulkanSwapChain.ImageFormat,
                                                                                                                              VK_SAMPLE_COUNT_1_BIT,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                                              VK_ATTACHMENT_STORE_OP_STORE,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                              VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, //VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                                                                                                              VK_IMAGE_LAYOUT_PRESENT_SRC_KHR //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL //VK_IMAGE_LAYOUT_PRESENT_SRC_KHR  // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                                                                             ),
                                                                             VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                            )],
                                         [],
                                         fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                             pvApplication.VulkanDepthImageFormat,
                                                                                                                             VK_SAMPLE_COUNT_1_BIT,
                                                                                                                             VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                                             VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                             VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                             VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                             VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, // VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                                                                                                             VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                                                            ),
                                                                                  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                 ),
                                         []);
 fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                        0,
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                        TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                        TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                        TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
 fVulkanRenderPass.AddSubpassDependency(0,
                                        VK_SUBPASS_EXTERNAL,
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                        TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                        TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                        TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                        TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
 fVulkanRenderPass.Initialize;

 fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.0;
 fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;

 fVulkanCanvas.VulkanRenderPass:=fVulkanRenderPass;
 fVulkanCanvas.CountBuffers:=pvApplication.CountInFlightFrames;
 if pvApplication.Width<pvApplication.Height then begin
  fVulkanCanvas.Width:=(720*pvApplication.Width) div pvApplication.Height;
  fVulkanCanvas.Height:=720;
 end else begin
  fVulkanCanvas.Width:=1280;
  fVulkanCanvas.Height:=(1280*pvApplication.Height) div pvApplication.Width;
 end;
 fVulkanCanvas.Viewport.x:=0;
 fVulkanCanvas.Viewport.y:=0;
 fVulkanCanvas.Viewport.width:=pvApplication.Width;
 fVulkanCanvas.Viewport.height:=pvApplication.Height;
 fScreenToCanvasScale:=TpvVector2.Create(fVulkanCanvas.Width,fVulkanCanvas.Height)/TpvVector2.Create(pvApplication.Width,pvApplication.Height);

 for Index:=0 to length(fVulkanRenderCommandBuffers)-1 do begin
  FreeAndNil(fVulkanRenderCommandBuffers[Index]);
  fVulkanRenderCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
 end;

 fGUIInstance.VulkanRenderPass:=fVulkanRenderPass;
 fGUIInstance.CountBuffers:=pvApplication.CountInFlightFrames;
 fGUIInstance.Width:=fVulkanCanvas.Width;
 fGUIInstance.Height:=fVulkanCanvas.Height;
 fGUIInstance.MousePosition:=TpvVector2.Create(fGUIInstance.Width*0.5,fGUIInstance.Height*0.5);

 pvApplication.Input.SetCursorPosition(pvApplication.Width div 2,pvApplication.Height div 2);

 fGUIInstance.AcquireVolatileResources;

 fGUIInstance.PerformLayout;

end;

procedure TScreenExampleGUI.BeforeDestroySwapChain;
begin
 fGUIInstance.ReleaseVolatileResources;
 fVulkanCanvas.VulkanRenderPass:=nil;
 FreeAndNil(fVulkanRenderPass);
 inherited BeforeDestroySwapChain;
end;

function TScreenExampleGUI.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and not fGUIInstance.KeyEvent(aKeyEvent) then begin
  if aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down then begin
   case aKeyEvent.KeyCode of
    KEYCODE_AC_BACK{,KEYCODE_ESCAPE}:begin
     pvApplication.NextScreen:=TScreenMainMenu.Create;
    end;
{   KEYCODE_UP:begin
     if fSelectedIndex<=0 then begin
      fSelectedIndex:=0;
     end else begin
      dec(fSelectedIndex);
     end;
    end;
    KEYCODE_DOWN:begin
     if fSelectedIndex>=0 then begin
      fSelectedIndex:=0;
     end else begin
      inc(fSelectedIndex);
     end;
    end;
    KEYCODE_PAGEUP:begin
     if fSelectedIndex<0 then begin
      fSelectedIndex:=0;
     end;
    end;
    KEYCODE_PAGEDOWN:begin
     if fSelectedIndex<0 then begin
      fSelectedIndex:=0;
     end;
    end;
    KEYCODE_HOME:begin
     fSelectedIndex:=0;
    end;
    KEYCODE_END:begin
     fSelectedIndex:=0;
    end;}
    KEYCODE_RETURN,KEYCODE_SPACE:begin
     if fSelectedIndex=0 then begin
      pvApplication.NextScreen:=TScreenMainMenu.Create;
     end;
    end;
   end;
  end;
 end;
end;

function TScreenExampleGUI.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Index:TpvInt32;
    cy:TpvFloat;
    LocalPointerEvent:TpvApplicationInputPointerEvent;
begin
 result:=false;
 if fReady then begin
  LocalPointerEvent:=aPointerEvent;
  LocalPointerEvent.Position:=LocalPointerEvent.Position*fScreenToCanvasScale;
  LocalPointerEvent.RelativePosition:=LocalPointerEvent.RelativePosition*fScreenToCanvasScale;
  if not fGUIInstance.PointerEvent(LocalPointerEvent) then begin
   case aPointerEvent.PointerEventType of
    TpvApplicationInputPointerEventType.Down:begin
     fSelectedIndex:=-1;
     cy:=fStartY;
     for Index:=0 to 0 do begin
      if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
       fSelectedIndex:=Index;
       if fSelectedIndex=0 then begin
        pvApplication.NextScreen:=TScreenMainMenu.Create;
       end;
      end;
      cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
     end;
    end;
    TpvApplicationInputPointerEventType.Up:begin
    end;
    TpvApplicationInputPointerEventType.Motion:begin
     fSelectedIndex:=-1;
     cy:=fStartY;
     for Index:=0 to 0 do begin
      if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
       fSelectedIndex:=Index;
      end;
      cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
     end;
    end;
    TpvApplicationInputPointerEventType.Drag:begin
    end;
   end;
  end;
 end;
 case aPointerEvent.PointerEventType of
  TpvApplicationInputPointerEventType.Down:begin
   Include(fLastMouseButtons,aPointerEvent.Button);
   fLastMousePosition:=aPointerEvent.Position*fScreenToCanvasScale;
  end;
  TpvApplicationInputPointerEventType.Up:begin
   Exclude(fLastMouseButtons,aPointerEvent.Button);
   fLastMousePosition:=aPointerEvent.Position*fScreenToCanvasScale;
  end;
  TpvApplicationInputPointerEventType.Motion:begin
   fLastMousePosition:=aPointerEvent.Position*fScreenToCanvasScale;
  end;
 end;
end;

function TScreenExampleGUI.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 if fReady then begin
  result:=fGUIInstance.Scrolled(fLastMousePosition,aRelativeAmount);
 end else begin
  result:=false;
 end;
end;

function TScreenExampleGUI.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenExampleGUI.Check(const aDeltaTime:TpvDouble);
begin

 inherited Check(aDeltaTime);

 fGUIInstance.UpdateBufferIndex:=pvApplication.UpdateInFlightFrameIndex;
 fGUIInstance.DeltaTime:=aDeltaTime;
 fGUIInstance.Check;

end;

procedure TScreenExampleGUI.Update(const aDeltaTime:TpvDouble);
const BoolToInt:array[boolean] of TpvInt32=(0,1);
      Options:array[0..0] of string=('Back');
var Index:TpvInt32;
    cy:TpvFloat;
    s:string;
    IsSelected:boolean;
begin
 inherited Update(aDeltaTime);

 fVulkanCanvas.Start(pvApplication.UpdateInFlightFrameIndex);

 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.Identity;

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;

{$if false}
 fVulkanCanvas.Color:=TpvVector4.Create(IfThen(TpvApplicationInputPointerButton.Left in fLastMouseButtons,1.0,0.0),
                                        IfThen(TpvApplicationInputPointerButton.Right in fLastMouseButtons,1.0,0.0),
                                        1.0,
                                        1.0);
 fVulkanCanvas.DrawFilledCircle(fLastMousePosition,16.0);
 fVulkanCanvas.Color:=TpvVector4.Create(0.5,1.0,0.5,1.0);
 fVulkanCanvas.DrawFilledCircle(fLastMousePosition,4.0);
 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,1.0);
{$ifend}

 fGUIInstance.DrawWidgetBounds:=false;
 fGUIInstance.UpdateBufferIndex:=pvApplication.UpdateInFlightFrameIndex;
 fGUIInstance.DeltaTime:=aDeltaTime;
 fGUIInstance.Update;
 fGUIInstance.Draw;

 fVulkanCanvas.Stop;

 Application.TextOverlay.AddText(pvApplication.Width*0.5,Application.TextOverlay.FontCharHeight*1.0,2.0,toaCenter,'GUI');
 fStartY:=pvApplication.Height-((((Application.TextOverlay.FontCharHeight+4)*FontSize)*1.25)-(4*FontSize));
 cy:=fStartY;
 for Index:=0 to 0 do begin
  IsSelected:=fSelectedIndex=Index;
  s:=' '+Options[Index]+' ';
  if IsSelected then begin
   s:='>'+s+'<';
  end;
  Application.TextOverlay.AddText(pvApplication.Width*0.5,cy,FontSize,toaCenter,TpvRawByteString(s),MenuColors[IsSelected,0,0],MenuColors[IsSelected,0,1],MenuColors[IsSelected,0,2],MenuColors[IsSelected,0,3],MenuColors[IsSelected,1,0],MenuColors[IsSelected,1,1],MenuColors[IsSelected,1,2],MenuColors[IsSelected,1,3]);
  cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
 end;

 fTime:=fTime+aDeltaTime;

 fReady:=true;
end;

procedure TScreenExampleGUI.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var VulkanCommandBuffer:TpvVulkanCommandBuffer;
    VulkanSwapChain:TpvVulkanSwapChain;
begin

 begin

  begin

   VulkanCommandBuffer:=fVulkanRenderCommandBuffers[pvApplication.DrawInFlightFrameIndex];
   VulkanSwapChain:=pvApplication.VulkanSwapChain;

   fGUIInstance.DrawBufferIndex:=pvApplication.DrawInFlightFrameIndex;
   fGUIInstance.ExecuteDraw(aWaitSemaphore);

   VulkanCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

   VulkanCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

   fVulkanCanvas.ExecuteUpload(pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence,
                               pvApplication.DrawInFlightFrameIndex);

   fVulkanRenderPass.BeginRenderPass(VulkanCommandBuffer,
                                     pvApplication.VulkanFrameBuffers[aSwapChainImageIndex],
                                     VK_SUBPASS_CONTENTS_INLINE,
                                     0,
                                     0,
                                     VulkanSwapChain.Width,
                                     VulkanSwapChain.Height);

   fVulkanCanvas.ExecuteDraw(VulkanCommandBuffer,
                             pvApplication.DrawInFlightFrameIndex);

   fVulkanRenderPass.EndRenderPass(VulkanCommandBuffer);

   VulkanCommandBuffer.EndRecording;

   VulkanCommandBuffer.Execute(pvApplication.VulkanDevice.GraphicsQueue,
                               TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                               aWaitSemaphore,
                               fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex],
                               aWaitFence,
                               false);

   aWaitSemaphore:=fVulkanRenderSemaphores[pvApplication.DrawInFlightFrameIndex];

  end;

 end;

end;

initialization
 RegisterExample('GUI',TScreenExampleGUI);
end.
