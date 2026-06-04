program smartcombineanimations;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$apptype console}

uses SysUtils,
     Classes,
     PasDblStrUtils in '..\..\externals\pasdblstrutils\src\PasDblStrUtils.pas',
     PasJSON in '..\..\externals\pasjson\src\PasJSON.pas',
     PasGLTF in '..\PasGLTF.pas';

var BaseGLTF:TPasGLTF.TDocument;

procedure MergeGLTF(const aFileName:String);
const NullBytes:array[0..3] of Byte=(0,0,0,0);
type TUsedBufferSpan=record
      BufferIndex:TPasGLTFSizeInt;
      Offset:TPasGLTFSizeInt;
      Size:TPasGLTFSizeInt; 
      OutputOffset:TPasGLTFSizeInt;
     end;
     PUsedBufferSpan=^TUsedBufferSpan;
     TUsedBufferSpans=array of TUsedBufferSpan;
     TBuffer=record
      Used:Boolean;
      RemappedIndex:TPasGLTFSizeInt;
     end;
     PBuffer=^TBuffer;
     TBuffers=array of TBuffer;
     TBufferView=record
      Used:Boolean;
      RemappedIndex:TPasGLTFSizeInt;
      UsedBufferSpanIndex:TPasGLTFSizeInt;
     end;
     PBufferView=^TBufferView;
     TBufferViews=array of TBufferView;
     TAccessor=record
      Used:Boolean;
      RemappedIndex:TPasGLTFSizeInt;
     end;
     PAccessor=^TAccessor;
     TAccessors=array of TAccessor;
     TNode=record
      Used:Boolean;
      RemappedIndex:TPasGLTFSizeInt;
     end;
     PNode=^TNode;
     TNodes=array of TNode;
     TAnimationSampler=record
      Used:Boolean;      
      RemappedIndex:TPasGLTFSizeInt;
     end;
     PAnimationSampler=^TAnimationSampler;
     TAnimationSamplers=array of TAnimationSampler;
     TAnimationChannel=record
      Used:Boolean;      
      RemappedIndex:TPasGLTFSizeInt;
     end;
     PAnimationChannel=^TAnimationChannel;
     TAnimationChannels=array of TAnimationChannel;
     TAnimation=record
      Used:Boolean;
      RemappedIndex:TPasGLTFSizeInt;
      Samplers:TAnimationSamplers;
      Channels:TAnimationChannels;           
     end;
     PAnimation=^TAnimation;
     TAnimations=array of TAnimation;
var GLTF:TPasGLTF.TDocument;
    Stream:TMemoryStream;    
    UsedBufferSpans:TUsedBufferSpans;
    TemporaryUsedBufferSpan:TUsedBufferSpan;
    CountUsedBufferSpans,UsedBufferSpanIndex,OutputOffset,
    BufferIndex,BufferViewIndex,AccessorIndex,NodeIndex,
    AnimationIndex,AnimationSamplerIndex,AnimationChannelIndex,
    Counter,OutputSize,OtherIndex:TPasGLTFSizeInt;
    Animation:TPasGLTF.TAnimation;    
    AnimationSampler:TPasGLTF.TAnimation.TSampler;
    AnimationChannel:TPasGLTF.TAnimation.TChannel;
    NodeName:TPasGLTFUTF8String;
    Buffers:TBuffers;
    BufferViews:TBufferViews;
    Accessors:TAccessors;
    Nodes:TNodes;
    Animations:TAnimations;
    SrcBuffer,DstBuffer:TPasGLTF.TBuffer;
    SrcBufferView,DstBufferView:TPasGLTF.TBufferView;
    SrcAccessor,DstAccessor:TPasGLTF.TAccessor;
    SrcAnimation,DstAnimation:TPasGLTF.TAnimation;
    SrcAnimationSampler,DstAnimationSampler:TPasGLTF.TAnimation.TSampler;
    SrcAnimationChannel,DstAnimationChannel:TPasGLTF.TAnimation.TChannel;
