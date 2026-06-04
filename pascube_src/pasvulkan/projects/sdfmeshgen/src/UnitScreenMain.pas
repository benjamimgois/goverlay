unit UnitScreenMain;
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
     Vulkan,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Collections,
     PasVulkan.Application,
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.GUI,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont,
     PasVulkan.TextEditor,
     PasJSON,
     PasGLTF,
     UnitExternalProcess;

type TScreenMain=class(TpvApplicationScreen)
      public
       const GridCellSizePerIteration=16;
             MaxGridCellsPerIteration=GridCellSizePerIteration*GridCellSizePerIteration*GridCellSizePerIteration;
             MaxTrianglesPerIteration=MaxGridCellsPerIteration*6*2;
       type TVertex=record
             Position:TpvVector4;
             QTantent:TpvQuaternion;
             Parameters0:TpvVector4;
             Parameters1:TpvVector4;
            end;
            PVertex=^TVertex;
            TVolumeTriangle=record
             Vertices:array[0..3] of TVertex;
            end;
            PVolumeTriangle=^TVolumeTriangle;
            TVolumeTrianglesMetaData=record
             Count:TpvUInt32;
             MaxCount:TpvUInt32;
             Reserved0:TpvUInt32;
             Reserved1:TpvUInt32;
            end;
            PVolumeTrianglesMetaData=^TVolumeTrianglesMetaData;
            TVolumeTriangles=record
             MetaData:TVolumeTrianglesMetaData;
             Triangles:array[0..MaxTrianglesPerIteration-1] of TVolumeTriangle;
            end;
            PVolumeTriangles=^TVolumeTriangles;
            TMeshVertices=TpvDynamicArray<TVertex>;
            TMeshIndices=TpvDynamicArray<TpvUInt32>;
            TMesh=record
             Vertices:TMeshVertices;
             Indices:TMeshIndices;
            end;
            PMesh=^TMesh;
            TUpdateThread=class(TThread)
             public
              type TComputePushConstants=record
                    GridOffsetX:TpvUInt32;
                    GridOffsetY:TpvUInt32;
                    GridOffsetZ:TpvUInt32;
                    GridOffsetW:TpvUInt32;
                   end;
                   PComputePushConstants=^TComputePushConstants;
             private
              fScreenMain:TScreenMain;
              fSignedDistanceFieldCode:TpvUTF8String;
              fMeshFragmentCode:TpvUTF8String;
              fGridSizeX:TpvInt64;
              fGridSizeY:TpvInt64;
              fGridSizeZ:TpvInt64;
              fWorldSizeX:TpvDouble;
              fWorldSizeY:TpvDouble;
              fWorldSizeZ:TpvDouble;
              fWorldMinX:TpvDouble;
              fWorldMinY:TpvDouble;
              fWorldMinZ:TpvDouble;
              fWorldMaxX:TpvDouble;
              fWorldMaxY:TpvDouble;
              fWorldMaxZ:TpvDouble;
              fProgress:TPasMPInt32;
              fErrorString:TpvUTF8String;
              fSignedDistanceFieldComputeShaderSPVStream:TMemoryStream;
              fMeshVertexShaderSPVStream:TMemoryStream;
              fMeshFragmentShaderSPVStream:TMemoryStream;
              fMaxComputeWorkGroupInvocations:TpvSizeInt;
              fLocalSizeX:TpvSizeInt;
              fLocalSizeY:TpvSizeInt;
              fLocalSizeZ:TpvSizeInt;
              fMesh:TMesh;
              fComputePushConstants:TComputePushConstants;
             protected
              constructor Create(const aScreenMain:TScreenMain); reintroduce;
              destructor Destroy; override;
              procedure Execute; override;
            end;
            TMeshVulkanCanvas=class(TpvGUIVulkanCanvas)
             private
              type TUniformBuffer=record
                    ModelViewMatrix:TpvMatrix4x4;
                    ModelViewProjectionMatrix:TpvMatrix4x4;
                    ModelViewNormalMatrix:TpvMatrix4x4;
                   end;
                   PUniformBuffer=^TUniformBuffer;
                   TState=record
                    Time:TpvDouble;
                    AnglePhases:array[0..1] of TpvFloat;
                   end;
                   PState=^TState;
                   TStates=array[0..MaxInFlightFrames-1] of TState;
                   PStates=^TStates;
              const Offsets:array[0..0] of TVkDeviceSize=(0);
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
              fUniformBuffer:TUniformBuffer;
              fBoxAlbedoTexture:TpvVulkanTexture;
              fState:TState;
              fStates:TStates;
              fRadius:TpvFloat;
              fMesh:TMesh;
             public
              constructor Create(const aParent:TpvGUIObject;
                                 const aMesh:TMesh;
                                 const aVertexShaderStream:TStream;
                                 const aFragmentShaderStream:TStream;
                                 const aRadius:TpvFloat); reintroduce;
              destructor Destroy; override;
              procedure AcquireVolatileResources; override;
              procedure ReleaseVolatileResources; override;
              procedure Update; override;
              procedure UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
              procedure DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect); override;
            end;
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
       fGUIStatusPanel:TpvGUIPanel;
       fGUIStatusFileNameLabel:TpvGUILabel;
       fGUIStatusModifiedLabel:TpvGUILabel;
       fGUIRootPanel:TpvGUIPanel;
       fGUIRootSplitterPanel0:TpvGUISplitterPanel;
       fGUIRootSplitterPanel1:TpvGUISplitterPanel;
       fGUILeftTabPanel:TpvGUITabPanel;
       fGUILeftToolPanel:TpvGUIPanel;
       fGUIVulkanCanvas:TpvGUIVulkanCanvas;
       fGUIGridSizePanel:TpvGUIPanel;
       fLabelGridSizeWidth:TpvGUILabel;
       fIntegerEditGridSizeWidth:TpvGUIIntegerEdit;
       fLabelGridSizeHeight:TpvGUILabel;
       fIntegerEditGridSizeHeight:TpvGUIIntegerEdit;
       fLabelGridSizeDepth:TpvGUILabel;
       fIntegerEditGridSizeDepth:TpvGUIIntegerEdit;
       fGUIWorldSizePanel:TpvGUIPanel;
       fLabelWorldSizeWidth:TpvGUILabel;
       fFloatEditWorldSizeWidth:TpvGUIFloatEdit;
       fLabelWorldSizeHeight:TpvGUILabel;
       fFloatEditWorldSizeHeight:TpvGUIFloatEdit;
       fLabelWorldSizeDepth:TpvGUILabel;
       fFloatEditWorldSizeDepth:TpvGUIFloatEdit;
       fGUISignedDistanceFieldCodeEditorTab:TpvGUITab;
       fGUIMeshFragmentCodeEditorTab:TpvGUITab;
       fGUISignedDistanceFieldCodeEditor:TpvGUIMultiLineTextEdit;
       fGUIMeshFragmentCodeEditor:TpvGUIMultiLineTextEdit;
       fGUIUpdateButton:TpvGUIButton;
       fGUIUpdateProgressBar:TpvGUIProgressBar;
       fGUIWindow:TpvGUIWindow;
       fGUILabel:TpvGUILabel;
       fGUIButton:TpvGUIButton;
       fGUITextEdit:TpvGUITextEdit;
       fGUIOtherWindow:TpvGUIWindow;
       fGUIYetOtherWindow:TpvGUIWindow;
       fLastMousePosition:TpvVector2;
       fLastMouseButtons:TpvApplicationInputPointerButtons;
       fReady:boolean;
       fModified:boolean;
       fNewProjectMessageDialogVisible:boolean;
       fOpenProjectMessageDialogVisible:boolean;
       fTerminationMessageDialogVisible:boolean;
       fTime:TpvDouble;
       fFileName:TpvUTF8String;
       fFileNameToDelayedOpen:TpvUTF8String;
       fTemporaryDirectory:TpvUTF8String;
       fVulkanSDKPath:TpvUTF8String;
       fVulkanSDKFound:boolean;
       fVulkanGLSLCPath:TpvUTF8String;
       fVulkanGLSLCFound:boolean;
       fUpdateThread:TUpdateThread;
       fVolumeTriangles:TVolumeTriangles;
       fVolumeTriangleBuffer:TpvVulkanBuffer;
       fMesh:TMesh;
       procedure UpdateGUIData;
       procedure MarkAsNotModified;
       procedure MarkAsModified;
       procedure CheckUpdateThread;
       procedure UpdateProject;
       procedure NewProject;
       procedure OpenProject(aFileName:TpvUTF8String);
       procedure SaveProject(aFileName:TpvUTF8String);
       procedure SignedDistanceFieldCodeEditorOnChange(const aSender:TpvGUIObject);
       procedure MeshFragmentCodeEditorOnChange(const aSender:TpvGUIObject);
       procedure GridSizeOnChange(const aSender:TpvGUIObject);
       procedure WorldSizeOnChange(const aSender:TpvGUIObject);
       procedure UpdateButtonOnClick(const aSender:TpvGUIObject);
       procedure OnNewProjectMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
       procedure OnNewProjectMessageDialogDestroy(const aSender:TpvGUIObject);
       procedure ShowNewProjectMessageDialog(const aSender:TpvGUIObject);
       procedure OnOpenProjectMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
       procedure OnOpenProjectMessageDialogDestroy(const aSender:TpvGUIObject);
       procedure ShowOpenProjectMessageDialog(const aSender:TpvGUIObject);
       procedure OnTerminationMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
       procedure OnTerminationMessageDialogDestroy(const aSender:TpvGUIObject);
       procedure ShowTerminationMessageDialog(const aSender:TpvGUIObject);
       procedure OpenFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
       procedure SaveFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
       procedure ExportFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
       procedure MenuOnOpenProject(const aSender:TpvGUIObject);
       procedure MenuOnSaveProject(const aSender:TpvGUIObject);
       procedure MenuOnSaveAsProject(const aSender:TpvGUIObject);
       procedure MenuOnExportAsProject(const aSender:TpvGUIObject);
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

var ScreenMain:TScreenMain=nil;

implementation

uses {$ifndef fpc}System.IOUtils,{$endif}PasDblStrUtils;

{ TScreenMain.TUpdateThread }

function LineNumberizeCode(const aCode,aWhere:TpvUTF8String):TpvUTF8String;
var StringList:TStringList;
    Index:TpvSizeInt;
