(******************************************************************************
 *                   ARCADE CAR PHYSICS FOR KRAFT PHYSICS ENGINE              *
 ******************************************************************************
 *                        Version 2021-07-23-13-53-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (c) 2021-2021, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/kraft                                        *
 * 4. Write code, which is compatible with lastest Delphi and lastest         *
 *    FreePascal versions                                                     *
 * 5. Don't use Delphi VCL, FreePascal FCL or Lazarus LCL libraries/units.    *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able                                                       *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging                  *
 * 9. Use TKraftScalar instead of float/double so that Kraft can be compiled  *
 *    as double/single precision.                                             *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms in single   *
 *     and double precision.                                                  *
 *                                                                            *
 ******************************************************************************
 *                  Loosely based on the ideas and concepts of                *
 *               https://github.com/SergeyMakeev/ArcadeCarPhysics             *
 ******************************************************************************)
unit KraftArcadeCarPhysics;
{$ifdef fpc}
 {$mode delphi}
 {$warnings off}
 {$hints off}
 {$define caninline}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
  {$define cpux64}
 {$else}
  {$ifdef cpux86_64}
   {$define cpuamd64}
   {$define cpux64}
  {$endif}
 {$endif}
 {$ifdef cpu386}
  {$define cpu386}
  {$asmmode intel}
  {$define canx86simd}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {$packset fixed}
{$else}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$safedivide off}
 {$optimization on}
 {$undef caninline}
 {$undef canx86simd}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
 {$ifdef ver180}
  {$define caninline}
  {$ifdef cpu386}
   {$define canx86simd}
  {$endif}
  {$finitefloat off}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$extendedsyntax on}
{$writeableconst on}
{$varstringchecks on}
{$typedaddress off}
{$overflowchecks off}
{$rangechecks off}
{$ifndef fpc}
{$realcompatibility off}
{$endif}
{$openstrings on}
{$longstrings on}
{$booleval off}
{$typeinfo on}

{-$define UseMoreCollisionGroups}

{$define UseTriangleMeshFullPerturbation}

{-$define DebugDraw}

{-$define memdebug}

{$ifdef UseDouble}
 {$define NonSIMD}
{$endif}

{-$define NonSIMD}

{$ifdef NonSIMD}
 {$undef CPU386ASMForSinglePrecision}
 {$undef SIMD}
{$else}
 {$ifdef cpu386}
  {$if not (defined(Darwin) or defined(CompileForWithPIC))}
   {$define CPU386ASMForSinglePrecision}
  {$ifend}
 {$endif}
 {$undef SIMD}
 {$ifdef CPU386ASMForSinglePrecision}
  {$define SIMD}
 {$endif}
{$endif}

interface

uses {$ifdef windows}
      Windows,
      MMSystem,
     {$else}
      {$ifdef unix}
       BaseUnix,
       Unix,
       UnixType,
       {$if defined(linux) or defined(android)}
        linux,
       {$ifend}
      {$else}
       SDL,
      {$endif}
     {$endif}
     {$ifdef DebugDraw}
      {$ifndef NoOpenGL}
       {$ifdef fpc}
        GL,
        GLext,
       {$else}
        OpenGL,
       {$endif}
      {$endif}
     {$endif}
     SysUtils,
     Classes,
     SyncObjs,
{$ifdef KraftPasMP}
     PasMP,
{$endif}
{$ifdef KraftPasJSON}
     PasJSON,
{$endif}
     Math,
     Kraft;

