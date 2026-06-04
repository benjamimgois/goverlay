/*******************************************************************************
                                 L I C E N S E
********************************************************************************

FLRE - Fast Light Regular Expressions - A fast light regular expression library
Copyright (C) 2015-2022, Benjamin 'BeRo' Rosseaux

The source code of the FLRE engine library and helper tools are
distributed under the Library GNU Lesser General Public License Version 2.1 
(see the files COPYING and COPYING.FLRE) with the following modification:

As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent modules,
and to copy and distribute the resulting executable under terms of your choice,
provided that you also meet, for each linked independent module, the terms
and conditions of the license of that module. An independent module is a module
which is not derived from or based on this library. If you modify this
library, you may extend this exception to your version of the library, but you
are not obligated to do so. If you do not wish to do so, delete this exception
statement from your version.

If you didn't receive a copy of the license, see <http://www.gnu.org/licenses/>
or contact:
      Free Software Foundation
      675 Mass Ave
      Cambridge, MA  02139
      USA

*******************************************************************************/
#ifndef LIBFLRE_H
#define LIBFLRE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdio.h>

#if defined(_WIN32) || defined(_WIN64)
  #define WINDOWS
#endif
#ifdef WINDOWS
  #define WIN32_LEAN_AND_MEAN
  #define _WINSOCK_DEPRECATED_NO_WARNINGS
  #include <windows.h>
#else
  #include <dlfcn.h>
  #include <sys/types.h>
#endif

#undef FLRE32
#undef FLRE64
#if defined(INTPTR_MAX) 
  #if INTPTR_MAX == INT32_MAX
    #define FLRE32 
   #elif INTPTR_MAX == INT64_MAX 
    #define FLRE64
  #else
    #error "32-bit or 64-bit target is needed!"
  #endif
#else
  #if _WIN32 || _WIN64
    #if _WIN64
      #define FLRE64
    #else
      #define FLRE32
    #endif
  #elif defined(__GNUC__)
    #if __x86_64__ || __ppc64__ || __aarch64__ || __aarch64
      #define FLRE64
    #else
      #define FLRE32
    #endif
  #else
    #error "32-bit or 64-bit target is needed!"
  #endif
#endif

typedef char TFLREChar;

typedef TFLREChar* PFLREChar;

#if defined(FLRE32)
typedef int32_t TFLRESizeInt;
#elif defined(FLRE64)
typedef int64_t TFLRESizeInt;
#endif

typedef TFLRESizeInt* PFLRESizeInt;

typedef const TFLREChar* PFLREConstChar;

typedef void* TFLREInstance;

#if defined(__GNUC__) && (defined(WIN32) || defined(_WIN32)) && (defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)) 
#define FLRE_CALLCONV __attribute__((stdcall))
#elif defined(_MSC_VER) && (defined(WIN32) || defined(_WIN32)) && (defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386))
#define FLRE_CALLCONV __stdcall
#else
// Just use the default target system call convention in this case  
#define FLRE_CALLCONV
#endif

static const uint32_t FLRE_carfIGNORECASE = 1u << 0;
static const uint32_t FLRE_carfSINGLELINE = 1u << 1;
static const uint32_t FLRE_carfMULTILINE = 1u << 2;
static const uint32_t FLRE_carfFREESPACING = 1u << 3;
static const uint32_t FLRE_carfNAMED = 1u << 4;
static const uint32_t FLRE_carfNOCAPTURES = 1u << 5;
static const uint32_t FLRE_carfUNGREEDY = 1u << 6;
static const uint32_t FLRE_carfLONGEST = 1u << 7;
static const uint32_t FLRE_carfMULTIMATCH = 1u << 8;
static const uint32_t FLRE_carfUTF8 = 1u << 9;
static const uint32_t FLRE_carfONLYFASTOPTIMIZATIONS = 1u << 10;
static const uint32_t FLRE_carfDELIMITERS = 1u << 11;
 
typedef FLRE_CALLCONV int32_t (*TFLREReplaceCallback)(const void* Data, const void* Input, const TFLRESizeInt InputLength, const void* Captures, const TFLRESizeInt CountCaptures, void** ReplacementString, TFLRESizeInt* ReplacementStringLength);

