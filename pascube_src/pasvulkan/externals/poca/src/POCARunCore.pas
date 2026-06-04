unit pocaruncore;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef win32}
 {$apptype console}
 {$define Windows}
{$endif}
{$ifdef win64}
 {$apptype console}
 {$define Windows}
{$endif}

interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,POCA;

procedure MainProc;

implementation

uses PasDblStrUtils;

const REPLCode='print("Welcome to POCA version '+POCAVersion+'.\n");'#13#10+
               'print("Type \".help\" for more information. To exit, press Ctrl+C, Ctrl+D or type \".exit\".\n");'#13#10+
               'let expr = "", lineRegExp = /^(.*)\\s*$/, cmdRegEx = /^\s*\.(\w+)\s*(.*)/, currentScope = {};'#13#10+
               'while(1){'#13#10+
               '  let match, line = readLine((expr == "") ? "> " : ". ");'#13#10+
               '  if(line === null){'#13#10+
               '    break;'#13#10+
               '  }'#13#10+
               '  if(match = lineRegExp.match(line)){'#13#10+
               '    expr ~= match[0][1] ~ "\n";'#13#10+
               '    continue;'#13#10+
               '  }'#13#10+
               '  expr ~= line;'#13#10+
               '  if(expr == "exit"){'#13#10+
               '    break;'#13#10+
               '  }else if(match = cmdRegEx.match(expr)){'#13#10+
               '    let cmd = match[0][1];'#13#10+
               '    when(cmd){'#13#10+
               '      case("exit"){'#13#10+
               '        break;'#13#10+
               '      }'#13#10+
               '      case("help"){'#13#10+
               '        print(".exit     Exit the REPL\n");'#13#10+
               '        print(".help     Print this help message\n");'#13#10+
               '      }'#13#10+
               '      else{'#13#10+
               '        print("Invalid REPL keyword \"." ~ cmd ~ "\"\n");'#13#10+
               '      }'#13#10+
               '    }'#13#10+
               '  }else{'#13#10+
               '    try{'#13#10+
               '      print("< " ~ String.dump(eval(expr, "<eval>", [], null, currentScope)) ~ "\n");'#13#10+
               '    }catch(let err){'#13#10+
               '      for(let i = err.size() - 1; i >= 0; i--){'#13#10+
               '        print(err[i] ~ " ");'#13#10+
               '      }'#13#10+
               '      print("\n");'#13#10+
               '    }'#13#10+
               '  }'#13#10+
               '  expr = "";'#13#10+
               '}'#13#10;

type TRandomNumberGenerator=class(TPOCANativeObject)
      public
       constructor Create(const pInstance:PPOCAInstance;const pContext:PPOCAContext;const pPrototype,pConstructor:PPOCAValue;const pExpandable:boolean); override;
       destructor Destroy; override;
      published
       function create_(const Context:PPOCAContext;const This:TPOCAValue;const Arguments:PPOCAValues;const CountArguments:longint):TPOCAValue;
     end;

     TRandomNumberGeneratorInstance=class(TPOCANativeObject)
      public
       constructor Create(const pInstance:PPOCAInstance;const pContext:PPOCAContext;const pPrototype,pConstructor:PPOCAValue;const pExpandable:boolean); override;
       destructor Destroy; override;
       function GetRandomNumber:double;
      published
       function get(const Context:PPOCAContext;const This:TPOCAValue;const Arguments:PPOCAValues;const CountArguments:longint):TPOCAValue;
       property randomnumber:double read GetRandomNumber;
     end;

constructor TRandomNumberGenerator.Create(const pInstance:PPOCAInstance;const pContext:PPOCAContext;const pPrototype,pConstructor:PPOCAValue;const pExpandable:boolean);
begin
 inherited Create(pInstance,pContext,pPrototype,pConstructor,pExpandable);
end;

destructor TRandomNumberGenerator.Destroy;
begin
 inherited Destroy;
end;

function TRandomNumberGenerator.create_(const Context:PPOCAContext;const This:TPOCAValue;const Arguments:PPOCAValues;const CountArguments:longint):TPOCAValue;
begin
 result:=POCANewNativeObject(Context,TRandomNumberGeneratorInstance.Create(Instance,Context,nil,@GhostValue,false));
end;

constructor TRandomNumberGeneratorInstance.Create(const pInstance:PPOCAInstance;const pContext:PPOCAContext;const pPrototype,pConstructor:PPOCAValue;const pExpandable:boolean);
begin
 inherited Create(pInstance,pContext,pPrototype,pConstructor,pExpandable,true);
