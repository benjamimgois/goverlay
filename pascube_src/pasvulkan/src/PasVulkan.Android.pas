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
unit PasVulkan.Android;
{$ifdef fpc}
 {$mode delphi}
 {$packrecords c}
 {$ifdef cpui386}
  {$define cpu386}
  {$define cpu32}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
  {$define cpu32}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux64}
  {$define cpux8664}
  {$define cpu64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define CanInline}
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
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
 {$if declared(UnicodeString)}
  {$define HAS_TYPE_UNICODESTRING}
 {$else}
  {$undef HAS_TYPE_UNICODESTRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$safedivide off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifdef cpux64}
  {$define cpux8664}
  {$define cpuamd64}
  {$define cpu64}
 {$endif}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
  {$if declared(UnicodeString)}
   {$define HAS_TYPE_UNICODESTRING}
  {$else}
   {$undef HAS_TYPE_UNICODESTRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
  {$undef HAS_TYPE_UTF8STRING}
  {$undef HAS_TYPE_UNICODESTRING}
 {$endif}
 {$ifndef BCB}
  {$ifdef ver120}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver140}
   {$define Delphi6}
  {$endif}
  {$ifdef ver150}
   {$define Delphi7}
  {$endif}
  {$ifdef ver170}
   {$define Delphi2005}
  {$endif}
 {$else}
  {$ifdef ver120}
   {$define Delphi4or5}
   {$define BCB4}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
 {$endif}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24}
   {$legacyifend on}
  {$ifend}
  {$if CompilerVersion>=14.0}
   {$if CompilerVersion=14.0}
    {$define Delphi6}
   {$ifend}
   {$define Delphi6AndUp}
  {$ifend}
  {$if CompilerVersion>=15.0}
   {$if CompilerVersion=15.0}
    {$define Delphi7}
   {$ifend}
   {$define Delphi7AndUp}
  {$ifend}
  {$if CompilerVersion>=17.0}
   {$if CompilerVersion=17.0}
    {$define Delphi2005}
   {$ifend}
   {$define Delphi2005AndUp}
   {$finitefloat off}
  {$ifend}
  {$if CompilerVersion>=18.0}
   {$if CompilerVersion=18.0}
    {$define BDS2006}
    {$define Delphi2006}
   {$ifend}
   {$define Delphi2006AndUp}
  {$ifend}
  {$if CompilerVersion>=18.5}
   {$if CompilerVersion=18.5}
    {$define Delphi2007}
   {$ifend}
   {$define Delphi2007AndUp}
  {$ifend}
  {$if CompilerVersion=19.0}
   {$define Delphi2007Net}
  {$ifend}
  {$if CompilerVersion>=20.0}
   {$if CompilerVersion=20.0}
    {$define Delphi2009}
   {$ifend}
   {$define Delphi2009AndUp}
   {$define CanInline}
  {$ifend}
  {$if CompilerVersion>=21.0}
   {$if CompilerVersion=21.0}
    {$define Delphi2010}
   {$ifend}
   {$define Delphi2010AndUp}
  {$ifend}
  {$if CompilerVersion>=22.0}
   {$if CompilerVersion=22.0}
    {$define DelphiXE}
   {$ifend}
   {$define DelphiXEAndUp}
  {$ifend}
  {$if CompilerVersion>=23.0}
   {$if CompilerVersion=23.0}
    {$define DelphiXE2}
   {$ifend}
   {$define DelphiXE2AndUp}
  {$ifend}
  {$if CompilerVersion>=24.0}
   {$if CompilerVersion=24.0}
    {$define DelphiXE3}
   {$ifend}
   {$define DelphiXE3AndUp}
  {$ifend}
  {$if CompilerVersion>=25.0}
   {$if CompilerVersion=25.0}
    {$define DelphiXE4}
   {$ifend}
   {$define DelphiXE4AndUp}
  {$ifend}
  {$if CompilerVersion>=26.0}
   {$if CompilerVersion=26.0}
    {$define DelphiXE5}
   {$ifend}
   {$define DelphiXE5AndUp}
  {$ifend}
  {$if CompilerVersion>=27.0}
   {$if CompilerVersion=27.0}
    {$define DelphiXE6}
   {$ifend}
   {$define DelphiXE6AndUp}
  {$ifend}
  {$if CompilerVersion>=28.0}
   {$if CompilerVersion=28.0}
    {$define DelphiXE7}
   {$ifend}
   {$define DelphiXE7AndUp}
  {$ifend}
  {$if CompilerVersion>=29.0}
   {$if CompilerVersion=29.0}
    {$define DelphiXE8}
   {$ifend}
   {$define DelphiXE8AndUp}
  {$ifend}
  {$if CompilerVersion>=30.0}
   {$if CompilerVersion=30.0}
    {$define Delphi10Seattle}
   {$ifend}
   {$define Delphi10SeattleAndUp}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$if CompilerVersion=31.0}
    {$define Delphi10Berlin}
   {$ifend}
   {$define Delphi10BerlinAndUp}
  {$ifend}
 {$endif}
 {$ifndef Delphi4or5}
  {$ifndef BCB}
   {$define Delphi6AndUp}
  {$endif}
   {$ifndef Delphi6}
    {$define BCB6OrDelphi7AndUp}
    {$ifndef BCB}
     {$define Delphi7AndUp}
    {$endif}
    {$ifndef BCB}
     {$ifndef Delphi7}
      {$ifndef Delphi2005}
       {$define BDS2006AndUp}
      {$endif}
     {$endif}
    {$endif}
   {$endif}
 {$endif}
 {$ifdef Delphi6AndUp}
  {$warn symbol_platform off}
  {$warn symbol_deprecated off}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
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

interface

{$if defined(fpc) and defined(Android)}
uses ctypes;

(*
 * Manifest constants.
 *)
const JNI_FALSE=0;
      JNI_TRUE=1;

      JNI_VERSION_1_1=$00010001;
      JNI_VERSION_1_2=$00010002;
      JNI_VERSION_1_4=$00010004;
      JNI_VERSION_1_6=$00010006;

      JNI_OK=0;         // no error
      JNI_ERR=-1;       // generic error
      JNI_EDETACHED=-2; // thread detached from the VM
      JNI_EVERSION=-3;  // JNI version error

      JNI_COMMIT=1;     // copy content, do not free buffer
      JNI_ABORT=2;      // free buffer w/o copying back

(*
 * Type definitions.
 *)
