(******************************************************************************
 *                      VEHICLE PHYSICS FOR KRAFT PHYSICS ENGINE              *
 ******************************************************************************
 *                        Version 2023-07-03-18-51-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (c) 2023-2023, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 ******************************************************************************)
unit KraftRayCastVehicle;
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
     Generics.Collections,
{$ifdef KraftPasMP}
     PasMP,
{$endif}
{$ifdef KraftPasJSON}
     PasJSON,
{$endif}
     Math,
     Kraft;

type { TKraftRayCastVehicle }
     TKraftRayCastVehicle=class
      public
       const CountWheels=4; // Count of wheels
       type TDebugDrawLine=procedure(const aP0,aP1:TKraftVector3;const aColor:TKraftVector4) of object;
            { TEnvelope }
            TEnvelope=class
             public
              type TMode=
                    (
                     Custom,
                     Linear,
                     EaseInOut,
                     Value
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
              constructor CreateValue(const aValue:TKraftScalar);
              destructor Destroy; override;
              procedure Clear;
              procedure Assign(const aFrom:TEnvelope);
              procedure Insert(const aTime,aValue:TKraftScalar);
              procedure FillLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
              procedure FillEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
              procedure FillValue(const aValue:TKraftScalar);
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
            { TRescueForce } // For cases where the vehicle is stuck otherwise
            TRescueForce=class
             public
              fEnabled:boolean; // Enabled?
              fBelowSpeedThreshold:TKraftScalar; // Below speed threshold in km/h
              fBelowSpeedTimeDuration:TKraftScalar; // The time duration to check if we are below speed and thus stuck
              fForce:TKraftScalar; // Force to apply
              fUntilSpeed:TKraftScalar; // Until speed in km/h
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure Clear;
{$ifdef KraftPasJSON}
              procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
              function SaveToJSON:TPasJSONItem;
{$endif}
             published
              property Enabled:boolean read fEnabled write fEnabled;
              property BelowSpeedThreshold:TKraftScalar read fBelowSpeedThreshold write fBelowSpeedThreshold;
              property BelowSpeedTimeDuration:TKraftScalar read fBelowSpeedTimeDuration write fBelowSpeedTimeDuration;
              property Force:TKraftScalar read fForce write fForce;
              property UntilSpeed:TKraftScalar read fUntilSpeed write fUntilSpeed;
            end;
            { TRescueForceState }
            TRescueForceState=record
             private
              fTimeUnderBelowSpeedThreshold:TKraftDouble;
              procedure Reset;
              function GetOverrideForce(const aRescueForce:TRescueForce;const aAbsoluteSpeedKMH,aOriginalForce:TKraftScalar;const aDeltaTime:TKraftDouble):TKraftScalar;
            end;
            { TSuspensionSpringMath }
            TSuspensionSpringMath=class
             public
              class function CalculateForce(const aCurrentLength,aRestLength,aStrength:TKraftScalar):TKraftScalar; static;
              class function CalculateForceDamped(const aCurrentLength,aLengthVelocity,aRestLength,aStrength,aDamper:TKraftScalar):TKraftScalar; static;
            end;
            TSuspensionMode=
             (
              Arcade,
              Realistic
             );
            PSuspensionMode=^TSuspensionMode;
            { TSuspension }
            TSuspension=record
             private
              fCurrentLength:TKraftScalar;
              fCurrentVelocity:TKraftScalar;
              fCompression:TKraftScalar;
            end;
            PSuspension=^TSuspension;
            { TSettings }
            TSettings=class // Vehicle settings
             public
              type { TWheel }
                   TWheel=class // A single wheel
                    public
                     type { TVisual }
                          TVisual=class
                           private
                            fWheel:TKraftRaycastVehicle.TSettings.TWheel;
                            fModelNode:UTF8String;
                            fRotationAxisMappingX:TKraftInt32;
                            fRotationAxisMappingY:TKraftInt32;
                            fRotationAxisMappingZ:TKraftInt32;
                            fRotationFactors:TKraftVector3;
                            fHeightOffset:TKraftScalar;
                            fRadius:TKraftScalar;
                           public
                            constructor Create(const aWheel:TKraftRaycastVehicle.TSettings.TWheel); reintroduce;
                            destructor Destroy; override;
{$ifdef KraftPasJSON}
                            procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
                            function SaveToJSON:TPasJSONItem;
{$endif}
                           public
                            property Wheel:TKraftRaycastVehicle.TSettings.TWheel read fWheel;
                            property ModelNode:UTF8String read fModelNode write fModelNode;
                            property RotationAxisMappingX:TKraftInt32 read fRotationAxisMappingX write fRotationAxisMappingX;
                            property RotationAxisMappingY:TKraftInt32 read fRotationAxisMappingY write fRotationAxisMappingY;
                            property RotationAxisMappingZ:TKraftInt32 read fRotationAxisMappingZ write fRotationAxisMappingZ;
                            property RotationFactors:TKraftVector3 read fRotationFactors write fRotationFactors;
                            property HeightOffset:TKraftScalar read fHeightOffset write fHeightOffset;
                            property Radius:TKraftScalar read fRadius write fRadius;
                          end;
                    private
                     fSettings:TSettings;
                     fName:UTF8String; // Name of the wheel
                     fPosition:TKraftVector3; // x = left/right, y = height, z = front/back
                     fRadius:TKraftScalar; // Radius of the wheel
                     fLength:TKraftScalar; // Length of the wheel for the usage with a future-implemented cylinder cast
                     fUseSphereCast:Boolean; // Use sphere cast instead of ray cast
                     fPowered:Boolean; // Is the wheel powered?
                     fSteering:Boolean; // Can the wheel do steering?
                     fMass:TKraftScalar; // Mass of the wheel
                     fSuspensionClamping:Boolean; // Clamping of the suspension length?
                     fSuspensionRestLength:TKraftScalar; // Rest length of the suspension
                     fSuspensionStrength:TKraftScalar; // Strength of the suspension
                     fSuspensionDamping:TKraftScalar; // Damping of the suspension
                     fSuspensionRelaxRate:TKraftScalar; // Relax time
                     fAccelerationForceFactor:TKraftScalar; // Acceleration force factor
                     fBrakeForceFactor:TKraftScalar; // Brake force factor
                     fRollingFriction:TKraftScalar; // Rolling friction
                     fMaximumSpeed:TKraftScalar; // Maximum speed in forward direction
                     fMaximumReverseSpeed:TKraftScalar; // Maximum speed in reverse direction
                     fGripFactor:TKraftScalar; // Grip factor at lateral forces
                     fAfterFlightSlipperyK:TKraftScalar; // Slippery K factor after flight at lateral forces
                     fBrakeSlipperyK:TKraftScalar; // Slippery K factor at brake at lateral forces
                     fHandBrakeSlipperyK:TKraftScalar; // Slippery K factor at hand brake at lateral forces
                     fDriftSlipperyK:TKraftScalar; // Slippery K factor at drift at lateral forces
                     fVisual:TKraftRaycastVehicle.TSettings.TWheel.TVisual; // Visual data of the wheel
                    public
                     constructor Create(const aSettings:TSettings); reintroduce;
                     destructor Destroy; overload;
{$ifdef KraftPasJSON}
                     procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
                     function SaveToJSON:TPasJSONItem;
{$endif}
                    public
                     property Name:UTF8String read fName write fName;
                     property Position:TKraftVector3 read fPosition write fPosition;
                     property Radius:TKraftScalar read fRadius write fRadius;
                     property Length:TKraftScalar read fLength write fLength;
                     property UseSphereCast:Boolean read fUseSphereCast write fUseSphereCast;
                     property Powered:Boolean read fPowered write fPowered;
                     property Steering:Boolean read fSteering write fSteering;
                     property Mass:TKraftScalar read fMass write fMass;
                     property SuspensionClamping:Boolean read fSuspensionClamping write fSuspensionClamping;
                     property SuspensionRestLength:TKraftScalar read fSuspensionRestLength write fSuspensionRestLength;
                     property SuspensionStrength:TKraftScalar read fSuspensionStrength write fSuspensionStrength;
                     property SuspensionDamping:TKraftScalar read fSuspensionDamping write fSuspensionDamping;
                     property SuspensionRelaxRate:TKraftScalar read fSuspensionRelaxRate write fSuspensionRelaxRate;
                     property AccelerationForceFactor:TKraftScalar read fAccelerationForceFactor write fAccelerationForceFactor;
                     property BrakeForceFactor:TKraftScalar read fBrakeForceFactor write fBrakeForceFactor;
                     property RollingFriction:TKraftScalar read fRollingFriction write fRollingFriction;
                     property MaximumSpeed:TKraftScalar read fMaximumSpeed write fMaximumSpeed;
                     property MaximumReverseSpeed:TKraftScalar read fMaximumReverseSpeed write fMaximumReverseSpeed;
                     property GripFactor:TKraftScalar read fGripFactor write fGripFactor;
                     property AfterFlightSlipperyK:TKraftScalar read fAfterFlightSlipperyK write fAfterFlightSlipperyK;
                     property BrakeSlipperyK:TKraftScalar read fBrakeSlipperyK write fBrakeSlipperyK;
                     property HandBrakeSlipperyK:TKraftScalar read fHandBrakeSlipperyK write fHandBrakeSlipperyK;
                     property DriftSlipperyK:TKraftScalar read fDriftSlipperyK write fDriftSlipperyK;
                     property Visual:TKraftRaycastVehicle.TSettings.TWheel.TVisual read fVisual;
                   end;
                   TWheels=Generics.Collections.TObjectList<TWheel>;
                   { TAxle }
                   TAxle=class // Axle with two or more wheels
                    private
                     fSettings:TKraftRaycastVehicle.TSettings;
                     fName:UTF8String; // Name of the axle
                     fWheels:TKraftRaycastVehicle.TSettings.TWheels; // Wheels of the axle
                     fStabilizerBarAntiRollForceFactor:TKraftScalar; // Anti roll force of the stabilizer bar
                    public
                     constructor Create(const aSettings:TKraftRaycastVehicle.TSettings); reintroduce;
                     destructor Destroy; override;
{$ifdef KraftPasJSON}
                     procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
                     function SaveToJSON:TPasJSONItem;
{$endif}
                    public
                     property Name:UTF8String read fName write fName;
                     property Wheels:TKraftRaycastVehicle.TSettings.TWheels read fWheels;
                     property StabilizerBarAntiRollForceFactor:TKraftScalar read fStabilizerBarAntiRollForceFactor write fStabilizerBarAntiRollForceFactor;
                   end;
                   TAxles=Generics.Collections.TObjectList<TAxle>;
                   { TAckermannGroup }
                   TAckermannGroup=class // Group of axles with Ackermann steering
                    private
                     fSettings:TKraftRaycastVehicle.TSettings;
                     fName:UTF8String; // Name of the Ackermann group
                     fAxles:TKraftRaycastVehicle.TSettings.TAxles; // Axles of the Ackermann group
                    public
                     constructor Create(const aSettings:TKraftRaycastVehicle.TSettings); reintroduce;
                     destructor Destroy; override;
{$ifdef KraftPasJSON}
                     procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
                     function SaveToJSON:TPasJSONItem;
{$endif}
                    public
                     property Name:UTF8String read fName write fName;
                     property Axles:TKraftRaycastVehicle.TSettings.TAxles read fAxles;
                   end;
                   TAckermannGroups=Generics.Collections.TObjectList<TAckermannGroup>;
             private
              fSuspensionMode:TKraftRayCastVehicle.TSuspensionMode;
              fWidth:TKraftScalar;
              fHeight:TKraftScalar;
              fLength:TKraftScalar;
              fAngularVelocityDamp:TKraftScalar;
              fLinearVelocityDamp:TKraftScalar;
              fRigidBodyRestitution:TKraftScalar;
              fRigidBodyRestitutionThreshold:TKraftScalar;
              fRigidBodyDensity:TKraftScalar;
              fRigidBodyFriction:TKraftScalar;
              fShapeOffset:TKraftVector3;
              fVisualModelOffset:TKraftVector3;
              fCenterOfMass:TKraftVector3;
              fChassisMass:TKraftScalar;
              fAirResistance:TKraftScalar;
              fHandBrakeSlipperyTime:TKraftScalar;
              fDriftSlipperyTime:TKraftScalar;
              fMaximumGravitySlopeAngle:TKraftScalar;
              fMaximumSpeed:TKraftScalar;
              fMaximumReverseSpeed:TKraftScalar;
              fAccelerationMinimumForce:TKraftScalar;
              fReverseAccelerationMinimumForce:TKraftScalar;
              fCurveEvaluationAccuracy:TKraftInt32;
              fAccelerationRescueForce:TRescueForce;
              fReverseAccelerationRescueForce:TRescueForce;
              fAccelerationCurveEnvelope:TEnvelope;
              fReverseAccelerationCurveEnvelope:TEnvelope;
              fBrakeCurveEnvelope:TEnvelope;
              fReverseBrakeCurveEnvelope:TEnvelope;
              fSteerAngleLimitEnvelope:TEnvelope;
              fSteeringResetSpeedEnvelope:TEnvelope;
              fSteeringSpeedEnvelope:TEnvelope;
              fDriftAngleAccelerationFactorEnvelope:TEnvelope;
              fDriftSteerAngleLimitEnvelope:TEnvelope;
              fDriftSteeringResetSpeedEnvelope:TEnvelope;
              fDriftSteeringSpeedEnvelope:TEnvelope;
              fGripFactorEnvelope:TEnvelope;
              fDrivingTractionFactorEnvelope:TEnvelope;
              fDownForceCurveEnvelope:TEnvelope;
              fDownForceFactor:TKraftScalar;
              fJumpImpulse:TKraftScalar;
              fDriftAfterJump:LongBool;
              fSuperJumpImpulse:TKraftScalar;
              fDriftAfterSuperJump:LongBool;
              fFlightSteeringTorqueFactor:TKraftScalar;
              fFlightSteeringTorqueFactorOnJump:TKraftScalar;
              fFlightSteeringTorqueFactorOnSuperJump:TKraftScalar;
              fFlightStabilizationAngularVelocityDamping:TKraftVector3;
              fFlightStabilizationDamping:TKraftScalar;
              fFlightStabilizationForceFactor:TKraftScalar;
              fKeepUprightThreshold:TKraftScalar;
              fKeepUprightForceFactor:TKraftScalar;
              fWheels:TWheels;
              fAxles:TAxles;
              fAckermannGroups:TAckermannGroups;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure LoadDefaultFourWheelsConfiguration;
{$ifdef KraftPasJSON}
              procedure LoadFromJSON(const aJSONItem:TPasJSONItem);
              function SaveToJSON:TPasJSONItem;
{$endif}
             public
              property SuspensionMode:TKraftRayCastVehicle.TSuspensionMode read fSuspensionMode write fSuspensionMode;
              property Width:TKraftScalar read fWidth write fWidth;
              property Height:TKraftScalar read fHeight write fHeight;
              property Length:TKraftScalar read fLength write fLength;
              property AngularVelocityDamp:TKraftScalar read fAngularVelocityDamp write fAngularVelocityDamp;
              property LinearVelocityDamp:TKraftScalar read fLinearVelocityDamp write fLinearVelocityDamp;
              property RigidBodyRestitution:TKraftScalar read fRigidBodyRestitution write fRigidBodyRestitution;
              property RigidBodyRestitutionThreshold:TKraftScalar read fRigidBodyRestitutionThreshold write fRigidBodyRestitutionThreshold;
              property RigidBodyDensity:TKraftScalar read fRigidBodyDensity write fRigidBodyDensity;
              property RigidBodyFriction:TKraftScalar read fRigidBodyFriction write fRigidBodyFriction;
              property ShapeOffset:TKraftVector3 read fShapeOffset write fShapeOffset;
              property VisualModelOffset:TKraftVector3 read fVisualModelOffset write fVisualModelOffset;
              property CenterOfMass:TKraftVector3 read fCenterOfMass write fCenterOfMass;
              property ChassisMass:TKraftScalar read fChassisMass write fChassisMass;
              property AirResistance:TKraftScalar read fAirResistance write fAirResistance;
              property HandBrakeSlipperyTime:TKraftScalar read fHandBrakeSlipperyTime write fHandBrakeSlipperyTime;
              property DriftSlipperyTime:TKraftScalar read fDriftSlipperyTime write fDriftSlipperyTime;
              property MaximumGravitySlopeAngle:TKraftScalar read fMaximumGravitySlopeAngle write fMaximumGravitySlopeAngle;
              property MaximumSpeed:TKraftScalar read fMaximumSpeed write fMaximumSpeed;
              property MaximumReverseSpeed:TKraftScalar read fMaximumReverseSpeed write fMaximumReverseSpeed;
              property AccelerationMinimumForce:TKraftScalar read fAccelerationMinimumForce write fAccelerationMinimumForce;
              property ReverseAccelerationMinimumForce:TKraftScalar read fReverseAccelerationMinimumForce write fReverseAccelerationMinimumForce;
              property CurveEvaluationAccuracy:TKraftInt32 read fCurveEvaluationAccuracy write fCurveEvaluationAccuracy;
              property AccelerationRescueForce:TRescueForce read fAccelerationRescueForce;
              property ReverseAccelerationRescueForce:TRescueForce read fReverseAccelerationRescueForce;
              property AccelerationCurveEnvelope:TEnvelope read fAccelerationCurveEnvelope;
              property ReverseAccelerationCurveEnvelope:TEnvelope read fReverseAccelerationCurveEnvelope;
              property BrakeCurveEnvelope:TEnvelope read fBrakeCurveEnvelope;
              property ReverseBrakeCurveEnvelope:TEnvelope read fReverseBrakeCurveEnvelope;
              property SteerAngleLimitEnvelope:TEnvelope read fSteerAngleLimitEnvelope;
              property SteeringResetSpeedEnvelope:TEnvelope read fSteeringResetSpeedEnvelope;
              property SteeringSpeedEnvelope:TEnvelope read fSteeringSpeedEnvelope;
              property DriftAngleAccelerationFactorEnvelope:TEnvelope read fDriftAngleAccelerationFactorEnvelope;
              property DriftSteerAngleLimitEnvelope:TEnvelope read fDriftSteerAngleLimitEnvelope;
              property DriftSteeringResetSpeedEnvelope:TEnvelope read fDriftSteeringResetSpeedEnvelope;
              property DriftSteeringSpeedEnvelope:TEnvelope read fDriftSteeringSpeedEnvelope;
              property GripFactorEnvelope:TEnvelope read fGripFactorEnvelope;
              property DrivingTractionFactorEnvelope:TEnvelope read fDrivingTractionFactorEnvelope;
              property DownForceCurveEnvelope:TEnvelope read fDownForceCurveEnvelope;
              property DownForceFactor:TKraftScalar read fDownForceFactor write fDownForceFactor;
              property JumpImpulse:TKraftScalar read fJumpImpulse write fJumpImpulse;
              property DriftAfterJump:LongBool read fDriftAfterJump write fDriftAfterJump;
              property SuperJumpImpulse:TKraftScalar read fSuperJumpImpulse write fSuperJumpImpulse;
              property DriftAfterSuperJump:LongBool read fDriftAfterSuperJump write fDriftAfterSuperJump;
              property FlightSteeringTorqueFactor:TKraftScalar read fFlightSteeringTorqueFactor write fFlightSteeringTorqueFactor;
              property FlightSteeringTorqueFactorOnJump:TKraftScalar read fFlightSteeringTorqueFactorOnJump write fFlightSteeringTorqueFactorOnJump;
              property FlightSteeringTorqueFactorOnSuperJump:TKraftScalar read fFlightSteeringTorqueFactorOnSuperJump write fFlightSteeringTorqueFactorOnSuperJump;
              property FlightStabilizationAngularVelocityDamping:TKraftVector3 read fFlightStabilizationAngularVelocityDamping write fFlightStabilizationAngularVelocityDamping;
              property FlightStabilizationDamping:TKraftScalar read fFlightStabilizationDamping write fFlightStabilizationDamping;
              property FlightStabilizationForceFactor:TKraftScalar read fFlightStabilizationForceFactor write fFlightStabilizationForceFactor;
              property KeepUprightThreshold:TKraftScalar read fKeepUprightThreshold write fKeepUprightThreshold;
              property KeepUprightForce:TKraftScalar read fKeepUprightForceFactor write fKeepUprightForceFactor;
              property Wheels:TWheels read fWheels;
              property Axles:TAxles read fAxles;
              property AckermannGroups:TAckermannGroups read fAckermannGroups;
            end;
            TWheel=class;
            TAxle=class;
            TAckermannGroup=class;
            { TWheel }
            TWheel=class
             private
              fVehicle:TKraftRayCastVehicle;
              fSettings:TKraftRayCastVehicle.TSettings.TWheel;
              fAxle:TKraftRayCastVehicle.TAxle;
              fIsGrounded:boolean;
              fSuspensionPreviousCompressionDistance:TKraftScalar;
              fSuspensionCompressionDistance:TKraftScalar;
              fSuspensionCompressionRatio:TKraftScalar;
              fSuspension:TSuspension;
              fYawRad:TKraftScalar;
              fLastYawRad:TKraftScalar;
              fVisualYawRad:TKraftScalar;
              fPhysicalRotationRad:TKraftScalar;
              fLastPhysicalRotationRad:TKraftScalar;
              fVisualPhysicalRotationRad:TKraftScalar;
              fRotationRad:TKraftScalar;
              fLastRotationRad:TKraftScalar;
              fVisualRotationRad:TKraftScalar;
              fSuspensionLength:TKraftScalar;
              fLastSuspensionLength:TKraftScalar;
              fVisualSuspensionLength:TKraftScalar;
              fLaterialForceStrength:TKraftScalar;
              fWorldTransform:TKraftMatrix4x4;
              fLastWorldTransform:TKraftMatrix4x4;
              fVisualWorldTransform:TKraftMatrix4x4;
{$ifdef DebugDraw}
              fDebugAntiRollForceFactor:TKraftVector3;
              fLastDebugAntiRollForceFactor:TKraftVector3;
              fVisualDebugAntiRollForceFactor:TKraftVector3;
              fDebugAccelerationForce:TKraftVector3;
              fLastDebugAccelerationForce:TKraftVector3;
              fVisualDebugAccelerationForce:TKraftVector3;
              fDebugLongitudinalForce:TKraftVector3;
              fLastDebugLongitudinalForce:TKraftVector3;
              fVisualDebugLongitudinalForce:TKraftVector3;
              fDebugLaterialForce:TKraftVector3;
              fLastDebugLaterialForce:TKraftVector3;
              fVisualDebugLaterialForce:TKraftVector3;
{$endif}
             public
              function GetSuspensionHitPosition:TKraftVector3;
              function GetSuspensionPosition:TKraftVector3;
              function GetSuspensionRelativePosition:TKraftVector3;
              function GetWheelGripFactor:TKraftScalar;
              function GetWheelLongitudinalDirection:TKraftVector3;
              function GetWheelLaterialDirection:TKraftVector3;
              function GetWheelTorquePosition:TKraftVector3;
              function GetWheelTorqueRelativePosition:TKraftVector3;
              function GetWheelTransform:TKraftMatrix4x4;
             private
              procedure UpdateArcadeSuspension;
              procedure UpdateRealisticSuspension;
              procedure UpdateSuspension;
              procedure UpdateLaterialForce;
              procedure UpdateAcceleration;
              procedure UpdateLongitudinalForce;
              procedure UpdateWheelRotation;
              procedure UpdateVisuals;
              procedure StoreWorldTransforms;
              procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar);
             public
              constructor Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TWheel); reintroduce;
              destructor Destroy; override;
             published
              property Settings:TKraftRayCastVehicle.TSettings.TWheel read fSettings;
              property Axle:TKraftRayCastVehicle.TAxle read fAxle write fAxle;
              property VisualYawRad:TKraftScalar read fVisualYawRad;
              property VisualRotationRad:TKraftScalar read fVisualPhysicalRotationRad;
              property VisualSuspensionLength:TKraftScalar read fVisualSuspensionLength;
            end;
            { TWheels }
            TWheels=Generics.Collections.TObjectList<TWheel>;
            { TAxle }
            TAxle=class
             private
              fVehicle:TKraftRayCastVehicle;
              fSettings:TKraftRayCastVehicle.TSettings.TAxle;
              fAckermannGroup:TKraftRayCastVehicle.TAckermannGroup;
              fWheels:TKraftRayCastVehicle.TWheels;
             public
              constructor Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TAxle); reintroduce;
              destructor Destroy; override;
              procedure UpdateAntiRollBar;
             published
              property Settings:TKraftRayCastVehicle.TSettings.TAxle read fSettings;
              property AckermannGroup:TKraftRayCastVehicle.TAckermannGroup read fAckermannGroup write fAckermannGroup;
              property Wheels:TKraftRayCastVehicle.TWheels read fWheels;
            end;
            { TAxles }
            TAxles=Generics.Collections.TObjectList<TAxle>;
            { TAckermannGroup }
            TAckermannGroup=class
             private
              fVehicle:TKraftRayCastVehicle;
              fSettings:TKraftRayCastVehicle.TSettings.TAckermannGroup;
              fAxles:TKraftRayCastVehicle.TAxles;
             public
              constructor Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TAckermannGroup); reintroduce;
              destructor Destroy; override;
              procedure UpdateAckermannSteering;
             published
              property Settings:TKraftRayCastVehicle.TSettings.TAckermannGroup read fSettings;
              property Axles:TKraftRayCastVehicle.TAxles read fAxles;
            end;
            { TAckermannGroups }
            TAckermannGroups=Generics.Collections.TObjectList<TAckermannGroup>;
            TOnGroundContactAfterJump=function(const aSender:TKraftRayCastVehicle):Boolean of object;
            TOnJump=procedure(const aSender:TKraftRayCastVehicle) of object;
            TOnJumpDone=procedure(const aSender:TKraftRayCastVehicle) of object;
            TOnGroundContactAfterSuperJump=function(const aSender:TKraftRayCastVehicle):Boolean of object;
            TOnSuperJump=procedure(const aSender:TKraftRayCastVehicle) of object;
            TOnSuperJumpDone=procedure(const aSender:TKraftRayCastVehicle) of object;
      private
       fPhysics:TKraft;
       fOwnsRigidBody:Boolean;
       fOwnsFreeShape:Boolean;
       fOnRayCastFilter:TKraftOnRayCastFilterHook;
       fConvexHull:TKraftConvexHull;
       fRigidBody:TKraftRigidBody;
       fShape:TKraftShape;
       fWheels:TWheels;
       fAxles:TAxles;
       fAckermannGroups:TAckermannGroups;
       fControllable:boolean;
       fAccelerationInput:TKraftScalar;
       fSettings:TSettings;
       fForward:TKraftVector3;
       fVelocity:TKraftVector3;
       fCountGroundedWheels:TKraftInt32;
       fDeltaTime:TKraftScalar;
       fInverseDeltaTime:TKraftScalar;
       fDebugDrawLine:TDebugDrawLine;
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
       fInputAIFlightSteerFactor:TKraftScalar;
       fInputAISteering:TKraftScalar;
       fInputHorizontal:TKraftScalar;
       fInputVertical:TKraftScalar;
       fInputReset:Boolean;
       fInputBrake:Boolean;
       fInputHandBrake:Boolean;
       fInputDrift:Boolean;
       fInputJump:Boolean;
       fInputSuperJump:Boolean;
       fInputAI:Boolean;
       fIsJump:Boolean;
       fJumpState:TKraftInt32;
       fDriftAfterJump:Boolean;
       fIsSuperJump:Boolean;
       fSuperJumpState:TKraftInt32;
       fDriftAfterSuperJump:Boolean;
       fIsAcceleration:Boolean;
       fIsReverseAcceleration:Boolean;
       fIsBrake:Boolean;
       fIsHandBrake:Boolean;
       fIsDrift:Boolean;
       fCountPoweredWheels:TKraftInt32;
       fAfterFlightSlipperyTiresTime:TKraftScalar;
       fBrakeSlipperyTiresTime:TKraftScalar;
       fHandBrakeSlipperyTiresTime:TKraftScalar;
       fDriftSlipperyTiresTime:TKraftScalar;
       fSteeringAngle:TKraftScalar;
       fFlightSteering:TKraftScalar;
       fAccelerationRescueForceState:TRescueForceState;
       fReverseAccelerationRescueForceState:TRescueForceState;
       fAccelerationForceMagnitude:TKraftScalar;
       fBrakeForceMagnitude:TKraftScalar;
       fSpeed:TKraftScalar;
       fSpeedKMH:TKraftScalar;
       fAbsoluteSpeedKMH:TKraftScalar;
       fMovingForward:boolean;
       fHitAverageNormal:TKraftVector3;
       fHitAverageNormalCount:TKraftInt32;
       fCollisionGroups:TKraftRigidBodyCollisionGroups;
       fCollideWithCollisionGroups:TKraftRigidBodyCollisionGroups;
       fCastCollisionGroups:TKraftRigidBodyCollisionGroups;
       fOnGroundContactAfterJump:TOnGroundContactAfterJump;
       fOnJump:TOnJump;
       fOnJumpDone:TOnJumpDone;
       fOnGroundContactAfterSuperJump:TOnGroundContactAfterSuperJump;
       fOnSuperJump:TOnSuperJump;
       fOnSuperJumpDone:TOnSuperJumpDone;
       fData:TObject;
{$ifdef DebugDraw}
       fDebugAirResistanceForce:TKraftVector3;
       fLastDebugAirResistanceForce:TKraftVector3;
       fVisualDebugAirResistanceForce:TKraftVector3;
       fDebugDownForceFactor:TKraftVector3;
       fLastDebugDownForceFactor:TKraftVector3;
       fVisualDebugDownForceFactor:TKraftVector3;
       fDebugFlightStabilizationTorque:TKraftVector3;
       fLastDebugFlightStabilizationTorque:TKraftVector3;
       fVisualDebugFlightStabilizationTorque:TKraftVector3;
       fDebugKeepUprightTorque:TKraftVector3;
       fLastDebugKeepUprightTorque:TKraftVector3;
       fVisualDebugKeepUprightTorque:TKraftVector3;
{$endif}
       function ShapeCanCollideWith(const WithShape:TKraftShape):boolean;
       function RayCastFilter(const aPoint,aNormal:TKraftVector3;const aTime:TKraftScalar;const aShape:TKraftShape):boolean;
       function GetHandBrakeK:TKraftScalar;
       function GetDriftK:TKraftScalar;
       function GetSteeringHandBrakeK:TKraftScalar;
       function GetSteerAngleLimitInDegrees(const aSpeedKMH:TKraftScalar):TKraftScalar;
       function GetSpeed:TKraftScalar;
       function GetAccelerationOrBrakeForceMagnitude(const aEnvelope:TEnvelope;const aSpeedKMH,aDeltaTime:TKraftScalar;const aBraking:boolean):TKraftScalar;
       function CalcAccelerationForceMagnitude:TKraftScalar;
       function CalcBrakeForceMagnitude:TKraftScalar;
       procedure UpdateGlobals;
       procedure UpdateInput;
       procedure UpdateWorldTransformVectors;
       procedure UpdateSuspension;
       procedure UpdateTractionAndGravityAndNearlyFlatGroundDetection;
       procedure UpdateAckermannSteering;
       procedure UpdateSteering;
       procedure UpdateAcceleration;
       procedure UpdateBraking;
       procedure UpdateAntiRollBar;
       procedure UpdateAirResistance;
       procedure UpdateDownForce;
       procedure UpdateJump;
       procedure UpdateSuperJump;
       procedure UpdateFlightStabilization;
       procedure UpdateKeepUpright;
       procedure UpdateWheelRotations;
       procedure UpdateVisuals;
      public
       constructor Create(const aPhysics:TKraft); reintroduce;
       destructor Destroy; override;
       procedure Reset;
       procedure Finish;
       procedure ReleaseJump;
       procedure ReleaseSuperJump;
       procedure Update(const aDeltaTime:TKraftScalar);
       procedure StoreWorldTransforms;
       procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar);
{$ifdef DebugDraw}
       procedure DebugDraw;
{$endif}
      public
       property Settings:TSettings read fSettings write fSettings;
       property CollisionGroups:TKraftRigidBodyCollisionGroups read fCollisionGroups write fCollisionGroups;
       property CollideWithCollisionGroups:TKraftRigidBodyCollisionGroups read fCollideWithCollisionGroups write fCollideWithCollisionGroups;
       property CastCollisionGroups:TKraftRigidBodyCollisionGroups read fCastCollisionGroups write fCastCollisionGroups;
       property OnGroundContactAfterJump:TOnGroundContactAfterJump read fOnGroundContactAfterJump write fOnGroundContactAfterJump;
       property OnJump:TOnJump read fOnJump write fOnJump;
       property OnJumpDone:TOnJumpDone read fOnJumpDone write fOnJumpDone;
       property OnGroundContactAfterSuperJump:TOnGroundContactAfterSuperJump read fOnGroundContactAfterSuperJump write fOnGroundContactAfterSuperJump;
       property OnSuperJump:TOnSuperJump read fOnSuperJump write fOnSuperJump;
       property OnSuperJumpDone:TOnSuperJumpDone read fOnSuperJumpDone write fOnSuperJumpDone;
       property Data:TObject read fData write fData;
       property Wheels:TWheels read fWheels;
       property Axles:TAxles read fAxles;
      published
       property Physics:TKraft read fPhysics;
       property OnRayCastFilter:TKraftOnRayCastFilterHook read fOnRayCastFilter write fOnRayCastFilter;
       property ConvexHull:TKraftConvexHull read fConvexHull write fConvexHull;
       property RigidBody:TKraftRigidBody read fRigidBody write fRigidBody;
       property Shape:TKraftShape read fShape write fShape;
       property Controllable:boolean read fControllable write fControllable;
       property IsAcceleration:boolean read fIsAcceleration;
       property IsReverseAcceleration:boolean read fIsReverseAcceleration;
       property CountPoweredWheels:TKraftInt32 read fCountPoweredWheels;
       property CountGroundedWheels:TKraftInt32 read fCountGroundedWheels;
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
       property InputAIFlightSteerFactor:TKraftScalar read fInputAIFlightSteerFactor write fInputAIFlightSteerFactor;
       property InputAISteering:TKraftScalar read fInputAISteering write fInputAISteering;
       property InputHorizontal:TKraftScalar read fInputHorizontal write fInputHorizontal;
       property InputVertical:TKraftScalar read fInputVertical write fInputVertical;
       property InputReset:Boolean read fInputReset write fInputReset;
       property InputBrake:Boolean read fInputBrake write fInputBrake;
       property InputHandBrake:Boolean read fInputHandBrake write fInputHandBrake;
       property InputDrift:Boolean read fInputDrift write fInputDrift;
       property InputJump:Boolean read fInputJump write fInputJump;
       property InputSuperJump:Boolean read fInputSuperJump write fInputSuperJump;
       property InputAI:Boolean read fInputAI write fInputAI;
       property Speed:TKraftScalar read fSpeed write fSpeed;
       property SpeedKMH:TKraftScalar read fSpeedKMH write fSpeedKMH;
       property AbsoluteSpeedKMH:TKraftScalar read fAbsoluteSpeedKMH write fAbsoluteSpeedKMH;
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