typedef FLRE_CALLCONV uint32_t (*_FLREGetVersion)();
typedef FLRE_CALLCONV PFLREChar (*_FLREGetVersionString)();
typedef FLRE_CALLCONV TFLREInstance (*_FLRECreate)(PFLREConstChar RegularExpression, TFLRESizeInt RegularExpressionLength, uint32_t Flags, PFLREChar* Error);
typedef FLRE_CALLCONV TFLREInstance (*_FLREDestroy)(TFLREInstance Instance);
typedef FLRE_CALLCONV void* (*_FLREAlloc)(const TFLRESizeInt Size);
typedef FLRE_CALLCONV void (*_FLREFree)(void* Data);
typedef FLRE_CALLCONV int32_t (*_FLREGetCountCaptures)(TFLREInstance Instance);
typedef FLRE_CALLCONV int32_t (*_FLREGetNamedGroupIndex)(TFLREInstance Instance, PFLREConstChar GroupName);
typedef FLRE_CALLCONV int32_t (*_FLREDumpRegularExpression)(TFLREInstance Instance, PFLREChar* RegularExpression, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREGetPrefilterExpression)(TFLREInstance Instance, PFLREChar* Expression, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREGetPrefilterShortExpression)(TFLREInstance Instance, PFLREChar* ShortExpression, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREGetPrefilterSQLBooleanFullTextExpression)(TFLREInstance Instance, PFLREChar* SQLBooleanFullTextExpression, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREGetPrefilterSQLExpression)(TFLREInstance Instance, PFLREConstChar field, PFLREChar* SQLExpression, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREGetRange)(TFLREInstance Instance, PFLREChar* LowRange, PFLREChar* HighRange, TFLRESizeInt* LowRangeLength, TFLRESizeInt* HighRangeLength, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREMatch)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, void** Captures, TFLRESizeInt MaxCaptures, TFLRESizeInt* CountCaptures, TFLRESizeInt StartPosition, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREMatchNext)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, void** Captures, TFLRESizeInt MaxCaptures, TFLRESizeInt* CountCaptures, TFLRESizeInt StartPosition, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREMatchAll)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, void** MultiCaptures, TFLRESizeInt MaxMultiCaptures, TFLRESizeInt* CountMultiCaptures, TFLRESizeInt* CountCaptures, TFLRESizeInt StartPosition, TFLRESizeInt Limit, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREReplaceAll)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, const void* Replacement, TFLRESizeInt ReplacementLength, void** ResultString, TFLRESizeInt* ResultStringLength, TFLRESizeInt StartPosition, TFLRESizeInt Limit, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREReplaceCallback)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, const void* CallbackData, const TFLREReplaceCallback Callback, void** ResultString, TFLRESizeInt* ResultStringLength, TFLRESizeInt StartPosition, TFLRESizeInt Limit, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLRESplit)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, void** SplittedStrings, TFLRESizeInt* CountSplittedStrings, TFLRESizeInt StartPosition, TFLRESizeInt Limit, int32_t WithEmpty, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLRETest)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, TFLRESizeInt StartPosition, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLRETestAll)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, TFLRESizeInt StartPosition, PFLREChar* Error);
typedef FLRE_CALLCONV int32_t (*_FLREFind)(TFLREInstance Instance, const void* Input, TFLRESizeInt InputLength, TFLRESizeInt StartPosition, PFLREChar* Error);

extern _FLREGetVersion FLREGetVersion;
extern _FLREGetVersionString FLREGetVersionString;
extern _FLRECreate FLRECreate;
extern _FLREDestroy FLREDestroy;
extern _FLREAlloc FLREAlloc;
extern _FLREFree FLREFree;
extern _FLREGetCountCaptures FLREGetCountCaptures;
extern _FLREGetNamedGroupIndex FLREGetNamedGroupIndex;
extern _FLREDumpRegularExpression FLREDumpRegularExpression;
extern _FLREGetPrefilterExpression FLREGetPrefilterExpression;
extern _FLREGetPrefilterShortExpression FLREGetPrefilterShortExpression;
extern _FLREGetPrefilterSQLBooleanFullTextExpression FLREGetPrefilterSQLBooleanFullTextExpression;
extern _FLREGetPrefilterSQLExpression FLREGetPrefilterSQLExpression;
extern _FLREGetRange FLREGetRange;
extern _FLREMatch FLREMatch;
extern _FLREMatchNext FLREMatchNext;
extern _FLREMatchAll FLREMatchAll;
extern _FLREReplaceAll FLREReplaceAll;
extern _FLREReplaceCallback FLREReplaceCallback;
extern _FLRESplit FLRESplit;
extern _FLRETest FLRETest;
extern _FLRETestAll FLRETestAll;
extern _FLREFind FLREFind;

extern int32_t FLRELoaded;

#ifdef WINDOWS
extern HINSTANCE FLRELibraryHandle;
#else
extern void* FLRELibraryHandle;
#endif

extern int32_t FLRELoad();
extern int32_t FLREUnload();

#ifdef LIBFLRE_IMPL
int32_t FLRELoaded = 0;

#ifdef WINDOWS
HINSTANCE FLRELibraryHandle = NULL;
#else
void* FLRELibraryHandle = NULL;
#endif