begin
 
 Buffers:=nil;
 BufferViews:=nil;
 Accessors:=nil;
 Nodes:=nil;
 Animations:=nil; 
 UsedBufferSpans:=nil;
 CountUsedBufferSpans:=0;
 try

  GLTF:=TPasGLTF.TDocument.Create;
  try

   Stream:=TMemoryStream.Create;
   try
    Stream.LoadFromFile(aFileName);
    Stream.Seek(0,soBeginning);
    GLTF.LoadFromStream(Stream);
   finally
    FreeAndNil(Stream);
   end;

   SetLength(Buffers,GLTF.Buffers.Count);
   for BufferIndex:=0 to GLTF.Buffers.Count-1 do begin
    Buffers[BufferIndex].Used:=false;
    Buffers[BufferIndex].RemappedIndex:=-1;
   end;

   SetLength(BufferViews,GLTF.BufferViews.Count);
   for BufferViewIndex:=0 to GLTF.BufferViews.Count-1 do begin
    BufferViews[BufferViewIndex].Used:=false;
    BufferViews[BufferViewIndex].RemappedIndex:=-1;
   end;

   SetLength(Accessors,GLTF.Accessors.Count);
   for AccessorIndex:=0 to GLTF.Accessors.Count-1 do begin
    Accessors[AccessorIndex].Used:=false;
    Accessors[AccessorIndex].RemappedIndex:=-1;
   end;

   SetLength(Nodes,GLTF.Nodes.Count);
   for NodeIndex:=0 to GLTF.Nodes.Count-1 do begin
    Nodes[NodeIndex].Used:=false;
    Nodes[NodeIndex].RemappedIndex:=-1;
   end;

   SetLength(Animations,GLTF.Animations.Count);
   for AnimationIndex:=0 to GLTF.Animations.Count-1 do begin
    Animations[AnimationIndex].Used:=false;
    SetLength(Animations[AnimationIndex].Samplers,GLTF.Animations[AnimationIndex].Samplers.Count);
    for AnimationSamplerIndex:=0 to GLTF.Animations[AnimationIndex].Samplers.Count-1 do begin
     Animations[AnimationIndex].Samplers[AnimationSamplerIndex].Used:=false;
     Animations[AnimationIndex].Samplers[AnimationSamplerIndex].RemappedIndex:=-1;
    end;
    SetLength(Animations[AnimationIndex].Channels,GLTF.Animations[AnimationIndex].Channels.Count);
    for AnimationChannelIndex:=0 to GLTF.Animations[AnimationIndex].Channels.Count-1 do begin
     Animations[AnimationIndex].Channels[AnimationChannelIndex].Used:=false;
     Animations[AnimationIndex].Channels[AnimationChannelIndex].RemappedIndex:=-1;
    end;
   end;

   // Scan for copyable animations (with targets which exists also in the base gltf)
   begin
     
    for AnimationIndex:=0 to GLTF.Animations.Count-1 do begin

     Animation:=GLTF.Animations[AnimationIndex];
     if assigned(Animation) then begin

      // Go through all animation channels
      Counter:=0;
      for AnimationChannelIndex:=0 to Animation.Channels.Count-1 do begin
       AnimationChannel:=Animation.Channels[AnimationChannelIndex];
       if (AnimationChannel.Target.Path='translation') or
          (AnimationChannel.Target.Path='rotation') or
          (AnimationChannel.Target.Path='scale') or
          (AnimationChannel.Target.Path='weights') then begin
        if (AnimationChannel.Target.Node>=0) and (AnimationChannel.Target.Node<GLTF.Nodes.Count) then begin
         NodeName:=GLTF.Nodes[AnimationChannel.Target.Node].Name;
         for NodeIndex:=0 to BaseGLTF.Nodes.Count-1 do begin
          if BaseGLTF.Nodes[NodeIndex].Name=NodeName then begin
           Animations[AnimationIndex].Used:=true;
           Animations[AnimationIndex].Channels[AnimationChannelIndex].Used:=true;
           Animations[AnimationIndex].Channels[AnimationChannelIndex].RemappedIndex:=Counter;
           inc(Counter);
           Animations[AnimationIndex].Samplers[AnimationChannel.Sampler].Used:=true;          
           Nodes[AnimationChannel.Target.Node].Used:=true;
           Nodes[AnimationChannel.Target.Node].RemappedIndex:=NodeIndex;
           Accessors[Animation.Samplers[AnimationChannel.Sampler].Input].Used:=true;
           Accessors[Animation.Samplers[AnimationChannel.Sampler].Output].Used:=true;
           break;
          end;
         end;
        end else begin
         writeln('Animation channel target node "',AnimationChannel.Target.Node,'" not found');
        end;
       end else begin
        writeln('Animation channel target path "',AnimationChannel.Target.Path,'" not supported');
       end;
      end;

      // Go through all animation samplers
      Counter:=0;
      for AnimationSamplerIndex:=0 to Animation.Samplers.Count-1 do begin
       if Animations[AnimationIndex].Samplers[AnimationSamplerIndex].Used then begin
        Animations[AnimationIndex].Samplers[AnimationSamplerIndex].RemappedIndex:=Counter;
        inc(Counter);
       end;
      
      end;

     end;

    end;

    // Assign remapped indices to animations
    Counter:=0;
    for AnimationIndex:=0 to GLTF.Animations.Count-1 do begin
     if Animations[AnimationIndex].Used then begin
      Animations[AnimationIndex].RemappedIndex:=Counter;
      inc(Counter);
     end;
    end; 

   end; 

   // Scan for copyable accessors (which are used by the copyable animations)
   begin     
    Counter:=0;
    for AccessorIndex:=0 to GLTF.Accessors.Count-1 do begin
     if Accessors[AccessorIndex].Used then begin
      Accessors[AccessorIndex].RemappedIndex:=Counter;
      BufferViews[GLTF.Accessors[AccessorIndex].BufferView].Used:=true;
      inc(Counter);
     end;
    end;
   end;

   // Scan for copyable buffer views (which are used by the copyable accessors)
   begin     
    Counter:=0;
    for BufferViewIndex:=0 to GLTF.BufferViews.Count-1 do begin
     if BufferViews[BufferViewIndex].Used then begin
      BufferViews[BufferViewIndex].RemappedIndex:=Counter;
      Buffers[GLTF.BufferViews[BufferViewIndex].Buffer].Used:=true;
      UsedBufferSpanIndex:=CountUsedBufferSpans;
      inc(CountUsedBufferSpans);
      if length(UsedBufferSpans)<CountUsedBufferSpans then begin
       SetLength(UsedBufferSpans,CountUsedBufferSpans+((CountUsedBufferSpans+1) shr 1));
      end;
      UsedBufferSpans[UsedBufferSpanIndex].BufferIndex:=GLTF.BufferViews[BufferViewIndex].Buffer;
      UsedBufferSpans[UsedBufferSpanIndex].Offset:=GLTF.BufferViews[BufferViewIndex].ByteOffset;
      UsedBufferSpans[UsedBufferSpanIndex].Size:=GLTF.BufferViews[BufferViewIndex].ByteLength;
      UsedBufferSpans[UsedBufferSpanIndex].OutputOffset:=0; // Will be assigned later, after sorting, therefore set to zero for now      
      inc(Counter);
     end;
    end;
   end;

   // Sort used buffer spans (must not be fast, therefore use a simple bubble sort variant, for a small nice to read code)
   UsedBufferSpanIndex:=0;
   while (UsedBufferSpanIndex+1)<CountUsedBufferSpans do begin
    if (UsedBufferSpans[UsedBufferSpanIndex].BufferIndex>UsedBufferSpans[UsedBufferSpanIndex+1].BufferIndex) or
       ((UsedBufferSpans[UsedBufferSpanIndex].BufferIndex=UsedBufferSpans[UsedBufferSpanIndex+1].BufferIndex) and
        (UsedBufferSpans[UsedBufferSpanIndex].Offset>UsedBufferSpans[UsedBufferSpanIndex+1].Offset)) then begin
     TemporaryUsedBufferSpan:=UsedBufferSpans[UsedBufferSpanIndex];
     UsedBufferSpans[UsedBufferSpanIndex]:=UsedBufferSpans[UsedBufferSpanIndex+1];
     UsedBufferSpans[UsedBufferSpanIndex+1]:=TemporaryUsedBufferSpan;
     if UsedBufferSpanIndex>0 then begin
      dec(UsedBufferSpanIndex);
     end else begin
      inc(UsedBufferSpanIndex);
     end;
    end else begin
     inc(UsedBufferSpanIndex);
    end;
   end;

   // Assign output offsets
   OutputOffset:=0;
   for UsedBufferSpanIndex:=0 to CountUsedBufferSpans-1 do begin
    UsedBufferSpans[UsedBufferSpanIndex].OutputOffset:=OutputOffset;
    inc(OutputOffset,UsedBufferSpans[UsedBufferSpanIndex].Size);
   end;
   OutputSize:=OutputOffset;

   // Remap buffer views together with the buffer spans
   for BufferViewIndex:=0 to GLTF.BufferViews.Count-1 do begin
    if BufferViews[BufferViewIndex].Used then begin
     BufferViews[BufferViewIndex].RemappedIndex:=BufferViews[BufferViewIndex].RemappedIndex+BaseGLTF.BufferViews.Count;
     for UsedBufferSpanIndex:=0 to CountUsedBufferSpans-1 do begin
      if (UsedBufferSpans[UsedBufferSpanIndex].BufferIndex=GLTF.BufferViews[BufferViewIndex].Buffer) and
         (UsedBufferSpans[UsedBufferSpanIndex].Offset=GLTF.BufferViews[BufferViewIndex].ByteOffset) and
         (UsedBufferSpans[UsedBufferSpanIndex].Size=GLTF.BufferViews[BufferViewIndex].ByteLength) then begin
       BufferViews[BufferViewIndex].UsedBufferSpanIndex:=UsedBufferSpanIndex;
       break;
      end;
     end;
    end;
   end;

   // Remap accessors
   for AccessorIndex:=0 to GLTF.Accessors.Count-1 do begin
    if Accessors[AccessorIndex].Used then begin
     Accessors[AccessorIndex].RemappedIndex:=Accessors[AccessorIndex].RemappedIndex+BaseGLTF.Accessors.Count;
    end;
   end;

   // Remap animations
   for AnimationIndex:=0 to GLTF.Animations.Count-1 do begin
    if Animations[AnimationIndex].Used then begin
     Animations[AnimationIndex].RemappedIndex:=Animations[AnimationIndex].RemappedIndex+BaseGLTF.Animations.Count;
    end;
   end;

   // Remapping node are not needed, because the nodes are not copied, since they are already in the base gltf

   // Now do the actual copying
   begin

    // Copy buffer contents
    begin

     // A GLB file have only one buffer as required by the GLTF specification, therefore we can just assume that, 
     // otherwise it just crashes with an exception, but that's ok, since it's a error in the input file then, 
     // and it's not a problem of this tool. :-) Of course, not so nice for the user, but it's ok for now.
     DstBuffer:=BaseGLTF.Buffers[0]; 
     for UsedBufferSpanIndex:=0 to CountUsedBufferSpans-1 do begin
      SrcBuffer:=GLTF.Buffers[UsedBufferSpans[UsedBufferSpanIndex].BufferIndex];
      SrcBuffer.Data.Seek(UsedBufferSpans[UsedBufferSpanIndex].Offset,soBeginning);
     {begin
       // Align to 4 bytes
       Counter:=DstBuffer.ByteLength and 3;
       if Counter<>0 then begin
        Counter:=4-Counter;
        DstBuffer.Data.Write(NullBytes,Counter);
        DstBuffer.ByteLength:=DstBuffer.ByteLength+Counter;
       end;        
      end;}
      UsedBufferSpans[UsedBufferSpanIndex].OutputOffset:=DstBuffer.ByteLength;
      Counter:=UsedBufferSpans[UsedBufferSpanIndex].OutputOffset and 3;
      if Counter<>0 then begin
       inc(UsedBufferSpans[UsedBufferSpanIndex].OutputOffset,4-Counter);
      end;
      DstBuffer.Data.Seek(UsedBufferSpans[UsedBufferSpanIndex].OutputOffset,soBeginning);
      DstBuffer.Data.CopyFrom(SrcBuffer.Data,UsedBufferSpans[UsedBufferSpanIndex].Size);
      DstBuffer.ByteLength:=UsedBufferSpans[UsedBufferSpanIndex].OutputOffset+UsedBufferSpans[UsedBufferSpanIndex].Size;
     end; 

     // Align to 4 bytes
     Counter:=DstBuffer.Data.Size and 3;
     if Counter<>0 then begin
      Counter:=4-Counter;
      DstBuffer.Data.Write(NullBytes,Counter);
     end; 
     DstBuffer.ByteLength:=DstBuffer.Data.Size;

    end; 

   end;

   // Copy buffer views
   for BufferViewIndex:=0 to GLTF.BufferViews.Count-1 do begin
    if BufferViews[BufferViewIndex].Used then begin
     SrcBufferView:=GLTF.BufferViews[BufferViewIndex];
     DstBufferView:=TPasGLTF.TBufferView.Create(BaseGLTF);
     DstBufferView.Name:=SrcBufferView.Name;
     DstBufferView.Buffer:=0;
     DstBufferView.ByteOffset:=UsedBufferSpans[BufferViews[BufferViewIndex].UsedBufferSpanIndex].OutputOffset;
     DstBufferView.ByteLength:=SrcBufferView.ByteLength;
     DstBufferView.ByteStride:=SrcBufferView.ByteStride;
     DstBufferView.Target:=SrcBufferView.Target;
     BufferViews[BufferViewIndex].RemappedIndex:=BaseGLTF.BufferViews.Add(DstBufferView);
    end;
   end;

   // Copy accessors
   for AccessorIndex:=0 to GLTF.Accessors.Count-1 do begin
    
    if Accessors[AccessorIndex].Used then begin
     
     SrcAccessor:=GLTF.Accessors[AccessorIndex];
     
     DstAccessor:=TPasGLTF.TAccessor.Create(BaseGLTF);
     try

      if assigned(SrcAccessor.Extensions) then begin
       DstAccessor.Extensions.Merge(SrcAccessor.Extensions);
      end;

      if assigned(SrcAccessor.Extras) then begin
       DstAccessor.Extras.Merge(SrcAccessor.Extras);
      end;

      DstAccessor.ComponentType:=SrcAccessor.ComponentType;
      DstAccessor.Type_:=SrcAccessor.Type_;
      DstAccessor.BufferView:=BufferViews[SrcAccessor.BufferView].RemappedIndex;
      DstAccessor.ByteOffset:=SrcAccessor.ByteOffset;//+(UsedBufferSpans[BufferViews[SrcAccessor.BufferView].UsedBufferSpanIndex].OutputOffset-UsedBufferSpans[BufferViews[SrcAccessor.BufferView].UsedBufferSpanIndex].Offset);
      DstAccessor.Count:=SrcAccessor.Count;
      for OtherIndex:=0 to SrcAccessor.MinArray.Count-1 do begin
       DstAccessor.MinArray.Add(SrcAccessor.MinArray[OtherIndex]);
      end;
      for OtherIndex:=0 to SrcAccessor.MaxArray.Count-1 do begin
       DstAccessor.MaxArray.Add(SrcAccessor.MaxArray[OtherIndex]);
      end;
      DstAccessor.Normalized:=SrcAccessor.Normalized;

      if assigned(SrcAccessor.Sparse.Extensions) then begin
       DstAccessor.Sparse.Extensions.Merge(SrcAccessor.Sparse.Extensions);
      end;

      if assigned(SrcAccessor.Sparse.Extras) then begin
       DstAccessor.Sparse.Extras.Merge(SrcAccessor.Sparse.Extras);
      end;

      DstAccessor.Sparse.Count:=SrcAccessor.Sparse.Count;

      if assigned(SrcAccessor.Sparse.Indices.Extensions) then begin
       DstAccessor.Sparse.Indices.Extensions.Merge(SrcAccessor.Sparse.Indices.Extensions);
      end;

      if assigned(SrcAccessor.Sparse.Indices.Extras) then begin
       DstAccessor.Sparse.Indices.Extras.Merge(SrcAccessor.Sparse.Indices.Extras);
      end;

      DstAccessor.Sparse.Indices.ComponentType:=SrcAccessor.Sparse.Indices.ComponentType;
      DstAccessor.Sparse.Indices.BufferView:=BufferViews[SrcAccessor.Sparse.Indices.BufferView].RemappedIndex;
      DstAccessor.Sparse.Indices.ByteOffset:=SrcAccessor.Sparse.Indices.ByteOffset;//+(UsedBufferSpans[BufferViews[SrcAccessor.Sparse.Indices.BufferView].UsedBufferSpanIndex].OutputOffset-UsedBufferSpans[BufferViews[SrcAccessor.Sparse.Indices.BufferView].UsedBufferSpanIndex].Offset);
      DstAccessor.Sparse.Indices.Empty:=SrcAccessor.Sparse.Indices.Empty;

      if assigned(SrcAccessor.Sparse.Values.Extensions) then begin
       DstAccessor.Sparse.Values.Extensions.Merge(SrcAccessor.Sparse.Values.Extensions);
      end;

      if assigned(SrcAccessor.Sparse.Indices.Extras) then begin
       DstAccessor.Sparse.Values.Extras.Merge(SrcAccessor.Sparse.Values.Extras);
      end;

      DstAccessor.Sparse.Values.BufferView:=BufferViews[SrcAccessor.Sparse.Values.BufferView].RemappedIndex;
      DstAccessor.Sparse.Values.ByteOffset:=SrcAccessor.Sparse.Values.ByteOffset;//+(UsedBufferSpans[BufferViews[SrcAccessor.Sparse.Values.BufferView].UsedBufferSpanIndex].OutputOffset-UsedBufferSpans[BufferViews[SrcAccessor.Sparse.Values.BufferView].UsedBufferSpanIndex].Offset);
      DstAccessor.Sparse.Values.Empty:=SrcAccessor.Sparse.Values.Empty;
      
     finally
      Accessors[AccessorIndex].RemappedIndex:=BaseGLTF.Accessors.Add(DstAccessor); 
     end; 
    
    end;
   end;

   // Copy animations
   for AnimationIndex:=0 to GLTF.Animations.Count-1 do begin

    if Animations[AnimationIndex].Used then begin

     Animation:=GLTF.Animations[AnimationIndex];

     DstAnimation:=TPasGLTF.TAnimation.Create(BaseGLTF);
     try

      if Animation.Name='mixamo.com' then begin
       DstAnimation.Name:=LowerCase(ChangeFileExt(ExtractFileName(aFileName),''));
      end else begin
       DstAnimation.Name:=Animation.Name;
      end;

      if assigned(Animation.Extensions) then begin
       DstAnimation.Extensions.Merge(Animation.Extensions);
      end;

      if assigned(Animation.Extras) then begin
       DstAnimation.Extras.Merge(Animation.Extras);
      end;

      for AnimationSamplerIndex:=0 to Animation.Samplers.Count-1 do begin
       if Animations[AnimationIndex].Samplers[AnimationSamplerIndex].Used then begin
        AnimationSampler:=Animation.Samplers[AnimationSamplerIndex];
        DstAnimationSampler:=TPasGLTF.TAnimation.TSampler.Create(BaseGLTF);
        try

         if assigned(AnimationSampler.Extensions) then begin
          DstAnimationSampler.Extensions.Merge(AnimationSampler.Extensions);
         end;

         if assigned(AnimationSampler.Extras) then begin
          DstAnimationSampler.Extras.Merge(AnimationSampler.Extras);
         end;

         DstAnimationSampler.Input:=Accessors[AnimationSampler.Input].RemappedIndex;
         DstAnimationSampler.Output:=Accessors[AnimationSampler.Output].RemappedIndex;
         DstAnimationSampler.Interpolation:=AnimationSampler.Interpolation;

        finally
         Animations[AnimationIndex].Samplers[AnimationSamplerIndex].RemappedIndex:=DstAnimation.Samplers.Add(DstAnimationSampler);
        end;
       end;
      end;

      for AnimationChannelIndex:=0 to Animation.Channels.Count-1 do begin
       if Animations[AnimationIndex].Channels[AnimationChannelIndex].Used then begin
        AnimationChannel:=Animation.Channels[AnimationChannelIndex];
        DstAnimationChannel:=TPasGLTF.TAnimation.TChannel.Create(BaseGLTF);
        try

         if assigned(AnimationChannel.Extensions) then begin
          DstAnimationChannel.Extensions.Merge(AnimationChannel.Extensions);
         end;

         if assigned(AnimationChannel.Extras) then begin
          DstAnimationChannel.Extras.Merge(AnimationChannel.Extras);
         end;

         DstAnimationChannel.Sampler:=Animations[AnimationIndex].Samplers[AnimationChannel.Sampler].RemappedIndex;

         if assigned(AnimationChannel.Target.Extensions) then begin
          DstAnimationChannel.Target.Extensions.Merge(AnimationChannel.Target.Extensions);
         end;

         if assigned(AnimationChannel.Target.Extras) then begin
          DstAnimationChannel.Target.Extras.Merge(AnimationChannel.Target.Extras);
         end;

         DstAnimationChannel.Target.Node:=Nodes[AnimationChannel.Target.Node].RemappedIndex;
         DstAnimationChannel.Target.Path:=AnimationChannel.Target.Path;

        finally
         Animations[AnimationIndex].Channels[AnimationChannelIndex].RemappedIndex:=DstAnimation.Channels.Add(DstAnimationChannel);
        end;

       end;

      end;

     finally
      Animations[AnimationIndex].RemappedIndex:=BaseGLTF.Animations.Add(DstAnimation);
     end;

    end;

   end;

  finally
   FreeAndNil(GLTF);
  end;

 finally
  Buffers:=nil;
  BufferViews:=nil;
  Accessors:=nil;
  Nodes:=nil;
  Animations:=nil;
  UsedBufferSpans:=nil;
 end; 