type { TVehicle }
     TVehicle=class
      public
       const WheelWidth=0.085;
       type TDebugDrawLine=procedure(const aP0,aP1:TKraftVector3;const aColor:TKraftVector4) of object;
            { TEnvelope }
            TEnvelope=class
             public
              type TMode=
                    (
                     Custom,
                     Linear,
                     EaseInOut
                    );
              type TPoint=record
                    private
                     fTime:TKraftScalar;
                     fValue:TKraftScalar;
                    public
                     property Time:TKraftScalar read fTime write fTime;
                     property Value:TKraftScalar read fValue write fValue;
                   end;
                   PPoint=^TPoint;
                   TPoints=array of TPoint;
             private
              fMode:TMode;
              fPoints:TPoints;
              fCount:TKraftInt32;
             public
              constructor Create; reintroduce;
              constructor CreateLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
              constructor CreateEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
              destructor Destroy; override;
              procedure Clear;
              procedure Assign(const aFrom:TEnvelope);
              procedure Insert(const aTime,aValue:TKraftScalar);
              procedure FillLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
              procedure FillEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
{$ifdef KraftPasJSON}
              procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
              function SaveToJSON:TPasJSONItem;
{$endif}
              function GetTimeAtIndex(const aIndex:TKraftInt32):TKraftScalar;
              function GetValueAtIndex(const aIndex:TKraftInt32):TKraftScalar;
              function GetIndexFromTime(const aTime:TKraftScalar):TKraftInt32;
              function GetValueAtTime(const aTime:TKraftScalar):TKraftScalar;
             published
              property Count:TKraftInt32 read fCount;
            end;
            { TAxle }
            TAxle=class
             public
              type { TWheel }
                   TWheel=class
                    private
                     fVehicle:TVehicle;
                     fAxle:TAxle;
                     fIsOnGround:boolean;
                     fBrake:boolean;
                     fHandBrake:boolean;
                     fHitValid:boolean;
                     fLastHitValid:boolean;
                     fVisualHitValid:boolean;
                     fHitPoint:TKraftVector3;
                     fLastHitPoint:TKraftVector3;
                     fVisualHitPoint:TKraftVector3;
                     fHitNormal:TKraftVector3;
                     fHitTime:TKraftScalar;
                     fYawRad:TKraftScalar;
                     fVisualRotationRad:TKraftScalar;
                     fCompression:TKraftScalar;
                     fCompressionPrev:TKraftScalar;
                     fSuspensionLength:TKraftScalar;
                     fOffset:TKraftScalar;
                     fWorldTransform:TKraftMatrix4x4;
                     fLastWorldTransform:TKraftMatrix4x4;
                     fVisualWorldTransform:TKraftMatrix4x4;
                     fLastLocalWheelPosition:TKraftVector3;
                     fLastLocalWheelRotation:TKraftVector3;
                     fLocalWheelPosition:TKraftVector3;
                     fLocalWheelRotation:TKraftVector3;
                     fVisualLocalWheelPosition:TKraftVector3;
                     fVisualLocalWheelRotation:TKraftVector3;
{$ifdef DebugDraw}
                     fDebugDrawLinePoints:array[0..1] of TKraftVector3;
                     fDebugSlidingVelocity:TKraftVector3;
                     fDebugFrictionForce:TKraftVector3;
                     fDebugLongitudinalForce:TKraftVector3;
                     fDebugAccForcePoint:TKraftVector3;
                     fDebugEngineForce:TKraftVector3;
                     fLastDebugDrawLinePoints:array[0..1] of TKraftVector3;
                     fLastDebugSlidingVelocity:TKraftVector3;
                     fLastDebugFrictionForce:TKraftVector3;
                     fLastDebugLongitudinalForce:TKraftVector3;
                     fLastDebugAccForcePoint:TKraftVector3;
                     fLastDebugEngineForce:TKraftVector3;
                     fVisualDebugDrawLinePoints:array[0..1] of TKraftVector3;
                     fVisualDebugSlidingVelocity:TKraftVector3;
                     fVisualDebugFrictionForce:TKraftVector3;
                     fVisualDebugLongitudinalForce:TKraftVector3;
                     fVisualDebugAccForcePoint:TKraftVector3;
                     fVisualDebugEngineForce:TKraftVector3;
{$endif}
                     fRayCastFilterDirection:TKraftVector3;
                     fRayCastFilterBidirection:TKraftVector3;
                     function RayCastFilterHook(const aPoint,aNormal:TKraftVector3;const aTime:TKraftScalar;const aShape:TKraftShape):boolean;
                    public
                     constructor Create(const aAxle:TAxle;const aOffset:TKraftScalar); reintroduce;
                     destructor Destroy; override;
                     procedure UpdateSuspensionLength;
                     procedure Update(const aWorldSpacePosition:TKraftVector3;const aTotalWheelsCount,aCountPoweredWheels:TKraftInt32;const aLeft:boolean);
                     procedure CalculateWheelRotationFromSpeed;
                     procedure UpdateVisual;
                     procedure StoreWorldTransforms;
                     procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar);
{$ifdef KraftPasJSON}
                     procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
                     function SaveToJSON:TPasJSONItem;
{$endif}
{$ifdef DebugDraw}
                     procedure DebugDraw;
{$endif}
                    published
                     property Vehicle:TVehicle read fVehicle write fVehicle;
                     property Axle:TAxle read fAxle write fAxle;
                     property IsOnGround:boolean read fIsOnGround write fIsOnGround;
                     property Brake:boolean read fBrake write fBrake;
                     property HandBrake:boolean read fHandBrake write fHandBrake;
                     property HitValid:boolean read fHitValid write fHitValid;
                    public
                     property HitPoint:TKraftVector3 read fHitPoint write fHitPoint;
                     property HitNormal:TKraftVector3 read fHitNormal write fHitNormal;
                    published
                     property HitTime:TKraftScalar read fHitTime write fHitTime;
                     property YawRad:TKraftScalar read fYawRad write fYawRad;
                     property VisualRotationRad:TKraftScalar read fVisualRotationRad write fVisualRotationRad;
                     property Compression:TKraftScalar read fCompression write fCompression;
                     property CompressionPrev:TKraftScalar read fCompressionPrev write fCompressionPrev;
                     property SuspensionLength:TKraftScalar read fSuspensionLength write fSuspensionLength;
                    public
                     property WorldTransform:TKraftMatrix4x4 read fWorldTransform write fWorldTransform;
                     property VisualWorldTransform:TKraftMatrix4x4 read fVisualWorldTransform write fVisualWorldTransform;
                     property LocalWheelPosition:TKraftVector3 read fLocalWheelPosition write fLocalWheelPosition;
                     property LocalWheelRotation:TKraftVector3 read fLocalWheelRotation write fLocalWheelRotation;
                     property VisualLocalWheelPosition:TKraftVector3 read fVisualLocalWheelPosition write fVisualLocalWheelPosition;
                     property VisualLocalWheelRotation:TKraftVector3 read fVisualLocalWheelRotation write fVisualLocalWheelRotation;
                   end;
             private
              fVehicle:TVehicle;
              fWheelLeft:TWheel;
              fWheelRight:TWheel;
              fWidth:TKraftScalar;
              fOffset:TKraftVector2;
              fSteerAngle:TKraftScalar;
              fRadius:TKraftScalar;
              fLaterialFriction:TKraftScalar;
              fRollingFriction:TKraftScalar;
              fBrakeForceMagnitude:TKraftScalar;
              fSuspensionStiffness:TKraftScalar;
              fSuspensionDamping:TKraftScalar;
              fSuspensionRestitution:TKraftScalar;
              fRelaxedSuspensionLength:TKraftScalar;
              fStabilizerBarAntiRollForce:TKraftScalar;
              fWheelVisualScale:TKraftScalar;
              fIsPowered:boolean;
              fAfterFlightSlipperyK:TKraftScalar;
              fBrakeSlipperyK:TKraftScalar;
              fHandBrakeSlipperyK:TKraftScalar;
{$ifdef DebugDraw}
              fDebugAntiRollForces:array[0..1] of TKraftVector3;
              fDebugWheels:array[0..1] of TKraftVector3;
              fDebugMiddle:TKraftVector3;
              fLastDebugAntiRollForces:array[0..1] of TKraftVector3;
              fLastDebugWheels:array[0..1] of TKraftVector3;
              fLastDebugMiddle:TKraftVector3;
              fVisualDebugAntiRollForces:array[0..1] of TKraftVector3;
              fVisualDebugWheels:array[0..1] of TKraftVector3;
              fVisualDebugMiddle:TKraftVector3;
{$endif}
             public
              constructor Create(const aVehicle:TVehicle); reintroduce;
              destructor Destroy; override;
              procedure ApplyAntiRoll;
              procedure UpdateSuspensionLengths;
              procedure Update(const aTotalWheelsCount,aCountPoweredWheels:TKraftInt32);
              procedure UpdateVisual;
              procedure StoreWorldTransforms;
              procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar);
{$ifdef KraftPasJSON}
              procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
              function SaveToJSON:TPasJSONItem;
{$endif}
{$ifdef DebugDraw}
              procedure DebugDraw;
{$endif}
             published
              property Vehicle:TVehicle read fVehicle write fVehicle;
              property WheelLeft:TWheel read fWheelLeft write fWheelLeft;
              property WheelRight:TWheel read fWheelRight write fWheelRight;
              property Width:TKraftScalar read fWidth write fWidth;
             public
              property Offset:TKraftVector2 read fOffset write fOffset;
             published
              property SteerAngle:TKraftScalar read fSteerAngle write fSteerAngle;
              property Radius:TKraftScalar read fRadius write fRadius;
              property LaterialFriction:TKraftScalar read fLaterialFriction write fLaterialFriction;
              property RollingFriction:TKraftScalar read fRollingFriction write fRollingFriction;
              property BrakeForceMagnitude:TKraftScalar read fBrakeForceMagnitude write fBrakeForceMagnitude;
              property SuspensionStiffness:TKraftScalar read fSuspensionStiffness write fSuspensionStiffness;
              property SuspensionDamping:TKraftScalar read fSuspensionDamping write fSuspensionDamping;
              property SuspensionRestitution:TKraftScalar read fSuspensionRestitution write fSuspensionRestitution;
              property RelaxedSuspensionLength:TKraftScalar read fRelaxedSuspensionLength write fRelaxedSuspensionLength;
              property StabilizerBarAntiRollForce:TKraftScalar read fStabilizerBarAntiRollForce write fStabilizerBarAntiRollForce;
              property WheelVisualScale:TKraftScalar read fWheelVisualScale write fWheelVisualScale;
              property IsPowered:boolean read fIsPowered write fIsPowered;
              property AfterFlightSlipperyK:TKraftScalar read fAfterFlightSlipperyK write fAfterFlightSlipperyK;
              property BrakeSlipperyK:TKraftScalar read fBrakeSlipperyK write fBrakeSlipperyK;
              property HandBrakeSlipperyK:TKraftScalar read fHandBrakeSlipperyK write fHandBrakeSlipperyK;
            end;
      private
       fKraftPhysics:TKraft;
       fAccelerationCurveEnvelope:TEnvelope;
       fReverseAccelerationCurveEnvelope:TEnvelope;
       fReverseEvaluationAccuracy:TKraftInt32;
       fSteerAngleLimitEnvelope:TEnvelope;
       fSteeringResetSpeedEnvelope:TEnvelope;
       fSteeringSpeedEnvelope:TEnvelope;
       fFlightStabilizationForce:TKraftScalar;
       fFlightStabilizationDamping:TKraftScalar;
       fHandBrakeSlipperyTime:TKraftScalar;
       fControllable:boolean;
       fDownForceCurveEnvelope:TEnvelope;
       fDownForce:TKraftScalar;
       fAxleFront:TAxle;
       fAxleRear:TAxle;
       fAfterFlightSlipperyTiresTime:TKraftScalar;
       fBrakeSlipperyTiresTime:TKraftScalar;
       fHandBrakeSlipperyTiresTime:TKraftScalar;
       fUseSphereCast:boolean;
       fIsBrake:boolean;
       fIsHandBrake:boolean;
       fIsAcceleration:boolean;
       fIsReverseAcceleration:boolean;
       fAccelerationForceMagnitude:TKraftScalar;
       fRigidBody:TKraftRigidBody;
       fWorldTransform:TKraftMatrix4x4;
       fWorldLeft:TKraftVector3;
       fWorldRight:TKraftVector3;
       fWorldDown:TKraftVector3;
       fWorldUp:TKraftVector3;
       fWorldBackward:TKraftVector3;
       fWorldForward:TKraftVector3;
       fWorldPosition:TKraftVector3;
       fLastWorldTransform:TKraftMatrix4x4;
       fLastWorldLeft:TKraftVector3;
       fLastWorldRight:TKraftVector3;
       fLastWorldDown:TKraftVector3;
       fLastWorldUp:TKraftVector3;
       fLastWorldBackward:TKraftVector3;
       fLastWorldForward:TKraftVector3;
       fLastWorldPosition:TKraftVector3;
       fVisualWorldTransform:TKraftMatrix4x4;
       fVisualWorldLeft:TKraftVector3;
       fVisualWorldRight:TKraftVector3;
       fVisualWorldDown:TKraftVector3;
       fVisualWorldUp:TKraftVector3;
       fVisualWorldBackward:TKraftVector3;
       fVisualWorldForward:TKraftVector3;
       fVisualWorldPosition:TKraftVector3;
       fInputVertical:TKraftScalar;
       fInputHorizontal:TKraftScalar;
       fInputReset:Boolean;
       fInputBrake:Boolean;
       fInputHandBrake:Boolean;
       fSpeed:TKraftScalar;
       fSpeedKMH:TKraftScalar;
       fDebugDrawLine:TDebugDrawLine;
      public
       constructor Create(const aKraftPhysics:TKraft); reintroduce;
       destructor Destroy; override;
       procedure UpdateWorldTransformVectors;
       procedure Reset;
       function GetHandBrakeK:TKraftScalar;
       function GetSteeringHandBrakeK:TKraftScalar;
       function GetAccelerationForceMagnitude(const aEnvelope:TEnvelope;const aSpeedMetersPerSec,aDeltaTime:TKraftScalar):TKraftScalar;
       function GetSpeed:TKraftScalar;
       function CalcAccelerationForceMagnitude:TKraftScalar;
       function GetSteerAngleLimitInDeg(const aSpeedMetersPerSec:TKraftScalar):TKraftScalar;
       procedure UpdateInput;
       procedure CalculateAckermannSteering;
       procedure UpdateVisual;
       procedure Update;
       procedure StoreWorldTransforms;
       procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar);
{$ifdef KraftPasJSON}
       procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
       function SaveToJSON:TPasJSONItem;
{$endif}
{$ifdef DebugDraw}
       procedure DebugDraw;
{$endif}
      published
       property AccelerationCurveEnvelope:TEnvelope read fAccelerationCurveEnvelope write fAccelerationCurveEnvelope;
       property ReverseAccelerationCurveEnvelope:TEnvelope read fReverseAccelerationCurveEnvelope write fReverseAccelerationCurveEnvelope;
       property ReverseEvaluationAccuracy:TKraftInt32 read fReverseEvaluationAccuracy write fReverseEvaluationAccuracy;
       property SteerAngleLimitEnvelope:TEnvelope read fSteerAngleLimitEnvelope write fSteerAngleLimitEnvelope;
       property SteeringResetSpeedEnvelope:TEnvelope read fSteeringResetSpeedEnvelope write fSteeringResetSpeedEnvelope;
       property SteeringSpeedEnvelope:TEnvelope read fSteeringSpeedEnvelope write fSteeringSpeedEnvelope;
       property FlightStabilizationForce:TKraftScalar read fFlightStabilizationForce write fFlightStabilizationForce;
       property FlightStabilizationDamping:TKraftScalar read fFlightStabilizationDamping write fFlightStabilizationDamping;
       property HandBrakeSlipperyTime:TKraftScalar read fHandBrakeSlipperyTime write fHandBrakeSlipperyTime;
       property Controllable:boolean read fControllable write fControllable;
       property DownForceCurveEnvelope:TEnvelope read fDownForceCurveEnvelope write fDownForceCurveEnvelope;
       property DownForce:TKraftScalar read fDownForce write fDownForce;
       property AxleFront:TAxle read fAxleFront write fAxleFront;
       property AxleRear:TAxle read fAxleRear write fAxleRear;
       property AfterFlightSlipperyTiresTime:TKraftScalar read fAfterFlightSlipperyTiresTime write fAfterFlightSlipperyTiresTime;
       property BrakeSlipperyTiresTime:TKraftScalar read fBrakeSlipperyTiresTime write fBrakeSlipperyTiresTime;
       property HandBrakeSlipperyTiresTime:TKraftScalar read fHandBrakeSlipperyTiresTime write fHandBrakeSlipperyTiresTime;
       property UseSphereCast:boolean read fUseSphereCast write fUseSphereCast;
       property IsBrake:boolean read fIsBrake write fIsBrake;
       property IsHandBrake:boolean read fIsHandBrake write fIsHandBrake;
       property IsAcceleration:boolean read fIsAcceleration write fIsAcceleration;
       property IsReverseAcceleration:boolean read fIsReverseAcceleration write fIsReverseAcceleration;
       property AccelerationForceMagnitude:TKraftScalar read fAccelerationForceMagnitude write fAccelerationForceMagnitude;
       property RigidBody:TKraftRigidBody read fRigidBody write fRigidBody;
      public
       property WorldTransform:TKraftMatrix4x4 read fWorldTransform write fWorldTransform;
       property WorldLeft:TKraftVector3 read fWorldLeft write fWorldLeft;
       property WorldRight:TKraftVector3 read fWorldRight write fWorldRight;
       property WorldDown:TKraftVector3 read fWorldDown write fWorldDown;
       property WorldUp:TKraftVector3 read fWorldUp write fWorldUp;
       property WorldBackward:TKraftVector3 read fWorldBackward write fWorldBackward;
       property WorldForward:TKraftVector3 read fWorldForward write fWorldForward;
       property WorldPosition:TKraftVector3 read fWorldPosition write fWorldPosition;
       property LastWorldTransform:TKraftMatrix4x4 read fLastWorldTransform write fLastWorldTransform;
       property LastWorldLeft:TKraftVector3 read fLastWorldLeft write fLastWorldLeft;
       property LastWorldRight:TKraftVector3 read fLastWorldRight write fLastWorldRight;
       property LastWorldDown:TKraftVector3 read fLastWorldDown write fLastWorldDown;
       property LastWorldUp:TKraftVector3 read fLastWorldUp write fLastWorldUp;
       property LastWorldBackward:TKraftVector3 read fLastWorldBackward write fLastWorldBackward;
       property LastWorldForward:TKraftVector3 read fLastWorldForward write fLastWorldForward;
       property LastWorldPosition:TKraftVector3 read fLastWorldPosition write fLastWorldPosition;
       property VisualWorldTransform:TKraftMatrix4x4 read fVisualWorldTransform write fVisualWorldTransform;
       property VisualWorldLeft:TKraftVector3 read fVisualWorldLeft write fVisualWorldLeft;
       property VisualWorldRight:TKraftVector3 read fVisualWorldRight write fVisualWorldRight;
       property VisualWorldDown:TKraftVector3 read fVisualWorldDown write fVisualWorldDown;
       property VisualWorldUp:TKraftVector3 read fVisualWorldUp write fVisualWorldUp;
       property VisualWorldBackward:TKraftVector3 read fVisualWorldBackward write fVisualWorldBackward;
       property VisualWorldForward:TKraftVector3 read fVisualWorldForward write fVisualWorldForward;
       property VisualWorldPosition:TKraftVector3 read fVisualWorldPosition write fVisualWorldPosition;
      published
       property InputVertical:TKraftScalar read fInputVertical write fInputVertical;
       property InputHorizontal:TKraftScalar read fInputHorizontal write fInputHorizontal;
       property InputReset:Boolean read fInputReset write fInputReset;
       property InputBrake:Boolean read fInputBrake write fInputBrake;
       property InputHandBrake:Boolean read fInputHandBrake write fInputHandBrake;
       property Speed:TKraftScalar read fSpeed write fSpeed;
       property SpeedKMH:TKraftScalar read fSpeedKMH write fSpeedKMH;
       property DebugDrawLine:TDebugDrawLine read fDebugDrawLine write fDebugDrawLine;
     end;

implementation

function Clamp(const aValue,aMin,aMax:TKraftScalar):TKraftScalar; inline;
begin
 if aValue<=aMin then begin
  result:=aMin;
 end else if aValue>=aMax then begin
  result:=aMax;
 end else begin
  result:=aValue;
 end;
end;

function Clamp01(const aValue:TKraftScalar):TKraftScalar; inline;
begin
 if aValue<=0.0 then begin
  result:=0.0;
 end else if aValue>=1.0 then begin
  result:=1.0;
 end else begin
  result:=aValue;
 end;
end;

function Lerp(a,b,x:TKraftScalar):TKraftScalar; inline;
begin
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  result:=(a*(1.0-x))+(b*x);
 end;
end;

{$ifdef DebugDraw}
procedure DrawRay(const aVehicle:TVehicle;const aRayOrigin,aRayDirection:TKraftVector3;const aR,aG,aB:TKraftScalar);
{$ifndef NoOpenGL}
var v:TKraftVector3;
{$endif}
begin
 if Vector3Length(aRayDirection)>0.0 then begin
{$ifdef NoOpenGL}
  if assigned(aVehicle.fDebugDrawLine) then begin
   aVehicle.fDebugDrawLine(aRayOrigin,Vector3Add(aRayOrigin,aRayDirection),Vector4(aR,aG,aB,1.0));
  end;
{$else}
  glColor4f(aR,aG,aB,1.0);
  glBegin(GL_LINES);
  v:=aRayOrigin;
  glVertex3fv(@v);
  v:=Vector3Add(aRayOrigin,aRayDirection);
  glVertex3fv(@v);
  glEnd;
{$endif}
 end;
end;
{$endif}

{ TEnvelope }

constructor TVehicle.TEnvelope.Create;
begin
 inherited Create;
 fMode:=TVehicle.TEnvelope.TMode.Custom;
 fPoints:=nil;
 fCount:=0;
end;

constructor TVehicle.TEnvelope.CreateLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
begin
 Create;
 FillLinear(aTimeStart,aValueStart,aTimeEnd,aValueEnd);