_FLREGetVersion FLREGetVersion = NULL;
_FLREGetVersionString FLREGetVersionString = NULL;
_FLRECreate FLRECreate = NULL;
_FLREDestroy FLREDestroy = NULL;
_FLREAlloc FLREAlloc = NULL;
_FLREFree FLREFree = NULL;
_FLREGetCountCaptures FLREGetCountCaptures = NULL;
_FLREGetNamedGroupIndex FLREGetNamedGroupIndex = NULL;
_FLREDumpRegularExpression FLREDumpRegularExpression = NULL;
_FLREGetPrefilterExpression FLREGetPrefilterExpression = NULL;
_FLREGetPrefilterShortExpression FLREGetPrefilterShortExpression = NULL;
_FLREGetPrefilterSQLBooleanFullTextExpression FLREGetPrefilterSQLBooleanFullTextExpression = NULL;
_FLREGetPrefilterSQLExpression FLREGetPrefilterSQLExpression = NULL;
_FLREGetRange FLREGetRange = NULL;
_FLREMatch FLREMatch = NULL;
_FLREMatchNext FLREMatchNext = NULL;
_FLREMatchAll FLREMatchAll = NULL;
_FLREReplaceAll FLREReplaceAll = NULL;
_FLREReplaceCallback FLREReplaceCallback = NULL;
_FLRESplit FLRESplit = NULL;
_FLRETest FLRETest = NULL;
_FLRETestAll FLRETestAll = NULL;
_FLREFind FLREFind = NULL;

