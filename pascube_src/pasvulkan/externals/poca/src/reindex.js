#!/usr/bin/env node

const pascalConsts = `
      popNOP=0;
      popADD=1;
      popSUB=2;
      popMUL=3;
      popDIV=4;
      popNEG=5;
      popNOT=6;
      popCAT=7;
      popLT=8;
      popLTEQ=9;
      popGT=10;
      popGTEQ=11;
      popEQ=12;
      popNEQ=13;
      popCMP=14;
      popSEQ=15;
      popSNEQ=16;
      popEACH=17;
      popJMP=18;
      popJMPLOOP=19;
      popJIFTRUE=20;
      popJIFFALSE=21;
      popJIFTRUELOOP=22;
      popJIFFALSELOOP=23;
      popFCALL=24;
      popMCALL=25;
      popRETURN=26;
      popLOADCODE=27;
      popLOADCONST=28;
      popLOADONE=29;
      popLOADZERO=30;
      popLOADINT32=31;
      popLOADNULL=32;
      popLOADTHAT=33;
      popLOADTHIS=34;
      popLOADSELF=35;
      popLOADLOCAL=36;
      popCOPY=37;
      popARRAYINSERT=38;
      popARRAYEXTRACT=39;
      popINSERT=38;
      popEXTRACT=39;
      popGETLENGTH=40;
      popGETMEMBER=41;
      popSETMEMBER=42;
      popGETLOCAL=43;
      popSETLOCAL=44;
      popGETLOCALVALUE=45;
      popSETLOCALVALUE=46;
      popGETOUTERVALUE=47;
      popSETOUTERVALUE=48;
      popNEWARRAY=49;
      popARRAYPUSH=50;
      popARRAYRANGEPUSH=51;
      popNEWHASH=52;
      popHASHAPPEND=53;
      popSETSYM=54;
      popINDEX=55;
      popFCALLH=56;
      popMCALLH=57;
      popUNPACK=58;
      popSLICE=59;
      popSLICE2=60;
      popSLICE3=61;
      popTRY=62;
      popTRYBLOCKEND=63;
      popTHROW=64;
      popDEC=65;
      popINC=66;
      popBAND=67;
      popBXOR=68;
      popBOR=69;
      popBNOT=70;
      popBSHL=71;
      popBSHR=72;
      popBUSHR=73;
      popMOD=74;
      popPOW=75;
      popINHERITEDGETMEMBER=76;
      popKEY=77;
      popIN=78;
      popINRANGE=79;
      popFTAILCALL=80;
      popMTAILCALL=81;
      popFTAILCALLH=82;
      popMTAILCALLH=83;
      popINSTANCEOF=84;
      popBREAKPOINT=85;
      popNUM=86;
      popN_NOT=87;
      popN_ADD=88;
      popN_SUB=89;
      popN_MUL=90;
      popN_DIV=91;
      popN_NEG=92;
      popN_LT=93;
      popN_LTEQ=94;
      popN_GT=95;
      popN_GTEQ=96;
      popN_EQ=97;
      popN_NEQ=98;
      popN_CMP=99;
      popN_DEC=100;
      popN_INC=101;
      popN_BAND=102;
      popN_BXOR=103;
      popN_BOR=104;
      popN_BNOT=105;
      popN_BSHL=106;
      popN_BSHR=107;
      popN_BUSHR=108;
      popN_MOD=109;
      popN_POW=110;
      popN_INRANGE=111;
      popN_JIFTRUE=112;
      popN_JIFFALSE=113;
      popN_JIFTRUELOOP=114;
      popN_JIFFALSELOOP=115;
      popN_JIFLT=116;
      popN_JIFLTEQ=117;
      popN_JIFGT=118;
      popN_JIFGTEQ=119;
      popN_JIFEQ=120;
      popN_JIFNEQ=121;
      popN_JIFLTLOOP=122;
      popN_JIFLTEQLOOP=123;
      popN_JIFGTLOOP=124;
      popN_JIFGTEQLOOP=125;
      popN_JIFEQLOOP=126;
      popN_JIFNEQLOOP=127;
      popUPDATESTRING=128;
      popREGEXP=129;
      popREGEXPEQ=130;
      popREGEXPNEQ=131;
      popSQRT=132;
      popN_SQRT=133;
      popGETPROTOTYPE=134;
      popSETPROTOTYPE=135;
      popGETCONSTRUCTOR=136;
      popSETCONSTRUCTOR=137;
      popDELETE=138;
      popDELETEEX=139;
      popDEFINED=140;
      popDEFINEDEX=141;
      popLOADGLOBAL=142;
      popLOADBASECLASS=143;
      popGETHASHKIND=144;
      popSETHASHKIND=145;
      popTYPEOF=146;
      popIDOF=147;
      popGHOSTTYPEOF=148;
      popELVIS=149;
      popIS=150;
      popJIFNULL=151;
      popJIFNOTNULL=152;
      popSAFEEXTRACT=153;
      popSAFEGETMEMBER=154;
      popSETCONSTLOCAL=155;
      popCOUNT=156;
`;

/*
let result = "";
let pos = 0;
let newIndex = 0;

// Loop through the entire input string
while (pos < pascalConsts.length) {
  // Look for the next '=' character
  let eqPos = pascalConsts.indexOf("=", pos);
  if (eqPos === -1) {
    // No more equals found; append remaining text.
    result += pascalConsts.substring(pos);
    break;
  }
  
  // Append everything up to and including the '='
  result += pascalConsts.substring(pos, eqPos + 1);
  pos = eqPos + 1;
  
  // Append any whitespace following '='
  while (pos < pascalConsts.length &&
         (pascalConsts.charAt(pos) === " " || pascalConsts.charAt(pos) === "\t")) {
    result += pascalConsts.charAt(pos);
    pos++;
  }
  
  // Skip over the old number (assumed to be a sequence of digits)
  while (pos < pascalConsts.length &&
         pascalConsts.charAt(pos) >= "0" && pascalConsts.charAt(pos) <= "9") {
    pos++;
  }
  
  // Insert the new sequential number
  result += newIndex.toString();
  newIndex++;
  
  // Append the rest of the line up to and including the next ';'
  let semiPos = pascalConsts.indexOf(";", pos);
  if (semiPos === -1) {
    // No semicolon found, append remainder and exit.
    result += pascalConsts.substring(pos);
    pos = pascalConsts.length;
  } else {
    result += pascalConsts.substring(pos, semiPos + 1);
    pos = semiPos + 1;
  }
}

console.log(result);
*/

let newIndex = 0;
const lines = pascalConsts.split("\n");
for(let i = 0; i < lines.length; i++){
  const line = lines[i];
  const assignPos = line.indexOf("=");
  if (assignPos !== -1) {
    let numberStart = assignPos + 1;
    while((numberStart < line.length) && ((line[numberStart] === " ") || (line[numberStart] === "\t"))){
      numberStart++;
    }
    let numberEnd = numberStart;
    while((numberEnd < line.length) && (line[numberEnd] >= "0" && line[numberEnd] <= "9")){
      numberEnd++;
    }
    const newLine = line.substring(0, numberStart) + newIndex.toString() + line.substring(numberEnd);
    lines[i] = newLine;
    newIndex++;
  }
}
const result = lines.join("\n");
console.log(result);