end;

constructor TVehicle.TEnvelope.CreateEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
begin
 Create;
 FillEaseInOut(aTimeStart,aValueStart,aTimeEnd,aValueEnd,aSteps);
end;

destructor TVehicle.TEnvelope.Destroy;
begin
 fPoints:=nil;
 inherited Destroy;
end;

procedure TVehicle.TEnvelope.Clear;
begin
 fMode:=TVehicle.TEnvelope.TMode.Custom;
 fPoints:=nil;
 fCount:=0;
end;

procedure TVehicle.TEnvelope.Assign(const aFrom:TEnvelope);
begin
 fMode:=aFrom.fMode;
 fPoints:=copy(aFrom.fPoints);
 fCount:=aFrom.fCount;
end;

procedure TVehicle.TEnvelope.Insert(const aTime,aValue:TKraftScalar);
var Index,LowIndex,HighIndex,MidIndex:TKraftInt32;
    Point:PPoint;
begin
 if fCount>0 then begin
  if aTime<fPoints[0].fTime then begin
   LowIndex:=0;
  end else if fPoints[fCount-1].fTime<aTime then begin
   LowIndex:=fCount;
  end else begin
   LowIndex:=0;
   HighIndex:=fCount-1;
   while LowIndex<=HighIndex do begin
    MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1);
    Point:=@fPoints[MidIndex];
    case Sign(Point^.fTime-aTime) of
     -1:begin
      LowIndex:=MidIndex+1;
     end;
     1:begin
      HighIndex:=MidIndex-1;
     end;
     else begin
      Point^.fValue:=aValue;
      exit;
     end;
    end;
   end;
  end;
  inc(fCount);
  if length(fPoints)<fCount then begin
   SetLength(fPoints,(fCount*3) shr 1);
  end;
  for Index:=fCount-1 downto LowIndex+1 do begin
   fPoints[Index]:=fPoints[Index-1];
  end;
  Index:=LowIndex;
 end else begin
  fCount:=1;
  SetLength(fPoints,1);
  Index:=0;
 end;
 fMode:=TVehicle.TEnvelope.TMode.Custom;
 Point:=@fPoints[Index];
 Point^.fTime:=aTime;
 Point^.fValue:=aValue;
end;

procedure TVehicle.TEnvelope.FillLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
begin
 Clear;
 Insert(aTimeStart,aValueStart);
 Insert(aTimeEnd,aValueEnd);
 fMode:=TVehicle.TEnvelope.TMode.Linear;
end;

procedure TVehicle.TEnvelope.FillEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
var Index,Last:TKraftInt32;
    x,Time,Value:TKraftScalar;
begin
 Clear;
 Last:=aSteps-1;
 for Index:=0 to Last do begin
  x:=Index/Last;
  Time:=(aTimeStart*(1.0-x))+(aTimeEnd*x);
  if x<0.5 then begin
   x:=(1-sqrt(1-sqr(2*x)))*0.5;
  end else begin
   x:=(sqrt(1-sqr((-2*x)+2))+1)*0.5;
  end;
  Value:=(aValueStart*(1.0-x))+(aValueEnd*x);
  Insert(Time,Value);
 end;
 fMode:=TVehicle.TEnvelope.TMode.EaseInOut;
end;

{$ifdef KraftPasJSON}
procedure TVehicle.TEnvelope.LoadFromJSON(const aJSONItem:TPasJSONItem);
var RootJSONItemObject:TPasJSONItemObject;
    Mode:TPasJSONUTF8String;
    JSONItem:TPasJSONItem;
    JSONItemArray:TPasJSONItemArray;
    JSONItemObject:TPasJSONItemObject;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  RootJSONItemObject:=TPasJSONItemObject(aJSONItem);
  Mode:=TPasJSON.GetString(RootJSONItemObject.Properties['mode'],'');
  if Mode='linear' then begin
   FillLinear(TPasJSON.GetNumber(RootJSONItemObject.Properties['timestart'],0.0),
              TPasJSON.GetNumber(RootJSONItemObject.Properties['valuestart'],0.0),
              TPasJSON.GetNumber(RootJSONItemObject.Properties['timeend'],0.0),
              TPasJSON.GetNumber(RootJSONItemObject.Properties['valueend'],0.0));
  end else if Mode='easeinout' then begin
   FillEaseInOut(TPasJSON.GetNumber(RootJSONItemObject.Properties['timestart'],0.0),
                 TPasJSON.GetNumber(RootJSONItemObject.Properties['valuestart'],0.0),
                 TPasJSON.GetNumber(RootJSONItemObject.Properties['timeend'],0.0),
                 TPasJSON.GetNumber(RootJSONItemObject.Properties['valueend'],0.0),
                 TPasJSON.GetInt64(RootJSONItemObject.Properties['steps'],16));
  end else if Mode='custom' then begin
   Clear;
   JSONItem:=RootJSONItemObject.Properties['points'];
   if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
    JSONItemArray:=TPasJSONItemArray(JSONItem);
    for JSONItem in JSONItemArray do begin
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      JSONItemObject:=TPasJSONItemObject(JSONItem);
      Insert(TPasJSON.GetNumber(JSONItemObject.Properties['time'],0.0),TPasJSON.GetNumber(JSONItemObject.Properties['value'],0.0));
     end;
    end;
   end;
  end;
 end;
end;

function TVehicle.TEnvelope.SaveToJSON:TPasJSONItem;
var Index:TKraftSizeInt;
    JSONItemArray:TPasJSONItemArray;
    JSONItemObject:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 case fMode of
  TVehicle.TEnvelope.TMode.Linear:begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('linear'));
   TPasJSONItemObject(result).Add('timestart',TPasJSONItemNumber.Create(fPoints[0].fTime));
   TPasJSONItemObject(result).Add('valuestart',TPasJSONItemNumber.Create(fPoints[0].fValue));
   TPasJSONItemObject(result).Add('timeend',TPasJSONItemNumber.Create(fPoints[1].fTime));
   TPasJSONItemObject(result).Add('valueend',TPasJSONItemNumber.Create(fPoints[1].fValue));
  end;
  TVehicle.TEnvelope.TMode.EaseInOut:begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('easeinout'));
   TPasJSONItemObject(result).Add('timestart',TPasJSONItemNumber.Create(fPoints[0].fTime));
   TPasJSONItemObject(result).Add('valuestart',TPasJSONItemNumber.Create(fPoints[0].fValue));
   TPasJSONItemObject(result).Add('timeend',TPasJSONItemNumber.Create(fPoints[fCount-1].fTime));
   TPasJSONItemObject(result).Add('valueend',TPasJSONItemNumber.Create(fPoints[fCount-1].fValue));
   TPasJSONItemObject(result).Add('steps',TPasJSONItemNumber.Create(fCount));
  end;
  else {TVehicle.TEnvelope.TMode.Custom:}begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('custom'));
   JSONItemArray:=TPasJSONItemArray.Create;
   try
    for Index:=0 to length(fPoints)-1 do begin
     JSONItemObject:=TPasJSONItemObject.Create;
     try
      JSONItemObject.Add('time',TPasJSONItemNumber.Create(fPoints[Index].fTime));
      JSONItemObject.Add('value',TPasJSONItemNumber.Create(fPoints[Index].fValue));
     finally
      JSONItemArray.Add(JSONItemObject);
     end;
    end;
   finally
    TPasJSONItemObject(result).Add('points',JSONItemArray);
   end;
  end;
 end;
end;
{$endif}

function TVehicle.TEnvelope.GetTimeAtIndex(const aIndex:TKraftInt32):TKraftScalar;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fPoints[aIndex].fTime;
 end else begin
  result:=0.0;
 end;
end;

function TVehicle.TEnvelope.GetValueAtIndex(const aIndex:TKraftInt32):TKraftScalar;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fPoints[aIndex].fValue;
 end else begin
  result:=0.0;
 end;
end;

function TVehicle.TEnvelope.GetIndexFromTime(const aTime:TKraftScalar):TKraftInt32;
var LowIndex,HighIndex,MidIndex:TKraftInt32;
    Point:PPoint;
begin
 if fCount>0 then begin
  if aTime<fPoints[0].fTime then begin
   LowIndex:=0;
  end else if fPoints[fCount-1].fTime<aTime then begin
   LowIndex:=fCount;
  end else begin
   LowIndex:=0;
   HighIndex:=fCount-1;
   while LowIndex<=HighIndex do begin
    MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1);
    Point:=@fPoints[MidIndex];
    case Sign(Point^.fTime-aTime) of
     -1:begin
      LowIndex:=MidIndex+1;
     end;
     1:begin
      HighIndex:=MidIndex-1;
     end;
     else begin
      result:=MidIndex;
      exit;
     end;
    end;
   end;
  end;
  HighIndex:=LowIndex;
  dec(LowIndex);
  if LowIndex<0 then begin
   LowIndex:=0;
  end else if LowIndex>=fCount then begin
   LowIndex:=fCount-1;
  end;
  if HighIndex<0 then begin
   HighIndex:=0;
  end else if HighIndex>=fCount then begin
   HighIndex:=fCount-1;
  end;
  if (LowIndex=HighIndex) or SameValue(fPoints[LowIndex].fTime,fPoints[HighIndex].fTime) then begin
   result:=HighIndex;
  end else begin
   result:=LowIndex;
  end;
 end else begin
  result:=-1;
 end;
end;

function TVehicle.TEnvelope.GetValueAtTime(const aTime:TKraftScalar):TKraftScalar;
var LowIndex,HighIndex,MidIndex:TKraftInt32;
    Point:PPoint;
begin
 if fCount>0 then begin
  if aTime<fPoints[0].fTime then begin
   LowIndex:=0;
  end else if fPoints[fCount-1].fTime<aTime then begin
   LowIndex:=fCount;
  end else begin
   LowIndex:=0;
   HighIndex:=fCount-1;
   while LowIndex<=HighIndex do begin
    MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1);
    Point:=@fPoints[MidIndex];
    case Sign(Point^.fTime-aTime) of
     -1:begin
      LowIndex:=MidIndex+1;
     end;
     1:begin
      HighIndex:=MidIndex-1;
     end;
     else begin
      result:=Point^.fValue;
      exit;
     end;
    end;
   end;
  end;
  HighIndex:=LowIndex;
  dec(LowIndex);
  if LowIndex<0 then begin
   LowIndex:=0;
  end else if LowIndex>=fCount then begin
   LowIndex:=fCount-1;
  end;
  if HighIndex<0 then begin
   HighIndex:=0;
  end else if HighIndex>=fCount then begin
   HighIndex:=fCount-1;
  end;
  if (LowIndex=HighIndex) or SameValue(fPoints[LowIndex].fTime,fPoints[HighIndex].fTime) then begin
   result:=fPoints[HighIndex].fValue;
  end else begin
   result:=Clamp01((aTime-fPoints[LowIndex].fTime)/(fPoints[HighIndex].fTime-fPoints[LowIndex].fTime));
   result:=(fPoints[LowIndex].fValue*(1.0-result))+(fPoints[HighIndex].fValue*result);
  end;
 end else begin
  result:=0;
 end;                                     
end;

{ TVehicle.TAxle.TWheel }

constructor TVehicle.TAxle.TWheel.Create(const aAxle:TAxle;const aOffset:TKraftScalar);
begin
 inherited Create;
 fAxle:=aAxle;
 fVehicle:=fAxle.fVehicle;
 fIsOnGround:=false;
 fBrake:=false;
 fHandBrake:=false;
 fHitValid:=false;
 fLastHitValid:=false;
 fVisualHitValid:=false;
 fHitPoint:=Vector3Origin;
 fHitNormal:=Vector3Origin;
 fHitTime:=0.0;
 fYawRad:=0.0;
 fVisualRotationRad:=0.0;
 fCompression:=0.0;
 fCompressionPrev:=0.0;
 fSuspensionLength:=fAxle.fRelaxedSuspensionLength;
 fOffset:=aOffset;
end;

destructor TVehicle.TAxle.TWheel.Destroy;
begin
 inherited Destroy;
end;

procedure TVehicle.TAxle.TWheel.UpdateSuspensionLength;
begin
 fSuspensionLength:=Clamp01(1.0-fCompression)*fAxle.fRelaxedSuspensionLength;
end;

function TVehicle.TAxle.TWheel.RayCastFilterHook(const aPoint,aNormal:TKraftVector3;const aTime:TKraftScalar;const aShape:TKraftShape):boolean;
begin
 result:=Vector3Dot(aNormal,fRayCastFilterDirection)<=-0.5;
end;

procedure TVehicle.TAxle.TWheel.Update(const aWorldSpacePosition:TKraftVector3;const aTotalWheelsCount,aCountPoweredWheels:TKraftInt32;const aLeft:boolean);
const RelaxSpeed=1.0;
type TRayResult=record
      Valid:boolean;
      Shape:TKraftShape;
      Time:TKraftScalar;
      Point:TKraftVector3;
      Normal:TKraftVector3;
     end;