begin
 result:='';
 StringList:=TStringList.Create;
 try
  StringList.Text:=String(aCode);
  for Index:=0 to StringList.Count-1 do begin
   result:=result+TpvUTF8String('#line '+IntToStr(Index+1)+' "'+String(aWhere)+'"'+#13#10+
                                TrimRight(StringList.Strings[Index])+#13#10);
  end;
 finally
  FreeAndNil(StringList);
 end;
end;

constructor TScreenMain.TUpdateThread.Create(const aScreenMain:TScreenMain);
var Counter:TpvSizeInt;
begin
 fScreenMain:=aScreenMain;
 fSignedDistanceFieldCode:=LineNumberizeCode(fScreenMain.fGUISignedDistanceFieldCodeEditor.Text,'Signed distance field');
 fMeshFragmentCode:=LineNumberizeCode(fScreenMain.fGUIMeshFragmentCodeEditor.Text,'Mesh fragment');
 fGridSizeX:=fScreenMain.fIntegerEditGridSizeWidth.Value;
 fGridSizeY:=fScreenMain.fIntegerEditGridSizeHeight.Value;
 fGridSizeZ:=fScreenMain.fIntegerEditGridSizeDepth.Value;
 fWorldSizeX:=fScreenMain.fFloatEditWorldSizeWidth.Value;
 fWorldSizeY:=fScreenMain.fFloatEditWorldSizeHeight.Value;
 fWorldSizeZ:=fScreenMain.fFloatEditWorldSizeDepth.Value;
 fWorldMinX:=-(fWorldSizeX*0.5);
 fWorldMinY:=-(fWorldSizeY*0.5);
 fWorldMinZ:=-(fWorldSizeZ*0.5);
 fWorldMaxX:=fWorldSizeX*0.5;
 fWorldMaxY:=fWorldSizeY*0.5;
 fWorldMaxZ:=fWorldSizeZ*0.5;
 fErrorString:='';
 fProgress:=0;
 fSignedDistanceFieldComputeShaderSPVStream:=TMemoryStream.Create;
 fMeshVertexShaderSPVStream:=TMemoryStream.Create;
 fMeshFragmentShaderSPVStream:=TMemoryStream.Create;
 fMaxComputeWorkGroupInvocations:=pvApplication.VulkanDevice.PhysicalDevice.Properties.limits.maxComputeWorkGroupInvocations;
 fLocalSizeX:=trunc(Power(fMaxComputeWorkGroupInvocations,1.0/3.0));
 fLocalSizeY:=fLocalSizeX;
 fLocalSizeZ:=fLocalSizeX;
 Counter:=0;
 while ((fLocalSizeX*fLocalSizeY*fLocalSizeZ)>fMaxComputeWorkGroupInvocations) or
       ((fLocalSizeX*fLocalSizeY*fLocalSizeZ)>MaxGridCellsPerIteration) do begin
  case Counter of
   0:begin
    dec(fLocalSizeX);
    Counter:=1;
   end;
   1:begin
    dec(fLocalSizeY);
    Counter:=2;
   end;
   2:begin
    dec(fLocalSizeZ);
    Counter:=0;
   end;
  end;
 end;
 if (fLocalSizeX>1) and ((GridCellSizePerIteration mod fLocalSizeX)<>0) then begin
  dec(fLocalSizeX,GridCellSizePerIteration mod fLocalSizeX);
 end;
 if (fLocalSizeY>1) and ((GridCellSizePerIteration mod fLocalSizeY)<>0) then begin
  dec(fLocalSizeY,GridCellSizePerIteration mod fLocalSizeY);
 end;
 if (fLocalSizeZ>1) and ((GridCellSizePerIteration mod fLocalSizeZ)<>0) then begin
  dec(fLocalSizeZ,GridCellSizePerIteration mod fLocalSizeZ);
 end;
 fMesh.Vertices.Initialize;
 fMesh.Indices.Initialize;
 inherited Create(false);
end;

destructor TScreenMain.TUpdateThread.Destroy;
begin
 FreeAndNil(fSignedDistanceFieldComputeShaderSPVStream);
 FreeAndNil(fMeshVertexShaderSPVStream);
 FreeAndNil(fMeshFragmentShaderSPVStream);
 inherited Destroy;
end;

procedure TScreenMain.TUpdateThread.Execute;
 function GetSignedDistanceFieldComputeShaderCode:TpvUTF8String;
 begin
  result:='#version 450 core'#13#10+

          'layout(local_size_x = '+TpvUTF8String(IntToStr(fLocalSizeX))+', local_size_y = '+TpvUTF8String(IntToStr(fLocalSizeY))+', local_size_z = '+TpvUTF8String(IntToStr(fLocalSizeZ))+') in;'#13#10+

          'struct VolumeTriangleVertex {'#13#10+ // 16 floats, 64 bytes per vertex
          '  vec4 position;'#13#10+
          '  vec4 qtangent;'#13#10+
          '  vec4 parameters0;'#13#10+
          '  vec4 parameters1;'#13#10+
          '};'#13#10+

          'struct VolumeTriangle {'#13#10+ // 64 * (3 + 1) = 256 bytes per triangle
          '  VolumeTriangleVertex vertices[4];'#13#10+ // 3 plus 1 for alignment padding
          '};'#13#10+

          'layout(std430, set = 0, binding = 0) buffer ssboTriangles {'#13#10+
          '  uvec4 volumeTrianglesMetaData;'#13#10+
          '  VolumeTriangle volumeTriangles[];'#13#10+
          '};'#13#10+

          'layout(push_constant) uniform pushConstants {'#13#10+
          '  ivec4 baseGridOffset;'#13#10+
          '} uPushConstants;'#13#10+

          'const ivec3 gridSize = ivec3('+TpvUTF8String(IntToStr(fGridSizeX))+', '+TpvUTF8String(IntToStr(fGridSizeY))+', '+TpvUTF8String(IntToStr(fGridSizeZ))+');'#13#10+

          'const vec3 worldMin = vec3('+TpvUTF8String(ConvertDoubleToString(fWorldMinX,omStandard))+', '+TpvUTF8String(ConvertDoubleToString(fWorldMinY,omStandard))+','+TpvUTF8String(ConvertDoubleToString(fWorldMinZ,omStandard))+');'#13#10+

          'const vec3 worldMax = vec3('+TpvUTF8String(ConvertDoubleToString(fWorldMaxX,omStandard))+', '+TpvUTF8String(ConvertDoubleToString(fWorldMaxY,omStandard))+','+TpvUTF8String(ConvertDoubleToString(fWorldMaxZ,omStandard))+');'#13#10+

          fSignedDistanceFieldCode+#13#10+

          'const uvec4 tetbits = uvec4(0x487d210u, 0x11282844u, 0x2e71b7ecu, 0x3bde4db8u);'#13#10+
          'const uint tetbits_q = 0x16696994u;'#13#10+

          // returns the mix factor x required to interpolate two vectors given two
          // density values, such that the interpolated vector is at the position where
          // a + (b-a)*x = 0
          'float tetlerp(float a, float b) {'#13#10+
          '  float d = (b - a);'#13#10+
          '  return (abs(d) < 1e-12) ? 0.0 : ((-a) / d);'#13#10+
          '}'#13#10+

          // takes the density values at the four endpoints (> 0 = outside / not on surface)
          // and returns the indices of the triangle / quad to be generated
          // returns 0 if no triangle is to be generated
          // 1 if the result is a tri (interpolate edges x-y x-z x-w)
          // 2 if the result is a quad (interpolate edges x-z x-w y-w y-z)
          'uint tetfaces(in vec4 d, out uvec4 i) {'#13#10+
          '  uint k = ((d[0] > 0.0) ? 2u : 0u) | ((d[1] > 0.0) ? 4u : 0u) | ((d[2] > 0.0) ? 8u : 0u) | ((d[3] > 0.0) ? 16u : 0u);'#13#10+
          '  i = (tetbits >> k) & 3u;'#13#10+
          '  return (tetbits_q >> k) & 3u;'#13#10+
          '}'#13#10+

          'const uvec4 btetbits = uvec4(0x1c008000u, 0x28404000u, 0x30c00000u, 0x14404000u);'#13#10+

          // takes four binary values (0 = outside, 1 = surface / inside)
          // returns w=1 if a triangle is to be generated,
          // and the indices of the triangle in xyz
          'uvec4 btetfaces(in bvec4 d) {'#13#10+
          '    uint k = (d[0] ? 2u : 0u) | (d[1] ? 4u : 0u) | (d[2] ? 8u : 0u) | (d[3] ? 16u :0u);'#13#10+
          '    return (btetbits >> k) & 3u;'#13#10+
          '}'#13#10+

          'const vec3 offsets[8] = vec3[]('#13#10+
          '  vec3(0.0, 0.0, 0.0),'#13#10+
          '  vec3(1.0, 0.0, 0.0),'#13#10+
          '  vec3(0.0, 0.0, 1.0),'#13#10+
          '  vec3(1.0, 0.0, 1.0),'#13#10+
          '  vec3(0.0, 1.0, 0.0),'#13#10+
          '  vec3(1.0, 1.0, 0.0),'#13#10+
          '  vec3(0.0, 1.0, 1.0),'#13#10+
          '  vec3(1.0, 1.0, 1.0)'#13#10+
          ');'#13#10+

          'const ivec4 indices[6] = ivec4[]('#13#10+
          '  ivec4(4, 6, 0, 7),'#13#10+
          '  ivec4(6, 0, 7, 2),'#13#10+
          '  ivec4(0, 7, 2, 3),'#13#10+
          '  ivec4(4, 5, 7, 0),'#13#10+
          '  ivec4(1, 7, 0, 3),'#13#10+
          '  ivec4(0, 5, 7, 1)'#13#10+
          ');'#13#10+

          'vec4 matrixToQTangent(mat3 m){'#13#10+
          '  float f = 1.0;'#13#10+
          '  if(((((((m[0][0] * m[1][1] * m[2][2])+'#13#10+
          '         (m[0][1] * m[1][2] * m[2][0])'#13#10+
          '        )+'#13#10+
          '        (m[0][2] * m[1][0] * m[2][1])'#13#10+
          '       )-'#13#10+
          '       (m[0][2] * m[1][1] * m[2][0])'#13#10+
          '      )-'#13#10+
          '      (m[0][1] * m[1][0] * m[2][2])'#13#10+
          '     )-'#13#10+
          '     (m[0][0] * m[1][2] * m[2][1]))<0.0){'#13#10+
          '    f = -1.0;'#13#10+
          '    m[2] = -m[2];'#13#10+
          '  }'#13#10+
          '  float t = m[0][0] + (m[1][1] + m[2][2]);'#13#10+
          '  vec4 r;'#13#10+
          '  if(t > 2.9999999){'#13#10+
          '    r = vec4(0.0, 0.0, 0.0, 1.0);'#13#10+
          '  }else if(t > 0.0000001){'#13#10+
          '    float s = sqrt(1.0 + t) * 2.0;'#13#10+
          '    r = vec4(vec3(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0]) / s, s * 0.25);'#13#10+
          '  }else if((m[0][0] > m[1][1]) && (m[0][0] > m[2][2])){'#13#10+
          '    float s = sqrt(1.0 + (m[0][0] - (m[1][1] + m[2][2]))) * 2.0;'#13#10+
          '    r = vec4(s * 0.25, vec3(m[1][0] - m[0][1], m[2][0] - m[0][2], m[0][2] - m[2][1]) / s);'#13#10+
          '  }else if(m[1][1] > m[2][2]){'#13#10+
          '    float s = sqrt(1.0 + (m[1][1] - (m[0][0] + m[2][2]))) * 2.0;'#13#10+
          '    r = vec4(vec3(m[1][0] + m[0][1], m[2][1] + m[1][2], m[2][0] - m[0][2]) / s, s * 0.25).xwyz;'#13#10+
          '  }else{'#13#10+
          '    float s = sqrt(1.0 + (m[2][2] - (m[0][0] + m[1][1]))) * 2.0;'#13#10+
          '    r = vec4(vec3(m[2][0] + m[0][2], m[2][1] + m[1][2], m[0][1] - m[1][0]) / s, s * 0.25).xywz;'#13#10+
          '  }'#13#10+
          '  r = normalize(r);'#13#10+
          '  const float threshold = 1e-5;'#13#10+
          '  if(abs(r.w) <= threshold){'#13#10+
          '    r = vec4(r.xyz * sqrt(1.0 - (threshold * threshold)), (r.w > 0.0) ? threshold : -threshold);'#13#10+
          '  }'#13#10+
          '  if(((f < 0.0) && (r.w >= 0.0)) || ((f >= 0.0) && (r.w < 0.0))){'#13#10+
          '    r = -r;'#13#10+
          '  }'#13#10+
          '  return r;'#13#10+
          '}'#13#10+

          'void addTriangle(vec3 p0,'#13#10+
          '                 vec3 p1,'#13#10+
          '                 vec3 p2,'#13#10+
          '                 mat3 ts0,'#13#10+
          '                 mat3 ts1,'#13#10+
          '                 mat3 ts2,'#13#10+
          '                 mat2x4 mp0,'#13#10+
          '                 mat2x4 mp1,'#13#10+
          '                 mat2x4 mp2){'#13#10+
          '  if(volumeTrianglesMetaData.x < volumeTrianglesMetaData.y){'#13#10+
          '    uint triangleIndex = atomicAdd(volumeTrianglesMetaData.x, 1);'#13#10+
          '    vec3 normal = normalize(cross(normalize(p2 - p0),'#13#10+
          '                                  normalize(p1 - p0)));'#13#10+
          '    VolumeTriangle volumeTriangle;'#13#10+
          '    if(dot(normalize(ts0[2] +'#13#10+
          '                     ts1[2] +'#13#10+
          '                     ts2[2]), normal) < 0.0){'#13#10+
          '      normal = -normal;'#13#10+
          '    }'#13#10+
          '    volumeTriangle.vertices[0].position = vec4(p0, normal.x);'#13#10+
          '    volumeTriangle.vertices[1].position = vec4(p1, normal.y);'#13#10+
          '    volumeTriangle.vertices[2].position = vec4(p2, normal.z);'#13#10+
          '    volumeTriangle.vertices[0].qtangent = matrixToQTangent(ts0);'#13#10+
          '    volumeTriangle.vertices[1].qtangent = matrixToQTangent(ts1);'#13#10+
          '    volumeTriangle.vertices[2].qtangent = matrixToQTangent(ts2);'#13#10+
          '    volumeTriangle.vertices[0].parameters0 = mp0[0];'#13#10+
          '    volumeTriangle.vertices[1].parameters0 = mp1[0];'#13#10+
          '    volumeTriangle.vertices[2].parameters0 = mp2[0];'#13#10+
          '    volumeTriangle.vertices[0].parameters1 = mp0[1];'#13#10+
          '    volumeTriangle.vertices[1].parameters1 = mp1[1];'#13#10+
          '    volumeTriangle.vertices[2].parameters1 = mp2[1];'#13#10+
          '    volumeTriangles[triangleIndex] = volumeTriangle;'#13#10+
          '  }'#13#10+
          '}'#13#10+

          'void getTangentSpaceBasisFromNormal(vec3 n, out vec3 t, out vec3 b){'#13#10+
          '  float s = (n.z >= 0.0) ? 1.0 : -1.0, c = n.y / (1.0 + abs(n.z)), d = n.y * c, e = -n.x * c;'#13#10+
          '  t = normalize(vec3(n.z + (s * d), (s * e), -n.x));'#13#10+
          '  b = normalize(vec3(e, 1.0 - d, -s * n.y));'#13#10+
{         '  b = normalize(cross(n, t));'#13#10+
          '  t = normalize(cross(b, n));'#13#10+}
(*        '  b = vec3(n.z, n.y, -n.x);'#13#10+
          '  t = vec3(-n.x, n.z, -n.y);'#13#10+*)
(*        '  vec3 tc = vec3((1.0 + n.z) - (n.xy * n.xy), -n.x * n.y) / (1.0 + n.z);'#13#10+
          '  t = (n.z < -0.999999) ? vec3(0.0, -1.0, 0.0) : vec3(tc.x, tc.z, -n.x);'#13#10+
          '  b = (n.z < -0.999999) ? vec3(-1.0, 0.0, 0.0) : vec3(tc.z, tc.y, -n.y);'#13#10+*)
          '}'#13#10+

          'void main(){'#13#10+
          '  ivec3 gridPositionBase = uPushConstants.baseGridOffset.xyz + ivec3(gl_GlobalInvocationID.xyz);'#13#10+
          '  if(all(greaterThanEqual(gridPositionBase, ivec3(0))) &&'#13#10+
          '     all(lessThan(gridPositionBase, ivec3(gridSize)))){'#13#10+
          '    const vec3 s = vec3(gridSize),'#13#10+
          '               si = vec3(1.0) / s;'#13#10+
          '    const vec2 e = vec2(0.0, normalOffsetFactor);'#13#10+
          '    vec3 ap[8], an[8], at[8], ab[8];'#13#10+
          '    float ad[8];'#13#10+
          '    mat2x4 amp[8];'#13#10+
          '    for(int i = 0; i < 8; i++){'#13#10+
          '      vec3 p = mix(worldMin, worldMax, (vec3(gridPositionBase) + offsets[i]) * si);'#13#10+
          '      vec3 n = normalize(vec3(getDistance(p + e.yxx) - getDistance(p - e.yxx),'#13#10+
          '                              getDistance(p + e.xyx) - getDistance(p - e.xyx),'#13#10+
          '                              getDistance(p + e.xxy) - getDistance(p - e.xxy)));'#13#10+
          '      ap[i] = p;'#13#10+
          '      an[i] = n;'#13#10+
          '      getTangentSpaceBasisFromNormal(n, at[i], ab[i]);'#13#10+
          '      ad[i] = getDistance(p);'#13#10+
          '      amp[i] = getParameters(p);'#13#10+
          '    }'#13#10+
          '    for(int i = 0; i < 6; i++){'#13#10+
          '      ivec4 t = indices[i];'#13#10+
          '      vec4 d = vec4(ad[t.x], ad[t.y], ad[t.z], ad[t.w]);'#13#10+
          '      uvec4 j;'#13#10+
          '      uint c = tetfaces(d, j);'#13#10+
          '      if(c == 1u){'#13#10+
          '        vec3 w0 = vec3(tetlerp(d[j.x], d[j.y]),'#13#10+
          '                       tetlerp(d[j.x], d[j.z]),'#13#10+
          '                       tetlerp(d[j.x], d[j.w]));'#13#10+
          '        addTriangle(mix(ap[t[j.x]], ap[t[j.y]], w0.x),'#13#10+
          '                    mix(ap[t[j.x]], ap[t[j.z]], w0.y),'#13#10+
          '                    mix(ap[t[j.x]], ap[t[j.w]], w0.z),'#13#10+
          '                    mat3('#13#10+
          '                      normalize(mix(at[t[j.x]], at[t[j.y]], w0.x)),'#13#10+
          '                      normalize(mix(ab[t[j.x]], ab[t[j.y]], w0.x)),'#13#10+
          '                      normalize(mix(an[t[j.x]], an[t[j.y]], w0.x))'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      normalize(mix(at[t[j.x]], at[t[j.z]], w0.y)),'#13#10+
          '                      normalize(mix(ab[t[j.x]], ab[t[j.z]], w0.y)),'#13#10+
          '                      normalize(mix(an[t[j.x]], an[t[j.z]], w0.y))'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      normalize(mix(at[t[j.x]], at[t[j.w]], w0.z)),'#13#10+
          '                      normalize(mix(ab[t[j.x]], ab[t[j.w]], w0.z)),'#13#10+
          '                      normalize(mix(an[t[j.x]], an[t[j.w]], w0.z))'#13#10+
          '                    ),'#13#10+
          '                    (amp[t[j.x]] * (1.0 - w0.x)) + (amp[t[j.y]] * w0.x),'#13#10+
          '                    (amp[t[j.x]] * (1.0 - w0.y)) + (amp[t[j.z]] * w0.y),'#13#10+
          '                    (amp[t[j.x]] * (1.0 - w0.z)) + (amp[t[j.w]] * w0.z)'#13#10+
          '                   );'#13#10+
          '      }else if(c == 2u){'#13#10+
          '        vec4 w0 = vec4(tetlerp(d[j.x], d[j.z]),'#13#10+
          '                       tetlerp(d[j.x], d[j.w]),'#13#10+
          '                       tetlerp(d[j.y], d[j.w]),'#13#10+
          '                       tetlerp(d[j.y], d[j.z]));'#13#10+
          '        vec3 p0 = mix(ap[t[j.x]], ap[t[j.z]], w0.x),'#13#10+
          '             p1 = mix(ap[t[j.x]], ap[t[j.w]], w0.y),'#13#10+
          '             p2 = mix(ap[t[j.y]], ap[t[j.w]], w0.z),'#13#10+
          '             p3 = mix(ap[t[j.y]], ap[t[j.z]], w0.w),'#13#10+
          '             n0 = normalize(mix(an[t[j.x]], an[t[j.z]], w0.x)),'#13#10+
          '             n1 = normalize(mix(an[t[j.x]], an[t[j.w]], w0.y)),'#13#10+
          '             n2 = normalize(mix(an[t[j.y]], an[t[j.w]], w0.z)),'#13#10+
          '             n3 = normalize(mix(an[t[j.y]], an[t[j.z]], w0.w)),'#13#10+
          '             t0 = normalize(mix(at[t[j.x]], at[t[j.z]], w0.x)),'#13#10+
          '             t1 = normalize(mix(at[t[j.x]], at[t[j.w]], w0.y)),'#13#10+
          '             t2 = normalize(mix(at[t[j.y]], at[t[j.w]], w0.z)),'#13#10+
          '             t3 = normalize(mix(at[t[j.y]], at[t[j.z]], w0.w)),'#13#10+
          '             b0 = normalize(mix(ab[t[j.x]], ab[t[j.z]], w0.x)),'#13#10+
          '             b1 = normalize(mix(ab[t[j.x]], ab[t[j.w]], w0.y)),'#13#10+
          '             b2 = normalize(mix(ab[t[j.y]], ab[t[j.w]], w0.z)),'#13#10+
          '             b3 = normalize(mix(ab[t[j.y]], ab[t[j.z]], w0.w));'#13#10+
          '        mat2x4 mp0 = (amp[t[j.x]] * (1.0 - w0.x)) + (amp[t[j.z]] * w0.x),'#13#10+
          '               mp1 = (amp[t[j.x]] * (1.0 - w0.y)) + (amp[t[j.w]] * w0.y),'#13#10+
          '               mp2 = (amp[t[j.y]] * (1.0 - w0.z)) + (amp[t[j.w]] * w0.z),'#13#10+
          '               mp3 = (amp[t[j.y]] * (1.0 - w0.w)) + (amp[t[j.z]] * w0.w);'#13#10+
          '        addTriangle(p0,'#13#10+
          '                    p1,'#13#10+
          '                    p2,'#13#10+
          '                    mat3('#13#10+
          '                      t0,'#13#10+
          '                      b0,'#13#10+
          '                      n0'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      t1,'#13#10+
          '                      b1,'#13#10+
          '                      n1'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      t2,'#13#10+
          '                      b2,'#13#10+
          '                      n2'#13#10+
          '                    ),'#13#10+
          '                    mp0,'#13#10+
          '                    mp1,'#13#10+
          '                    mp2'#13#10+
          '                   );'#13#10+
          '        addTriangle(p2,'#13#10+
          '                    p3,'#13#10+
          '                    p0,'#13#10+
          '                    mat3('#13#10+
          '                      t2,'#13#10+
          '                      b2,'#13#10+
          '                      n2'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      t3,'#13#10+
          '                      b3,'#13#10+
          '                      n3'#13#10+
          '                    ),'#13#10+
          '                    mat3('#13#10+
          '                      t0,'#13#10+
          '                      b0,'#13#10+
          '                      n0'#13#10+
          '                    ),'#13#10+
          '                    mp2,'#13#10+
          '                    mp3,'#13#10+
          '                    mp0'#13#10+
          '                   );'#13#10+
          '      }'#13#10+
          '    }'#13#10+
          '  }'#13#10+

          '}'#13#10;
 end;
 function GetMeshVertexShaderCode:TpvUTF8String;
 begin
  result:='#version 450 core'#13#10+
          'layout(location = 0) in vec3 inPosition;'#13#10+
          'layout(location = 1) in vec4 inQTangent;'#13#10+
          'layout(location = 2) in vec4 inParameters0;'#13#10+
          'layout(location = 3) in vec4 inParameters1;'#13#10+
          'layout(location = 0) out vec3 outPosition;'#13#10+
          'layout(location = 1) out vec3 outViewSpacePosition;'#13#10+
          'layout(location = 2) out mat3 outTangentSpace;'#13#10+
          'layout(location = 5) out mat2x4 outParameters;'#13#10+
          'layout(binding = 0) uniform UBO {'#13#10+
          '	mat4 modelViewMatrix;'#13#10+
          '	mat4 modelViewProjectionMatrix;'#13#10+
          '	mat4 modelViewNormalMatrix;'#13#10+
          '} ubo;'#13#10+
(*        'layout(push_constant) uniform pushConstants {'#13#10+
          '  mat4 modelViewMatrix;'#13#10+
          '  mat4 modelViewProjectionMatrix;'#13#10+
          '} uPushConstants;'#13#10+*)
          'mat3 qTangentToMatrix(vec4 q){'#13#10+
          '  q = normalize(q);'#13#10+
          '  float qx2 = q.x + q.x,'#13#10+
          '        qy2 = q.y + q.y,'#13#10+
          '        qz2 = q.z + q.z,'#13#10+
          '        qxqx2 = q.x * qx2,'#13#10+
          '        qxqy2 = q.x * qy2,'#13#10+
          '        qxqz2 = q.x * qz2,'#13#10+
          '        qxqw2 = q.w * qx2,'#13#10+
          '        qyqy2 = q.y * qy2,'#13#10+
          '        qyqz2 = q.y * qz2,'#13#10+
          '        qyqw2 = q.w * qy2,'#13#10+
          '        qzqz2 = q.z * qz2,'#13#10+
          '        qzqw2 = q.w * qz2;'#13#10+
          '  mat3 m = mat3(1.0 - (qyqy2 + qzqz2), qxqy2 + qzqw2, qxqz2 - qyqw2,'#13#10+
          '                qxqy2 - qzqw2, 1.0 - (qxqx2 + qzqz2), qyqz2 + qxqw2,'#13#10+
          '                qxqz2 + qyqw2, qyqz2 - qxqw2, 1.0 - (qxqx2 + qyqy2));'#13#10+
          '  m[2] = normalize(cross(m[0], m[1])) * ((q.w < 0.0) ? -1.0 : 1.0);'#13#10+
          '  return m;'#13#10+
          '}'#13#10+
          'void main(){'#13#10+
          '  outTangentSpace = mat3(ubo.modelViewNormalMatrix) * qTangentToMatrix(inQTangent);'#13#10+
          '  outParameters = mat2x4(inParameters0, inParameters1);'#13#10+
          '  outViewSpacePosition = (ubo.modelViewMatrix * vec4(inPosition, 1.0)).xyz;'#13#10+
          '  gl_Position = ubo.modelViewProjectionMatrix * vec4(inPosition, 1.0);'#13#10+
          '}'#13#10;
 end;
 function GetMeshFragmentShaderCode:TpvUTF8String;
 begin
  result:='#version 450 core'#13#10+
          'layout(location = 0) in vec3 inPosition;'#13#10+
          'layout(location = 1) in vec3 inViewSpacePosition;'#13#10+
          'layout(location = 2) in mat3 inTangentSpace;'#13#10+
          'layout(location = 5) in mat2x4 inParameters;'#13#10+
          'layout(location = 0) out vec4 outColor;'#13#10+
          fMeshFragmentCode+#13#10+
          'void main(){'#13#10+
          '  outColor = getFragmentColor(inPosition,'#13#10+
          '                              inTangentSpace,'#13#10+
          '                              inParameters,'#13#10+
          '                              normalize(inViewSpacePosition));'#13#10+
          '}'#13#10;
 end;
 procedure WriteFile(const aFileName:string;const aCode:TpvUTF8String);
 var FileStream:TFileStream;
 begin
  FileStream:=TFileStream.Create(aFileName,fmCreate);
  try
   if length(aCode)>0 then begin
    FileStream.WriteBuffer(aCode[1],length(aCode));
   end;
  finally
   FreeAndNil(FileStream);
  end;
 end;
type TVertexIndexHashMap=TpvHashMap<TVertex,TpvUInt32>;
var TriangleIndex,TriangleVertexIndex:TpvSizeInt;
    MaxGridCells,GridCells:TpvInt64;
    SignedDistanceFieldComputeShaderGLSLFile,
    SignedDistanceFieldComputeShaderSPVFile,
    MeshVertexShaderGLSLFile,
    MeshVertexShaderSPVFile,
    MeshFragmentShaderGLSLFile,
    MeshFragmentShaderSPVFile:string;
    OutputString,
    ErrorString:UnicodeString;
    SignedDistanceFieldComputeShaderModule:TpvVulkanShaderModule;
    SignedDistanceFieldComputePipelineShaderStage:TpvVulkanPipelineShaderStage;
    SignedDistanceFieldComputeDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    SignedDistanceFieldComputePipelineLayout:TpvVulkanPipelineLayout;
    SignedDistanceFieldComputePipeline:TpvVulkanComputePipeline;
    SignedDistanceFieldComputeDescriptorPool:TpvVulkanDescriptorPool;
    SignedDistanceFieldComputeDescriptorSet:TpvVulkanDescriptorSet;
    SignedDistanceFieldComputeCommandPool:TpvVulkanCommandPool;
    SignedDistanceFieldComputeCommandBuffer:TpvVulkanCommandBuffer;
    SignedDistanceFieldComputeTransferCommandPool:TpvVulkanCommandPool;
    SignedDistanceFieldComputeTransferCommandBuffer:TpvVulkanCommandBuffer;
    SignedDistanceFieldComputeTransferCommandBufferFence:TpvVulkanFence;
    VertexIndexHashMap:TVertexIndexHashMap;
    VertexIndex:TpvUInt32;
    Triangle:PVolumeTriangle;
    Vertex:PVertex;
begin
 ErrorString:='';
 try
  TPasMPInterlocked.Write(fProgress,0);
  try
   SignedDistanceFieldComputeShaderGLSLFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_compute_'+IntToStr(GetTickCount),'.glsl');
   SignedDistanceFieldComputeShaderSPVFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_compute_'+IntToStr(GetTickCount),'.spv');
   WriteFile(SignedDistanceFieldComputeShaderGLSLFile,GetSignedDistanceFieldComputeShaderCode);
   try
    if ExecuteCommand(ExtractFilePath(String(fScreenMain.fVulkanGLSLCPath)),
                      String(fScreenMain.fVulkanGLSLCPath),
                      ['--target-env=vulkan1.0',
                       '-x','glsl',
                       '-fshader-stage=comp',
                       '-fentry-point=main',
                       '-O',
                       '-o',SignedDistanceFieldComputeShaderSPVFile,
                       SignedDistanceFieldComputeShaderGLSLFile],
                      OutputString)=0 then begin
     if FileExists(SignedDistanceFieldComputeShaderSPVFile) then begin
      fSignedDistanceFieldComputeShaderSPVStream.LoadFromFile(SignedDistanceFieldComputeShaderSPVFile);
     end;
    end else begin
     ErrorString:=ErrorString+OutputString;
    end;
   finally
    if FileExists(SignedDistanceFieldComputeShaderGLSLFile) then begin
     DeleteFile(SignedDistanceFieldComputeShaderGLSLFile);
    end;
    if FileExists(SignedDistanceFieldComputeShaderSPVFile) then begin
     DeleteFile(SignedDistanceFieldComputeShaderSPVFile);
    end;
   end;
  finally
  end;
  TPasMPInterlocked.Write(fProgress,2048);
  try
   MeshVertexShaderGLSLFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_vertex_'+IntToStr(GetTickCount),'.glsl');
   MeshVertexShaderSPVFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_vertex_'+IntToStr(GetTickCount),'.spv');
   WriteFile(MeshVertexShaderGLSLFile,GetMeshVertexShaderCode);
   try
    if ExecuteCommand(ExtractFilePath(String(fScreenMain.fVulkanGLSLCPath)),
                      String(fScreenMain.fVulkanGLSLCPath),
                      ['--target-env=vulkan1.0',
                       '-x','glsl',
                       '-fshader-stage=vert',
                       '-fentry-point=main',
                       '-O',
                       '-o',MeshVertexShaderSPVFile,
                       MeshVertexShaderGLSLFile],
                      OutputString)=0 then begin
     if FileExists(MeshVertexShaderSPVFile) then begin
      fMeshVertexShaderSPVStream.LoadFromFile(MeshVertexShaderSPVFile);
     end;
    end else begin
     ErrorString:=ErrorString+OutputString;
    end;
   finally
    if FileExists(MeshVertexShaderGLSLFile) then begin
     DeleteFile(MeshVertexShaderGLSLFile);
    end;
    if FileExists(MeshVertexShaderSPVFile) then begin
     DeleteFile(MeshVertexShaderSPVFile);
    end;
   end;
  finally
  end;
  try
   MeshFragmentShaderGLSLFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_fragment_'+IntToStr(GetTickCount),'.glsl');
   MeshFragmentShaderSPVFile:=IncludeTrailingPathDelimiter(String(fScreenMain.fTemporaryDirectory))+ChangeFileExt('sdfmeshgen_fragment_'+IntToStr(GetTickCount),'.spv');
   WriteFile(MeshFragmentShaderGLSLFile,GetMeshFragmentShaderCode);
   try
    if ExecuteCommand(ExtractFilePath(String(fScreenMain.fVulkanGLSLCPath)),
                      String(fScreenMain.fVulkanGLSLCPath),
                      ['--target-env=vulkan1.0',
                       '-x','glsl',
                       '-fshader-stage=frag',
                       '-fentry-point=main',
                       '-O',
                       '-o',MeshFragmentShaderSPVFile,
                       MeshFragmentShaderGLSLFile],
                      OutputString)=0 then begin
     if FileExists(MeshFragmentShaderSPVFile) then begin
      fMeshFragmentShaderSPVStream.LoadFromFile(MeshFragmentShaderSPVFile);
     end;
    end else begin
     ErrorString:=ErrorString+OutputString;
    end;
   finally
    if FileExists(MeshFragmentShaderGLSLFile) then begin
     DeleteFile(MeshFragmentShaderGLSLFile);
    end;
    if FileExists(MeshFragmentShaderSPVFile) then begin
     DeleteFile(MeshFragmentShaderSPVFile);
    end;
   end;
  finally
  end;
  TPasMPInterlocked.Write(fProgress,4096);
  if (length(ErrorString)=0) and (fSignedDistanceFieldComputeShaderSPVStream.Size>0) then begin
   SignedDistanceFieldComputeShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,
                                                                        fSignedDistanceFieldComputeShaderSPVStream);
   try
    TPasMPInterlocked.Write(fProgress,4608);
    SignedDistanceFieldComputePipelineShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,
                                                                                       SignedDistanceFieldComputeShaderModule,
                                                                                       'main');
    try
     SignedDistanceFieldComputePipelineShaderStage.Initialize;
     TPasMPInterlocked.Write(fProgress,5120);
     SignedDistanceFieldComputeDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
     try
      SignedDistanceFieldComputeDescriptorSetLayout.AddBinding(0,
                                                               VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                               1,
                                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                               []);
      SignedDistanceFieldComputeDescriptorSetLayout.Initialize;
      TPasMPInterlocked.Write(fProgress,5632);
      SignedDistanceFieldComputeDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                               1);
      try
       SignedDistanceFieldComputeDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1);
       SignedDistanceFieldComputeDescriptorPool.Initialize;
       TPasMPInterlocked.Write(fProgress,6144);
       SignedDistanceFieldComputeDescriptorSet:=TpvVulkanDescriptorSet.Create(SignedDistanceFieldComputeDescriptorPool,
                                                                              SignedDistanceFieldComputeDescriptorSetLayout);
       try
        SignedDistanceFieldComputeDescriptorSet.WriteToDescriptorSet(0,
                                                                     0,
                                                                     1,
                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                     [],
                                                                     [fScreenMain.fVolumeTriangleBuffer.DescriptorBufferInfo],
                                                                     [],
                                                                     false
                                                                    );
        SignedDistanceFieldComputeDescriptorSet.Flush;
        TPasMPInterlocked.Write(fProgress,6656);
        SignedDistanceFieldComputePipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
        try
         SignedDistanceFieldComputePipelineLayout.AddDescriptorSetLayout(SignedDistanceFieldComputeDescriptorSetLayout);
         SignedDistanceFieldComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                                       0,
                                                                       SizeOf(TComputePushConstants));
         SignedDistanceFieldComputePipelineLayout.Initialize;
         TPasMPInterlocked.Write(fProgress,7168);
         SignedDistanceFieldComputePipeline:=TpvVulkanComputePipeline.Create(pvApplication.VulkanDevice,
                                                                             pvApplication.VulkanPipelineCache,
                                                                             0,
                                                                             SignedDistanceFieldComputePipelineShaderStage,
                                                                             SignedDistanceFieldComputePipelineLayout,
                                                                             nil,
                                                                             0);
         try
          TPasMPInterlocked.Write(fProgress,7680);
          SignedDistanceFieldComputeCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                                             pvApplication.VulkanDevice.ComputeQueueFamilyIndex,
                                                                             TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
          try
           TPasMPInterlocked.Write(fProgress,7808);
           SignedDistanceFieldComputeCommandBuffer:=TpvVulkanCommandBuffer.Create(SignedDistanceFieldComputeCommandPool,
                                                                                  VK_COMMAND_BUFFER_LEVEL_PRIMARY);
           try
            TPasMPInterlocked.Write(fProgress,7936);
            SignedDistanceFieldComputeTransferCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                                                       pvApplication.VulkanDevice.TransferQueueFamilyIndex,
                                                                                       TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
            try
             TPasMPInterlocked.Write(fProgress,7968);
             SignedDistanceFieldComputeTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(SignedDistanceFieldComputeTransferCommandPool,
                                                                                            VK_COMMAND_BUFFER_LEVEL_PRIMARY);
             try
              TPasMPInterlocked.Write(fProgress,8000);
              SignedDistanceFieldComputeTransferCommandBufferFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);
              try
               TPasMPInterlocked.Write(fProgress,8064);
               VertexIndexHashMap:=TVertexIndexHashMap.Create(0);
               try
                TPasMPInterlocked.Write(fProgress,8192);
                MaxGridCells:=fGridSizeX*fGridSizeY*fGridSizeZ;
                fComputePushConstants.GridOffsetZ:=0;
                while fComputePushConstants.GridOffsetZ<fGridSizeZ do begin
                 fComputePushConstants.GridOffsetY:=0;
                 while fComputePushConstants.GridOffsetY<fGridSizeY do begin
                  fComputePushConstants.GridOffsetX:=0;
                  while fComputePushConstants.GridOffsetX<fGridSizeX do begin
                   fScreenMain.fVolumeTriangles.MetaData.Count:=0;
                   fScreenMain.fVolumeTriangles.MetaData.MaxCount:=MaxTrianglesPerIteration;
                   fScreenMain.fVolumeTriangleBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                                                SignedDistanceFieldComputeTransferCommandBuffer,
                                                                SignedDistanceFieldComputeTransferCommandBufferFence,
                                                                fScreenMain.fVolumeTriangles.MetaData,
                                                                0,
                                                                SizeOf(TVolumeTrianglesMetaData),
                                                                TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic);
                   SignedDistanceFieldComputeCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT),nil);
                   SignedDistanceFieldComputeCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                                           SignedDistanceFieldComputePipeline.Handle);
                   SignedDistanceFieldComputeCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                                                 SignedDistanceFieldComputePipelineLayout.Handle,
                                                                                 0,
                                                                                 1,
                                                                                 @SignedDistanceFieldComputeDescriptorSet.Handle,
                                                                                 0,
                                                                                 nil);
                   SignedDistanceFieldComputeCommandBuffer.CmdPushConstants(SignedDistanceFieldComputePipelineLayout.Handle,
                                                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                                            0,
                                                                            SizeOf(TComputePushConstants),
                                                                            @fComputePushConstants);
                   SignedDistanceFieldComputeCommandBuffer.CmdDispatch(GridCellSizePerIteration div fLocalSizeX,
                                                                       GridCellSizePerIteration div fLocalSizeY,
                                                                       GridCellSizePerIteration div fLocalSizeZ);
                   SignedDistanceFieldComputeCommandBuffer.EndRecording;
                   SignedDistanceFieldComputeCommandBuffer.Execute(pvApplication.VulkanDevice.ComputeQueue,
                                                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                                                   nil,
                                                                   nil,
                                                                   SignedDistanceFieldComputeTransferCommandBufferFence,
                                                                   true);
                   fScreenMain.fVolumeTriangleBuffer.DownloadData(pvApplication.VulkanDevice.TransferQueue,
                                                                  SignedDistanceFieldComputeTransferCommandBuffer,
                                                                  SignedDistanceFieldComputeTransferCommandBufferFence,
                                                                  fScreenMain.fVolumeTriangles.MetaData,
                                                                  0,
                                                                  SizeOf(TVolumeTrianglesMetaData),
                                                                  TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic);
 //                writeln(fScreenMain.fVolumeTriangles.MetaData.Count);
                   fScreenMain.fVolumeTriangleBuffer.DownloadData(pvApplication.VulkanDevice.TransferQueue,
                                                                  SignedDistanceFieldComputeTransferCommandBuffer,
                                                                  SignedDistanceFieldComputeTransferCommandBufferFence,
                                                                  fScreenMain.fVolumeTriangles,
                                                                  0,
                                                                  SizeOf(TVolumeTrianglesMetaData)+(TpvSizeInt(fScreenMain.fVolumeTriangles.MetaData.Count)*SizeOf(TVolumeTriangle)),
                                                                  TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic);
                   for TriangleIndex:=0 to TpvSizeInt(fScreenMain.fVolumeTriangles.MetaData.Count)-1 do begin
                    Triangle:=@fScreenMain.fVolumeTriangles.Triangles[TriangleIndex];
                    for TriangleVertexIndex:=0 to 2 do begin
                     Vertex:=@Triangle^.Vertices[TriangleVertexIndex];
                     Vertex^.Position.w:=0.0;
                     if not VertexIndexHashMap.TryGet(Vertex^,VertexIndex) then begin
                      VertexIndex:=fMesh.Vertices.Add(Vertex^);
                      VertexIndexHashMap.Add(Vertex^,VertexIndex);
                     end;
                     fMesh.Indices.Add(VertexIndex);
                    end;
                   end;
                   GridCells:=Min(MaxGridCells,
                                  GridCells+(GridCellSizePerIteration*
                                             GridCellSizePerIteration*
                                             GridCellSizePerIteration));
                   TPasMPInterlocked.Write(fProgress,Min(8192+(GridCells*TpvInt64(65535-8192)) div MaxGridCells,TpvInt64(65535)));
                   fComputePushConstants.GridOffsetX:=fComputePushConstants.GridOffsetX+GridCellSizePerIteration;
                  end;
                  fComputePushConstants.GridOffsetY:=fComputePushConstants.GridOffsetY+GridCellSizePerIteration;
                 end;
                 fComputePushConstants.GridOffsetZ:=fComputePushConstants.GridOffsetZ+GridCellSizePerIteration;
                end;
               finally
                FreeAndNil(VertexIndexHashMap);
               end;
               fMesh.Vertices.Finish;
               fMesh.Indices.Finish;
              finally
               FreeAndNil(SignedDistanceFieldComputeTransferCommandBufferFence);
              end;
             finally
              FreeAndNil(SignedDistanceFieldComputeTransferCommandBuffer);
             end;
            finally
             FreeAndNil(SignedDistanceFieldComputeTransferCommandPool);
            end;
           finally
            FreeAndNil(SignedDistanceFieldComputeCommandBuffer);
           end;
          finally
           FreeAndNil(SignedDistanceFieldComputeCommandPool);
          end;
         finally
          FreeAndNil(SignedDistanceFieldComputePipeline);
         end;
        finally
         FreeAndNil(SignedDistanceFieldComputePipelineLayout);
        end;
       finally
        FreeAndNil(SignedDistanceFieldComputeDescriptorSet);
       end;
      finally
       FreeAndNil(SignedDistanceFieldComputeDescriptorPool);
      end;
     finally
      FreeAndNil(SignedDistanceFieldComputeDescriptorSetLayout);
     end;
    finally
     FreeAndNil(SignedDistanceFieldComputePipelineShaderStage);
    end;
   finally
    FreeAndNil(SignedDistanceFieldComputeShaderModule);
   end;
  end;
 finally
  try
   fErrorString:=TpvUTF8String(ErrorString);
  finally
   ErrorString:='';
  end;
 end;
 TPasMPInterlocked.Write(fProgress,65535);
