program convert;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {-$pic off}
 {$define CAN_INLINE}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef WinCE}
 {$define Windows}
{$endif}
{$ifdef Windows}
 {$define Win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define CAN_INLINE}
{$else}
 {$undef CAN_INLINE}
 {$ifdef ver180}
  {$define CAN_INLINE}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define CAN_INLINE}
   {$ifend}
  {$endif}
 {$endif}
{$endif}
{$ifdef windows}
 {$apptype console}
{$endif}
{$undef UNICODE}

uses SysUtils,Classes;

var StringList:TStringList;

procedure ConvertFile(SrcFileName,ArrayName:string);
var ms:TMemoryStream;
    i,j:integer;
    b:byte;
    s:string;
begin
 ms:=TMemoryStream.Create;
 try
  ms.LoadFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+StringReplace(StringReplace(SrcFileName,'/',SysUtils.PathDelim,[rfReplaceAll]),'\',SysUtils.PathDelim,[rfReplaceAll]));
  StringList.Add('const '+ArrayName+'DataSize='+IntToStr(ms.Size)+';');
  StringList.Add('      '+ArrayName+'Data:array[0..'+ArrayName+'DataSize-1] of byte=');
  StringList.Add('       (');
  s:='        ';
  j:=0;
  for i:=1 to ms.Size do begin
   ms.ReadBuffer(b,SizeOf(byte));
   s:=s+'$'+LowerCase(IntToHex(b,2));
   if (i+1)<=ms.Size then begin
    s:=s+',';
   end;
   inc(j);
   if j>=16 then begin
    j:=0;
    StringList.Add(s);
    s:='        ';
   end;
  end;
  StringList.Add(s);
  StringList.Add('       );');
  StringList.Add('');
 finally
  ms.Free;
 end;
end;

begin
 StringList:=TStringList.Create;
 try
  ConvertFile('fonts/notosans.ttf','GUIStandardTrueTypeFontSansFont');
  ConvertFile('fonts/notosansbold.ttf','GUIStandardTrueTypeFontSansBoldFont');
  ConvertFile('fonts/notosansbolditalic.ttf','GUIStandardTrueTypeFontSansBoldItalicFont');
  ConvertFile('fonts/notosansitalic.ttf','GUIStandardTrueTypeFontSansItalicFont');
//ConvertFile('fonts/notomono.ttf','GUIStandardTrueTypeFontMonoFont');
  ConvertFile('fonts/hackregular.ttf','GUIStandardTrueTypeFontMonoFont');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture.spv','CanvasFragmentGUINoTextureSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture.spv','CanvasFragmentNoTextureSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture.spv','CanvasFragmentTextureSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture.spv','CanvasFragmentAtlasTextureSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath.spv','CanvasFragmentVectorPathSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture_no_blending.spv','CanvasFragmentGUINoTextureNoBlendingSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture_no_blending.spv','CanvasFragmentNoTextureNoBlendingSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture_no_blending.spv','CanvasFragmentTextureNoBlendingSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture_no_blending.spv','CanvasFragmentAtlasTextureNoBlendingSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath_no_blending.spv','CanvasFragmentVectorPathNoBlendingSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture_no_blending_no_discard.spv','CanvasFragmentGUINoTextureNoBlendingNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture_no_blending_no_discard.spv','CanvasFragmentNoTextureNoBlendingNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture_no_blending_no_discard.spv','CanvasFragmentTextureNoBlendingNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture_no_blending_no_discard.spv','CanvasFragmentAtlasTextureNoBlendingNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath_no_blending_no_discard.spv','CanvasFragmentVectorPathNoBlendingNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture_clip_distance.spv','CanvasFragmentGUINoTextureClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture_clip_distance.spv','CanvasFragmentNoTextureClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture_clip_distance.spv','CanvasFragmentTextureClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture_clip_distance.spv','CanvasFragmentAtlasTextureClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath_clip_distance.spv','CanvasFragmentVectorPathClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture_no_blending_clip_distance.spv','CanvasFragmentGUINoTextureNoBlendingClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture_no_blending_clip_distance.spv','CanvasFragmentNoTextureNoBlendingClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture_no_blending_clip_distance.spv','CanvasFragmentTextureNoBlendingClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture_no_blending_clip_distance.spv','CanvasFragmentAtlasTextureNoBlendingClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath_no_blending_clip_distance.spv','CanvasFragmentVectorPathNoBlendingClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_gui_no_texture_no_blending_clip_distance_no_discard.spv','CanvasFragmentGUINoTextureNoBlendingClipDistanceNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_no_texture_no_blending_clip_distance_no_discard.spv','CanvasFragmentNoTextureNoBlendingClipDistanceNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_texture_no_blending_clip_distance_no_discard.spv','CanvasFragmentTextureNoBlendingClipDistanceNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_atlas_texture_no_blending_clip_distance_no_discard.spv','CanvasFragmentAtlasTextureNoBlendingClipDistanceNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_frag_vectorpath_no_blending_clip_distance_no_discard.spv','CanvasFragmentVectorPathNoBlendingClipDistanceNoDiscardSPIRV');
  ConvertFile('shaders/canvas/canvas_vert.spv','CanvasVertexSPIRV');
  ConvertFile('shaders/canvas/canvas_vert_clip_distance.spv','CanvasVertexClipDistanceSPIRV');
  ConvertFile('shaders/canvas/canvas_no_texture_vert.spv','CanvasNoTextureVertexSPIRV');
  ConvertFile('shaders/canvas/canvas_no_texture_vert_clip_distance.spv','CanvasNoTextureVertexClipDistanceSPIRV');
  ConvertFile('shaders/canvas/vr_disabled_to_screen_blit_frag.spv','VRDisabledToScreenBlitFragSPIRV');
  ConvertFile('shaders/canvas/vr_disabled_to_screen_blit_vert.spv','VRDisabledToScreenBlitVertSPIRV');
  ConvertFile('shaders/canvas/vr_enabled_to_screen_blit_frag.spv','VREnabledToScreenBlitFragSPIRV');
  ConvertFile('shaders/canvas/vr_enabled_to_screen_blit_vert.spv','VREnabledToScreenBlitVertSPIRV');
  StringList.SaveToFile(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'..')+'PasVulkanAssets.inc');
 finally
  FreeAndNil(StringList);
 end;
(*StringList:=TStringList.Create;
 try
  ConvertFile('shaders/scene3d/scene3dshaders.zip','Scene3DSPIRVShaders');
{ ConvertFile('textures/scene3d/lenscolor.png','Scene3DLensColor');
  ConvertFile('textures/scene3d/lensdirt.png','Scene3DLensDirt');
  ConvertFile('textures/scene3d/lensstar.png','Scene3DLensStar');}
  StringList.SaveToFile(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'..')+'PasVulkanScene3DAssets.inc');
 finally
  FreeAndNil(StringList);
 end;*)
end.