var LocalWheelRotation,WorldSpaceWheelRotation:TKraftQuaternion;
    WorldSpaceAxleLeft{,WorldSpaceAxleUp},RayOrigin,
    SuspensionForce,WheelVelocity,ContactUp,ContactLeft,ContactForward,LeftVelocity,ForwardVelocity,
    SlideVelocity,SlidingForce,FrictionForce,
    LongitudinalForce,AccForcePoint,
    EngineForce:TKraftVector3;
    TraceLen,SuspensionLengthNow,SuspensionForceMagnitude,SpringForce,
    SuspCompressionVelocity,DamperForce,
    LaterialFriction,SlipperyK,HandBrakeK,
    LongitudinalForceMagnitude,LongitudinalBrakeForceMagnitude:TKraftScalar;
    RayResult:TRayResult;
 function SphereCast(const aRayOrigin,aRayDirection:TKraftVector3;const aMaxTime,aWheelRadius:TKraftScalar):TRayResult;
 begin
  result.Valid:=fVehicle.fKraftPhysics.SphereCast(aRayOrigin,
                                                  aWheelRadius,
                                                  aRayDirection,
                                                  aMaxTime,
                                                  result.Shape,
                                                  result.Time,
                                                  result.Point,
                                                  result.Normal,
                                                  [0],
                                                  RayCastFilterHook
                                                 );
  if result.Valid then begin
   result.Time:=result.Time+aWheelRadius;
   result.Point:=Vector3Add(result.Point,Vector3ScalarMul(aRayDirection,aWheelRadius));
  end;
 end;
 function WheelRayCast(const aRayOrigin,aRayDirection,aRayOtherDirection:TKraftVector3;const aFromAngle,aToAngle:TKraftScalar;const aRelaxedSuspensionLength,aWheelRadius:TKraftScalar):TRayResult;
 const CountRays=32; // +1 primary ray
       DivFactor=1.0/(CountRays-1);
 var Index,Count:TKraftInt32;
     Temporary:TRayResult;
     Time,Angle,Sinus,Cosinus,MaxTime:TKraftScalar;
     PointXSum,PointYSum,PointZSum,NormalXSum,NormalYSum,NormalZSum,TimeSum,WeightSum,Weight:Double;
     WheelPositionAtSuspensionLength,Direction:TKraftVector3;
     Points,Normals:array[0..CountRays] of TKraftVector3;
     Times:array[0..CountRays] of TKraftScalar;
 begin

  MaxTime:=fAxle.fRelaxedSuspensionLength+aWheelRadius;

  WheelPositionAtSuspensionLength:=Vector3Add(aRayOrigin,Vector3ScalarMul(aRayDirection,fSuspensionLength));

  result.Valid:=fVehicle.fKraftPhysics.RayCast(aRayOrigin,
                                               aRayDirection,
                                               MaxTime,
                                               result.Shape,
                                               result.Time,
                                               result.Point,
                                               result.Normal,
                                               [0],
                                               RayCastFilterHook
                                              );
  exit;
  // TODO: FIXME MULTI RAYCAST

  Count:=0;

  if result.Valid then begin
   Points[Count]:=result.Point;
   Normals[Count]:=result.Normal;
   Times[Count]:=result.Time;
   inc(Count);
  end;

  // Other additional rays with last known suspension length
  for Index:=0 to CountRays-1 do begin
   Time:=Index*DivFactor;
   Angle:=(aFromAngle*(1.0-Time))+(aToAngle*Time);
   SinCos(Angle,Sinus,Cosinus);
   Direction:=Vector3Sub(
               Vector3Add(
                WheelPositionAtSuspensionLength,
                Vector3ScalarMul(
                 Vector3Norm(
                  Vector3Add(Vector3ScalarMul(aRayDirection,Cosinus),
                             Vector3ScalarMul(aRayOtherDirection,Sinus)
                            )
                 ),
                 aWheelRadius)
                ),
                WheelPositionAtSuspensionLength
               );
   Temporary.Valid:=fVehicle.fKraftPhysics.RayCast(WheelPositionAtSuspensionLength,
                                                   Vector3Norm(Direction),
                                                   Vector3Length(Direction),
                                                   Temporary.Shape,
                                                   Temporary.Time,
                                                   Temporary.Point,
                                                   Temporary.Normal,
                                                   [0],
                                                   RayCastFilterHook
                                                  );
   if Temporary.Valid then begin
    Points[Count]:=Temporary.Point;
    Normals[Count]:=Temporary.Normal;
    Times[Count]:=Temporary.Time;
    inc(Count);
   end;
  end;

  if Count>0 then begin
   PointXSum:=0.0;
   PointYSum:=0.0;
   PointZSum:=0.0;
   NormalXSum:=0.0;
   NormalYSum:=0.0;
   NormalZSum:=0.0;
   TimeSum:=0.0;
   WeightSum:=0.0;
   for Index:=0 to Count-1 do begin
    Weight:=Times[Index];
    PointXSum:=PointXSum+(Points[Index].x*Weight);
    PointYSum:=PointYSum+(Points[Index].y*Weight);
    PointZSum:=PointZSum+(Points[Index].z*Weight);
    NormalXSum:=NormalXSum+(Normals[Index].x*Weight);
    NormalYSum:=NormalYSum+(Normals[Index].y*Weight);
    NormalZSum:=NormalZSum+(Normals[Index].z*Weight);
    TimeSum:=TimeSum+(Times[Index]*Weight);
    WeightSum:=WeightSum+Weight;
   end;
   if WeightSum>0.0 then begin
    WeightSum:=1.0/WeightSum;
    result.Point:=Vector3(PointXSum*WeightSum,PointYSum*WeightSum,PointZSum*WeightSum);
    result.Normal:=Vector3Norm(Vector3(NormalXSum*WeightSum,NormalYSum*WeightSum,NormalZSum*WeightSum));
    result.Time:=(TimeSum*WeightSum)+fSuspensionLength;
    result.Valid:=true;
   end;
  end;

 end;
begin

 UpdateSuspensionLength;

 LocalWheelRotation:=QuaternionFromAngles(fYawRad,0.0,0.0);
 WorldSpaceWheelRotation:=QuaternionMul(fVehicle.fRigidBody.Sweep.q,LocalWheelRotation);

 // Wheel axle left direction
 WorldSpaceAxleLeft:=Vector3Norm(Vector3TermQuaternionRotate(Vector3(-1.0,0.0,0.0),WorldSpaceWheelRotation));
//WorldSpaceAxleUp:=Vector3Norm(Vector3TermQuaternionRotate(Vector3(0.0,1.0,0.0),WorldSpaceWheelRotation));

 fIsOnGround:=false;

 fHitValid:=false;

 TraceLen:=fAxle.fRelaxedSuspensionLength+fAxle.fRadius;

 fRayCastFilterDirection:=fVehicle.WorldDown;
 fRayCastFilterBidirection:=fVehicle.WorldForward;

 RayOrigin:=aWorldSpacePosition;
 if fVehicle.fUseSphereCast then begin
  RayResult:=SphereCast(RayOrigin,
                        fVehicle.WorldDown,
                        fAxle.fRelaxedSuspensionLength,
                        fAxle.fRadius);
 end else begin
  RayResult:=WheelRayCast(RayOrigin,
                          fVehicle.WorldDown,
                          fVehicle.WorldForward,
                          -PI*0.5,
                          PI*0.5,
                          fAxle.fRelaxedSuspensionLength,
                          fAxle.fRadius);
 end;

 if not RayResult.Valid then begin
  fCompressionPrev:=fCompression;
  fCompression:=Clamp01(fCompression-(fVehicle.fKraftPhysics.WorldDeltaTime*RelaxSpeed));
  exit;
 end;

 fHitValid:=RayResult.Valid;
 fHitTime:=RayResult.Time;
 fHitPoint:=RayResult.Point;
 fHitNormal:=RayResult.Normal;

 SuspensionLengthNow:=fHitTime-fAxle.fRadius;

 if SuspensionLengthNow>TraceLen then begin
  // Sanity check failed
  //exit;
 end;

 fIsOnGround:=true;

 // Suspension force

 // Spring force - want's go to position 0
 // Damping force - want's go to velocity 0

 SuspensionForceMagnitude:=0.0;

 // Positive value means that the spring is compressed
 // Negative value means that the spring is elongated.

 fCompression:=1.0-Clamp01(SuspensionLengthNow/fAxle.fRelaxedSuspensionLength);

 // Hooke's law (springs)
 // F = -k x

 // Spring force (try to reset compression from spring)
 SpringForce:=fCompression*(-fAxle.fSuspensionStiffness);
 SuspensionForceMagnitude:=SuspensionForceMagnitude+SpringForce;

 // Damping force (try to reset velocity to 0)
 SuspCompressionVelocity:=(fCompression-fCompressionPrev)*fVehicle.fKraftPhysics.WorldInverseDeltaTime;
 fCompressionPrev:=fCompression;

 DamperForce:=(-SuspCompressionVelocity)*fAxle.fSuspensionDamping;
 SuspensionForceMagnitude:=SuspensionForceMagnitude+DamperForce;

 // Only consider component of force that is along the contact normal.
 SuspensionForceMagnitude:=SuspensionForceMagnitude*Vector3Dot(HitNormal,fVehicle.WorldUp);

 // Apply suspension force
 SuspensionForce:=Vector3ScalarMul(fVehicle.WorldDown,SuspensionForceMagnitude);
 fVehicle.fRigidBody.AddForceAtPosition(SuspensionForce,HitPoint,kfmForce,false);

{$ifdef DebugDraw}
 fDebugDrawLinePoints[0]:=aWorldSpacePosition;
 fDebugDrawLinePoints[1]:=HitPoint;
{$endif}

 // Friction forces

 WheelVelocity:=fVehicle.fRigidBody.GetWorldLinearVelocityFromPoint(fHitPoint);

 ContactUp:=Vector3Norm(HitNormal);
 ContactLeft:=Vector3Norm(Vector3Sub(WorldSpaceAxleLeft,Vector3Project(WorldSpaceAxleLeft,ContactUp)));
{ContactLeft:=Vector3Norm(Vector3Sub(WorldSpaceAxleLeft,
                          Vector3ScalarMul(ContactUp,
                                           Vector3Dot(WorldSpaceAxleLeft,ContactUp))));}
 ContactForward:=Vector3Norm(Vector3Cross(ContactUp,ContactLeft));
 ContactLeft:=Vector3Norm(Vector3Cross(ContactForward,ContactUp));

{LeftVelocity:=Vector3ScalarMul(ContactLeft,Vector3Dot(WheelVelocity,ContactLeft));
 ForwardVelocity:=Vector3ScalarMul(ContactForward,Vector3Dot(WheelVelocity,ContactForward));}
 LeftVelocity:=Vector3Project(WheelVelocity,ContactLeft);
 ForwardVelocity:=Vector3Project(WheelVelocity,ContactForward);
 SlideVelocity:=Vector3Avg(LeftVelocity,ForwardVelocity);

