program combineanimations;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$apptype console}

uses SysUtils,
     Classes,
     PasDblStrUtils in '..\..\externals\pasdblstrutils\src\PasDblStrUtils.pas',
     PasJSON in '..\..\externals\pasjson\src\PasJSON.pas',
     PasGLTF in '..\PasGLTF.pas';

function GetRelativeFileList(const aPath:UnicodeString;const aMask:UnicodeString={$ifdef Unix}'*'{$else}'*.*'{$endif};const aParentPath:UnicodeString=''):TStringList;
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

var Index,ItemIndex,BaseAccessorIndex,BaseBufferIndex,BaseBufferViewIndex,
    OtherIndex,BaseBufferByteOffset:TPasGLTFSizeInt;
    Files,TemporaryFiles:TStringList;
    BaseDirectory,InputFileName:String;
    BaseGLTF,CurrentGLTF:TPasGLTF.TDocument;
    Stream:TMemoryStream;
    CurrentAccessor,NewAccessor:TPasGLTF.TAccessor;
    CurrentBuffer,NewBuffer:TPasGLTF.TBuffer;
    CurrentBufferView,NewBufferView:TPasGLTF.TBufferView;
    CurrentAnimation,NewAnimation:TPasGLTF.TAnimation;
    CurrentAnimationSampler,NewAnimationSampler:TPasGLTF.TAnimation.TSampler;
    CurrentAnimationChannel,NewAnimationChannel:TPasGLTF.TAnimation.TChannel;
    SingleBuffer:boolean;