end;

destructor TRandomNumberGeneratorInstance.Destroy;
begin
 inherited Destroy;
end;

function TRandomNumberGeneratorInstance.GetRandomNumber:double;
begin
 result:=random;
end;

function TRandomNumberGeneratorInstance.get(const Context:PPOCAContext;const This:TPOCAValue;const Arguments:PPOCAValues;const CountArguments:longint):TPOCAValue;
begin
 result.Num:=GetRandomNumber;
end;

type TPOCAHostData=record

      Instance:PPOCAInstance;

      Vector2Hash:TPOCAValue;
      Vector2HashEvents:TPOCAValue;

     end;
     PPOCAHostData=^TPOCAHostData;

function POCAGetHostData(const aContext:PPOCAContext):PPOCAHostData;
begin
 result:=aContext^.Instance^.Globals.HostData;
end;

procedure POCASetHostData(const aContext:PPOCAContext;const aHostData:PPOCAHostData);
begin
 aContext^.Instance^.Globals.HostData:=aHostData;
end;
type TVector2D=record
      x,y:Double;
     end;
     PVector2D=^TVector2D;

procedure POCAVector2GhostDestroy(const aGhost:PPOCAGhost);
begin
 if assigned(aGhost) and assigned(aGhost^.Ptr) then begin
  FreeMem(aGhost^.Ptr);
 end;
end;

function POCAVector2GhostExistKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var s:TPOCAUTF8String;
begin
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    result:=true;
   end;
   'y','g':begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

function POCAVector2GhostGetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;out aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector2:PVector2D;
    s:TPOCAUTF8String;
begin
 Vector2:=PVector2D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    aValue.Num:=Vector2^.x;
    result:=true;
   end;
   'y','g':begin
    aValue.Num:=Vector2^.y;
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

function POCAVector2GhostSetKey(const aContext:PPOCAContext;const aGhost:PPOCAGhost;const aKey:TPOCAValue;const aValue:TPOCAValue;const aCacheIndex:PPOCAUInt32):TPOCABool32;
var Vector2:PVector2D;
    s:TPOCAUTF8String;
begin
 Vector2:=PVector2D(PPOCAGhost(aGhost)^.Ptr);
 s:=POCAGetStringValue(aContext,aKey);
 if length(s)=1 then begin
  case s[1] of
   'x','r':begin
    Vector2^.x:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   'y','g':begin
    Vector2^.y:=POCAGetNumberValue(aContext,aValue);
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
end;

const POCAVector2Ghost:TPOCAGhostType=
       (
        Destroy:POCAVector2GhostDestroy;
        CanDestroy:nil;
        Mark:nil;
        ExistKey:POCAVector2GhostExistKey;
        GetKey:POCAVector2GhostGetKey;
        SetKey:POCAVector2GhostSetKey;
        Name:'Vector2'
       );

function POCANewVector2(const aContext:PPOCAContext;const aVector2:TVector2D):TPOCAValue; overload;
var Vector2:PVector2D;
begin
 Vector2:=nil;
 GetMem(Vector2,SizeOf(TVector2D));
 Vector2^:=aVector2;
 result:=POCANewGhost(aContext,@POCAVector2Ghost,Vector2,nil,pgptRAW);
 POCATemporarySave(aContext,result);
 POCAGhostSetHashValue(result,POCAGetHostData(aContext)^.Vector2Hash);
end;

function POCANewVector2(const aContext:PPOCAContext;const aX:Double;const aY:Double):TPOCAValue; overload;
var v:TVector2D;
begin
 v.x:=aX;
 v.y:=aY;
 result:=POCANewVector2(aContext,v);
end;

function POCAGetVector2Value(const aValue:TPOCAValue):TVector2D;
begin
 if POCAGhostGetType(aValue)=@POCAVector2Ghost then begin
  result:=PVector2D(POCAGhostFastGetPointer(aValue))^;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
 end;
end;