{if self=fVehicle.fAxleFront.fWheelLeft then begin
  writeln('WV: ',WheelVelocity.x:14:5,' ',WheelVelocity.y:14:5,' ',WheelVelocity.z:14:5,' - ',
          'SV: ',SlideVelocity.x:14:5,' ',SlideVelocity.y:14:5,' ',SlideVelocity.z:14:5,' - ',
          'LV: ',LeftVelocity.x:14:5,' ',LeftVelocity.y:14:5,' ',LeftVelocity.z:14:5,' - ',
          'FV: ',ForwardVelocity.x:14:5,' ',ForwardVelocity.y:14:5,' ',ForwardVelocity.z:14:5,' - ',
          'CL: ',ContactLeft.x:14:5,' ',ContactLeft.y:14:5,' ',ContactLeft.z:14:5,' - ',
          'CU: ',ContactUp.x:14:5,' ',ContactUp.y:14:5,' ',ContactUp.z:14:5,' - ',
          'CF: ',ContactForward.x:14:5,' ',ContactForward.y:14:5,' ',ContactForward.z:14:5,' - ',
          'HF: ',fHitPoint.x:14:5,' ',fHitPoint.y:14:5,' ',fHitPoint.z:14:5,' - ',
          'LV: ',fVehicle.fRigidBody.LinearVelocity.x:14:5,' ',fVehicle.fRigidBody.LinearVelocity.y:14:5,' ',fVehicle.fRigidBody.LinearVelocity.z:14:5,' - ',
          'AV: ',fVehicle.fRigidBody.AngularVelocity.x:14:5,' ',fVehicle.fRigidBody.AngularVelocity.y:14:5,' ',fVehicle.fRigidBody.AngularVelocity.z:14:5,' - ');
 end;//}

{if self=fVehicle.fAxleFRont.fWheelLeft then begin
  writeln(Vector3Dot(WorldSpaceAxleLeft,WheelVelocity):8:4,' ',
          Vector3Dot(WorldSpaceAxleLeft,LeftVelocity):8:4,' ',
          Vector3Dot(WheelVelocity,LeftVelocity):8:4,' - ',
          'FF: ',fDebugFrictionForce.x:8:4,' ',fDebugFrictionForce.y:8:4,' ',fDebugFrictionForce.z:8:4,' - ',
          'AV: ',fVehicle.fRigidBody.AngularVelocity.x:8:4,' ',fVehicle.fRigidBody.AngularVelocity.y:8:4,' ',fVehicle.fRigidBody.AngularVelocity.z:8:4,' - ',
          'HP: ',HitPoint.x:8:4,' ',HitPoint.y:8:4,' ',HitPoint.z:8:4,' - ',
          'WV: ',WheelVelocity.x:8:4,' ',WheelVelocity.y:8:4,' ',WheelVelocity.z:8:4);
 end;}

 // Sliding force
 SlidingForce:=Vector3ScalarMul(SlideVelocity,(fVehicle.fRigidBody.Mass*fVehicle.fKraftPhysics.WorldInverseDeltaTime)/aTotalWheelsCount);

{$ifdef DebugDraw}
 fDebugSlidingVelocity:=SlideVelocity;
{$endif}

 LaterialFriction:=Clamp01(fAxle.fLaterialFriction);

 SlipperyK:=1.0;

 // Simulate slippery tires
 if fVehicle.fAfterFlightSlipperyTiresTime>0.0 then begin
  SlipperyK:=Min(SlipperyK,Lerp(1.0,fAxle.fAfterFlightSlipperyK,Clamp01(fVehicle.fAfterFlightSlipperyTiresTime)));
 end;

 if fVehicle.fBrakeSlipperyTiresTime>0.0 then begin
  SlipperyK:=Min(SlipperyK,Lerp(1.0,fAxle.fBrakeSlipperyK,Clamp01(fVehicle.fBrakeSlipperyTiresTime)));
 end;

 HandBrakeK:=fVehicle.GetHandBrakeK;
 if HandBrakeK>0.0 then begin
  SlipperyK:=Min(SlipperyK,Lerp(1.0,fAxle.fHandBrakeSlipperyK,HandBrakeK));
 end;

 LaterialFriction:=LaterialFriction*SlipperyK;

 // Simulate perfect static friction
 FrictionForce:=Vector3ScalarMul(SlidingForce,-LaterialFriction);

 // Remove friction along roll-direction of wheel
//LongitudinalForce:=Vector3ScalarMul(ContactForward,Vector3Dot(FrictionForce,ContactForward));
 LongitudinalForce:=Vector3Project(FrictionForce,ContactForward);

{if self=fVehicle.fAxleFront.fWheelLeft then begin
  writeln(ContactLeft.x:10:5,' ',ContactLeft.y:10:5,' ',ContactLeft.z:10:5,' - ',ContactForward.x:10:5,' ',ContactForward.y:10:5,' ',ContactForward.z:10:5,' - ',ContactUp.x:10:5,' ',ContactUp.y:10:5,' ',ContactUp.z:10:5,' ');
 end;//}

 // Apply braking force or rolling resistance force or nothing
 if fBrake or fHandBrake then begin
  LongitudinalForceMagnitude:=Vector3Length(LongitudinalForce);
  if not IsZero(LongitudinalForceMagnitude) then begin
   LongitudinalBrakeForceMagnitude:=Clamp(fAxle.fBrakeForceMagnitude*fVehicle.fRigidBody.Mass,
                                           0.0,
                                           LongitudinalForceMagnitude);
   if fHandBrake and not fBrake then begin
    LongitudinalBrakeForceMagnitude:=LongitudinalBrakeForceMagnitude*0.8;
   end;
   Vector3DirectSub(LongitudinalForce,Vector3ScalarMul(Vector3Norm(LongitudinalForce),LongitudinalBrakeForceMagnitude));
// Vector3Scale(LongitudinalForce,1.0-Clamp01(LongitudinalBrakeForceMagnitude/LongitudinalForceMagnitude));
  end;
 end else begin
  if not (fVehicle.fIsAcceleration or fVehicle.fIsReverseAcceleration) then begin
   // Apply rolling-friction (automatic slow-down) only if player don't press to the accelerator
   Vector3Scale(LongitudinalForce,1.0-Clamp01(fAxle.fRollingFriction));
  end;
 end;

 FrictionForce:=Vector3Sub(FrictionForce,LongitudinalForce);

{$ifdef DebugDraw}
 fDebugFrictionForce:=FrictionForce;
 fDebugLongitudinalForce:=LongitudinalForce;
{$endif}

 // Apply resulting force
 fVehicle.fRigidBody.AddForceAtPosition(FrictionForce,fHitPoint,kfmForce,false);

 // Engine force
 if fAxle.fIsPowered and (abs(fVehicle.fAccelerationForceMagnitude)>0.01) and not fVehicle.fIsBrake then begin
  AccForcePoint:=Vector3Add(fHitPoint,Vector3ScalarMul(fVehicle.WorldDown,-0.2));
  EngineForce:=Vector3ScalarMul(ContactForward,(fVehicle.fAccelerationForceMagnitude/aCountPoweredWheels)*fVehicle.fKraftPhysics.WorldInverseDeltaTime);
{$ifdef DebugDraw}
  fDebugAccForcePoint:=AccForcePoint;
  fDebugEngineForce:=EngineForce;
{$endif}
  fVehicle.fRigidBody.AddForceAtPosition(EngineForce,AccForcePoint,kfmForce,true);
 end else begin
{$ifdef DebugDraw}
  fDebugEngineForce:=Vector3Origin;
{$endif}
 end;

end;

procedure TVehicle.TAxle.TWheel.CalculateWheelRotationFromSpeed;
const TwoPI=2.0*PI;
var LocalWheelPosition,WorldspaceWheelPosition,
    WorldSpaceWheelForward,VelocityQueryPos,WheelVelocity:TKraftVector3;
    LocalWheelRotation,WorldSpaceWheelRotation:TKraftQuaternion;
    TireLongSpeed,WheelLengthMeters,RevolutionsPerSecond,DeltaRot,
    SuspensionCurrentLength:TKraftScalar;
begin
 if assigned(fVehicle.fRigidBody) then begin

  SuspensionCurrentLength:=Clamp01(1.0-fCompression)*fAxle.fRelaxedSuspensionLength;

  LocalWheelPosition:=Vector3(fAxle.fWidth*fOffset*0.5,fAxle.fOffset.y-SuspensionCurrentLength,fAxle.fOffset.x);
  LocalWheelRotation:=QuaternionFromAngles(fYawRad,0.0,0.0);

  WorldSpaceWheelPosition:=Vector3TermMatrixMul(LocalWheelPosition,fVehicle.fWorldTransform);
  WorldSpaceWheelRotation:=QuaternionMul(Vehicle.fRigidBody.Sweep.q,LocalWheelRotation);

  WorldSpaceWheelForward:=Vector3TermQuaternionRotate(Vector3(0.0,0.0,1.0),WorldSpaceWheelRotation);

  if fIsOnGround then begin
   VelocityQueryPos:=fHitPoint;
  end else begin
   VelocityQueryPos:=WorldSpaceWheelPosition;
  end;
  WheelVelocity:=fVehicle.fRigidBody.GetWorldLinearVelocityFromPoint(VelocityQueryPos);

  // Longitudinal speed (meters/sec)
  TireLongSpeed:=Vector3Dot(WheelVelocity,WorldSpaceWheelForward);

  // Circle length = 2 * PI * R
  WheelLengthMeters:=TwoPI*fAxle.fRadius;

  // Wheel "Revolutions per second";
  RevolutionsPerSecond:=TireLongSpeed/WheelLengthMeters;

  DeltaRot:=TwoPI*RevolutionsPerSecond*fVehicle.fKraftPhysics.WorldDeltaTime;

  fVisualRotationRad:=fVisualRotationRad+DeltaRot;

 end else begin

  fVisualRotationRad:=0.0;

 end;

end;

procedure TVehicle.TAxle.TWheel.UpdateVisual;
var Scale:TKraftScalar;
    LocalWheelPosition:TKraftVector3;
    LocalWheelRotation:TKraftQuaternion;
    WorldWheelPosition:TKraftVector3;
    WorldWheelRotation:TKraftQuaternion;
begin

 fLocalWheelPosition:=Vector3(0.0,-fSuspensionLength,0.0);
//fLocalWheelPosition:=Vector3(fAxle.fWidth*fOffset*0.5,fAxle.fOffset.y-fSuspensionLength,fAxle.fOffset.x);
 fLocalWheelRotation:=Vector3(fYawRad+IfThen(fOffset<0.0,PI,0.0),0.0,fVisualRotationRad*fOffset);

 LocalWheelPosition:=Vector3(fAxle.fWidth*fOffset*0.5,fAxle.fOffset.y-fSuspensionLength,fAxle.fOffset.x);
 LocalWheelRotation:=QuaternionFromAngles(fYawRad+IfThen(fOffset<0.0,PI,0.0),0.0,fVisualRotationRad*fOffset);

 WorldWheelPosition:=Vector3TermMatrixMul(LocalWheelPosition,fVehicle.fWorldTransform);
 WorldWheelRotation:=QuaternionMul(Vehicle.fRigidBody.Sweep.q,LocalWheelRotation);

 fWorldTransform:=QuaternionToMatrix4x4(WorldWheelRotation);
 Scale:=fAxle.fRadius*fAxle.fWheelVisualScale;
 fWorldTransform[0,0]:=fWorldTransform[0,0]*Scale;
 fWorldTransform[0,1]:=fWorldTransform[0,1]*Scale;
 fWorldTransform[0,2]:=fWorldTransform[0,2]*Scale;
 fWorldTransform[1,0]:=fWorldTransform[1,0]*Scale;
 fWorldTransform[1,1]:=fWorldTransform[1,1]*Scale;
 fWorldTransform[1,2]:=fWorldTransform[1,2]*Scale;
 fWorldTransform[2,0]:=fWorldTransform[2,0]*Scale;
 fWorldTransform[2,1]:=fWorldTransform[2,1]*Scale;
 fWorldTransform[2,2]:=fWorldTransform[2,2]*Scale;
{Vector3Scale(PKraftVector3(@fWorldTransform[0,0])^,fAxle.fRadius*fAxle.fWheelVisualScale);
 Vector3Scale(PKraftVector3(@fWorldTransform[1,0])^,fAxle.fRadius*fAxle.fWheelVisualScale);
 Vector3Scale(PKraftVector3(@fWorldTransform[2,0])^,fAxle.fRadius*fAxle.fWheelVisualScale);}
 PKraftVector3(@fWorldTransform[3,0])^.xyz:=WorldWheelPosition.xyz;


end;

procedure TVehicle.TAxle.TWheel.StoreWorldTransforms;
begin
 fLastWorldTransform:=fWorldTransform;
 fLastLocalWheelPosition:=fLocalWheelPosition;
 fLastLocalWheelRotation:=fLocalWheelRotation;
{$ifdef DebugDraw}
 fLastHitValid:=fHitValid;
 fLastHitPoint:=fHitPoint;
 fLastDebugDrawLinePoints[0]:=fDebugDrawLinePoints[0];
 fLastDebugDrawLinePoints[1]:=fDebugDrawLinePoints[1];
 fLastDebugSlidingVelocity:=fDebugSlidingVelocity;
 fLastDebugFrictionForce:=fDebugFrictionForce;
 fLastDebugLongitudinalForce:=fDebugLongitudinalForce;
 fLastDebugAccForcePoint:=fDebugAccForcePoint;
 fLastDebugEngineForce:=fDebugEngineForce;
{$endif}
end;

procedure TVehicle.TAxle.TWheel.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 fVisualWorldTransform:=Matrix4x4Lerp(fLastWorldTransform,fWorldTransform,aAlpha);
 fVisualLocalWheelPosition:=Vector3Lerp(fLastLocalWheelPosition,fLocalWheelPosition,aAlpha);
 fVisualLocalWheelRotation.x:=AngleLerp(fLastLocalWheelRotation.x,fLocalWheelRotation.x,aAlpha);
 fVisualLocalWheelRotation.y:=AngleLerp(fLastLocalWheelRotation.y,fLocalWheelRotation.y,aAlpha);
 fVisualLocalWheelRotation.z:=AngleLerp(fLastLocalWheelRotation.z,fLocalWheelRotation.z,aAlpha);
{$ifdef DebugDraw}
 if fLastHitValid then begin
  if fHitValid then begin
   fVisualHitValid:=true;
   fVisualHitPoint:=Vector3Lerp(fLastHitPoint,fHitPoint,aAlpha);
   fVisualDebugDrawLinePoints[0]:=Vector3Lerp(fLastDebugDrawLinePoints[0],fDebugDrawLinePoints[0],aAlpha);
   fVisualDebugDrawLinePoints[1]:=Vector3Lerp(fLastDebugDrawLinePoints[1],fDebugDrawLinePoints[1],aAlpha);
   fVisualDebugSlidingVelocity:=Vector3Lerp(fLastDebugSlidingVelocity,fDebugSlidingVelocity,aAlpha);
   fVisualDebugFrictionForce:=Vector3Lerp(fLastDebugFrictionForce,fDebugFrictionForce,aAlpha);
   fVisualDebugLongitudinalForce:=Vector3Lerp(fLastDebugLongitudinalForce,fDebugLongitudinalForce,aAlpha);
   fVisualDebugAccForcePoint:=Vector3Lerp(fLastDebugAccForcePoint,fDebugAccForcePoint,aAlpha);
   fVisualDebugEngineForce:=Vector3Lerp(fLastDebugEngineForce,fDebugEngineForce,aAlpha);
  end else begin
   fVisualHitValid:=true;
   fVisualHitPoint:=fLastHitPoint;
   fVisualDebugDrawLinePoints[0]:=fLastDebugDrawLinePoints[0];
   fVisualDebugDrawLinePoints[1]:=fLastDebugDrawLinePoints[1];
   fVisualDebugSlidingVelocity:=fLastDebugSlidingVelocity;
   fVisualDebugFrictionForce:=fLastDebugFrictionForce;
   fVisualDebugLongitudinalForce:=fLastDebugLongitudinalForce;
   fVisualDebugAccForcePoint:=fLastDebugAccForcePoint;
   fVisualDebugEngineForce:=fLastDebugEngineForce;
  end;
 end else begin
  if fHitValid then begin
   fVisualHitValid:=true;
   fVisualHitPoint:=fHitPoint;
   fVisualDebugDrawLinePoints[0]:=fDebugDrawLinePoints[0];
   fVisualDebugDrawLinePoints[1]:=fDebugDrawLinePoints[1];
   fVisualDebugSlidingVelocity:=fDebugSlidingVelocity;
   fVisualDebugFrictionForce:=fDebugFrictionForce;
   fVisualDebugLongitudinalForce:=fDebugLongitudinalForce;
   fVisualDebugAccForcePoint:=fDebugAccForcePoint;
   fVisualDebugEngineForce:=fDebugEngineForce;
  end else begin
   fVisualHitValid:=false;
  end;
 end;
{$endif}
end;

{$ifdef KraftPasJSON}
procedure TVehicle.TAxle.TWheel.LoadFromJSON(const aJSONItem:TPasJSONItem);
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fOffset:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['offset'],fOffset);
 end;
end;

function TVehicle.TAxle.TWheel.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('offset',TPasJSONItemNumber.Create(fOffset));
end;
{$endif}

{$ifdef DebugDraw}
procedure TVehicle.TAxle.TWheel.DebugDraw;
var Index:TKraftInt32;
    v{$ifdef NoOpenGL},v0,v1,v2{$endif}:TKraftVector3;
begin
 if true then begin

  if fVisualHitValid then begin

{$ifdef NoOpenGL}
   if assigned(fVehicle.fDebugDrawLine) then begin
    fVehicle.fDebugDrawLine(fVisualDebugDrawLinePoints[0],fVisualDebugDrawLinePoints[1],Vector4(1.0,1.0,1.0,1.0));
   end;
{$else}
   glColor4f(1.0,1.0,0.0,1.0);
   glBegin(GL_LINES);
   glVertex3fv(@fVisualDebugDrawLinePoints[0]);
   glVertex3fv(@fVisualDebugDrawLinePoints[1]);
   glEnd;
{$endif}

   DrawRay(fVehicle,fVisualHitPoint,fVisualDebugSlidingVelocity,1.0,0.0,0.0);

   DrawRay(fVehicle,fVisualHitPoint,fVisualDebugFrictionForce,1.0,0.0,0.0);

   DrawRay(fVehicle,fVisualHitPoint,fVisualDebugLongitudinalForce,1.0,1.0,1.0);

   DrawRay(fVehicle,fVisualDebugAccForcePoint,fVisualDebugEngineForce,0.0,1.0,0.0);

  end;

{$ifdef NoOpenGL}
  v:=Vector3TermMatrixMul(Vector3Origin,fVisualWorldTransform);
  v0:=v;
  for Index:=0 to 16 do begin
   if assigned(fVehicle.fDebugDrawLine) then begin
    v1:=v0;
    v0:=Vector3TermMatrixMul(Vector3Add(Vector3Add(Vector3Origin,Vector3ScalarMul(Vector3YAxis,Sin((Index/16)*PI*2))),Vector3ScalarMul(Vector3ZAxis,Cos((Index/16)*PI*2))),fVisualWorldTransform);
    if Index>0 then begin
     fVehicle.fDebugDrawLine(v,v0,Vector4(1.0,1.0,1.0,1.0));
     fVehicle.fDebugDrawLine(v0,v1,Vector4(1.0,1.0,1.0,1.0));
    end;
   end;
  end;
{$else}
  glColor4f(1.0,1.0,1.0,1.0);
  glDisable(GL_CULL_FACE);
  glBegin(GL_TRIANGLE_FAN);
  v:=Vector3TermMatrixMul(Vector3Origin,fVisualWorldTransform);
  glVertex3fv(@v);
  for Index:=0 to 16 do begin
   v:=Vector3TermMatrixMul(Vector3Add(Vector3Add(Vector3Origin,Vector3ScalarMul(Vector3YAxis,Sin((Index/16)*PI*2))),Vector3ScalarMul(Vector3ZAxis,Cos((Index/16)*PI*2))),fVisualWorldTransform);
   glVertex3fv(@v);
  end;
  glEnd;
  glEnable(GL_CULL_FACE);
{$endif}

 end;
end;
{$endif}

{ TVehicle.TAxle }

constructor TVehicle.TAxle.Create(const aVehicle:TVehicle);
begin
 inherited Create;
 fVehicle:=aVehicle;
 fWidth:=0.4;
 fOffset:=Vector2Origin;
 fSteerAngle:=0.0;
 fRadius:=0.3;
 fLaterialFriction:=0.1;
 fRollingFriction:=0.01;
 fBrakeForceMagnitude:=4.0;
 fSuspensionStiffness:=8500.0;
 fSuspensionDamping:=3000.0;
 fSuspensionRestitution:=1.0;
 fRelaxedSuspensionLength:=0.55;
 fStabilizerBarAntiRollForce:=10000.0;
 fWheelVisualScale:=0.03270531;
 fIsPowered:=false;
 fAfterFlightSlipperyK:=0.02;
 fBrakeSlipperyK:=0.5;
 fHandBrakeSlipperyK:=0.01;
 fWheelLeft:=TWheel.Create(self,-1.0);
 fWheelRight:=TWheel.Create(self,1.0);
end;

destructor TVehicle.TAxle.Destroy;
begin
 FreeAndNil(fWheelLeft);
 FreeAndNil(fWheelRight);
 inherited Destroy;
end;

procedure TVehicle.TAxle.ApplyAntiRoll;
var TravelL,TravelR,AntiRollForce:TKraftScalar;
begin
 TravelL:=1.0-Clamp01(fWheelLeft.fCompression);
 TravelR:=1.0-Clamp01(fWheelRight.fCompression);
 AntiRollForce:=(TravelL-TravelR)*fStabilizerBarAntiRollForce;
 if fWheelLeft.IsOnGround then begin
  fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,AntiRollForce),fWheelLeft.fHitPoint,kfmForce,false);
{$ifdef DebugDraw}
  fDebugAntiRollForces[0]:=Vector3ScalarMul(fVehicle.fWorldDown,AntiRollForce);
{$endif}
 end else begin
{$ifdef DebugDraw}
  fDebugAntiRollForces[0]:=Vector3Origin;
{$endif}
 end;
 if fWheelRight.IsOnGround then begin
  fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,-AntiRollForce),fWheelRight.fHitPoint,kfmForce,false);
{$ifdef DebugDraw}
  fDebugAntiRollForces[1]:=Vector3ScalarMul(fVehicle.fWorldDown,-AntiRollForce);
{$endif}
 end else begin
{$ifdef DebugDraw}
  fDebugAntiRollForces[1]:=Vector3Origin;
{$endif}
 end;
