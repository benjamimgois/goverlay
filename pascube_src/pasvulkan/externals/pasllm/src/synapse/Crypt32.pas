{==============================================================================|
| Project : Ararat Synapse                                       | 001.000.000 |
|==============================================================================|
| Content: minimal support for crypt32 windows API                             |
|==============================================================================|
| Copyright (c)2018, Pepak                                                     |
| All rights reserved.                                                         |
|                                                                              |
| Redistribution and use in source and binary forms, with or without           |
| modification, are permitted provided that the following conditions are met:  |
|                                                                              |
| Redistributions of source code must retain the above copyright notice, this  |
| list of conditions and the following disclaimer.                             |
|                                                                              |
| Redistributions in binary form must reproduce the above copyright notice,    |
| this list of conditions and the following disclaimer in the documentation    |
| and/or other materials provided with the distribution.                       |
|                                                                              |
| Neither the name of Lukas Gebauer nor the names of its contributors may      |
| be used to endorse or promote products derived from this software without    |
| specific prior written permission.                                           |
|                                                                              |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  |
| AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    |
| IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   |
| ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  |
| ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       |
| DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   |
| SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   |
| CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           |
| LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    |
| OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  |
| DAMAGE.                                                                      |
|==============================================================================|
| The Initial Developer of the Original Code is Pepak (Czech Republic).        |
| Portions created by Pepak are Copyright (c)2018.                             |
| All Rights Reserved.                                                         |
|==============================================================================|
| Contributor(s):                                                              |
|==============================================================================|
| History: see HISTORY.HTM from distribution package                           |
|          (Found at URL: http://www.ararat.cz/synapse/)                       |
|==============================================================================}

unit Crypt32;
// Pozor, tohle je naprosto minimalni mnozina toho, co Crypt32.dll nabizi.
// Prevedl jsem jen to, co jsem potreboval.

interface

uses
  Windows;

const
  AdvapiLib = 'advapi32.dll';
  CryptoLib = 'crypt32.dll';
  CryptDlgLib = 'cryptdlg.dll';

type
  HCERTSTORE = THandle;
  HCRYPTPROV = THandle;
  HCRYPTKEY = THandle;
  PCRYPT_DATA_BLOB = ^CRYPT_DATA_BLOB;
  CRYPT_DATA_BLOB = record
    cbData: DWORD;
    pbData: PByte;
    end;

const
  CRYPT_EXPORTABLE = $00000001;
  CRYPT_USER_PROTECTED = $00000002;
  CRYPT_MACHINE_KEYSET = $00000020;
  CRYPT_USER_KEYSET = $00001000;

const
  PKCS12_PREFER_CNG_KSP = $00000100;
  PKCS12_ALWAYS_CNG_KSP = $00000200;
  PKCS12_ALLOW_OVERWRITE_KEY = $00004000;
  PKCS12_NO_PERSIST_KEY = $00008000;
  PKCS12_INCLUDE_EXTENDED_PROPERTIES = $0010;

type
  CRYPT_ALGORITHM_IDENTIFIER = record
    pszObjId: PAnsiChar;
    Parameters: CRYPT_DATA_BLOB;
    end;
  CERT_PUBLIC_KEY_INFO = record
    Algorithm: CRYPT_ALGORITHM_IDENTIFIER;
    PublicKey: CRYPT_DATA_BLOB;
    end;
  PCERT_EXTENSION = ^CERT_EXTENSION;
  CERT_EXTENSION = record
    pszObjId: PAnsiChar;
    bCritical: BOOL;
    Value: CRYPT_DATA_BLOB;
    end;
  PCERT_INFO = ^CERT_INFO;
  CERT_INFO = record
    dwVersion: DWORD;
    SerialNumber: CRYPT_DATA_BLOB;
    SignatureAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    Issuer: CRYPT_DATA_BLOB;
    NotBefore: FILETIME;
    NotAfter: FILETIME;
    Subject: CRYPT_DATA_BLOB;
    SubjectPublicKeyInfo: CERT_PUBLIC_KEY_INFO;
    IssuerUniqueId: CRYPT_DATA_BLOB;
    SubjectUniqueId: CRYPT_DATA_BLOB;
    cExtension: DWORD;
    rgExtension: PCERT_EXTENSION;
    end;
  PPCCERT_CONTEXT = ^PCCERT_CONTEXT;
  PCCERT_CONTEXT = ^CERT_CONTEXT;
  CERT_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: PByte;
    cbCertEncoded: DWORD;
    pCertInfo: PCERT_INFO;
    hCertStore: HCERTSTORE;
    end;
  PCRYPT_KEY_PROV_PARAM = ^CRYPT_KEY_PROV_PARAM;
  CRYPT_KEY_PROV_PARAM = record
    dwParam: DWORD;
    pbData: PByte;
    cbData: DWORD;
    dwFlags: DWORD;
  end;
  PCRYPT_KEY_PROV_INFO = ^CRYPT_KEY_PROV_INFO;
  CRYPT_KEY_PROV_INFO = record
    pwszContainerName: PWideChar;
    pwszProvName: PWideChar;
    dwProvType: DWORD;
    dwFlags: DWORD;
    cProvParam: DWORD;
    rgProvParam: PCRYPT_KEY_PROV_PARAM;
    dwKeySpec: DWORD;
    __dummy: array[0..65535] of byte;
  end;
  PCRYPT_HASH_BLOB = ^CRYPT_HASH_BLOB;
  CRYPT_HASH_BLOB = record
    cbData: DWORD;
    pbData: Pointer;
  end;
  PCRL_ENTRY = ^CRL_ENTRY;
  CRL_ENTRY = record
    SerialNumber: CRYPT_DATA_BLOB;
    RevocationDate: FILETIME;
    cExtension: DWORD;
    rgExtension: PCERT_EXTENSION;
  end;
  PCRL_INFO = ^CRL_INFO;
  CRL_INFO = record
    dwVersion: DWORD;
    SignatureAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    Issuer: CRYPT_DATA_BLOB;
    ThisUpdate: FILETIME;
    NextUpdate: FILETIME;
    cCRLEntry: DWORD;
    rgCRLEntry: PCRL_ENTRY;
    cExtension: DWORD;
    rgExtension: PCERT_EXTENSION;
  end;
  PCCRL_CONTEXT = ^CRL_CONTEXT;
  CRL_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCrlEncoded: Pointer;
    cbCrlEncoded: DWORD;
    pCrlInfo: PCRL_INFO;
    hCertStore: HCERTSTORE;
  end;
  PCRYPT_ATTRIBUTE = ^CRYPT_ATTRIBUTE;
  CRYPT_ATTRIBUTE = record
    pszObjId: LPSTR;
    cValue: DWORD;
    rgValue: PCRYPT_DATA_BLOB;
  end;
  PCRYPT_SIGN_MESSAGE_PARA = ^CRYPT_SIGN_MESSAGE_PARA;
  CRYPT_SIGN_MESSAGE_PARA = record
    cbSize: DWORD;
    dwMsgEncodingType: DWORD;
    pSigningCert: PCCERT_CONTEXT;
    HashAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    pvHashAuxInfo: Pointer;
    cMsgCert: DWORD;
    rgpMsgCert: PCCERT_CONTEXT;
    cMsgCrl: DWORD;
    rgpMsgCrl: PCCRL_CONTEXT;
    cAuthAttr: DWORD;
    rgAuthAttr: PCRYPT_ATTRIBUTE;
    cUnauthAttr: DWORD;
    rgUnauthAttr: PCRYPT_ATTRIBUTE;
    dwFlags: DWORD;
    dwInnerContentType: DWORD;
    HashEncryptionAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    pvHashEncryptionAuxInfo: Pointer;
  end;
  PPtrArray = ^TPtrArray;
  TPtrArray = array[0..32767] of Pointer;
  PDWORDArray = ^TDWORDArray;
  TDWORDArray = array[0..32767] of DWORD;

const
  CERT_STORE_PROV_MSG = LPCSTR(1);
  CERT_STORE_PROV_MEMORY = LPCSTR(2);
  CERT_STORE_PROV_FILE = LPCSTR(3);
  CERT_STORE_PROV_REG = LPCSTR(4);
  CERT_STORE_PROV_PKCS7 = LPCSTR(5);
  CERT_STORE_PROV_SERIALIZED = LPCSTR(6);
  CERT_STORE_PROV_FILENAME_A = LPCSTR(7);
  CERT_STORE_PROV_FILENAME_W = LPCSTR(8);
  CERT_STORE_PROV_FILENAME = CERT_STORE_PROV_FILENAME_W;
  CERT_STORE_PROV_SYSTEM_A = LPCSTR(9);
  CERT_STORE_PROV_SYSTEM_W = LPCSTR(10);
  CERT_STORE_PROV_SYSTEM = CERT_STORE_PROV_SYSTEM_W;
  CERT_STORE_PROV_COLLECTION = LPCSTR(11);
  CERT_STORE_PROV_SYSTEM_REGISTRY_A = LPCSTR(12);
  CERT_STORE_PROV_SYSTEM_REGISTRY_W = LPCSTR(13);
  CERT_STORE_PROV_SYSTEM_REGISTRY = CERT_STORE_PROV_SYSTEM_REGISTRY_W;
  CERT_STORE_PROV_PHYSICAL_W = LPCSTR(14);
  CERT_STORE_PROV_PHYSICAL = CERT_STORE_PROV_PHYSICAL_W;
  CERT_STORE_PROV_SMART_CARD_W = LPCSTR(15);
  CERT_STORE_PROV_SMART_CARD = CERT_STORE_PROV_SMART_CARD_W;
  CERT_STORE_PROV_LDAP_W = LPCSTR(16);
  CERT_STORE_PROV_LDAP = CERT_STORE_PROV_LDAP_W;
  sz_CERT_STORE_PROV_MEMORY = 'Memory';
  sz_CERT_STORE_PROV_FILENAME_W = 'File';
  sz_CERT_STORE_PROV_FILENAME = sz_CERT_STORE_PROV_FILENAME_W;
  sz_CERT_STORE_PROV_SYSTEM_W = 'System';
  sz_CERT_STORE_PROV_SYSTEM = sz_CERT_STORE_PROV_SYSTEM_W;
  sz_CERT_STORE_PROV_PKCS7 = 'PKCS7';
  sz_CERT_STORE_PROV_SERIALIZED = 'Serialized';
  sz_CERT_STORE_PROV_COLLECTION = 'Collection';
  sz_CERT_STORE_PROV_SYSTEM_REGISTRY_W = 'SystemRegistry';
  sz_CERT_STORE_PROV_SYSTEM_REGISTRY = sz_CERT_STORE_PROV_SYSTEM_REGISTRY_W;
  sz_CERT_STORE_PROV_PHYSICAL_W = 'Physical';
  sz_CERT_STORE_PROV_PHYSICAL = sz_CERT_STORE_PROV_PHYSICAL_W;
  sz_CERT_STORE_PROV_SMART_CARD_W = 'SmartCard';
  sz_CERT_STORE_PROV_SMART_CARD = sz_CERT_STORE_PROV_SMART_CARD_W;
  sz_CERT_STORE_PROV_LDAP_W = 'Ldap';
  sz_CERT_STORE_PROV_LDAP = sz_CERT_STORE_PROV_LDAP_W;

const
  X509_ASN_ENCODING = 1;
  PKCS_7_ASN_ENCODING = 65536;

const
  CERT_SYSTEM_STORE_UNPROTECTED_FLAG = $40000000;
  CERT_SYSTEM_STORE_LOCATION_MASK = $ff0000;
  CERT_SYSTEM_STORE_LOCATION_SHIFT = 16;
  CERT_SYSTEM_STORE_CURRENT_USER_ID = 1;
  CERT_SYSTEM_STORE_LOCAL_MACHINE_ID = 2;
  CERT_SYSTEM_STORE_CURRENT_SERVICE_ID = 4;
  CERT_SYSTEM_STORE_SERVICES_ID = 5;
  CERT_SYSTEM_STORE_USERS_ID = 6;
  CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY_ID = 7;
  CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY_ID = 8;
  CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE_ID = 9;
  CERT_SYSTEM_STORE_CURRENT_USER = (CERT_SYSTEM_STORE_CURRENT_USER_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_LOCAL_MACHINE = (CERT_SYSTEM_STORE_LOCAL_MACHINE_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_CURRENT_SERVICE = (CERT_SYSTEM_STORE_CURRENT_SERVICE_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_SERVICES = (CERT_SYSTEM_STORE_SERVICES_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_USERS = (CERT_SYSTEM_STORE_USERS_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY = (CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY = (CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE = (CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE_ID shl CERT_SYSTEM_STORE_LOCATION_SHIFT);
  CERT_STORE_READONLY_FLAG = $8000;

const
  CERT_FIND_ANY = 0;
  CERT_FIND_CERT_ID = 1048576;
  CERT_FIND_CTL_USAGE = 655360;
  CERT_FIND_ENHKEY_USAGE = 655360;
  CERT_FIND_EXISTING = 851968;
  CERT_FIND_HASH = 65536;
  CERT_FIND_ISSUER_ATTR = 196612;
  CERT_FIND_ISSUER_NAME = 131076;
  CERT_FIND_ISSUER_OF = 786432;
  CERT_FIND_KEY_IDENTIFIER = 983040;
  CERT_FIND_KEY_SPEC = 589824;
  CERT_FIND_MD5_HASH = 262144;
  CERT_FIND_PROPERTY = 327680;
  CERT_FIND_PUBLIC_KEY = 393216;
  CERT_FIND_SHA1_HASH = 65536;
  CERT_FIND_SIGNATURE_HASH = 917504;
  CERT_FIND_SUBJECT_ATTR = 196615;
  CERT_FIND_SUBJECT_CERT = 720896;
  CERT_FIND_SUBJECT_NAME = 131079;
  CERT_FIND_SUBJECT_STR_A = 458759;
  CERT_FIND_SUBJECT_STR_W = 524295;
  CERT_FIND_ISSUER_STR_A = 458756;
  CERT_FIND_ISSUER_STR_W = 524292;
  CERT_FIND_OR_ENHKEY_USAGE_FLAG = 16;
  CERT_FIND_OPTIONAL_ENHKEY_USAGE_FLAG = 1;
  CERT_FIND_NO_ENHKEY_USAGE_FLAG = 8;
  CERT_FIND_VALID_ENHKEY_USAGE_FLAG = 32;
  CERT_FIND_EXT_ONLY_ENHKEY_USAGE_FLAG = 2;

const
  CERT_NAME_EMAIL_TYPE = 1;
  CERT_NAME_RDN_TYPE = 2;
  CERT_NAME_ATTR_TYPE = 3;
  CERT_NAME_SIMPLE_DISPLAY_TYPE = 4;
  CERT_NAME_FRIENDLY_DISPLAY_TYPE = 5;
  CERT_NAME_DNS_TYPE = 6;
  CERT_NAME_URL_TYPE = 7;
  CERT_NAME_UPN_TYPE = 8;

const
  CERT_NAME_ISSUER_FLAG = 1;

const
  CERT_KEY_PROV_HANDLE_PROP_ID = 1;
  CERT_KEY_PROV_INFO_PROP_ID = 2;
  CERT_SHA1_HASH_PROP_ID = 3;
  CERT_MD5_HASH_PROP_ID = 4;
  CERT_HASH_PROP_ID = CERT_SHA1_HASH_PROP_ID;
  CERT_KEY_CONTEXT_PROP_ID = 5;
  CERT_KEY_SPEC_PROP_ID = 6;
  CERT_IE30_RESERVED_PROP_ID = 7;
  CERT_PUBKEY_HASH_RESERVED_PROP_ID = 8;
  CERT_ENHKEY_USAGE_PROP_ID = 9;
  CERT_CTL_USAGE_PROP_ID = CERT_ENHKEY_USAGE_PROP_ID;
  CERT_NEXT_UPDATE_LOCATION_PROP_ID = 10;
  CERT_FRIENDLY_NAME_PROP_ID = 11;
  CERT_PVK_FILE_PROP_ID = 12;
  CERT_DESCRIPTION_PROP_ID = 13;
  CERT_ACCESS_STATE_PROP_ID = 14;
  CERT_SIGNATURE_HASH_PROP_ID = 15;
  CERT_SMART_CARD_DATA_PROP_ID = 16;
  CERT_EFS_PROP_ID = 17;
  CERT_FORTEZZA_DATA_PROP_ID = 18;
  CERT_ARCHIVED_PROP_ID = 19;
  CERT_KEY_IDENTIFIER_PROP_ID = 20;
  CERT_AUTO_ENROLL_PROP_ID = 21;
  CERT_PUBKEY_ALG_PARA_PROP_ID = 22;
  CERT_CROSS_CERT_DIST_POINTS_PROP_ID = 23;
  CERT_ISSUER_PUBLIC_KEY_MD5_HASH_PROP_ID = 24;
  CERT_SUBJECT_PUBLIC_KEY_MD5_HASH_PROP_ID = 25;
  CERT_ENROLLMENT_PROP_ID = 26;
  CERT_DATE_STAMP_PROP_ID = 27;
  CERT_ISSUER_SERIAL_NUMBER_MD5_HASH_PROP_ID = 28;
  CERT_SUBJECT_NAME_MD5_HASH_PROP_ID = 29;
  CERT_EXTENDED_ERROR_INFO_PROP_ID = 30;
  CERT_RENEWAL_PROP_ID = 64;
  CERT_ARCHIVED_KEY_HASH_PROP_ID = 65;
  CERT_AUTO_ENROLL_RETRY_PROP_ID = 66;
  CERT_AIA_URL_RETRIEVED_PROP_ID = 67;
  CERT_AUTHORITY_INFO_ACCESS_PROP_ID = 68;
  CERT_BACKED_UP_PROP_ID = 69;
  CERT_OCSP_RESPONSE_PROP_ID = 70;
  CERT_REQUEST_ORIGINATOR_PROP_ID = 71;
  CERT_SOURCE_LOCATION_PROP_ID = 72;
  CERT_SOURCE_URL_PROP_ID = 73;
  CERT_NEW_KEY_PROP_ID = 74;
  CERT_OCSP_CACHE_PREFIX_PROP_ID = 75;
  CERT_SMART_CARD_ROOT_INFO_PROP_ID = 76;
  CERT_NO_AUTO_EXPIRE_CHECK_PROP_ID = 77;
  CERT_NCRYPT_KEY_HANDLE_PROP_ID = 78;
  CERT_HCRYPTPROV_OR_NCRYPT_KEY_HANDLE_PROP_ID = 79;
  CERT_SUBJECT_INFO_ACCESS_PROP_ID = 80;
  CERT_CA_OCSP_AUTHORITY_INFO_ACCESS_PROP_ID = 81;
  CERT_CA_DISABLE_CRL_PROP_ID = 82;
  CERT_ROOT_PROGRAM_CERT_POLICIES_PROP_ID = 83;
  CERT_ROOT_PROGRAM_NAME_CONSTRAINTS_PROP_ID = 84;
  CERT_SUBJECT_OCSP_AUTHORITY_INFO_ACCESS_PROP_ID = 85;
  CERT_SUBJECT_DISABLE_CRL_PROP_ID = 86;
  CERT_CEP_PROP_ID = 87;
  CERT_SIGN_HASH_CNG_ALG_PROP_ID = 89;
  CERT_SCARD_PIN_ID_PROP_ID = 90;
  CERT_SCARD_PIN_INFO_PROP_ID = 91;
  CERT_SUBJECT_PUB_KEY_BIT_LENGTH_PROP_ID = 92;
  CERT_PUB_KEY_CNG_ALG_BIT_LENGTH_PROP_ID = 93;
  CERT_ISSUER_PUB_KEY_BIT_LENGTH_PROP_ID = 94;
  CERT_ISSUER_CHAIN_SIGN_HASH_CNG_ALG_PROP_ID = 95;
  CERT_ISSUER_CHAIN_PUB_KEY_CNG_ALG_BIT_LENGTH_PROP_ID = 96;
  CERT_NO_EXPIRE_NOTIFICATION_PROP_ID = 97;
  CERT_AUTH_ROOT_SHA256_HASH_PROP_ID = 98;
  CERT_NCRYPT_KEY_HANDLE_TRANSFER_PROP_ID = 99;
  CERT_HCRYPTPROV_TRANSFER_PROP_ID = 100;
  CERT_SMART_CARD_READER_PROP_ID = 101;
  CERT_SEND_AS_TRUSTED_ISSUER_PROP_ID = 102;
  CERT_KEY_REPAIR_ATTEMPTED_PROP_ID = 103;
  CERT_DISALLOWED_FILETIME_PROP_ID = 104;
  CERT_ROOT_PROGRAM_CHAIN_POLICIES_PROP_ID = 105;
  CERT_SMART_CARD_READER_NON_REMOVABLE_PROP_ID = 106;

  CERT_FIRST_RESERVED_PROP_ID = 107;
  CERT_LAST_RESERVED_PROP_ID = $00007fff;
  CERT_FIRST_USER_PROP_ID = $8000;
  CERT_LAST_USER_PROP_ID = $0000ffff;

const
  CRYPT_DELETEKEYSET = 16;

const
  CRYPT_E_NOT_FOUND = $80092004;

const
  CRYPT_ACQUIRE_CACHE_FLAG = $1;
  CRYPT_ACQUIRE_USE_PROV_INFO_FLAG = $2;
  CRYPT_ACQUIRE_COMPARE_KEY_FLAG = $4;
  CRYPT_ACQUIRE_NO_HEALING = $8;
  CRYPT_ACQUIRE_SILENT_FLAG = $40;
  CRYPT_ACQUIRE_WINDOW_HANDLE_FLAG = $80;

  CRYPT_ACQUIRE_NCRYPT_KEY_FLAGS_MASK = $70000;
  CRYPT_ACQUIRE_ALLOW_NCRYPT_KEY_FLAG = $10000;
  CRYPT_ACQUIRE_PREFER_NCRYPT_KEY_FLAG = $20000;
  CRYPT_ACQUIRE_ONLY_NCRYPT_KEY_FLAG = $40000;

const
  szOID_RSA = '1.2.840.113549';
  szOID_PKCS = '1.2.840.113549.1';
  szOID_RSA_HASH = '1.2.840.113549.2';
  szOID_RSA_ENCRYPT = '1.2.840.113549.3';

  szOID_PKCS_1 = '1.2.840.113549.1.1';
  szOID_PKCS_2 = '1.2.840.113549.1.2';
  szOID_PKCS_3 = '1.2.840.113549.1.3';
  szOID_PKCS_4 = '1.2.840.113549.1.4';
  szOID_PKCS_5 = '1.2.840.113549.1.5';
  szOID_PKCS_6 = '1.2.840.113549.1.6';
  szOID_PKCS_7 = '1.2.840.113549.1.7';
  szOID_PKCS_8 = '1.2.840.113549.1.8';
  szOID_PKCS_9 = '1.2.840.113549.1.9';
  szOID_PKCS_10 = '1.2.840.113549.1.10';
  szOID_PKCS_12 = '1.2.840.113549.1.12';

  szOID_RSA_RSA = '1.2.840.113549.1.1.1';
  szOID_RSA_MD2RSA = '1.2.840.113549.1.1.2';
  szOID_RSA_MD4RSA = '1.2.840.113549.1.1.3';
  szOID_RSA_MD5RSA = '1.2.840.113549.1.1.4';
  szOID_RSA_SHA1RSA = '1.2.840.113549.1.1.5';
  szOID_RSA_SETOAEP_RSA = '1.2.840.113549.1.1.6';

  szOID_RSAES_OAEP = '1.2.840.113549.1.1.7';
  szOID_RSA_MGF1 = '1.2.840.113549.1.1.8';
  szOID_RSA_PSPECIFIED = '1.2.840.113549.1.1.9';
  szOID_RSA_SSA_PSS = '1.2.840.113549.1.1.10';
  szOID_RSA_SHA256RSA = '1.2.840.113549.1.1.11';
  szOID_RSA_SHA384RSA = '1.2.840.113549.1.1.12';
  szOID_RSA_SHA512RSA = '1.2.840.113549.1.1.13';

  szOID_RSA_DH = '1.2.840.113549.1.3.1';

  szOID_RSA_data = '1.2.840.113549.1.7.1';
  szOID_RSA_signedData = '1.2.840.113549.1.7.2';
  szOID_RSA_envelopedData = '1.2.840.113549.1.7.3';
  szOID_RSA_signEnvData = '1.2.840.113549.1.7.4';
  szOID_RSA_digestedData = '1.2.840.113549.1.7.5';
  szOID_RSA_hashedData = '1.2.840.113549.1.7.5';
  szOID_RSA_encryptedData = '1.2.840.113549.1.7.6';

  szOID_RSA_emailAddr = '1.2.840.113549.1.9.1';
  szOID_RSA_unstructName = '1.2.840.113549.1.9.2';
  szOID_RSA_contentType = '1.2.840.113549.1.9.3';
  szOID_RSA_messageDigest = '1.2.840.113549.1.9.4';
  szOID_RSA_signingTime = '1.2.840.113549.1.9.5';
  szOID_RSA_counterSign = '1.2.840.113549.1.9.6';
  szOID_RSA_challengePwd = '1.2.840.113549.1.9.7';
  szOID_RSA_unstructAddr = '1.2.840.113549.1.9.8';
  szOID_RSA_extCertAttrs = '1.2.840.113549.1.9.9';
  szOID_RSA_certExtensions = '1.2.840.113549.1.9.14';
  szOID_RSA_SMIMECapabilities = '1.2.840.113549.1.9.15';
  szOID_RSA_preferSignedData = '1.2.840.113549.1.9.15.1';

  szOID_TIMESTAMP_TOKEN = '1.2.840.113549.1.9.16.1.4';
  szOID_RFC3161_counterSign = '1.3.6.1.4.1.311.3.3.1';

  szOID_RSA_SMIMEalg = '1.2.840.113549.1.9.16.3';
  szOID_RSA_SMIMEalgESDH = '1.2.840.113549.1.9.16.3.5';
  szOID_RSA_SMIMEalgCMS3DESwrap = '1.2.840.113549.1.9.16.3.6';
  szOID_RSA_SMIMEalgCMSRC2wrap = '1.2.840.113549.1.9.16.3.7';

  szOID_RSA_MD2 = '1.2.840.113549.2.2';
  szOID_RSA_MD4 = '1.2.840.113549.2.4';
  szOID_RSA_MD5 = '1.2.840.113549.2.5';

  szOID_RSA_RC2CBC = '1.2.840.113549.3.2';
  szOID_RSA_RC4 = '1.2.840.113549.3.4';
  szOID_RSA_DES_EDE3_CBC = '1.2.840.113549.3.7';
  szOID_RSA_RC5_CBCPad = '1.2.840.113549.3.9';

  szOID_ANSI_X942 = '1.2.840.10046';
  szOID_ANSI_X942_DH = '1.2.840.10046.2.1';

  szOID_X957 = '1.2.840.10040';
  szOID_X957_DSA = '1.2.840.10040.4.1';
  szOID_X957_SHA1DSA = '1.2.840.10040.4.3';

  szOID_ECC_PUBLIC_KEY = '1.2.840.10045.2.1';
  szOID_ECC_CURVE_P256 = '1.2.840.10045.3.1.7';
  szOID_ECC_CURVE_P384 = '1.3.132.0.34';
  szOID_ECC_CURVE_P521 = '1.3.132.0.35';
  szOID_ECDSA_SHA1 = '1.2.840.10045.4.1';
  szOID_ECDSA_SPECIFIED = '1.2.840.10045.4.3';
  szOID_ECDSA_SHA256 = '1.2.840.10045.4.3.2';
  szOID_ECDSA_SHA384 = '1.2.840.10045.4.3.3';
  szOID_ECDSA_SHA512 = '1.2.840.10045.4.3.4';

  szOID_NIST_AES128_CBC = '2.16.840.1.101.3.4.1.2';
  szOID_NIST_AES192_CBC = '2.16.840.1.101.3.4.1.22';
  szOID_NIST_AES256_CBC = '2.16.840.1.101.3.4.1.42';

  szOID_NIST_AES128_WRAP = '2.16.840.1.101.3.4.1.5';
  szOID_NIST_AES192_WRAP = '2.16.840.1.101.3.4.1.25';
  szOID_NIST_AES256_WRAP = '2.16.840.1.101.3.4.1.45';

  szOID_DH_SINGLE_PASS_STDDH_SHA1_KDF = '1.3.133.16.840.63.0.2';
  szOID_DH_SINGLE_PASS_STDDH_SHA256_KDF = '1.3.132.1.11.1';
  szOID_DH_SINGLE_PASS_STDDH_SHA384_KDF = '1.3.132.1.11.2';

  szOID_DS = '2.5';
  szOID_DSALG = '2.5.8';
  szOID_DSALG_CRPT = '2.5.8.1';
  szOID_DSALG_HASH = '2.5.8.2';
  szOID_DSALG_SIGN = '2.5.8.3';
  szOID_DSALG_RSA = '2.5.8.1.1';

  szOID_OIW = '1.3.14';

  szOID_OIWSEC = '1.3.14.3.2';
  szOID_OIWSEC_md4RSA = '1.3.14.3.2.2';
  szOID_OIWSEC_md5RSA = '1.3.14.3.2.3';
  szOID_OIWSEC_md4RSA2 = '1.3.14.3.2.4';
  szOID_OIWSEC_desECB = '1.3.14.3.2.6';
  szOID_OIWSEC_desCBC = '1.3.14.3.2.7';
  szOID_OIWSEC_desOFB = '1.3.14.3.2.8';
  szOID_OIWSEC_desCFB = '1.3.14.3.2.9';
  szOID_OIWSEC_desMAC = '1.3.14.3.2.10';
  szOID_OIWSEC_rsaSign = '1.3.14.3.2.11';
  szOID_OIWSEC_dsa = '1.3.14.3.2.12';
  szOID_OIWSEC_shaDSA = '1.3.14.3.2.13';
  szOID_OIWSEC_mdc2RSA = '1.3.14.3.2.14';
  szOID_OIWSEC_shaRSA = '1.3.14.3.2.15';
  szOID_OIWSEC_dhCommMod = '1.3.14.3.2.16';
  szOID_OIWSEC_desEDE = '1.3.14.3.2.17';
  szOID_OIWSEC_sha = '1.3.14.3.2.18';
  szOID_OIWSEC_mdc2 = '1.3.14.3.2.19';
  szOID_OIWSEC_dsaComm = '1.3.14.3.2.20';
  szOID_OIWSEC_dsaCommSHA = '1.3.14.3.2.21';
  szOID_OIWSEC_rsaXchg = '1.3.14.3.2.22';
  szOID_OIWSEC_keyHashSeal = '1.3.14.3.2.23';
  szOID_OIWSEC_md2RSASign = '1.3.14.3.2.24';
  szOID_OIWSEC_md5RSASign = '1.3.14.3.2.25';
  szOID_OIWSEC_sha1 = '1.3.14.3.2.26';
  szOID_OIWSEC_dsaSHA1 = '1.3.14.3.2.27';
  szOID_OIWSEC_dsaCommSHA1 = '1.3.14.3.2.28';
  szOID_OIWSEC_sha1RSASign = '1.3.14.3.2.29';

  szOID_OIWDIR = '1.3.14.7.2';
  szOID_OIWDIR_CRPT = '1.3.14.7.2.1';
  szOID_OIWDIR_HASH = '1.3.14.7.2.2';
  szOID_OIWDIR_SIGN = '1.3.14.7.2.3';
  szOID_OIWDIR_md2 = '1.3.14.7.2.2.1';
  szOID_OIWDIR_md2RSA = '1.3.14.7.2.3.1';

  szOID_INFOSEC = '2.16.840.1.101.2.1';
  szOID_INFOSEC_sdnsSignature = '2.16.840.1.101.2.1.1.1';
  szOID_INFOSEC_mosaicSignature = '2.16.840.1.101.2.1.1.2';
  szOID_INFOSEC_sdnsConfidentiality = '2.16.840.1.101.2.1.1.3';
  szOID_INFOSEC_mosaicConfidentiality = '2.16.840.1.101.2.1.1.4';
  szOID_INFOSEC_sdnsIntegrity = '2.16.840.1.101.2.1.1.5';
  szOID_INFOSEC_mosaicIntegrity = '2.16.840.1.101.2.1.1.6';
  szOID_INFOSEC_sdnsTokenProtection = '2.16.840.1.101.2.1.1.7';
  szOID_INFOSEC_mosaicTokenProtection = '2.16.840.1.101.2.1.1.8';
  szOID_INFOSEC_sdnsKeyManagement = '2.16.840.1.101.2.1.1.9';
  szOID_INFOSEC_mosaicKeyManagement = '2.16.840.1.101.2.1.1.10';
  szOID_INFOSEC_sdnsKMandSig = '2.16.840.1.101.2.1.1.11';
  szOID_INFOSEC_mosaicKMandSig = '2.16.840.1.101.2.1.1.12';
  szOID_INFOSEC_SuiteASignature = '2.16.840.1.101.2.1.1.13';
  szOID_INFOSEC_SuiteAConfidentiality = '2.16.840.1.101.2.1.1.14';
  szOID_INFOSEC_SuiteAIntegrity = '2.16.840.1.101.2.1.1.15';
  szOID_INFOSEC_SuiteATokenProtection = '2.16.840.1.101.2.1.1.16';
  szOID_INFOSEC_SuiteAKeyManagement = '2.16.840.1.101.2.1.1.17';
  szOID_INFOSEC_SuiteAKMandSig = '2.16.840.1.101.2.1.1.18';
  szOID_INFOSEC_mosaicUpdatedSig = '2.16.840.1.101.2.1.1.19';
  szOID_INFOSEC_mosaicKMandUpdSig = '2.16.840.1.101.2.1.1.20';
  szOID_INFOSEC_mosaicUpdatedInteg = '2.16.840.1.101.2.1.1.21';

  szOID_NIST_sha256 = '2.16.840.1.101.3.4.2.1';
  szOID_NIST_sha384 = '2.16.840.1.101.3.4.2.2';
  szOID_NIST_sha512 = '2.16.840.1.101.3.4.2.3';

const
  CERT_STORE_ADD_NEW = 1;
  CERT_STORE_ADD_USE_EXISTING = 2;
  CERT_STORE_ADD_REPLACE_EXISTING = 3;
  CERT_STORE_ADD_ALWAYS = 4;
  CERT_STORE_ADD_REPLACE_EXISTING_INHERIT_PROPERTIES = 5;
  CERT_STORE_ADD_NEWER = 6;
  CERT_STORE_ADD_NEWER_INHERIT_PROPERTIES = 7;

function PFXImportCertStore(pPFX: PCRYPT_DATA_BLOB; szPassword: PWideChar; dwFlags: DWORD): HCERTSTORE; stdcall; external CryptoLib;
function CertOpenSystemStore(hProv: HCRYPTPROV; szSubsystemProtocol: PChar): HCERTSTORE; stdcall; external CryptoLib name {$IFDEF UNICODE} 'CertOpenSystemStoreW' {$ELSE} 'CertOpenSystemStoreA' {$ENDIF} ;
function CertOpenStore(szStoreProvider: LPCSTR; dwMsgAndCertEncodingType: DWORD; hCryptProv: HCRYPTPROV; dwFlags: DWORD; pvPara: Pointer): HCERTSTORE; stdcall; external CryptoLib name 'CertOpenStore';
function CertCloseStore(hCertStore: HCERTSTORE; dwFlags: DWORD): BOOL; stdcall; external CryptoLib;
function CertEnumCertificatesInStore(hCertStore: HCERTSTORE; pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external CryptoLib;
function CertFindCertificateInStore(hCertStore: HCERTSTORE; dwCertEncodingType: DWORD; dwFindFlags: DWORD; dwFindType: DWORD; pvFindPara: Pointer; pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external CryptoLib;
function CertFreeCertificateContext(pCertContext: PCCERT_CONTEXT): BOOL; stdcall; external CryptoLib;
function CertDuplicateCertificateContext(pCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external CryptoLib;
function CertGetNameStringA(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer; pszNameString: PAnsiChar; cchNameString: DWORD): DWORD; stdcall; external CryptoLib name 'CertGetNameStringA';
function CertGetNameStringW(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer; pszNameString: PWideChar; cchNameString: DWORD): DWORD; stdcall; external CryptoLib name 'CertGetNameStringW';
function CertGetNameString(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer; pszNameString: PChar; cchNameString: DWORD): DWORD; stdcall; external CryptoLib name {$IFDEF UNICODE} 'CertGetNameStringW' {$ELSE} 'CertGetNameStringA' {$ENDIF} ;
function GetFriendlyNameOfCert(pCertContext: PCCERT_CONTEXT; pchBuffer: PChar; cchBuffer: DWORD): DWORD; stdcall; external CryptDlgLib name {$IFDEF UNICODE} 'GetFriendlyNameOfCertW' {$ELSE} 'GetFriendlyNameOfCertA' {$ENDIF} ;
function CertGetCertificateContextProperty(pCertContext: PCCERT_CONTEXT; dwPropId: DWORD; pvData: Pointer; var pcbData: DWORD): BOOL; stdcall; external CryptoLib;
function CryptAcquireContextA(var phProv: HCRYPTPROV; pszContainer, pszProvider: PAnsiChar; dwProvType, dwFlags: DWORD): BOOL; stdcall; external AdvapiLib;
function CryptAcquireContextU(var phProv: HCRYPTPROV; pszContainer, pszProvider: PWideChar; dwProvType, dwFlags: DWORD): BOOL; stdcall; external AdvapiLib name 'CryptAcquireContextW';
function CryptAcquireContextW(var phProv: HCRYPTPROV; pszContainer, pszProvider: PWideChar; dwProvType, dwFlags: DWORD): BOOL; stdcall; external AdvapiLib;
function CryptAcquireContext(var phProv: HCRYPTPROV; pszContainer, pszProvider: PChar; dwProvType, dwFlags: DWORD): BOOL; stdcall; external AdvapiLib name {$IFDEF UNICODE} 'CryptAcquireContextW' {$ELSE} 'CryptAcquireContextA' {$ENDIF} ;
function CryptAcquireCertificatePrivateKey(pCertContext: PCCERT_CONTEXT; dwFlags: DWORD; pvParameters: Pointer; var phCryptProv: HCRYPTPROV; var pdwKeySpec: DWORD; pfCallerFreeProv: PBOOL): BOOL; stdcall; external CryptoLib;
function CertAddCertificateContextToStore(hCertStore: HCERTSTORE; pCertContext: PCCERT_CONTEXT; dwAddDisposition: DWORD; ppStoreContext: PPCCERT_CONTEXT): BOOL; stdcall; external CryptoLib;
function CryptSignMessage(pSignPara: PCRYPT_SIGN_MESSAGE_PARA; fDetachedSignature: BOOL; cToBeSigned: DWORD; rgpbToBeSigned: PPtrArray; rgcbToBeSigned: PDWORDArray; pbSignedBlob: PByte; var pcbSignedBlob: DWORD): BOOL; stdcall external CryptoLib;

function CertGetNameStringPAS(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer; out Name: string): boolean; overload;
function CertGetNameStringPAS(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer): string; overload;
function CertGetCertificateContextPropertyPAS(pCertContext: PCCERT_CONTEXT; dwPropId: DWORD; out Data: AnsiString): BOOL; overload;
function CertGetCertificateContextPropertyPAS(pCertContext: PCCERT_CONTEXT; dwPropId: DWORD): AnsiString; overload;

implementation

function CertGetNameStringPAS(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer; out Name: string): boolean; overload;
var
  n: DWORD;
begin
  Result := False;
  Name := '';
  n := CertGetNameString(pCertContext, dwType, dwFlags, pvTypePara, nil, 0);
  if n > 0 then
  begin
    SetLength(Name, n);
    n := CertGetNameString(pCertContext, dwType, dwFlags, pvTypePara, @Name[1], n);
    if n > 0 then
    begin
      SetLength(Name, n-1);
      Result := True;
    end
    else
      Name := '';
  end;
end;

function CertGetNameStringPAS(pCertContext: PCCERT_CONTEXT; dwType, dwFlags: DWORD; pvTypePara: Pointer): string;
begin
  if not CertGetNameStringPAS(pCertContext, dwType, dwFlags, pvTypePara, Result) then
    Result := '';
end;

function CertGetCertificateContextPropertyPAS(pCertContext: PCCERT_CONTEXT; dwPropId: DWORD; out Data: AnsiString): BOOL;
var
  n: DWORD;
begin
  Result := False;
  Data := '';
  n := 0;
  if CertGetCertificateContextProperty(pCertContext, dwPropId, nil, n) then
  begin
    SetLength(Data, n);
    if CertGetCertificateContextProperty(pCertContext, dwPropId, @Data[1], n) then
    begin
      SetLength(Data, n);
      Result := True;
    end
    else
      Data := '';
  end;
end;

function CertGetCertificateContextPropertyPAS(pCertContext: PCCERT_CONTEXT; dwPropId: DWORD): AnsiString;
begin
  if not CertGetCertificateContextPropertyPAS(pCertContext, dwPropId, Result) then
    Result := '';
end;

end.