begin

 BaseDirectory:=IncludeTrailingPathDelimiter(GetCurrentDir);

 SingleBuffer:=false;

 BaseGLTF:=nil;
 try

  Files:=TStringList.Create;
  try

   TemporaryFiles:=GetRelativeFileList(BaseDirectory,'*.glb');
   if assigned(TemporaryFiles) then begin
    try
     Files.AddStrings(TemporaryFiles);
    finally
     FreeAndNil(TemporaryFiles);
    end;
   end;

   TemporaryFiles:=GetRelativeFileList(BaseDirectory,'*.gltf');
   if assigned(TemporaryFiles) then begin
    try
     Files.AddStrings(TemporaryFiles);
    finally
     FreeAndNil(TemporaryFiles);
    end;
   end;

   if Files.Count>0 then begin

    Files.Sort;

    for Index:=0 to Files.Count-1 do begin

     InputFileName:=Files[Index];

     if ExtractFileName(InputFileName)<>'output.glb' then begin

      Stream:=TMemoryStream.Create;
      try

       Stream.LoadFromFile(InputFileName);

       Stream.Seek(0,soBeginning);

       if assigned(BaseGLTF) then begin

        CurrentGLTF:=TPasGLTF.TDocument.Create;
        try

         CurrentGLTF.LoadFromStream(Stream);

         if SingleBuffer and (CurrentGLTF.Buffers.Count<>1) then begin
          raise Exception.Create('At least a additional GLTF have not exactly one buffer');
         end;

         BaseAccessorIndex:=BaseGLTF.Accessors.Count;

         if SingleBuffer then begin
          BaseBufferIndex:=0;
          BaseBufferByteOffset:=BaseGLTF.Buffers[0].ByteLength;
         end else begin
          BaseBufferIndex:=BaseGLTF.Buffers.Count;
          BaseBufferByteOffset:=0;
         end;

         BaseBufferViewIndex:=BaseGLTF.BufferViews.Count;

         for ItemIndex:=0 to CurrentGLTF.Accessors.Count-1 do begin

          CurrentAccessor:=CurrentGLTF.Accessors[ItemIndex];

          NewAccessor:=TPasGLTF.TAccessor.Create(BaseGLTF);
          try

           if assigned(CurrentAccessor.Extensions) then begin
            NewAccessor.Extensions.Merge(CurrentAccessor.Extensions);
           end;

           if assigned(CurrentAccessor.Extras) then begin
            NewAccessor.Extras.Merge(CurrentAccessor.Extras);
           end;

           NewAccessor.ComponentType:=CurrentAccessor.ComponentType;
           NewAccessor.Type_:=CurrentAccessor.Type_;
           NewAccessor.BufferView:=CurrentAccessor.BufferView+BaseBufferViewIndex;
           NewAccessor.ByteOffset:=CurrentAccessor.ByteOffset;
           NewAccessor.Count:=CurrentAccessor.Count;
           for OtherIndex:=0 to CurrentAccessor.MinArray.Count-1 do begin
            NewAccessor.MinArray.Add(CurrentAccessor.MinArray[OtherIndex]);
           end;
           for OtherIndex:=0 to CurrentAccessor.MaxArray.Count-1 do begin
            NewAccessor.MaxArray.Add(CurrentAccessor.MaxArray[OtherIndex]);
           end;
           NewAccessor.Normalized:=CurrentAccessor.Normalized;
           NewAccessor.BufferView:=CurrentAccessor.BufferView+BaseBufferViewIndex;
           NewAccessor.Count:=CurrentAccessor.Count;

           if assigned(CurrentAccessor.Sparse.Extensions) then begin
            NewAccessor.Sparse.Extensions.Merge(CurrentAccessor.Sparse.Extensions);
           end;

           if assigned(CurrentAccessor.Sparse.Extras) then begin
            NewAccessor.Sparse.Extras.Merge(CurrentAccessor.Sparse.Extras);
           end;

           NewAccessor.Sparse.Count:=CurrentAccessor.Sparse.Count;

           if assigned(CurrentAccessor.Sparse.Indices.Extensions) then begin
            NewAccessor.Sparse.Indices.Extensions.Merge(CurrentAccessor.Sparse.Indices.Extensions);
           end;

           if assigned(CurrentAccessor.Sparse.Indices.Extras) then begin
            NewAccessor.Sparse.Indices.Extras.Merge(CurrentAccessor.Sparse.Indices.Extras);
           end;

           NewAccessor.Sparse.Indices.ComponentType:=CurrentAccessor.Sparse.Indices.ComponentType;
           NewAccessor.Sparse.Indices.BufferView:=CurrentAccessor.Sparse.Indices.BufferView+BaseBufferViewIndex;
           NewAccessor.Sparse.Indices.ByteOffset:=CurrentAccessor.Sparse.Indices.ByteOffset;
           NewAccessor.Sparse.Indices.Empty:=CurrentAccessor.Sparse.Indices.Empty;

           if assigned(CurrentAccessor.Sparse.Values.Extensions) then begin
            NewAccessor.Sparse.Values.Extensions.Merge(CurrentAccessor.Sparse.Values.Extensions);
           end;

           if assigned(CurrentAccessor.Sparse.Indices.Extras) then begin
            NewAccessor.Sparse.Values.Extras.Merge(CurrentAccessor.Sparse.Values.Extras);
           end;

           NewAccessor.Sparse.Values.BufferView:=CurrentAccessor.Sparse.Values.BufferView+BaseBufferViewIndex;
           NewAccessor.Sparse.Values.ByteOffset:=CurrentAccessor.Sparse.Values.ByteOffset;
           NewAccessor.Sparse.Values.Empty:=CurrentAccessor.Sparse.Values.Empty;

          finally
           BaseGLTF.Accessors.Add(NewAccessor);
          end;

         end;

         if SingleBuffer then begin

          CurrentBuffer:=CurrentGLTF.Buffers[0];

          NewBuffer:=BaseGLTF.Buffers[0];

          NewBuffer.Data.Seek(0,soEnd);
          CurrentBuffer.Data.Seek(0,soBeginning);
          NewBuffer.Data.CopyFrom(CurrentBuffer.Data,CurrentBuffer.ByteLength);
          NewBuffer.ByteLength:=NewBuffer.ByteLength+CurrentBuffer.ByteLength;

         end else begin

          for ItemIndex:=0 to CurrentGLTF.Buffers.Count-1 do begin

           CurrentBuffer:=CurrentGLTF.Buffers[ItemIndex];

           NewBuffer:=TPasGLTF.TBuffer.Create(BaseGLTF);
           try

            if assigned(CurrentBuffer.Extensions) then begin
             NewBuffer.Extensions.Merge(CurrentBuffer.Extensions);
            end;

            if assigned(CurrentBuffer.Extras) then begin
             NewBuffer.Extras.Merge(CurrentBuffer.Extras);
            end;

            NewBuffer.ByteLength:=CurrentBuffer.ByteLength;

            NewBuffer.Name:=CurrentBuffer.Name;

            NewBuffer.Data.LoadFromStream(CurrentBuffer.Data);

           finally
            BaseGLTF.Buffers.Add(NewBuffer);
           end;

          end;

         end;

         for ItemIndex:=0 to CurrentGLTF.BufferViews.Count-1 do begin

          CurrentBufferView:=CurrentGLTF.BufferViews[ItemIndex];

          NewBufferView:=TPasGLTF.TBufferView.Create(BaseGLTF);
          try

           if assigned(CurrentBufferView.Extensions) then begin
            NewBufferView.Extensions.Merge(CurrentBufferView.Extensions);
           end;

           if assigned(CurrentBufferView.Extras) then begin
            NewBufferView.Extras.Merge(CurrentBufferView.Extras);
           end;

           NewBufferView.ByteLength:=CurrentBufferView.ByteLength;

           NewBufferView.Name:=CurrentBufferView.Name;

           NewBufferView.Buffer:=CurrentBufferView.Buffer+BaseBufferIndex;

           NewBufferView.ByteLength:=CurrentBufferView.ByteLength;

           NewBufferView.ByteOffset:=CurrentBufferView.ByteOffset+BaseBufferByteOffset;

           NewBufferView.ByteStride:=CurrentBufferView.ByteStride;

           NewBufferView.Target:=CurrentBufferView.Target;

          finally
           BaseGLTF.BufferViews.Add(NewBufferView);
          end;

         end;

         for ItemIndex:=0 to CurrentGLTF.Animations.Count-1 do begin

          CurrentAnimation:=CurrentGLTF.Animations[ItemIndex];

          NewAnimation:=TPasGLTF.TAnimation.Create(BaseGLTF);
          try

           NewAnimation.Name:=CurrentAnimation.Name;

           if assigned(CurrentAnimation.Extensions) then begin
            NewAnimation.Extensions.Merge(CurrentAnimation.Extensions);
           end;

           if assigned(CurrentAnimation.Extras) then begin
            NewAnimation.Extras.Merge(CurrentAnimation.Extras);
           end;

           for CurrentAnimationSampler in CurrentAnimation.Samplers do begin

            NewAnimationSampler:=TPasGLTF.TAnimation.TSampler.Create(BaseGLTF);
            try

             if assigned(CurrentAnimationSampler.Extensions) then begin
              NewAnimationSampler.Extensions.Merge(CurrentAnimationSampler.Extensions);
             end;

             if assigned(CurrentAnimationSampler.Extras) then begin
              NewAnimationSampler.Extras.Merge(CurrentAnimationSampler.Extras);
             end;

             NewAnimationSampler.Input:=CurrentAnimationSampler.Input+BaseAccessorIndex;
             NewAnimationSampler.Output:=CurrentAnimationSampler.Output+BaseAccessorIndex;
             NewAnimationSampler.Interpolation:=CurrentAnimationSampler.Interpolation;

            finally
             NewAnimation.Samplers.Add(NewAnimationSampler);
            end;

           end;

           for CurrentAnimationChannel in CurrentAnimation.Channels do begin

            NewAnimationChannel:=TPasGLTF.TAnimation.TChannel.Create(BaseGLTF);
            try

             if assigned(CurrentAnimationChannel.Extensions) then begin
              NewAnimationChannel.Extensions.Merge(CurrentAnimationChannel.Extensions);
             end;

             if assigned(CurrentAnimationChannel.Extras) then begin
              NewAnimationChannel.Extras.Merge(CurrentAnimationChannel.Extras);
             end;

             NewAnimationChannel.Sampler:=CurrentAnimationChannel.Sampler;

             if assigned(CurrentAnimationChannel.Target.Extensions) then begin
              NewAnimationChannel.Target.Extensions.Merge(CurrentAnimationChannel.Target.Extensions);
             end;

             if assigned(CurrentAnimationChannel.Target.Extras) then begin
              NewAnimationChannel.Target.Extras.Merge(CurrentAnimationChannel.Target.Extras);
             end;

             NewAnimationChannel.Target.Node:=CurrentAnimationChannel.Target.Node;
             NewAnimationChannel.Target.Path:=CurrentAnimationChannel.Target.Path;
             NewAnimationChannel.Target.Empty:=CurrentAnimationChannel.Target.Empty;

            finally
             NewAnimation.Channels.Add(NewAnimationChannel);
            end;

           end;

          finally
           BaseGLTF.Animations.Add(NewAnimation);
          end;

         end;

        finally
         FreeAndNil(CurrentGLTF);
        end;

       end else begin

        BaseGLTF:=TPasGLTF.TDocument.Create;

        BaseGLTF.LoadFromStream(Stream);

        SingleBuffer:=BaseGLTF.Buffers.Count=1;

       end;

      finally
       FreeAndNil(Stream);
      end;

     end;

    end;

   end;

  finally
   FreeAndNil(Files);
  end;

  if assigned(BaseGLTF) then begin
   Stream:=TMemoryStream.Create;
   try
    BaseGLTF.SaveToBinary(Stream);
    Stream.SaveToFile(BaseDirectory+'output.glb');
   finally
    FreeAndNil(Stream);
   end;
  end;

 finally
  FreeAndNil(BaseGLTF);
 end;

end.