{$ifdef KraftPasJSON}
function JSONToVector2(const aVectorJSONItem:TPasJSONItem;const aDefault:TKraftVector2):TKraftVector2;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=2) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector2ToJSON(const aVector:TKraftVector2):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
end;

function JSONToVector3(const aVectorJSONItem:TPasJSONItem;const aDefault:TKraftVector3):TKraftVector3;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=3) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[2],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['z'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector3ToJSON(const aVector:TKraftVector3):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
 result.Add(TPasJSONItemNumber.Create(aVector.z));
end;
{$endif}

{ TEnvelope }

constructor TKraftRayCastVehicle.TEnvelope.Create;
begin
 inherited Create;
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.Custom;
 fPoints:=nil;
 fCount:=0;
end;

constructor TKraftRayCastVehicle.TEnvelope.CreateLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
begin
 Create;
 FillLinear(aTimeStart,aValueStart,aTimeEnd,aValueEnd);
end;

constructor TKraftRayCastVehicle.TEnvelope.CreateEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
begin
 Create;
 FillEaseInOut(aTimeStart,aValueStart,aTimeEnd,aValueEnd,aSteps);
end;

constructor TKraftRayCastVehicle.TEnvelope.CreateValue(const aValue:TKraftScalar);
begin
 Create;
 FillValue(aValue);
end;

destructor TKraftRayCastVehicle.TEnvelope.Destroy;
begin
 fPoints:=nil;
 inherited Destroy;
end;

procedure TKraftRayCastVehicle.TEnvelope.Clear;
begin
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.Custom;
 fPoints:=nil;
 fCount:=0;
end;

procedure TKraftRayCastVehicle.TEnvelope.Assign(const aFrom:TEnvelope);
begin
 fMode:=aFrom.fMode;
 fPoints:=copy(aFrom.fPoints);
 fCount:=aFrom.fCount;
end;

procedure TKraftRayCastVehicle.TEnvelope.Insert(const aTime,aValue:TKraftScalar);
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
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.Custom;
 Point:=@fPoints[Index];
 Point^.fTime:=aTime;
 Point^.fValue:=aValue;
end;

procedure TKraftRayCastVehicle.TEnvelope.FillLinear(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar);
begin
 Clear;
 Insert(aTimeStart,aValueStart);
 Insert(aTimeEnd,aValueEnd);
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.Linear;
end;

procedure TKraftRayCastVehicle.TEnvelope.FillEaseInOut(const aTimeStart,aValueStart,aTimeEnd,aValueEnd:TKraftScalar;const aSteps:TKraftInt32=16);
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
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.EaseInOut;
end;

procedure TKraftRayCastVehicle.TEnvelope.FillValue(const aValue:TKraftScalar);
begin
 Clear;
 Insert(0.0,aValue);
 fMode:=TKraftRayCastVehicle.TEnvelope.TMode.Value;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TEnvelope.LoadFromJSON(const aJSONItem:TPasJSONItem);
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
  end else if Mode='value' then begin
   FillValue(TPasJSON.GetNumber(RootJSONItemObject.Properties['value'],0.0));
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

function TKraftRayCastVehicle.TEnvelope.SaveToJSON:TPasJSONItem;
var Index:TKraftSizeInt;
    JSONItemArray:TPasJSONItemArray;
    JSONItemObject:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 case fMode of
  TKraftRayCastVehicle.TEnvelope.TMode.Linear:begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('linear'));
   TPasJSONItemObject(result).Add('timestart',TPasJSONItemNumber.Create(fPoints[0].fTime));
   TPasJSONItemObject(result).Add('valuestart',TPasJSONItemNumber.Create(fPoints[0].fValue));
   TPasJSONItemObject(result).Add('timeend',TPasJSONItemNumber.Create(fPoints[1].fTime));
   TPasJSONItemObject(result).Add('valueend',TPasJSONItemNumber.Create(fPoints[1].fValue));
  end;
  TKraftRayCastVehicle.TEnvelope.TMode.EaseInOut:begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('easeinout'));
   TPasJSONItemObject(result).Add('timestart',TPasJSONItemNumber.Create(fPoints[0].fTime));
   TPasJSONItemObject(result).Add('valuestart',TPasJSONItemNumber.Create(fPoints[0].fValue));
   TPasJSONItemObject(result).Add('timeend',TPasJSONItemNumber.Create(fPoints[fCount-1].fTime));
   TPasJSONItemObject(result).Add('valueend',TPasJSONItemNumber.Create(fPoints[fCount-1].fValue));
   TPasJSONItemObject(result).Add('steps',TPasJSONItemNumber.Create(fCount));
  end;
  TKraftRayCastVehicle.TEnvelope.TMode.Value:begin
   TPasJSONItemObject(result).Add('mode',TPasJSONItemString.Create('value'));
   TPasJSONItemObject(result).Add('value',TPasJSONItemNumber.Create(fPoints[0].fValue));
  end;
  else {TKraftRayCastVehicle.TEnvelope.TMode.Custom:}begin
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

function TKraftRayCastVehicle.TEnvelope.GetTimeAtIndex(const aIndex:TKraftInt32):TKraftScalar;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fPoints[aIndex].fTime;
 end else begin
  result:=0.0;
 end;
end;

function TKraftRayCastVehicle.TEnvelope.GetValueAtIndex(const aIndex:TKraftInt32):TKraftScalar;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fPoints[aIndex].fValue;
 end else begin
  result:=0.0;
 end;
end;

function TKraftRayCastVehicle.TEnvelope.GetIndexFromTime(const aTime:TKraftScalar):TKraftInt32;
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

function TKraftRayCastVehicle.TEnvelope.GetValueAtTime(const aTime:TKraftScalar):TKraftScalar;
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

{ TKraftRayCastVehicle.TRescueForce }

constructor TKraftRayCastVehicle.TRescueForce.Create;
begin
 inherited Create;
 Clear;
end;

destructor TKraftRayCastVehicle.TRescueForce.Destroy;
begin
 inherited Destroy;
end;

procedure TKraftRayCastVehicle.TRescueForce.Clear;
begin
 fEnabled:=false;
 fBelowSpeedThreshold:=1.0;
 fBelowSpeedTimeDuration:=1.0;
 fForce:=100.0;
 fUntilSpeed:=5.0;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TRescueForce.LoadFromJSON(const aJSONItem:TPasJSONItem);
var RootJSONItemObject:TPasJSONItemObject;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  RootJSONItemObject:=TPasJSONItemObject(aJSONItem);
  fEnabled:=TPasJSON.GetBoolean(RootJSONItemObject.Properties['enabled'],fEnabled);
  fBelowSpeedThreshold:=TPasJSON.GetNumber(RootJSONItemObject.Properties['belowspeedthreshold'],fBelowSpeedThreshold);
  fBelowSpeedTimeDuration:=TPasJSON.GetNumber(RootJSONItemObject.Properties['belowspeedtimeduration'],fBelowSpeedTimeDuration);
  fForce:=TPasJSON.GetNumber(RootJSONItemObject.Properties['force'],fForce);
  fUntilSpeed:=TPasJSON.GetNumber(RootJSONItemObject.Properties['untilspeed'],fUntilSpeed);
 end;
end;

function TKraftRayCastVehicle.TRescueForce.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('enabled',TPasJSONItemBoolean.Create(fEnabled));
 TPasJSONItemObject(result).Add('belowspeedthreshold',TPasJSONItemNumber.Create(fBelowSpeedThreshold));
 TPasJSONItemObject(result).Add('belowspeedtimeduration',TPasJSONItemNumber.Create(fBelowSpeedTimeDuration));
 TPasJSONItemObject(result).Add('force',TPasJSONItemNumber.Create(fForce));
 TPasJSONItemObject(result).Add('untilspeed',TPasJSONItemNumber.Create(fUntilSpeed));
end;
{$endif}

{ TKraftRayCastVehicle.TRescueForceState }

procedure TKraftRayCastVehicle.TRescueForceState.Reset;
begin
 fTimeUnderBelowSpeedThreshold:=0.0;
end;