end;

{ TScreenMain.TMeshVulkanCanvas }

constructor TScreenMain.TMeshVulkanCanvas.Create(const aParent:TpvGUIObject;
                                                 const aMesh:TMesh;
                                                 const aVertexShaderStream:TStream;
                                                 const aFragmentShaderStream:TStream;
                                                 const aRadius:TpvFloat);
var Index:TpvInt32;
begin

 inherited Create(aParent);

 fRadius:=aRadius;

 fMesh:=aMesh;

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

 fCubeVertexShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,aVertexShaderStream);

 fCubeFragmentShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,aFragmentShaderStream);

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
                                             fMesh.Vertices.Count*SizeOf(TVertex),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
 fVulkanVertexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                fVulkanTransferCommandBuffer,
                                fVulkanTransferCommandBufferFence,
                                fMesh.Vertices.Items[0],
                                0,
                                fMesh.Vertices.Count*SizeOf(TVertex),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 fVulkanIndexBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                            fMesh.Indices.Count*SizeOf(TpvUInt32),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                           );
 fVulkanIndexBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                               fVulkanTransferCommandBuffer,
                               fVulkanTransferCommandBufferFence,
                               fMesh.Indices.Items[0],
                               0,
                               fMesh.Indices.Count*SizeOf(TpvUInt32),
                               TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanUniformBuffers[Index]:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                                       SizeOf(TUniformBuffer),
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
                                          SizeOf(TUniformBuffer),
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