int32_t FLRELoad(){
  if(FLRELoaded){
    return 1;
  }else{ 
#ifdef WINDOWS
  #if defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)
    FLRELibraryHandle = dlopen("libFLRE_i386.dll");
  #elif defined(__amd64) || defined(__amd64__) || defined(__x86_64) || defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
    FLRELibraryHandle = LoadLibrary("libFLRE_x86_64.dll");
  #elif defined(__aarch64) || defined(__aarch64__)
    FLRELibraryHandle = LoadLibrary("libFLRE_aarch64.dll");
  #elif defined(__arm__)
    FLRELibraryHandle = LoadLibrary("libFLRE_arm.dll");
  #else
    #error "Unsupported CPU/OS target combination"
  #endif
    if(FLRELibraryHandle == NULL){
      FLRELibraryHandle = LoadLibrary("libFLRE.dll");
    }
#else
#if defined(__ANDROID_API__)
  #if defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)
    FLRELibraryHandle = dlopen("libFLRE_android_i386.so");
  #elif defined(__amd64) || defined(__amd64__) || defined(__x86_64) || defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
    FLRELibraryHandle = dlopen("libFLRE_android_x86_64.so");
  #elif defined(__aarch64) || defined(__aarch64__)
    FLRELibraryHandle = dlopen("libFLRE_android_aarch64.so");
  #elif defined(__arm__)
    FLRELibraryHandle = dlopen("libFLRE_android_arm.so");
  #else
    #error "Unsupported CPU/OS target combination"
  #endif    
#elif defined(__APPLE__)
  #include "TargetConditionals.h"
  #if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
    #if defined(__aarch64) || defined(__aarch64__)  
    FLRELibraryHandle = dlopen("libFLRE_ios_aarch64.dylib");
    #elif defined(__arm__)
    FLRELibraryHandle = dlopen("libFLRE_ios_arm.dylib");
    #else
      #error "Unsupported CPU/OS target combination"
    #endif    
  #elif TARGET_OS_MAC
    #if defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)
    FLRELibraryHandle = dlopen("libFLRE_darwin_i386.dylib");
    #elif defined(__amd64) || defined(__amd64__) || defined(__x86_64) || defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
    FLRELibraryHandle = dlopen("libFLRE_darwin_x86_64.dylib");
    #elif defined(__aarch64) || defined(__aarch64__)  
    FLRELibraryHandle = dlopen("libFLRE_darwin_aarch64.dylib");
    #else
        #error "Unsupported CPU/OS target combination"
    #endif    
  #else
    #error "Unsupported CPU/OS target combination"
  #endif
#elif defined(__linux__) || defined(__linux) || defined(linux)
  #if defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)
    FLRELibraryHandle = dlopen("libFLRE_linux_i386.so");
  #elif defined(__amd64) || defined(__amd64__) || defined(__x86_64) || defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
    FLRELibraryHandle = dlopen("libFLRE_linux_x86_64.so");
  #elif defined(__aarch64) || defined(__aarch64__)
    FLRELibraryHandle = dlopen("libFLRE_linux_aarch64.so");
  #elif defined(__arm__)
    FLRELibraryHandle = dlopen("libFLRE_linux_arm.so");
  #else
    #error "Unsupported CPU/OS target combination"
  #endif    
#elif defined(__FreeBSD__)
  #if defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(_M_IX86) || defined(__X86__) || defined(_X86_) || defined(__386)
    FLRELibraryHandle = dlopen("libFLRE_freebsd_i386.so");
  #elif defined(__amd64) || defined(__amd64__) || defined(__x86_64) || defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
    FLRELibraryHandle = dlopen("libFLRE_freebsd_x86_64.so");
  #else
    #error "Unsupported CPU/OS target combination"
  #endif    
#elif defined(__unix__) || defined(__unix) || defined(unix)
  #warning "Non-offical supported CPU/OS target combination (*BSD etc.)"
#else
  #error "Unsupported CPU/OS target combination"
#endif    
    if(FLRELibraryHandle == NULL){
      FLRELibraryHandle = dlopen("libFLRE.so");
    }
#endif          
    if(FLRELibraryHandle != NULL){
#ifdef WINDOWS
#define FLREGetProcAddress GetProcAddress
#else
#define FLREGetProcAddress dlsym
#endif
      FLREGetVersion = (_FLREGetVersion)FLREGetProcAddress(FLRELibraryHandle, "FLREGetVersion");
      FLREGetVersionString = (_FLREGetVersionString)FLREGetProcAddress(FLRELibraryHandle, "FLREGetVersionString");
      FLRECreate = (_FLRECreate)FLREGetProcAddress(FLRELibraryHandle, "FLRECreate");
      FLREDestroy = (_FLREDestroy)FLREGetProcAddress(FLRELibraryHandle, "FLREDestroy");
      FLREAlloc = (_FLREAlloc)FLREGetProcAddress(FLRELibraryHandle, "FLREAlloc");
      FLREFree = (_FLREFree)FLREGetProcAddress(FLRELibraryHandle, "FLREFree");
      FLREGetCountCaptures = (_FLREGetCountCaptures)FLREGetProcAddress(FLRELibraryHandle, "FLREGetCountCaptures");
      FLREGetNamedGroupIndex = (_FLREGetNamedGroupIndex)FLREGetProcAddress(FLRELibraryHandle, "FLREGetNamedGroupIndex");
      FLREDumpRegularExpression = (_FLREDumpRegularExpression)FLREGetProcAddress(FLRELibraryHandle, "FLREDumpRegularExpression");
      FLREGetPrefilterExpression = (_FLREGetPrefilterExpression)FLREGetProcAddress(FLRELibraryHandle, "FLREGetPrefilterExpression");
      FLREGetPrefilterShortExpression = (_FLREGetPrefilterShortExpression)FLREGetProcAddress(FLRELibraryHandle, "FLREGetPrefilterShortExpression");
      FLREGetPrefilterSQLBooleanFullTextExpression = (_FLREGetPrefilterSQLBooleanFullTextExpression)FLREGetProcAddress(FLRELibraryHandle, "FLREGetPrefilterSQLBooleanFullTextExpression");
      FLREGetPrefilterSQLExpression = (_FLREGetPrefilterSQLExpression)FLREGetProcAddress(FLRELibraryHandle, "FLREGetPrefilterSQLExpression");
      FLREGetRange = (_FLREGetRange)FLREGetProcAddress(FLRELibraryHandle, "FLREGetRange");
      FLREMatch = (_FLREMatch)FLREGetProcAddress(FLRELibraryHandle, "FLREMatch");
      FLREMatchNext = (_FLREMatchNext)FLREGetProcAddress(FLRELibraryHandle, "FLREMatchNext");
      FLREMatchAll = (_FLREMatchAll)FLREGetProcAddress(FLRELibraryHandle, "FLREMatchAll");
      FLREReplaceAll = (_FLREReplaceAll)FLREGetProcAddress(FLRELibraryHandle, "FLREReplaceAll");
      FLREReplaceCallback = (_FLREReplaceCallback)FLREGetProcAddress(FLRELibraryHandle, "FLREReplaceCallback");
      FLRESplit = (_FLRESplit)FLREGetProcAddress(FLRELibraryHandle, "FLRESplit");
      FLRETest = (_FLRETest)FLREGetProcAddress(FLRELibraryHandle, "FLRETest");
      FLRETestAll = (_FLRETestAll)FLREGetProcAddress(FLRELibraryHandle, "FLRETestAll");
      FLREFind = (_FLREFind)FLREGetProcAddress(FLRELibraryHandle, "FLREFind");
#undef FLREGetProcAddress
      if(FLREGetVersion &&
         FLREGetVersionString &&
         FLRECreate &&
         FLREDestroy &&
         FLREAlloc &&
         FLREFree &&
         FLREGetCountCaptures &&
         FLREGetNamedGroupIndex &&
         FLREDumpRegularExpression &&
         FLREGetPrefilterExpression &&
         FLREGetPrefilterShortExpression &&
         FLREGetPrefilterSQLBooleanFullTextExpression &&
         FLREGetPrefilterSQLExpression &&
         FLREGetRange &&
         FLREMatch &&
         FLREMatchNext &&
         FLREMatchAll &&
         FLREReplaceAll &&
         FLREReplaceCallback &&
         FLRESplit &&
         FLRETest &&
         FLRETestAll &&
         FLREFind){
        FLRELoaded = 1;
        return 1;
      }     
    }
    return 0;
  } 
}