end;

function GetRelativeFileList(const aPath:String;const aMask:String={$ifdef Unix}'*'{$else}'*.*'{$endif};const aParentPath:String=''):TStringList;
var SearchRec:{$if declared(TUnicodeSearchRec)}TUnicodeSearchRec{$else}TSearchRec{$ifend};
    SubList:TStringList;
begin
 result:=TStringList.Create;
 try
  if FindFirst(IncludeTrailingPathDelimiter(aPath)+aMask,faAnyFile,SearchRec)=0 then begin
   try
    repeat
     if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then begin
      if (SearchRec.Attr and faDirectory)<>0 then begin
       result.Add(String(ExcludeLeadingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(aParentPath)+SearchRec.Name))));
       SubList:=GetRelativeFileList(IncludeTrailingPathDelimiter(aPath)+SearchRec.Name,
                                    aMask,
                                    IncludeTrailingPathDelimiter(aParentPath)+SearchRec.Name);
       if assigned(SubList) then begin
        try
         result.AddStrings(SubList);
        finally
         FreeAndNil(SubList);
        end;
       end;
      end else begin
       result.Add(String(ExcludeLeadingPathDelimiter(IncludeTrailingPathDelimiter(aParentPath)+SearchRec.Name)));
      end;
     end;
    until FindNext(SearchRec)<>0;
   finally
    FindClose(SearchRec);
   end;
  end;
 except
  FreeAndNil(result);
  raise;
 end;