end;

procedure TVehicle.TAxle.UpdateSuspensionLengths;
begin
 fWheelLeft.UpdateSuspensionLength;
 fWheelRight.UpdateSuspensionLength;
end;

procedure TVehicle.TAxle.Update(const aTotalWheelsCount,aCountPoweredWheels:TKraftInt32);
begin
 fWheelLeft.Update(Vector3TermMatrixMul(Vector3(fWidth*-0.5,fOffset.y,fOffset.x),fVehicle.fWorldTransform),aTotalWheelsCount,aCountPoweredWheels,true);
 fWheelRight.Update(Vector3TermMatrixMul(Vector3(fWidth*0.5,fOffset.y,fOffset.x),fVehicle.fWorldTransform),aTotalWheelsCount,aCountPoweredWheels,false);
 ApplyAntiRoll;
end;

procedure TVehicle.TAxle.UpdateVisual;
begin
 fWheelLeft.UpdateVisual;
 fWheelRight.UpdateVisual;
{$ifdef DebugDraw}
 fDebugWheels[0]:=Vector3TermMatrixMul(Vector3(fWidth*-0.5,fOffset.y,fOffset.x),fVehicle.fWorldTransform);
 fDebugWheels[1]:=Vector3TermMatrixMul(Vector3(fWidth*0.5,fOffset.y,fOffset.x),fVehicle.fWorldTransform);
 fDebugMiddle:=Vector3Avg(fDebugWheels[0],fDebugWheels[1]);
{$endif}
end;

procedure TVehicle.TAxle.StoreWorldTransforms;
begin
 fWheelLeft.StoreWorldTransforms;
 fWheelRight.StoreWorldTransforms;
{$ifdef DebugDraw}
 fLastDebugAntiRollForces[0]:=fDebugAntiRollForces[0];
 fLastDebugAntiRollForces[1]:=fDebugAntiRollForces[1];
 fLastDebugWheels[0]:=fDebugWheels[0];
 fLastDebugWheels[1]:=fDebugWheels[1];
 fLastDebugMiddle:=Vector3Avg(fLastDebugWheels[0],fLastDebugWheels[1]);
{$endif}
end;

procedure TVehicle.TAxle.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 fWheelLeft.InterpolateWorldTransforms(aAlpha);
 fWheelRight.InterpolateWorldTransforms(aAlpha);
{$ifdef DebugDraw}
 fVisualDebugAntiRollForces[0]:=Vector3Lerp(fLastDebugAntiRollForces[0],fDebugAntiRollForces[0],aAlpha);
 fVisualDebugAntiRollForces[1]:=Vector3Lerp(fLastDebugAntiRollForces[1],fDebugAntiRollForces[1],aAlpha);
 fVisualDebugWheels[0]:=Vector3Lerp(fLastDebugWheels[0],fDebugWheels[0],aAlpha);
 fVisualDebugWheels[1]:=Vector3Lerp(fLastDebugWheels[1],fDebugWheels[1],aAlpha);
 fVisualDebugMiddle:=Vector3Avg(fVisualDebugWheels[0],fVisualDebugWheels[1]);
{$endif}
end;

{$ifdef KraftPasJSON}
procedure TVehicle.TAxle.LoadFromJSON(const aJSONItem:TPasJSONItem);
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fWidth:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['width'],fWidth);
  fOffset.x:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['horizontaloffset'],fOffset.x);
  fOffset.y:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['verticaloffset'],fOffset.y);
  fRadius:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['radius'],fRadius);
  fLaterialFriction:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['laterialfriction'],fLaterialFriction);
  fRollingFriction:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rollingfriction'],fRollingFriction);
  fBrakeForceMagnitude:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['brakeforcemagnitude'],fBrakeForceMagnitude);
  fSuspensionStiffness:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensionstiffness'],fSuspensionStiffness);
  fSuspensionDamping:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensiondamping'],fSuspensionDamping);
  fSuspensionRestitution:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensionrestitution'],fSuspensionRestitution);
  fRelaxedSuspensionLength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['relaxedsuspensionlength'],fRelaxedSuspensionLength);
  fStabilizerBarAntiRollForce:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['stabilizerbarantirollforce'],fStabilizerBarAntiRollForce);
  fWheelVisualScale:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['wheelvisualscale'],fWheelVisualScale);
  fIsPowered:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['ispowered'],fIsPowered);
  fAfterFlightSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['afterflightslipperyk'],fAfterFlightSlipperyK);
  fBrakeSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['brakeslipperyk'],fBrakeSlipperyK);
  fHandBrakeSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['handbrakeslipperyk'],fHandBrakeSlipperyK);
 end;
end;