int32_t FLREUnload(){
  if(FLRELoaded){
#ifdef WINDOWS
    FreeLibrary(FLRELibraryHandle);
#else
    dlclose(FLRELibraryHandle);
#endif    
    FLRELoaded = 0;
  }
  return 0;
}

#endif

#ifdef __cplusplus
}

#include <string>
#include <vector>
#include <exception>
#include <stdexcept>
#include <functional>

class TFLRE {
private: 

  class AutoDeleteFLRECharString {
  private:
  public:
      PFLREChar stringPointer = NULL;
      explicit AutoDeleteFLRECharString(PFLREChar s = NULL): stringPointer(s){}
      ~AutoDeleteFLRECharString(){ if(stringPointer){ FLREFree(stringPointer); stringPointer = NULL; } }
      std::string getString(){ return std::string(stringPointer); }
  };
   
  template<typename T> 
  class AutoDelete {
  private:
  public:
      T pointer = NULL;
      explicit AutoDelete(T p = NULL): pointer(p){}
      ~AutoDelete(){ if(pointer){ FLREFree(pointer); pointer = NULL; } }
  };
  
public:

  class TError : public std::runtime_error {
  public:
      TError(const std::string& what = "") : std::runtime_error(what) {}
  };

  typedef struct TCapture {
    TFLRESizeInt start;
    TFLRESizeInt length;
  } TCapture;

  typedef TCapture* PCapture;

  using TCaptures = std::vector<TCapture>;

  using TMultiCaptures = std::vector<TCaptures>;

  using TReplacementCallback = std::function<bool(void* /*Data*/, const void* /*Input*/, const TFLRESizeInt /*InputLength*/, const TCaptures& /*Captures*/, std::string& /*ReplacementString*/)>;

  TFLREInstance m_instance = NULL;

  TFLRE(const std::string &regularExpression = "", uint32_t flags = FLRE_carfDELIMITERS);
   
  virtual ~TFLRE();

  int32_t getCountCaptures();

  int32_t getNamedGroupIndex(const std::string& groupName);

  std::string dumpRegularExpression();

  std::string getPrefilterExpression();

  std::string getPrefilterShortExpression();

  std::string getPrefilterSQLBooleanFullTextExpression();

  std::string getPrefilterSQLExpression(const std::string &field);

  bool getRange(std::string &lowRange, std::string &highRange);

  bool match(const void* input, const TFLRESizeInt inputLength, TCaptures& captures, const TFLRESizeInt startPosition = 0/*, const TFLRESizeInt maxCaptures = -1*/);

  bool match(const std::string& input, TCaptures& captures, const TFLRESizeInt startPosition = 0/*, const TFLRESizeInt maxCaptures = -1*/);

  bool matchNext(const void* input, const TFLRESizeInt inputLength, TCaptures& captures, const TFLRESizeInt startPosition = 0/*, const TFLRESizeInt maxCaptures = -1*/);

  bool matchNext(const std::string& input, TCaptures& captures, const TFLRESizeInt startPosition = 0/*, const TFLRESizeInt maxCaptures = -1*/);

  bool matchAll(const void* input, const TFLRESizeInt inputLength, TMultiCaptures& multiCaptures, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1/*, const TFLRESizeInt maxMultiCaptures = -1*/);

  bool matchAll(const std::string& input, TMultiCaptures& multiCaptures, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1/*, const TFLRESizeInt maxMultiCaptures = -1*/);

  bool replaceAll(const void* input, const TFLRESizeInt inputLength, const std::string& replacement, std::string& result, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1);

  bool replaceAll(const std::string& input, const std::string& replacement, std::string& result, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1);

  bool replaceCallback(const void* input, const TFLRESizeInt inputLength, void* replacementCallbackData, const TReplacementCallback& replacementCallback, std::string& result, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1);

  bool replaceCallback(const std::string& input, void* replacementCallbackData, const TReplacementCallback& replacementCallback, std::string& result, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1);

  bool split(const void* input, const TFLRESizeInt inputLength, std::vector<std::string>& splittedStrings, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1, const bool withEmpty = true);

  bool split(const std::string& input, std::vector<std::string>& splittedStrings, const TFLRESizeInt startPosition = 0, const TFLRESizeInt limit = -1, const bool withEmpty = true);

  bool test(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition = 0);

  bool test(const std::string& input, const TFLRESizeInt startPosition = 0);

  bool testAll(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition = 0);

  bool testAll(const std::string& input, const TFLRESizeInt startPosition = 0);

  TFLRESizeInt find(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition = 0);