// Returns the override force if the vehicle is below the speed threshold for the specified time duration in case the vehicle is stuck or similar.
function TKraftRayCastVehicle.TRescueForceState.GetOverrideForce(const aRescueForce:TKraftRayCastVehicle.TRescueForce;const aAbsoluteSpeedKMH,aOriginalForce:TKraftScalar;const aDeltaTime:TKraftDouble):TKraftScalar;
var NextTimeUnderBelowSpeedThreshold:TKraftScalar;
begin
  if aRescueForce.fEnabled and (aAbsoluteSpeedKMH<aRescueForce.fBelowSpeedThreshold) then begin
  NextTimeUnderBelowSpeedThreshold:=fTimeUnderBelowSpeedThreshold+aDeltaTime;
  fTimeUnderBelowSpeedThreshold:=Min(NextTimeUnderBelowSpeedThreshold,aRescueForce.fBelowSpeedTimeDuration);
  if (NextTimeUnderBelowSpeedThreshold>=aRescueForce.fBelowSpeedTimeDuration) and
     (aAbsoluteSpeedKMH<=aRescueForce.fUntilSpeed) then begin
   result:=aRescueForce.fForce;
  end else begin
   result:=aOriginalForce;
  end;
 end else begin
  fTimeUnderBelowSpeedThreshold:=0.0;
  result:=aOriginalForce;
 end;
end;

{ TKraftRayCastVehicle.TSuspensionSpringMath }

// Calculates the force which wants to restore the suspension spring to its rest length.
class function TKraftRayCastVehicle.TSuspensionSpringMath.CalculateForce(const aCurrentLength,aRestLength,aStrength:TKraftScalar):TKraftScalar;
begin
 result:=(aRestLength-aCurrentLength)*aStrength;
end;

// Combines the force which wants to restore the suspension spring to its rest length with the force which wants to damp the suspension spring's motion.
class function TKraftRayCastVehicle.TSuspensionSpringMath.CalculateForceDamped(const aCurrentLength,aLengthVelocity,aRestLength,aStrength,aDamper:TKraftScalar):TKraftScalar;
begin
 result:=((aRestLength-aCurrentLength)*aStrength)-(aLengthVelocity*aDamper);
end;

{ TKraftRayCastVehicle.TSettings.TWheel.TVisual }

constructor TKraftRayCastVehicle.TSettings.TWheel.TVisual.Create(const aWheel:TKraftRaycastVehicle.TSettings.TWheel);
begin
 inherited Create;
 fWheel:=aWheel;
 fModelNode:='';
 fRotationAxisMappingX:=0;
 fRotationAxisMappingY:=1;
 fRotationAxisMappingZ:=2;
 fRotationFactors:=Vector3(1.0,1.0,1.0);
 fHeightOffset:=0.0;
end;

destructor TKraftRayCastVehicle.TSettings.TWheel.TVisual.Destroy;
begin
 inherited Destroy;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TSettings.TWheel.TVisual.LoadFromJSON(const aJSONItem:TPasJSONItem);
var RotationAxisMapping:TKraftVector3;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fModelNode:=TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['modelnode'],fModelNode);
  RotationAxisMapping:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['rotationaxismapping'],Vector3(fRotationAxisMappingX,fRotationAxisMappingY,fRotationAxisMappingZ));
  fRotationAxisMappingX:=round(RotationAxisMapping.x);
  fRotationAxisMappingY:=round(RotationAxisMapping.y);
  fRotationAxisMappingZ:=round(RotationAxisMapping.z);
  fRotationFactors:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['rotationfactors'],fRotationFactors);
  fHeightOffset:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['heightoffset'],fHeightOffset);
  fRadius:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['radius'],fRadius);
 end;
end;

function TKraftRayCastVehicle.TSettings.TWheel.TVisual.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('modelnode',TPasJSONItemString.Create(fModelNode));
 TPasJSONItemObject(result).Add('rotationaxismapping',Vector3ToJSON(Vector3(fRotationAxisMappingX,fRotationAxisMappingY,fRotationAxisMappingZ)));
 TPasJSONItemObject(result).Add('rotationfactors',Vector3ToJSON(fRotationFactors));
 TPasJSONItemObject(result).Add('heightoffset',TPasJSONItemNumber.Create(fHeightOffset));
 TPasJSONItemObject(result).Add('radius',TPasJSONItemNumber.Create(fRadius));
end;
{$endif}

{ TKraftRayCastVehicle.TSettings.TWheel }

constructor TKraftRayCastVehicle.TSettings.TWheel.Create(const aSettings:TSettings);
begin
 inherited Create;
 fSettings:=aSettings;
 fName:='';
 fVisual:=TKraftRayCastVehicle.TSettings.TWheel.TVisual.Create(self);
end;

destructor TKraftRayCastVehicle.TSettings.TWheel.Destroy;
begin
 FreeAndNil(fVisual);
 inherited Destroy;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TSettings.TWheel.LoadFromJSON(const aJSONItem:TPasJSONItem);
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fName:=TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['name'],fName);
  fPosition:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['position'],fPosition);
  fRadius:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['radius'],fRadius);
  fLength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['length'],fLength);
  fUseSphereCast:=TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['castmode'],'raycast')='spherecast';
  fPowered:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['powered'],fPowered);
  fSteering:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['steering'],fSteering);
  fMass:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['mass'],fMass);
  fSuspensionClamping:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['suspensionclamping'],fSuspensionClamping);
  fSuspensionRestLength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensionrestlength'],fSuspensionRestLength);
  fSuspensionStrength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensionstrength'],fSuspensionStrength);
  fSuspensionDamping:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensiondamping'],fSuspensionDamping);
  fSuspensionRelaxRate:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['suspensionrelaxrate'],fSuspensionRelaxRate);
  fAccelerationForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['accelerationforcefactor'],fAccelerationForceFactor);
  fBrakeForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['brakeforcefactor'],fBrakeForceFactor);
  fRollingFriction:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rollingfriction'],fRollingFriction);
  fMaximumSpeed:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maximumspeed'],fMaximumSpeed);
  fMaximumReverseSpeed:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maximumreversespeed'],fMaximumReverseSpeed);
  fGripFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['gripfactor'],fGripFactor);
  fAfterFlightSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['afterflightslipperyk'],fAfterFlightSlipperyK);
  fBrakeSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['brakeslipperyk'],fBrakeSlipperyK);
  fHandBrakeSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['handbrakeslipperyk'],fHandBrakeSlipperyK);
  fDriftSlipperyK:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['driftslipperyk'],fDriftSlipperyK);
  fVisual.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['visual']);
 end;
end;

function TKraftRayCastVehicle.TSettings.TWheel.SaveToJSON:TPasJSONItem;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('name',TPasJSONItemString.Create(fName));
 TPasJSONItemObject(result).Add('position',Vector3ToJSON(fPosition));
 TPasJSONItemObject(result).Add('radius',TPasJSONItemNumber.Create(fRadius));
 TPasJSONItemObject(result).Add('length',TPasJSONItemNumber.Create(fLength));
 if fUseSphereCast then begin
  TPasJSONItemObject(result).Add('castmode',TPasJSONItemString.Create('spherecast'));
 end else begin
  TPasJSONItemObject(result).Add('castmode',TPasJSONItemString.Create('raycast'));
 end;
 TPasJSONItemObject(result).Add('powered',TPasJSONItemBoolean.Create(fPowered));
 TPasJSONItemObject(result).Add('steering',TPasJSONItemBoolean.Create(fSteering));
 TPasJSONItemObject(result).Add('mass',TPasJSONItemNumber.Create(fMass));
 TPasJSONItemObject(result).Add('suspensionclamping',TPasJSONItemBoolean.Create(fSuspensionClamping));
 TPasJSONItemObject(result).Add('suspensionrestlength',TPasJSONItemNumber.Create(fSuspensionRestLength));
 TPasJSONItemObject(result).Add('suspensionstrength',TPasJSONItemNumber.Create(fSuspensionStrength));
 TPasJSONItemObject(result).Add('suspensiondamping',TPasJSONItemNumber.Create(fSuspensionDamping));
 TPasJSONItemObject(result).Add('suspensionrelaxrate',TPasJSONItemNumber.Create(fSuspensionRelaxRate));
 TPasJSONItemObject(result).Add('accelerationforcefactor',TPasJSONItemNumber.Create(fAccelerationForceFactor));
 TPasJSONItemObject(result).Add('brakeforcefactor',TPasJSONItemNumber.Create(fBrakeForceFactor));
 TPasJSONItemObject(result).Add('rollingfriction',TPasJSONItemNumber.Create(fRollingFriction));
 TPasJSONItemObject(result).Add('maximumspeed',TPasJSONItemNumber.Create(fMaximumSpeed));
 TPasJSONItemObject(result).Add('maximumreversespeed',TPasJSONItemNumber.Create(fMaximumReverseSpeed));
 TPasJSONItemObject(result).Add('gripfactor',TPasJSONItemNumber.Create(fGripFactor));
 TPasJSONItemObject(result).Add('afterflightslipperyk',TPasJSONItemNumber.Create(fAfterFlightSlipperyK));
 TPasJSONItemObject(result).Add('brakeslipperyk',TPasJSONItemNumber.Create(fBrakeSlipperyK));
 TPasJSONItemObject(result).Add('handbrakeslipperyk',TPasJSONItemNumber.Create(fHandBrakeSlipperyK));
 TPasJSONItemObject(result).Add('driftslipperyk',TPasJSONItemNumber.Create(fDriftSlipperyK));
 TPasJSONItemObject(result).Add('visual',fVisual.SaveToJSON);
end;
{$endif}

{ TKraftRayCastVehicle.TSettings.TAxle }

constructor TKraftRayCastVehicle.TSettings.TAxle.Create(const aSettings:TSettings);
begin
 inherited Create;
 fSettings:=aSettings;
 fName:='';
 fWheels:=TWheels.Create(false);
end;

destructor TKraftRayCastVehicle.TSettings.TAxle.Destroy;
begin
 FreeAndNil(fWheels);
 inherited Destroy;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TSettings.TAxle.LoadFromJSON(const aJSONItem:TPasJSONItem);
var Index,OtherIndex:TKraftSizeInt;
    JSONItemArray:TPasJSONItemArray;
    JSONItem:TPasJSONItem;
    WheelName:UTF8String;
    Wheel:TWheel;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fWheels.Clear;
  fName:=TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['name'],fName);
  fStabilizerBarAntiRollForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['stabilizerbarantirollforcefactor'],fStabilizerBarAntiRollForceFactor);
  JSONItem:=TPasJSONItemObject(aJSONItem).Properties['wheels'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
   JSONItemArray:=TPasJSONItemArray(JSONItem);
   for Index:=0 to JSONItemArray.Count-1 do begin
    JSONItem:=JSONItemArray.Items[Index];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemString) then begin
     WheelName:=Trim(LowerCase(TPasJSONItemString(JSONItem).Value));
     for OtherIndex:=0 to fSettings.fWheels.Count-1 do begin
      Wheel:=fSettings.fWheels[OtherIndex];
      if Trim(LowerCase(Wheel.fName))=WheelName then begin
       fWheels.Add(Wheel);
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function TKraftRayCastVehicle.TSettings.TAxle.SaveToJSON:TPasJSONItem;
var Index:TPasJSONSizeInt;
    JSONItemArray:TPasJSONItemArray;
    Wheel:TWheel;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('name',TPasJSONItemString.Create(fName));
 TPasJSONItemObject(result).Add('stabilizerbarantirollforcefactor',TPasJSONItemNumber.Create(fStabilizerBarAntiRollForceFactor));
 JSONItemArray:=TPasJSONItemArray.Create;
 try
  for Index:=0 to fWheels.Count-1 do begin
   Wheel:=fWheels[Index];
   if assigned(Wheel) then begin
    JSONItemArray.Add(TPasJSONItemString.Create(Wheel.fName));
   end;
  end;
 finally
  TPasJSONItemObject(result).Add('wheels',JSONItemArray);
 end;
end;
{$endif}

{ TKraftRayCastVehicle.TSettings.TAckermannGroup }

constructor TKraftRayCastVehicle.TSettings.TAckermannGroup.Create(const aSettings:TSettings);
begin
 inherited Create;
 fSettings:=aSettings;
 fName:='';
 fAxles:=TAxles.Create(false);
end;

destructor TKraftRayCastVehicle.TSettings.TAckermannGroup.Destroy;
begin
 FreeAndNil(fAxles);
 inherited Destroy;
end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TSettings.TAckermannGroup.LoadFromJSON(const aJSONItem:TPasJSONItem);
var Index,OtherIndex:TPasJSONSizeInt;
    JSONItemArray:TPasJSONItemArray;
    JSONItem:TPasJSONItem;
    AxleName:UTF8String;
    Axle:TAxle;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  fAxles.Clear;
  fName:=TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['name'],fName);
  JSONItem:=TPasJSONItemObject(aJSONItem).Properties['axles'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
   JSONItemArray:=TPasJSONItemArray(JSONItem);
   for Index:=0 to JSONItemArray.Count-1 do begin
    JSONItem:=JSONItemArray.Items[Index];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemString) then begin
     AxleName:=Trim(LowerCase(TPasJSONItemString(JSONItem).Value));
     for OtherIndex:=0 to fSettings.fAxles.Count-1 do begin
      Axle:=fSettings.fAxles[OtherIndex];
      if Trim(LowerCase(Axle.fName))=AxleName then begin
       fAxles.Add(Axle);
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function TKraftRayCastVehicle.TSettings.TAckermannGroup.SaveToJSON:TPasJSONItem;
var Index:TPasJSONSizeInt;
    JSONItemArray:TPasJSONItemArray;
    Axle:TAxle;
begin
 result:=TPasJSONItemObject.Create;
 TPasJSONItemObject(result).Add('name',TPasJSONItemString.Create(fName));
 JSONItemArray:=TPasJSONItemArray.Create;
 try
  for Index:=0 to fAxles.Count-1 do begin
   Axle:=fAxles[Index];
   if assigned(Axle) then begin
    JSONItemArray.Add(TPasJSONItemString.Create(Axle.fName));
   end;
  end;
 finally
  TPasJSONItemObject(result).Add('axles',JSONItemArray);
 end;
end;

{$endif}

{ TKraftRayCastVehicle.TSettings }

constructor TKraftRayCastVehicle.TSettings.Create;
begin
 inherited Create;

 fSuspensionMode:=TKraftRayCastVehicle.TSuspensionMode.Realistic;

 fWidth:=1.451598048210144;
 fHeight:=1.223848819732666;
 fLength:=2.0949294567108154;

 fAngularVelocityDamp:=10.0;
 fLinearVelocityDamp:=0.3275;

 fRigidBodyRestitution:=0.3;
 fRigidBodyRestitutionThreshold:=-1.0;
 fRigidBodyDensity:=1.0;
 fRigidBodyFriction:=0.0;

 fShapeOffset:=Vector3(0.0,0.0,0.0);

 fVisualModelOffset:=Vector3(0.0,0.0,0.0);

 fCenterOfMass:=Vector3(0.0,0.0,0.24);

 fChassisMass:=60;

 fAirResistance:=5.0;

 fHandBrakeSlipperyTime:=2.2;

 fDriftSlipperyTime:=2.2;

 fAccelerationRescueForce:=TRescueForce.Create;

 fReverseAccelerationRescueForce:=TRescueForce.Create;

 fAccelerationCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,200.0);

 fReverseAccelerationCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,20.0);

 fCurveEvaluationAccuracy:=25;

 fBrakeCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,200.0);

 fReverseBrakeCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,5.0,200.0);

 fSteerAngleLimitEnvelope:=TEnvelope.CreateLinear(0.0,35.0,100.0,5.0);

 fSteeringResetSpeedEnvelope:=TEnvelope.CreateEaseInOut(0.0,30.0,100.0,10.0,64);

 fSteeringSpeedEnvelope:=TEnvelope.CreateLinear(0.0,200.0,100.0,50.0);

 fDriftAngleAccelerationFactorEnvelope:=TEnvelope.CreateLinear(1.0,1.0,90.0,1.0);

 fDriftSteerAngleLimitEnvelope:=TEnvelope.CreateLinear(0.0,35.0,100.0,5.0);

 fDriftSteeringResetSpeedEnvelope:=TEnvelope.CreateEaseInOut(0.0,30.0,100.0,10.0,64);

 fDriftSteeringSpeedEnvelope:=TEnvelope.CreateLinear(0.0,200.0,100.0,50.0);

 fGripFactorEnvelope:=TEnvelope.CreateLinear(0.0,1.0,100.0,1.0);

 fDrivingTractionFactorEnvelope:=TEnvelope.CreateLinear(10.0,0.0,50.0,1.0);

 fDownForceCurveEnvelope:=TEnvelope.CreateLinear(0.0,0.0,200.0,100.0);
 fDownForceFactor:=1.0;

 fJumpImpulse:=350.0;

 fDriftAfterJump:=false;

 fSuperJumpImpulse:=350.0;

 fDriftAfterSuperJump:=false;

 fFlightSteeringTorqueFactor:=20.0;

 fFlightSteeringTorqueFactorOnJump:=40.0;

 fFlightSteeringTorqueFactorOnSuperJump:=200.0;

 fFlightStabilizationAngularVelocityDamping:=Vector3(40.0,10.0,40.0);
 fFlightStabilizationDamping:=0.0;
 fFlightStabilizationForceFactor:=8.0;

 fKeepUprightThreshold:=0.9;
 fKeepUprightForceFactor:=0.0;

 fWheels:=TWheels.Create(true);

 fAxles:=TAxles.Create(true);

 fAckermannGroups:=TAckermannGroups.Create(true);

 LoadDefaultFourWheelsConfiguration;

end;

destructor TKraftRayCastVehicle.TSettings.Destroy;
begin
 FreeAndNil(fWheels);
 FreeAndNil(fAxles);
 FreeAndNil(fAckermannGroups);
 FreeAndNil(fAccelerationCurveEnvelope);
 FreeAndNil(fReverseAccelerationCurveEnvelope);
 FreeAndNil(fBrakeCurveEnvelope);
 FreeAndNil(fReverseBrakeCurveEnvelope);
 FreeAndNil(fSteerAngleLimitEnvelope);
 FreeAndNil(fSteeringResetSpeedEnvelope);
 FreeAndNil(fSteeringSpeedEnvelope);
 FreeAndNil(fDriftAngleAccelerationFactorEnvelope);
 FreeAndNil(fDriftSteerAngleLimitEnvelope);
 FreeAndNil(fDriftSteeringResetSpeedEnvelope);
 FreeAndNil(fDriftSteeringSpeedEnvelope);
 FreeAndNil(fGripFactorEnvelope);
 FreeAndNil(fDrivingTractionFactorEnvelope);
 FreeAndNil(fDownForceCurveEnvelope);
 inherited Destroy;
end;

procedure TKraftRayCastVehicle.TSettings.LoadDefaultFourWheelsConfiguration;
// This default configuration is for a car or kart with four wheels with two axles with a single ackermann group
var WheelFrontLeft,WheelFrontRight,WheelRearLeft,WheelRearRight:TKraftRayCastVehicle.TSettings.TWheel;
    AxleFront,AxleRear:TKraftRayCastVehicle.TSettings.TAxle;
    AckermannGroup:TKraftRayCastVehicle.TSettings.TAckermannGroup;
