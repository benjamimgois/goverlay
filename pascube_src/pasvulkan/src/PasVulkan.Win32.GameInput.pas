(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2024, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.Win32.GameInput;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

{$if defined(Windows)}

uses {$if defined(Windows)}
      Windows,
     {$elseif defined(Unix)}
      BaseUnix,UnixType,dl,
     {$ifend}
     SysUtils,
     Classes,
     PasMP,
     PasVulkan.Types;

const FACILITY_GAMEINPUT=906;

      GAMEINPUT_E_DEVICE_DISCONNECTED=TpvUInt32($838a0001);

      GAMEINPUT_E_DEVICE_NOT_FOUND=TpvUInt32($838a0002);

      GAMEINPUT_E_READING_NOT_FOUND=TpvUInt32($838a0003);

      GAMEINPUT_E_REFERENCE_READING_TOO_OLD=TpvUInt32($838a0004);

      GAMEINPUT_E_TIMESTAMP_OUT_OF_RANGE=TpvUInt32($838a0005);

      GAMEINPUT_E_INSUFFICIENT_FORCE_FEEDBACK_RESOURCES=TpvUInt32($838a0006);

type TGameInputKind=TpvUInt32;

const GameInputKindUnknown=$00000000;
      GameInputKindRawDeviceReport=$00000001;
      GameInputKindControllerAxis=$00000002;
      GameInputKindControllerButton=$00000004;
      GameInputKindControllerSwitch=$00000008;
      GameInputKindController=$0000000E;
      GameInputKindKeyboard=$00000010;
      GameInputKindMouse=$00000020;
      GameInputKindTouch=$00000100;
      GameInputKindMotion=$00001000;
      GameInputKindArcadeStick=$00010000;
      GameInputKindFlightStick=$00020000;
      GameInputKindGamepad=$00040000;
      GameInputKindRacingWheel=$00080000;
      GameInputKindUiNavigation=$01000000;

type TGameInputEnumerationKind=TpvUInt32;

const GameInputNoEnumeration=0;
      GameInputAsyncEnumeration=1;
      GameInputBlockingEnumeration=2;

type TGameInputFocusPolicy=TpvUInt32;

const GameInputDefaultFocusPolicy=$00000000;
      GameInputDisableBackgroundInput=$00000001;
      GameInputExclusiveForegroundInput=$00000002;

type TGameInputSwitchKind=TpvInt32;

const GameInputUnknownSwitchKind=-1;
      GameInput2WaySwitch=0;
      GameInput4WaySwitch=1;
      GameInput8WaySwitch=2;

type TGameInputSwitchPosition=TpvUInt32;
     PGameInputSwitchPosition=^TGameInputSwitchPosition;

const GameInputSwitchCenter=0;
      GameInputSwitchUp=1;
      GameInputSwitchUpRight=2;
      GameInputSwitchRight=3;
      GameInputSwitchDownRight=4;
      GameInputSwitchDown=5;
      GameInputSwitchDownLeft=6;
      GameInputSwitchLeft=7;
      GameInputSwitchUpLeft=8;

type TGameInputKeyboardKind=TpvInt32;

const GameInputUnknownKeyboard=-1;
      GameInputAnsiKeyboard=0;
      GameInputIsoKeyboard=1;
      GameInputKsKeyboard=2;
      GameInputAbntKeyboard=3;
      GameInputJisKeyboard=4;

type TGameInputMouseButtons=TpvUInt32;

const GameInputMouseNone=$00000000;
      GameInputMouseLeftButton=$00000001;
      GameInputMouseRightButton=$00000002;
      GameInputMouseMiddleButton=$00000004;
      GameInputMouseButton4=$00000008;
      GameInputMouseButton5=$00000010;
      GameInputMouseWheelTiltLeft=$00000020;
      GameInputMouseWheelTiltRight=$00000040;

type TGameInputTouchShape=TpvInt32;

const GameInputTouchShapeUnknown=-1;
      GameInputTouchShapePoint=0;
      GameInputTouchShape1DLinear=1;
      GameInputTouchShape1DRadial=2;
      GameInputTouchShape1DIrregular=3;
      GameInputTouchShape2DRectangular=4;
      GameInputTouchShape2DElliptical=5;
      GameInputTouchShape2DIrregular=6;

type TGameInputMotionAccuracy=TpvUInt32;

const GameInputMotionAccuracyUnknown=-1;
      GameInputMotionUnavailable=0;
      GameInputMotionUnreliable=1;
      GameInputMotionApproximate=2;
      GameInputMotionAccurate=3;

type TGameInputArcadeStickButtons=TpvUInt32;

const GameInputArcadeStickNone=$00000000;
      GameInputArcadeStickMenu=$00000001;
      GameInputArcadeStickView=$00000002;
      GameInputArcadeStickUp=$00000004;
      GameInputArcadeStickDown=$00000008;
      GameInputArcadeStickLeft=$00000010;
      GameInputArcadeStickRight=$00000020;
      GameInputArcadeStickAction1=$00000040;
      GameInputArcadeStickAction2=$00000080;
      GameInputArcadeStickAction3=$00000100;
      GameInputArcadeStickAction4=$00000200;
      GameInputArcadeStickAction5=$00000400;
      GameInputArcadeStickAction6=$00000800;
      GameInputArcadeStickSpecial1=$00001000;
      GameInputArcadeStickSpecial2=$00002000;

type TGameInputFlightStickButtons=TpvUInt32;

const GameInputFlightStickNone=$00000000;
      GameInputFlightStickMenu=$00000001;
      GameInputFlightStickView=$00000002;
      GameInputFlightStickFirePrimary=$00000004;
      GameInputFlightStickFireSecondary=$00000008;

type TGameInputGamepadButtons=TpvUInt32;

const GameInputGamepadNone=$00000000;
      GameInputGamepadMenu=$00000001;
      GameInputGamepadView=$00000002;
      GameInputGamepadA=$00000004;
      GameInputGamepadB=$00000008;
      GameInputGamepadX=$00000010;
      GameInputGamepadY=$00000020;
      GameInputGamepadDPadUp=$00000040;
      GameInputGamepadDPadDown=$00000080;
      GameInputGamepadDPadLeft=$00000100;
      GameInputGamepadDPadRight=$00000200;
      GameInputGamepadLeftShoulder=$00000400;
      GameInputGamepadRightShoulder=$00000800;
      GameInputGamepadLeftThumbstick=$00001000;
      GameInputGamepadRightThumbstick=$00002000;

type TGameInputRacingWheelButtons=TpvUInt32;

const GameInputRacingWheelNone=$00000000;
      GameInputRacingWheelMenu=$00000001;
      GameInputRacingWheelView=$00000002;
      GameInputRacingWheelPreviousGear=$00000004;
      GameInputRacingWheelNextGear=$00000008;
      GameInputRacingWheelDpadUp=$00000010;
      GameInputRacingWheelDpadDown=$00000020;
      GameInputRacingWheelDpadLeft=$00000040;
      GameInputRacingWheelDpadRight=$00000080;

type TGameInputUiNavigationButtons=TpvUInt32;

const GameInputUiNavigationNone=$00000000;
      GameInputUiNavigationMenu=$00000001;
      GameInputUiNavigationView=$00000002;
      GameInputUiNavigationAccept=$00000004;
      GameInputUiNavigationCancel=$00000008;
      GameInputUiNavigationUp=$00000010;
      GameInputUiNavigationDown=$00000020;
      GameInputUiNavigationLeft=$00000040;
      GameInputUiNavigationRight=$00000080;
      GameInputUiNavigationContext1=$00000100;
      GameInputUiNavigationContext2=$00000200;
      GameInputUiNavigationContext3=$00000400;
      GameInputUiNavigationContext4=$00000800;
      GameInputUiNavigationPageUp=$00001000;
      GameInputUiNavigationPageDown=$00002000;
      GameInputUiNavigationPageLeft=$00004000;
      GameInputUiNavigationPageRight=$00008000;
      GameInputUiNavigationScrollUp=$00010000;
      GameInputUiNavigationScrollDown=$00020000;
      GameInputUiNavigationScrollLeft=$00040000;
      GameInputUiNavigationScrollRight=$00080000;

type TGameInputDeviceStatus=TpvUInt32;

const GameInputDeviceNoStatus=$00000000;
      GameInputDeviceConnected=$00000001;
      GameInputDeviceInputEnabled=$00000002;
      GameInputDeviceOutputEnabled=$00000004;
      GameInputDeviceRawIoEnabled=$00000008;
      GameInputDeviceAudioCapture=$00000010;
      GameInputDeviceAudioRender=$00000020;
      GameInputDeviceSynchronized=$00000040;
      GameInputDeviceWireless=$00000080;
      GameInputDeviceUserIdle=$00100000;
      GameInputDeviceAnyStatus=$00FFFFFF;

type TGameInputBatteryStatus=TpvInt32;

const GameInputBatteryUnknown=-1;
      GameInputBatteryNotPresent=0;
      GameInputBatteryDischarging=1;
      GameInputBatteryIdle=2;
      GameInputBatteryCharging=3;

type TGameInputDeviceFamily=TpvInt32;

const GameInputFamilyVirtual=-1;
      GameInputFamilyAggregate=0;
      GameInputFamilyXboxOne=1;
      GameInputFamilyXbox360=2;
      GameInputFamilyHid=3;
      GameInputFamilyI8042=4;

type TGameInputDeviceCapabilities=TpvUInt32;

const GameInputDeviceCapabilityNone=$00000000;
      GameInputDeviceCapabilityAudio=$00000001;
      GameInputDeviceCapabilityPluginModule=$00000002;
      GameInputDeviceCapabilityPowerOff=$00000004;
      GameInputDeviceCapabilitySynchronization=$00000008;
      GameInputDeviceCapabilityWireless=$00000010;

type TGameInputRawDeviceReportKind=TpvUInt32;

const GameInputRawInputReport=0;
    GameInputRawOutputReport=1;
    GameInputRawFeatureReport=2;

type TGameInputRawDeviceReportItemFlags=TpvUInt32;

const GameInputDefaultItem=$00000000;
      GameInputConstantItem=$00000001;
      GameInputArrayItem=$00000002;
      GameInputRelativeItem=$00000004;
      GameInputWraparoundItem=$00000008;
      GameInputNonlinearItem=$00000010;
      GameInputStableItem=$00000020;
      GameInputNullableItem=$00000040;
      GameInputVolatileItem=$00000080;
      GameInputBufferedItem=$00000100;

type TGameInputRawDeviceItemCollectionKind=TpvInt32;

const GameInputUnknownItemCollection=-1;
      GameInputPhysicalItemCollection=0;
      GameInputApplicationItemCollection=1;
      GameInputLogicalItemCollection=2;
      GameInputReportItemCollection=3;
      GameInputNamedArrayItemCollection=4;
      GameInputUsageSwitchItemCollection=5;
      GameInputUsageModifierItemCollection=6;

type TGameInputRawDevicePhysicalUnitKind=TpvInt32;

const GameInputPhysicalUnitUnknown=-1;
      GameInputPhysicalUnitNone=0;
      GameInputPhysicalUnitTime=1;
      GameInputPhysicalUnitFrequency=2;
      GameInputPhysicalUnitLength=3;
      GameInputPhysicalUnitVelocity=4;
      GameInputPhysicalUnitAcceleration=5;
      GameInputPhysicalUnitMass=6;
      GameInputPhysicalUnitMomentum=7;
      GameInputPhysicalUnitForce=8;
      GameInputPhysicalUnitPressure=9;
      GameInputPhysicalUnitAngle=10;
      GameInputPhysicalUnitAngularVelocity=11;
      GameInputPhysicalUnitAngularAcceleration=12;
      GameInputPhysicalUnitAngularMass=13;
      GameInputPhysicalUnitAngularMomentum=14;
      GameInputPhysicalUnitAngularTorque=15;
      GameInputPhysicalUnitElectricCurrent=16;
      GameInputPhysicalUnitElectricCharge=17;
      GameInputPhysicalUnitElectricPotential=18;
      GameInputPhysicalUnitEnergy=19;
      GameInputPhysicalUnitPower=20;
      GameInputPhysicalUnitTemperature=21;
      GameInputPhysicalUnitLuminousIntensity=22;
      GameInputPhysicalUnitLuminousFlux=23;
      GameInputPhysicalUnitIlluminance=24;

type TGameInputLabel=TpvInt32;

const GameInputLabelUnknown=-1;
      GameInputLabelNone=0;
      GameInputLabelXboxGuide=1;
      GameInputLabelXboxBack=2;
      GameInputLabelXboxStart=3;
      GameInputLabelXboxMenu=4;
      GameInputLabelXboxView=5;
      GameInputLabelXboxA=7;
      GameInputLabelXboxB=8;
      GameInputLabelXboxX=9;
      GameInputLabelXboxY=10;
      GameInputLabelXboxDPadUp=11;
      GameInputLabelXboxDPadDown=12;
      GameInputLabelXboxDPadLeft=13;
      GameInputLabelXboxDPadRight=14;
      GameInputLabelXboxLeftShoulder=15;
      GameInputLabelXboxLeftTrigger=16;
      GameInputLabelXboxLeftStickButton=17;
      GameInputLabelXboxRightShoulder=18;
      GameInputLabelXboxRightTrigger=19;
      GameInputLabelXboxRightStickButton=20;
      GameInputLabelXboxPaddle1=21;
      GameInputLabelXboxPaddle2=22;
      GameInputLabelXboxPaddle3=23;
      GameInputLabelXboxPaddle4=24;
      GameInputLabelLetterA=25;
      GameInputLabelLetterB=26;
      GameInputLabelLetterC=27;
      GameInputLabelLetterD=28;
      GameInputLabelLetterE=29;
      GameInputLabelLetterF=30;
      GameInputLabelLetterG=31;
      GameInputLabelLetterH=32;
      GameInputLabelLetterI=33;
      GameInputLabelLetterJ=34;
      GameInputLabelLetterK=35;
      GameInputLabelLetterL=36;
      GameInputLabelLetterM=37;
      GameInputLabelLetterN=38;
      GameInputLabelLetterO=39;
      GameInputLabelLetterP=40;
      GameInputLabelLetterQ=41;
      GameInputLabelLetterR=42;
      GameInputLabelLetterS=43;
      GameInputLabelLetterT=44;
      GameInputLabelLetterU=45;
      GameInputLabelLetterV=46;
      GameInputLabelLetterW=47;
      GameInputLabelLetterX=48;
      GameInputLabelLetterY=49;
      GameInputLabelLetterZ=50;
      GameInputLabelNumber0=51;
      GameInputLabelNumber1=52;
      GameInputLabelNumber2=53;
      GameInputLabelNumber3=54;
      GameInputLabelNumber4=55;
      GameInputLabelNumber5=56;
      GameInputLabelNumber6=57;
      GameInputLabelNumber7=58;
      GameInputLabelNumber8=59;
      GameInputLabelNumber9=60;
      GameInputLabelArrowUp=61;
      GameInputLabelArrowUpRight=62;
      GameInputLabelArrowRight=63;
      GameInputLabelArrowDownRight=64;
      GameInputLabelArrowDown=65;
      GameInputLabelArrowDownLLeft=66;
      GameInputLabelArrowLeft=67;
      GameInputLabelArrowUpLeft=68;
      GameInputLabelArrowUpDown=69;
      GameInputLabelArrowLeftRight=70;
      GameInputLabelArrowUpDownLeftRight=71;
      GameInputLabelArrowClockwise=72;
      GameInputLabelArrowCounterClockwise=73;
      GameInputLabelArrowReturn=74;
      GameInputLabelIconBranding=75;
      GameInputLabelIconHome=76;
      GameInputLabelIconMenu=77;
      GameInputLabelIconCross=78;
      GameInputLabelIconCircle=79;
      GameInputLabelIconSquare=80;
      GameInputLabelIconTriangle=81;
      GameInputLabelIconStar=82;
      GameInputLabelIconDPadUp=83;
      GameInputLabelIconDPadDown=84;
      GameInputLabelIconDPadLeft=85;
      GameInputLabelIconDPadRight=86;
      GameInputLabelIconDialClockwise=87;
      GameInputLabelIconDialCounterClockwise=88;
      GameInputLabelIconSliderLeftRight=89;
      GameInputLabelIconSliderUpDown=90;
      GameInputLabelIconWheelUpDown=91;
      GameInputLabelIconPlus=92;
      GameInputLabelIconMinus=93;
      GameInputLabelIconSuspension=94;
      GameInputLabelHome=95;
      GameInputLabelGuide=96;
      GameInputLabelMode=97;
      GameInputLabelSelect=98;
      GameInputLabelMenu=99;
      GameInputLabelView=100;
      GameInputLabelBack=101;
      GameInputLabelStart=102;
      GameInputLabelOptions=103;
      GameInputLabelShare=104;
      GameInputLabelUp=105;
      GameInputLabelDown=106;
      GameInputLabelLeft=107;
      GameInputLabelRight=108;
      GameInputLabelLB=109;
      GameInputLabelLT=110;
      GameInputLabelLSB=111;
      GameInputLabelL1=112;
      GameInputLabelL2=113;
      GameInputLabelL3=114;
      GameInputLabelRB=115;
      GameInputLabelRT=116;
      GameInputLabelRSB=117;
      GameInputLabelR1=118;
      GameInputLabelR2=119;
      GameInputLabelR3=120;
      GameInputLabelP1=121;
      GameInputLabelP2=122;
      GameInputLabelP3=123;
      GameInputLabelP4=124;

type TGameInputLocation=TpvInt32;

const GameInputLocationUnknown=-1;
      GameInputLocationChassis=0;
      GameInputLocationDisplay=1;
      GameInputLocationAxis=2;
      GameInputLocationButton=3;
      GameInputLocationSwitch=4;
      GameInputLocationKey=5;
      GameInputLocationTouchPad=6;

type TGameInputFeedbackAxes=TpvUInt32;

const GameInputFeedbackAxisNone=$00000000;
      GameInputFeedbackAxisLinearX=$00000001;
      GameInputFeedbackAxisLinearY=$00000002;
      GameInputFeedbackAxisLinearZ=$00000004;
      GameInputFeedbackAxisAngularX=$00000008;
      GameInputFeedbackAxisAngularY=$00000010;
      GameInputFeedbackAxisAngularZ=$00000020;
      GameInputFeedbackAxisNormal=$00000040;

type TGameInputFeedbackEffectState=TpvUInt32;

const GameInputFeedbackStopped=0;
      GameInputFeedbackRunning=1;
      GameInputFeedbackPaused=2;

type TGameInputForceFeedbackEffectKind=TpvUInt32;

const GameInputForceFeedbackConstant=0;
      GameInputForceFeedbackRamp=1;
      GameInputForceFeedbackSineWave=2;
      GameInputForceFeedbackSquareWave=3;
      GameInputForceFeedbackTriangleWave=4;
      GameInputForceFeedbackSawtoothUpWave=5;
      GameInputForceFeedbackSawtoothDownWave=6;
      GameInputForceFeedbackSpring=7;
      GameInputForceFeedbackFriction=8;
      GameInputForceFeedbackDamper=9;
      GameInputForceFeedbackInertia=10;

type TGameInputRumbleMotors=TpvUInt32;

const GameInputRumbleNone=$00000000;
      GameInputRumbleLowFrequency=$00000001;
      GameInputRumbleHighFrequency=$00000002;
      GameInputRumbleLeftTrigger=$00000004;
      GameInputRumbleRightTrigger=$00000008;

type TGameInputCallbackToken=TpvUInt64;
     PGameInputCallbackToken=^TGameInputCallbackToken;

const GAMEINPUT_CURRENT_CALLBACK_TOKEN_VALUE=TpvUInt64($ffffffffffffffff);
      GAMEINPUT_INVALID_CALLBACK_TOKEN_VALUE=TpvUInt64($0000000000000000);

type TAPP_LOCAL_DEVICE_ID=record
      value:array[0..31] of TpvUInt8;
     end;

     PAPP_LOCAL_DEVICE_ID=^TAPP_LOCAL_DEVICE_ID;

     IGameInput=interface;

     PIGameInput=^IGameInput;

     IGameInputDevice=interface;

     PIGameInputDevice=^IGameInputDevice;

     IGameInputReading=interface;

     PIGameInputReading=^IGameInputReading;

     IGameInputDispatcher=interface;

     PIGameInputDispatcher=^IGameInputDispatcher;

     IGameInputForceFeedbackEffect=interface;

     PIGameInputForceFeedbackEffect=^IGameInputForceFeedbackEffect;

     IGameInputRawDeviceReport=interface;

     PIGameInputRawDeviceReport=^IGameInputRawDeviceReport;

     TGameInputReadingCallback=procedure(callbackToken:TGameInputCallbackToken;context:TpvPointer;reading:IGameInputReading;HasOverrunOccurred:BOOL); {$ifdef cpu386}stdcall;{$endif}

     TGameInputDeviceCallback=procedure(callbackToken:TGameInputCallbackToken;context:TpvPointer;device:IGameInputDevice;timestamp:TpvUInt64;currentStatus,previousStatus:TGameInputDeviceStatus); {$ifdef cpu386}stdcall;{$endif}

     TGameInputGuideButtonCallback=procedure(callbackToken:TGameInputCallbackToken;context:TpvPointer;device:IGameInputDevice;timestamp:TpvUInt64;isPressed:BOOL); {$ifdef cpu386}stdcall;{$endif}

     TGameInputKeyboardLayoutCallback=procedure(callbackToken:TGameInputCallbackToken;context:TpvPointer;device:IGameInputDevice;timestamp:TpvUInt64;currentLayout,previousLayout:TpvUInt32); {$ifdef cpu386}stdcall;{$endif}

     TGameInputKeyState=record
      scanCode:TpvUInt32;
      codePoint:TpvUInt32;
      virtualKey:TpvUInt8;
      isDeadKey:BOOL;
     end;

     PGameInputKeyState=^TGameInputKeyState;

     TGameInputMouseState=record
      buttons:TGameInputMouseButtons;
      positionX:TpvInt64;
      positionY:TpvInt64;
      wheelX:TpvInt64;
      wheelY:TpvInt64;
     end;

     PGameInputMouseState=^TGameInputMouseState;

     TGameInputTouchState=record
      touchId:TpvUInt64;
      sensorIndex:TpvUInt32;
      positionX:TpvFloat;
      positionY:TpvFloat;
      pressure:TpvFloat;
      proximity:TpvFloat;
      contactRectTop:TpvFloat;
      contactRectLeft:TpvFloat;
      contactRectRight:TpvFloat;
      contactRectBottom:TpvFloat;
     end;

     PGameInputTouchState=^TGameInputTouchState;

     TGameInputMotionState=record
      accelerationX:TpvFloat;
      accelerationY:TpvFloat;
      accelerationZ:TpvFloat;
      angularVelocityX:TpvFloat;
      angularVelocityY:TpvFloat;
      angularVelocityZ:TpvFloat;
      magneticFieldX:TpvFloat;
      magneticFieldY:TpvFloat;
      magneticFieldZ:TpvFloat;
      orientationW:TpvFloat;
      orientationX:TpvFloat;
      orientationY:TpvFloat;
      orientationZ:TpvFloat;
      accelerometerAccuracy:TGameInputMotionAccuracy;
      gyroscopeAccuracy:TGameInputMotionAccuracy;
      magnetometerAccuracy:TGameInputMotionAccuracy;
      orientationAccuracy:TGameInputMotionAccuracy;
     end;

     PGameInputMotionState=^TGameInputMotionState;

     TGameInputArcadeStickState=record
      buttons:TGameInputArcadeStickButtons;
     end;

     PGameInputArcadeStickState=^TGameInputArcadeStickState;

     TGameInputFlightStickState=record
      buttons:TGameInputFlightStickButtons;
      hatSwitch:TGameInputSwitchPosition;
      roll:TpvFloat;
      pitch:TpvFloat;
      yaw:TpvFloat;
      throttle:TpvFloat;
     end;

     PGameInputFlightStickState=^TGameInputFlightStickState;

     TGameInputGamepadState=record
      buttons:TGameInputGamepadButtons;
      leftTrigger:TpvFloat;
      rightTrigger:TpvFloat;
      leftThumbstickX:TpvFloat;
      leftThumbstickY:TpvFloat;
      rightThumbstickX:TpvFloat;
      rightThumbstickY:TpvFloat;
     end;

     PGameInputGamepadState=^TGameInputGamepadState;

     TGameInputRacingWheelState=record
      buttons:TGameInputRacingWheelButtons;
      patternShifterGear:TpvInt32;
      wheel:TpvFloat;
      throttle:TpvFloat;
      brake:TpvFloat;
      clutch:TpvFloat;
      handbrake:TpvFloat;
     end;

     PGameInputRacingWheelState=^TGameInputRacingWheelState;

     TGameInputUiNavigationState=record
      buttons:TGameInputUiNavigationButtons;
     end;

     PGameInputUiNavigationState=^TGameInputUiNavigationState;

     TGameInputBatteryState=record
      chargeRate:TpvFloat;
      maxChargeRate:TpvFloat;
      remainingCapacity:TpvFloat;
      fullChargeCapacity:TpvFloat;
      status:TGameInputBatteryStatus;
     end;

     PGameInputBatteryState=^TGameInputBatteryState;

     TGameInputString=record
      sizeInBytes:TpvUInt32;
      codePointCount:TpvUInt32;
      data:PAnsiChar;
     end;

     PGameInputString=^TGameInputString;

     TGameInputUsage=record
      page:TpvUInt16;
      id:TpvUInt16;
     end;

     PGameInputUsage=^TGameInputUsage;

     TGameInputVersion=record
      major:TpvUInt16;
      minor:TpvUInt16;
      build:TpvUInt16;
      revision:TpvUInt16;
     end;

     PGameInputVersion=^TGameInputVersion;

     PGameInputRawDeviceItemCollectionInfo=^TGameInputRawDeviceItemCollectionInfo;

     TGameInputRawDeviceItemCollectionInfo=record
      kind:TGameInputRawDeviceItemCollectionKind;
      childCount:TpvUInt32;
      siblingCount:TpvUInt32;
      usageCount:TpvUInt32;
      usages:PGameInputUsage;
      parent:PGameInputRawDeviceItemCollectionInfo;
      firstSibling:PGameInputRawDeviceItemCollectionInfo;
      previousSibling:PGameInputRawDeviceItemCollectionInfo;
      nextSibling:PGameInputRawDeviceItemCollectionInfo;
      lastSibling:PGameInputRawDeviceItemCollectionInfo;
      firstChild:PGameInputRawDeviceItemCollectionInfo;
      lastChild:PGameInputRawDeviceItemCollectionInfo;
     end;

     TGameInputRawDeviceReportItemInfo=record
      bitOffset:TpvUInt32;
      bitSize:TpvUInt32;
      logicalMin:TpvInt64;
      logicalMax:TpvInt64;
      physicalMin:TpvDouble;
      physicalMax:TpvDouble;
      physicalUnits:TGameInputRawDevicePhysicalUnitKind;
      rawPhysicalUnits:TpvUInt32;
      rawPhysicalUnitsExponent:TpvInt32;
      flags:TGameInputRawDeviceReportItemFlags;
      usageCount:TpvUInt32;
      usages:PGameInputUsage;
      collection:PGameInputRawDeviceItemCollectionInfo;
      itemString:PGameInputString;
     end;

     PGameInputRawDeviceReportItemInfo=^TGameInputRawDeviceReportItemInfo;

     TGameInputRawDeviceReportInfo=record
      kind:TGameInputRawDeviceReportKind;
      id:TpvUInt32;
      size:TpvUInt32;
      itemCount:TpvUInt32;
      items:PGameInputRawDeviceReportItemInfo;
     end;

     PGameInputRawDeviceReportInfo=^TGameInputRawDeviceReportInfo;

     TGameInputControllerAxisInfo=record
      mappedInputKinds:TGameInputKind;
      label_:TGameInputLabel;
      isContinuous:bool;
      isNonlinear:bool;
      isQuantized:bool;
      hasRestValue:bool;
      restValue:TpvFloat;
      resolution:TpvUInt64;
      legacyDInputIndex:TpvUInt16;
      legacyHidIndex:TpvUInt16;
      rawReportIndex:TpvUInt32;
      inputReport:PGameInputRawDeviceReportInfo;
      inputReportItem:PGameInputRawDeviceReportItemInfo;
     end;

     PGameInputControllerAxisInfo=^TGameInputControllerAxisInfo;

     TGameInputControllerButtonInfo=record
      mappedInputKinds:TGameInputKind;
      label_:TGameInputLabel;
      legacyDInputIndex:TpvUInt16;
      legacyHidIndex:TpvUInt16;
      rawReportIndex:TpvUInt32;
      inputReport:PGameInputRawDeviceReportInfo;
      inputReportItem:PGameInputRawDeviceReportItemInfo;
     end;

     PGameInputControllerButtonInfo=^TGameInputControllerButtonInfo;

     TGameInputControllerSwitchInfo=record
      mappedInputKinds:TGameInputKind;
      label_:TGameInputLabel;
      positionLabels:array[0..8] of TGameInputLabel;
      kind:TGameInputSwitchKind;
      legacyDInputIndex:TpvUInt16;
      legacyHidIndex:TpvUInt16;
      rawReportIndex:TpvUInt32;
      inputReport:PGameInputRawDeviceReportInfo;
      inputReportItem:PGameInputRawDeviceReportItemInfo;
     end;

     PGameInputControllerSwitchInfo=^TGameInputControllerSwitchInfo;

     TGameInputKeyboardInfo=record
      kind:TGameInputKeyboardKind;
      layout:TpvUInt32;
      keyCount:TpvUInt32;
      functionKeyCount:TpvUInt32;
      maxSimultaneousKeys:TpvUInt32;
      platformType:TpvUInt32;
      platformSubtype:TpvUInt32;
      nativeLanguage:PGameInputString;
     end;

     PGameInputKeyboardInfo=^TGameInputKeyboardInfo;

     TGameInputMouseInfo=record
      supportedButtons:TGameInputMouseButtons;
      sampleRate:TpvUInt32;
      sensorDpi:TpvUInt32;
      hasWheelX:bool;
      hasWheelY:bool;
     end;

     PGameInputMouseInfo=^TGameInputMouseInfo;

     TGameInputTouchSensorInfo=record
      mappedInputKinds:TGameInputKind;
      label_:TGameInputLabel;
      location:TGameInputLocation;
      locationId:TpvUInt32;
      resolutionX:TpvUInt64;
      resolutionY:TpvUInt64;
      shape:TGameInputTouchShape;
      aspectRatio:TpvFloat;
      orientation:TpvFloat;
      physicalWidth:TpvFloat;
      physicalHeight:TpvFloat;
      maxPressure:TpvFloat;
      maxProximity:TpvFloat;
      maxTouchPoints:TpvUInt32;
     end;

     PGameInputTouchSensorInfo=^TGameInputTouchSensorInfo;

     TGameInputMotionInfo=record
      maxAcceleration:TpvFloat;
      maxAngularVelocity:TpvFloat;
      maxMagneticFieldStrength:TpvFloat;
     end;

     PGameInputMotionInfo=^TGameInputMotionInfo;

     TGameInputArcadeStickInfo=record
      menuButtonLabel:TGameInputLabel;
      viewButtonLabel:TGameInputLabel;
      stickUpLabel:TGameInputLabel;
      stickDownLabel:TGameInputLabel;
      stickLeftLabel:TGameInputLabel;
      stickRightLabel:TGameInputLabel;
      actionButton1Label:TGameInputLabel;
      actionButton2Label:TGameInputLabel;
      actionButton3Label:TGameInputLabel;
      actionButton4Label:TGameInputLabel;
      actionButton5Label:TGameInputLabel;
      actionButton6Label:TGameInputLabel;
      specialButton1Label:TGameInputLabel;
      specialButton2Label:TGameInputLabel;
     end;

     PGameInputArcadeStickInfo=^TGameInputArcadeStickInfo;

     TGameInputFlightStickInfo=record
      menuButtonLabel:TGameInputLabel;
      viewButtonLabel:TGameInputLabel;
      firePrimaryButtonLabel:TGameInputLabel;
      fireSecondaryButtonLabel:TGameInputLabel;
      hatSwitchKind:TGameInputSwitchKind;
     end;

     PGameInputFlightStickInfo=^TGameInputFlightStickInfo;

     TGameInputGamepadInfo=record
      menuButtonLabel:TGameInputLabel;
      viewButtonLabel:TGameInputLabel;
      aButtonLabel:TGameInputLabel;
      bButtonLabel:TGameInputLabel;
      xButtonLabel:TGameInputLabel;
      yButtonLabel:TGameInputLabel;
      dpadUpLabel:TGameInputLabel;
      dpadDownLabel:TGameInputLabel;
      dpadLeftLabel:TGameInputLabel;
      dpadRightLabel:TGameInputLabel;
      leftShoulderButtonLabel:TGameInputLabel;
      rightShoulderButtonLabel:TGameInputLabel;
      leftThumbstickButtonLabel:TGameInputLabel;
      rightThumbstickButtonLabel:TGameInputLabel;
     end;

     PGameInputGamepadInfo=^TGameInputGamepadInfo;

     TGameInputRacingWheelInfo=record
      menuButtonLabel:TGameInputLabel;
      viewButtonLabel:TGameInputLabel;
      previousGearButtonLabel:TGameInputLabel;
      nextGearButtonLabel:TGameInputLabel;
      dpadUpLabel:TGameInputLabel;
      dpadDownLabel:TGameInputLabel;
      dpadLeftLabel:TGameInputLabel;
      dpadRightLabel:TGameInputLabel;
      hasClutch:bool;
      hasHandbrake:bool;
      hasPatternShifter:bool;
      minPatternShifterGear:TpvInt32;
      maxPatternShifterGear:TpvInt32;
      maxWheelAngle:TpvFloat;
     end;

     PGameInputRacingWheelInfo=^TGameInputRacingWheelInfo;

     TGameInputUiNavigationInfo=record
      menuButtonLabel:TGameInputLabel;
      viewButtonLabel:TGameInputLabel;
      acceptButtonLabel:TGameInputLabel;
      cancelButtonLabel:TGameInputLabel;
      upButtonLabel:TGameInputLabel;
      downButtonLabel:TGameInputLabel;
      leftButtonLabel:TGameInputLabel;
      rightButtonLabel:TGameInputLabel;
      contextButton1Label:TGameInputLabel;
      contextButton2Label:TGameInputLabel;
      contextButton3Label:TGameInputLabel;
      contextButton4Label:TGameInputLabel;
      pageUpButtonLabel:TGameInputLabel;
      pageDownButtonLabel:TGameInputLabel;
      pageLeftButtonLabel:TGameInputLabel;
      pageRightButtonLabel:TGameInputLabel;
      scrollUpButtonLabel:TGameInputLabel;
      scrollDownButtonLabel:TGameInputLabel;
      scrollLeftButtonLabel:TGameInputLabel;
      scrollRightButtonLabel:TGameInputLabel;
      guideButtonLabel:TGameInputLabel;
     end;

     PGameInputUiNavigationInfo=^TGameInputUiNavigationInfo;

     TGameInputForceFeedbackMotorInfo=record
      supportedAxes:TGameInputFeedbackAxes;
      location:TGameInputLocation;
      locationId:TpvUInt32;
      maxSimultaneousEffects:TpvUInt32;
      isConstantEffectSupported:bool;
      isRampEffectSupported:bool;
      isSineWaveEffectSupported:bool;
      isSquareWaveEffectSupported:bool;
      isTriangleWaveEffectSupported:bool;
      isSawtoothUpWaveEffectSupported:bool;
      isSawtoothDownWaveEffectSupported:bool;
      isSpringEffectSupported:bool;
      isFrictionEffectSupported:bool;
      isDamperEffectSupported:bool;
      isInertiaEffectSupported:bool;
     end;

     PGameInputForceFeedbackMotorInfo=^TGameInputForceFeedbackMotorInfo;

     TGameInputHapticWaveformInfo=record
      usage:TGameInputUsage;
      isDurationSupported:bool;
      isIntensitySupported:bool;
      isRepeatSupported:bool;
      isRepeatDelaySupported:bool;
      defaultDuration:TpvUInt64;
     end;

     PGameInputHapticWaveformInfo=^TGameInputHapticWaveformInfo;

     TGameInputHapticFeedbackMotorInfo=record
      mappedRumbleMotors:TGameInputRumbleMotors;
      location:TGameInputLocation;
      locationId:TpvUInt32;
      waveformCount:TpvUInt32;
      waveformInfo:PGameInputHapticWaveformInfo;
     end;

     PGameInputHapticFeedbackMotorInfo=^TGameInputHapticFeedbackMotorInfo;

     TGameInputDeviceInfo=record
      infoSize:TpvUInt32;
      vendorId:TpvUInt16;
      productId:TpvUInt16;
      revisionNumber:TpvUInt16;
      interfaceNumber:TpvUInt8;
      collectionNumber:TpvUInt8;
      usage:TGameInputUsage;
      hardwareVersion:TGameInputVersion;
      firmwareVersion:TGameInputVersion;
      deviceId:TAPP_LOCAL_DEVICE_ID;
      deviceRootId:TAPP_LOCAL_DEVICE_ID;
      deviceFamily:TGameInputDeviceFamily;
      capabilities:TGameInputDeviceCapabilities;
      supportedInput:TGameInputKind;
      supportedRumbleMotors:TGameInputRumbleMotors;
      inputReportCount:TpvUInt32;
      outputReportCount:TpvUInt32;
      featureReportCount:TpvUInt32;
      controllerAxisCount:TpvUInt32;
      controllerButtonCount:TpvUInt32;
      controllerSwitchCount:TpvUInt32;
      touchPointCount:TpvUInt32;
      touchSensorCount:TpvUInt32;
      forceFeedbackMotorCount:TpvUInt32;
      hapticFeedbackMotorCount:TpvUInt32;
      deviceStringCount:TpvUInt32;
      deviceDescriptorSize:TpvUInt32;
      inputReportInfo:PGameInputRawDeviceReportInfo;
      outputReportInfo:PGameInputRawDeviceReportInfo;
      featureReportInfo:PGameInputRawDeviceReportInfo;
      controllerAxisInfo:PGameInputControllerAxisInfo;
      controllerButtonInfo:PGameInputControllerButtonInfo;
      controllerSwitchInfo:PGameInputControllerSwitchInfo;
      keyboardInfo:PGameInputKeyboardInfo;
      mouseInfo:PGameInputMouseInfo;
      touchSensorInfo:PGameInputTouchSensorInfo;
      motionInfo:PGameInputMotionInfo;
      arcadeStickInfo:PGameInputArcadeStickInfo;
      flightStickInfo:PGameInputFlightStickInfo;
      gamepadInfo:PGameInputGamepadInfo;
      racingWheelInfo:PGameInputRacingWheelInfo;
      uiNavigationInfo:PGameInputUiNavigationInfo;
      forceFeedbackMotorInfo:PGameInputForceFeedbackMotorInfo;
      hapticFeedbackMotorInfo:PGameInputHapticFeedbackMotorInfo;
      displayName:PGameInputString;
      deviceStrings:PGameInputString;
      deviceDescriptorData:TpvPointer;
     end;

     PGameInputDeviceInfo=^TGameInputDeviceInfo;

     TGameInputForceFeedbackEnvelope=record
      attackDuration:TpvUInt64;
      sustainDuration:TpvUInt64;
      releaseDuration:TpvUInt64;
      attackGain:TpvFloat;
      sustainGain:TpvFloat;
      releaseGain:TpvFloat;
      playCount:TpvUInt32;
      repeatDelay:TpvUInt64;
     end;

     PGameInputForceFeedbackEnvelope=^TGameInputForceFeedbackEnvelope;

     TGameInputForceFeedbackMagnitude=record
      linearX:TpvFloat;
      linearY:TpvFloat;
      linearZ:TpvFloat;
      angularX:TpvFloat;
      angularY:TpvFloat;
      angularZ:TpvFloat;
      normal:TpvFloat;
     end;

     PGameInputForceFeedbackMagnitude=^TGameInputForceFeedbackMagnitude;

     TGameInputForceFeedbackConditionParams=record
      magnitude:PGameInputForceFeedbackMagnitude;
      positiveCoefficient:TpvFloat;
      negativeCoefficient:TpvFloat;
      maxPositiveMagnitude:TpvFloat;
      maxNegativeMagnitude:TpvFloat;
      deadZone:TpvFloat;
      bias:TpvFloat;
     end;

     PGameInputForceFeedbackConditionParams=^TGameInputForceFeedbackConditionParams;

     TGameInputForceFeedbackConstantParams=record
      envelope:TGameInputForceFeedbackEnvelope;
      magnitude:TGameInputForceFeedbackMagnitude;
     end;

     PGameInputForceFeedbackConstantParams=^TGameInputForceFeedbackConstantParams;

     TGameInputForceFeedbackPeriodicParams=record
      envelope:TGameInputForceFeedbackEnvelope;
      magnitude:TGameInputForceFeedbackMagnitude;
      frequency:TpvFloat;
      phase:TpvFloat;
      bias:TpvFloat;
     end;

     PGameInputForceFeedbackPeriodicParams=^TGameInputForceFeedbackPeriodicParams;

     TGameInputForceFeedbackRampParams=record
      envelope:TGameInputForceFeedbackEnvelope;
      startMagnitude:TGameInputForceFeedbackMagnitude;
      endMagnitude:TGameInputForceFeedbackMagnitude;
     end;

     PGameInputForceFeedbackRampParams=^TGameInputForceFeedbackRampParams;

     TGameInputForceFeedbackParams=record
      kind:TGameInputForceFeedbackEffectKind;
      data:record
       case TGameInputForceFeedbackEffectKind of
        GameInputForceFeedbackConstant:(
         constant:TGameInputForceFeedbackConstantParams;
        );
        GameInputForceFeedbackRamp:(
         ramp:TGameInputForceFeedbackRampParams;
        );
        GameInputForceFeedbackSineWave:(
         sineWave:TGameInputForceFeedbackPeriodicParams;
        );
        GameInputForceFeedbackSquareWave:(
         squareWave:TGameInputForceFeedbackPeriodicParams;
        );
        GameInputForceFeedbackTriangleWave:(
         triangleWave:TGameInputForceFeedbackPeriodicParams;
        );
        GameInputForceFeedbackSawtoothUpWave:(
         sawtoothUpWave:TGameInputForceFeedbackPeriodicParams;
        );
        GameInputForceFeedbackSawtoothDownWave:(
         sawtoothDownWave:TGameInputForceFeedbackPeriodicParams;
        );
        GameInputForceFeedbackSpring:(
         spring:TGameInputForceFeedbackConditionParams;
        );
        GameInputForceFeedbackFriction:(
         friction:TGameInputForceFeedbackConditionParams;
        );
        GameInputForceFeedbackDamper:(
         damper:TGameInputForceFeedbackConditionParams;
        );
        GameInputForceFeedbackInertia:(
         inertia:TGameInputForceFeedbackConditionParams;
        );
      end;
     end;

     PGameInputForceFeedbackParams=^TGameInputForceFeedbackParams;

     TGameInputHapticFeedbackParams=record
      waveformIndex:TpvUInt32;
      duration:TpvUInt64;
      intensity:TpvFloat;
      playCount:TpvUInt32;
      repeatDelay:TpvUInt64;
     end;

     PGameInputHapticFeedbackParams=^TGameInputHapticFeedbackParams;

     TGameInputRumbleParams=record
      lowFrequency:TpvFloat;
      highFrequency:TpvFloat;
      leftTrigger:TpvFloat;
      rightTrigger:TpvFloat;
     end;

     PGameInputRumbleParams=^TGameInputRumbleParams;

     IGameInput=interface(IUnknown)['{11BE2A7E-4254-445A-9C09-FFC40F006918}']
      function GetCurrentTimestamp:TpvUInt64; {$ifdef cpu386}stdcall;{$endif}
      function GetCurrentReading(inputKind:TGameInputKind;device:IGameInputDevice;out reading:IGameInputReading):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function GetNextReading(referenceReading:IGameInputReading;inputKind:TGameInputKind;device:IGameInputDevice;out reading:IGameInputReading):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function GetPreviousReading(referenceReading:IGameInputReading;inputKind:TGameInputKind;device:IGameInputDevice;out reading:IGameInputReading):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function GetTemporalReading(timeStamp:TpvUInt64;device:IGameInputDevice;out reading:IGameInputReading):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function RegisterReadingCallback(device:IGameInputDevice;inputKind:TGameInputKind;analogThreshold:TpvFloat;context:TpvPointer;callbackFunc:TGameInputReadingCallback;callbackToken:PGameInputCallbackToken):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function RegisterDeviceCallback(device:IGameInputDevice;inputKind:TGameInputKind;statusFilter:TGameInputDeviceStatus;enumerationKind:TGameInputEnumerationKind;context:TpvPointer;callbackFunc:TGameInputDeviceCallback;callbackToken:PGameInputCallbackToken):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function RegisterGuideButtonCallback(device:IGameInputDevice;context:TpvPointer;callbackFunc:TGameInputGuideButtonCallback;callbackToken:PGameInputCallbackToken):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function RegisterKeyboardLayoutCallback(device:IGameInputDevice;context:TpvPointer;callbackFunc:TGameInputKeyboardLayoutCallback;callbackToken:PGameInputCallbackToken):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      procedure StopCallback(callbackToken:TGameInputCallbackToken); {$ifdef cpu386}stdcall;{$endif}
      function UnregisterCallback(callbackToken:TGameInputCallbackToken;timeoutInMicroseconds:TpvUInt64):BOOL; {$ifdef cpu386}stdcall;{$endif}
      function CreateDispatcher(out dispatcher:IGameInputDispatcher):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function CreateAggregateDevice(inputKind:TGameInputKind;out device:IGameInputDevice):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function FindDeviceFromId(value:PAPP_LOCAL_DEVICE_ID;out device:IGameInputDevice):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function FindDeviceFromObject(value:IUnknown;out device:IGameInputDevice):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function FindDeviceFromPlatformHandle(value:THANDLE;out device:IGameInputDevice):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function FindDeviceFromPlatformString(value:LPCWSTR;out device:IGameInputDevice):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function EnableOemDeviceSupport(vendorId,productId:TpvUInt16;interfaceNumber,collectionNumber:TpvUInt8):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      procedure SetFocusPolicy(policy:TGameInputFocusPolicy); {$ifdef cpu386}stdcall;{$endif}
     end;

     IGameInputReading=interface(IUnknown)['{2156947A-E1FA-4DE0-A30B-D812931DBD8D}']
      function GetInputKind:TGameInputKind; {$ifdef cpu386}stdcall;{$endif}
      function GetSequenceNumber(inputKind:TGameInputKind):TpvUInt64; {$ifdef cpu386}stdcall;{$endif}
      function GetTimeStamp:TpvUInt64; {$ifdef cpu386}stdcall;{$endif}
      procedure GetDevice(out device:IGameInputDevice); {$ifdef cpu386}stdcall;{$endif}
      function GetRawReport(out report:IGameInputRawDeviceReport):bool; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerAxisCount:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerAxisState(stateArrayCount:TpvUInt32;stateArray:PpvFloat):TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerButtonCount:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerButtonState(stateArrayCount:TpvUInt32;stateArray:PBool):TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerSwitchCount:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetControllerSwitchState(stateArrayCount:TpvUInt32;stateArray:PGameInputSwitchPosition):TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetKeyCount:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetKeyState(stateArrayCount:TpvUInt32;stateArray:PGameInputKeyState):TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetMouseState(state:PGameInputMouseState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetTouchCount:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetTouchState(stateArrayCount:TpvUInt32;stateArray:PGameInputTouchState):TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetMotionState(state:PGameInputMotionState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetArcadeStickState(state:PGameInputArcadeStickState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetFlightStickState(state:PGameInputFlightStickState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetGamepadState(state:PGameInputGamepadState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetRacingWheelState(state:PGameInputRacingWheelState):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetUiNavigationState(state:PGameInputUiNavigationState):Bool; {$ifdef cpu386}stdcall;{$endif}
     end;

     IGameInputDevice=interface(IUnknown)['{31DD86FB-4C1B-408A-868F-439B3CD47125}']
      function GetDeviceInfo:PGameInputDeviceInfo; {$ifdef cpu386}stdcall;{$endif}
      function GetDeviceStatus:TGameInputDeviceStatus; {$ifdef cpu386}stdcall;{$endif}
      procedure GetBatteryState(state:PGameInputBatteryState); {$ifdef cpu386}stdcall;{$endif}
      function CreateForceFeedbackEffect(motorIndex:TpvUInt32;params:PGameInputForceFeedbackParams;out effect:IGameInputForceFeedbackEffect):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function IsForceFeedbackMotorPoweredOn(motorIndex:TpvUInt32):Bool; {$ifdef cpu386}stdcall;{$endif}
      procedure SetForceFeedbackMotorGain(motorIndex:TpvUInt32;masterGain:TpvFloat); {$ifdef cpu386}stdcall;{$endif}
      procedure SetHapticMotorState(motorIndex:TpvUInt32;params:PGameInputHapticFeedbackParams); {$ifdef cpu386}stdcall;{$endif}
      procedure SetRumbleState(params:PGameInputRumbleParams); {$ifdef cpu386}stdcall;{$endif}
      procedure SetInputSynchronizationState(enabled:Bool); {$ifdef cpu386}stdcall;{$endif}
      procedure SendInputSynchronizationHint; {$ifdef cpu386}stdcall;{$endif}
      procedure PowerOff; {$ifdef cpu386}stdcall;{$endif}
      function CreateRawDeviceReport(reportId:TpvUInt32;reportKind:TGameInputRawDeviceReportKind;out report:IGameInputRawDeviceReport):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function GetRawDeviceFeature(reportId:TpvUInt32;out report:IGameInputRawDeviceReport):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function SetRawDeviceFeature(report:IGameInputRawDeviceReport):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function SendRawDeviceOutput(report:IGameInputRawDeviceReport):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function SendRawDeviceOutputWithResponse(requestReport:IGameInputRawDeviceReport;out responseReport:IGameInputRawDeviceReport):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function ExecuteRawDeviceIoControl(controlCode:TpvUInt32;inputBufferSize:TpvSizeUInt;inputBuffer:TpvPointer;outputBufferSize:TpvSizeUInt;outputBuffer:TpvPointer;outputSize:TpvSizeUInt):HRESULT; {$ifdef cpu386}stdcall;{$endif}
      function AcquireExclusiveRawDeviceAccess(timeoutInMicroseconds:TpvUInt64):Bool; {$ifdef cpu386}stdcall;{$endif}
      procedure ReleaseExclusiveRawDeviceAccess; {$ifdef cpu386}stdcall;{$endif}
     end;

     IGameInputDispatcher=interface(IUnknown)['{415EED2E-98CB-42C2-8F28-B94601074E31}']
      function Dispatch(quotaInMicroseconds:TpvUInt64):Bool; {$ifdef cpu386}stdcall;{$endif}
      function OpenWaitHandle(waitHandle:PHandle):HRESULT; {$ifdef cpu386}stdcall;{$endif}
     end;

     IGameInputForceFeedbackEffect=interface(IUnknown)['{51BDA05E-F742-45D9-B085-9444AE48381D}']
      procedure GetDevice(out device:IGameInputDevice); {$ifdef cpu386}stdcall;{$endif}
      function GetMotorIndex:TpvUInt32; {$ifdef cpu386}stdcall;{$endif}
      function GetGain:TpvFloat; {$ifdef cpu386}stdcall;{$endif}
      procedure SetGain(gain:TpvFloat); {$ifdef cpu386}stdcall;{$endif}
      procedure GetParams(params:PGameInputForceFeedbackParams); {$ifdef cpu386}stdcall;{$endif}
      function SetParams(params:PGameInputForceFeedbackParams):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetState:TGameInputFeedbackEffectState; {$ifdef cpu386}stdcall;{$endif}
      procedure SetState(state:TGameInputFeedbackEffectState); {$ifdef cpu386}stdcall;{$endif}
     end;

     IGameInputRawDeviceReport=interface(IUnknown)['{61F08CF1-1FFC-40CA-A2B8-E1AB8BC5B6DC}']
      procedure GetDevice(out device:IGameInputDevice); {$ifdef cpu386}stdcall;{$endif}
      function GetReportInfo:PGameInputRawDeviceReportInfo; {$ifdef cpu386}stdcall;{$endif}
      function GetRawDataSize:TpvSizeUInt; {$ifdef cpu386}stdcall;{$endif}
      function GetRawData(bufferSize:TpvSizeUInt;buffer:Pointer):TpvSizeUInt; {$ifdef cpu386}stdcall;{$endif}
      function SetRawData(bufferSize:TpvSizeUInt;buffer:Pointer):Bool; {$ifdef cpu386}stdcall;{$endif}
      function GetItemValue(itemIndex:TpvUInt32;value:PpvInt64):Bool; {$ifdef cpu386}stdcall;{$endif}
      function SetItemValue(itemIndex:TpvUInt32;value:TpvInt64):Bool; {$ifdef cpu386}stdcall;{$endif}
      function ResetItemValue(itemIndex:TpvUInt32):Bool; {$ifdef cpu386}stdcall;{$endif}
      function ResetAllItems:Bool; {$ifdef cpu386}stdcall;{$endif}
     end;

     TGameInputCreate=function(out gameInput:IGameInput):HRESULT; {$ifdef cpu386}stdcall;{$endif}

var GameInputCreate:TGameInputCreate=nil;

    GameInputLibrary:THandle=THandle(0);

{$ifend}

implementation

{$if defined(Windows)}
procedure InitializeGameInput;
begin
 GameInputLibrary:=LoadLibrary('gameinput.dll');
 if GameInputLibrary<>THandle(0) then begin
  @GameInputCreate:=GetProcAddress(GameInputLibrary,'GameInputCreate');
 end;
end;

procedure FinalizeGameInput;
begin
 if GameInputLibrary<>THandle(0) then begin
  try
   FreeLibrary(GameInputLibrary);
  finally
   GameInputLibrary:=THandle(0);
  end;
 end;
end;

initialization
 InitializeGameInput;
finalization
 FinalizeGameInput;
{$ifend}
end.