type va_list=pointer;

     TJavaUnicodeString={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

     jboolean=byte;        // unsigned 8 bits
     jbyte=shortint;       // signed 8 bits
     jchar=word;           // unsigned 16 bits
     jshort=smallint;      // signed 16 bits
     jint=longint;         // signed 32 bits
     jlong=int64;          // signed 64 bits
     jfloat=single;        // 32-bit IEEE 754
     jdouble=double;       // 64-bit IEEE 754

     jsize=jint;            // "cardinal indices and sizes"

     Pjboolean=^jboolean;
     Pjbyte=^jbyte;
     Pjchar=^jchar;
     Pjshort=^jshort;
     Pjint=^jint;
     Pjlong=^jlong;
     Pjfloat=^jfloat;
     Pjdouble=^jdouble;

     Pjsize=^jsize;

     // Reference type
     jobject=pointer;
     jclass=jobject;
     jstring=jobject;
     jarray=jobject;
     jobjectArray=jarray;
     jbooleanArray=jarray;
     jbyteArray=jarray;
     jcharArray=jarray;
     jshortArray=jarray;
     jintArray=jarray;
     jlongArray=jarray;
     jfloatArray=jarray;
     jdoubleArray=jarray;
     jthrowable=jobject;
     jweak=jobject;
     jref=jobject;

     PpvPointer=^pointer;
     Pjobject=^jobject;
     Pjclass=^jclass;
     Pjstring=^jstring;
     Pjarray=^jarray;
     PjobjectArray=^jobjectArray;
     PjbooleanArray=^jbooleanArray;
     PjbyteArray=^jbyteArray;
     PjcharArray=^jcharArray;
     PjshortArray=^jshortArray;
     PjintArray=^jintArray;
     PjlongArray=^jlongArray;
     PjfloatArray=^jfloatArray;
     PjdoubleArray=^jdoubleArray;
     Pjthrowable=^jthrowable;
     Pjweak=^jweak;
     Pjref=^jref;

     _jfieldID=record // opaque structure
     end;
     jfieldID=^_jfieldID;// field IDs
     PjfieldID=^jfieldID;

     _jmethodID=record // opaque structure
     end;
     jmethodID=^_jmethodID;// method IDs
     PjmethodID=^jmethodID;

     PJNIInvokeInterface=^JNIInvokeInterface;

     Pjvalue=^jvalue;
     jvalue={$ifdef packedrecords}packed{$endif} record
      case integer of
       0:(z:jboolean);
       1:(b:jbyte);
       2:(c:jchar);
       3:(s:jshort);
       4:(i:jint);
       5:(j:jlong);
       6:(f:jfloat);
       7:(d:jdouble);
       8:(l:jobject);
     end;

     jobjectRefType=(
      JNIInvalidRefType=0,
      JNILocalRefType=1,
      JNIGlobalRefType=2,
      JNIWeakGlobalRefType=3);

     PJNINativeMethod=^JNINativeMethod;
     JNINativeMethod={$ifdef packedrecords}packed{$endif} record
      name:pchar;
      signature:pchar;
      fnPtr:pointer;
     end;

     PJNINativeInterface=^JNINativeInterface;

     _JNIEnv={$ifdef packedrecords}packed{$endif} record
      functions:PJNINativeInterface;
     end;

     _JavaVM= record
      functions:PJNIInvokeInterface;
     end;
     P_JavaVM = ^_JavaVM;

     C_JNIEnv=^JNINativeInterface;
     JNIEnv=^JNINativeInterface;
     JavaVM=^JNIInvokeInterface;

     PPJNIEnv=^PJNIEnv;
     PJNIEnv=^JNIEnv;

     PPJavaVM=^PJavaVM;
     PJavaVM=^JavaVM;

     JNINativeInterface= record
      reserved0:pointer;
      reserved1:pointer;
      reserved2:pointer;
      reserved3:pointer;

      GetVersion:function(Env:PJNIEnv):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      DefineClass:function(Env:PJNIEnv;const Name:pchar;Loader:JObject;const Buf:PJByte;Len:JSize):JClass;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      FindClass:function(Env:PJNIEnv;const Name:pchar):JClass;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Reflection Support
      FromReflectedMethod:function(Env:PJNIEnv;Method:JObject):JMethodID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      FromReflectedField:function(Env:PJNIEnv;Field:JObject):JFieldID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ToReflectedMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;IsStatic:JBoolean):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetSuperclass:function(Env:PJNIEnv;Sub:JClass):JClass;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      IsAssignableFrom:function(Env:PJNIEnv;Sub:JClass;Sup:JClass):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Reflection Support
      ToReflectedField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;IsStatic:JBoolean):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      Throw:function(Env:PJNIEnv;Obj:JThrowable):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ThrowNew:function(Env:PJNIEnv;AClass:JClass;const Msg:pchar):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ExceptionOccurred:function(Env:PJNIEnv):JThrowable;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ExceptionDescribe:procedure(Env:PJNIEnv);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ExceptionClear:procedure(Env:PJNIEnv);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      FatalError:procedure(Env:PJNIEnv;const Msg:pchar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Local Reference Management
      PushLocalFrame:function(Env:PJNIEnv;Capacity:JInt):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      PopLocalFrame:function(Env:PJNIEnv;Result:JObject):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      NewGlobalRef:function(Env:PJNIEnv;LObj:JObject):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      DeleteGlobalRef:procedure(Env:PJNIEnv;GRef:JObject);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      DeleteLocalRef:procedure(Env:PJNIEnv;Obj:JObject);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      IsSameObject:function(Env:PJNIEnv;Obj1:JObject;Obj2:JObject):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Local Reference Management
      NewLocalRef:function(Env:PJNIEnv;Ref:JObject):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      EnsureLocalCapacity:function(Env:PJNIEnv;Capacity:JInt):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      AllocObject:function(Env:PJNIEnv;AClass:JClass):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewObject:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewObjectV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewObjectA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetObjectClass:function(Env:PJNIEnv;Obj:JObject):JClass;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      IsInstanceOf:function(Env:PJNIEnv;Obj:JObject;AClass:JClass):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetMethodID:function(Env:PJNIEnv;AClass:JClass;const Name:pchar;const Sig:pchar):JMethodID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallObjectMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallObjectMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallObjectMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallBooleanMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallBooleanMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallBooleanMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallByteMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallByteMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallByteMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallCharMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallCharMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallCharMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallShortMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallShortMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallShortMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallIntMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallIntMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallIntMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallLongMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallLongMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallLongMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallFloatMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallFloatMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallFloatMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallDoubleMethod:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallDoubleMethodV:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallDoubleMethodA:function(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallVoidMethod:procedure(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallVoidMethodV:procedure(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:va_list);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallVoidMethodA:procedure(Env:PJNIEnv;Obj:JObject;MethodID:JMethodID;Args:PJValue);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualObjectMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualObjectMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualObjectMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualBooleanMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualBooleanMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualBooleanMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualByteMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualByteMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualByteMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualCharMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualCharMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualCharMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualShortMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualShortMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualShortMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualIntMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualIntMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualIntMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualLongMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualLongMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualLongMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualFloatMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualFloatMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualFloatMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualDoubleMethod:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualDoubleMethodV:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualDoubleMethodA:function(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallNonvirtualVoidMethod:procedure(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualVoidMethodV:procedure(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:va_list);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallNonvirtualVoidMethodA:procedure(Env:PJNIEnv;Obj:JObject;AClass:JClass;MethodID:JMethodID;Args:PJValue);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetFieldID:function(Env:PJNIEnv;AClass:JClass;const Name:pchar;const Sig:pchar):JFieldID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetObjectField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetBooleanField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetByteField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetCharField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetShortField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetIntField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetLongField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetFloatField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetDoubleField:function(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      SetObjectField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JObject);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetBooleanField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JBoolean);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetByteField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JByte);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetCharField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetShortField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JShort);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetIntField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetLongField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JLong);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetFloatField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JFloat);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetDoubleField:procedure(Env:PJNIEnv;Obj:JObject;FieldID:JFieldID;Val:JDouble);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetStaticMethodID:function(Env:PJNIEnv;AClass:JClass;const Name:pchar;const Sig:pchar):JMethodID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticObjectMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticObjectMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticObjectMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticBooleanMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticBooleanMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticBooleanMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticByteMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticByteMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticByteMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticCharMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticCharMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticCharMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticShortMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticShortMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticShortMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticIntMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticIntMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticIntMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticLongMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticLongMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticLongMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticFloatMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticFloatMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticFloatMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticDoubleMethod:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticDoubleMethodV:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticDoubleMethodA:function(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      CallStaticVoidMethod:procedure(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticVoidMethodV:procedure(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:va_list);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      CallStaticVoidMethodA:procedure(Env:PJNIEnv;AClass:JClass;MethodID:JMethodID;Args:PJValue);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetStaticFieldID:function(Env:PJNIEnv;AClass:JClass;const Name:pchar;const Sig:pchar):JFieldID;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticObjectField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticBooleanField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticByteField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticCharField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticShortField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticIntField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticLongField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticFloatField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStaticDoubleField:function(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID):JDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      SetStaticObjectField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JObject);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticBooleanField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JBoolean);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticByteField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JByte);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticCharField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticShortField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JShort);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticIntField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticLongField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JLong);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticFloatField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JFloat);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetStaticDoubleField:procedure(Env:PJNIEnv;AClass:JClass;FieldID:JFieldID;Val:JDouble);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      NewString:function(Env:PJNIEnv;const Unicode:PJChar;Len:JSize):JString;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStringLength:function(Env:PJNIEnv;Str:JString):JSize;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStringChars:function(Env:PJNIEnv;Str:JString;IsCopy:PJBoolean):PJChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseStringChars:procedure(Env:PJNIEnv;Str:JString;const Chars:PJChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      NewStringUTF:function(Env:PJNIEnv;const UTF:pchar):JString;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStringUTFLength:function(Env:PJNIEnv;Str:JString):JSize;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStringUTFChars:function(Env:PJNIEnv;Str:JString;IsCopy:PJBoolean):pchar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseStringUTFChars:procedure(Env:PJNIEnv;Str:JString;const Chars:pchar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetArrayLength:function(Env:PJNIEnv;AArray:JArray):JSize;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      NewObjectArray:function(Env:PJNIEnv;Len:JSize;AClass:JClass;Init:JObject):JObjectArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetObjectArrayElement:function(Env:PJNIEnv;AArray:JObjectArray;Index:JSize):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetObjectArrayElement:procedure(Env:PJNIEnv;AArray:JObjectArray;Index:JSize;Val:JObject);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      NewBooleanArray:function(Env:PJNIEnv;Len:JSize):JBooleanArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewByteArray:function(Env:PJNIEnv;Len:JSize):JByteArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewCharArray:function(Env:PJNIEnv;Len:JSize):JCharArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewShortArray:function(Env:PJNIEnv;Len:JSize):JShortArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewIntArray:function(Env:PJNIEnv;Len:JSize):JIntArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewLongArray:function(Env:PJNIEnv;Len:JSize):JLongArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewFloatArray:function(Env:PJNIEnv;Len:JSize):JFloatArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      NewDoubleArray:function(Env:PJNIEnv;Len:JSize):JDoubleArray;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetBooleanArrayElements:function(Env:PJNIEnv;AArray:JBooleanArray;var IsCopy:JBoolean):PJBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetByteArrayElements:function(Env:PJNIEnv;AArray:JByteArray;var IsCopy:JBoolean):PJByte;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetCharArrayElements:function(Env:PJNIEnv;AArray:JCharArray;var IsCopy:JBoolean):PJChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetShortArrayElements:function(Env:PJNIEnv;AArray:JShortArray;var IsCopy:JBoolean):PJShort;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetIntArrayElements:function(Env:PJNIEnv;AArray:JIntArray;var IsCopy:JBoolean):PJInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetLongArrayElements:function(Env:PJNIEnv;AArray:JLongArray;var IsCopy:JBoolean):PJLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetFloatArrayElements:function(Env:PJNIEnv;AArray:JFloatArray;var IsCopy:JBoolean):PJFloat;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetDoubleArrayElements:function(Env:PJNIEnv;AArray:JDoubleArray;var IsCopy:JBoolean):PJDouble;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      ReleaseBooleanArrayElements:procedure(Env:PJNIEnv;AArray:JBooleanArray;Elems:PJBoolean;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseByteArrayElements:procedure(Env:PJNIEnv;AArray:JByteArray;Elems:PJByte;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseCharArrayElements:procedure(Env:PJNIEnv;AArray:JCharArray;Elems:PJChar;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseShortArrayElements:procedure(Env:PJNIEnv;AArray:JShortArray;Elems:PJShort;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseIntArrayElements:procedure(Env:PJNIEnv;AArray:JIntArray;Elems:PJInt;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseLongArrayElements:procedure(Env:PJNIEnv;AArray:JLongArray;Elems:PJLong;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseFloatArrayElements:procedure(Env:PJNIEnv;AArray:JFloatArray;Elems:PJFloat;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseDoubleArrayElements:procedure(Env:PJNIEnv;AArray:JDoubleArray;Elems:PJDouble;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetBooleanArrayRegion:procedure(Env:PJNIEnv;AArray:JBooleanArray;Start:JSize;Len:JSize;Buf:PJBoolean);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetByteArrayRegion:procedure(Env:PJNIEnv;AArray:JByteArray;Start:JSize;Len:JSize;Buf:PJByte);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetCharArrayRegion:procedure(Env:PJNIEnv;AArray:JCharArray;Start:JSize;Len:JSize;Buf:PJChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetShortArrayRegion:procedure(Env:PJNIEnv;AArray:JShortArray;Start:JSize;Len:JSize;Buf:PJShort);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetIntArrayRegion:procedure(Env:PJNIEnv;AArray:JIntArray;Start:JSize;Len:JSize;Buf:PJInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetLongArrayRegion:procedure(Env:PJNIEnv;AArray:JLongArray;Start:JSize;Len:JSize;Buf:PJLong);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetFloatArrayRegion:procedure(Env:PJNIEnv;AArray:JFloatArray;Start:JSize;Len:JSize;Buf:PJFloat);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetDoubleArrayRegion:procedure(Env:PJNIEnv;AArray:JDoubleArray;Start:JSize;Len:JSize;Buf:PJDouble);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      SetBooleanArrayRegion:procedure(Env:PJNIEnv;AArray:JBooleanArray;Start:JSize;Len:JSize;Buf:PJBoolean);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetByteArrayRegion:procedure(Env:PJNIEnv;AArray:JByteArray;Start:JSize;Len:JSize;Buf:PJByte);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetCharArrayRegion:procedure(Env:PJNIEnv;AArray:JCharArray;Start:JSize;Len:JSize;Buf:PJChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetShortArrayRegion:procedure(Env:PJNIEnv;AArray:JShortArray;Start:JSize;Len:JSize;Buf:PJShort);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetIntArrayRegion:procedure(Env:PJNIEnv;AArray:JIntArray;Start:JSize;Len:JSize;Buf:PJInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetLongArrayRegion:procedure(Env:PJNIEnv;AArray:JLongArray;Start:JSize;Len:JSize;Buf:PJLong);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetFloatArrayRegion:procedure(Env:PJNIEnv;AArray:JFloatArray;Start:JSize;Len:JSize;Buf:PJFloat);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      SetDoubleArrayRegion:procedure(Env:PJNIEnv;AArray:JDoubleArray;Start:JSize;Len:JSize;Buf:PJDouble);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      RegisterNatives:function(Env:PJNIEnv;AClass:JClass;const Methods:PJNINativeMethod;NMethods:JInt):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      UnregisterNatives:function(Env:PJNIEnv;AClass:JClass):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      MonitorEnter:function(Env:PJNIEnv;Obj:JObject):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      MonitorExit:function(Env:PJNIEnv;Obj:JObject):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      GetJavaVM:function(Env:PJNIEnv;var VM:JavaVM):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // String Operations
      GetStringRegion:procedure(Env:PJNIEnv;Str:JString;Start:JSize;Len:JSize;Buf:PJChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetStringUTFRegion:procedure(Env:PJNIEnv;Str:JString;Start:JSize;Len:JSize;Buf:pchar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Array Operations
      GetPrimitiveArrayCritical:function(Env:PJNIEnv;AArray:JArray;var IsCopy:JBoolean):pointer;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleasePrimitiveArrayCritical:procedure(Env:PJNIEnv;AArray:JArray;CArray:pointer;Mode:JInt);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // String Operations
      GetStringCritical:function(Env:PJNIEnv;Str:JString;var IsCopy:JBoolean):PJChar;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      ReleaseStringCritical:procedure(Env:PJNIEnv;Str:JString;CString:PJChar);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Weak Global References
      NewWeakGlobalRef:function(Env:PJNIEnv;Obj:JObject):JWeak;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      DeleteWeakGlobalRef:procedure(Env:PJNIEnv;Ref:JWeak);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // Exceptions
      ExceptionCheck:function(Env:PJNIEnv):JBoolean;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // J2SDK1_4
      NewDirectByteBuffer:function(Env:PJNIEnv;Address:pointer;Capacity:JLong):JObject;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetDirectBufferAddress:function(Env:PJNIEnv;Buf:JObject):pointer;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetDirectBufferCapacity:function(Env:PJNIEnv;Buf:JObject):JLong;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

      // added in JNI 1.6
      GetObjectRefType:function(Env:PJNIEnv;AObject:JObject):jobjectRefType;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
     end;

     JNIInvokeInterface= record
      reserved0:pointer;
      reserved1:pointer;
      reserved2:pointer;

      DestroyJavaVM:function(PVM:PJavaVM):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      AttachCurrentThread:function(PVM:PJavaVM;PEnv:PPJNIEnv;Args:pointer):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      DetachCurrentThread:function(PVM:PJavaVM):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      GetEnv:function(PVM:PJavaVM;PEnv:Ppvpointer;Version:JInt):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
      AttachCurrentThreadAsDaemon:function(PVM:PJavaVM;PEnv:PPJNIEnv;Args:pointer):JInt;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
     end;

     JavaVMAttachArgs=packed record
      version:jint;  // must be >= JNI_VERSION_1_2
      name:pchar;    // NULL or name of thread as modified UTF-8 str
      group:jobject; // global ref of a ThreadGroup object, or NULL
     end;

(**
 * JNI 1.2+ initialization.  (As of 1.6, the pre-1.2 structures are no
 * longer supported.)
 *)

     PJavaVMOption=^JavaVMOption;
     JavaVMOption={$ifdef packedrecords}packed{$endif} record
      optionString:pchar;
      extraInfo:pointer;
     end;

     JavaVMInitArgs={$ifdef packedrecords}packed{$endif} record
      version:jint; // use JNI_VERSION_1_2 or later
      nOptions:jint;
      options:PJavaVMOption;
      ignoreUnrecognized:Pjboolean;
     end;

(*
 * VM initialization functions.
 *
 * Note these are the only symbols exported for JNI by the VM.
 *)
{$ifdef jniexternals}
function JNI_GetDefaultJavaVMInitArgs(p:pointer):jint;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}external 'jni' name 'JNI_GetDefaultJavaVMInitArgs';
function JNI_CreateJavaVM(vm:PPJavaVM;AEnv:PPJNIEnv;p:pointer):jint;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}external 'jni' name 'JNI_CreateJavaVM';
function JNI_GetCreatedJavaVMs(vm:PPJavaVM;ASize:jsize;p:Pjsize):jint;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}external 'jni' name 'JNI_GetCreatedJavaVMs';
{$endif}

(*
 * Prototypes for functions exported by loadable shared libs.  These are
 * called by JNI, not provided by JNI.
 *)

var CurrentJavaVM:PJavaVM=nil;
    CurrentJNIEnv:PJNIEnv=nil;

function JNI_OnLoad(vm:PJavaVM;reserved:pointer):jint;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
procedure JNI_OnUnload(vm:PJavaVM;reserved:pointer);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}

type PARect=^TARect;
     TARect=packed record
      left:cint32;
      top:cint32;
      right:int32;
      bottom:cint32;
     end;

const LibAndroidName='libandroid.so';
      LibJNIGraphicsName='libjnigraphics.so';
      LibLogName='liblog.so';

      ANDROID_LOG_UNKNOWN=0;
      ANDROID_LOG_DEFAULT=1;
      ANDROID_LOG_VERBOSE=2;
      ANDROID_LOG_DEBUG=3;
      ANDROID_LOG_INFO=4;
      ANDROID_LOG_WARN=5;
      ANDROID_LOG_ERROR=6;
      ANDROID_LOG_FATAL=7;
      ANDROID_LOG_SILENT=8;

      ANDROID_BITMAP_RESUT_SUCCESS=0;
      ANDROID_BITMAP_RESULT_BAD_PARAMETER=-1;
      ANDROID_BITMAP_RESULT_JNI_EXCEPTION=-2;
      ANDROID_BITMAP_RESULT_ALLOCATION_FAILED=-3;
      
      WINDOW_FORMAT_RGBA_8888=1;
      WINDOW_FORMAT_RGBX_8888=2;
      WINDOW_FORMAT_RGB_565=4;

      ALOOPER_PREPARE_ALLOW_NON_CALLBACKS=1 shl 0;

      ALOOPER_POLL_WAKE=-1;
      ALOOPER_POLL_CALLBACK=-2;
      ALOOPER_POLL_TIMEOUT=-3;
      ALOOPER_POLL_ERROR=-4;

      ALOOPER_EVENT_INPUT=1 shl 0;
      ALOOPER_EVENT_OUTPUT=1 shl 1;
      ALOOPER_EVENT_ERROR=1 shl 2;
      ALOOPER_EVENT_HANGUP=1 shl 3;
      ALOOPER_EVENT_INVALID=1 shl 4;

      AKEYCODE_UNKNOWN=0;
      AKEYCODE_SOFT_LEFT=1;
      AKEYCODE_SOFT_RIGHT=2;
      AKEYCODE_HOME=3;
      AKEYCODE_BACK=4;
      AKEYCODE_CALL=5;
      AKEYCODE_ENDCALL=6;
      AKEYCODE_0=7;
      AKEYCODE_1=8;
      AKEYCODE_2=9;
      AKEYCODE_3=10;
      AKEYCODE_4=11;
      AKEYCODE_5=12;
      AKEYCODE_6=13;
      AKEYCODE_7=14;
      AKEYCODE_8=15;
      AKEYCODE_9=16;
      AKEYCODE_STAR=17;
      AKEYCODE_POUND=18;
      AKEYCODE_DPAD_UP=19;
      AKEYCODE_DPAD_DOWN=20;
      AKEYCODE_DPAD_LEFT=21;
      AKEYCODE_DPAD_RIGHT=22;
      AKEYCODE_DPAD_CENTER=23;
      AKEYCODE_VOLUME_UP=24;
      AKEYCODE_VOLUME_DOWN=25;
      AKEYCODE_POWER=26;
      AKEYCODE_CAMERA=27;
      AKEYCODE_CLEAR=28;
      AKEYCODE_A=29;
      AKEYCODE_B=30;
      AKEYCODE_C=31;
      AKEYCODE_D=32;
      AKEYCODE_E=33;
      AKEYCODE_F=34;
      AKEYCODE_G=35;
      AKEYCODE_H=36;
      AKEYCODE_I=37;
      AKEYCODE_J=38;
      AKEYCODE_K=39;
      AKEYCODE_L=40;
      AKEYCODE_M=41;
      AKEYCODE_N=42;
      AKEYCODE_O=43;
      AKEYCODE_P=44;
      AKEYCODE_Q=45;
      AKEYCODE_R=46;
      AKEYCODE_S=47;
      AKEYCODE_T=48;
      AKEYCODE_U=49;
      AKEYCODE_V=50;
      AKEYCODE_W=51;
      AKEYCODE_X=52;
      AKEYCODE_Y=53;
      AKEYCODE_Z=54;
      AKEYCODE_COMMA=55;
      AKEYCODE_PERIOD=56;
      AKEYCODE_ALT_LEFT=57;
      AKEYCODE_ALT_RIGHT=58;
      AKEYCODE_SHIFT_LEFT=59;
      AKEYCODE_SHIFT_RIGHT=60;
      AKEYCODE_TAB=61;
      AKEYCODE_SPACE=62;
      AKEYCODE_SYM=63;
      AKEYCODE_EXPLORER=64;
      AKEYCODE_ENVELOPE=65;
      AKEYCODE_ENTER=66;
      AKEYCODE_DEL=67;
      AKEYCODE_GRAVE=68;
      AKEYCODE_MINUS=69;
      AKEYCODE_EQUALS=70;
      AKEYCODE_LEFT_BRACKET=71;
      AKEYCODE_RIGHT_BRACKET=72;
      AKEYCODE_BACKSLASH=73;
      AKEYCODE_SEMICOLON=74;
      AKEYCODE_APOSTROPHE=75;
      AKEYCODE_SLASH=76;
      AKEYCODE_AT=77;
      AKEYCODE_NUM=78;
      AKEYCODE_HEADSETHOOK=79;
      AKEYCODE_FOCUS=80;  // *Camera* focus
      AKEYCODE_PLUS=81;
      AKEYCODE_MENU=82;
      AKEYCODE_NOTIFICATION=83;
      AKEYCODE_SEARCH=84;
      AKEYCODE_MEDIA_PLAY_PAUSE=85;
      AKEYCODE_MEDIA_STOP=86;
      AKEYCODE_MEDIA_NEXT=87;
      AKEYCODE_MEDIA_PREVIOUS=88;
      AKEYCODE_MEDIA_REWIND=89;
      AKEYCODE_MEDIA_FAST_FORWARD=90;
      AKEYCODE_MUTE=91;
      AKEYCODE_PAGE_UP=92;
      AKEYCODE_PAGE_DOWN=93;
      AKEYCODE_PICTSYMBOLS=94;
      AKEYCODE_SWITCH_CHARSET=95;
      AKEYCODE_BUTTON_A=96;
      AKEYCODE_BUTTON_B=97;
      AKEYCODE_BUTTON_C=98;
      AKEYCODE_BUTTON_X=99;
      AKEYCODE_BUTTON_Y=100;
      AKEYCODE_BUTTON_Z=101;
      AKEYCODE_BUTTON_L1=102;
      AKEYCODE_BUTTON_R1=103;
      AKEYCODE_BUTTON_L2=104;
      AKEYCODE_BUTTON_R2=105;
      AKEYCODE_BUTTON_THUMBL=106;
      AKEYCODE_BUTTON_THUMBR=107;
      AKEYCODE_BUTTON_START=108;
      AKEYCODE_BUTTON_SELECT=109;
      AKEYCODE_BUTTON_MODE=110;

      // Now all elements from android.view.KeyEvent

      ACTION_DOWN=0;
      ACTION_MULTIPLE=2;
      ACTION_UP=1;
      FLAG_CANCELED=$20;
      FLAG_CANCELED_LONG_PRESS=$100;
      FLAG_EDITOR_ACTION=$10;
      FLAG_FALLBACK=$400;
      FLAG_FROM_SYSTEM=8;
      FLAG_KEEP_TOUCH_MODE=4;
      FLAG_LONG_PRESS=$80;
      FLAG_SOFT_KEYBOARD=2;
      FLAG_TRACKING=$200;
      FLAG_VIRTUAL_HARD_KEY=$40;
      FLAG_WOKE_HERE=1;
      KEYCODE_0=7;
      KEYCODE_1=8;
      KEYCODE_2=9;
      KEYCODE_3=10;
      KEYCODE_3D_MODE=$000000ce; // 3D Mode key. Toggles the display between 2D and 3D mode.
      KEYCODE_4=11;
      KEYCODE_5=12;
      KEYCODE_6=13;
      KEYCODE_7=14;
      KEYCODE_8=15;
      KEYCODE_9=16;
      KEYCODE_A=29;
      KEYCODE_ALT_LEFT=$00000039;
      KEYCODE_ALT_RIGHT=$0000003a;
      KEYCODE_APOSTROPHE=$0000004b;
      KEYCODE_APP_SWITCH=$000000bb;
      KEYCODE_AT=$0000004d;
      KEYCODE_AVR_INPUT=$000000b6;
      KEYCODE_AVR_POWER=$000000b5;
      KEYCODE_B=30;
      KEYCODE_BACK=4;
      KEYCODE_BACKSLASH=$00000049;
      KEYCODE_BOOKMARK=$000000ae;
      KEYCODE_BREAK=$00000079;
      KEYCODE_BUTTON_1=$000000bc;
      KEYCODE_BUTTON_10=$000000c5;
      KEYCODE_BUTTON_11=$000000c6;
      KEYCODE_BUTTON_12=$000000c7;
      KEYCODE_BUTTON_13=$000000c8;
      KEYCODE_BUTTON_14=$000000c9;
      KEYCODE_BUTTON_15=$000000ca;
      KEYCODE_BUTTON_16=$000000cb; // Generic Game Pad Button #16.
      KEYCODE_BUTTON_2=$000000bd; // Generic Game Pad Button #2.
      KEYCODE_BUTTON_3=$000000be;
      KEYCODE_BUTTON_4=$000000bf;
      KEYCODE_BUTTON_5=$000000c0;
      KEYCODE_BUTTON_6=$000000c1;
      KEYCODE_BUTTON_7=$000000c2;
      KEYCODE_BUTTON_8=$000000c3;
      KEYCODE_BUTTON_9=$000000c4; // Generic Game Pad Button #9.
      KEYCODE_BUTTON_A=$00000060; // A Button key. On a game controller, the A button should be either the button labeled A or the first button on the upper row of controller buttons.
      KEYCODE_BUTTON_B=$00000061;
      KEYCODE_BUTTON_C=$00000062;
      KEYCODE_BUTTON_L1=$00000066; // L1 Button key. On a game controller, the L1 button should be either the button labeled L1 (or L) or the top left trigger button.
      KEYCODE_BUTTON_L2=$00000068;
      KEYCODE_BUTTON_MODE=$0000006e; // Mode Button key. On a game controller, the button labeled Mode.
      KEYCODE_BUTTON_R1=$00000067; // R1 Button key. On a game controller, the R1 button should be either the button labeled R1 (or R) or the top right trigger button.
      KEYCODE_BUTTON_R2=$00000069; // R2 Button key. On a game controller, the R2 button should be either the button labeled R2 or the bottom right trigger button.
      KEYCODE_BUTTON_SELECT=$0000006d; // Select Button key. On a game controller, the button labeled Select.
      KEYCODE_BUTTON_START=$0000006c; // Start Button key. On a game controller, the button labeled Start.
      KEYCODE_BUTTON_THUMBL=$0000006a; // Left Thumb Button key. On a game controller, the left thumb button indicates that the left (or only) joystick is pressed.
      KEYCODE_BUTTON_THUMBR=$0000006b; // Right Thumb Button key. On a game controller, the right thumb button indicates that the right joystick is pressed.
      KEYCODE_BUTTON_X=$00000063; // X Button key. On a game controller, the X button should be either the button labeled X or the first button on the lower row of controller buttons.
      KEYCODE_BUTTON_Y=$00000064; // Y Button key. On a game controller, the Y button should be either the button labeled Y or the second button on the lower row of controller buttons.
      KEYCODE_BUTTON_Z=$00000065; // Z Button key. On a game controller, the Z button should be either the button labeled Z or the third button on the lower row of controller buttons.
      KEYCODE_C=31; // 'C' key.
      KEYCODE_CALCULATOR=$000000d2; // Calculator special function key. Used to launch a calculator application.
      KEYCODE_CALENDAR=$000000d0; // Calendar special function key. Used to launch a calendar application.
      KEYCODE_CALL=$00000005; // Call key.
      KEYCODE_CAMERA=$0000001b; // Camera key. Used to launch a camera application or take pictures.
      KEYCODE_CAPS_LOCK=$00000073;
      KEYCODE_CAPTIONS=$000000af; // Toggle captions key. Switches the mode for closed-captioning text, for example during television shows.
      KEYCODE_CHANNEL_DOWN=$000000a7; // Channel down key. On TV remotes, decrements the television channel.
      KEYCODE_CHANNEL_UP=$000000a6; // Channel up key. On TV remotes, increments the television channel.
      KEYCODE_CLEAR=$0000001c;
      KEYCODE_COMMA=$00000037;
      KEYCODE_CONTACTS=$000000cf; // Contacts special function key. Used to launch an address book application.
      KEYCODE_CTRL_LEFT=$00000071; // Left Control modifier key.
      KEYCODE_CTRL_RIGHT=$00000072; // Right Control modifier key.
      KEYCODE_D=32;
      KEYCODE_DEL=$00000043; // Backspace key. Deletes characters before the insertion point, unlike KEYCODE_FORWARD_DEL.
      KEYCODE_DPAD_CENTER=$00000017; // Directional Pad Center key. May also be synthesized from trackball motions.
      KEYCODE_DPAD_DOWN=$00000014; // Directional Pad Down key. May also be synthesized from trackball motions.
      KEYCODE_DPAD_LEFT=$00000015; // Directional Pad Left key. May also be synthesized from trackball motions.
      KEYCODE_DPAD_RIGHT=$00000016; // Directional Pad Right key. May also be synthesized from trackball motions.
      KEYCODE_DPAD_UP=$00000013; // Directional Pad Up key. May also be synthesized from trackball motions.
      KEYCODE_DVR=$000000ad; // DVR key. On some TV remotes, switches to a DVR mode for recorded shows.
      KEYCODE_E=33;
      KEYCODE_ENDCALL=$00000006; // End Call key.
      KEYCODE_ENTER=$00000042; // Enter key.
      KEYCODE_ENVELOPE=$00000041; // Envelope special function key. Used to launch a mail application.
      KEYCODE_EQUALS=$00000046; // '=' key.
      KEYCODE_ESCAPE=$0000006f; // Escape key.
      KEYCODE_EXPLORER=$00000040; // Explorer special function key. Used to launch a browser application.
      KEYCODE_F=34; // 'F' key.
      KEYCODE_F1=$00000083;
      KEYCODE_F10=$0000008c;
      KEYCODE_F11=$0000008d;
      KEYCODE_F12=$0000008e;
      KEYCODE_F2=$00000084;
      KEYCODE_F3=$00000085;
      KEYCODE_F4=$00000086;
      KEYCODE_F5=$00000087;
      KEYCODE_F6=$00000088;
      KEYCODE_F7=$00000089;
      KEYCODE_F8=$0000008a;
      KEYCODE_F9=$0000008b;
      KEYCODE_FOCUS=$00000050; // Camera Focus key. Used to focus the camera.
      KEYCODE_FORWARD=$0000007d; // Forward key. Navigates forward in the history stack. Complement of KEYCODE_BACK.
      KEYCODE_FORWARD_DEL=$00000070; // Forward Delete key. Deletes characters ahead of the insertion point, unlike KEYCODE_DEL.
      KEYCODE_FUNCTION=$00000077; // Function modifier key.
      KEYCODE_G=35;
      KEYCODE_GRAVE=$00000044; // '`' (backtick) key.
      KEYCODE_GUIDE=$000000ac; // Guide key. On TV remotes, shows a programming guide.
      KEYCODE_H=36;
      KEYCODE_HEADSETHOOK=$0000004f; // Headset Hook key. Used to hang up calls and stop media.
      KEYCODE_HOME=$00000003; // Home key. This key is handled by the framework and is never delivered to applications.
      KEYCODE_I=37;
      KEYCODE_INFO=$000000a5; // Info key. Common on TV remotes to show additional information related to what is currently being viewed.
      KEYCODE_INSERT=$0000007c; // Insert key. Toggles insert / overwrite edit mode.
      KEYCODE_J=38;
      KEYCODE_K=39;
      KEYCODE_L=40;
      KEYCODE_LANGUAGE_SWITCH=$000000cc; // Language Switch key. Toggles the current input language such as switching between English and Japanese on a QWERTY keyboard. On some devices, the same function may be performed by pressing Shift+Spacebar.
      KEYCODE_LEFT_BRACKET=$00000047; // '[' key.
      KEYCODE_M=41;
      KEYCODE_MANNER_MODE=$000000cd; // Manner Mode key. Toggles silent or vibrate mode on and off to make the device behave more politely in certain settings such as on a crowded train. On some devices, the key may only operate when long-pressed.
      KEYCODE_MEDIA_CLOSE=$00000080; // Close media key. May be used to close a CD tray, for example.
      KEYCODE_MEDIA_EJECT=$00000081; // Eject media key. May be used to eject a CD tray, for example.
      KEYCODE_MEDIA_FAST_FORWARD=$0000005a; // Fast Forward media key.
      KEYCODE_MEDIA_NEXT=$00000057; // Play Next media key.
      KEYCODE_MEDIA_PAUSE=$0000007f; // Pause media key.
      KEYCODE_MEDIA_PLAY=$0000007e; // Play media key.
      KEYCODE_MEDIA_PLAY_PAUSE=$00000055; // Play/Pause media key.
      KEYCODE_MEDIA_PREVIOUS=$00000058; // Play Previous media key.
      KEYCODE_MEDIA_RECORD=$00000082; // Record media key.
      KEYCODE_MEDIA_REWIND=$00000059; // Rewind media key.
      KEYCODE_MEDIA_STOP=$00000056; // Stop media key.
      KEYCODE_MENU=$00000052; // Menu key.
      KEYCODE_META_LEFT=$00000075; // Left Meta modifier key.
      KEYCODE_META_RIGHT=$00000076; // Right Meta modifier key.
      KEYCODE_MINUS=$00000045; // '-'
      KEYCODE_MOVE_END =$0000007b; // End Movement key. Used for scrolling or moving the cursor around to the end of a line or to the bottom of a list.
      KEYCODE_MOVE_HOME=$0000007a; // Home Movement key. Used for scrolling or moving the cursor around to the start of a line or to the top of a list.
      KEYCODE_MUSIC=$000000d1; // Music special function key. Used to launch a music player application.
      KEYCODE_MUTE=$0000005b; //Mute key. Mutes the microphone, unlike KEYCODE_VOLUME_MUTE
      KEYCODE_N=42;
      KEYCODE_NOTIFICATION=$00000053;
      KEYCODE_NUM=$0000004e; // Number modifier key. Used to enter numeric symbols. This key is not Num Lock; it is more like KEYCODE_ALT_LEFT and is interpreted as an ALT key by MetaKeyKeyListener.
      KEYCODE_NUMPAD_0=$00000090;
      KEYCODE_NUMPAD_1=$00000091;
      KEYCODE_NUMPAD_2=$00000092;
      KEYCODE_NUMPAD_3=$00000093;
      KEYCODE_NUMPAD_4=$00000094;
      KEYCODE_NUMPAD_5=$00000095;
      KEYCODE_NUMPAD_6=$00000096;
      KEYCODE_NUMPAD_7=$00000097;
      KEYCODE_NUMPAD_8=$00000098;
      KEYCODE_NUMPAD_9=$00000099;
      KEYCODE_NUMPAD_ADD=$0000009d;
      KEYCODE_NUMPAD_COMMA=$0000009f;
      KEYCODE_NUMPAD_DIVIDE=$0000009a;
      KEYCODE_NUMPAD_DOT=$0000009e;
      KEYCODE_NUMPAD_ENTER=$000000a0;
      KEYCODE_NUMPAD_EQUALS=$000000a1;
      KEYCODE_NUMPAD_LEFT_PAREN=$000000a2;
      KEYCODE_NUMPAD_MULTIPLY=$0000009b;
      KEYCODE_NUMPAD_RIGHT_PAREN=$000000a3;
      KEYCODE_NUMPAD_SUBTRACT=$0000009c;
      KEYCODE_NUM_LOCK=$0000008f;
      KEYCODE_O=43;
      KEYCODE_P=44;
      KEYCODE_PAGE_DOWN=$0000005d;
      KEYCODE_PAGE_UP=$0000005c;
      KEYCODE_PERIOD=$00000038;
      KEYCODE_PICTSYMBOLS=$0000005e;
      KEYCODE_PLUS=$00000051; // '+' key
      KEYCODE_POUND=$00000012; // '#' key.
      KEYCODE_POWER=$0000001a;
      KEYCODE_PROG_BLUE=$000000ba;
      KEYCODE_PROG_GREEN=$000000b8;
      KEYCODE_PROG_RED=$000000b7;
      KEYCODE_PROG_YELLOW=$000000b9;
      KEYCODE_Q=45;
      KEYCODE_R=46;
      KEYCODE_RIGHT_BRACKET=$00000048;
      KEYCODE_S=47;
      KEYCODE_SCROLL_LOCK=$00000074;
      KEYCODE_SEARCH=$00000054;
      KEYCODE_SEMICOLON=$0000004a;
      KEYCODE_SETTINGS=$000000b0;
      KEYCODE_SHIFT_LEFT=59;
      KEYCODE_SHIFT_RIGHT=60;
      KEYCODE_SLASH=$0000004c; // '/' key.
      KEYCODE_SOFT_LEFT=$00000001;
      KEYCODE_SOFT_RIGHT=$00000002;
      KEYCODE_SPACE=$0000003e;
      KEYCODE_STAR=$00000011;
      KEYCODE_STB_INPUT=$000000b4;
      KEYCODE_STB_POWER=$000000b3;
      KEYCODE_SWITCH_CHARSET=$0000005f;
      KEYCODE_SYM=$0000003f; // Symbol modifier key. Used to enter alternate symbols.
      KEYCODE_SYSRQ=$00000078; // System Request / Print Screen key.
      KEYCODE_T=48;
      KEYCODE_TAB=$0000003d;
      KEYCODE_TV=$000000aa;
      KEYCODE_TV_INPUT=$000000b2;
      KEYCODE_TV_POWER=$000000b1;
      KEYCODE_U=49;
      KEYCODE_UNKNOWN=0;
      KEYCODE_V=50;
      KEYCODE_VOLUME_DOWN=$00000019;
      KEYCODE_VOLUME_MUTE=$000000a4;
      KEYCODE_VOLUME_UP=$00000018;
      KEYCODE_W=51;
      KEYCODE_WINDOW=$000000ab; // Window key. On TV remotes, toggles picture-in-picture mode or other windowing functions.
      KEYCODE_X=52;
      KEYCODE_Y=53;
      KEYCODE_Z=54;
      KEYCODE_ZOOM_IN=$000000a8;
      KEYCODE_ZOOM_OUT=$000000a9;
      MAX_KEYCODE=$00000054; // deprecated!
      META_ALT_LEFT_ON=$00000010;
      META_ALT_MASK=$00000032;
      META_ALT_ON=$00000002;
      META_ALT_RIGHT_ON=$00000020;
      META_CAPS_LOCK_ON=$00100000;
      META_CTRL_LEFT_ON=$00002000;
      META_CTRL_MASK=$00007000;
      META_CTRL_ON=$00001000;
      META_CTRL_RIGHT_ON=$00004000;
      META_FUNCTION_ON=$00000008;
      META_META_LEFT_ON=$00020000;
      META_META_MASK=$00070000;
      META_META_ON=$00010000;
      META_META_RIGHT_ON=$00040000;
      META_NUM_LOCK_ON=$00200000;
      META_SCROLL_LOCK_ON=$00400000;
      META_SHIFT_LEFT_ON=$00000040;
      META_SHIFT_MASK=$000000c1;
      META_SHIFT_ON=$00000001;
      META_SHIFT_RIGHT_ON=$00000080;
      META_SYM_ON=4;

      AKEY_STATE_UNKNOWN=-1;
      AKEY_STATE_UP=0;
      AKEY_STATE_DOWN=1;
      AKEY_STATE_VIRTUAL=2;

      AMETA_NONE=0;
      AMETA_SHIFT_ON=$01;
      AMETA_ALT_ON=$02;
      AMETA_SYM_ON=$04;
      AMETA_ALT_LEFT_ON=$10;
      AMETA_ALT_RIGHT_ON=$20;
      AMETA_SHIFT_LEFT_ON=$40;
      AMETA_SHIFT_RIGHT_ON=$80;

      AINPUT_EVENT_TYPE_KEY=1;
      AINPUT_EVENT_TYPE_MOTION=2;

      AKEY_EVENT_ACTION_DOWN=0;
      AKEY_EVENT_ACTION_UP=1;
      AKEY_EVENT_ACTION_MULTIPLE=2;

      AKEY_EVENT_FLAG_WOKE_HERE=$1;
      AKEY_EVENT_FLAG_SOFT_KEYBOARD=$2;
      AKEY_EVENT_FLAG_KEEP_TOUCH_MODE=$4;
      AKEY_EVENT_FLAG_FROM_SYSTEM=$8;
      AKEY_EVENT_FLAG_EDITOR_ACTION=$10;
      AKEY_EVENT_FLAG_CANCELED=$20;
      AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY=$40;
      AKEY_EVENT_FLAG_LONG_PRESS=$80;
      AKEY_EVENT_FLAG_CANCELED_LONG_PRESS=$100;
      AKEY_EVENT_FLAG_TRACKING=$200;

      AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT=8;

      AMOTION_EVENT_ACTION_DOWN=0;
      AMOTION_EVENT_ACTION_UP=1;
      AMOTION_EVENT_ACTION_MOVE=2;
      AMOTION_EVENT_ACTION_CANCEL=3;
      AMOTION_EVENT_ACTION_OUTSIDE=4;
      AMOTION_EVENT_ACTION_POINTER_DOWN=5;
      AMOTION_EVENT_ACTION_POINTER_UP=6;
      AMOTION_EVENT_ACTION_MASK=$ff;
      AMOTION_EVENT_ACTION_POINTER_INDEX_MASK=$ff00;

      AMOTION_EVENT_FLAG_WINDOW_IS_OBSCURED=$1;

      AMOTION_EVENT_EDGE_FLAG_NONE=0;
      AMOTION_EVENT_EDGE_FLAG_TOP=$01;
      AMOTION_EVENT_EDGE_FLAG_BOTTOM=$02;
      AMOTION_EVENT_EDGE_FLAG_LEFT=$04;
      AMOTION_EVENT_EDGE_FLAG_RIGHT=$08;

      AINPUT_SOURCE_CLASS_MASK=$000000ff;
      AINPUT_SOURCE_CLASS_NONE=$00000000;
      AINPUT_SOURCE_CLASS_BUTTON=$00000001;
      AINPUT_SOURCE_CLASS_POINTER=$00000002;
      AINPUT_SOURCE_CLASS_NAVIGATION=$00000004;
      AINPUT_SOURCE_CLASS_POSITION=$00000008;
      AINPUT_SOURCE_CLASS_JOYSTICK=$00000010;

      AINPUT_SOURCE_UNKNOWN=$00000000;
      AINPUT_SOURCE_KEYBOARD=$00000100 or AINPUT_SOURCE_CLASS_BUTTON;
      AINPUT_SOURCE_DPAD=$00000200 or AINPUT_SOURCE_CLASS_BUTTON;
      AINPUT_SOURCE_GAMEPAD=$00000400 or AINPUT_SOURCE_CLASS_BUTTON;
      AINPUT_SOURCE_TOUCHSCREEN=$00001000 or AINPUT_SOURCE_CLASS_POINTER;
      AINPUT_SOURCE_MOUSE=$00002000 or AINPUT_SOURCE_CLASS_POINTER;
      AINPUT_SOURCE_STYLUS=$00004000 or AINPUT_SOURCE_CLASS_POINTER;
      AINPUT_SOURCE_BLUETOOTH_STYLUS=$00008000 or AINPUT_SOURCE_CLASS_POINTER;
      AINPUT_SOURCE_TRACKBALL=$00010000 or AINPUT_SOURCE_CLASS_NAVIGATION;
      AINPUT_SOURCE_MOUSE_RELATIVE=$00020000 or AINPUT_SOURCE_CLASS_NAVIGATION;
      AINPUT_SOURCE_TOUCHPAD=$00100000 or AINPUT_SOURCE_CLASS_POSITION;
      AINPUT_SOURCE_NAVIGATION=$00200000 or AINPUT_SOURCE_CLASS_NONE;
      AINPUT_SOURCE_JOYSTICK=$01000000 or AINPUT_SOURCE_CLASS_JOYSTICK;
      AINPUT_SOURCE_ROTARY_ENCODER=$00400000 or AINPUT_SOURCE_CLASS_NONE;
      AINPUT_SOURCE_ANY=$ffffff00;

      AINPUT_KEYBOARD_TYPE_NONE=0;
      AINPUT_KEYBOARD_TYPE_NON_ALPHABETIC=1;
      AINPUT_KEYBOARD_TYPE_ALPHABETIC=2;

      AINPUT_MOTION_RANGE_X=0;
      AINPUT_MOTION_RANGE_Y=1;
      AINPUT_MOTION_RANGE_PRESSURE=2;
      AINPUT_MOTION_RANGE_SIZE=3;
      AINPUT_MOTION_RANGE_TOUCH_MAJOR=4;
      AINPUT_MOTION_RANGE_TOUCH_MINOR=5;
      AINPUT_MOTION_RANGE_TOOL_MAJOR=6;
      AINPUT_MOTION_RANGE_TOOL_MINOR=7;
      AINPUT_MOTION_RANGE_ORIENTATION=8;

      AASSET_MODE_UNKNOWN=0;
      AASSET_MODE_RANDOM=1;
      AASSET_MODE_STREAMING=2;
      AASSET_MODE_BUFFER=3;

      ANATIVEACTIVITY_SHOW_SOFT_INPUT_IMPLICIT=$0001;
      ANATIVEACTIVITY_SHOW_SOFT_INPUT_FORCED=$0002;

      ANATIVEACTIVITY_HIDE_SOFT_INPUT_IMPLICIT_ONLY=$0001;
      ANATIVEACTIVITY_HIDE_SOFT_INPUT_NOT_ALWAYS=$0002;

      ACONFIGURATION_ORIENTATION_ANY=$0000;
      ACONFIGURATION_ORIENTATION_PORT=$0001;
      ACONFIGURATION_ORIENTATION_LAND=$0002;
      ACONFIGURATION_ORIENTATION_SQUARE=$0003;
      ACONFIGURATION_TOUCHSCREEN_ANY=$0000;
      ACONFIGURATION_TOUCHSCREEN_NOTOUCH=$0001;
      ACONFIGURATION_TOUCHSCREEN_STYLUS=$0002;
      ACONFIGURATION_TOUCHSCREEN_FINGER=$0003;
      ACONFIGURATION_DENSITY_DEFAULT=0;
      ACONFIGURATION_DENSITY_LOW=120;
      ACONFIGURATION_DENSITY_MEDIUM=160;
      ACONFIGURATION_DENSITY_HIGH=240;
      ACONFIGURATION_DENSITY_NONE=$ffff;
      ACONFIGURATION_KEYBOARD_ANY=$0000;
      ACONFIGURATION_KEYBOARD_NOKEYS=$0001;
      ACONFIGURATION_KEYBOARD_QWERTY=$0002;
      ACONFIGURATION_KEYBOARD_12KEY=$0003;
      ACONFIGURATION_NAVIGATION_ANY=$0000;
      ACONFIGURATION_NAVIGATION_NONAV=$0001;
      ACONFIGURATION_NAVIGATION_DPAD=$0002;
      ACONFIGURATION_NAVIGATION_TRACKBALL=$0003;
      ACONFIGURATION_NAVIGATION_WHEEL=$0004;
      ACONFIGURATION_KEYSHIDDEN_ANY=$0000;
      ACONFIGURATION_KEYSHIDDEN_NO=$0001;
      ACONFIGURATION_KEYSHIDDEN_YES=$0002;
      ACONFIGURATION_KEYSHIDDEN_SOFT=$0003;
      ACONFIGURATION_NAVHIDDEN_ANY=$0000;
      ACONFIGURATION_NAVHIDDEN_NO=$0001;
      ACONFIGURATION_NAVHIDDEN_YES=$0002;
      ACONFIGURATION_SCREENSIZE_ANY=$00;
      ACONFIGURATION_SCREENSIZE_SMALL=$01;
      ACONFIGURATION_SCREENSIZE_NORMAL=$02;
      ACONFIGURATION_SCREENSIZE_LARGE=$03;
      ACONFIGURATION_SCREENSIZE_XLARGE=$04;
      ACONFIGURATION_SCREENLONG_ANY=$00;
      ACONFIGURATION_SCREENLONG_NO=$1;
      ACONFIGURATION_SCREENLONG_YES=$2;
      ACONFIGURATION_UI_MODE_TYPE_ANY=$00;
      ACONFIGURATION_UI_MODE_TYPE_NORMAL=$01;
      ACONFIGURATION_UI_MODE_TYPE_DESK=$02;
      ACONFIGURATION_UI_MODE_TYPE_CAR=$03;
      ACONFIGURATION_UI_MODE_NIGHT_ANY=$00;
      ACONFIGURATION_UI_MODE_NIGHT_NO=$1;
      ACONFIGURATION_UI_MODE_NIGHT_YES=$2;
      ACONFIGURATION_MCC=$0001;
      ACONFIGURATION_MNC=$0002;
      ACONFIGURATION_LOCALE=$0004;
      ACONFIGURATION_TOUCHSCREEN=$0008;
      ACONFIGURATION_KEYBOARD=$0010;
      ACONFIGURATION_KEYBOARD_HIDDEN=$0020;
      ACONFIGURATION_NAVIGATION=$0040;
      ACONFIGURATION_ORIENTATION=$0080;
      ACONFIGURATION_DENSITY=$0100;
      ACONFIGURATION_SCREEN_SIZE=$0200;
      ACONFIGURATION_VERSION=$0400;
      ACONFIGURATION_SCREEN_LAYOUT=$0800;
      ACONFIGURATION_UI_MODE=$1000;

type android_LogPriority=cint;

     Pint=^cint;

     PANativeWindow=^TANativeWindow;
     TANativeWindow=record
     end;

     PANativeWindow_Buffer=^TANativeWindow_Buffer;
     TANativeWindow_Buffer=packed record
      width:cint32;
      height:cint32;
      stride:cint32;
      format:cint32;
      bits:pointer;
      reserved:array[0..5] of cuint32;
     end;

     PALooper=^TALooper;
     TALooper=record
     end;

     PPAInputEvent=^PAInputEvent;
     PAInputEvent=^TAInputEvent;
     TAInputEvent=record
     end;

     PAInputQueue=^TAInputQueue;
     TAInputQueue=record
     end;

     TALooper_callbackFunc=function(fd,events:cint;data:Pointer):cint; cdecl;

     PAndroidBitmapFormat=^TAndroidBitmapFormat;
     TAndroidBitmapFormat=(
      ANDROID_BITMAP_FORMAT_NONE=0,
      ANDROID_BITMAP_FORMAT_RGBA_8888=1,
      ANDROID_BITMAP_FORMAT_RGB_565=4,
      ANDROID_BITMAP_FORMAT_RGBA_4444=7,
      ANDROID_BITMAP_FORMAT_A_8=8
     );

     PAndroidBitmapInfo=^TAndroidBitmapInfo;
     TAndroidBitmapInfo=record
      width:uint32;
      height:uint32;
      stride:uint32;
      format:int32;
      flags:uint32;
     end;

     PAAssetManager=^TAAssetManager;
     TAAssetManager=record
     end;

     PAAssetDir=^TAAssetDir;
     TAAssetDir=record
     end;

     PAAsset=^tAAsset;
     TAAsset=record
     end;

     PAConfiguration=^TAConfiguration;
     TAConfiguration=record
     end;

     Poff_t=^coff_t;

     PANativeActivityCallbacks=^TANativeActivityCallbacks;

     PANativeActivity=^TANativeActivity;
     TANativeActivity=packed record
      callbacks:PANativeActivityCallbacks;
      vm:PJavaVM;
      env:PJNIEnv;
      clazz:jobject;
      internalDataPath:PAnsiChar;
      externalDataPath:PAnsiChar;
      sdkVersion:longword;
      instance:Pointer;
      assetManager:PAAssetManager;
     end;

     Psize_t=^csize_t;

     TANativeActivityCallbacks=packed record
      onStart:procedure(activity:PANativeActivity); cdecl;
      onResume:procedure(activity:PANativeActivity); cdecl;
      onSaveInstanceState:function(activity:PANativeActivity;outSize:Psize_t):Pointer; cdecl;
      onPause:procedure(activity:PANativeActivity); cdecl;
      onStop:procedure(activity:PANativeActivity); cdecl;
      onDestroy:procedure(activity:PANativeActivity); cdecl;
      onWindowFocusChanged:procedure(activity:PANativeActivity;hasFocus:cint); cdecl;
      onNativeWindowCreated:procedure(activity:PANativeActivity;window:PANativeWindow); cdecl;
      onNativeWindowResized:procedure(activity:PANativeActivity;window:PANativeWindow); cdecl;
      onNativeWindowRedrawNeeded:procedure(activity:PANativeActivity;window:PANativeWindow); cdecl;
      onNativeWindowDestroyed:procedure(activity:PANativeActivity;window:PANativeWindow); cdecl;
      onInputQueueCreated:procedure(activity:PANativeActivity;queue:PAInputQueue); cdecl;
      onInputQueueDestroyed:procedure(activity:PANativeActivity;queue:PAInputQueue); cdecl;
      onContentRectChanged:procedure(activity:PANativeActivity;rect:PARect); cdecl;
      onConfigurationChanged:procedure(activity:PANativeActivity); cdecl;
      onLowMemory:procedure(activity:PANativeActivity); cdecl;
     end;

     TANativeActivity_createFunc=procedure(activity:PANativeActivity;savedState:pointer;savedStateSize:SizeInt); cdecl;

//var ANativeActivity_onCreate:TANativeActivity_createFunc; external;

function __android_log_write(prio:cint;tag,text:PAnsiChar):cint; cdecl; external LibLogName name '__android_log_write';
function LOGI(prio:longint;tag,text:PAnsiChar):cint; cdecl; varargs; external LibLogName name '__android_log_print';

procedure LOGW(const Text:PAnsiChar;const Tag:PAnsiChar='');
//function __android_log_print(prio:cint;tag,print:PAnsiChar;params:array of PAnsiChar):cint; cdecl; external LibLogName name '__android_log_print';

procedure ANativeWindow_acquire(window:PANativeWindow); cdecl; external LibAndroidName name 'ANativeWindow_acquire';
procedure ANativeWindow_release(window:PANativeWindow); cdecl; external LibAndroidName name 'ANativeWindow_release';
function ANativeWindow_getWidth(window:PANativeWindow):cint32; cdecl; external LibAndroidName name 'ANativeWindow_getWidth';
function ANativeWindow_getHeight(window:PANativeWindow):cint32; cdecl; external LibAndroidName name 'ANativeWindow_getHeight';
function ANativeWindow_getFormat(window:PANativeWindow):cint32; cdecl; external LibAndroidName name 'ANativeWindow_getFormat';
function ANativeWindow_setBuffersGeometry(window:PANativeWindow;width,height,format:cint32):cint32; cdecl; external LibAndroidName name 'ANativeWindow_setBuffersGeometry';
function ANativeWindow_lock(window:PANativeWindow;outBuffer:PANativeWindow_Buffer;inOutDirtyBounds:PARect):cint32; cdecl; external LibAndroidName name 'ANativeWindow_lock';
function ANativeWindow_unlockAndPost(window:PANativeWindow):cint32; cdecl; external LibAndroidName name 'ANativeWindow_unlockAndPost';

function ALooper_forThread:PALooper; cdecl; external LibAndroidName name 'ALooper_forThread';
function ALooper_prepare(opts:cint):PALooper; cdecl; external LibAndroidName name 'ALooper_prepare';
procedure ALooper_acquire(looper:PALooper); cdecl; external LibAndroidName name 'ALooper_acquire';
procedure ALooper_release(looper:PALooper); cdecl; external LibAndroidName name 'ALooper_release';
function ALooper_pollOnce(timeoutMillis:cint;outFd,outEvents:Pint;outData:PpvPointer):cint; cdecl; external LibAndroidName name 'ALooper_pollOnce';
function ALooper_pollAll(timeoutMillis:cint;outFd,outEvents:Pint;outData:PpvPointer):cint; cdecl; external LibAndroidName name 'ALooper_pollAll';
procedure ALooper_wake(looper:PALooper); cdecl; external LibAndroidName name 'ALooper_wake';
function ALooper_addFd(looper:PALooper;fd,ident,events:cint;callback:TALooper_callbackFunc;data:Pointer):cint; cdecl; external LibAndroidName name 'ALooper_addFd';
function ALooper_removeFd(looper:PALooper;fd:cint):cint; cdecl; external LibAndroidName name 'ALooper_removeFd';

function AInputEvent_getType(event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AInputEvent_getType';
function AInputEvent_getDeviceId(event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AInputEvent_getDeviceId';
function AInputEvent_getSource(event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AInputEvent_getSource';
function AKeyEvent_getAction(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getAction';
function AKeyEvent_getFlags(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getFlags';
function AKeyEvent_getKeyCode(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getKeyCode';
function AKeyEvent_getScanCode(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getScanCode';
function AKeyEvent_getMetaState(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getMetaState';
function AKeyEvent_getRepeatCount(key_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AKeyEvent_getRepeatCount';
function AKeyEvent_getDownTime(key_event:PAInputEvent):cint64; cdecl; external LibAndroidName name 'AKeyEvent_getDownTime';
function AKeyEvent_getEventTime(key_event:PAInputEvent):cint64; cdecl; external LibAndroidName name 'AKeyEvent_getEventTime';
function AMotionEvent_getAction(motion_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AMotionEvent_getAction';
function AMotionEvent_getFlags(motion_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AMotionEvent_getFlags';
function AMotionEvent_getMetaState(motion_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AMotionEvent_getMetaState';
function AMotionEvent_getEdgeFlags(motion_event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AMotionEvent_getEdgeFlags';
function AMotionEvent_getDownTime(motion_event:PAInputEvent):cint64; cdecl; external LibAndroidName name 'AMotionEvent_getDownTime';
function AMotionEvent_getEventTime(motion_event:PAInputEvent):cint64; cdecl; external LibAndroidName name 'AMotionEvent_getEventTime';
function AMotionEvent_getXOffset(motion_event:PAInputEvent):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getXOffset';
function AMotionEvent_getYOffset(motion_event:PAInputEvent):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getYOffset';
function AMotionEvent_getXPrecision(motion_event:PAInputEvent):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getXPrecision';
function AMotionEvent_getYPrecision(motion_event:PAInputEvent):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getYPrecision';
function AMotionEvent_getPointerCount(motion_event:PAInputEvent):csize_t; cdecl; external LibAndroidName name 'AMotionEvent_getPointerCount';
function AMotionEvent_getPointerId(motion_event:PAInputEvent;pointer_index:csize_t):cint32; cdecl; external LibAndroidName name 'AMotionEvent_getPointerId';
function AMotionEvent_getRawX(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getRawX';
function AMotionEvent_getRawY(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getRawY';
function AMotionEvent_getX(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getX';
function AMotionEvent_getY(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getY';
function AMotionEvent_getPressure(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getPressure';
function AMotionEvent_getSize(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getSize';
function AMotionEvent_getTouchMajor(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getTouchMajor';
function AMotionEvent_getTouchMinor(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getTouchMinor';
function AMotionEvent_getToolMajor(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getToolMajor';
function AMotionEvent_getToolMinor(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getToolMinor';
function AMotionEvent_getOrientation(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getOrientation';
function AMotionEvent_getHistorySize(motion_event:PAInputEvent):csize_t; cdecl; external LibAndroidName name 'AMotionEvent_getHistorySize';
function AMotionEvent_getHistoricalEventTime(motion_event:PAInputEvent;history_index:csize_t):cint64; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalEventTime';
function AMotionEvent_getHistoricalRawX(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalRawX';
function AMotionEvent_getHistoricalRawY(motion_event:PAInputEvent;pointer_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalRawY';
function AMotionEvent_getHistoricalX(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalX';
function AMotionEvent_getHistoricalY(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalY';
function AMotionEvent_getHistoricalPressure(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalPressure';
function AMotionEvent_getHistoricalSize(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalSize';
function AMotionEvent_getHistoricalTouchMajor(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalTouchMajor';
function AMotionEvent_getHistoricalTouchMinor(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalTouchMinor';
function AMotionEvent_getHistoricalToolMajor(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalToolMajor';
function AMotionEvent_getHistoricalToolMinor(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalToolMinor';
function AMotionEvent_getHistoricalOrientation(motion_event:PAInputEvent;pointer_index,history_index:csize_t):cfloat; cdecl; external LibAndroidName name 'AMotionEvent_getHistoricalOrientation';

procedure AInputQueue_attachLooper(queue:PAInputQueue;looper:PALooper;ident:cint;callback:TALooper_callbackFunc;data:Pointer); cdecl; external LibAndroidName name 'AInputQueue_attachLooper';
procedure AInputQueue_detachLooper(queue:PAInputQueue); cdecl; external LibAndroidName name 'AInputQueue_detachLooper';
function AInputQueue_hasEvents(queue:PAInputQueue):cint32; cdecl; external LibAndroidName name 'AInputQueue_hasEvents';
function AInputQueue_getEvent(queue:PAInputQueue;outEvent:PPAInputEvent):cint32; cdecl; external LibAndroidName name 'AInputQueue_getEvent';
function AInputQueue_preDispatchEvent(queue:PAInputQueue;event:PAInputEvent):cint32; cdecl; external LibAndroidName name 'AInputQueue_preDispatchEvent';
procedure AInputQueue_finishEvent(queue:PAInputQueue;event:PAInputEvent;handled:cint); cdecl; external LibAndroidName name 'AInputQueue_finishEvent';

function AndroidBitmap_getInfo(env:PJNIEnv;jbitmap:jobject;info: PAndroidBitmapInfo):cint; cdecl; external LibJNIGraphicsName name 'AndroidBitmap_getInfo';
function AndroidBitmap_lockPixels(env:PJNIEnv;jbitmap:jobject;addrPtr:PpvPointer):cint; cdecl; external LibJNIGraphicsName name 'AndroidBitmap_lockPixels';
function AndroidBitmap_unlockPixels(env:PJNIEnv;jbitmap:jobject):cint; cdecl; external LibJNIGraphicsName name 'AndroidBitmap_unlockPixels';

function AAssetManager_fromJava(env:PJNIEnv;assetManager:JObject): PAAssetManager; cdecl; external LibAndroidName name 'AAssetManager_fromJava';
function AAssetManager_openDir(mgr:PAAssetManager;dirName:PAnsiChar):PAAssetDir; cdecl; external LibAndroidName name 'AAssetManager_openDir';
function AAssetManager_open(mgr:PAAssetManager;filename:PAnsiChar;mode:cint):PAAsset; cdecl; external LibAndroidName name 'AAssetManager_open';
function AAssetDir_getNextFileName(assetDir:PAAssetDir):PAnsiChar; cdecl; external LibAndroidName name 'AAssetDir_getNextFileName';
procedure AAssetDir_rewind(assetDir:PAAssetDir); cdecl; external LibAndroidName name 'AAssetDir_rewind';
procedure AAssetDir_close(assetDir:PAAssetDir); cdecl; external LibAndroidName name 'AAssetDir_close';
function AAsset_read(asset:PAAsset;buf:Pointer;count:csize_t):cint; cdecl; external LibAndroidName name 'AAsset_read';
function AAsset_seek(asset:PAAsset;offset:coff_t;whence:cint):coff_t; cdecl; external LibAndroidName name 'AAsset_seek';
procedure AAsset_close(asset:PAAsset); cdecl; external LibAndroidName name 'AAsset_close';
function AAsset_getBuffer(asset:PAAsset):Pointer; cdecl; external LibAndroidName name 'AAsset_getBuffer';
function AAsset_getLength(asset:PAAsset):coff_t; cdecl; external LibAndroidName name 'AAsset_getLength';
function AAsset_getRemainingLength(asset:PAAsset):coff_t; cdecl; external LibAndroidName name 'AAsset_getRemainingLength';
function AAsset_openFileDescriptor(asset:PAAsset;outStart,outLength:Poff_t):cint; cdecl; external LibAndroidName name 'AAsset_openFileDescriptor';
function AAsset_isAllocated(asset:PAAsset):cint; cdecl; external LibAndroidName name 'AAsset_isAllocated';

procedure ANativeActivity_finish(activity:PANativeActivity); cdecl; external LibAndroidName name 'ANativeActivity_finish';
procedure ANativeActivity_setWindowFormat(activity:PANativeActivity;format:cint32); cdecl; external LibAndroidName name 'ANativeActivity_setWindowFormat';
procedure ANativeActivity_setWindowFlags(activity:PANativeActivity;addFlags,removeFlags:cuint32); cdecl; external LibAndroidName name 'ANativeActivity_setWindowFlags';
procedure ANativeActivity_showSoftInput(activity:PANativeActivity;flags:cuint32); cdecl; external LibAndroidName name 'ANativeActivity_showSoftInput';
procedure ANativeActivity_hideSoftInput(activity:PANativeActivity;flags:cuint32); cdecl; external LibAndroidName name 'ANativeActivity_hideSoftInput';

function AConfiguration_new:PAConfiguration; cdecl; external LibAndroidName;
procedure AConfiguration_delete(config:PAConfiguration); cdecl; external LibAndroidName;
procedure AConfiguration_fromAssetManager(out_:PAConfiguration;am:PAAssetManager); cdecl; external LibAndroidName;
procedure AConfiguration_copy(dest,src:PAConfiguration); cdecl; external LibAndroidName;
function AConfiguration_getMcc(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setMcc(config:PAConfiguration;mcc:cint32); cdecl; external LibAndroidName;
function AConfiguration_getMnc(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setMnc(config:PAConfiguration;mnc:cint32); cdecl; external LibAndroidName;
procedure AConfiguration_getLanguage(config:PAConfiguration;outLanguage:Pchar); cdecl; external LibAndroidName;
procedure AConfiguration_setLanguage(config:PAConfiguration;language:Pchar); cdecl; external LibAndroidName;
procedure AConfiguration_getCountry(config:PAConfiguration;outCountry:Pchar); cdecl; external LibAndroidName;
procedure AConfiguration_setCountry(config:PAConfiguration;country:Pchar); cdecl; external LibAndroidName;
function AConfiguration_getOrientation(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setOrientation(config:PAConfiguration; orientation:cint32); cdecl; external LibAndroidName;
function AConfiguration_getTouchscreen(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setTouchscreen(config:PAConfiguration; touchscreen:cint32); cdecl; external LibAndroidName;
function AConfiguration_getDensity(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setDensity(config:PAConfiguration; density:cint32); cdecl; external LibAndroidName;
function AConfiguration_getKeyboard(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setKeyboard(config:PAConfiguration; keyboard:cint32); cdecl; external LibAndroidName;
function AConfiguration_getNavigation(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setNavigation(config:PAConfiguration; navigation:cint32); cdecl; external LibAndroidName;
function AConfiguration_getKeysHidden(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setKeysHidden(config:PAConfiguration; keysHidden:cint32); cdecl; external LibAndroidName;
function AConfiguration_getNavHidden(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setNavHidden(config:PAConfiguration; navHidden:cint32); cdecl; external LibAndroidName;
function AConfiguration_getSdkVersion(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setSdkVersion(config:PAConfiguration; sdkVersion:cint32); cdecl; external LibAndroidName;
function AConfiguration_getScreenSize(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setScreenSize(config:PAConfiguration; screenSize:cint32); cdecl; external LibAndroidName;
function AConfiguration_getScreenLong(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setScreenLong(config:PAConfiguration; screenLong:cint32); cdecl; external LibAndroidName;
function AConfiguration_getUiModeType(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setUiModeType(config:PAConfiguration; uiModeType:cint32); cdecl; external LibAndroidName;
function AConfiguration_getUiModeNight(config:PAConfiguration):cint32; cdecl; external LibAndroidName;
procedure AConfiguration_setUiModeNight(config:PAConfiguration; uiModeNight:cint32); cdecl; external LibAndroidName;
function AConfiguration_diff(config1,config2:PAConfiguration):cint32; cdecl; external LibAndroidName;
function AConfiguration_match(base,requested:PAConfiguration):cint32; cdecl; external LibAndroidName;
function AConfiguration_isBetterThan(base,test,requested:PAConfiguration) :cint32; cdecl; external LibAndroidName;

function JStringToString(const aEnv:PJNIEnv;const aStr:JString):TJavaUnicodeString;
function StringToJString(const aEnv:PJNIEnv;const aStr:TJavaUnicodeString):JString;
procedure FreeJString(const aEnv:PJNIEnv;const aStr:JString);

function GetHandleField(const aEnv:PJNIEnv;const aObj:jobject):jfieldID;
function GetHandle(const aEnv:PJNIEnv;const aObj:jobject):pointer;
procedure SetHandle(const aEnv:PJNIEnv;const aObj:jobject;const aPointer:pointer);

{$ifend}

implementation

{$if defined(fpc) and defined(Android)}
function JNI_OnLoad(vm:PJavaVM;reserved:pointer):jint;{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
begin
{$ifndef Release}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering JNI_OnLoad . . .');
{$endif}
 CurrentJavaVM:=vm;
 result:=JNI_VERSION_1_6;
{$ifndef Release}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving JNI_OnLoad . . .');
{$endif}
end;

procedure JNI_OnUnload(vm:PJavaVM;reserved:pointer);{$ifdef mswindows}stdcall;{$else}cdecl;{$endif}
begin
{$ifndef Release}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering JNI_OnUnload . . .');
{$endif}
{$ifndef Release}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving JNI_OnUnload . . .');
{$endif}
end;

procedure LOGW(const Text:PAnsiChar;const Tag:PAnsiChar='');
begin
 __android_log_write(ANDROID_LOG_FATAL,Tag,text);
end;

function JStringToString(const aEnv:PJNIEnv;const aStr:JString):TJavaUnicodeString;
var Len:Int32;
    IsCopy:JBoolean;
    Chars:PJChar;
begin
 result:='';
 if assigned(aStr) then begin
  Len:=aEnv^.GetStringLength(aEnv,aStr);
  if Len>0 then begin
   IsCopy:=0;
   Chars:=aEnv^.GetStringChars(aEnv,aStr,@IsCopy);
   if assigned(Chars) then begin
    try
     SetLength(result,Len);
     Move(Chars^,result[1],Len*SizeOf(WideChar));
    finally
     aEnv^.ReleaseStringChars(aEnv,aStr,Chars);
    end;
   end;
  end;
 end;
end;

function StringToJString(const aEnv:PJNIEnv;const aStr:TJavaUnicodeString):JString;
var l:jsize;
begin
//__android_log_write(ANDROID_LOG_DEBUG,'PasAndroidApplication',PAnsiChar(AnsiString('StringToJString Before: '+aStr)));
 l:=length(aStr);
 if l>0 then begin
  result:=aEnv^.NewString(aEnv,@aStr[1],l);
 end else begin
  result:=aEnv^.NewString(aEnv,nil,0);
 end;
//__android_log_write(ANDROID_LOG_DEBUG,'PasAndroidApplication',PAnsiChar(AnsiString('StringToJString After: '+aStr)));
end;

procedure FreeJString(const aEnv:PJNIEnv;const aStr:JString);
begin
 aEnv^.DeleteLocalRef(aEnv,aStr);
end;

function GetHandleField(const aEnv:PJNIEnv;const aObj:jobject):jfieldID;
begin
 result:=aEnv^.GetFieldID(aEnv,aEnv^.GetObjectClass(aEnv,aObj),'nativeHandle','J');
end;

function GetHandle(const aEnv:PJNIEnv;const aObj:jobject):pointer;
begin
 result:=pointer(PtrUInt(jlong(aEnv^.GetLongField(aEnv,aObj,GetHandleField(aEnv,aObj)))));
end;

procedure SetHandle(const aEnv:PJNIEnv;const aObj:jobject;const aPointer:pointer);
begin
 aEnv^.SetLongField(aEnv,aObj,GetHandleField(aEnv,aObj),jlong(PtrUInt(pointer(aPointer))));
end;

{$ifend}

end.