function TVehicle.TAxle.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('width',TPasJSONItemNumber.Create(fWidth));
 TPasJSONItemObject(result).Add('horizontaloffset',TPasJSONItemNumber.Create(fOffset.x));
 TPasJSONItemObject(result).Add('verticaloffset',TPasJSONItemNumber.Create(fOffset.y));
 TPasJSONItemObject(result).Add('radius',TPasJSONItemNumber.Create(fRadius));
 TPasJSONItemObject(result).Add('laterialfriction',TPasJSONItemNumber.Create(fLaterialFriction));
 TPasJSONItemObject(result).Add('rollingfriction',TPasJSONItemNumber.Create(fRollingFriction));
 TPasJSONItemObject(result).Add('brakeforcemagnitude',TPasJSONItemNumber.Create(fBrakeForceMagnitude));
 TPasJSONItemObject(result).Add('suspensionstiffness',TPasJSONItemNumber.Create(fSuspensionStiffness));
 TPasJSONItemObject(result).Add('suspensiondamping',TPasJSONItemNumber.Create(fSuspensionDamping));
 TPasJSONItemObject(result).Add('suspensionrestitution',TPasJSONItemNumber.Create(fSuspensionRestitution));
 TPasJSONItemObject(result).Add('relaxedsuspensionlength',TPasJSONItemNumber.Create(fRelaxedSuspensionLength));
 TPasJSONItemObject(result).Add('stabilizerbarantirollforce',TPasJSONItemNumber.Create(fStabilizerBarAntiRollForce));
 TPasJSONItemObject(result).Add('wheelvisualscale',TPasJSONItemNumber.Create(fWheelVisualScale));
 TPasJSONItemObject(result).Add('ispowered',TPasJSONItemBoolean.Create(fIsPowered));
 TPasJSONItemObject(result).Add('afterflightslipperyk',TPasJSONItemNumber.Create(fAfterFlightSlipperyK));
 TPasJSONItemObject(result).Add('brakeslipperyk',TPasJSONItemNumber.Create(fBrakeSlipperyK));
 TPasJSONItemObject(result).Add('handbrakeslipperyk',TPasJSONItemNumber.Create(fHandBrakeSlipperyK));
end;
{$endif}

{$ifdef DebugDraw}
procedure TVehicle.TAxle.DebugDraw;
begin
 fWheelLeft.DebugDraw;
 fWheelRight.DebugDraw;
 if fWheelLeft.fHitValid then begin
  DrawRay(fVehicle,fWheelLeft.fVisualHitPoint,fVisualDebugAntiRollForces[0],1.0,0.0,1.0);
 end;
 if fWheelRight.fHitValid then begin
  DrawRay(fVehicle,fWheelRight.fVisualHitPoint,fVisualDebugAntiRollForces[1],1.0,0.0,1.0);
 end;
{$ifdef NoOpenGL}
 if assigned(fVehicle.fDebugDrawLine) then begin
  fVehicle.fDebugDrawLine(fVisualDebugWheels[0],fVisualDebugWheels[1],Vector4(0.0,0.0,1.0,1.0));
 end;
{$else}
 glColor4f(0.0,0.0,1.0,1.0);
 glBegin(GL_LINES);
 glVertex3fv(@fVisualDebugWheels[0]);
 glVertex3fv(@fVisualDebugWheels[1]);
 glEnd;
 glColor4f(1.0,1.0,1.0,1.0);
{$endif}
end;
{$endif}

{ TVehicle }

constructor TVehicle.Create(const aKraftPhysics:TKraft);
begin
 inherited Create;
 fKraftPhysics:=aKraftPhysics;
 fAccelerationCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,100.0);
 fReverseAccelerationCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,20.0);
 fReverseEvaluationAccuracy:=25;
 fSteerAngleLimitEnvelope:=TEnvelope.CreateLinear(0.0,35.0,100.0,5.0);
 fSteeringResetSpeedEnvelope:=TEnvelope.CreateEaseInOut(0.0,30.0,100.0,10.0,64);
 fSteeringSpeedEnvelope:=TEnvelope.CreateLinear(0.0,2.0,100.0,0.5);
 fFlightStabilizationForce:=8.0;
 fFlightStabilizationDamping:=0.0;
 fHandBrakeSlipperyTime:=2.2;
 fControllable:=true;
 fDownForceCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,200.0,100.0);
 fDownForce:=5.0;
 fAxleFront:=TAxle.Create(self);
 fAxleRear:=TAxle.Create(self);
 fAfterFlightSlipperyTiresTime:=0.0;
 fBrakeSlipperyTiresTime:=0.0;
 fHandBrakeSlipperyTiresTime:=0.0;
 fUseSphereCast:=true;
 fIsBrake:=false;
 fIsHandBrake:=false;
 fIsAcceleration:=false;
 fIsReverseAcceleration:=false;
 fAccelerationForceMagnitude:=0.0;
 fRigidBody:=nil;
 fInputVertical:=0.0;
 fInputHorizontal:=0.0;
 fInputReset:=false;
 fInputBrake:=false;
 fInputHandBrake:=false;
 fDebugDrawLine:=nil;
end;

destructor TVehicle.Destroy;
begin
 FreeAndNil(fAccelerationCurveEnvelope);
 FreeAndNil(fReverseAccelerationCurveEnvelope);
 FreeAndNil(fSteerAngleLimitEnvelope);
 FreeAndNil(fSteeringResetSpeedEnvelope);
 FreeAndNil(fSteeringSpeedEnvelope);
 FreeAndNil(fDownForceCurveEnvelope);
 FreeAndNil(fAxleFront);
 FreeAndNil(fAxleRear);
 inherited Destroy;
end;

procedure TVehicle.Reset;
begin
 fRigidBody.LinearVelocity:=Vector3Origin;
 fRigidBody.AngularVelocity:=Vector3Origin;
 AxleFront.SteerAngle:=0.0;
 AxleRear.SteerAngle:=0.0;
 fInputVertical:=0.0;
 fInputHorizontal:=0.0;
 fInputReset:=false;
 fInputBrake:=false;
 fInputHandBrake:=false;
end;

procedure TVehicle.UpdateWorldTransformVectors;
begin
 fWorldTransform:=fRigidBody.WorldTransform;
 fWorldRight:=Vector3(PKraftRawVector3(pointer(@fWorldTransform[0,0]))^);
 fWorldLeft:=Vector3Neg(fWorldRight);
 fWorldUp:=Vector3(PKraftRawVector3(pointer(@fWorldTransform[1,0]))^);
 fWorldDown:=Vector3Neg(fWorldUp);
 fWorldForward:=Vector3(PKraftRawVector3(pointer(@fWorldTransform[2,0]))^);
 fWorldBackward:=Vector3Neg(fWorldForward);
 fWorldPosition:=Vector3(PKraftRawVector3(pointer(@fWorldTransform[3,0]))^);
end;

function TVehicle.GetHandBrakeK:TKraftScalar;
begin
 result:=fHandBrakeSlipperyTiresTime/Max(0.1,fHandBrakeSlipperyTime);
 result:=result*result*result*(result*((result*6.0)-15.0)+10.0);
end;

function TVehicle.GetSteeringHandBrakeK:TKraftScalar;
begin
 result:=0.4+(1.0-GetHandBrakeK)*0.6;
end;

function TVehicle.GetAccelerationForceMagnitude(const aEnvelope:TEnvelope;const aSpeedMetersPerSec,aDeltaTime:TKraftScalar):TKraftScalar;
const Inv3d6=1/3.6;
var Index,Count:TKraftInt32;
    SpeedKMH,Mass,MinTime,MaxTime,TimeNow,CurrentSpeed,CurrentSpeedDifference,
    Step,StepTime,StepSpeed,StepSpeedDifference:TKraftScalar;
begin

 SpeedKMH:=aSpeedMetersPerSec*3.6;

 Mass:=fRigidBody.Mass;

 Count:=aEnvelope.Count;

 case Count of
  0:begin
   result:=0.0;
  end;
  1:begin
   result:=Max(0.0,((aEnvelope.fPoints[0].fValue-SpeedKMH)*Inv3d6)*Mass);
  end;
  else begin

   MinTime:=aEnvelope.fPoints[0].fTime;
   MaxTime:=aEnvelope.fPoints[Count-1].fTime;

   Step:=MaxTime-MinTime;

   TimeNow:=MinTime;

   if SpeedKMH<aEnvelope.fPoints[Count-1].fValue then begin

    for Index:=0 to fReverseEvaluationAccuracy-1 do begin

     CurrentSpeed:=aEnvelope.GetValueAtTime(TimeNow);
     CurrentSpeedDifference:=abs(SpeedKMH-CurrentSpeed);

     StepTime:=TimeNow+Step;
     StepSpeed:=aEnvelope.GetValueAtTime(StepTime);
     StepSpeedDifference:=abs(SpeedKMH-StepSpeed);

     if StepSpeedDifference<CurrentSpeedDifference then begin
      TimeNow:=StepTime;
      CurrentSpeed:=StepSpeed;
     end;

     Step:=abs(Step*0.5)*Sign(SpeedKMH-CurrentSpeed);

    end;

    result:=aEnvelope.GetValueAtTime(TimeNow+aDeltaTime);

   end else begin

    result:=aEnvelope.fPoints[Count-1].fValue;

   end;

   result:=Max(0.0,(result-SpeedKMH)*Inv3d6*Mass);

  end;

 end;

end;

function TVehicle.GetSpeed:TKraftScalar;
var LinearVelocity,WorldSpaceForward,ProjectedVector:TKraftVector3;
    Factor:TKraftScalar;
begin
 LinearVelocity:=fRigidBody.LinearVelocity;
 WorldSpaceForward:=Vector3(PKraftRawVector3(@fRigidBody.WorldTransform[2,0])^);
 Factor:=Vector3Dot(WorldSpaceForward,LinearVelocity);
 ProjectedVector:=Vector3ScalarMul(WorldSpaceForward,Factor);
 result:=Vector3Length(ProjectedVector)*Sign(Factor);
end;

function TVehicle.CalcAccelerationForceMagnitude:TKraftScalar;
var DeltaTime:TKraftScalar;
begin
 if fIsAcceleration or fIsReverseAcceleration then begin
  DeltaTime:=fKraftPhysics.WorldDeltaTime;
  if IsAcceleration then begin
   result:=GetAccelerationForceMagnitude(fAccelerationCurveEnvelope,fSpeed,DeltaTime);
  end else begin
   result:=-GetAccelerationForceMagnitude(fReverseAccelerationCurveEnvelope,-fSpeed,DeltaTime);
  end;
 end else begin
  result:=0.0;
 end;
end;

function TVehicle.GetSteerAngleLimitInDeg(const aSpeedMetersPerSec:TKraftScalar):TKraftScalar;
begin
 result:=fSteerAngleLimitEnvelope.GetValueAtTime(aSpeedMetersPerSec*3.6*GetSteeringHandBrakeK);
end;

procedure TVehicle.UpdateInput;
var Vertical,Horizontal,NewSteerAngle,AngleReturnSpeedDegressPerSecond:TKraftScalar;
    IsBrakeNow,IsHandBrakeNow:boolean;
begin

 if fControllable then begin
  Vertical:=fInputVertical;
  Horizontal:=fInputHorizontal;
  if fInputReset then begin
   Reset;
  end;
 end else begin
  Vertical:=0.0;
  Horizontal:=0.0;
 end;

 IsBrakeNow:=false;
 IsHandBrakeNow:=fControllable and fInputHandBrake;

 fIsAcceleration:=false;
 fIsReverseAcceleration:=false;

 if fInputBrake and fControllable then begin
  IsBrakeNow:=true;
 end else if Vertical>0.4 then begin
  if fSpeed<-0.5 then begin
   IsBrakeNow:=true;
  end else begin
   fIsAcceleration:=true;
  end;
 end else if Vertical<-0.4 then begin
  if fSpeed>0.5 then begin
   IsBrakeNow:=true;
  end else begin
   fIsReverseAcceleration:=true;
  end;
 end;

 if IsBrakeNow and not fIsBrake then begin
  fBrakeSlipperyTiresTime:=1.0;
 end;

 if IsHandBrakeNow then begin
  fHandBrakeSlipperyTiresTime:=Max(0.1,fHandBrakeSlipperyTime);
 end;

 fIsBrake:=IsBrakeNow;

 fIsHandBrake:=IsHandBrakeNow and not (fIsAcceleration or fIsReverseAcceleration);

 fAxleFront.WheelLeft.fBrake:=fIsBrake;
 fAxleFront.WheelRight.fBrake:=fIsBrake;
 fAxleRear.WheelLeft.fBrake:=fIsBrake;
 fAxleRear.WheelRight.fBrake:=fIsBrake;

 fAxleFront.WheelLeft.fHandBrake:=fIsHandBrake;
 fAxleFront.WheelRight.fHandBrake:=fIsHandBrake;
 fAxleRear.WheelLeft.fHandBrake:=fIsHandBrake;
 fAxleRear.WheelRight.fHandBrake:=fIsHandBrake;

 if abs(Horizontal)>0.001 then begin
  NewSteerAngle:=fAxleFront.fSteerAngle+(Horizontal*fSteeringSpeedEnvelope.GetValueAtTime(fSpeedKMH*GetSteeringHandBrakeK));
  fAxleFront.fSteerAngle:=Min(abs(NewSteerAngle),GetSteerAngleLimitInDeg(Speed))*Sign(NewSteerAngle);
 end else begin
  AngleReturnSpeedDegressPerSecond:=fSteeringResetSpeedEnvelope.GetValueAtTime(fSpeedKMH)*Clamp01(fSpeedKMH*0.5);
  fAxleFront.SteerAngle:=Max(abs(fAxleFront.fSteerAngle)-(AngleReturnSpeedDegressPerSecond*fKraftPhysics.WorldDeltaTime),0.0)*Sign(fAxleFront.fSteerAngle);
 end;