destructor TScreenMain.TMeshVulkanCanvas.Destroy;
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

procedure TScreenMain.TMeshVulkanCanvas.AcquireVolatileResources;
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
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32B32A32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.QTantent)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32A32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Parameters0)));
 fVulkanGraphicsPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32G32B32A32_SFLOAT,TVkPtrUInt(pointer(@PVertex(nil)^.Parameters1)));

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.DynamicViewPorts:=true;

 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,pvApplication.VulkanSwapChain.Width,pvApplication.VulkanSwapChain.Height);
 fVulkanGraphicsPipeline.ViewPortState.DynamicScissors:=true;

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
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

procedure TScreenMain.TMeshVulkanCanvas.ReleaseVolatileResources;
begin
 FreeAndNil(fVulkanGraphicsPipeline);
 inherited ReleaseVolatileResources;
end;

procedure TScreenMain.TMeshVulkanCanvas.Update;
const f0=1.0/(2.0*pi);
      f1=0.5/(2.0*pi);
begin
 fState.Time:=fState.Time+Instance.DeltaTime;
 fState.AnglePhases[0]:=frac(fState.AnglePhases[0]+(Instance.DeltaTime*f0));
 fState.AnglePhases[1]:=frac(fState.AnglePhases[1]+(Instance.DeltaTime*f1));
 fStates[pvApplication.UpdateInFlightFrameIndex]:=fState;
 inherited Update;
end;