begin

 fSuspensionMode:=TKraftRayCastVehicle.TSuspensionMode.Realistic;

 // The rigid body physical dimensions as a box
 fWidth:=1.451598048210144;
 fHeight:=1.223848819732666;
 fLength:=2.0949294567108154;

 // The rigid body physical damping factors
 fAngularVelocityDamp:=10.0;
 fLinearVelocityDamp:=0.3275;

 // The rigid body physical properties
 fRigidBodyRestitution:=0.3;
 fRigidBodyRestitutionThreshold:=-1.0;
 fRigidBodyDensity:=1.0;
 fRigidBodyFriction:=0.0;

 // The shape offset
 fShapeOffset:=Vector3(0.0,0.0,0.0);

 // The rigid body visual model offset
 fVisualModelOffset:=Vector3(0.0,0.0,0.0);

 // The rigid body center of mass
 fCenterOfMass:=Vector3(0.0,0.0,0.24);

 // The chassis mass
 fChassisMass:=60.0;

 // Air resistance
 fAirResistance:=5.0;

 // Hand brake slippery time
 fHandBrakeSlipperyTime:=2.2;

 // Drift slippery time
 fDriftSlipperyTime:=2.2;

 // The maximum gravity slope angle
 fMaximumGravitySlopeAngle:=10.0; // 10 degrees should be enough for most cases

 // The maximum speed in km/h
 fMaximumSpeed:=80.0;
 fMaximumReverseSpeed:=18.0;

 // The acceleration minimum force
 fAccelerationMinimumForce:=0.0;

 // The reverse acceleration minimum force
 fReverseAccelerationMinimumForce:=0.0;

 // The curve evaluation accuracy
 fCurveEvaluationAccuracy:=25;

 // The acceleration rescue force
 fAccelerationRescueForce.Clear;

 // The reverse acceleration rescue force
 fReverseAccelerationRescueForce.Clear;

 // The acceleration curve envelope
 fAccelerationCurveEnvelope.FillLinear(0.0,0.0,5.0,200.0);

 // The reverse acceleration curve envelope
 fReverseAccelerationCurveEnvelope.FillLinear(0.0,0.0,5.0,50.0);

 // The brake curve envelope
 fBrakeCurveEnvelope.FillLinear(0.0,0.0,5.0,200.0);

 // The reverse brake curve envelope
 fReverseBrakeCurveEnvelope.FillLinear(0.0,0.0,5.0,200.0);

 // The steering angle limit envelope
 fSteerAngleLimitEnvelope.FillLinear(0.0,35.0,100.0,5.0);

 // The steering reset speed envelope
 fSteeringResetSpeedEnvelope.FillEaseInOut(0.0,30.0,100.0,10.0,64);

 // The steering speed envelope
 fSteeringSpeedEnvelope.FillLinear(0.0,200.0,100.0,50.0);

 // The drift angle acceleration factor envelope
 fDriftAngleAccelerationFactorEnvelope.FillLinear(1.0,1.0,90.0,1.0);

 // The drift steering angle limit envelope
 fDriftSteerAngleLimitEnvelope.FillLinear(0.0,35.0,100.0,5.0);

 // The drift steering reset speed envelope
 fDriftSteeringResetSpeedEnvelope.FillEaseInOut(0.0,30.0,100.0,10.0,64);

 // The drift steering speed envelope
 fDriftSteeringSpeedEnvelope.FillLinear(0.0,200.0,100.0,50.0);

 // The grip envelope
 fGripFactorEnvelope.FillLinear(0.0,1.0,100.0,1.0);

 // The driving traction factor envelope
 fDrivingTractionFactorEnvelope.FillLinear(10.0,0.0,50.0,1.0);

 // The down force curve envelope and settings
 fDownForceCurveEnvelope.FillLinear(0.0,0.0,200.0,100.0);
 fDownForceFactor:=1.0;

 // The jump impulse
 fJumpImpulse:=350.0;

 // The DriftAfterJump
 fDriftAfterJump:=false;

 // The super jump impulse
 fSuperJumpImpulse:=350.0;

 // The DriftAfterSuperJump
 fDriftAfterSuperJump:=false;

 // The flight sterring torque factor
 fFlightSteeringTorqueFactor:=20.0;

 // The flight sterring torque factor on jump
 fFlightSteeringTorqueFactorOnJump:=40.0;

 // The flight sterring torque factor on super jump
 fFlightSteeringTorqueFactorOnSuperJump:=200.0;

 // The flight stabilization settings
 fFlightStabilizationAngularVelocityDamping:=Vector3(40.0,10.0,40.0);
 fFlightStabilizationDamping:=0.0;
 fFlightStabilizationForceFactor:=8.0;

 // The keep upright force
 fKeepUprightThreshold:=0.9;
 fKeepUprightForceFactor:=0.0;

 // The wheels
 begin

  fWheels.Clear;

  WheelFrontLeft:=TKraftRayCastVehicle.TSettings.TWheel.Create(self);
  try
   WheelFrontLeft.fName:='frontleft';
   WheelFrontLeft.fPosition:=Vector3(-0.63870317,-0.25,0.8170225);
   WheelFrontLeft.fRadius:=0.25;
   WheelFrontLeft.fLength:=0.25;
   WheelFrontLeft.fUseSphereCast:=true;
   WheelFrontLeft.fPowered:=true;
   WheelFrontLeft.fSteering:=true;
   WheelFrontLeft.fMass:=1.0;
   WheelFrontLeft.fSuspensionClamping:=false;
   WheelFrontLeft.fSuspensionRestLength:=0.8;
   WheelFrontLeft.fSuspensionStrength:=20.0;
   WheelFrontLeft.fSuspensionDamping:=1.25;
   WheelFrontLeft.fSuspensionRelaxRate:=0.4;
   WheelFrontLeft.fAccelerationForceFactor:=0.25;
   WheelFrontLeft.fBrakeForceFactor:=0.25;
   WheelFrontLeft.fRollingFriction:=0.15;
   WheelFrontLeft.fMaximumSpeed:=0.0;
   WheelFrontLeft.fMaximumReverseSpeed:=0.0;
   WheelFrontLeft.fGripFactor:=0.8;
   WheelFrontLeft.fAfterFlightSlipperyK:=0.02;
   WheelFrontLeft.fBrakeSlipperyK:=0.5;
   WheelFrontLeft.fHandBrakeSlipperyK:=0.01;
   WheelFrontLeft.fDriftSlipperyK:=0.01;
  finally
   fWheels.Add(WheelFrontLeft);
  end;

  WheelFrontRight:=TKraftRayCastVehicle.TSettings.TWheel.Create(self);
  try
   WheelFrontRight.fName:='frontright';
   WheelFrontRight.fPosition:=Vector3(0.63870317,-0.25,0.8170225);
   WheelFrontRight.fRadius:=0.25;
   WheelFrontRight.fLength:=0.25;
   WheelFrontRight.fUseSphereCast:=true;
   WheelFrontRight.fPowered:=true;
   WheelFrontRight.fSteering:=true;
   WheelFrontRight.fMass:=1.0;
   WheelFrontRight.fSuspensionClamping:=false;
   WheelFrontRight.fSuspensionRestLength:=0.8;
   WheelFrontRight.fSuspensionStrength:=20.0;
   WheelFrontRight.fSuspensionDamping:=1.25;
   WheelFrontRight.fSuspensionRelaxRate:=0.4;
   WheelFrontRight.fAccelerationForceFactor:=0.25;
   WheelFrontRight.fBrakeForceFactor:=0.25;
   WheelFrontRight.fRollingFriction:=0.15;
   WheelFrontRight.fMaximumSpeed:=0.0;
   WheelFrontRight.fMaximumReverseSpeed:=0.0;
   WheelFrontRight.fGripFactor:=0.8;
   WheelFrontRight.fAfterFlightSlipperyK:=0.02;
   WheelFrontRight.fBrakeSlipperyK:=0.5;
   WheelFrontRight.fHandBrakeSlipperyK:=0.01;
   WheelFrontRight.fDriftSlipperyK:=0.01;
  finally
   fWheels.Add(WheelFrontRight);
  end;

  WheelRearLeft:=TKraftRayCastVehicle.TSettings.TWheel.Create(self);
  try
   WheelRearLeft.fName:='rearleft';
   WheelRearLeft.fPosition:=Vector3(-0.63870317,-0.25,-0.42946056);
   WheelRearLeft.fRadius:=0.25;
   WheelRearLeft.fLength:=0.25;
   WheelRearLeft.fUseSphereCast:=true;
   WheelRearLeft.fPowered:=true;
   WheelRearLeft.fSteering:=false;
   WheelRearLeft.fMass:=1.0;
   WheelRearLeft.fSuspensionClamping:=false;
   WheelRearLeft.fSuspensionRestLength:=0.8;
   WheelRearLeft.fSuspensionStrength:=20.0;
   WheelRearLeft.fSuspensionDamping:=1.25;
   WheelRearLeft.fSuspensionRelaxRate:=0.4;
   WheelRearLeft.fAccelerationForceFactor:=0.25;
   WheelRearLeft.fBrakeForceFactor:=0.25;
   WheelRearLeft.fRollingFriction:=0.15;
   WheelRearLeft.fMaximumSpeed:=0.0;
   WheelRearLeft.fMaximumReverseSpeed:=0.0;
   WheelRearLeft.fGripFactor:=0.9;
   WheelRearLeft.fAfterFlightSlipperyK:=0.02;
   WheelRearLeft.fBrakeSlipperyK:=0.5;
   WheelRearLeft.fHandBrakeSlipperyK:=0.01;
   WheelRearLeft.fDriftSlipperyK:=0.01;
  finally
   fWheels.Add(WheelRearLeft);
  end;

  WheelRearRight:=TKraftRayCastVehicle.TSettings.TWheel.Create(self);
  try
   WheelRearRight.fName:='rearright';
   WheelRearRight.fPosition:=Vector3(0.63870317,-0.25,-0.42946056);
   WheelRearRight.fRadius:=0.25;
   WheelRearRight.fLength:=0.25;
   WheelRearRight.fUseSphereCast:=true;
   WheelRearRight.fPowered:=true;
   WheelRearRight.fSteering:=false;
   WheelRearRight.fMass:=1.0;
   WheelRearRight.fSuspensionClamping:=false;
   WheelRearRight.fSuspensionRestLength:=0.8;
   WheelRearRight.fSuspensionStrength:=20.0;
   WheelRearRight.fSuspensionDamping:=1.25;
   WheelRearRight.fSuspensionRelaxRate:=0.4;
   WheelRearRight.fAccelerationForceFactor:=0.25;
   WheelRearRight.fBrakeForceFactor:=0.25;
   WheelRearRight.fRollingFriction:=0.15;
   WheelRearRight.fMaximumSpeed:=0.0;
   WheelRearRight.fMaximumReverseSpeed:=0.0;
   WheelRearRight.fGripFactor:=0.9;
   WheelRearRight.fAfterFlightSlipperyK:=0.02;
   WheelRearRight.fBrakeSlipperyK:=0.5;
   WheelRearRight.fHandBrakeSlipperyK:=0.01;
   WheelRearRight.fDriftSlipperyK:=0.01;
  finally
   fWheels.Add(WheelRearRight);
  end;

 end;

 // The axles
 begin

  fAxles.Clear;

  AxleFront:=TKraftRayCastVehicle.TSettings.TAxle.Create(self);
  try
   AxleFront.fName:='front';
   AxleFront.fWheels.Add(WheelFrontLeft);
   AxleFront.fWheels.Add(WheelFrontRight);
   AxleFront.fStabilizerBarAntiRollForceFactor:=1.5;
  finally
   fAxles.Add(AxleFront);
  end;

  AxleRear:=TKraftRayCastVehicle.TSettings.TAxle.Create(self);
  try
   AxleRear.fName:='rear';
   AxleRear.fWheels.Add(WheelRearLeft);
   AxleRear.fWheels.Add(WheelRearRight);
   AxleRear.fStabilizerBarAntiRollForceFactor:=1.5;
  finally
   fAxles.Add(AxleRear);
  end;

 end;

 // The ackermann groups
 begin

  fAckermannGroups.Clear;

  AckermannGroup:=TKraftRayCastVehicle.TSettings.TAckermannGroup.Create(self);
  try
   AckermannGroup.fName:='frontrear';
   AckermannGroup.fAxles.Add(AxleFront);
   AckermannGroup.fAxles.Add(AxleRear);
  finally
   fAckermannGroups.Add(AckermannGroup);
  end;

 end;

end;