end;

procedure TVehicle.CalculateAckermannSteering;
var SteerAngleRad,AxleSeparation,WheelSeparation,TurningCircleRadius:TKraftScalar;
    AxleDiff,WheelDiff:TKraftVector3;
begin

 SteerAngleRad:=fAxleFront.fSteerAngle*DEG2RAD;
 fAxleFront.WheelLeft.fYawRad:=SteerAngleRad;
 fAxleFront.WheelRight.fYawRad:=SteerAngleRad;

 SteerAngleRad:=fAxleRear.fSteerAngle*DEG2RAD;
 fAxleRear.WheelLeft.fYawRad:=SteerAngleRad;
 fAxleRear.WheelRight.fYawRad:=SteerAngleRad;

 if abs(fAxleRear.fSteerAngle)>0.0001 then begin
  exit;
 end;

 AxleDiff:=Vector3Sub(Vector3TermMatrixMul(Vector3(0.0,fAxleFront.fOffset.y,fAxleFront.fOffset.x),fRigidBody.WorldTransform),
                      Vector3TermMatrixMul(Vector3(0.0,fAxleRear.fOffset.y,fAxleRear.fOffset.x),fRigidBody.WorldTransform));
 AxleSeparation:=Vector3Length(AxleDiff);

 WheelDiff:=Vector3Sub(Vector3TermMatrixMul(Vector3(fAxleFront.fWidth*-0.5,fAxleFront.fOffset.y,fAxleFront.fOffset.x),fRigidBody.WorldTransform),
                       Vector3TermMatrixMul(Vector3(fAxleFront.fWidth*0.5,fAxleFront.fOffset.y,fAxleFront.fOffset.x),fRigidBody.WorldTransform));
 WheelSeparation:=Vector3Length(WheelDiff);

 TurningCircleRadius:=AxleSeparation/Tan(fAxleFront.fSteerAngle*DEG2RAD);
 if IsNaN(TurningCircleRadius) then begin
  TurningCircleRadius:=0.0;
 end;

 AxleFront.WheelLeft.fYawRad:=ArcTan(AxleSeparation/(TurningCircleRadius+(WheelSeparation*0.5)));
 AxleFront.WheelRight.fYawRad:=ArcTan(AxleSeparation/(TurningCircleRadius-(WheelSeparation*0.5)));

 if fIsAcceleration or fIsReverseAcceleration then begin
  fRigidBody.SetToAwake;
 end;

end;

procedure TVehicle.UpdateVisual;
begin
 fAxleFront.UpdateVisual;
 fAxleRear.UpdateVisual;
end;

procedure TVehicle.Update;
const TotalWheelsCount=2 shl 1;
var CountPoweredWheels:TKraftInt32;
    Axis,AngularVelocity,AngularVelocityDamping,VehicleUp,AntiGravityUp:TKraftVector3;
    DownForceAmount:TKraftScalar;
begin

 UpdateWorldTransformVectors;

 fSpeed:=GetSpeed;
 fSpeedKMH:=abs(fSpeed)*3.6;

 UpdateInput;

 fAccelerationForceMagnitude:=CalcAccelerationForceMagnitude*Clamp01(0.8+((1.0-GetHandBrakeK)*0.2));

 CalculateAckermannSteering;

 CountPoweredWheels:=((ord(fAxleFront.IsPowered) and 1)+(ord(fAxleRear.IsPowered) and 1)) shl 1;

 fAxleFront.Update(TotalWheelsCount,CountPoweredWheels);
 fAxleRear.Update(TotalWheelsCount,CountPoweredWheels);

 if (fAxleFront.fWheelLeft.IsOnGround or fAxleFront.fWheelRight.IsOnGround) or
    (fAxleRear.fWheelLeft.IsOnGround or fAxleRear.fWheelRight.IsOnGround) then begin

  // Not all wheels in air

  DownForceAmount:=fDownForceCurveEnvelope.GetValueAtTime(fSpeedKMH)*0.01;
//  fRigidBody.AddWorldForce(Vector3ScalarMul(fWorldDown,fRigidBody.Mass*DownForceAmount*fDownForce));

 end else begin

  // All wheels in air

  fAfterFlightSlipperyTiresTime:=1.0;

  // Length of axis depends on the angle - i.e. the further awat
  // the vehicle is from being upright, the larger the applied impulse
  // will be, resulting in fast changes when the vehicle is on its
  // side, but not overcompensating (and therefore shaking) when
  // the vehicle is not much away from being upright.
  VehicleUp:=fWorldUp;
  AntiGravityUp:=Vector3Neg(fKraftPhysics.Gravity.Vector);
  Axis:=Vector3Norm(Vector3Cross(VehicleUp,AntiGravityUp));

  // To avoid the vehicle goinh backwards/forwards (or rolling sideways),
  // set the pitch/roll to 0 before applying the 'straightening' impulse.
  if fFlightStabilizationDamping>0.0 then begin
   fRigidBody.AngularVelocity:=Vector3Lerp(fRigidBody.AngularVelocity,
                                           Vector3(0.0,fRigidBody.AngularVelocity.y,0.0),
                                           Clamp01(fFlightStabilizationDamping*fKraftPhysics.WorldDeltaTime));
  end;
 
  // Give a nicely balanced feeling for rebalancing the vehicle
  fRigidBody.AddWorldTorque(Vector3ScalarMul(Axis,fFlightStabilizationForce*fRigidBody.Mass));

 end;

 fAfterFlightSlipperyTiresTime:=Max(0.0,fAfterFlightSlipperyTiresTime-fKraftPhysics.WorldDeltaTime);

 fBrakeSlipperyTiresTime:=Max(0.0,fBrakeSlipperyTiresTime-fKraftPhysics.WorldDeltaTime);

 fHandBrakeSlipperyTiresTime:=Max(0.0,fHandBrakeSlipperyTiresTime-fKraftPhysics.WorldDeltaTime);

 fAxleFront.fWheelLeft.CalculateWheelRotationFromSpeed;
 fAxleFront.fWheelRight.CalculateWheelRotationFromSpeed;
 fAxleRear.fWheelLeft.CalculateWheelRotationFromSpeed;
 fAxleRear.fWheelRight.CalculateWheelRotationFromSpeed;

 fAxleFront.UpdateSuspensionLengths;
 fAxleRear.UpdateSuspensionLengths;

 UpdateVisual;

end;

procedure TVehicle.StoreWorldTransforms;
begin
 UpdateWorldTransformVectors;
 UpdateVisual;
 fAxleFront.StoreWorldTransforms;
 fAxleRear.StoreWorldTransforms;
 fLastWorldTransform:=fWorldTransform;
 fLastWorldRight:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[0,0]))^);
 fLastWorldLeft:=Vector3Neg(fLastWorldRight);
 fLastWorldUp:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[1,0]))^);
 fLastWorldDown:=Vector3Neg(fLastWorldUp);
 fLastWorldForward:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[2,0]))^);
 fLastWorldBackward:=Vector3Neg(fLastWorldForward);
 fLastWorldPosition:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[3,0]))^);
end;

procedure TVehicle.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 UpdateWorldTransformVectors;
 UpdateVisual;
 fAxleFront.InterpolateWorldTransforms(aAlpha);
 fAxleRear.InterpolateWorldTransforms(aAlpha);
 fVisualWorldTransform:=Matrix4x4Lerp(fLastWorldTransform,fWorldTransform,aAlpha);
 fVisualWorldRight:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[0,0]))^);
 fVisualWorldLeft:=Vector3Neg(fVisualWorldRight);
 fVisualWorldUp:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[1,0]))^);
 fVisualWorldDown:=Vector3Neg(fVisualWorldUp);
 fVisualWorldForward:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[2,0]))^);
 fVisualWorldBackward:=Vector3Neg(fVisualWorldForward);
 fVisualWorldPosition:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[3,0]))^);
end;

{$ifdef KraftPasJSON}
procedure TVehicle.LoadFromJSON(const aJSONItem:TPasJSONItem);
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fAccelerationCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['accelerationcurveenvelope']);
  fReverseAccelerationCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['reverseaccelerationcurveenvelope']);
  fReverseEvaluationAccuracy:=TPasJSON.GetInt64(TPasJSONItemObject(aJSONItem).Properties['reverseevaluationaccuracy'],fReverseEvaluationAccuracy);
  fSteerAngleLimitEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeranglelimitenvelope']);
  fSteeringResetSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeringresetspeedenvelope']);
  fSteeringSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeringspeedenvelope']);
  fFlightStabilizationForce:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightstabilizationforce'],fFlightStabilizationForce);
  fFlightStabilizationDamping:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightstabilizationdamping'],fFlightStabilizationDamping);
  fHandBrakeSlipperyTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['handbrakeslipperytime'],fHandBrakeSlipperyTime);
  fControllable:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['controllable'],fControllable);
  fDownForceCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['downforcecurveenvelope']);
  fDownForce:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['downforce'],fDownForce);
  fAxleFront.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['axlefront']);
  fAxleRear.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['axlerear']);
 end;
end;

function TVehicle.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('accelerationcurveenvelope',fAccelerationCurveEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('reverseaccelerationcurveenvelope',fReverseAccelerationCurveEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('reverseevaluationaccuracyenvelope',TPasJSONItemNumber.Create(fReverseEvaluationAccuracy));
 TPasJSONItemObject(result).Add('steeranglelimitenvelope',fSteerAngleLimitEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('steeringresetspeedenvelope',fSteeringResetSpeedEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('steeringspeedenvelope',fSteeringSpeedEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('flightstabilizationforce',TPasJSONItemNumber.Create(fFlightStabilizationForce));
 TPasJSONItemObject(result).Add('flightstabilizationdamping',TPasJSONItemNumber.Create(fFlightStabilizationDamping));
 TPasJSONItemObject(result).Add('handbrakeslipperytime',TPasJSONItemNumber.Create(fHandBrakeSlipperyTime));
 TPasJSONItemObject(result).Add('controllable',TPasJSONItemBoolean.Create(fControllable));
 TPasJSONItemObject(result).Add('downforcecurveenvelope',fDownForceCurveEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('downforce',TPasJSONItemNumber.Create(fDownForce));
 TPasJSONItemObject(result).Add('axlefront',fAxleFront.SaveToJSON);
 TPasJSONItemObject(result).Add('axlerear',fAxleRear.SaveToJSON);
end;
{$endif}

{$ifdef DebugDraw}
procedure TVehicle.DebugDraw;
var v{$ifdef NoOpenGL},v0{$endif}:TKraftVector3;
begin
 v:=Vector3TermMatrixMul(fRigidBody.Sweep.LocalCenter,fRigidBody.InterpolatedWorldTransform);
{$ifdef NoOpenGL}
{$else}
 glDisable(GL_DEPTH_TEST);
{$endif}
 fAxleFront.DebugDraw;
 fAxleRear.DebugDraw;
{$ifdef NoOpenGL}
 if assigned(fDebugDrawLine) then begin
  v0:=Vector3Lerp(fAxleFront.fVisualDebugMiddle,v,0.95);
  fDebugDrawLine(fAxleFront.fVisualDebugMiddle,v0,Vector4(0.0,0.0,1.0,1.0));
  fDebugDrawLine(v0,v,Vector4(0.0,1.0,1.0,1.0));
  v0:=Vector3Lerp(fAxleRear.fVisualDebugMiddle,v,0.95);
  fDebugDrawLine(v,v0,Vector4(0.0,1.0,1.0,1.0));
  fDebugDrawLine(v0,fAxleRear.fVisualDebugMiddle,Vector4(0.0,0.0,1.0,1.0));
 end;
{$else}
 glColor4f(0.0,0.0,1.0,1.0);
 glBegin(GL_LINE_STRIP);
 glVertex3fv(@fAxleFront.fVisualDebugMiddle);
 glVertex3fv(@v);
 glVertex3fv(@fAxleRear.fVisualDebugMiddle);
 glEnd;
 begin
  glColor4f(1.0,1.0,0.0,1.0);
  glBegin(GL_POINTS);
  glVertex3fv(@v);
  glEnd;
 end;
 glColor4f(1.0,1.0,1.0,1.0);
 glEnable(GL_DEPTH_TEST);
{$endif}
//write(#13,fAxleFront.SteerAngle:1:5,' ',AxleFront.WheelLeft.fYawRad*RAD2DEG:1:5,' ',fSpeed*3.6:1:5,' - ',fWorldForward.x:1:5,' ',fWorldForward.y:1:5,' ',fWorldForward.z:1:5);
end;
{$endif}

end.

