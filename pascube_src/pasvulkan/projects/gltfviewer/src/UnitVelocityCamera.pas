unit UnitVelocityCamera;
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

{$scopedenums on}

{$define UseMomentBasedOrderIndependentTransparency}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math;

type { TVelocityCamera }
     TVelocityCamera=class 
      private
       fLastPosition:TpvVector3;
       fLastOrientation:TpvQuaternion;
       fPosition:TpvVector3;
       fOrientation:TpvQuaternion;
       fInterpolatedPosition:TpvVector3;
       fInterpolatedOrientation:TpvQuaternion;
       fLinearVelocity:TpvVector3;
       fAngularVelocity:TpvVector3;
       fForce:TpvVector3;
       fTorque:TpvVector3;
       fLinearVelocityDamping:TpvScalar;
       fAngularVelocityDamping:TpvScalar;
       fTimeAccumulator:TpvDouble;
       fTimeStep:TpvDouble;
       fFirstUpdate:boolean;
       fLinearVelocitySpeed:TpvScalar;
       fAngularVelocitySpeed:TpvScalar;
      private
       fKeyLeft:boolean;
       fKeyRight:boolean;
       fKeyUp:boolean;
       fKeyDown:boolean;
       fKeyForward:boolean;
       fKeyBackward:boolean;
       fKeyRollLeft:boolean;
       fKeyRollRight:boolean;
       fKeyPitchUp:boolean;
       fKeyPitchDown:boolean;
       fKeyYawLeft:boolean;
       fKeyYawRight:boolean;
      private
       function GetMatrix:TpvMatrix4x4;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Reset;
       procedure SetPositionAndOrientation(const aPosition:TpvVector3;const aOrientation:TpvQuaternion);
       procedure Update(const aDeltaTime:TpvDouble);
       procedure AddForce(const aForce:TpvVector3);
       procedure AddTorque(const aTorque:TpvVector3);
      public
       property Position:TpvVector3 read fPosition write fPosition;
       property Orientation:TpvQuaternion read fOrientation write fOrientation;
       property LinearVelocity:TpvVector3 read fLinearVelocity write fLinearVelocity;
       property AngularVelocity:TpvVector3 read fAngularVelocity write fAngularVelocity;
       property Force:TpvVector3 read fForce write fForce;
       property Torque:TpvVector3 read fTorque write fTorque;
       property LinearVelocityDamping:TpvScalar read fLinearVelocityDamping write fLinearVelocityDamping;
       property AngularVelocityDamping:TpvScalar read fAngularVelocityDamping write fAngularVelocityDamping;
       property Matrix:TpvMatrix4x4 read GetMatrix;
       property LinearVelocitySpeed:TpvScalar read fLinearVelocitySpeed write fLinearVelocitySpeed;
       property AngularVelocitySpeed:TpvScalar read fAngularVelocitySpeed write fAngularVelocitySpeed;
      public 
       property KeyLeft:boolean read fKeyLeft write fKeyLeft;
       property KeyRight:boolean read fKeyRight write fKeyRight;
       property KeyUp:boolean read fKeyUp write fKeyUp;
       property KeyDown:boolean read fKeyDown write fKeyDown;
       property KeyForward:boolean read fKeyForward write fKeyForward;
       property KeyBackward:boolean read fKeyBackward write fKeyBackward;
       property KeyRollLeft:boolean read fKeyRollLeft write fKeyRollLeft;
       property KeyRollRight:boolean read fKeyRollRight write fKeyRollRight;
       property KeyPitchUp:boolean read fKeyPitchUp write fKeyPitchUp;
       property KeyPitchDown:boolean read fKeyPitchDown write fKeyPitchDown;
       property KeyYawLeft:boolean read fKeyYawLeft write fKeyYawLeft;
       property KeyYawRight:boolean read fKeyYawRight write fKeyYawRight;       
     end;   

implementation

{ TVelocityCamera }