  TFLRESizeInt find(const std::string& input, const TFLRESizeInt startPosition = 0);

};

#ifdef LIBFLRE_IMPL
TFLRE::TFLRE(const std::string &regularExpression, uint32_t flags){
  AutoDeleteFLRECharString error(NULL);
  m_instance = FLRECreate(regularExpression.c_str(), regularExpression.size(), flags, &error.stringPointer);
  if(error.stringPointer){
    throw new TFLRE::TError(error.getString());
  }
}
  
TFLRE::~TFLRE(){
  if(m_instance){
    FLREDestroy(m_instance);
    m_instance = NULL;
  }
}

int32_t TFLRE::getCountCaptures(){
  return FLREGetCountCaptures(m_instance);
}

int32_t TFLRE::getNamedGroupIndex(const std::string& groupName){
  return FLREGetNamedGroupIndex(m_instance, groupName.c_str());
}

std::string TFLRE::dumpRegularExpression(){
  AutoDeleteFLRECharString regularExpression(NULL);
  AutoDeleteFLRECharString error(NULL);
  if(FLREDumpRegularExpression(m_instance, &regularExpression.stringPointer, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return regularExpression.getString();
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return "";
  }
}

std::string TFLRE::getPrefilterExpression(){
  AutoDeleteFLRECharString expression(NULL);
  AutoDeleteFLRECharString error(NULL);
  if(FLREGetPrefilterExpression(m_instance, &expression.stringPointer, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return expression.getString();
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return "";
  }
}

std::string TFLRE::getPrefilterShortExpression(){
  AutoDeleteFLRECharString shortExpression(NULL);
  AutoDeleteFLRECharString error(NULL);
  if(FLREGetPrefilterShortExpression(m_instance, &shortExpression.stringPointer, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return shortExpression.getString();
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return "";
  }
}

std::string TFLRE::getPrefilterSQLBooleanFullTextExpression(){
  AutoDeleteFLRECharString SQLBooleanFullTextExpression(NULL);
  AutoDeleteFLRECharString error(NULL);
  if(FLREGetPrefilterSQLBooleanFullTextExpression(m_instance, &SQLBooleanFullTextExpression.stringPointer, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return SQLBooleanFullTextExpression.getString();
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return "";
  }
}

std::string TFLRE::getPrefilterSQLExpression(const std::string &field){
  AutoDeleteFLRECharString SQLExpression(NULL);
  AutoDeleteFLRECharString error(NULL);
  if(FLREGetPrefilterSQLExpression(m_instance, field.c_str(), &SQLExpression.stringPointer, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return SQLExpression.getString();
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return "";
  }
}

bool TFLRE::getRange(std::string &lowRange, std::string &highRange){
  AutoDeleteFLRECharString lowRange_(NULL);
  AutoDeleteFLRECharString highRange_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt lowRangeLength = 0;
  TFLRESizeInt highRangeLength = 0;
  if(FLREGetRange(m_instance, &lowRange_.stringPointer, &highRange_.stringPointer, &lowRangeLength, &highRangeLength, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    lowRange = (lowRangeLength > 0) ? std::string(lowRange_.stringPointer, lowRangeLength) : "";
    highRange = (highRangeLength > 0) ? std::string(highRange_.stringPointer, highRangeLength) : "";
    return true;
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return false;
  }
}

bool TFLRE::match(const void* input, const TFLRESizeInt inputLength, TCaptures& captures, const TFLRESizeInt startPosition /*, const TFLRESizeInt maxCaptures*/){
  AutoDelete<void*> captures_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt countCaptures = 0; 
  if(FLREMatch(m_instance, (void*)input, inputLength, (void**)&captures_.pointer, /*maxCaptures*/-1, &countCaptures, startPosition, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    if(countCaptures > 0){
      captures.resize(countCaptures);
      for(TFLRESizeInt index = 0; index < countCaptures; index++){
        TCapture &capture = captures.at(index);
        capture.start = ((TFLRESizeInt*)captures_.pointer)[(index << 1) | 0];
        capture.length = ((TFLRESizeInt*)captures_.pointer)[(index << 1) | 1];
      }
    }else{
      captures.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    captures.clear();
    return false; 
  }
}

bool TFLRE::match(const std::string& input, TCaptures& captures, const TFLRESizeInt startPosition/*, const TFLRESizeInt maxCaptures*/){
  return match(input.c_str(), input.size(), captures, startPosition/*, maxCaptures*/);
}

bool TFLRE::matchNext(const void* input, const TFLRESizeInt inputLength, TCaptures& captures, const TFLRESizeInt startPosition/*, const TFLRESizeInt maxCaptures*/){
  AutoDelete<void*> captures_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt countCaptures = 0;
  if(FLREMatchNext(m_instance, (void*)input, inputLength, (void**)&captures_.pointer, /*maxCaptures*/-1, &countCaptures, startPosition, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    if(countCaptures > 0){
      captures.resize(countCaptures);
      for(TFLRESizeInt index = 0; index < countCaptures; index++){
        TCapture &capture = captures.at(index);
        capture.start = ((TFLRESizeInt*)captures_.pointer)[(index << 1) | 0];
        capture.length = ((TFLRESizeInt*)captures_.pointer)[(index << 1) | 1];
      }
    }else{
      captures.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    captures.clear();
    return false; 
  }
}

bool TFLRE::matchNext(const std::string& input, TCaptures& captures, const TFLRESizeInt startPosition/*, const TFLRESizeInt maxCaptures*/){
  return matchNext(input.c_str(), input.size(), captures, startPosition/*, maxCaptures*/);
}

bool TFLRE::matchAll(const void* input, const TFLRESizeInt inputLength, TMultiCaptures& multiCaptures, const TFLRESizeInt startPosition, const TFLRESizeInt limit/*, const TFLRESizeInt maxMultiCaptures*/){
  AutoDelete<void*> multiCaptures_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt countMultiCaptures = 0;
  TFLRESizeInt countCaptures = 0;
  if(FLREMatchAll(m_instance, (void*)input, inputLength, (void**)&multiCaptures_.pointer, /*maxMultiCaptures*/-1, &countMultiCaptures, &countCaptures, startPosition, limit, &error.stringPointer)){
    if(error.stringPointer){
      throw new std::runtime_error(error.getString());    
    }
    if((countMultiCaptures > 0) && (countCaptures > 0)){
      multiCaptures.resize(countMultiCaptures);
      for(TFLRESizeInt index = 0; index < countMultiCaptures; index++){
        TCaptures &captures = multiCaptures.at(index);
        captures.resize(countCaptures);
        for(TFLRESizeInt otherIndex = 0; otherIndex < countCaptures; otherIndex++){
          TCapture &capture = captures.at(otherIndex);
          int32_t endIndex = (index * countCaptures) + otherIndex;
          capture.start = ((TFLRESizeInt*)multiCaptures_.pointer)[(endIndex << 1) | 0];
          capture.length = ((TFLRESizeInt*)multiCaptures_.pointer)[(endIndex << 1) | 1];
        }
      }
    }else{
      multiCaptures.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new std::runtime_error(error.getString());    
    }
    multiCaptures.clear();
    return false; 
  }
}

bool TFLRE::matchAll(const std::string& input, TMultiCaptures& multiCaptures, const TFLRESizeInt startPosition, const TFLRESizeInt limit/*, const TFLRESizeInt maxMultiCaptures*/){
  return matchAll(input.c_str(), input.size(), multiCaptures, startPosition, limit/*, maxCaptures*/);
}

bool TFLRE::replaceAll(const void* input, const TFLRESizeInt inputLength, const std::string& replacement, std::string& result, const TFLRESizeInt startPosition, const TFLRESizeInt limit){
  AutoDeleteFLRECharString result_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt resultLength = 0;
  if(FLREReplaceAll(m_instance, (void*)input, inputLength, replacement.c_str(), replacement.size(), (void**)&result_.stringPointer, &resultLength, startPosition, limit, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    if(resultLength > 0){
      result.assign(result_.stringPointer, resultLength);
    }else{
      result.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    result.clear();
    return false; 
  }
}

bool TFLRE::replaceAll(const std::string& input, const std::string& replacement, std::string& result, const TFLRESizeInt startPosition, const TFLRESizeInt limit){
  return replaceAll(input.c_str(), input.size(), replacement, result, startPosition, limit);
}

typedef struct TFLRE_replaceCallbackHandlerData {
  void* replacementCallbackData;
  const TFLRE::TReplacementCallback *replacementCallback;
  TFLRE::TCaptures captures;
} TFLRE_replaceCallbackHandlerData;

int32_t TFLRE_replaceCallbackHandler(const void* Data, const void* Input, const TFLRESizeInt InputLength, const void* Captures, const TFLRESizeInt CountCaptures, void** ReplacementString, TFLRESizeInt* ReplacementStringLength){
  if(CountCaptures > 0){
    TFLRE_replaceCallbackHandlerData* replaceCallbackHandlerData = (TFLRE_replaceCallbackHandlerData*)Data;
    if(replaceCallbackHandlerData->replacementCallback){
      if(replaceCallbackHandlerData->captures.size() != CountCaptures){
        replaceCallbackHandlerData->captures.resize(CountCaptures);
      }
      for(TFLRESizeInt index = 0; index < CountCaptures; index++){
        TFLRE::TCapture &capture = replaceCallbackHandlerData->captures.at(index);
        capture.start = ((TFLRESizeInt*)Captures)[(index << 1) | 0];
        capture.length = ((TFLRESizeInt*)Captures)[(index << 1) | 1];
      }
      std::string replacementString = "";
      if((*(replaceCallbackHandlerData->replacementCallback))(replaceCallbackHandlerData->replacementCallbackData, Input, InputLength, replaceCallbackHandlerData->captures, replacementString)){
        *ReplacementString = FLREAlloc(replacementString.size() + 1);
        memcpy(*ReplacementString, replacementString.c_str(), replacementString.size() + 1);
        *ReplacementStringLength = replacementString.size();
        return 1;
      }
    }
  }  
  return 0;
}

bool TFLRE::replaceCallback(const void* input, const TFLRESizeInt inputLength, void* replacementCallbackData, const TReplacementCallback& replacementCallback, std::string& result, const TFLRESizeInt startPosition, const TFLRESizeInt limit){
  AutoDeleteFLRECharString result_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt resultLength = 0;
  TFLRE_replaceCallbackHandlerData replaceCallbackHandlerData;
  replaceCallbackHandlerData.replacementCallbackData = replacementCallbackData;  
  replaceCallbackHandlerData.replacementCallback = &replacementCallback;    
  if(FLREReplaceCallback(m_instance, (void*)input, inputLength, &replaceCallbackHandlerData, &TFLRE_replaceCallbackHandler, (void**)&result_.stringPointer, &resultLength, startPosition, limit, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    if(resultLength > 0){
      result.assign(result_.stringPointer, resultLength);
    }else{
      result.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    result.clear();
    return false; 
  }
}

bool TFLRE::replaceCallback(const std::string& input, void* replacementCallbackData, const TReplacementCallback& replacementCallback, std::string& result, const TFLRESizeInt startPosition, const TFLRESizeInt limit){
  return replaceCallback(input.c_str(), input.size(), replacementCallbackData,replacementCallback, result, startPosition, limit);
}

bool TFLRE::split(const void* input, const TFLRESizeInt inputLength, std::vector<std::string>& splittedStrings, const TFLRESizeInt startPosition, const TFLRESizeInt limit, const bool withEmpty){
  AutoDelete<void*> splittedStrings_(NULL);
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt countSplittedStrings = 0;
  if(FLRESplit(m_instance, (void*)input, inputLength, &splittedStrings_.pointer, &countSplittedStrings, startPosition, limit, withEmpty ? 1 : 0, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    if(splittedStrings_.pointer && (countSplittedStrings > 0)){      
      splittedStrings.resize(countSplittedStrings);
      uint8_t* p = (uint8_t*)splittedStrings_.pointer;
      for(TFLRESizeInt index = 0; index < countSplittedStrings; index++){
        std::string &splittedString = splittedStrings.at(index);
        TFLRESizeInt stringLength = *((TFLRESizeInt*)p);
        p += sizeof(TFLRESizeInt);
        if(stringLength > 0){
          splittedString.assign((char*)p, stringLength);
        }else{
          splittedString.clear();
        }
        p += stringLength + 1;        
      }
    }else{
      splittedStrings.clear();
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    splittedStrings.clear();
    return false; 
  }
}

bool TFLRE::split(const std::string& input, std::vector<std::string>& splittedStrings, const TFLRESizeInt startPosition, const TFLRESizeInt limit, const bool withEmpty){
  return split(input.c_str(), input.size(), splittedStrings, startPosition, limit, withEmpty);
}

bool TFLRE::test(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition){
  AutoDeleteFLRECharString error(NULL);
  if(FLRETest(m_instance, (void*)input, inputLength, startPosition, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return false; 
  }
}

bool TFLRE::test(const std::string& input, const TFLRESizeInt startPosition){
  return test(input.c_str(), input.size(), startPosition);
}

bool TFLRE::testAll(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition){
  AutoDeleteFLRECharString error(NULL);
  if(FLRETestAll(m_instance, (void*)input, inputLength, startPosition, &error.stringPointer)){
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return true; 
  }else{
    if(error.stringPointer){
      throw new TFLRE::TError(error.getString());    
    }
    return false; 
  }
}

bool TFLRE::testAll(const std::string& input, const TFLRESizeInt startPosition){
  return testAll(input.c_str(), input.size(), startPosition);
}

TFLRESizeInt TFLRE::find(const void* input, const TFLRESizeInt inputLength, const TFLRESizeInt startPosition){
  AutoDeleteFLRECharString error(NULL);
  TFLRESizeInt result = FLREFind(m_instance, (void*)input, inputLength, startPosition, &error.stringPointer);
  if(error.stringPointer){
    throw new TFLRE::TError(error.getString());    
  }
  return result; 
}

TFLRESizeInt TFLRE::find(const std::string& input, const TFLRESizeInt startPosition){
  return find(input.c_str(), input.size(), startPosition);
}

#endif

#endif

#endif