{$ifdef KraftPasJSON}
procedure TKraftRayCastVehicle.TSettings.LoadFromJSON(const aJSONItem:TPasJSONItem);
var JSONItem,OtherJSONItem:TPasJSONItem;
    Index:TPasJSONSizeInt;
    Wheel:TKraftRayCastVehicle.TSettings.TWheel;
    Axle:TKraftRayCastVehicle.TSettings.TAxle;
    AckermannGroup:TKraftRayCastVehicle.TSettings.TAckermannGroup;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin

  if TPasJSON.GetString(TPasJSONItemObject(aJSONItem).Properties['suspensionmode'],'realistic')='arcade' then begin
   fSuspensionMode:=TKraftRayCastVehicle.TSuspensionMode.Arcade;
  end else begin
   fSuspensionMode:=TKraftRayCastVehicle.TSuspensionMode.Realistic;
  end;

  fWidth:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['width'],fWidth);
  fHeight:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['height'],fHeight);
  fLength:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['length'],fLength);

  fAngularVelocityDamp:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['angularvelocitydamp'],fAngularVelocityDamp);
  fLinearVelocityDamp:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['linearvelocitydamp'],fLinearVelocityDamp);

  fRigidBodyRestitution:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rigidbodyrestitution'],fRigidBodyRestitution);
  fRigidBodyRestitutionThreshold:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rigidbodyrestitutionthreshold'],fRigidBodyRestitutionThreshold);
  fRigidBodyDensity:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rigidbodydensity'],fRigidBodyDensity);
  fRigidBodyFriction:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['rigidbodyfriction'],fRigidBodyFriction);

  fShapeOffset:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['shapeoffset'],fShapeOffset);

  fVisualModelOffset:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['visualmodeloffset'],fVisualModelOffset);

  fCenterOfMass:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['centerofmass'],fCenterOfMass);

  fChassisMass:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['chassismass'],fChassisMass);

  fAirResistance:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['airresistance'],fAirResistance);

  fHandBrakeSlipperyTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['handbrakeslipperytime'],fHandBrakeSlipperyTime);

  fDriftSlipperyTime:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['driftslipperytime'],fDriftSlipperyTime);

  fMaximumGravitySlopeAngle:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maximumgravityslopeangle'],fMaximumGravitySlopeAngle);

  fMaximumSpeed:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maximumspeed'],fMaximumSpeed);

  fMaximumReverseSpeed:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['maximumreversespeed'],fMaximumReverseSpeed);

  fAccelerationMinimumForce:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['accelerationminimumforce'],fAccelerationMinimumForce);

  fReverseAccelerationMinimumForce:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['reverseaccelerationminimumforce'],fReverseAccelerationMinimumForce);

  fCurveEvaluationAccuracy:=TPasJSON.GetInt64(TPasJSONItemObject(aJSONItem).Properties['curveevaluationaccuracy'],fCurveEvaluationAccuracy);

  fAccelerationRescueForce.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['accelerationrescueforce']);

  fReverseAccelerationRescueForce.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['reverseaccelerationrescueforce']);

  fAccelerationCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['accelerationcurveenvelope']);

  fReverseAccelerationCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['reverseaccelerationcurveenvelope']);

  fBrakeCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['brakecurveenvelope']);

  fReverseBrakeCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['reversebrakecurveenvelope']);

  fSteerAngleLimitEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeranglelimitenvelope']);

  fSteeringResetSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeringresetspeedenvelope']);

  fSteeringSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['steeringspeedenvelope']);

  fDriftAngleAccelerationFactorEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['driftangleaccelerationfactorenvelope']);

  fDriftSteerAngleLimitEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['driftsteeranglelimitenvelope']);

  fDriftSteeringResetSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['driftsteeringresetspeedenvelope']);

  fDriftSteeringSpeedEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['driftsteeringspeedenvelope']);

  fGripFactorEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['gripfactorenvelope']);

  fDrivingTractionFactorEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['drivingtractionfactorenvelope']);

  fDownForceCurveEnvelope.LoadFromJSON(TPasJSONItemObject(aJSONItem).Properties['downforcecurveenvelope']);
  fDownForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['downforcefactor'],fDownForceFactor);

  fJumpImpulse:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['jumpimpulse'],fJumpImpulse);

  fDriftAfterJump:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['driftafterjump'],fDriftAfterJump);

  fSuperJumpImpulse:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['superjumpimpulse'],fSuperJumpImpulse);

  fDriftAfterSuperJump:=TPasJSON.GetBoolean(TPasJSONItemObject(aJSONItem).Properties['driftaftersuperjump'],fDriftAfterSuperJump);

  fFlightSteeringTorqueFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightsteeringtorquefactor'],fFlightSteeringTorqueFactor);

  fFlightSteeringTorqueFactorOnJump:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightsteeringtorquefactoronjump'],fFlightSteeringTorqueFactorOnJump);

  fFlightSteeringTorqueFactorOnSuperJump:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightsteeringtorquefactoronsuperjump'],fFlightSteeringTorqueFactorOnSuperJump);

  fFlightStabilizationAngularVelocityDamping:=JSONToVector3(TPasJSONItemObject(aJSONItem).Properties['flightstabilizationangularvelocitydamping'],fFlightStabilizationAngularVelocityDamping);
  fFlightStabilizationDamping:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightstabilizationdamping'],fFlightStabilizationDamping);
  fFlightStabilizationForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['flightstabilizationforcefactor'],fFlightStabilizationForceFactor);

  fKeepUprightThreshold:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['keepuprightthreshold'],KeepUprightThreshold);
  fKeepUprightForceFactor:=TPasJSON.GetNumber(TPasJSONItemObject(aJSONItem).Properties['keepuprightforcefactor'],KeepUprightForce);

  fWheels.Clear;
  JSONItem:=TPasJSONItemObject(aJSONItem).Properties['wheels'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
   for Index:=0 to TPasJSONItemObject(JSONItem).Count-1 do begin
    OtherJSONItem:=TPasJSONItemObject(JSONItem).Values[Index];
    if assigned(OtherJSONItem) and (OtherJSONItem is TPasJSONItemObject) then begin
     Wheel:=TKraftRayCastVehicle.TSettings.TWheel.Create(self);
     try
      Wheel.fName:=TPasJSONItemObject(JSONItem).Keys[Index];
      Wheel.LoadFromJSON(OtherJSONItem);
      fWheels.Add(Wheel);
     except
      FreeAndNil(Wheel);
      raise;
     end;
    end;
   end;
  end;

  fAxles.Clear;
  JSONItem:=TPasJSONItemObject(aJSONItem).Properties['axles'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
   for Index:=0 to TPasJSONItemObject(JSONItem).Count-1 do begin
    OtherJSONItem:=TPasJSONItemObject(JSONItem).Values[Index];
    if assigned(OtherJSONItem) and (OtherJSONItem is TPasJSONItemObject) then begin
     Axle:=TKraftRayCastVehicle.TSettings.TAxle.Create(self);
     try
      Axle.fName:=TPasJSONItemObject(JSONItem).Keys[Index];
      Axle.LoadFromJSON(OtherJSONItem);
      fAxles.Add(Axle);
     except
      FreeAndNil(Axle);
      raise;
     end;
    end;
   end;
  end;

  fAckermannGroups.Clear;
  JSONItem:=TPasJSONItemObject(aJSONItem).Properties['ackermanngroups'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
   for Index:=0 to TPasJSONItemObject(JSONItem).Count-1 do begin
    OtherJSONItem:=TPasJSONItemObject(JSONItem).Values[Index];
    if assigned(OtherJSONItem) and (OtherJSONItem is TPasJSONItemObject) then begin
     AckermannGroup:=TKraftRayCastVehicle.TSettings.TAckermannGroup.Create(self);
     try
      AckermannGroup.fName:=TPasJSONItemObject(JSONItem).Keys[Index];
      AckermannGroup.LoadFromJSON(OtherJSONItem);
      fAckermannGroups.Add(AckermannGroup);
     except
      FreeAndNil(AckermannGroup);
      raise;
     end;
    end;
   end;
  end;

 end;
end;

function TKraftRayCastVehicle.TSettings.SaveToJSON:TPasJSONItem;
var Index:TPasJSONSizeInt;
    Wheel:TKraftRayCastVehicle.TSettings.TWheel;
    Axle:TKraftRayCastVehicle.TSettings.TAxle;
    AckermannGroup:TKraftRayCastVehicle.TSettings.TAckermannGroup;
    JSONItem,SubJSONItem:TPasJSONItem;
begin

 result:=TPasJSONItemObject.Create;

 case fSuspensionMode of
  TKraftRayCastVehicle.TSuspensionMode.Arcade:begin
   TPasJSONItemObject(result).Add('suspensionmode',TPasJSONItemString.Create('arcade'));
  end;
  else begin
   TPasJSONItemObject(result).Add('suspensionmode',TPasJSONItemString.Create('realistic'));
  end;
 end;

 TPasJSONItemObject(result).Add('width',TPasJSONItemNumber.Create(fWidth));

 TPasJSONItemObject(result).Add('height',TPasJSONItemNumber.Create(fHeight));

 TPasJSONItemObject(result).Add('length',TPasJSONItemNumber.Create(fLength));

 TPasJSONItemObject(result).Add('angularvelocitydamp',TPasJSONItemNumber.Create(fAngularVelocityDamp));

 TPasJSONItemObject(result).Add('linearvelocitydamp',TPasJSONItemNumber.Create(fLinearVelocityDamp));

 TPasJSONItemObject(result).Add('rigidbodyrestitution',TPasJSONItemNumber.Create(fRigidBodyRestitution));

 TPasJSONItemObject(result).Add('rigidbodyrestitutionthreshold',TPasJSONItemNumber.Create(fRigidBodyRestitutionThreshold));

 TPasJSONItemObject(result).Add('rigidbodydensity',TPasJSONItemNumber.Create(fRigidBodyDensity));

 TPasJSONItemObject(result).Add('rigidbodyfriction',TPasJSONItemNumber.Create(fRigidBodyFriction));

 TPasJSONItemObject(result).Add('shapeoffset',Vector3ToJSON(fShapeOffset));

 TPasJSONItemObject(result).Add('visualmodeloffset',Vector3ToJSON(fVisualModelOffset));

 TPasJSONItemObject(result).Add('centerofmass',Vector3ToJSON(fCenterOfMass));

 TPasJSONItemObject(result).Add('chassismass',TPasJSONItemNumber.Create(fChassisMass));

 TPasJSONItemObject(result).Add('airresistance',TPasJSONItemNumber.Create(fAirResistance));

 TPasJSONItemObject(result).Add('handbrakeslipperytime',TPasJSONItemNumber.Create(fHandBrakeSlipperyTime));

 TPasJSONItemObject(result).Add('driftslipperytime',TPasJSONItemNumber.Create(fDriftSlipperyTime));

 TPasJSONItemObject(result).Add('maximumgravityslopeangle',TPasJSONItemNumber.Create(fMaximumGravitySlopeAngle));

 TPasJSONItemObject(result).Add('maximumspeed',TPasJSONItemNumber.Create(fMaximumSpeed));

 TPasJSONItemObject(result).Add('maximumreversespeed',TPasJSONItemNumber.Create(fMaximumReverseSpeed));

 TPasJSONItemObject(result).Add('accelerationminimumforce',TPasJSONItemNumber.Create(fAccelerationMinimumForce));

 TPasJSONItemObject(result).Add('reverseaccelerationminimumforce',TPasJSONItemNumber.Create(fReverseAccelerationMinimumForce));

 TPasJSONItemObject(result).Add('curveevaluationaccuracy',TPasJSONItemNumber.Create(fCurveEvaluationAccuracy));

 TPasJSONItemObject(result).Add('accelerationrescueforce',fAccelerationRescueForce.SaveToJSON);

 TPasJSONItemObject(result).Add('reverseaccelerationrescueforce',fReverseAccelerationRescueForce.SaveToJSON);

 TPasJSONItemObject(result).Add('accelerationcurveenvelope',fAccelerationCurveEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('reverseaccelerationcurveenvelope',fReverseAccelerationCurveEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('brakecurveenvelope',fBrakeCurveEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('reversebrakecurveenvelope',fReverseBrakeCurveEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('steeranglelimitenvelope',fSteerAngleLimitEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('steeringresetspeedenvelope',fSteeringResetSpeedEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('steeringspeedenvelope',fSteeringSpeedEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('driftangleaccelerationfactorenvelope',fDriftAngleAccelerationFactorEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('driftsteeranglelimitenvelope',fDriftSteerAngleLimitEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('driftsteeringresetspeedenvelope',fDriftSteeringResetSpeedEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('driftsteeringspeedenvelope',fDriftSteeringSpeedEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('gripfactorenvelope',fGripFactorEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('drivingtractionfactorenvelope',fDrivingTractionFactorEnvelope.SaveToJSON);

 TPasJSONItemObject(result).Add('downforcecurveenvelope',fDownForceCurveEnvelope.SaveToJSON);
 TPasJSONItemObject(result).Add('downforcefactor',TPasJSONItemNumber.Create(fDownForceFactor));

 TPasJSONItemObject(result).Add('jumpimpulse',TPasJSONItemNumber.Create(fJumpImpulse));

 TPasJSONItemObject(result).Add('driftafterjump',TPasJSONItemBoolean.Create(fDriftAfterJump));

 TPasJSONItemObject(result).Add('superjumpimpulse',TPasJSONItemNumber.Create(fSuperJumpImpulse));

 TPasJSONItemObject(result).Add('driftaftersuperjump',TPasJSONItemBoolean.Create(fDriftAfterSuperJump));

 TPasJSONItemObject(result).Add('flightsteeringtorquefactor',TPasJSONItemNumber.Create(fFlightSteeringTorqueFactor));

 TPasJSONItemObject(result).Add('flightsteeringtorquefactoronjump',TPasJSONItemNumber.Create(fFlightSteeringTorqueFactorOnJump));

 TPasJSONItemObject(result).Add('flightsteeringtorquefactoronsuperjump',TPasJSONItemNumber.Create(fFlightSteeringTorqueFactorOnSuperJump));

 TPasJSONItemObject(result).Add('flightstabilizationangularvelocitydamping',Vector3ToJSON(fFlightStabilizationAngularVelocityDamping));
 TPasJSONItemObject(result).Add('flightstabilizationdamping',TPasJSONItemNumber.Create(fFlightStabilizationDamping));
 TPasJSONItemObject(result).Add('flightstabilizationforcefactor',TPasJSONItemNumber.Create(fFlightStabilizationForceFactor));

 TPasJSONItemObject(result).Add('keepuprightthreshold',TPasJSONItemNumber.Create(fKeepUprightThreshold));
 TPasJSONItemObject(result).Add('keepuprightforcefactor',TPasJSONItemNumber.Create(fKeepUprightForceFactor));

 JSONItem:=TPasJSONItemObject.Create;
 try
  for Index:=0 to fWheels.Count-1 do begin
   Wheel:=fWheels[Index];
   if assigned(Wheel) then begin
    SubJSONItem:=Wheel.SaveToJSON;
    if assigned(SubJSONItem) then begin
     try
      if SubJSONItem is TPasJSONItemObject then begin
       TPasJSONItemObject(SubJSONItem).Delete('name'); // Don't have the name also in the child object, because it is already in the parent object as the key
      end;
      TPasJSONItemObject(JSONItem).Add(Wheel.fName,SubJSONItem);
     except
      FreeAndNil(SubJSONItem);
      raise;
     end;
    end;
   end;
  end;
 finally
  TPasJSONItemObject(result).Add('wheels',JSONItem);
 end;

 JSONItem:=TPasJSONItemObject.Create;
 try
  for Index:=0 to fAxles.Count-1 do begin
   Axle:=fAxles[Index];
   if assigned(Axle) then begin
    SubJSONItem:=Axle.SaveToJSON;
    if assigned(SubJSONItem) then begin
     try
      if SubJSONItem is TPasJSONItemObject then begin
       TPasJSONItemObject(SubJSONItem).Delete('name'); // Don't have the name also in the child object, because it is already in the parent object as the key
      end;
      TPasJSONItemObject(JSONItem).Add(Axle.fName,SubJSONItem);
     except
      FreeAndNil(SubJSONItem);
      raise;
     end;
    end;
   end;
  end;
 finally
  TPasJSONItemObject(result).Add('axles',JSONItem);
 end;

 JSONItem:=TPasJSONItemObject.Create;
 try
  for Index:=0 to fAckermannGroups.Count-1 do begin
   AckermannGroup:=fAckermannGroups[Index];
   if assigned(AckermannGroup) then begin
    SubJSONItem:=AckermannGroup.SaveToJSON;
    if assigned(SubJSONItem) then begin
     try
      if SubJSONItem is TPasJSONItemObject then begin
       TPasJSONItemObject(SubJSONItem).Delete('name'); // Don't have the name also in the child object, because it is already in the parent object as the key
      end;
      TPasJSONItemObject(JSONItem).Add(AckermannGroup.fName,SubJSONItem);
     except
      FreeAndNil(SubJSONItem);
      raise;
     end;
    end;
   end;
  end;
 finally
  TPasJSONItemObject(result).Add('ackermanngroups',JSONItem);
 end;

end;

{$endif}

{ TKraftRayCastVehicle.TWheel }

constructor TKraftRayCastVehicle.TWheel.Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TWheel);
begin
 inherited Create;
 fVehicle:=aVehicle;
 fSettings:=aSettings;
 fAxle:=nil;
 fIsGrounded:=false;
 fSuspensionLength:=fSettings.fSuspensionRestLength;
 fSuspension.fCurrentLength:=fSettings.fSuspensionRestLength+fSettings.Radius;
 fSuspension.fCurrentVelocity:=0.0;
 fSuspension.fCompression:=0.0;
 fYawRad:=0.0;
 fPhysicalRotationRad:=0.0;
 fWorldTransform:=Matrix4x4Identity;
 fLastWorldTransform:=Matrix4x4Identity;
 fVisualWorldTransform:=Matrix4x4Identity;
end;

destructor TKraftRayCastVehicle.TWheel.Destroy;
begin
 inherited Destroy;
end;

function TKraftRayCastVehicle.TWheel.GetSuspensionRelativePosition:TKraftVector3;
begin
 result:=fSettings.fPosition;
end;

function TKraftRayCastVehicle.TWheel.GetSuspensionPosition:TKraftVector3;
begin
 result:=Vector3TermMatrixMul(GetSuspensionRelativePosition,fVehicle.fWorldTransform);
end;

function TKraftRayCastVehicle.TWheel.GetSuspensionHitPosition:TKraftVector3;
begin
 result:=Vector3Add(GetSuspensionPosition,Vector3ScalarMul(fVehicle.fWorldDown,fSuspensionLength+fSettings.Radius));
end;

function TKraftRayCastVehicle.TWheel.GetWheelLongitudinalDirection:TKraftVector3;
begin
 if fSettings.fSteering then begin
  result:=Vector3TermQuaternionRotate(fVehicle.fWorldForward,QuaternionFromAxisAngle(fVehicle.fWorldUp,fYawRad));
 end else begin
  result:=fVehicle.fWorldForward;
 end;
end;

function TKraftRayCastVehicle.TWheel.GetWheelLaterialDirection:TKraftVector3;
begin
 result:=Vector3Cross(fVehicle.fWorldUp,GetWheelLongitudinalDirection);
end;

function TKraftRayCastVehicle.TWheel.GetWheelTorqueRelativePosition:TKraftVector3;
begin
 result:=Vector3(fSettings.fPosition.x,0,fSettings.fPosition.z);
end;

function TKraftRayCastVehicle.TWheel.GetWheelTorquePosition:TKraftVector3;
begin
 result:=Vector3TermMatrixMul(GetWheelTorqueRelativePosition,fVehicle.fWorldTransform);
end;

function TKraftRayCastVehicle.TWheel.GetWheelGripFactor:TKraftScalar;
begin
 result:=fSettings.fGripFactor*fVehicle.fSettings.fGripFactorEnvelope.GetValueAtTime(fVehicle.fSpeedKMH);
end;

function TKraftRayCastVehicle.TWheel.GetWheelTransform:TKraftMatrix4x4;
var {LocalWheelPosition,}WorldWheelPosition:TKraftVector3;
    LocalWheelRotation,WorldWheelRotation:TKraftQuaternion;
begin
 LocalWheelRotation:=QuaternionFromAngles(fYawRad,0.0,fPhysicalRotationRad);
 WorldWheelPosition:=Vector3Add(GetSuspensionPosition,Vector3ScalarMul(fVehicle.fWorldDown,fSuspensionLength{-fSettings.fRadius}));
 WorldWheelRotation:=QuaternionMul(fVehicle.fRigidBody.Sweep.q,LocalWheelRotation);
 result:=QuaternionToMatrix4x4(WorldWheelRotation);
 PKraftVector3(@result[3,0])^.xyz:=WorldWheelPosition.xyz;
end;

procedure TKraftRayCastVehicle.TWheel.UpdateArcadeSuspension;
var RayOrigin,RayDirection,HitPoint,HitNormal:TKraftVector3;
    SuspensionRestLengthWithRadius,RayLength,PreviousLength,CurrentLength,HitTime,
    CurrentVelocity,Force:TKraftScalar;
    HitShape:TKraftShape;
begin

 HitShape:=nil;

 SuspensionRestLengthWithRadius:=fSettings.fSuspensionRestLength+fSettings.Radius;

 RayOrigin:=GetSuspensionPosition;
 PreviousLength:=fSuspension.fCurrentLength;
 RayDirection:=fVehicle.fWorldDown;
 if fSettings.fUseSphereCast then begin
  RayLength:=SuspensionRestLengthWithRadius-fSettings.Radius;
  if fVehicle.fPhysics.SphereCast(RayOrigin,fSettings.fRadius,RayDirection,RayLength,HitShape,HitTime,HitPoint,HitNormal,fVehicle.fCastCollisionGroups,fVehicle.RayCastFilter) then begin
   CurrentLength:=HitTime+fSettings.fRadius;
   Vector3DirectAdd(fVehicle.fHitAverageNormal,HitNormal);
   inc(fVehicle.fHitAverageNormalCount);
  end else begin
   CurrentLength:=SuspensionRestLengthWithRadius;
   HitShape:=nil;
  end;
 end else begin
  RayLength:=SuspensionRestLengthWithRadius;
  if fVehicle.fPhysics.RayCast(RayOrigin,RayDirection,RayLength,HitShape,HitTime,HitPoint,HitNormal,fVehicle.fCastCollisionGroups,fVehicle.RayCastFilter) then begin
   CurrentLength:=HitTime;
   Vector3DirectAdd(fVehicle.fHitAverageNormal,HitNormal);
   inc(fVehicle.fHitAverageNormalCount);
  end else begin
   CurrentLength:=SuspensionRestLengthWithRadius;
   HitShape:=nil;
  end;
 end;

 fSuspension.fCurrentVelocity:=(CurrentLength-PreviousLength)*fVehicle.fInverseDeltaTime;
 fSuspension.fCurrentLength:=CurrentLength;
 fSuspension.fCompression:=1.0-Clamp01(CurrentLength/SuspensionRestLengthWithRadius);

 fSuspensionCompressionDistance:=Max(0.0,CurrentLength-fSettings.Radius);

 fSuspensionCompressionRatio:=fSuspension.fCompression;

 fIsGrounded:=fSuspension.fCurrentLength<SuspensionRestLengthWithRadius;

 fSuspensionLength:=fSuspension.fCurrentLength-fSettings.fRadius;
 CurrentLength:=fSuspension.fCurrentLength;
 CurrentVelocity:=fSuspension.fCurrentVelocity;
 Force:=TKraftRayCastVehicle.TSuspensionSpringMath.CalculateForceDamped(CurrentLength,
                                                                        CurrentVelocity,
                                                                        SuspensionRestLengthWithRadius,
                                                                        fSettings.fSuspensionStrength,
                                                                        fSettings.fSuspensionDamping)*fVehicle.fRigidBody.Mass;

 if abs(Force)>EPSILON then begin

  fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldUp,Force),GetSuspensionPosition,kfmForce,false);

  if assigned(HitShape) and assigned(HitShape.RigidBody) and (HitShape.RigidBody.RigidBodyType=krbtDynamic) then begin
   HitShape.RigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,Force),GetSuspensionPosition,kfmForce,false);
  end;

 end;

end;

procedure TKraftRayCastVehicle.TWheel.UpdateRealisticSuspension;
var RayOrigin,HitPoint,HitNormal:TKraftVector3;
    HitTime,Force:TKraftScalar;
    HitShape:TKraftShape;
begin

 RayOrigin:=GetSuspensionPosition;

 if fSettings.fUseSphereCast then begin
  fIsGrounded:=fVehicle.fPhysics.SphereCast(RayOrigin,
                                            fSettings.fRadius,
                                            fVehicle.fWorldDown,
                                            fSettings.fSuspensionRestLength,
                                            HitShape,
                                            HitTime,
                                            HitPoint,
                                            HitNormal,
                                            fVehicle.fCastCollisionGroups,
                                            fVehicle.RayCastFilter);
  if fIsGrounded then begin
   HitTime:=HitTime+fSettings.fRadius;
  end;
 end else begin
  fIsGrounded:=fVehicle.fPhysics.RayCast(RayOrigin,
                                         fVehicle.fWorldDown,
                                         fSettings.fSuspensionRestLength+fSettings.fRadius,
                                         HitShape,
                                         HitTime,
                                         HitPoint,
                                         HitNormal,
                                         fVehicle.fCastCollisionGroups,
                                         fVehicle.RayCastFilter);
 end;

 if fIsGrounded then begin
  Vector3DirectAdd(fVehicle.fHitAverageNormal,HitNormal);
  inc(fVehicle.fHitAverageNormalCount);
 end;

 fSuspensionPreviousCompressionDistance:=fSuspensionCompressionDistance;

 if fIsGrounded then begin

  fSuspensionCompressionDistance:=fSettings.fSuspensionRestLength-(HitTime-fSettings.fRadius);

  if fSettings.fSuspensionClamping then begin
   fSuspensionCompressionDistance:=Clamp(fSuspensionCompressionDistance,0,fSettings.fSuspensionRestLength);
  end;

  fSuspensionCompressionRatio:=fSuspensionCompressionDistance/fSettings.fSuspensionRestLength;

  fSuspensionLength:=fSettings.fSuspensionRestLength-fSuspensionCompressionDistance;

  Force:=((fSuspensionCompressionRatio*fSettings.fSuspensionStrength)-
          (((fSuspensionPreviousCompressionDistance-fSuspensionCompressionDistance)*fSettings.SuspensionDamping)*fVehicle.fInverseDeltaTime))*fVehicle.fRigidBody.Mass;

  if abs(Force)>EPSILON then begin

   fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldUp,Force),GetSuspensionHitPosition,kfmForce,false);

   if assigned(HitShape) and assigned(HitShape.RigidBody) and (HitShape.RigidBody.RigidBodyType=krbtDynamic) then begin
    HitShape.RigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,Force),GetSuspensionHitPosition,kfmForce,false);
   end;

  end;

 end else begin

  fSuspensionCompressionDistance:=Clamp(fSuspensionCompressionDistance-(fVehicle.fDeltaTime*fSettings.fSuspensionRelaxRate),0,fSettings.fSuspensionRestLength);

  fSuspensionCompressionRatio:=fSuspensionCompressionDistance/fSettings.fSuspensionRestLength;

  fSuspensionLength:=fSettings.fSuspensionRestLength-fSuspensionCompressionDistance;

 end;

end;

procedure TKraftRayCastVehicle.TWheel.UpdateSuspension;
begin
 case fVehicle.fSettings.fSuspensionMode of
  TKraftRayCastVehicle.TSuspensionMode.Arcade:begin
   UpdateArcadeSuspension;
  end;
  else begin
   UpdateRealisticSuspension;
  end;
 end;
end;

procedure TKraftRayCastVehicle.TWheel.UpdateLaterialForce;
var SuspensionPosition,LaterialDirection,Force:TKraftVector3;
    SlipperyK,HandBrakeK,DriftK,LaterialVelocity,DesiredVelocityChange,DesiredAcceleration,
    AfterFlightSlipperyK,BrakeSlipperyK,HandBrakeSlipperyK,DriftSlipperyK:TKraftScalar;
begin

{$ifdef DebugDraw}
 fDebugLaterialForce:=Vector3Origin;
{$endif}
 if fIsGrounded then begin

  begin

   // Simulate slippery tires

   SlipperyK:=1.0;

   AfterFlightSlipperyK:=fSettings.fAfterFlightSlipperyK;
   if (fVehicle.fAfterFlightSlipperyTiresTime>0.0) and not IsZero(AfterFlightSlipperyK) then begin
    SlipperyK:=Min(SlipperyK,Lerp(1.0,AfterFlightSlipperyK,Clamp01(fVehicle.fAfterFlightSlipperyTiresTime)));
   end;

   BrakeSlipperyK:=fSettings.fBrakeSlipperyK;
   if (fVehicle.fBrakeSlipperyTiresTime>0.0) and not IsZero(BrakeSlipperyK) then begin
    SlipperyK:=Min(SlipperyK,Lerp(1.0,BrakeSlipperyK,Clamp01(fVehicle.fBrakeSlipperyTiresTime)));
   end;

   HandBrakeSlipperyK:=fSettings.fHandBrakeSlipperyK;
   if not IsZero(HandBrakeSlipperyK) then begin
    HandBrakeK:=fVehicle.GetHandBrakeK;
    if HandBrakeK>0.0 then begin
     SlipperyK:=Min(SlipperyK,Lerp(1.0,HandBrakeSlipperyK,HandBrakeK));
    end;
   end;

   DriftSlipperyK:=fSettings.fDriftSlipperyK;
   if not IsZero(DriftSlipperyK) then begin
    DriftK:=fVehicle.GetDriftK;
    if DriftK>0.0 then begin
     SlipperyK:=Min(SlipperyK,Lerp(1.0,DriftSlipperyK,DriftK));
    end;
   end;

  end;

  SuspensionPosition:=GetSuspensionPosition;
  LaterialDirection:=GetWheelLaterialDirection;
  LaterialVelocity:=Vector3Dot(LaterialDirection,fVehicle.fRigidBody.GetWorldLinearVelocityFromPoint(SuspensionPosition));
  DesiredVelocityChange:=-(LaterialVelocity*GetWheelGripFactor*SlipperyK);
  DesiredAcceleration:=DesiredVelocityChange*fVehicle.fInverseDeltaTime;
  fLaterialForceStrength:=abs(DesiredVelocityChange);
  Force:=Vector3ScalarMul(LaterialDirection,DesiredAcceleration*fSettings.fMass);
{$ifdef DebugDraw}
  Vector3DirectAdd(fDebugLaterialForce,Force);
{$endif}
  if Vector3Length(Force)>EPSILON then begin
   fVehicle.fRigidBody.AddForceAtPosition(Force,GetWheelTorquePosition,kfmForce,false);
  end;
 end else begin
  fLaterialForceStrength:=0.0;
 end;
end;

procedure TKraftRayCastVehicle.TWheel.UpdateAcceleration;
var WheelForward,Force:TKraftVector3;
    MaximumSpeed,MaximumReverseSpeed,ForceMagnitude,Factor,DriftK:TKraftScalar;
begin

{$ifdef DebugDraw}
 fDebugAccelerationForce:=Vector3Origin;
{$endif}

 // If the wheel is not powered, then exit
 if not fSettings.fPowered then begin
  exit;
 end;

 if not (IsZero(fVehicle.fAccelerationForceMagnitude) or IsZero(fSettings.fAccelerationForceFactor)) then begin

  MaximumSpeed:=fSettings.fMaximumSpeed;
  if IsZero(MaximumSpeed) then begin
   MaximumSpeed:=fVehicle.fSettings.fMaximumSpeed;
  end;

  MaximumReverseSpeed:=fSettings.fMaximumReverseSpeed;
  if IsZero(MaximumReverseSpeed) then begin
   MaximumReverseSpeed:=fVehicle.fSettings.fMaximumReverseSpeed;
  end;

  if fIsGrounded and
     ((fVehicle.fMovingForward and (IsZero(MaximumSpeed) or (fVehicle.fAbsoluteSpeedKMH<MaximumSpeed))) or
      ((not fVehicle.fMovingForward) and (IsZero(MaximumReverseSpeed) or (fVehicle.fAbsoluteSpeedKMH<MaximumReverseSpeed)))) then begin

   WheelForward:=GetWheelLongitudinalDirection;

   DriftK:=fVehicle.GetDriftK;
   if not IsZero(DriftK) then begin
    Factor:=Lerp(1.0,Max(1.0,fVehicle.fSettings.fDriftAngleAccelerationFactorEnvelope.GetValueAtTime(abs(fYawRad*RAD2DEG))),DriftK);
   end else begin
    Factor:=1.0;
   end;

   ForceMagnitude:=fVehicle.fAccelerationForceMagnitude*Factor;

   Force:=Vector3ScalarMul(WheelForward,ForceMagnitude*Clamp01(fSettings.fAccelerationForceFactor)*fVehicle.fInverseDeltaTime);
//   Force:=Vector3ScalarMul(WheelForward,fVehicle.fAccelerationForceMagnitude*Clamp01(fSettings.fAccelerationForceFactor)*fVehicle.fInverseDeltaTime);

{$ifdef DebugDraw}
   Vector3DirectAdd(fDebugAccelerationForce,Force);
{$endif}

   if Vector3Length(Force)>EPSILON then begin
    fVehicle.fRigidBody.AddForceAtPosition(Force,GetWheelTorquePosition,kfmForce,true);
   end;

  end;

 end;
end;

procedure TKraftRayCastVehicle.TWheel.UpdateLongitudinalForce;
var BrakeRatio,RollingFrictionRatio,LongitudinalVelocity,DesiredVelocityChange,DesiredAcceleration:TKraftScalar;
    SuspensionPosition,LongitudinalDirection,Force:TKraftVector3;
begin

{$ifdef DebugDraw}
 fDebugLongitudinalForce:=Vector3Origin;
{$endif}

 if fVehicle.fIsBrake or fVehicle.fIsHandBrake then begin
  if fVehicle.fIsHandBrake and not fVehicle.fIsBrake then begin
   BrakeRatio:=0.8;
  end else begin
   BrakeRatio:=1.0;
  end;
  RollingFrictionRatio:=0.0;
 end else if not (fVehicle.fIsAcceleration or fVehicle.fIsReverseAcceleration) then begin
  BrakeRatio:=0.0;
  RollingFrictionRatio:=1.0;
 end else begin
  exit;
 end;

 {if assigned(fAxle) and
    (((fAxle.fAxleID=TAxleID.Front) and not fVehicle.fSettings.fFrontPowered) or
     ((fAxle.fAxleID=TAxleID.Rear) and not fVehicle.fSettings.fRearPowered)) then begin
  BrakeRatio:=0.0; // If the wheel at the current axle is not powered, then disable braking
 end;}

 if fIsGrounded then begin
  SuspensionPosition:=GetSuspensionPosition;
  LongitudinalDirection:=GetWheelLongitudinalDirection;
  LongitudinalVelocity:=Vector3Dot(LongitudinalDirection,fVehicle.fRigidBody.GetWorldLinearVelocityFromPoint(SuspensionPosition));
  Force:=Vector3Origin;
  if not IsZero(BrakeRatio) then begin
// DesiredVelocityChange:=-Max(0.0,BrakeRatio*Clamp01(fSettings.fBrakeForceFactor)*fVehicle.fBrakeForceMagnitude)*Sign(LongitudinalVelocity);
   DesiredVelocityChange:=-Clamp(BrakeRatio*Clamp01(fSettings.fBrakeForceFactor)*fVehicle.fBrakeForceMagnitude,0.0,abs(LongitudinalVelocity))*Sign(LongitudinalVelocity);
   DesiredAcceleration:=DesiredVelocityChange*fVehicle.fInverseDeltaTime;
   Vector3DirectAdd(Force,Vector3ScalarMul(LongitudinalDirection,DesiredAcceleration));
  end;
  if not IsZero(RollingFrictionRatio) then begin
   Vector3DirectAdd(Force,Vector3ScalarMul(LongitudinalDirection,-(LongitudinalVelocity*RollingFrictionRatio*(1.0-Clamp01(fSettings.fRollingFriction)))));
  end;
{$ifdef DebugDraw}
  Vector3DirectAdd(fDebugLongitudinalForce,Force);
{$endif}
  if Vector3Length(Force)>EPSILON then begin
   fVehicle.fRigidBody.AddForceAtPosition(Force,GetWheelTorquePosition,kfmForce,false);
  end;
 end;

end;

procedure TKraftRayCastVehicle.TWheel.UpdateWheelRotation;
const TwoPI=2.0*PI;
var WorldWheelPosition,WorldWheelForward,VelocityQueryPos,WheelVelocity:TKraftVector3;
    LocalWheelRotation,WorldWheelRotation:TKraftQuaternion;
    TireLongSpeed,WheelLengthMeters,RevolutionsPerSecond,DeltaRotation:TKraftScalar;
begin

 LocalWheelRotation:=QuaternionFromAngles(fYawRad,0.0,0);

 WorldWheelPosition:=Vector3Add(GetSuspensionPosition,Vector3ScalarMul(fVehicle.WorldDown,fSuspensionLength));
 WorldWheelRotation:=QuaternionMul(fVehicle.fRigidBody.Sweep.q,LocalWheelRotation);

 WorldWheelForward:=Vector3TermQuaternionRotate(Vector3(0.0,0.0,1.0),WorldWheelRotation);

 VelocityQueryPos:=WorldWheelPosition;
 WheelVelocity:=fVehicle.fRigidBody.GetWorldLinearVelocityFromPoint(VelocityQueryPos);

 // Longitudinal speed (meters/sec)
 TireLongSpeed:=Vector3Dot(WheelVelocity,WorldWheelForward);

 // For physical-side wheel radius:
 begin

  // Circle length = 2 * PI * R
  WheelLengthMeters:=TwoPI*fSettings.fRadius;

  // Wheel "Revolutions per second";
  RevolutionsPerSecond:=TireLongSpeed/WheelLengthMeters;

  DeltaRotation:=TwoPI*RevolutionsPerSecond*fVehicle.fDeltaTime;

  fPhysicalRotationRad:=fPhysicalRotationRad+DeltaRotation;

 end;

 // For visual-side wheel radius:
 begin

  // Circle length = 2 * PI * R
  WheelLengthMeters:=TwoPI*fSettings.fVisual.fRadius;

  // Wheel "Revolutions per second";
  RevolutionsPerSecond:=TireLongSpeed/WheelLengthMeters;

  DeltaRotation:=TwoPI*RevolutionsPerSecond*fVehicle.fDeltaTime;

  fRotationRad:=fRotationRad+DeltaRotation;

 end;

end;

procedure TKraftRayCastVehicle.TWheel.UpdateVisuals;
begin
 fWorldTransform:=GetWheelTransform;
end;

procedure TKraftRayCastVehicle.TWheel.StoreWorldTransforms;
begin
 fLastYawRad:=fYawRad;
 fLastPhysicalRotationRad:=fPhysicalRotationRad;
 fLastRotationRad:=fRotationRad;
 fLastSuspensionLength:=fSuspensionLength;
 fLastWorldTransform:=fWorldTransform;
{$ifdef DebugDraw}
 fLastDebugAntiRollForceFactor:=fDebugAntiRollForceFactor;
 fLastDebugAccelerationForce:=fDebugAccelerationForce;
 fLastDebugLongitudinalForce:=fDebugLongitudinalForce;
 fLastDebugLaterialForce:=fDebugLaterialForce;
{$endif}
end;

procedure TKraftRayCastVehicle.TWheel.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 fVisualYawRad:=AngleLerp(fLastYawRad,fYawRad,aAlpha);
 fVisualPhysicalRotationRad:=AngleLerp(fLastPhysicalRotationRad,fPhysicalRotationRad,aAlpha);
 fVisualRotationRad:=AngleLerp(fLastRotationRad,fRotationRad,aAlpha);
 fVisualSuspensionLength:=Lerp(fLastSuspensionLength,fSuspensionLength,aAlpha);
 fVisualWorldTransform:=Matrix4x4Slerp(fLastWorldTransform,fWorldTransform,aAlpha);
{$ifdef DebugDraw}
 fVisualDebugAntiRollForceFactor:=Vector3Lerp(fLastDebugAntiRollForceFactor,fDebugAntiRollForceFactor,aAlpha);
 fVisualDebugAccelerationForce:=Vector3Lerp(fLastDebugAccelerationForce,fDebugAccelerationForce,aAlpha);
 fVisualDebugLongitudinalForce:=Vector3Lerp(fLastDebugLongitudinalForce,fDebugLongitudinalForce,aAlpha);
 fVisualDebugLaterialForce:=Vector3Lerp(fLastDebugLaterialForce,fDebugLaterialForce,aAlpha);
{$endif}
end;

{ TKraftRayCastVehicle.TAxle }

constructor TKraftRayCastVehicle.TAxle.Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TAxle);
var Index,OtherIndex:TKraftSizeInt;
    SettingWheel:TKraftRayCastVehicle.TSettings.TWheel;
    Wheel:TKraftRayCastVehicle.TWheel;
begin

 inherited Create;

 fVehicle:=aVehicle;

 fSettings:=aSettings;

 fAckermannGroup:=nil;

 fWheels:=TKraftRayCastVehicle.TWheels.Create(false);

 for Index:=0 to fSettings.fWheels.Count-1 do begin
  SettingWheel:=fSettings.fWheels[Index];
  for OtherIndex:=0 to fVehicle.fWheels.Count-1 do begin
   Wheel:=fVehicle.fWheels[OtherIndex];
   if Wheel.fSettings=SettingWheel then begin
    Wheel.fAxle:=self;
    fWheels.Add(Wheel);
    break;
   end;
  end;
 end;

end;

destructor TKraftRayCastVehicle.TAxle.Destroy;
begin
 inherited Destroy;
end;

procedure TKraftRayCastVehicle.TAxle.UpdateAntiRollBar;
var TravelL,TravelR,AntiRollForceFactor:TKraftScalar;
    WheelLeft,WheelRight:TKraftRayCastVehicle.TWheel;
begin
 if (fWheels.Count=2) and not IsZero(fSettings.fStabilizerBarAntiRollForceFactor) then begin
  WheelLeft:=fWheels[0];
  WheelRight:=fWheels[1];
  TravelL:=1.0-Clamp01(WheelLeft.fSuspensionCompressionRatio);
  TravelR:=1.0-Clamp01(WheelRight.fSuspensionCompressionRatio);
  AntiRollForceFactor:=(TravelL-TravelR)*fSettings.fStabilizerBarAntiRollForceFactor;
  if WheelLeft.fIsGrounded and (abs(AntiRollForceFactor)>EPSILON) then begin
   fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,AntiRollForceFactor*fVehicle.fRigidBody.Mass),WheelLeft.GetSuspensionHitPosition,kfmForce,false);
{$ifdef DebugDraw}
   WheelLeft.fDebugAntiRollForceFactor:=Vector3ScalarMul(fVehicle.fWorldDown,AntiRollForceFactor);
{$endif}
  end else begin
{$ifdef DebugDraw}
   WheelLeft.fDebugAntiRollForceFactor:=Vector3Origin;
{$endif}
  end;
  if WheelRight.fIsGrounded and (abs(AntiRollForceFactor)>EPSILON) then begin
   fVehicle.fRigidBody.AddForceAtPosition(Vector3ScalarMul(fVehicle.fWorldDown,-AntiRollForceFactor*fVehicle.fRigidBody.Mass),WheelRight.GetSuspensionHitPosition,kfmForce,false);
{$ifdef DebugDraw}
   WheelRight.fDebugAntiRollForceFactor:=Vector3ScalarMul(fVehicle.fWorldDown,-AntiRollForceFactor);
{$endif}
  end else begin
{$ifdef DebugDraw}
   WheelRight.fDebugAntiRollForceFactor:=Vector3Origin;
{$endif}
  end;
 end;
end;

{ TKraftRayCastVehicle.TAckermannGroup }

constructor TKraftRayCastVehicle.TAckermannGroup.Create(const aVehicle:TKraftRayCastVehicle;const aSettings:TKraftRayCastVehicle.TSettings.TAckermannGroup);
var Index,OtherIndex:TKraftSizeInt;
    SettingAxle:TKraftRayCastVehicle.TSettings.TAxle;
    Axle:TKraftRayCastVehicle.TAxle;
begin
 inherited Create;
 fVehicle:=aVehicle;
 fSettings:=aSettings;
 fAxles:=TKraftRayCastVehicle.TAxles.Create(false);
 for Index:=0 to fSettings.fAxles.Count-1 do begin
  SettingAxle:=fSettings.fAxles[Index];
  for OtherIndex:=0 to fVehicle.fAxles.Count-1 do begin
   Axle:=fVehicle.fAxles[OtherIndex];
   if Axle.fSettings=SettingAxle then begin
    Axle.fAckermannGroup:=self;
    fAxles.Add(Axle);
    break;
   end;
  end;
 end;
end;

destructor TKraftRayCastVehicle.TAckermannGroup.Destroy;
begin
 FreeAndNil(fAxles);
 inherited Destroy;
end;

procedure TKraftRayCastVehicle.TAckermannGroup.UpdateAckermannSteering;
var SteerAngleRad,AxleSeparation,WheelSeparation,TurningCircleRadius:TKraftScalar;
    AxleDiff,WheelDiff:TKraftVector3;
    WheelFrontLeft,WheelFrontRight,WheelRearLeft,WheelRearRight:TKraftRayCastVehicle.TWheel;
begin

 if (fAxles.Count=2) and (fAxles[0].fWheels.Count=2) and (fAxles[1].fWheels.Count=2) then begin

  // Ackermann steering for 4 wheels in 2x2 configuration

  WheelFrontLeft:=fAxles[0].fWheels[0];
  WheelFrontRight:=fAxles[0].fWheels[1];
  WheelRearLeft:=fAxles[1].fWheels[0];
  WheelRearRight:=fAxles[1].fWheels[1];

  if (WheelFrontLeft.fSettings.fSteering and WheelFrontRight.fSettings.fSteering) and
     ((not WheelRearLeft.fSettings.fSteering) and (not WheelRearRight.fSettings.fSteering)) then begin

   // Front wheels are steering wheels and rear wheels are not steering wheels

   SteerAngleRad:=fVehicle.fSteeringAngle*DEG2RAD;

   AxleDiff:=Vector3Sub(Vector3Avg(WheelFrontLeft.GetSuspensionPosition,WheelFrontRight.GetSuspensionPosition),
                        Vector3Avg(WheelRearLeft.GetSuspensionPosition,WheelRearRight.GetSuspensionPosition));
   AxleSeparation:=Vector3Length(AxleDiff);

   WheelDiff:=Vector3Sub(WheelFrontLeft.GetSuspensionPosition,WheelFrontRight.GetSuspensionPosition);
   WheelSeparation:=Vector3Length(WheelDiff);

   TurningCircleRadius:=AxleSeparation/Tan(SteerAngleRad);
   if IsNaN(TurningCircleRadius) then begin
    TurningCircleRadius:=0.0;
   end;

   WheelFrontLeft.fYawRad:=ArcTan(AxleSeparation/(TurningCircleRadius+(WheelSeparation*0.5)));
   WheelFrontRight.fYawRad:=ArcTan(AxleSeparation/(TurningCircleRadius-(WheelSeparation*0.5)));

   WheelRearLeft.fYawRad:=0.0;
   WheelRearRight.fYawRad:=0.0;

  end;

 end;

end;

{ TKraftRayCastVehicle }

constructor TKraftRayCastVehicle.Create(const aPhysics:TKraft);
begin
 inherited Create;
 fPhysics:=aPhysics;
 fOnRayCastFilter:=nil;
 fConvexHull:=nil;
 fOwnsRigidBody:=false;
 fOwnsFreeShape:=false;
 fRigidBody:=nil;
 fShape:=nil;
 fData:=nil;
 fAccelerationInput:=0.0;
 fControllable:=true;
 fForward:=Vector3(0.0,0.0,-1.0);
 fVelocity:=Vector3(0.0,0.0,0.0);
 fCollisionGroups:=[1];
 fCollideWithCollisionGroups:=[Low(TKraftRigidBodyCollisionGroup)..High(TKraftRigidBodyCollisionGroup)];
 fCastCollisionGroups:=[Low(TKraftRigidBodyCollisionGroup)..High(TKraftRigidBodyCollisionGroup)];
 fOnGroundContactAfterJump:=nil;
 fOnJump:=nil;
 fOnJumpDone:=nil;
 fOnGroundContactAfterSuperJump:=nil;
 fOnSuperJump:=nil;
 fOnSuperJumpDone:=nil;
 fSettings:=TKraftRayCastVehicle.TSettings.Create;
 fWheels:=TKraftRayCastVehicle.TWheels.Create(true);
 fAxles:=TKraftRayCastVehicle.TAxles.Create(true);
 fAckermannGroups:=TKraftRayCastVehicle.TAckermannGroups.Create(true);
 fInputAIFlightSteerFactor:=100.0;
 Reset;
end;

destructor TKraftRayCastVehicle.Destroy;
begin
 FreeAndNil(fAckermannGroups);
 FreeAndNil(fAxles);
 FreeAndNil(fWheels);
 FreeAndNil(fSettings);
 if fOwnsFreeShape then begin
  FreeAndNil(fShape);
 end;
 if fOwnsRigidBody then begin
  FreeAndNil(fRigidBody);
 end;
 inherited Destroy;
end;

function TKraftRayCastVehicle.ShapeCanCollideWith(const WithShape:TKraftShape):boolean;
begin
 result:=true;
end;

function TKraftRayCastVehicle.RayCastFilter(const aPoint,aNormal:TKraftVector3;const aTime:TKraftScalar;const aShape:TKraftShape):boolean;
var Shape:TKraftShape;
begin
 if assigned(fRigidBody) then begin
  Shape:=fRigidBody.ShapeFirst;
  while assigned(Shape) do begin
   if Shape=aShape then begin
    result:=false;
    exit;
   end else begin
    if Shape=fRigidBody.ShapeLast then begin
     break;
    end else begin
     Shape:=Shape.ShapeNext;
    end;
   end;
  end;
 end;
 if assigned(fOnRayCastFilter) and not fOnRayCastFilter(aPoint,aNormal,aTime,aShape) then begin
  result:=false;
  exit;
 end;
 result:=Vector3Dot(aNormal,fWorldUp)>0.0;
end;

procedure TKraftRayCastVehicle.Reset;
begin
 fIsAcceleration:=false;
 fIsReverseAcceleration:=false;
 fJumpState:=0;
 fDriftAfterJump:=false;
 fSuperJumpState:=0;
 fDriftAfterSuperJump:=false;
 fAfterFlightSlipperyTiresTime:=0.0;
 fBrakeSlipperyTiresTime:=0.0;
 fHandBrakeSlipperyTiresTime:=0.0;
 fDriftSlipperyTiresTime:=0.0;
 fSteeringAngle:=0.0;
 fFlightSteering:=0.0;
 fAccelerationRescueForceState.Reset;
 fReverseAccelerationRescueForceState.Reset;
end;

procedure TKraftRayCastVehicle.Finish;
var Index:TKraftInt32;
    SettingWheel:TKraftRayCastVehicle.TSettings.TWheel;
    SettingAxle:TKraftRayCastVehicle.TSettings.TAxle;
    SettingAckermannGroup:TKraftRayCastVehicle.TSettings.TAckermannGroup;
    Wheel:TKraftRayCastVehicle.TWheel;
    Axle:TKraftRayCastVehicle.TAxle;
    AckermannGroup:TKraftRayCastVehicle.TAckermannGroup;
    MassSum:TKraftScalar;
begin

 fWheels.Clear;
 fCountPoweredWheels:=0;
 for Index:=0 to fSettings.fWheels.Count-1 do begin
  SettingWheel:=fSettings.fWheels[Index];
  Wheel:=TKraftRayCastVehicle.TWheel.Create(self,SettingWheel);
  if Wheel.fSettings.fPowered then begin
   inc(fCountPoweredWheels);
  end;
  fWheels.Add(Wheel);
 end;

 fAxles.Clear;
 for Index:=0 to fSettings.fAxles.Count-1 do begin
  SettingAxle:=fSettings.fAxles[Index];
  Axle:=TKraftRayCastVehicle.TAxle.Create(self,SettingAxle);
  fAxles.Add(Axle);
 end;

 fAckermannGroups.Clear;
 for Index:=0 to fSettings.fAckermannGroups.Count-1 do begin
  SettingAckermannGroup:=fSettings.fAckermannGroups[Index];
  AckermannGroup:=TKraftRayCastVehicle.TAckermannGroup.Create(self,SettingAckermannGroup);
  fAckermannGroups.Add(AckermannGroup);
 end;

 if not (assigned(fRigidBody) and assigned(fShape)) then begin

  MassSum:=fSettings.fChassisMass;
  for Index:=0 to fWheels.Count-1 do begin
   Wheel:=fWheels[Index];
   if assigned(Wheel) then begin
    MassSum:=MassSum+Wheel.fSettings.fMass;
   end;
  end;

  fRigidBody:=TKraftRigidBody.Create(fPhysics);
  fRigidBody.SetRigidBodyType(krbtDYNAMIC);
  fRigidBody.CollisionGroups:=fCollisionGroups;
  fRigidBody.CollideWithCollisionGroups:=fCollideWithCollisionGroups;
  fRigidBody.AngularVelocityDamp:=fSettings.fAngularVelocityDamp;
  fRigidBody.LinearVelocityDamp:=fSettings.fLinearVelocityDamp;

  if assigned(fConvexHull) then begin
   fShape:=TKraftShapeConvexHull.Create(fPhysics,fRigidBody,fConvexHull);
  end else begin
   fShape:=TKraftShapeBox.Create(fPhysics,fRigidBody,Vector3(fSettings.fWidth*0.5,fSettings.fHeight*0.5,fSettings.fLength*0.5));
  end;
  fShape.LocalTransform:=Matrix4x4Translate(fSettings.fShapeOffset);
  fShape.Flags:=fShape.Flags+[ksfHasForcedCenterOfMass];
  fShape.ForcedCenterOfMass.Vector:=fSettings.fCenterOfMass;
  fShape.ForcedMass:=MassSum;
  fShape.Restitution:=fSettings.fRigidBodyRestitution;
  fShape.RestitutionThreshold:=fSettings.fRigidBodyRestitutionThreshold;
  fShape.Density:=fSettings.fRigidBodyDensity;
  fShape.Friction:=fSettings.fRigidBodyFriction;

  fRigidBody.Finish;

  fOwnsRigidBody:=true;
  fOwnsFreeShape:=true;

 end else begin

  fOwnsRigidBody:=false;
  fOwnsFreeShape:=false;

  fShape.Flags:=fShape.Flags+[ksfHasForcedCenterOfMass];
  fShape.ForcedCenterOfMass.Vector:=fSettings.fCenterOfMass;
  fShape.ForcedMass:=MassSum;
  fShape.Restitution:=fSettings.fRigidBodyRestitution;
  fShape.RestitutionThreshold:=fSettings.fRigidBodyRestitutionThreshold;
  fShape.Density:=fSettings.fRigidBodyDensity;
  fShape.Friction:=fSettings.fRigidBodyFriction;

  fRigidBody.CollisionGroups:=fCollisionGroups;
  fRigidBody.CollideWithCollisionGroups:=fCollideWithCollisionGroups;
  fRigidBody.AngularVelocityDamp:=fSettings.fAngularVelocityDamp;
  fRigidBody.LinearVelocityDamp:=fSettings.fLinearVelocityDamp;

 end;

 fShape.OnCanCollideWith:=ShapeCanCollideWith;

end;

procedure TKraftRayCastVehicle.UpdateWorldTransformVectors;
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

function TKraftRayCastVehicle.GetHandBrakeK:TKraftScalar;
begin
 result:=fHandBrakeSlipperyTiresTime/Max(0.1,fSettings.fHandBrakeSlipperyTime);
 result:=result*result*result*(result*((result*6.0)-15.0)+10.0);
end;

function TKraftRayCastVehicle.GetDriftK:TKraftScalar;
begin
 result:=fDriftSlipperyTiresTime/Max(0.1,fSettings.fDriftSlipperyTime);
 result:=result*result*result*(result*((result*6.0)-15.0)+10.0);
end;

function TKraftRayCastVehicle.GetSteeringHandBrakeK:TKraftScalar;
begin
 result:=0.4+((1.0-GetHandBrakeK)*0.6);
end;

function TKraftRayCastVehicle.GetSteerAngleLimitInDegrees(const aSpeedKMH:TKraftScalar):TKraftScalar;
var DriftK:TKraftScalar;
begin
 result:=fSettings.fSteerAngleLimitEnvelope.GetValueAtTime(aSpeedKMH*GetSteeringHandBrakeK);
 DriftK:=GetDriftK;
 if not IsZero(DriftK) then begin
  result:=Lerp(result,fSettings.fDriftSteerAngleLimitEnvelope.GetValueAtTime(aSpeedKMH),DriftK);
 end;
end;

function TKraftRayCastVehicle.GetSpeed:TKraftScalar;
var LinearVelocity,WorldSpaceForward,ProjectedVector:TKraftVector3;
    Factor:TKraftScalar;
begin
 LinearVelocity:=fRigidBody.LinearVelocity;
 WorldSpaceForward:=Vector3(PKraftRawVector3(@fRigidBody.WorldTransform[2,0])^);
 Factor:=Vector3Dot(WorldSpaceForward,LinearVelocity);
 ProjectedVector:=Vector3ScalarMul(WorldSpaceForward,Factor);
 result:=Vector3Length(ProjectedVector)*Sign(Factor);
end;

function TKraftRayCastVehicle.GetAccelerationOrBrakeForceMagnitude(const aEnvelope:TEnvelope;const aSpeedKMH,aDeltaTime:TKraftScalar;const aBraking:boolean):TKraftScalar;
const Inv3d6=1.0/3.6;
var Index,Count:TKraftInt32;
    SpeedKMH,Mass,MinTime,MaxTime,TimeNow,CurrentSpeed,CurrentSpeedDifference,
    Step,StepTime,StepSpeed,StepSpeedDifference:TKraftScalar;
begin

 SpeedKMH:=aSpeedKMH;

 Mass:=fRigidBody.Mass;

 Count:=aEnvelope.Count;

 case Count of
  0:begin
   // No points, so no acceleration or braking
   result:=0.0;
  end;
  1:begin
   // In the case of only one point, use it
   if aBraking then begin
    result:=Max(0.0,((SpeedKMH-aEnvelope.fPoints[0].fValue)*Inv3d6)*Mass);
   end else begin
    result:=Max(0.0,((aEnvelope.fPoints[0].fValue-SpeedKMH)*Inv3d6)*Mass);
   end;
  end;
  else begin

   // Use binary search to find the closest point
   MinTime:=aEnvelope.fPoints[0].fTime;
   MaxTime:=aEnvelope.fPoints[Count-1].fTime;

   Step:=MaxTime-MinTime;

   TimeNow:=MinTime;

   // But first check if the speed is below the maximum speed at acceleraton or above the minimum speed at braking
   if ((not aBraking) and (SpeedKMH<aEnvelope.fPoints[Count-1].fValue)) or
      (aBraking and (SpeedKMH>aEnvelope.fPoints[0].fValue)) then begin

    // Do the actual binary search

    for Index:=0 to fSettings.fCurveEvaluationAccuracy-1 do begin

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

    // We have found the closest point, so use it
    if aBraking then begin
     result:=aEnvelope.GetValueAtTime(TimeNow-aDeltaTime);
    end else begin
     result:=aEnvelope.GetValueAtTime(TimeNow+aDeltaTime);
    end;

   end else begin

    if aBraking then begin

     // Minimum speed reached, so use the last point
     result:=aEnvelope.fPoints[0].fValue;

    end else begin

     // Maximum speed reached, so use the last point
     result:=aEnvelope.fPoints[Count-1].fValue;

    end;

   end;

   // Convert it to force magnitude
   if aBraking then begin
    result:=Max(0.0,(SpeedKMH-result)*Inv3d6*Mass);
   end else begin
    result:=Max(0.0,(result-SpeedKMH)*Inv3d6*Mass);
   end;

  end;

 end;

end;

function TKraftRayCastVehicle.CalcAccelerationForceMagnitude:TKraftScalar;
begin
 if fIsAcceleration or fIsReverseAcceleration then begin
  if fIsAcceleration then begin
   fReverseAccelerationRescueForceState.Reset;
   result:=GetAccelerationOrBrakeForceMagnitude(fSettings.fAccelerationCurveEnvelope,fSpeedKMH,fDeltaTime,false);
   result:=Max(fAccelerationRescueForceState.GetOverrideForce(fSettings.fAccelerationRescueForce,fAbsoluteSpeedKMH,result,fDeltaTime),fSettings.fAccelerationMinimumForce);
  end else begin
   fAccelerationRescueForceState.Reset;
   result:=GetAccelerationOrBrakeForceMagnitude(fSettings.fReverseAccelerationCurveEnvelope,-fSpeedKMH,fDeltaTime,false);
   result:=-Max(fReverseAccelerationRescueForceState.GetOverrideForce(fSettings.fReverseAccelerationRescueForce,fAbsoluteSpeedKMH,result,fDeltaTime),fSettings.fReverseAccelerationMinimumForce);
  end;
 end else begin
  fReverseAccelerationRescueForceState.Reset;
  fAccelerationRescueForceState.Reset;
  result:=0.0;
 end;
end;

function TKraftRayCastVehicle.CalcBrakeForceMagnitude:TKraftScalar;
begin
 if fMovingForward then begin
  result:=GetAccelerationOrBrakeForceMagnitude(fSettings.fBrakeCurveEnvelope,fSpeedKMH,fDeltaTime,true);
 end else begin
  result:=GetAccelerationOrBrakeForceMagnitude(fSettings.fReverseBrakeCurveEnvelope,-fSpeedKMH,fDeltaTime,true);
 end;
end;

procedure TKraftRayCastVehicle.UpdateGlobals;
begin

 fSpeed:=GetSpeed;
 fSpeedKMH:=fSpeed*3.6;
 fAbsoluteSpeedKMH:=abs(fSpeed)*3.6;

 fMovingForward:=fSpeed>0.0;

end;

procedure TKraftRayCastVehicle.UpdateInput;
var Vertical,Horizontal,NewSteerAngle,AngleReturnSpeedDegressPerSecond,Factor:TKraftScalar;
    IsBrakeNow,IsHandBrakeNow:boolean;
begin

 if fControllable then begin
  Vertical:=fInputVertical;
  Horizontal:=fInputHorizontal;
  if fInputReset then begin
//  Reset;
  end;
 end else begin
  Vertical:=0.0;
  Horizontal:=0.0;
 end;

 fAccelerationInput:=Min(Max(Vertical,-1.0),1.0);

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
  fHandBrakeSlipperyTiresTime:=Max(0.1,fSettings.fHandBrakeSlipperyTime);
 end;

 fIsBrake:=IsBrakeNow;

 fIsHandBrake:=IsHandBrakeNow and not (fIsAcceleration or fIsReverseAcceleration);

 fIsDrift:=fInputDrift or fDriftAfterJump or fDriftAfterSuperJump;

 fIsJump:=fInputJump;

 fIsSuperJump:=fInputSuperJump;

 if fIsDrift then begin
  fDriftSlipperyTiresTime:=Max(0.1,fSettings.fDriftSlipperyTime);
 end;

 if abs(Horizontal)>0.001 then begin
  Factor:=fSettings.fSteeringSpeedEnvelope.GetValueAtTime(fAbsoluteSpeedKMH*GetSteeringHandBrakeK);
  if not IsZero(fDriftSlipperyTiresTime) then begin
   Factor:=Lerp(Factor,fSettings.fDriftSteeringSpeedEnvelope.GetValueAtTime(fAbsoluteSpeedKMH),GetDriftK);
  end;
  NewSteerAngle:=fSteeringAngle+(Horizontal*Factor*fDeltaTime);
  fSteeringAngle:=Min(abs(NewSteerAngle),GetSteerAngleLimitInDegrees(fSpeedKMH))*Sign(NewSteerAngle);
 end else begin
  Factor:=fSettings.fSteeringResetSpeedEnvelope.GetValueAtTime(fAbsoluteSpeedKMH);
  if not IsZero(fDriftSlipperyTiresTime) then begin
   Factor:=Lerp(Factor,fSettings.fDriftSteeringResetSpeedEnvelope.GetValueAtTime(fAbsoluteSpeedKMH),GetDriftK);
  end;
  AngleReturnSpeedDegressPerSecond:=Factor*Clamp01(fAbsoluteSpeedKMH*0.5);
  fSteeringAngle:=Max(abs(fSteeringAngle)-(AngleReturnSpeedDegressPerSecond*fDeltaTime),0.0)*Sign(fSteeringAngle);
 end;

 if fInputAI then begin

  NewSteerAngle:=fInputAISteering*RAD2DEG;

  fSteeringAngle:=Min(abs(NewSteerAngle),GetSteerAngleLimitInDegrees(fSpeedKMH))*Sign(NewSteerAngle);

  fFlightSteering:=Lerp(fFlightSteering,Min(Max(InputAISteering*fInputAIFlightSteerFactor,-1.0),1.0),exp(-fDeltaTime*0.1));

 end else begin

  fFlightSteering:=Lerp(fFlightSteering,Horizontal,exp(-fDeltaTime*0.1));

 end;

 fAccelerationForceMagnitude:=CalcAccelerationForceMagnitude*Clamp01(0.8+((1.0-GetHandBrakeK)*0.2));//*Lerp(1.0,1.0,Clamp01(GetDriftK));

 if IsBrakeNow or IsHandBrakeNow then begin
  fBrakeForceMagnitude:=CalcBrakeForceMagnitude;
 end else begin
  fBrakeForceMagnitude:=0.0;
 end;

 if fIsAcceleration or fIsReverseAcceleration then begin
  fRigidBody.SetToAwake;
 end;

end;

procedure TKraftRayCastVehicle.UpdateSuspension;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 fHitAverageNormal:=Vector3Origin;
 fHitAverageNormalCount:=0;
 fCountGroundedWheels:=0;
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateSuspension;
  if Wheel.fIsGrounded then begin
   inc(fCountGroundedWheels);
  end;
 end;
end;

procedure TKraftRayCastVehicle.UpdateTractionAndGravityAndNearlyFlatGroundDetection;
var Normal,GravityDirection:TKraftVector3;
    Factor:TKraftScalar;
begin

 if fHitAverageNormalCount>0 then begin

  Normal:=Vector3Neg(Vector3Norm(fHitAverageNormal));

  GravityDirection:=Vector3Norm(fPhysics.Gravity.Vector);

  Factor:=Clamp01(fSettings.fDrivingTractionFactorEnvelope.GetValueAtTime(fAbsoluteSpeedKMH));

  if fSettings.fMaximumGravitySlopeAngle>EPSILON then begin
   // If there are any hit points derived from the suspension's raycasting or spherecasting, we
   // compute the average normal across all of them. This value is then used to ascertain whether
   // the vehicle is on a surface that's nearly parallel to the direction of gravity, indicating a
   // flat or nearly flat ground.
   // The calculated normal is compared to the gravity direction within the limits of a predefined
   // maximum slope angle. If the angle between the normal and gravity direction is less than or
   // equal to this maximum slope angle, the vehicle is considered to be on a nearly flat surface.
   // This assessment can enable putting the vehicle into a 'sleep mode' when it's on such a surface,
   // avoiding unnecessary computations or actions. For instance, it can prevent unintended sliding
   // when the vehicle is actually stationary on a nearly flat surface.
   if Vector3Dot(Normal,GravityDirection)>=cos(fSettings.fMaximumGravitySlopeAngle*DEG2RAD) then begin
    Factor:=1.0;
   end;
  end;

  if Factor>EPSILON then begin
   fRigidBody.Flags:=fRigidBody.Flags+[krbfHasOwnGravity];
   fRigidBody.Gravity.Vector:=Vector3ScalarMul(Vector3Norm(Vector3Lerp(GravityDirection,Normal,Factor)),Vector3Length(fPhysics.Gravity.Vector));
  end else begin
   fRigidBody.Flags:=fRigidBody.Flags-[krbfHasOwnGravity];
  end;

 end else begin
  fRigidBody.Flags:=fRigidBody.Flags-[krbfHasOwnGravity];
 end;
end;

procedure TKraftRayCastVehicle.UpdateAckermannSteering;
var Index:TKraftInt32;
    Wheel:TWheel;
    AckermannGroup:TAckermannGroup;
begin

 // Update steering without Ackermann steering as fallback first
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  if Wheel.fSettings.fSteering then begin
   Wheel.fYawRad:=fSteeringAngle*DEG2RAD;
  end else begin
   Wheel.fYawRad:=0.0;
  end;
 end;

 // Then do the Ackermann steering by overwriting the steering angles per wheel
 for Index:=0 to fAckermannGroups.Count-1 do begin
  AckermannGroup:=fAckermannGroups[Index];
  AckermannGroup.UpdateAckermannSteering;
 end;

end;

procedure TKraftRayCastVehicle.UpdateSteering;
var Index:TKraftInt32;
    Wheel:TWheel;
    FlightSteeringTorqueFactor:TKraftScalar;
begin
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateLaterialForce;
 end;
 if ((fSuperJumpState=1) or (fSuperJumpState=2)) and not IsZero(fSettings.fFlightSteeringTorqueFactorOnSuperJump) then begin
  FlightSteeringTorqueFactor:=fSettings.fFlightSteeringTorqueFactorOnSuperJump;
 end else if ((fJumpState=1) or (fJumpState=2)) and not IsZero(fSettings.fFlightSteeringTorqueFactorOnJump) then begin
  FlightSteeringTorqueFactor:=fSettings.fFlightSteeringTorqueFactorOnJump;
 end else begin
  FlightSteeringTorqueFactor:=fSettings.fFlightSteeringTorqueFactor;
 end;
 if (fCountGroundedWheels=0) and not (IsZero(FlightSteeringTorqueFactor) or IsZero(fFlightSteering)) then begin
  fRigidBody.AddBodyTorque(Vector3ScalarMul(Vector3(0.0,fFlightSteering,0.0),fRigidBody.Mass*FlightSteeringTorqueFactor),kfmForce,false);
 end;
end;

procedure TKraftRayCastVehicle.UpdateAcceleration;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateAcceleration;
 end;
end;

procedure TKraftRayCastVehicle.UpdateBraking;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateLongitudinalForce;
 end;
end;

procedure TKraftRayCastVehicle.UpdateAntiRollBar;
var Index:TKraftInt32;
    Axle:TAxle;
begin
 for Index:=0 to fAxles.Count-1 do begin
  Axle:=fAxles[Index];
  Axle.UpdateAntiRollBar;
 end;
end;

procedure TKraftRayCastVehicle.UpdateAirResistance;
var Velocity,Force:TKraftVector3;
begin
 Velocity:=fRigidBody.LinearVelocity;
 Force:=Vector3ScalarMul(Vector3Norm(Velocity),
                         -Clamp(fSettings.fAirResistance*Vector3Length(Vector3(fSettings.fWidth,
                                                                               fSettings.fHeight,
                                                                               fSettings.fLength)),
                                0.0,
                                Vector3Length(Velocity)));
{$ifdef DebugDraw}
 fDebugAirResistanceForce:=Force;
{$endif}
 if Vector3Length(Force)>EPSILON then begin
  fRigidBody.AddWorldForce(Force,kfmForce,false);
 end;
end;

procedure TKraftRayCastVehicle.UpdateDownForce;
var DownForceAmount:TKraftScalar;
    Force:TKraftVector3;
begin
 if (fCountGroundedWheels>0) and not IsZero(fSettings.fDownForceFactor) then begin
  DownForceAmount:=fSettings.fDownForceCurveEnvelope.GetValueAtTime(fAbsoluteSpeedKMH)*0.01;
  Force:=Vector3ScalarMul(fWorldDown,DownForceAmount*fSettings.fDownForceFactor);
{$ifdef DebugDraw}
  fDebugDownForceFactor:=Force;
{$endif}
  if Vector3Length(Force)>EPSILON then begin
   fRigidBody.AddWorldForce(Vector3ScalarMul(Force,fRigidBody.Mass),kfmForce,false);
  end;
{$ifdef DebugDraw}
 end else begin
  fDebugDownForceFactor:=Vector3Origin;
{$endif}
 end;
end;

procedure TKraftRayCastVehicle.ReleaseJump;
begin
 fJumpState:=4; // To the "multi-jump-prevention" phase
end;

procedure TKraftRayCastVehicle.UpdateJump;
begin
 // The jump state machine is a simple state machine with just five states:
 repeat
  case fJumpState of
   1:begin
    // Jump phase 1: The "maybe-still-on-the-ground-after-jump" phase but check if the vehicle is in the air, and if so, set the jump state to 2
    if (fCountGroundedWheels=0) or not fIsJump then begin
     fJumpState:=2;
    end else begin
     // If the vehicle is still on the ground, do nothing and abort the repeat loop
     break;
    end;
   end;
   2:begin
    // Jump phase 2: The "in-the-air-after-jump" phase but check if the vehicle is on the ground again, and if so, set the jump state to 3 or 4
    if fCountGroundedWheels>0 then begin
     if assigned(fOnGroundContactAfterJump) then begin
      // The "ground-hit-after-jump" callback, for example, for playing a sound or start drifting as at Mario Kart
      if fOnGroundContactAfterJump(self) then begin
       fJumpState:=3; // Drifting or something-else-after-jump action, so delay the "multi-jump-prevention" phase until the one action is finished, by calling "ReleaseJump"
      end else begin
       if fSettings.fDriftAfterJump then begin
        fDriftAfterJump:=true;
        fJumpState:=3; // Drifting or something-else-after-jump action, so delay the "multi-jump-prevention" phase until the one action is finished, by calling "ReleaseJump"
       end else begin
        fJumpState:=4; // Direct to the "multi-jump-prevention" phase
       end;
      end;
     end else begin
      fJumpState:=4; // Direct to the "multi-jump-prevention" phase
     end;
    end else begin
     // If the vehicle is still in the air, do nothing and abort the repeat loop
     break;
    end;
   end;
   3:begin
    // Jump phase 3: The "drifting-after-jump" phase, do nothing and abort the repeat loop, until "ReleaseJump" is called, for example after drifting and so on
    if fSettings.fDriftAfterJump and not fIsJump then begin
     fJumpState:=4; // Direct to the "multi-jump-prevention" phase
    end else begin
     break;
    end;
   end;
   4:begin
    // Jump phase 4: The "multi-jump-prevention" phase, so check if the jump button is released, and if so, reset the jump state to 0, so that
    // as long the jump button is still pressed, don't trigger a new jump
    if fIsJump then begin
     // If the jump button is still pressed, do nothing and abort the repeat loop
     break;
    end else begin
     // But if the jump button is released, reset the jump state to 0 for the next jump
     fJumpState:=0;
     if assigned(fOnJumpDone) then begin
      fOnJumpDone(self); // The "jump done" callback, for example, for playing a sound
     end;
     fDriftAfterJump:=false;
    end;
   end;
   else {0:}begin
    // Jump phase 0: If vehicle is on the ground and the jump button is pressed, trigger a new jump
    if fIsJump and (fCountGroundedWheels>0) then begin
     fDriftAfterJump:=false;
     fJumpState:=1;
     fRigidBody.SetWorldForce(Vector3ScalarMul(fWorldUp,fSettings.JumpImpulse),kfmImpulse);
     if assigned(fOnJump) then begin
      fOnJump(self); // The "jump" callback, for example, for playing a sound
     end;
    end else begin
     // Otherwise if the jump button is not pressed, do nothing
    end;
    break; // Abort the repeat loop in any case at this special state, because it is the start "and" end of the jump state machine
   end;
  end;
 until false;
end;

procedure TKraftRayCastVehicle.ReleaseSuperJump;
begin
 fSuperJumpState:=4; // To the "multi-jump-prevention" phase
end;

procedure TKraftRayCastVehicle.UpdateSuperJump;
begin
 // The jump state machine is a simple state machine with just five states:
 repeat
  case fSuperJumpState of
   1:begin
    // Jump phase 1: The "maybe-still-on-the-ground-after-jump" phase but check if the vehicle is in the air, and if so, set the jump state to 2
    if (fCountGroundedWheels=0) or not fIsSuperJump then begin
     fSuperJumpState:=2;
    end else begin
     // If the vehicle is still on the ground, do nothing and abort the repeat loop
     break;
    end;
   end;
   2:begin
    // Jump phase 2: The "in-the-air-after-jump" phase but check if the vehicle is on the ground again, and if so, set the jump state to 3 or 4
    if fCountGroundedWheels>0 then begin
     if assigned(fOnGroundContactAfterSuperJump) then begin
      // The "ground-hit-after-jump" callback, for example, for playing a sound or start drifting as at Mario Kart
      if fOnGroundContactAfterSuperJump(self) then begin
       fSuperJumpState:=3; // Drifting or something-else-after-jump action, so delay the "multi-jump-prevention" phase until the one action is finished, by calling "ReleaseJump"
      end else begin
       if fSettings.fDriftAfterSuperJump then begin
        fDriftAfterSuperJump:=true;
        fSuperJumpState:=3; // Drifting or something-else-after-jump action, so delay the "multi-jump-prevention" phase until the one action is finished, by calling "ReleaseJump"
       end else begin
        fSuperJumpState:=4; // Direct to the "multi-jump-prevention" phase
       end;
      end;
     end else begin
      fSuperJumpState:=4; // Direct to the "multi-jump-prevention" phase
     end;
    end else begin
     // If the vehicle is still in the air, do nothing and abort the repeat loop
     break;
    end;
   end;
   3:begin
    // Jump phase 3: The "drifting-after-jump" phase, do nothing and abort the repeat loop, until "ReleaseJump" is called, for example after drifting and so on
    if fSettings.fDriftAfterSuperJump and not fIsSuperJump then begin
     fSuperJumpState:=4; // Direct to the "multi-jump-prevention" phase
    end else begin
     break;
    end;
   end;
   4:begin
    // Jump phase 4: The "multi-jump-prevention" phase, so check if the jump button is released, and if so, reset the jump state to 0, so that
    // as long the jump button is still pressed, don't trigger a new jump
    if fIsSuperJump then begin
     // If the jump button is still pressed, do nothing and abort the repeat loop
     break;
    end else begin
     // But if the jump button is released, reset the jump state to 0 for the next jump
     fSuperJumpState:=0;
     if assigned(fOnSuperJumpDone) then begin
      fOnSuperJumpDone(self); // The "jump done" callback, for example, for playing a sound
     end;
     fDriftAfterSuperJump:=false;
    end;
   end;
   else {0:}begin
    // Jump phase 0: If vehicle is on the ground and the jump button is pressed, trigger a new jump
    if fIsSuperJump and (fCountGroundedWheels>0) then begin
     fDriftAfterSuperJump:=false;
     fSuperJumpState:=1;
     fRigidBody.SetWorldForce(Vector3ScalarMul(fWorldUp,fSettings.SuperJumpImpulse),kfmImpulse);
     if assigned(fOnSuperJump) then begin
      fOnSuperJump(self); // The "jump" callback, for example, for playing a sound
     end;
    end else begin
     // Otherwise if the jump button is not pressed, do nothing
    end;
    break; // Abort the repeat loop in any case at this special state, because it is the start "and" end of the jump state machine
   end;
  end;
 until false;
end;

procedure TKraftRayCastVehicle.UpdateFlightStabilization;
var VehicleUp,AntiGravityUp,Axis,Torque,AngularVelocity:TKraftVector3;
begin

{$ifdef DebugDraw}
 fDebugFlightStabilizationTorque:=Vector3Origin;
{$endif}

 if fCountGroundedWheels=0{fWheels.Count} then begin

  fAfterFlightSlipperyTiresTime:=1.0;

  // Damp the angular velocity to avoid the vehicle spinning out of control, if wished
  AngularVelocity:=fRigidBody.AngularVelocity;
  if not IsZero(fSettings.fFlightStabilizationAngularVelocityDamping.x) then begin
   AngularVelocity.x:=AngularVelocity.x*Clamp01(1.0-exp((-fDeltaTime)*fSettings.fFlightStabilizationAngularVelocityDamping.x));
  end;
  if not IsZero(fSettings.fFlightStabilizationAngularVelocityDamping.y) then begin
   AngularVelocity.y:=AngularVelocity.y*Clamp01(1.0-exp((-fDeltaTime)*fSettings.fFlightStabilizationAngularVelocityDamping.x));
  end;
  if not IsZero(fSettings.fFlightStabilizationAngularVelocityDamping.z) then begin
   AngularVelocity.z:=AngularVelocity.z*Clamp01(1.0-exp((-fDeltaTime)*fSettings.fFlightStabilizationAngularVelocityDamping.x));
  end;
  fRigidBody.AngularVelocity:=AngularVelocity;

  // To avoid the vehicle going backwards/forwards (or rolling sideways),
  // set the pitch/roll to 0 before applying the 'straightening' impulse.
  if not IsZero(fSettings.fFlightStabilizationDamping) then begin
   fRigidBody.AngularVelocity:=Vector3Lerp(fRigidBody.AngularVelocity,
                                           Vector3(0.0,fRigidBody.AngularVelocity.y,0.0),
                                           Clamp01(1.0-exp((-fDeltaTime)*fSettings.fFlightStabilizationDamping)));
  end;

  // Give a nicely balanced feeling for rebalancing the vehicle with keep-up-right-forward
  if not IsZero(fSettings.fFlightStabilizationForceFactor) then begin

   // Length of axis depends on the angle - i.e. the further awat
   // the vehicle is from being upright, the larger the applied impulse
   // will be, resulting in fast changes when the vehicle is on its
   // side, but not overcompensating (and therefore shaking) when
   // the vehicle is not much away from being upright.
   Axis:=Vector3Norm(Vector3Cross(fWorldUp,Vector3Norm(Vector3Neg(fPhysics.Gravity.Vector))));

   Torque:=Vector3ScalarMul(Axis,fSettings.fFlightStabilizationForceFactor);

   if Vector3Length(Torque)>EPSILON then begin
{$ifdef DebugDraw}
    fDebugFlightStabilizationTorque:=Torque;
{$endif}
    fRigidBody.AddWorldTorque(Vector3ScalarMul(Torque,fRigidBody.Mass),kfmForce,false);
   end;
  end;

 end;

end;

procedure TKraftRayCastVehicle.UpdateKeepUpright;
var KeepUpNormal,NewUp,Axis,Torque:TKraftVector3;
begin

{$ifdef DebugDraw}
 fDebugKeepUprightTorque:=Vector3Origin;
{$endif}

if not (IsZero(fSettings.fKeepUprightForceFactor) or IsZero(fSettings.fKeepUprightThreshold)) then begin

  KeepUpNormal:=Vector3Neg(fPhysics.Gravity.Vector);

  NewUp:=Vector3Norm(KeepUpNormal);

  if Vector3Dot(fWorldUp,NewUp)<fSettings.fKeepUprightThreshold then begin

   Axis:=Vector3Norm(Vector3Cross(fWorldUp,NewUp));

   Torque:=Vector3ScalarMul(Axis,fSettings.fKeepUprightForceFactor);
   if Vector3Length(Torque)>1e-6 then begin
{$ifdef DebugDraw}
    Vector3DirectAdd(fDebugKeepUprightTorque,Torque);
{$endif}
    fRigidBody.AddWorldTorque(Vector3ScalarMul(Torque,fRigidBody.Mass),kfmForce,false);
   end;

  end;

 end;

end;

procedure TKraftRayCastVehicle.UpdateWheelRotations;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateWheelRotation;
 end;
end;

procedure TKraftRayCastVehicle.UpdateVisuals;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.UpdateVisuals;
 end;
end;

procedure TKraftRayCastVehicle.Update(const aDeltaTime:TKraftScalar);
begin

 fDeltaTime:=aDeltaTime;
 fInverseDeltaTime:=1.0/fDeltaTime;

 UpdateWorldTransformVectors;

 UpdateGlobals;

 UpdateInput;

{if krbfAwake in fRigidBody.Flags then}begin
  UpdateSuspension;
  UpdateTractionAndGravityAndNearlyFlatGroundDetection;
  UpdateAckermannSteering;
  UpdateSteering;
  UpdateAcceleration;
  UpdateBraking;
  UpdateAntiRollBar;
  UpdateAirResistance;
  UpdateDownForce;
  UpdateJump;
  UpdateSuperJump;
  UpdateFlightStabilization;
  UpdateKeepUpright;
 end;

 UpdateWheelRotations;

 UpdateVisuals;

 fAfterFlightSlipperyTiresTime:=Max(0.0,fAfterFlightSlipperyTiresTime-fDeltaTime);

 fBrakeSlipperyTiresTime:=Max(0.0,fBrakeSlipperyTiresTime-fDeltaTime);

 fHandBrakeSlipperyTiresTime:=Max(0.0,fHandBrakeSlipperyTiresTime-fDeltaTime);

 fDriftSlipperyTiresTime:=Max(0.0,fDriftSlipperyTiresTime-fDeltaTime);

end;

procedure TKraftRayCastVehicle.StoreWorldTransforms;
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 UpdateWorldTransformVectors;
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.StoreWorldTransforms;
 end;
 fLastWorldTransform:=fWorldTransform;
 fLastWorldRight:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[0,0]))^);
 fLastWorldLeft:=Vector3Neg(fLastWorldRight);
 fLastWorldUp:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[1,0]))^);
 fLastWorldDown:=Vector3Neg(fLastWorldUp);
 fLastWorldForward:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[2,0]))^);
 fLastWorldBackward:=Vector3Neg(fLastWorldForward);
 fLastWorldPosition:=Vector3(PKraftRawVector3(pointer(@fLastWorldTransform[3,0]))^);
{$ifdef DebugDraw}
 fLastDebugAirResistanceForce:=fDebugAirResistanceForce;
 fLastDebugDownForceFactor:=fDebugDownForceFactor;
 fLastDebugFlightStabilizationTorque:=fDebugFlightStabilizationTorque;
 fLastDebugKeepUprightTorque:=fDebugKeepUprightTorque;
{$endif}
end;