constructor TVelocityCamera.Create;
begin
 inherited Create;

 fLastPosition:=TpvVector3.Origin;
 fLastOrientation:=TpvQuaternion.Identity;

 fPosition:=TpvVector3.Origin;
 fOrientation:=TpvQuaternion.Identity;

 fInterpolatedPosition:=TpvVector3.Origin;
 fInterpolatedOrientation:=TpvQuaternion.Identity;
 
 fLinearVelocity:=TpvVector3.Null;
 fAngularVelocity:=TpvVector3.Null;

 fForce:=TpvVector3.Null;
 fTorque:=TpvVector3.Null;

 fTimeAccumulator:=0.0;
 fTimeStep:=1.0/60.0;

 fLinearVelocityDamping:=1.0;
 fAngularVelocityDamping:=1.0;

 fFirstUpdate:=true;

 fKeyLeft:=false;
 fKeyRight:=false;
 fKeyUp:=false;
 fKeyDown:=false;
 fKeyForward:=false;
 fKeyBackward:=false;
 fKeyRollLeft:=false;
 fKeyRollRight:=false;
 fKeyPitchUp:=false;
 fKeyPitchDown:=false;
 fKeyYawLeft:=false;
 fKeyYawRight:=false;

 fLinearVelocitySpeed:=20.0;
 fAngularVelocitySpeed:=1.0;

end;

destructor TVelocityCamera.Destroy;
begin
 inherited Destroy;
end;

function TVelocityCamera.GetMatrix:TpvMatrix4x4;
begin
 result:=TpvMatrix4x4.CreateFromQuaternion(fInterpolatedOrientation);
 result.Components[3,0]:=fInterpolatedPosition.x;
 result.Components[3,1]:=fInterpolatedPosition.y;
 result.Components[3,2]:=fInterpolatedPosition.z; 
end;

procedure TVelocityCamera.Reset;
begin

 fLastPosition:=TpvVector3.Origin;
 fLastOrientation:=TpvQuaternion.Identity;

 fPosition:=TpvVector3.Origin;
 fOrientation:=TpvQuaternion.Identity;

 fInterpolatedPosition:=TpvVector3.Origin;
 fInterpolatedOrientation:=TpvQuaternion.Identity;
 
 fLinearVelocity:=TpvVector3.Null;
 fAngularVelocity:=TpvVector3.Null;

 fForce:=TpvVector3.Null;
 fTorque:=TpvVector3.Null;

 fKeyLeft:=false;
 fKeyRight:=false;
 fKeyUp:=false;
 fKeyDown:=false;
 fKeyForward:=false;
 fKeyBackward:=false;
 fKeyRollLeft:=false;
 fKeyRollRight:=false;
 fKeyPitchUp:=false;
 fKeyPitchDown:=false;
 fKeyYawLeft:=false;
 fKeyYawRight:=false;

 fFirstUpdate:=true;

end;

procedure TVelocityCamera.SetPositionAndOrientation(const aPosition:TpvVector3;const aOrientation:TpvQuaternion);
begin
 fLastPosition:=aPosition;
 fLastOrientation:=aOrientation;
 fPosition:=aPosition;
 fOrientation:=aOrientation;
 fInterpolatedPosition:=aPosition;
 fInterpolatedOrientation:=aOrientation;
 fFirstUpdate:=true;
end;

procedure TVelocityCamera.Update(const aDeltaTime:TpvDouble);
const OneDiv3=1.0/3.0;
      OneDiv6=1.0/6.0;
var Alpha,DeltaTimeDiv6,DeltaTimeDiv3:TpvDouble;
    Positions:array[0..3] of TpvVector3;
    Quaternions:array[0..3] of TpvQuaternion;
    HalfSpinQuaternion:TpvQuaternion;
    OrientationMatrix:TpvMatrix3x3;