procedure TScreenMain.TMeshVulkanCanvas.UpdateContent(const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
begin
end;

procedure TScreenMain.TMeshVulkanCanvas.DrawContent(const aVulkanCommandBuffer:TpvVulkanCommandBuffer;const aBufferIndex:TpvInt32;const aDrawRect,aClipRect:TpvRect);
var ViewPort:TVkViewPort;
    ScissorRect:TVkRect2D;
    ClearAttachments:array[0..1] of TVkClearAttachment;
    ClearRects:array[0..1] of TVkClearRect;
    ModelMatrix:TpvMatrix4x4;
    ViewMatrix:TpvMatrix4x4;
    ProjectionMatrix:TpvMatrix4x4;
    State:PState;
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
  ViewMatrix:=TpvMatrix4x4.CreateTranslation(0.0,0.0,-(fRadius*1.0));
  ProjectionMatrix:=TpvMatrix4x4.CreatePerspectiveRightHandedZeroToOne(45.0,aDrawRect.Width/aDrawRect.Height,1.0,(fRadius*10.0))*
                    TpvMatrix4x4.FlipYClipSpace;

  fUniformBuffer.ModelViewMatrix:=ModelMatrix*ViewMatrix;
  fUniformBuffer.ModelViewProjectionMatrix:=fUniformBuffer.ModelViewMatrix*ProjectionMatrix;
  fUniformBuffer.ModelViewNormalMatrix:=TpvMatrix4x4.Create(fUniformBuffer.ModelViewMatrix.ToMatrix3x3.Inverse.Transpose);

  p:=fVulkanUniformBuffers[pvApplication.DrawInFlightFrameIndex].Memory.MapMemory(0,SizeOf(TUniformBuffer));
  if assigned(p) then begin
   try
    Move(fUniformBuffer,p^,SizeOf(TUniformBuffer));
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
  aVulkanCommandBuffer.CmdDrawIndexed(fMesh.Indices.Count,1,0,0,0);

 end;

end;

{ TScreenMain }

constructor TScreenMain.Create;
begin
 inherited Create;

 ScreenMain:=self;

 fUpdateThread:=nil;

 fReady:=false;

 fModified:=false;

 fNewProjectMessageDialogVisible:=false;

 fTerminationMessageDialogVisible:=false;

 fMesh.Vertices.Initialize;
 fMesh.Indices.Initialize;

 fTime:=0.48;

 fLastMousePosition:=TpvVector2.Null;

 fLastMouseButtons:=[];

 fFileName:='';

 fFileNameToDelayedOpen:='';

 fTemporaryDirectory:=TpvUTF8String(IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')));
 if (length(fTemporaryDirectory)<2) or not DirectoryExists(ExcludeTrailingPathDelimiter(String(fTemporaryDirectory))) then begin
{$ifdef fpc}
  fTemporaryDirectory:=TpvUTF8String(IncludeTrailingPathDelimiter(SysUtils.GetTempDir));
{$else}
  fTemporaryDirectory:=TpvUTF8String(IncludeTrailingPathDelimiter(System.IOUtils.TPath.GetTempPath));
{$endif}
 end;

 fVulkanSDKPath:=TpvUTF8String(GetEnvironmentVariable('VULKAN_SDK'));
 if length(fVulkanSDKPath)>0 then begin
  fVulkanSDKPath:=TpvUTF8String(IncludeTrailingPathDelimiter(ExpandFileName(String(fVulkanSDKPath))));
  fVulkanSDKFound:=DirectoryExists(ExcludeTrailingPathDelimiter(String(fVulkanSDKPath)));
  fVulkanGLSLCPath:=IncludeTrailingPathDelimiter(fVulkanSDKPath+'Bin64')+'glslc'{$ifdef Windows}+'.exe'{$endif};
  fVulkanGLSLCFound:=FileExists(ExcludeTrailingPathDelimiter(String(fVulkanGLSLCPath)));
  if not fVulkanGLSLCFound then begin
   fVulkanGLSLCPath:=IncludeTrailingPathDelimiter(fVulkanSDKPath+'bin64')+'glslc'{$ifdef Windows}+'.exe'{$endif};
   fVulkanGLSLCFound:=FileExists(ExcludeTrailingPathDelimiter(String(fVulkanGLSLCPath)));
   if not fVulkanGLSLCFound then begin
    fVulkanGLSLCPath:=IncludeTrailingPathDelimiter(fVulkanSDKPath+'Bin')+'glslc'{$ifdef Windows}+'.exe'{$endif};
    fVulkanGLSLCFound:=FileExists(ExcludeTrailingPathDelimiter(String(fVulkanGLSLCPath)));
    if not fVulkanGLSLCFound then begin
     fVulkanGLSLCPath:=IncludeTrailingPathDelimiter(fVulkanSDKPath+'bin')+'glslc'{$ifdef Windows}+'.exe'{$endif};
     fVulkanGLSLCFound:=FileExists(ExcludeTrailingPathDelimiter(String(fVulkanGLSLCPath)));
    end;
   end;
  end;
 end else begin
  fVulkanSDKFound:=false;
  fVulkanGLSLCFound:=false;
 end;

{$ifndef Windows}
 if not fVulkanGLSLCFound then begin
  fVulkanGLSLCPath:='/usr/bin/glslc';
  fVulkanGLSLCFound:=FileExists(ExcludeTrailingPathDelimiter(String(fVulkanGLSLCPath)));
  if fVulkanGLSLCFound then begin
   fVulkanSDKFound:=true;
  end;
 end;
{$endif}

end;

destructor TScreenMain.Destroy;
begin
 if assigned(fUpdateThread) then begin
  fUpdateThread.Terminate;
  fUpdateThread.WaitFor;
  FreeAndNil(fUpdateThread);
 end;
 fMesh.Vertices.Finalize;
 fMesh.Indices.Finalize;
 inherited Destroy;
end;

procedure TScreenMain.UpdateGUIData;
begin
 if length(fFileName)>0 then begin
  fGUIStatusFileNameLabel.Caption:=fFileName;
 end else begin
  fGUIStatusFileNameLabel.Caption:='<Unnamed>';
 end;
 if fModified then begin
  fGUIStatusModifiedLabel.Caption:='Modified';
 end else if length(fFileName)>0 then begin
  fGUIStatusModifiedLabel.Caption:='Saved';
 end else begin
  fGUIStatusModifiedLabel.Caption:='Unsaved';
 end;
end;

procedure TScreenMain.MarkAsNotModified;
begin
 fModified:=false;
 UpdateGUIData;
end;

procedure TScreenMain.MarkAsModified;
begin
 fModified:=true;
 UpdateGUIData;
end;

procedure TScreenMain.CheckUpdateThread;
 procedure ShowErrorWindow(const aErrorString:TpvUTF8String);
 var ErrorWindow:TpvGUIWindow;
     ErrorMultilineTextEdit:TpvGUIMultiLineTextEdit;
 begin
  ErrorWindow:=TpvGUIWindow.Create(fGUIInstance);
  ErrorWindow.Title:='Error';
  ErrorWindow.Content.Layout:=TpvGUIFillLayout.Create(ErrorWindow.Content,4.0);
  ErrorWindow.AddMinimizationButton;
  ErrorWindow.AddMaximizationButton;
  ErrorWindow.AddCloseButton;
  ErrorMultilineTextEdit:=TpvGUIMultiLineTextEdit.Create(ErrorWindow.Content);
  ErrorMultilineTextEdit.TextEditor.SyntaxHighlighting:=TpvTextEditor.TSyntaxHighlighting.GetSyntaxHighlightingClassByFileExtension('.txt').Create(ErrorMultilineTextEdit.TextEditor);
  ErrorMultilineTextEdit.TextEditor.TabWidth:=2;
  ErrorMultilineTextEdit.Text:=aErrorString;
  ErrorMultilineTextEdit.Editable:=true;
  ErrorWindow.Width:=fGUIInstance.Width*0.9;
  ErrorWindow.Height:=fGUIInstance.Height*0.6;
  ErrorWindow.PerformLayout;
  ErrorWindow.Center;
  ErrorMultilineTextEdit.RequestFocus;
 end;
begin
 if assigned(fUpdateThread) then begin
  if fUpdateThread.Finished then begin
   fUpdateThread.WaitFor;
   if length(Trim(String(fUpdateThread.fErrorString)))>0 then begin
    ShowErrorWindow(fUpdateThread.fErrorString);
   end else begin
    pvApplication.VulkanDevice.WaitIdle;
    fGUIVulkanCanvas.Release;
    fGUIVulkanCanvas:=TScreenMain.TMeshVulkanCanvas.Create(fGUIRootSplitterPanel1.LeftTopPanel,
                                                           fUpdateThread.fMesh,
                                                           fUpdateThread.fMeshVertexShaderSPVStream,
                                                           fUpdateThread.fMeshFragmentShaderSPVStream,
                                                           sqrt(sqr(fUpdateThread.fWorldSizeX)+sqr(fUpdateThread.fWorldSizeY)+sqr(fUpdateThread.fWorldSizeZ))
                                                          );
    fGUIVulkanCanvas.AcquireVolatileResources;
    fGUIRootSplitterPanel1.LeftTopPanel.PerformLayout;
    fMesh:=fUpdateThread.fMesh;
   end;
   FreeAndNil(fUpdateThread);
   fGUIUpdateButton.Enabled:=true;
   fGUIUpdateProgressBar.Value:=0;
  end else begin
   fGUIUpdateProgressBar.Value:=TPasMPInterlocked.Read(fUpdateThread.fProgress);
  end;
  fGUIInstance.SetRenderDirty;
 end;
end;

procedure TScreenMain.UpdateProject;
begin
 if not assigned(fUpdateThread) then begin
  fGUIUpdateButton.Enabled:=false;
  fGUIUpdateProgressBar.MinimumValue:=0;
  fGUIUpdateProgressBar.MaximumValue:=65535;
  fGUIUpdateProgressBar.Value:=0;
  fUpdateThread:=TUpdateThread.Create(self);
  fGUIInstance.SetRenderDirty;
 end;
end;

procedure TScreenMain.NewProject;
begin

 fGUISignedDistanceFieldCodeEditor.Text:=#13#10+
                                         'const float normalOffsetFactor = 1e-4;'#13#10+
                                         #13#10+
                                         'float getDistance(vec3 position){'#13#10+
                                         '  return length(position) - 1.0;'#13#10+
                                         '}'#13#10+
                                         #13#10+
                                         'mat2x4 getParameters(vec3 position){'#13#10+
                                         '  return mat2x4(vec4(vec3(1.0), 0.0), // first three values => rgb color'#13#10+
                                         '                vec4(0.0));'#13#10+
                                         '}'#13#10;

 fGUIMeshFragmentCodeEditor.Text:=#13#10+
                                  'vec4 getFragmentColor(vec3 position,'#13#10+
                                  '                      mat3 tangentSpace,'#13#10+
                                  '                      mat2x4 parameters,'#13#10+
                                  '                      vec3 rayDirection){'#13#10+
                                  '  return vec4(max(0.0,'#13#10+
                                  '                  -dot(tangentSpace[2],'#13#10+
                                  '                       rayDirection)) * parameters[0].xyz,'#13#10+
                                  '              1.0);'#13#10+
                                  '}'#13#10;

 fIntegerEditGridSizeWidth.Value:=64;

 fIntegerEditGridSizeHeight.Value:=64;

 fIntegerEditGridSizeDepth.Value:=64;

 fFloatEditWorldSizeWidth.Value:=2.0;

 fFloatEditWorldSizeHeight.Value:=2.0;

 fFloatEditWorldSizeDepth.Value:=2.0;

 fFileName:='';

 fFileNameToDelayedOpen:='';

 fGUIVulkanCanvas.Release;

 fGUIVulkanCanvas:=TpvGUIVulkanCanvas.Create(fGUIRootSplitterPanel1.LeftTopPanel);

 fGUIRootSplitterPanel1.LeftTopPanel.PerformLayout;

 fMesh.Vertices.Clear;
 fMesh.Indices.Clear;

 fGUILeftTabPanel.TabIndex:=0;

 fGUISignedDistanceFieldCodeEditor.RequestFocus;

 MarkAsNotModified;

end;

procedure TScreenMain.OpenProject(aFileName:TpvUTF8String);
var FileStream:TFileStream;
    JSONRootItem:TPasJSONItem;
    JSONRootItemObject:TPasJSONItemObject;
    JSONRootItemObjectProperty:TPasJSONItemObjectProperty;
begin
 NewProject;
 fFileName:=aFileName;
 try
  FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
  try
   JSONRootItem:=TPasJSON.Parse(FileStream,[TPasJSONModeFlag.Comments],TPasJSONEncoding.AutomaticDetection);
   if assigned(JSONRootItem) then begin
    try
     if JSONRootItem is TPasJSONItemObject then begin
      JSONRootItemObject:=TPasJSONItemObject(JSONRootItem);
      for JSONRootItemObjectProperty in JSONRootItemObject do begin
       if JSONRootItemObjectProperty.Key='signeddistancefieldcode' then begin
        fGUISignedDistanceFieldCodeEditor.Text:=TPasJSON.GetString(JSONRootItemObjectProperty.Value,fGUISignedDistanceFieldCodeEditor.Text);
       end else if JSONRootItemObjectProperty.Key='meshfragmentcode' then begin
        fGUIMeshFragmentCodeEditor.Text:=TPasJSON.GetString(JSONRootItemObjectProperty.Value,fGUIMeshFragmentCodeEditor.Text);
       end else if JSONRootItemObjectProperty.Key='gridsize' then begin
        if assigned(JSONRootItemObjectProperty.Value) and
           (JSONRootItemObjectProperty.Value is TPasJSONItemArray) and
           (TPasJSONItemArray(JSONRootItemObjectProperty.Value).Count>=3) then begin
         fIntegerEditGridSizeWidth.Value:=TPasJSON.GetInt64(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[0],fIntegerEditGridSizeWidth.Value);
         fIntegerEditGridSizeHeight.Value:=TPasJSON.GetInt64(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[1],fIntegerEditGridSizeHeight.Value);
         fIntegerEditGridSizeDepth.Value:=TPasJSON.GetInt64(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[2],fIntegerEditGridSizeDepth.Value);
        end;
       end else if JSONRootItemObjectProperty.Key='worldsize' then begin
        if assigned(JSONRootItemObjectProperty.Value) and
           (JSONRootItemObjectProperty.Value is TPasJSONItemArray) and
           (TPasJSONItemArray(JSONRootItemObjectProperty.Value).Count>=3) then begin
         fFloatEditWorldSizeWidth.Value:=TPasJSON.GetNumber(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[0],fFloatEditWorldSizeWidth.Value);
         fFloatEditWorldSizeHeight.Value:=TPasJSON.GetNumber(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[1],fFloatEditWorldSizeHeight.Value);
         fFloatEditWorldSizeDepth.Value:=TPasJSON.GetNumber(TPasJSONItemArray(JSONRootItemObjectProperty.Value).Items[2],fFloatEditWorldSizeDepth.Value);
        end;
       end;
      end;
     end;
    finally
     FreeAndNil(JSONRootItem);
    end;
   end;
  finally
   FreeAndNil(FileStream);
  end;
  MarkAsNotModified;
 except
  on e:Exception do begin
   TpvGUIMessageDialog.Create(fGUIInstance,
                              'Error',
                              TpvUTF8String(e.ClassName+': '+e.Message),
                              [TpvGUIMessageDialogButton.Create(0,'OK',[KEYCODE_ESCAPE,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER])],
                              fGUIInstance.Skin.IconDialogError);
  end;
 end;
 fGUILeftTabPanel.TabIndex:=0;
 fGUISignedDistanceFieldCodeEditor.RequestFocus;
end;

procedure TScreenMain.SaveProject(aFileName:TpvUTF8String);
var FileStream:TFileStream;
    JSONRootItemObject:TPasJSONItemObject;
    JSONItemArray:TPasJSONItemArray;
    JSONString:TPasJSONRawByteString;
begin
 fFileName:=aFileName;
 try
  JSONRootItemObject:=TPasJSONItemObject.Create;
  try
   JSONRootItemObject.Add('signeddistancefieldcode',TPasJSONItemString.Create(fGUISignedDistanceFieldCodeEditor.Text));
   JSONRootItemObject.Add('meshfragmentcode',TPasJSONItemString.Create(fGUIMeshFragmentCodeEditor.Text));
   begin
    JSONItemArray:=TPasJSONItemArray.Create;
    try
     JSONItemArray.Add(TPasJSONItemNumber.Create(fIntegerEditGridSizeWidth.Value));
     JSONItemArray.Add(TPasJSONItemNumber.Create(fIntegerEditGridSizeHeight.Value));
     JSONItemArray.Add(TPasJSONItemNumber.Create(fIntegerEditGridSizeDepth.Value));
    finally
     JSONRootItemObject.Add('gridsize',JSONItemArray);
    end;
   end;
   begin
    JSONItemArray:=TPasJSONItemArray.Create;
    try
     JSONItemArray.Add(TPasJSONItemNumber.Create(fFloatEditWorldSizeWidth.Value));
     JSONItemArray.Add(TPasJSONItemNumber.Create(fFloatEditWorldSizeHeight.Value));
     JSONItemArray.Add(TPasJSONItemNumber.Create(fFloatEditWorldSizeDepth.Value));
    finally
     JSONRootItemObject.Add('worldsize',JSONItemArray);
    end;
   end;
   JSONString:=TPasJSON.Stringify(JSONRootItemObject,true);
   try
    if length(JSONString)>0 then begin
     FileStream:=TFileStream.Create(aFileName,fmCreate);
     try
      FileStream.WriteBuffer(JSONString[1],length(JSONString));
     finally
      FreeAndNil(FileStream);
     end;
    end;
   finally
    JSONString:='';
   end;
  finally
   FreeAndNil(JSONRootItemObject);
  end;
  MarkAsNotModified;
 except
  on e:Exception do begin
   TpvGUIMessageDialog.Create(fGUIInstance,
                              'Error',
                              TpvUTF8String(e.ClassName+': '+e.Message),
                              [TpvGUIMessageDialogButton.Create(0,'OK',[KEYCODE_ESCAPE,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER])],
                              fGUIInstance.Skin.IconDialogError);
  end;
 end;
{fGUILeftTabPanel.TabIndex:=0;
 fGUISignedDistanceFieldCodeEditor.RequestFocus;}
end;

procedure TScreenMain.SignedDistanceFieldCodeEditorOnChange(const aSender:TpvGUIObject);
begin
 MarkAsModified;
end;

procedure TScreenMain.MeshFragmentCodeEditorOnChange(const aSender:TpvGUIObject);
begin
 MarkAsModified;
end;

procedure TScreenMain.GridSizeOnChange(const aSender:TpvGUIObject);
begin
 MarkAsModified;
end;

procedure TScreenMain.WorldSizeOnChange(const aSender:TpvGUIObject);
begin
 MarkAsModified;
end;

procedure TScreenMain.UpdateButtonOnClick(const aSender:TpvGUIObject);
begin
 UpdateProject;
end;

procedure TScreenMain.OnNewProjectMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
begin
 if aID=0 then begin
  NewProject;
 end;
end;

procedure TScreenMain.OnNewProjectMessageDialogDestroy(const aSender:TpvGUIObject);
begin
 fNewProjectMessageDialogVisible:=false;
end;

procedure TScreenMain.ShowNewProjectMessageDialog(const aSender:TpvGUIObject);
var MessageDialog:TpvGUIMessageDialog;
begin
 if not (fGUIInstance.HasModalWindows or fNewProjectMessageDialogVisible) then begin
  if fModified then begin
   fNewProjectMessageDialogVisible:=true;
   MessageDialog:=TpvGUIMessageDialog.Create(fGUIInstance,
                                             'Question',
                                             'Do you really want to create a new project and discard the changes in the current project?',
                                             [TpvGUIMessageDialogButton.Create(0,'Yes',[KEYCODE_Y,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER],fGUIInstance.Skin.IconThumbUp,24.0),
                                              TpvGUIMessageDialogButton.Create(1,'No',[KEYCODE_N,KEYCODE_ESCAPE],fGUIInstance.Skin.IconThumbDown,24.0)],
                                             fGUIInstance.Skin.IconDialogQuestion);
   MessageDialog.OnButtonClick:=OnNewProjectMessageDialogButtonClick;
   MessageDialog.OnDestroy:=OnNewProjectMessageDialogDestroy;
  end else begin
   NewProject;
  end;
 end;
end;

procedure TScreenMain.OnOpenProjectMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
begin
 if aID=0 then begin
  OpenProject(fFileNameToDelayedOpen);
 end;
end;

procedure TScreenMain.OnOpenProjectMessageDialogDestroy(const aSender:TpvGUIObject);
begin
 fOpenProjectMessageDialogVisible:=false;
end;

procedure TScreenMain.ShowOpenProjectMessageDialog(const aSender:TpvGUIObject);
var MessageDialog:TpvGUIMessageDialog;
begin
 if not ({fGUIInstance.HasModalWindows or }fOpenProjectMessageDialogVisible) then begin
  fOpenProjectMessageDialogVisible:=true;
  MessageDialog:=TpvGUIMessageDialog.Create(fGUIInstance,
                                            'Question',
                                            'Do you really want to open a project and discard the changes in the current project?',
                                            [TpvGUIMessageDialogButton.Create(0,'Yes',[KEYCODE_Y,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER],fGUIInstance.Skin.IconThumbUp,24.0),
                                             TpvGUIMessageDialogButton.Create(1,'No',[KEYCODE_N,KEYCODE_ESCAPE],fGUIInstance.Skin.IconThumbDown,24.0)],
                                            fGUIInstance.Skin.IconDialogQuestion);
  MessageDialog.OnButtonClick:=OnOpenProjectMessageDialogButtonClick;
  MessageDialog.OnDestroy:=OnOpenProjectMessageDialogDestroy;
 end;
end;

procedure TScreenMain.OnTerminationMessageDialogButtonClick(const aSender:TpvGUIObject;const aID:TpvInt32);
begin
 if aID=0 then begin
  pvApplication.Terminate;
 end;
end;

procedure TScreenMain.OnTerminationMessageDialogDestroy(const aSender:TpvGUIObject);
begin
 fTerminationMessageDialogVisible:=false;
end;

procedure TScreenMain.ShowTerminationMessageDialog(const aSender:TpvGUIObject);
var MessageDialog:TpvGUIMessageDialog;
begin
 if not fTerminationMessageDialogVisible then begin
  fTerminationMessageDialogVisible:=true;
  MessageDialog:=TpvGUIMessageDialog.Create(fGUIInstance,
                                            'Question',
                                            'Do you really want to quit this application?',
                                            [TpvGUIMessageDialogButton.Create(0,'Yes',[KEYCODE_Y,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER],fGUIInstance.Skin.IconThumbUp,24.0),
                                             TpvGUIMessageDialogButton.Create(1,'No',[KEYCODE_N,KEYCODE_ESCAPE],fGUIInstance.Skin.IconThumbDown,24.0)],
                                            fGUIInstance.Skin.IconDialogQuestion);
  MessageDialog.OnButtonClick:=OnTerminationMessageDialogButtonClick;
  MessageDialog.OnDestroy:=OnTerminationMessageDialogDestroy;
 end;
end;

procedure TScreenMain.OpenFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
begin
 if aOK then begin
  if fModified then begin
   fFileNameToDelayedOpen:=aFileName;
   ShowOpenProjectMessageDialog(nil);
  end else begin
   OpenProject(aFileName);
  end;
 end;
end;

procedure TScreenMain.SaveFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
begin
 if aOK then begin
  SaveProject(aFileName);
 end;
end;

procedure TScreenMain.ExportFileDialogOnResult(const aSender:TpvGUIObject;const aOK:boolean;aFileName:TpvUTF8String);
var Index:TpvSizeInt;
    GLTFDocument:TPasGLTF.TDocument;
    FileStream:TFileStream;
    Buffer:TPasGLTF.TBuffer;
    BufferView:TPasGLTF.TBufferView;
    Accessor:TPasGLTF.TAccessor;
    Material:TPasGLTF.TMaterial;
    Mesh:TPasGLTF.TMesh;
    Primitive:TPasGLTF.TMesh.TPrimitive;
    Node:TPasGLTF.TNode;
    Scene:TPasGLTF.TScene;
    Vertex:PVertex;
    Matrix:TpvMatrix3x3;
    Vector:TpvVector4;
begin
 if aOK then begin
  GLTFDocument:=TPasGLTF.TDocument.Create;
  try
   GLTFDocument.Asset.Generator:='sdfmeshgen';
   GLTFDocument.Asset.Version:='2.0';
   begin
    Buffer:=TPasGLTF.TBuffer.Create(GLTFDocument);
    GLTFDocument.Buffers.Add(Buffer);
    if fMesh.Indices.Count>0 then begin
     Buffer.Data.WriteBuffer(fMesh.Indices.Items[0],SizeOf(TpvUInt32)*fMesh.Indices.Count);
    end;
    for Index:=0 to fMesh.Vertices.Count-1 do begin
     Vertex:=@fMesh.Vertices.Items[Index];
     Buffer.Data.WriteBuffer(Vertex^.Position,SizeOf(TpvVector3));
     Matrix:=TpvMatrix3x3.CreateFromQTangent(Vertex^.QTantent);
     Matrix:=Matrix.RobustOrthoNormalize;
     Vector:=TpvVector4.InlineableCreate(Matrix.Normal,0.0);
     Buffer.Data.WriteBuffer(Vector,SizeOf(TpvVector3));
     Vector:=TpvVector4.InlineableCreate(Matrix.Tangent,Sign(Matrix.Tangent.Cross(Matrix.Normal).Dot(Matrix.Bitangent)));
     Buffer.Data.WriteBuffer(Vector,SizeOf(TpvVector4));
     Buffer.Data.WriteBuffer(Vertex^.Parameters0,SizeOf(TpvVector4));
     Buffer.Data.WriteBuffer(Vertex^.Parameters1,SizeOf(TpvVector4));
    end;
    Buffer.ByteLength:=Buffer.Data.Size;
   end;
   begin
    // Index
    BufferView:=TPasGLTF.TBufferView.Create(GLTFDocument);
    GLTFDocument.BufferViews.Add(BufferView);
    BufferView.Name:='Indices';
    BufferView.Buffer:=0;
    BufferView.ByteOffset:=0;
    BufferView.ByteLength:=SizeOf(TpvUInt32)*fMesh.Indices.Count;
    BufferView.ByteStride:=0; //SizeOf(TpvUInt32);
    BufferView.Target:=TPasGLTF.TBufferView.TTargetType.ElementArrayBuffer;
   end;
   begin
    // Vertices
    BufferView:=TPasGLTF.TBufferView.Create(GLTFDocument);
    GLTFDocument.BufferViews.Add(BufferView);
    BufferView.Name:='Vertices';
    BufferView.Buffer:=0;
    BufferView.ByteOffset:=SizeOf(TpvUInt32)*fMesh.Indices.Count;
    BufferView.ByteLength:=((SizeOf(TpvVector3)*2)+(SizeOf(TpvVector4)*3))*fMesh.Vertices.Count;
    BufferView.ByteStride:=(SizeOf(TpvVector3)*2)+(SizeOf(TpvVector4)*3);
    BufferView.Target:=TPasGLTF.TBufferView.TTargetType.ArrayBuffer;
   end;
   begin
    // Index
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.UnsignedInt;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Scalar;
    Accessor.BufferView:=0;
    Accessor.ByteOffset:=0;
    Accessor.Count:=fMesh.Indices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    // Position
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.Float;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Vec3;
    Accessor.BufferView:=1;
    Accessor.ByteOffset:=0;
    Accessor.MinArray.Add(-(fFloatEditWorldSizeWidth.Value*0.5));
    Accessor.MinArray.Add(-(fFloatEditWorldSizeHeight.Value*0.5));
    Accessor.MinArray.Add(-(fFloatEditWorldSizeDepth.Value*0.5));
    Accessor.MaxArray.Add(fFloatEditWorldSizeWidth.Value*0.5);
    Accessor.MaxArray.Add(fFloatEditWorldSizeHeight.Value*0.5);
    Accessor.MaxArray.Add(fFloatEditWorldSizeDepth.Value*0.5);
    Accessor.Count:=fMesh.Vertices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    // Normal
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.Float;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Vec3;
    Accessor.BufferView:=1;
    Accessor.ByteOffset:=SizeOf(TpvVector3);
{   Accessor.MinArray.Add(-1.0);
    Accessor.MinArray.Add(-1.0);
    Accessor.MinArray.Add(-1.0);
    Accessor.MaxArray.Add(1.0);
    Accessor.MaxArray.Add(1.0);
    Accessor.MaxArray.Add(1.0);}
    Accessor.Count:=fMesh.Vertices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    // Tangent
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.Float;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Vec4;
    Accessor.BufferView:=1;
    Accessor.ByteOffset:=SizeOf(TpvVector3)+SizeOf(TpvVector3);
{   Accessor.MinArray.Add(-1.0);
    Accessor.MinArray.Add(-1.0);
    Accessor.MinArray.Add(-1.0);
    Accessor.MinArray.Add(-1.0);
    Accessor.MaxArray.Add(1.0);
    Accessor.MaxArray.Add(1.0);
    Accessor.MaxArray.Add(1.0);
    Accessor.MaxArray.Add(1.0);}
    Accessor.Count:=fMesh.Vertices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    // Parameters 0
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.Float;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Vec4;
    Accessor.BufferView:=1;
    Accessor.ByteOffset:=SizeOf(TpvVector3)+SizeOf(TpvVector3)+SizeOf(TpvVector4);
{   Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);}
    Accessor.Count:=fMesh.Vertices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    // Parameters 1
    Accessor:=TPasGLTF.TAccessor.Create(GLTFDocument);
    GLTFDocument.Accessors.Add(Accessor);
    Accessor.ComponentType:=TPasGLTF.TAccessor.TComponentType.Float;
    Accessor.Type_:=TPasGLTF.TAccessor.TType.Vec4;
    Accessor.BufferView:=1;
    Accessor.ByteOffset:=SizeOf(TpvVector3)+SizeOf(TpvVector3)+SizeOf(TpvVector4)+SizeOf(TpvVector4);
{   Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MinArray.Add(-MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);
    Accessor.MaxArray.Add(MaxSingle);}
    Accessor.Count:=fMesh.Vertices.Count;
    Accessor.Normalized:=false;
   end;
   begin
    Material:=TPasGLTF.TMaterial.Create(GLTFDocument);
    GLTFDocument.Materials.Add(Material);
   end;
   begin
    Mesh:=TPasGLTF.TMesh.Create(GLTFDocument);
    GLTFDocument.Meshes.Add(Mesh);
    Primitive:=TPasGLTF.TMesh.TPrimitive.Create(GLTFDocument);
    Mesh.Primitives.Add(Primitive);
    Primitive.Mode:=TPasGLTF.TMesh.TPrimitive.TMode.Triangles;
    Primitive.Indices:=0;
    Primitive.Material:=0;
    Primitive.Attributes['POSITION']:=1;
    Primitive.Attributes['NORMAL']:=2;
    Primitive.Attributes['TANGENT']:=3;
    Primitive.Attributes['COLOR_0']:=4;
    Primitive.Attributes['COLOR_1']:=5;
   end;
   begin
    Node:=TPasGLTF.TNode.Create(GLTFDocument);
    GLTFDocument.Nodes.Add(Node);
    Node.Mesh:=0;
   end;
   begin
    Scene:=TPasGLTF.TScene.Create(GLTFDocument);
    GLTFDocument.Scenes.Add(Scene);
    Scene.Nodes.Add(0);
   end;
   begin
    GLTFDocument.Scene:=0;
   end;
   FileStream:=TFileStream.Create(aFileName,fmCreate);
   try
    GLTFDocument.SaveToBinary(FileStream);
   finally
    FreeAndNil(FileStream);
   end;
  finally
   FreeAndNil(GLTFDocument);
  end;
 end;
end;

procedure TScreenMain.MenuOnOpenProject(const aSender:TpvGUIObject);
var FileDialog:TpvGUIFileDialog;
begin
 if not fGUIInstance.HasModalWindows then begin
  FileDialog:=TpvGUIFileDialog.Create(fGUIInstance,TpvGUIFileDialog.TMode.Open);
  FileDialog.Title:='Open';
  FileDialog.Filter:='*.sdfmeshgen';
  FileDialog.DefaultFileExtension:='.sdfmeshgen';
  FileDialog.Path:=GetCurrentDir;
  FileDialog.OnResult:=OpenFileDialogOnResult;
 end;
end;

procedure TScreenMain.MenuOnSaveProject(const aSender:TpvGUIObject);
begin
 if length(fFileName)=0 then begin
  MenuOnSaveAsProject(nil);
 end else begin
  SaveProject(fFileName);
 end;
end;

procedure TScreenMain.MenuOnSaveAsProject(const aSender:TpvGUIObject);
var FileDialog:TpvGUIFileDialog;
begin
 if not fGUIInstance.HasModalWindows then begin
  FileDialog:=TpvGUIFileDialog.Create(fGUIInstance,TpvGUIFileDialog.TMode.Save);
  FileDialog.Title:='Save as';
  FileDialog.Filter:='*.sdfmeshgen';
  FileDialog.DefaultFileExtension:='.sdfmeshgen';
  FileDialog.OverwritePrompt:=true;
  FileDialog.Path:=GetCurrentDir;
  FileDialog.OnResult:=SaveFileDialogOnResult;
 end;
end;

procedure TScreenMain.MenuOnExportAsProject(const aSender:TpvGUIObject);
var FileDialog:TpvGUIFileDialog;
begin
 if not fGUIInstance.HasModalWindows then begin
  FileDialog:=TpvGUIFileDialog.Create(fGUIInstance,TpvGUIFileDialog.TMode.Save);
  FileDialog.Title:='Export as';
  FileDialog.Filter:='*.glb';
  FileDialog.DefaultFileExtension:='.glb';
  FileDialog.OverwritePrompt:=true;
  FileDialog.Path:=GetCurrentDir;
  FileDialog.OnResult:=ExportFileDialogOnResult;
 end;
end;

procedure TScreenMain.Show;
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

 FillChar(fVolumeTriangles,SizeOf(TVolumeTriangles),#0);

 fVolumeTriangleBuffer:=TpvVulkanBuffer.Create(pvApplication.VulkanDevice,
                                               SizeOf(TVolumeTriangles),
                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT) or
                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or
                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                               pvApplication.VulkanDevice.QueueFamilyIndices.ItemArray,
                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                               0,
                                               0,
                                               0,
                                               0,
                                               0,
                                               0,
                                               [TpvVulkanBufferFlag.PersistentMapped]);
 fVolumeTriangleBuffer.UploadData(pvApplication.VulkanDevice.TransferQueue,
                                  fVulkanTransferCommandBuffer,
                                  fVulkanTransferCommandBufferFence,
                                  fVolumeTriangles,
                                  0,
                                  SizeOf(TVolumeTriangles),
                                  TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

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

  begin
   PopupMenu:=TpvGUIPopupMenu.Create(MenuItem);

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconContentDelete;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='New';
   MenuItem.ShortcutHint:='Shift+Ctrl+N';
   MenuItem.OnClick:=ShowNewProjectMessageDialog;

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconContentPaste;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='Open';
   MenuItem.ShortcutHint:='Ctrl+O';
   MenuItem.OnClick:=MenuOnOpenProject;

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconContentCopy;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='Save';
   MenuItem.ShortcutHint:='Ctrl+S';
   MenuItem.OnClick:=MenuOnSaveProject;

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconContentCopy;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='Save as';
   MenuItem.ShortcutHint:='Shift+Ctrl+S';
   MenuItem.OnClick:=MenuOnSaveAsProject;

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Caption:='-';

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconContentCopy;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='Export as';
   MenuItem.ShortcutHint:='Shift+Ctrl+E';
   MenuItem.OnClick:=MenuOnExportAsProject;

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Caption:='-';

   MenuItem:=TpvGUIMenuItem.Create(PopupMenu);
   MenuItem.Icon:=fGUIInstance.Skin.IconWindowClose;
   MenuItem.IconHeight:=12;
   MenuItem.Caption:='Exit';
   MenuItem.ShortcutHint:='Alt+F4';
   MenuItem.OnClick:=ShowTerminationMessageDialog;

  end;

 end;

 fGUIInstance.Content.Layout:=TpvGUIAdvancedGridLayout.Create(fGUIInstance.Content,0.0);
 TpvGUIAdvancedGridLayout(fGUIInstance.Content.Layout).Rows.Add(640.0,1.0);
 TpvGUIAdvancedGridLayout(fGUIInstance.Content.Layout).Rows.Add(32.0,0.0);
 TpvGUIAdvancedGridLayout(fGUIInstance.Content.Layout).Columns.Add(0.0,1.0);

 fGUIStatusPanel:=TpvGUIPanel.Create(fGUIInstance.Content);
 TpvGUIAdvancedGridLayout(fGUIInstance.Content.Layout).Anchors[fGUIStatusPanel]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,1,1,1,0.0,0.0,0.0,0.0,TpvGUILayoutAlignment.Fill,TpvGUILayoutAlignment.Fill);
 fGUIStatusPanel.Background:=true;
 fGUIStatusPanel.Layout:=TpvGUIAdvancedGridLayout.Create(fGUIStatusPanel,0.0);
 TpvGUIAdvancedGridLayout(fGUIStatusPanel.Layout).Rows.Add(10.0,1.0);
 TpvGUIAdvancedGridLayout(fGUIStatusPanel.Layout).Columns.Add(10.0,0.75);
 TpvGUIAdvancedGridLayout(fGUIStatusPanel.Layout).Columns.Add(10.0,0.25);

 fGUIStatusFileNameLabel:=TpvGUILabel.Create(fGUIStatusPanel);
 TpvGUIAdvancedGridLayout(fGUIStatusPanel.Layout).Anchors[fGUIStatusFileNameLabel]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,0,1,1,12.0,0.0,8.0,0.0,TpvGUILayoutAlignment.Fill,TpvGUILayoutAlignment.Fill);
 fGUIStatusFileNameLabel.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;
 fGUIStatusFileNameLabel.TextVerticalAlignment:=TpvGUITextAlignment.Middle;

 fGUIStatusModifiedLabel:=TpvGUILabel.Create(fGUIStatusPanel);
 TpvGUIAdvancedGridLayout(fGUIStatusPanel.Layout).Anchors[fGUIStatusModifiedLabel]:=TpvGUIAdvancedGridLayoutAnchor.Create(1,0,1,1,8.0,0.0,12.0,0.0,TpvGUILayoutAlignment.Fill,TpvGUILayoutAlignment.Fill);
 fGUIStatusModifiedLabel.TextHorizontalAlignment:=TpvGUITextAlignment.Tailing;
 fGUIStatusModifiedLabel.TextVerticalAlignment:=TpvGUITextAlignment.Middle;

 fGUIRootPanel:=TpvGUIPanel.Create(fGUIInstance.Content);
 TpvGUIAdvancedGridLayout(fGUIInstance.Content.Layout).Anchors[fGUIRootPanel]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,0,1,1);
 fGUIRootPanel.Background:=true;
 fGUIRootPanel.Layout:=TpvGUIFillLayout.Create(fGUIRootPanel,0.0);

 fGUIRootSplitterPanel0:=TpvGUISplitterPanel.Create(fGUIRootPanel);
 fGUIRootSplitterPanel0.Orientation:=TpvGUISplitterPanelOrientation.Horizontal;
 fGUIRootSplitterPanel0.LeftTopPanel.Layout:=TpvGUIAdvancedGridLayout.Create(fGUIRootSplitterPanel0.LeftTopPanel,4.0);
 fGUIRootSplitterPanel0.LeftTopPanel.Background:=true;
 fGUIRootSplitterPanel0.RightBottomPanel.Layout:=TpvGUIFillLayout.Create(fGUIRootSplitterPanel0.RightBottomPanel,4.0);
 fGUIRootSplitterPanel0.RightBottomPanel.Background:=true;

 fGUIRootSplitterPanel1:=TpvGUISplitterPanel.Create(fGUIRootSplitterPanel0.RightBottomPanel);
 fGUIRootSplitterPanel1.Orientation:=TpvGUISplitterPanelOrientation.Vertical;
 fGUIRootSplitterPanel1.LeftTopPanel.Layout:=TpvGUIFillLayout.Create(fGUIRootSplitterPanel1.LeftTopPanel,4.0);
 fGUIRootSplitterPanel1.LeftTopPanel.Background:=true;

 fGUIRootSplitterPanel1.RightBottomPanel.Layout:=TpvGUIFlowLayout.Create(fGUIRootSplitterPanel1.RightBottomPanel,
                                                                         TpvGUILayoutOrientation.Horizontal,
                                                                         8.0);
 fGUIRootSplitterPanel1.RightBottomPanel.Background:=true;

 TpvGUIAdvancedGridLayout(fGUIRootSplitterPanel0.LeftTopPanel.Layout).Rows.Add(200.0,1.0);
 TpvGUIAdvancedGridLayout(fGUIRootSplitterPanel0.LeftTopPanel.Layout).Rows.Add(70.0,0.0);
 TpvGUIAdvancedGridLayout(fGUIRootSplitterPanel0.LeftTopPanel.Layout).Columns.Add(0.0,1.0);

 fGUILeftTabPanel:=TpvGUITabPanel.Create(fGUIRootSplitterPanel0.LeftTopPanel);
 TpvGUIAdvancedGridLayout(fGUIRootSplitterPanel0.LeftTopPanel.Layout).Anchors[fGUILeftTabPanel]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,0,1,1);
 fGUILeftTabPanel.VisibleHeader:=true;
 fGUILeftTabPanel.VisibleContent:=true;
 fGUILeftTabPanel.VisibleContentBackground:=true;
 fGUISignedDistanceFieldCodeEditorTab:=fGUILeftTabPanel.Tabs.Add('Signed distance field');
 fGUIMeshFragmentCodeEditorTab:=fGUILeftTabPanel.Tabs.Add('Mesh fragment');
 fGUILeftTabPanel.TabIndex:=0;

 fGUILeftToolPanel:=TpvGUIPanel.Create(fGUIRootSplitterPanel0.LeftTopPanel);
 TpvGUIAdvancedGridLayout(fGUIRootSplitterPanel0.LeftTopPanel.Layout).Anchors[fGUILeftToolPanel]:=TpvGUIAdvancedGridLayoutAnchor.Create(0,1,1,1,4.0,0.0,4.0,0.0);
 fGUILeftToolPanel.Layout:=TpvGUIGridLayout.Create(fGUILeftToolPanel,
                                                   1,
                                                   TpvGUILayoutAlignment.Fill,
                                                   TpvGUILayoutAlignment.Middle,
                                                   TpvGUILayoutOrientation.Horizontal,
                                                   4.0,
                                                   4.0,
                                                   4.0);
 fGUILeftToolPanel.Background:=false;

 fGUISignedDistanceFieldCodeEditorTab.Content:=TpvGUIPanel.Create(fGUILeftTabPanel.Content);
 fGUISignedDistanceFieldCodeEditorTab.Content.Layout:=TpvGUIFillLayout.Create(fGUISignedDistanceFieldCodeEditorTab.Content,4.0);

 fGUIMeshFragmentCodeEditorTab.Content:=TpvGUIPanel.Create(fGUILeftTabPanel.Content);
 fGUIMeshFragmentCodeEditorTab.Content.Layout:=TpvGUIFillLayout.Create(fGUIMeshFragmentCodeEditorTab.Content,4.0);

 fGUISignedDistanceFieldCodeEditor:=TpvGUIMultiLineTextEdit.Create(fGUISignedDistanceFieldCodeEditorTab.Content);
 fGUISignedDistanceFieldCodeEditor.TextEditor.SyntaxHighlighting:=TpvTextEditor.TSyntaxHighlighting.GetSyntaxHighlightingClassByFileExtension('.glsl').Create(fGUISignedDistanceFieldCodeEditor.TextEditor);
 fGUISignedDistanceFieldCodeEditor.TextEditor.TabWidth:=2;
 fGUISignedDistanceFieldCodeEditor.LineWrap:=false;
 fGUISignedDistanceFieldCodeEditor.OnChange:=SignedDistanceFieldCodeEditorOnChange;

 fGUIMeshFragmentCodeEditor:=TpvGUIMultiLineTextEdit.Create(fGUIMeshFragmentCodeEditorTab.Content);
 fGUIMeshFragmentCodeEditor.TextEditor.SyntaxHighlighting:=TpvTextEditor.TSyntaxHighlighting.GetSyntaxHighlightingClassByFileExtension('.glsl').Create(fGUIMeshFragmentCodeEditor.TextEditor);
 fGUIMeshFragmentCodeEditor.TextEditor.TabWidth:=2;
 fGUIMeshFragmentCodeEditor.LineWrap:=false;
 fGUIMeshFragmentCodeEditor.OnChange:=MeshFragmentCodeEditorOnChange;

 fGUIUpdateButton:=TpvGUIButton.Create(fGUILeftToolPanel);
 fGUIUpdateButton.Caption:='Update (F9)';
 fGUIUpdateButton.OnClick:=UpdateButtonOnClick;

 fGUIUpdateProgressBar:=TpvGUIProgressBar.Create(fGUILeftToolPanel);
 fGUIUpdateProgressBar.Orientation:=TpvGUIProgressBarOrientation.Horizontal;
 fGUIUpdateProgressBar.Width:=30.0;
 fGUIUpdateProgressBar.MinimumValue:=0;
 fGUIUpdateProgressBar.MaximumValue:=65536;
 fGUIUpdateProgressBar.Value:=0;

 fGUIVulkanCanvas:=TpvGUIVulkanCanvas.Create(fGUIRootSplitterPanel1.LeftTopPanel);

 begin

  fGUIGridSizePanel:=TpvGUIPanel.Create(fGUIRootSplitterPanel1.RightBottomPanel);
  fGUIGridSizePanel.Layout:=TpvGUIGroupLayout.Create(fGUIGridSizePanel,
                                                     15,
                                                     6,
                                                     14,
                                                     20);
  fGUIGridSizePanel.Background:=true;

  begin

   fLabelGridSizeWidth:=TpvGUILabel.Create(fGUIGridSizePanel);
   fLabelGridSizeWidth.Caption:='Grid width';
   fLabelGridSizeWidth.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fIntegerEditGridSizeWidth:=TpvGUIIntegerEdit.Create(fGUIGridSizePanel);
   fIntegerEditGridSizeWidth.FixedWidth:=96.0;
   fIntegerEditGridSizeWidth.FixedHeight:=32.0;
   fIntegerEditGridSizeWidth.MinimumValue:=1;
   fIntegerEditGridSizeWidth.MaximumValue:=4096;
   fIntegerEditGridSizeWidth.SmallStep:=1;
   fIntegerEditGridSizeWidth.LargeStep:=16;
   fIntegerEditGridSizeWidth.OnChange:=GridSizeOnChange;
  //fIntegerEditGridSizeWidth.OnChange:=IntegerEditGridSizeWidthOnChange;

  end;

  begin

   fLabelGridSizeHeight:=TpvGUILabel.Create(fGUIGridSizePanel);
   fLabelGridSizeHeight.Caption:='Grid height';
   fLabelGridSizeHeight.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fIntegerEditGridSizeHeight:=TpvGUIIntegerEdit.Create(fGUIGridSizePanel);
   fIntegerEditGridSizeHeight.FixedWidth:=96.0;
   fIntegerEditGridSizeHeight.FixedHeight:=32.0;
   fIntegerEditGridSizeHeight.MinimumValue:=1;
   fIntegerEditGridSizeHeight.MaximumValue:=4096;
   fIntegerEditGridSizeHeight.SmallStep:=1;
   fIntegerEditGridSizeHeight.LargeStep:=16;
   fIntegerEditGridSizeHeight.OnChange:=GridSizeOnChange;
  //fIntegerEditGridSizeHeight.OnChange:=IntegerEditGridSizeHeightOnChange;

  end;

  begin

   fLabelGridSizeDepth:=TpvGUILabel.Create(fGUIGridSizePanel);
   fLabelGridSizeDepth.Caption:='Grid depth';
   fLabelGridSizeDepth.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fIntegerEditGridSizeDepth:=TpvGUIIntegerEdit.Create(fGUIGridSizePanel);
   fIntegerEditGridSizeDepth.FixedWidth:=96.0;
   fIntegerEditGridSizeDepth.FixedHeight:=32.0;
   fIntegerEditGridSizeDepth.MinimumValue:=1;
   fIntegerEditGridSizeDepth.MaximumValue:=4096;
   fIntegerEditGridSizeDepth.SmallStep:=1;
   fIntegerEditGridSizeDepth.LargeStep:=16;
   fIntegerEditGridSizeDepth.OnChange:=GridSizeOnChange;
  //fIntegerEditGridSizeDepth.OnChange:=IntegerEditGridSizeDepthOnChange;

  end;

 end;

 begin

  fGUIWorldSizePanel:=TpvGUIPanel.Create(fGUIRootSplitterPanel1.RightBottomPanel);
  fGUIWorldSizePanel.Layout:=TpvGUIGroupLayout.Create(fGUIWorldSizePanel,
                                                     15,
                                                     6,
                                                     14,
                                                     20);
  fGUIWorldSizePanel.Background:=true;

  begin

   fLabelWorldSizeWidth:=TpvGUILabel.Create(fGUIWorldSizePanel);
   fLabelWorldSizeWidth.Caption:='World width';
   fLabelWorldSizeWidth.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fFloatEditWorldSizeWidth:=TpvGUIFloatEdit.Create(fGUIWorldSizePanel);
   fFloatEditWorldSizeWidth.FixedWidth:=96.0;
   fFloatEditWorldSizeWidth.FixedHeight:=32.0;
   fFloatEditWorldSizeWidth.MinimumValue:=0.0;
   fFloatEditWorldSizeWidth.MaximumValue:=4096.0;
   fFloatEditWorldSizeWidth.SmallStep:=0.1;
   fFloatEditWorldSizeWidth.LargeStep:=1.0;
   fFloatEditWorldSizeWidth.OnChange:=WorldSizeOnChange;
  //fFloatEditWorldSizeWidth.OnChange:=FloatEditWorldSizeWidthOnChange;

  end;

  begin

   fLabelWorldSizeHeight:=TpvGUILabel.Create(fGUIWorldSizePanel);
   fLabelWorldSizeHeight.Caption:='World height';
   fLabelWorldSizeHeight.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fFloatEditWorldSizeHeight:=TpvGUIFloatEdit.Create(fGUIWorldSizePanel);
   fFloatEditWorldSizeHeight.FixedWidth:=96.0;
   fFloatEditWorldSizeHeight.FixedHeight:=32.0;
   fFloatEditWorldSizeHeight.MinimumValue:=0.0;
   fFloatEditWorldSizeHeight.MaximumValue:=4096.0;
   fFloatEditWorldSizeHeight.SmallStep:=0.1;
   fFloatEditWorldSizeHeight.LargeStep:=1.0;
   fFloatEditWorldSizeHeight.OnChange:=WorldSizeOnChange;
  //fFloatEditWorldSizeHeight.OnChange:=FloatEditWorldSizeHeightOnChange;

  end;

  begin

   fLabelWorldSizeDepth:=TpvGUILabel.Create(fGUIWorldSizePanel);
   fLabelWorldSizeDepth.Caption:='World depth';
   fLabelWorldSizeDepth.TextHorizontalAlignment:=TpvGUITextAlignment.Leading;

   fFloatEditWorldSizeDepth:=TpvGUIFloatEdit.Create(fGUIWorldSizePanel);
   fFloatEditWorldSizeDepth.FixedWidth:=96.0;
   fFloatEditWorldSizeDepth.FixedHeight:=32.0;
   fFloatEditWorldSizeDepth.MinimumValue:=0.0;
   fFloatEditWorldSizeDepth.MaximumValue:=4096.0;
   fFloatEditWorldSizeDepth.SmallStep:=0.1;
   fFloatEditWorldSizeDepth.LargeStep:=1.0;
   fFloatEditWorldSizeDepth.OnChange:=WorldSizeOnChange;
  //fFloatEditWorldSizeDepth.OnChange:=FloatEditWorldSizeDepthOnChange;

  end;

 end;

 NewProject;

 if not fVulkanSDKFound then begin
  TpvGUIMessageDialog.Create(fGUIInstance,
                             'No installed Vulkan SDK found!',
                             'This application requires an installed Vulkan SDK on your system for its full functionality.',
                             [TpvGUIMessageDialogButton.Create(0,'OK',[KEYCODE_ESCAPE,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER])],
                             fGUIInstance.Skin.IconDialogError);
 end else if not fVulkanGLSLCFound then begin
  TpvGUIMessageDialog.Create(fGUIInstance,
                             'Incomplete Vulkan SDK found!',
                             'This application requires an complete installed Vulkan SDK on your system for its full functionality.',
                             [TpvGUIMessageDialogButton.Create(0,'OK',[KEYCODE_ESCAPE,KEYCODE_RETURN,KEYCODE_RETURN2,KEYCODE_KP_ENTER])],
                             fGUIInstance.Skin.IconDialogError);
 end;