procedure TKraftRayCastVehicle.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
var Index:TKraftInt32;
    Wheel:TWheel;
begin
 UpdateWorldTransformVectors;
 for Index:=0 to fWheels.Count-1 do begin
  Wheel:=fWheels[Index];
  Wheel.InterpolateWorldTransforms(aAlpha);
 end;
 fVisualWorldTransform:=Matrix4x4Slerp(fLastWorldTransform,fWorldTransform,aAlpha);
 fVisualWorldRight:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[0,0]))^);
 fVisualWorldLeft:=Vector3Neg(fVisualWorldRight);
 fVisualWorldUp:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[1,0]))^);
 fVisualWorldDown:=Vector3Neg(fVisualWorldUp);
 fVisualWorldForward:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[2,0]))^);
 fVisualWorldBackward:=Vector3Neg(fVisualWorldForward);
 fVisualWorldPosition:=Vector3(PKraftRawVector3(pointer(@fVisualWorldTransform[3,0]))^);
{$ifdef DebugDraw}
 fVisualDebugAirResistanceForce:=Vector3Lerp(fLastDebugAirResistanceForce,fDebugAirResistanceForce,aAlpha);
 fVisualDebugDownForceFactor:=Vector3Lerp(fLastDebugDownForceFactor,fDebugDownForceFactor,aAlpha);
 fVisualDebugFlightStabilizationTorque:=Vector3Lerp(fLastDebugFlightStabilizationTorque,fDebugFlightStabilizationTorque,aAlpha);
 fVisualDebugKeepUprightTorque:=Vector3Lerp(fLastDebugKeepUprightTorque,fDebugKeepUprightTorque,aAlpha);
{$endif}
end;