begin
 
 DeltaTimeDiv6:=fTimeStep*OneDiv6;
 DeltaTimeDiv3:=fTimeStep*OneDiv3;

 if fFirstUpdate then begin
  fFirstUpdate:=false;
  fLastPosition:=fPosition;
  fLastOrientation:=fOrientation;
  fInterpolatedPosition:=fPosition;
  fInterpolatedOrientation:=fOrientation;
 end;

 // Accumulate time with delta time
 fTimeAccumulator:=fTimeAccumulator+aDeltaTime;

 // While time accumulator is greater or equal to time step, for proper fixed time step integration
 while fTimeAccumulator>=fTimeStep do begin

  // Decrease time accumulator wrapped around the time step
  fTimeAccumulator:=fTimeAccumulator-fTimeStep;

  // Save last position and orientation
  fLastPosition:=fPosition;
  fLastOrientation:=fOrientation;

  // Get orientation matrix
  OrientationMatrix:=TpvMatrix3x3.CreateFromQuaternion(fOrientation);

  // Process key input
  if fKeyLeft then begin
   fForce:=fForce-(OrientationMatrix.Right*fLinearVelocitySpeed);
  end; 
  if fKeyRight then begin
   fForce:=fForce+(OrientationMatrix.Right*fLinearVelocitySpeed);
  end;
  if fKeyUp then begin
   fForce:=fForce+(OrientationMatrix.Up*fLinearVelocitySpeed);
  end;
  if fKeyDown then begin
   fForce:=fForce-(OrientationMatrix.Up*fLinearVelocitySpeed);
  end;
  if fKeyForward then begin
   fForce:=fForce-(OrientationMatrix.Forwards*fLinearVelocitySpeed);
  end;
  if fKeyBackward then begin
   fForce:=fForce+(OrientationMatrix.Forwards*fLinearVelocitySpeed);
  end;

  // Roll: Rotation around the forward axis
  if fKeyRollLeft then begin
   fTorque:=fTorque+(OrientationMatrix.Forwards*fAngularVelocitySpeed);
  end;
  if fKeyRollRight then begin
   fTorque:=fTorque-(OrientationMatrix.Forwards*fAngularVelocitySpeed);
  end;

  // Pitch: Rotation around the right axis
  if fKeyPitchUp then begin
   fTorque:=fTorque+(OrientationMatrix.Right*fAngularVelocitySpeed);
  end;
  if fKeyPitchDown then begin
   fTorque:=fTorque-(OrientationMatrix.Right*fAngularVelocitySpeed);
  end;

  // Yaw: Rotation around the up axis
  if fKeyYawLeft then begin
   fTorque:=fTorque-(OrientationMatrix.Up*fAngularVelocitySpeed);
  end;
  if fKeyYawRight then begin
   fTorque:=fTorque+(OrientationMatrix.Up*fAngularVelocitySpeed);
  end;

  // Integration of forces
  fLinearVelocity:=fLinearVelocity+(fForce*fTimeStep);
  fAngularVelocity:=fAngularVelocity+(fTorque*fTimeStep);
  
  // Damping
  fLinearVelocity:=fLinearVelocity/(1.0+(fLinearVelocityDamping*fTimeStep));
  fAngularVelocity:=fAngularVelocity/(1.0+(fAngularVelocityDamping*fTimeStep));

  // Integration of linear velocity (RK4)
  Positions[0]:=fLinearVelocity;
  Positions[1]:=Positions[0]+(fLinearVelocity*(fTimeStep*0.5));
  Positions[2]:=Positions[1]+(fLinearVelocity*(fTimeStep*0.5));
  Positions[3]:=Positions[2]+(fLinearVelocity*fTimeStep);
  fPosition:=fPosition+(((Positions[0]+Positions[3])*DeltaTimeDiv6)+((Positions[1]+Positions[2])*DeltaTimeDiv3));

  // Integration of angular velocity (RK4)
  HalfSpinQuaternion.x:=fAngularVelocity.x*0.5;
  HalfSpinQuaternion.y:=fAngularVelocity.y*0.5;
  HalfSpinQuaternion.z:=fAngularVelocity.z*0.5;
  HalfSpinQuaternion.w:=0;
  Quaternions[0]:=HalfSpinQuaternion*fOrientation.Normalize;
  Quaternions[1]:=HalfSpinQuaternion*(fOrientation+(Quaternions[0]*(fTimeStep*0.5))).Normalize;
  Quaternions[2]:=HalfSpinQuaternion*(fOrientation+(Quaternions[1]*(fTimeStep*0.5))).Normalize;
  Quaternions[3]:=HalfSpinQuaternion*(fOrientation+(Quaternions[2]*fTimeStep)).Normalize;
  fOrientation:=(fOrientation+(((Quaternions[0]+Quaternions[3])*DeltaTimeDiv6)+((Quaternions[1]+Quaternions[2])*DeltaTimeDiv3))).Normalize;

  // Reset forces and torques
  fForce:=TpvVector3.Null;
  fTorque:=TpvVector3.Null;

 end;

 // Interpolation factor (based on time accumulator and time step)
 Alpha:=fTimeAccumulator/fTimeStep;

 // Interpolate between last and current position and orientation
 fInterpolatedPosition:=fLastPosition.Lerp(fPosition,Alpha);
 fInterpolatedOrientation:=fLastOrientation.Slerp(fOrientation,Alpha);

end;

procedure TVelocityCamera.AddForce(const aForce:TpvVector3);
begin
 fForce:=fForce+aForce;
end;

procedure TVelocityCamera.AddTorque(const aTorque:TpvVector3);
begin
 fTorque:=fTorque+aTorque;
end;

end.