end;

procedure TScreenMain.Hide;
var Index:TpvInt32;
begin
 if assigned(fUpdateThread) then begin
  fUpdateThread.Terminate;
  fUpdateThread.WaitFor;
  FreeAndNil(fUpdateThread);
 end;
 FreeAndNil(fGUIInstance);
 FreeAndNil(fVulkanCanvas);
 FreeAndNil(fVolumeTriangleBuffer);
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

procedure TScreenMain.Resume;
begin
 inherited Resume;
end;

procedure TScreenMain.Pause;
begin
 inherited Pause;
end;

procedure TScreenMain.Resize(const aWidth,aHeight:TpvInt32);
begin
 inherited Resize(aWidth,aHeight);
end;

procedure TScreenMain.AfterCreateSwapChain;
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
{fVulkanCanvas.Width:=(pvApplication.Width*12) div 16;
 fVulkanCanvas.Height:=(pvApplication.Height*12) div 16;}
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

procedure TScreenMain.BeforeDestroySwapChain;
begin
 fGUIInstance.ReleaseVolatileResources;
 fVulkanCanvas.VulkanRenderPass:=nil;
 FreeAndNil(fVulkanRenderPass);
 inherited BeforeDestroySwapChain;
end;

function TScreenMain.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and not fGUIInstance.KeyEvent(aKeyEvent) then begin
  if aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down then begin
   case aKeyEvent.KeyCode of
    KEYCODE_QUIT,KEYCODE_F4:begin
     if (aKeyEvent.KeyCode=KEYCODE_QUIT) or
        ((aKeyEvent.KeyCode=KEYCODE_F4) and
         ((aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                   TpvApplicationInputKeyModifier.CTRL,
                                   TpvApplicationInputKeyModifier.SHIFT,
                                   TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.ALT])) then begin
      ShowTerminationMessageDialog(nil);
      result:=true;
     end;
    end;
    KEYCODE_N:begin
     if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                 TpvApplicationInputKeyModifier.CTRL,
                                 TpvApplicationInputKeyModifier.SHIFT,
                                 TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.SHIFT] then begin
      ShowNewProjectMessageDialog(nil);
      result:=true;
     end;
    end;
    KEYCODE_O:begin
     if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                 TpvApplicationInputKeyModifier.CTRL,
                                 TpvApplicationInputKeyModifier.SHIFT,
                                 TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.CTRL] then begin
      MenuOnOpenProject(nil);
      result:=true;
     end;
    end;
    KEYCODE_S:begin
     if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                 TpvApplicationInputKeyModifier.CTRL,
                                 TpvApplicationInputKeyModifier.SHIFT,
                                 TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.CTRL] then begin
      MenuOnSaveProject(nil);
      result:=true;
     end else if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                          TpvApplicationInputKeyModifier.CTRL,
                                          TpvApplicationInputKeyModifier.SHIFT,
                                          TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.SHIFT] then begin
      MenuOnSaveAsProject(nil);
      result:=true;
     end;
    end;
    KEYCODE_E:begin
     if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                          TpvApplicationInputKeyModifier.CTRL,
                                          TpvApplicationInputKeyModifier.SHIFT,
                                          TpvApplicationInputKeyModifier.META])=[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.SHIFT] then begin
      MenuOnExportAsProject(nil);
      result:=true;
     end;
    end;
    KEYCODE_F9:begin
     if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,
                                 TpvApplicationInputKeyModifier.CTRL,
                                 TpvApplicationInputKeyModifier.SHIFT,
                                 TpvApplicationInputKeyModifier.META])=[] then begin
      UpdateButtonOnClick(nil);
      result:=true;
     end;
    end;
   end;
  end;
 end;