{$ifdef DebugDraw}
procedure TKraftRayCastVehicle.DebugDraw;
const SphereSlices=8;
      SphereStacks=8;
var Index,OtherIndex,OtherOtherIndex,SliceIndex,StackIndex:TKraftInt32;
    AckermannGroup:TAckermannGroup;
    Axle:TAxle;
    Wheel:TWheel;
    v0,v1,v2,v3,v:TKraftVector3;
    Color:TKraftVector4;
    DeltaTheta,DeltaPhi,Phi,PhiNext,Theta,ThetaNext,
    SinusTheta,CosinusTheta,SinusThetaNext,CosinusThetaNext,
    SinusPhi,CosinusPhi,SinusPhiNext,CosinusPhiNext:TKraftScalar;
begin
{$ifndef NoOpenGL}
 glDisable(GL_DEPTH_TEST);
{$endif}

 v1:=Vector3Origin;
 for Index:=0 to fAckermannGroups.Count-1 do begin
  AckermannGroup:=fAckermannGroups[Index];

  if AckermannGroup.fAxles.Count>0 then begin

   Color:=Vector4(0.0625,0.125,0.5,1.0);

   for OtherIndex:=0 to AckermannGroup.fAxles.Count-1 do begin

    Axle:=AckermannGroup.fAxles[OtherIndex];
    if Axle.fWheels.Count>0 then begin

     v0:=v1;
     v1:=Vector3Origin;
     for OtherOtherIndex:=0 to Axle.fWheels.Count-1 do begin
      Vector3DirectAdd(v1,Axle.fWheels[OtherOtherIndex].GetSuspensionRelativePosition);
     end;
     v1:=Vector3TermMatrixMul(Vector3ScalarMul(v1,1.0/Axle.fWheels.Count),fVisualWorldTransform);

     if OtherIndex>0 then begin