end;

var Index:Int32;
    InputDirectoryName,OutputGLBFileName,BaseInputFileName,InputFileName:String;
    InputFileList,TemporaryInputFileList:TStringList;
    Stream:TMemoryStream;
begin
 
 if ParamCount=0 then begin
  writeln('Usage: combineanimations <input glb files directory> <output glb file>');
  halt(1); 
 end;

 InputDirectoryName:=ParamStr(1);
 if not DirectoryExists(InputDirectoryName) then begin
  writeln('Input directory not found');
  halt(1);
 end;

 if ParamCount>1 then begin
  OutputGLBFileName:=ParamStr(2);
 end else begin
  OutputGLBFileName:=IncludeTrailingPathDelimiter(InputDirectoryName)+'output.glb';
 end;

 InputFileList:=TStringList.Create;

 TemporaryInputFileList:=GetRelativeFileList(InputDirectoryName,'*.glb');
 if assigned(TemporaryInputFileList) then begin
  try
   InputFileList.AddStrings(TemporaryInputFileList);
  finally
   FreeAndNil(TemporaryInputFileList);
  end;
 end;

 InputDirectoryName:=IncludeTrailingPathDelimiter(InputDirectoryName);

 if InputFileList.Count>0 then begin

  InputFileList.Sort;

  // Search for base.glb or base.gltf
  BaseInputFileName:='';
  for Index:=0 to InputFileList.Count-1 do begin
   InputFileName:=InputDirectoryName+InputFileList[Index];
   if ExtractFileName(InputFileName)='base.glb' then begin
    BaseInputFileName:=InputFileName;
    InputFileList.Delete(Index);    
    break;
   end;
  end;

  if (length(BaseInputFileName)=0) or not FileExists(BaseInputFileName) then begin
   writeln('No base.glb found!');
   halt(1);
  end;

  if FileExists(OutputGLBFileName) then begin
   DeleteFile(OutputGLBFileName);
   if FileExists(OutputGLBFileName) then begin
    writeln('Could not delete output file!');
    halt(1);
   end;
  end;

  BaseGLTF:=TPasGLTF.TDocument.Create;
  try

   Stream:=TMemoryStream.Create;
   try
    Stream.LoadFromFile(BaseInputFileName);
    Stream.Seek(0,soBeginning);
    BaseGLTF.LoadFromStream(Stream);
   finally
    FreeAndNil(Stream);
   end;

   for Index:=0 to InputFileList.Count-1 do begin
    MergeGLTF(InputDirectoryName+InputFileList[Index]);
   end;

   Stream:=TMemoryStream.Create;
   try
    BaseGLTF.SaveToBinary(Stream);
    Stream.SaveToFile(OutputGLBFileName);
   finally
    FreeAndNil(Stream);
   end;

  finally
   FreeAndNil(BaseGLTF);
  end;

  writeln('Done!');

 end else begin

  writeln('No input files found!');
  halt(1);

 end;  

end.