function POCAVector2FunctionCREATE(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:TVector2D;
begin
 if (aCountArguments>0) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=PVector2D(POCAGhostFastGetPointer(aArguments^[0]))^;
 end else begin
  if aCountArguments>0 then begin
   Vector2.x:=POCAGetNumberValue(aContext,aArguments^[0]);
  end else begin
   Vector2.x:=0.0;
  end;
  if aCountArguments>1 then begin
   Vector2.y:=POCAGetNumberValue(aContext,aArguments^[1]);
  end else begin
   Vector2.y:=0.0;
  end;
 end;
 result:=POCANewVector2(aContext,Vector2);
end;

function POCAVector2FunctionLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,sqrt(sqr(Vector2^.x)+sqr(Vector2^.y)));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSquaredLength(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewNumber(aContext,sqr(Vector2^.x)+sqr(Vector2^.y));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNormalize(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    l:Double;
begin
 if POCAGhostGetType(aThis)=@POCAVector2Ghost then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  l:=sqrt(sqr(Vector2^.x)+sqr(Vector2^.y));
  if l>0.0 then begin
   Vector2^.x:=Vector2^.x/l;
   Vector2^.y:=Vector2^.y/l;
  end;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionDot(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result.Num:=(Vector2^.x*OtherVector2^.x)+(Vector2^.y*OtherVector2^.y);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionClone(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  result:=POCANewVector2(aContext,Vector2^);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionCopy(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^:=OtherVector2^;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^.x:=Vector2^.x+OtherVector2^.x;
  Vector2^.y:=Vector2^.y+OtherVector2^.y;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^.x:=Vector2^.x-OtherVector2^.x;
  Vector2^.y:=Vector2^.y-OtherVector2^.y;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    Factor:Double;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector2^.x:=Vector2^.x*Factor;
  Vector2^.y:=Vector2^.y*Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^.x:=Vector2^.x*OtherVector2^.x;
  Vector2^.y:=Vector2^.y*OtherVector2^.y;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    Factor:Double;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[0])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Factor:=POCAGetNumberValue(aContext,aArguments^[0]);
  Vector2^.x:=Vector2^.x/Factor;
  Vector2^.y:=Vector2^.y/Factor;
  result:=aThis;
 end else if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Vector2^.x:=Vector2^.x/OtherVector2^.x;
  Vector2^.y:=Vector2^.y/OtherVector2^.y;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  Vector2^.x:=-Vector2^.x;
  Vector2^.y:=-Vector2^.y;
  result:=aThis;
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord((Vector2^.x=OtherVector2^.x) and (Vector2^.y=OtherVector2^.y)) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewNumber(aContext,ord((Vector2^.x<>OtherVector2^.x) and (Vector2^.y<>OtherVector2^.y)) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    s:TPOCAUTF8String;
begin
 if (aCountArguments=0) and (POCAGhostGetType(aThis)=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aThis);
  s:='['+ConvertDoubleToString(Vector2^.x,omStandard,-1)+','+ConvertDoubleToString(Vector2^.y,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

// "THIS" is null, because it is a binary operator, so the first argument is the first operand and the second argument is the second operand
function POCAVector2FunctionOpAdd(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    v:TVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  v.x:=Vector2^.x+OtherVector2^.x;
  v.y:=Vector2^.y+OtherVector2^.y;
  result:=POCANewVector2(aContext,v);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpSub(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    v:TVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  v.x:=Vector2^.x-OtherVector2^.x;
  v.y:=Vector2^.y-OtherVector2^.y;
  result:=POCANewVector2(aContext,v);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpMul(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    v:TVector2D;
    Factor:Double;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  v.x:=Vector2^.x*Factor;
  v.y:=Vector2^.y*Factor;
  result:=POCANewVector2(aContext,v);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  v.x:=Vector2^.x*OtherVector2^.x;
  v.y:=Vector2^.y*OtherVector2^.y;
  result:=POCANewVector2(aContext,v);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpDiv(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
    v:TVector2D;
    Factor:Double;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGetValueType(aArguments^[1])=pvtNUMBER) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  Factor:=POCAGetNumberValue(aContext,aArguments^[1]);
  v.x:=Vector2^.x/Factor;
  v.y:=Vector2^.y/Factor;
  result:=POCANewVector2(aContext,v);
 end else if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  v.x:=Vector2^.x/OtherVector2^.x;
  v.y:=Vector2^.y/OtherVector2^.y;
  result:=POCANewVector2(aContext,v);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord((Vector2^.x=OtherVector2^.x) and (Vector2^.y=OtherVector2^.y)) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpNotEqual(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2,OtherVector2:PVector2D;
begin
 if (aCountArguments=2) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) and (POCAGhostGetType(aArguments^[1])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  OtherVector2:=POCAGhostFastGetPointer(aArguments^[1]);
  result:=POCANewNumber(aContext,ord((Vector2^.x<>OtherVector2^.x) and (Vector2^.y<>OtherVector2^.y)) and 1);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpNeg(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,-Vector2^.x,-Vector2^.y);
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpSqrt(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  result:=POCANewVector2(aContext,Sqrt(Vector2^.x),Sqrt(Vector2^.y));
 end else begin
  result:=POCAValueNull;
 end;
end;

function POCAVector2FunctionOpToString(aContext:PPOCAContext;const aThis:TPOCAValue;const aArguments:PPOCAValues;const aCountArguments:TPOCAInt32;const aUserData:TPOCAPointer):TPOCAValue;
var Vector2:PVector2D;
    s:TPOCAUTF8String;
begin
 if (aCountArguments=1) and (POCAGhostGetType(aArguments^[0])=@POCAVector2Ghost) then begin
  Vector2:=POCAGhostFastGetPointer(aArguments^[0]);
  s:='['+ConvertDoubleToString(Vector2^.x,omStandard,-1)+','+ConvertDoubleToString(Vector2^.y,omStandard,-1)+']';
  result:=POCANewString(aContext,s);
 end else begin
  result:=POCAValueNull;
 end;
end;

procedure POCAInitVector2Hash(aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 HostData:=POCAGetHostData(aContext);

 HostData^.Vector2Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector2Hash);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'length',POCAVector2FunctionLength);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'squaredLength',POCAVector2FunctionSquaredLength);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'normalize',POCAVector2FunctionNormalize);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'dot',POCAVector2FunctionDot);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'clone',POCAVector2FunctionClone);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'copy',POCAVector2FunctionCopy);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'add',POCAVector2FunctionAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'sub',POCAVector2FunctionSub);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'mul',POCAVector2FunctionMul);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'div',POCAVector2FunctionDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'neg',POCAVector2FunctionNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'equal',POCAVector2FunctionEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'notEqual',POCAVector2FunctionNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2Hash,'toString',POCAVector2FunctionToString);

 HostData^.Vector2HashEvents:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,HostData^.Vector2HashEvents);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__add',POCAVector2FunctionOpAdd);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__sub',POCAVector2FunctionOpSub);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__mul',POCAVector2FunctionOpMul);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__div',POCAVector2FunctionOpDiv);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__eq',POCAVector2FunctionOpEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__neq',POCAVector2FunctionOpNotEqual);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__neg',POCAVector2FunctionOpNeg);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__sqrt',POCAVector2FunctionOpSqrt);
 POCAAddNativeFunction(aContext,HostData^.Vector2HashEvents,'__tostring',POCAVector2FunctionOpToString);

 POCAHashSetHashEvents(aContext,HostData^.Vector2Hash,HostData^.Vector2HashEvents);