{$ifdef NoOpenGL}
      if assigned(fDebugDrawLine) then begin
       fDebugDrawLine(v0,v1,Color);
      end;
{$else}
      glColor4fv(@Color);
      glBegin(GL_LINE_STRIP);
      glVertex3fv(@v0);
      glVertex3fv(@v1);
      glEnd;
{$endif}

     end;

    end;

   end;

  end;


 end;

 for Index:=0 to fAxles.Count-1 do begin
  Axle:=fAxles[Index];

  Color:=Vector4(0.0,0.0,1.0,1.0);

  v1:=Vector3Origin;
  for OtherIndex:=0 to Axle.fWheels.Count-1 do begin
   Wheel:=Axle.fWheels[OtherIndex];
   if OtherIndex>0 then begin
    v0:=v1;
   end;
   v1:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
   if OtherIndex>0 then begin
{$ifdef NoOpenGL}
    if assigned(fDebugDrawLine) then begin
     fDebugDrawLine(v0,v1,Color);
    end;
{$else}
    glColor4fv(@Color);
    glBegin(GL_LINE_STRIP);
    glVertex3fv(@v0);
    glVertex3fv(@v1);
    glEnd;
{$endif}
   end;
  end;

 end;

 begin

  v:=Vector3TermMatrixMul(fRigidBody.Sweep.LocalCenter,fVisualWorldTransform);

  v0:=Vector3Add(v,Vector3ScalarMul(fVisualWorldDown,0.1));
  v1:=Vector3Add(v,Vector3ScalarMul(fVisualWorldUp,0.1));
  Color:=Vector4(0.0,1.0,1.0,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=Vector3Add(v,Vector3ScalarMul(fVisualWorldLeft,0.1));
  v1:=Vector3Add(v,Vector3ScalarMul(fVisualWorldRight,0.1));
  Color:=Vector4(0.0,1.0,1.0,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=Vector3Add(v,Vector3ScalarMul(fVisualWorldBackward,0.1));
  v1:=Vector3Add(v,Vector3ScalarMul(fVisualWorldForward,0.1));
  Color:=Vector4(0.0,1.0,1.0,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=v;
  v1:=Vector3Add(v0,Vector3ScalarMul(fVisualDebugAirResistanceForce,1.0));
  Color:=Vector4(0.0,1.0,0.0,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=v;
  v1:=Vector3Add(v0,Vector3ScalarMul(fVisualDebugDownForceFactor,1.0));
  Color:=Vector4(0.5,0.25,0.75,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=v;
  v1:=Vector3Add(v0,Vector3ScalarMul(fVisualDebugFlightStabilizationTorque,1.0));
  Color:=Vector4(0.75,0.25,0.5,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  v0:=v;
  v1:=Vector3Add(v0,Vector3ScalarMul(fVisualDebugKeepUprightTorque,1.0));
  Color:=Vector4(0.25,0.75,0.5,1.0);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

 end;

 for Index:=0 to fWheels.Count-1 do begin

  Wheel:=fWheels[Index];

  if Wheel.fIsGrounded then begin
   Color:=Vector4(0.0,0.0,1.0,1.0);
  end else begin
   Color:=Vector4(1.0,0.0,1.0,1.0);
  end;

  v0:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
  v1:=Vector3Add(v0,Vector3ScalarMul(fVisualWorldDown,Wheel.fVisualSuspensionLength));
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  Color:=Vector4(1.0,0.0,1.0,1.0);
  v0:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
  v1:=Vector3Add(v0,Wheel.fVisualDebugAntiRollForceFactor);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  Color:=Vector4(1.0,0.0,0.0,1.0);
  v0:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
  v1:=Vector3Add(v0,Wheel.fVisualDebugAccelerationForce);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  Color:=Vector4(1.0,0.5,0.5,1.0);
  v0:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
  v1:=Vector3Add(v0,Wheel.fVisualDebugLongitudinalForce);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  Color:=Vector4(1.0,0.75,0.25,1.0);
  v0:=Vector3TermMatrixMul(Wheel.GetSuspensionRelativePosition,fVisualWorldTransform);
  v1:=Vector3Add(v0,Wheel.fVisualDebugLaterialForce);
{$ifdef NoOpenGL}
  if assigned(fDebugDrawLine) then begin
   fDebugDrawLine(v0,v1,Color);
  end;
{$else}
  glColor4fv(@Color);
  glBegin(GL_LINE_STRIP);
  glVertex3fv(@v0);
  glVertex3fv(@v1);
  glEnd;
{$endif}

  if Wheel.fSettings.fUseSphereCast then begin
   if Wheel.fIsGrounded then begin
    Color:=Vector4(0.0625,0.25,0.0625,1.0);
   end else begin
    Color:=Vector4(0.25,0.0625,0.0625,1.0);
   end;
{$ifndef NoOpenGL}
   glColor4fv(@Color);
   glDisable(GL_CULL_FACE);
   glBegin(GL_LINES);
{$endif}
   v:=Vector3TermMatrixMul(Vector3Origin,Wheel.fVisualWorldTransform);
   DeltaTheta:=PI*2.0/SphereSlices;
   DeltaPhi:=PI/SphereStacks;
   for SliceIndex:=0 to SphereSlices-1 do begin
    Theta:=SliceIndex*DeltaTheta;
    ThetaNext:=(SliceIndex+1)*DeltaTheta;
    SinusTheta:=sin(Theta);
    CosinusTheta:=cos(Theta);
    SinusThetaNext:=sin(ThetaNext);
    CosinusThetaNext:=cos(ThetaNext);
    for StackIndex:=0 to SphereStacks-1 do begin
     Phi:=StackIndex*DeltaPhi;
     PhiNext:=(StackIndex+1)*DeltaPhi;
     SinusPhi:=sin(Phi);
     CosinusPhi:=cos(Phi);
     SinusPhiNext:=sin(PhiNext);
     CosinusPhiNext:=cos(PhiNext);
     v0:=Vector3TermMatrixMul(Vector3ScalarMul(Vector3(SinusPhi*CosinusTheta,SinusPhi*SinusTheta,CosinusPhi),Wheel.fSettings.Radius),Wheel.fVisualWorldTransform);
     v1:=Vector3TermMatrixMul(Vector3ScalarMul(Vector3(SinusPhi*CosinusThetaNext,SinusPhi*SinusThetaNext,CosinusPhi),Wheel.fSettings.Radius),Wheel.fVisualWorldTransform);
     v2:=Vector3TermMatrixMul(Vector3ScalarMul(Vector3(SinusPhiNext*CosinusThetaNext,SinusPhiNext*SinusThetaNext,CosinusPhiNext),Wheel.fSettings.Radius),Wheel.fVisualWorldTransform);
     v3:=Vector3TermMatrixMul(Vector3ScalarMul(Vector3(SinusPhiNext*CosinusTheta,SinusPhiNext*SinusTheta,CosinusPhiNext),Wheel.fSettings.Radius),Wheel.fVisualWorldTransform);
{$ifdef NoOpenGL}
     if assigned(fDebugDrawLine) then begin
      fDebugDrawLine(v0,v1,Color);
      fDebugDrawLine(v1,v2,Color);
      fDebugDrawLine(v2,v3,Color);
      fDebugDrawLine(v3,v0,Color);
     end;
{$else}
     glVertex3fv(@v0);
     glVertex3fv(@v1);
     glVertex3fv(@v1);
     glVertex3fv(@v2);
     glVertex3fv(@v2);
     glVertex3fv(@v3);
     glVertex3fv(@v3);
     glVertex3fv(@v0);
{$endif}
    end;
   end;
{$ifndef NoOpenGL}
   glEnd;
   glEnable(GL_CULL_FACE);
{$endif}
  end;
  begin
   if Wheel.fIsGrounded then begin
    Color:=Vector4(0.0625,1.0,0.0625,1.0);
   end else begin
    Color:=Vector4(1.0,0.0625,0.0625,1.0);
   end;
{$ifdef NoOpenGL}
   v:=Vector3TermMatrixMul(Vector3Origin,Wheel.fVisualWorldTransform);
   v0:=v;
   for OtherIndex:=0 to 16 do begin
    if assigned(fDebugDrawLine) then begin
     v1:=v0;
     v0:=Vector3TermMatrixMul(Vector3Add(Vector3Add(Vector3Origin,Vector3ScalarMul(Vector3YAxis,Sin((OtherIndex/16)*PI*2)*Wheel.fSettings.fRadius)),Vector3ScalarMul(Vector3ZAxis,Cos((OtherIndex/16)*PI*2)*Wheel.fSettings.Radius)),Wheel.fVisualWorldTransform);
     if OtherIndex>0 then begin
      fDebugDrawLine(v,v0,Color);
      fDebugDrawLine(v0,v1,Color);
     end;
    end;
   end;
{$else}
   glColor4fv(@Color);
   glDisable(GL_CULL_FACE);
   glBegin(GL_TRIANGLE_FAN);
   v0:=Vector3TermMatrixMul(Vector3Origin,Wheel.fVisualWorldTransform);
   glVertex3fv(@v0);
   for OtherIndex:=0 to 16 do begin
    v0:=Vector3TermMatrixMul(Vector3Add(Vector3Add(Vector3Origin,Vector3ScalarMul(Vector3YAxis,Sin((OtherIndex/16)*PI*2)*Wheel.fSettings.Radius)),Vector3ScalarMul(Vector3ZAxis,Cos((OtherIndex/16)*PI*2)*Wheel.fSettings.Radius)),Wheel.fVisualWorldTransform);
    glVertex3fv(@v0);
   end;
   glEnd;
   glEnable(GL_CULL_FACE);
{$endif}
  end;

 end;
{$ifndef NoOpenGL}
 glEnable(GL_DEPTH_TEST);
{$endif}
end;
{$endif}

end.