end;

function TScreenMain.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
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

function TScreenMain.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 if fReady then begin
  result:=fGUIInstance.Scrolled(fLastMousePosition,aRelativeAmount);
 end else begin
  result:=false;
 end;
end;

function TScreenMain.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenMain.Check(const aDeltaTime:TpvDouble);
begin

 inherited Check(aDeltaTime);

 CheckUpdateThread;

 fGUIInstance.UpdateBufferIndex:=pvApplication.UpdateInFlightFrameIndex;
 fGUIInstance.DeltaTime:=aDeltaTime;
 fGUIInstance.Check;

end;

procedure TScreenMain.Update(const aDeltaTime:TpvDouble);
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

// fGUIUpdateProgressBar.Value:=trunc(fTime*65536) and $ffff;

 if fMesh.Indices.Count>0 then begin
  fGUIInstance.SetRenderDirty;
 end;

 fGUIInstance.DrawWidgetBounds:=false;
 fGUIInstance.UpdateBufferIndex:=pvApplication.UpdateInFlightFrameIndex;
 fGUIInstance.DeltaTime:=aDeltaTime;
 fGUIInstance.Update;
 fGUIInstance.Draw;

{$if false}
 fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.Identity;
 fVulkanCanvas.ModelMatrix:=TpvMatrix4x4.Identity;
 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.AlphaBlending;
 fVulkanCanvas.Color:=TpvVector4.Create(IfThen(TpvApplicationInputPointerButton.Left in fLastMouseButtons,1.0,0.0),
                                        IfThen(TpvApplicationInputPointerButton.Right in fLastMouseButtons,1.0,0.0),
                                        1.0,
                                        0.5);
 fVulkanCanvas.DrawFilledCircle(fLastMousePosition,16.0);
 fVulkanCanvas.Color:=TpvVector4.Create(0.5,1.0,0.5,0.5);
 fVulkanCanvas.DrawFilledCircle(fLastMousePosition,4.0);
 fVulkanCanvas.Color:=TpvVector4.Create(1.0,1.0,1.0,0.5);
{$ifend}

 fVulkanCanvas.Stop;

 fTime:=fTime+aDeltaTime;

 fReady:=true;
end;

procedure TScreenMain.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var VulkanCommandBuffer:TpvVulkanCommandBuffer;
    VulkanSwapChain:TpvVulkanSwapChain;
begin

 if fGUIInstance.CheckRenderDirty(pvApplication.DrawInFlightFrameIndex,aSwapChainImageIndex,true) then begin

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

end.