end;

procedure POCAInitVector2Namespace(aContext:PPOCAContext);
var Hash:TPOCAValue;
begin
 Hash:=POCANewHash(aContext);
 POCAArrayPush(aContext^.Instance^.Globals.RootArray,Hash);
 POCAAddNativeFunction(aContext,Hash,'create',POCAVector2FunctionCREATE);
 POCAHashSetString(aContext,aContext^.Instance^.Globals.Namespace,'Vector2',Hash);
end;

procedure POCAInitVector2(aContext:PPOCAContext);
begin
 POCAInitVector2Hash(aContext);
 POCAInitVector2Namespace(aContext);
end;

procedure InitializeForPOCAContext(const aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin

 GetMem(HostData,SizeOf(TPOCAHostData));
 FillChar(HostData^,SizeOf(TPOCAHostData),#0);

 HostData^.Instance:=aContext^.Instance;

 aContext^.Instance^.Globals.HostData:=HostData;
 aContext^.Instance^.Globals.HostDataFreeable:=true;

 POCAInitVector2(aContext);

end;

procedure FinalizeForPOCAContext(const aContext:PPOCAContext);
var HostData:PPOCAHostData;
begin
 HostData:=aContext^.Instance^.Globals.HostData;
 if Assigned(HostData) then begin
  try
   FreeMem(HostData);
  finally
   aContext^.Instance^.Globals.HostData:=nil;
  end;
 end;
end;

procedure UTF8WriteLn(const s:TPOCAUTF8String);
{$ifdef Windows}
var NumWritten:Cardinal;
begin
 WriteConsoleA(GetStdHandle(STD_OUTPUT_HANDLE),PAnsiChar(s),length(s),NumWritten,nil);
 WriteLn;
end;
{$else}
begin
 WriteLn(s);
end;
{$endif}

procedure MainProc2;
var Instance:PPOCAInstance;
    Context:PPOCAContext;
    Hash:TPOCAValue;
    Index:TPOCAPtrInt;
begin
 Instance:=POCAInstanceCreate;
 try
  Context:=POCAContextCreate(Instance);
  try
   Hash:=POCANewHash(Context);
   POCAHashSet(Context,Instance.Globals.Namespace,POCANewUniqueString(Context,'TestHash'),Hash);
   for Index:=0 to 16777216 do begin
    POCAHashSetString(Context,Hash,IntToStr(Index),POCANewNumber(Context,Index));
   end;
   POCAHashSetString(Context,Hash,IntToStr(-1),POCANewNumber(Context,-1));
  finally
   POCAContextDestroy(Context);
  end;
 finally
  POCAInstanceDestroy(Instance);
 end;
end;

procedure MainProc;
{$ifdef Windows}
//const CP_UTF16=1200;
{$endif}
var Instance:PPOCAInstance;
    Context:PPOCAContext;
    Code:TPOCAValue;
    ResultValue:TPOCAValue;
    ExitCode:TPOCAInt32;
    FileName:string;
    Arguments:array of TPOCAValue;
    i:longint;
begin
 ExitCode:=0;
{$ifdef Windows}
{SetTextCodePage(Input,CP_UTF8);
 SetTextCodePage(Output,CP_UTF8);
 SetConsoleCP(CP_UTF8);{}
 SetTextCodePage(Output,CP_UTF8);
 SetConsoleOutputCP(CP_UTF8);
{$endif}
 Randomize;
 Arguments:=nil;
 if FindCmdLineSwitch('h',true) then begin
  writeln('Usage: '+ExtractFileName(ParamStr(0))+' file.poca [parameters...]');
 end else begin
  Instance:=POCAInstanceCreate;
  try
   Context:=POCAContextCreate(Instance);
   try
    InitializeForPOCAContext(Context);
    try
     POCAHashSet(Context,Instance.Globals.Namespace,POCANewUniqueString(Context,'RandomNumberGenerator'),POCANewNativeObject(Context,TRandomNumberGenerator.Create(Instance,Context,nil,nil,false)));
     if ParamCount>0 then begin
      FileName:=ParamStr(1);
      if ParamCount>1 then begin
       SetLength(Arguments,ParamCount-1);
       for i:=2 to ParamCount do begin
        Arguments[i-2]:=POCANewString(Context,TPOCAUTF8String(ParamStr(i)));
       end;
      end;
      if not FileExists(FileName) then begin
       raise EPOCAGeneralError.Create(-1,-1,-1,'File "'+FileName+'" not found');
      end;
      Code:=POCACompile(Instance,Context,POCAGetFileContent(TPOCAUTF8String(FileName)),TPOCAUTF8String(FileName));
     end else begin
      Code:=POCACompile(Instance,Context,REPLCode,'<REPL>');
     end;
     ResultValue:=POCACall(Context,Code,@Arguments[0],length(Arguments),POCAValueNull,Instance^.Globals.Namespace);
     if POCAIsValueNumber(ResultValue) then begin
      ExitCode:=trunc(POCAGetNumberValue(Context,ResultValue));
     end;
    finally
     FinalizeForPOCAContext(Context);
    end;
   except
    on e:EPOCAGeneralError do begin
     writeln('GeneralError: ',e.Message);
     raise;
    end;
    on e:EPOCASyntaxError do begin
     writeln('SyntaxError["',Instance^.SourceFiles[e.SourceFile],'":',e.SourceLine,',',e.SourceColumn,']: ',e.Message);
     raise;
    end;
    on e:EPOCARuntimeError do begin
     writeln('RuntimeError["',Instance^.SourceFiles[e.SourceFile],'":',e.SourceLine,']: ',e.Message);
     raise;
    end;
    on e:EPOCAScriptError do begin
     writeln('ScriptError["',Instance^.SourceFiles[e.SourceFile],'":',e.SourceLine,']: ',e.Message);
     raise;
    end;
    on e:Exception do begin
     raise;
    end;
   end;
  finally
   SetLength(Arguments,0);
   POCAInstanceDestroy(Instance);
  end;
 end;
 if ExitCode<>0 then begin
  halt(ExitCode);
 end;
end;

end.
