unit UnitSearchTests;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses UnitTestGlobals,FLRE;

procedure ExecuteSearchTests;

implementation

procedure ExecuteSearchTests;
begin

 // Simple basic tests
 ExecuteSearchTest('a','a',[]);
 ExecuteSearchTest('a','zyzzyva',[]);
 ExecuteSearchTest('a+','aa',[]);
 ExecuteSearchTest('(a+|b)+','ab',[]);
 ExecuteSearchTest('ab|cd','xabcdx',[]);
 ExecuteSearchTest('h.*od?','hello'#10'goodbye'#10,[]);
 ExecuteSearchTest('h.*o','hello'#10'goodbye'#10,[]);
 ExecuteSearchTest('h.*o','goodbye'#10'hello'#10,[]);
 ExecuteSearchTest('h.*o','hello world',[]);
 ExecuteSearchTest('h.*o','othello, world',[]);
 ExecuteSearchFailTest('[^\s\S]','aaaaaaa',[]);
 ExecuteSearchTest('a','aaaaaaa',[]);
 ExecuteSearchTest('a*','aaaaaaa',[]);
 ExecuteSearchTest('a*','',[]);
 ExecuteSearchTest('a','cab',[]);
 ExecuteSearchTest('a*b','cab',[]);
 ExecuteSearchTest('((((((((((((((((((((x))))))))))))))))))))','x',[]);
 ExecuteSearchTest('[abcd]','xxxabcdxxx',[]);
 ExecuteSearchTest('[^x]','xxxabcdxxx',[]);
 ExecuteSearchTest('[abcd]+','xxxabcdxxx',[]);
 ExecuteSearchTest('[^x]+','xxxabcdxxx',[]);
 ExecuteSearchTest('(fo|foo)','fo',[]);
 ExecuteSearchTest('(foo|fo)','foo',[]);
 ExecuteSearchTest('aa','aA',[rfIGNORECASE]);
 ExecuteSearchFailTest('aa','aA',[]);
 ExecuteSearchTest('a','Aa',[rfIGNORECASE]);
 ExecuteSearchTest('ABC','abc',[rfIGNORECASE]);
 ExecuteSearchFailTest('ABC','abc',[]);
 ExecuteSearchTest('abc','XABCY',[rfIGNORECASE]);
 ExecuteSearchFailTest('abc','XABCY',[]);
 ExecuteSearchTest('ABC','xabcy',[rfIGNORECASE]);
 ExecuteSearchFailTest('ABC','xabcy',[]);

 // Make sure ^ and $ work.
 ExecuteSearchTest('foo|bar|[A-Z]','foo',[]);
 ExecuteSearchTest('^(foo|bar|[A-Z])','foo',[]);
 ExecuteSearchTest('(foo|bar|[A-Z])$','foo'#10,[rfMULTILINE]);
 ExecuteSearchTest('(foo|bar|[A-Z])$','foo',[]);
 ExecuteSearchTest('^(foo|bar|[A-Z])$','foo'#10,[rfMULTILINE]);
 ExecuteSearchTest('^(foo|bar|[A-Z])$','foo',[]);
 ExecuteSearchTest('^(foo|bar|[A-Z])$','bar'#10,[rfMULTILINE]);
 ExecuteSearchTest('^(foo|bar|[A-Z])$','X',[]);
 ExecuteSearchFailTest('^(foo|bar|[A-Z])$','XY',[]);
 ExecuteSearchFailTest('(foo|bar|[A-Z])$','foo '#10,[rfMULTILINE]);
 ExecuteSearchFailTest('(foo|bar|[A-Z])$','foo ',[]);
 ExecuteSearchFailTest('^(foo|bar|[A-Z])$',' foo '#10,[rfMULTILINE]);
 ExecuteSearchFailTest('^(foo|bar|[A-Z])$',' foo ',[]);
 ExecuteSearchTest('^$','',[]);
 ExecuteSearchFailTest('^$','x',[]);
 ExecuteSearchTest('^^$','',[]);
 ExecuteSearchTest('^$$','',[]);
 ExecuteSearchFailTest('^^$','x',[]);
 ExecuteSearchFailTest('^$$','x',[]);
 ExecuteSearchTest('^^$$','',[]);
 ExecuteSearchFailTest('^^$$','x',[]);
 ExecuteSearchTest('^^^^^^^^$$$$$$$$','',[]);
 ExecuteSearchTest('^','x',[]);
 ExecuteSearchTest('$','x',[]);
 ExecuteSearchAnchoredTest('^','x',[]);
 ExecuteSearchAnchoredFailTest('$','x',[]);

 // Word boundaries
 ExecuteSearchTest('\bfoo\b', 'nofoo foo that',[]);
 ExecuteSearchTest('a\b', 'faoa x',[]);
 ExecuteSearchTest('\bbar', 'bar x',[]);
 ExecuteSearchTest('\bbar', 'foo'#10'bar x',[]);
 ExecuteSearchTest('bar\b', 'foobar',[]);
 ExecuteSearchTest('bar\b', 'foobar'#10'xxx',[]);
 ExecuteSearchTest('(foo|bar|[A-Z])\b', 'foo',[]);
 ExecuteSearchTest('(foo|bar|[A-Z])\b', 'foo'#10,[]);
 ExecuteSearchFailTest('\b', '',[]);
 ExecuteSearchTest('\b', 'x',[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])', 'foo',[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])\b', 'X',[]);
 ExecuteSearchFailTest('\b(foo|bar|[A-Z])\b', 'XY',[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])\b', 'bar',[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])\b', 'foo',[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])\b', 'foo'#10,[]);
 ExecuteSearchTest('\b(foo|bar|[A-Z])\b', 'ffoo bbar N x',[]);
 ExecuteSearchTest('\b(fo|foo)\b', 'fo',[]);
 ExecuteSearchTest('\b(fo|foo)\b', 'foo',[]);
 ExecuteSearchFailTest('\b\b', '',[]);
 ExecuteSearchTest('\b\b', 'x',[]);
 ExecuteSearchFailTest('\b$', '',[]);
 ExecuteSearchTest('\b$', 'x',[]);
 ExecuteSearchTest('\b$', 'y x',[]);
 ExecuteSearchTest('\b.$', 'x',[]);
 ExecuteSearchTest('^\b(fo|foo)\b', 'fo',[]);
 ExecuteSearchTest('^\b(fo|foo)\b', 'foo',[]);
 ExecuteSearchFailTest('^\b', '',[]);
 ExecuteSearchTest('^\b', 'x',[]);
 ExecuteSearchFailTest('^\b\b', '',[]);
 ExecuteSearchTest('^\b\b', 'x',[]);
 ExecuteSearchFailTest('^\b$', '',[]);
 ExecuteSearchFailTest('^\b$', 'x',[]);
 ExecuteSearchTest('^\b.$', 'x',[]);
 ExecuteSearchTest('^\b.\b$', 'x',[]);
 ExecuteSearchFailTest('^^^^^^^^\b$$$$$$$', '',[]);
 ExecuteSearchTest('^^^^^^^^\b.$$$$$$', 'x',[]);
 ExecuteSearchFailTest('^^^^^^^^\b$$$$$$$', 'x',[]);

// Non-word boundaries.
 ExecuteSearchTest('\Bfoo\B', 'n foo xfoox that',[]);
 ExecuteSearchTest('a\B', 'faoa x',[]);
 ExecuteSearchFailTest('\Bbar', 'bar x',[]);
 ExecuteSearchFailTest('\Bbar', 'foo'#10'bar x',[]);
 ExecuteSearchFailTest('bar\B', 'foobar',[]);
 ExecuteSearchFailTest('bar\B', 'foobar'#10'xxx',[]);
 ExecuteSearchTest('(foo|bar|[A-Z])\B', 'foox',[]);
 ExecuteSearchFailTest('(foo|bar|[A-Z])\B', 'foo'#10,[]);
 ExecuteSearchTest('\B', '',[]);
 ExecuteSearchFailTest('\B', 'x',[]);
 ExecuteSearchFailTest('\B(foo|bar|[A-Z])', 'foo',[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])', 'foobar',[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])\B', 'xXy',[]);
 ExecuteSearchFailTest('\B(foo|bar|[A-Z])\B', 'XY',[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])\B', 'XYZ',[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])\B', 'abara',[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])\B', 'xfoo_',[]);
 ExecuteSearchFailTest('\B(foo|bar|[A-Z])\B', 'xfoo'#10,[]);
 ExecuteSearchTest('\B(foo|bar|[A-Z])\B', 'foo bar vNx',[]);
 ExecuteSearchTest('\B(fo|foo)\B', 'xfoo',[]);
 ExecuteSearchTest('\B(foo|fo)\B', 'xfooo',[]);
 ExecuteSearchTest('\B\B', '',[]);
 ExecuteSearchFailTest('\B\B', 'x',[]);
 ExecuteSearchTest('\B\B', 'xx',[]);
 ExecuteSearchTest('\B$', '',[]);
 ExecuteSearchFailTest('\B$', 'x',[]);
 ExecuteSearchFailTest('\B$', 'y x',[]);
 ExecuteSearchFailTest('\B.$', 'x',[]);
 ExecuteSearchFailTest('^\B(fo|foo)\B', 'fo',[]);
 ExecuteSearchFailTest('^\B(fo|foo)\B', 'foo',[]);
 ExecuteSearchTest('^\B', '',[]);
 ExecuteSearchFailTest('^\B', 'x',[]);
 ExecuteSearchTest('^\B\B', '',[]);
 ExecuteSearchFailTest('^\B\B', 'x',[]);
 ExecuteSearchTest('^\B$', '',[]);
 ExecuteSearchFailTest('^\B$', 'x',[]);
 ExecuteSearchFailTest('^\B.$', 'x',[]);
 ExecuteSearchFailTest('^\B.\B$', 'x',[]);
 ExecuteSearchTest('^^^^^^^^\B$$$$$$$', '',[]);
 ExecuteSearchFailTest('^^^^^^^^\B.$$$$$$', 'x',[]);
 ExecuteSearchFailTest('^^^^^^^^\B$$$$$$$', 'x',[]);

 // Weird boundary cases.
 ExecuteSearchTest('^$^$','',[]);
 ExecuteSearchTest('^$^','',[]);
 ExecuteSearchTest('$^$','',[]);
 ExecuteSearchFailTest('^$^$','x',[]);
 ExecuteSearchFailTest('^$^','x',[]);
 ExecuteSearchFailTest('$^$','x',[]);
 ExecuteSearchFailTest('^$^$','x'#10'y',[]);
 ExecuteSearchFailTest('^$^','x'#10'y',[]);
 ExecuteSearchFailTest('$^$','x'#10'y',[]);
 ExecuteSearchFailTest('^$^$','x'#10#10'y',[]);
 ExecuteSearchFailTest('^$^','x'#10#10'y',[]);
 ExecuteSearchFailTest('$^$','x'#10#10'y',[]);
 ExecuteSearchFailTest('^(foo\$)$','foo$bar',[]);
 ExecuteSearchTest('^(foo\$)','foo$',[]);
 ExecuteSearchTest('(foo\$)','foo$',[]);
 ExecuteSearchTest('^...$','abc',[]);

 // UTF-8
 ExecuteSearchTest('^'#$e6#$9c#$ac'$',#$e6#$9c#$ac,[rfUTF8]);
 ExecuteSearchTest('^...$',#$e6#$97#$a5#$e6#$9c#$ac#$e8#$aa#$9e,[rfUTF8]);
 ExecuteSearchTest('^...$','.'#$e6#$9c#$ac'.',[rfUTF8]);
 ExecuteSearchTest('^\C\C\C$',#$e6#$9c#$ac,[rfUTF8]);
 ExecuteSearchFailTest('^\C$',#$e6#$9c#$ac,[rfUTF8]);
 ExecuteSearchFailTest('^\C\C\C$',#$e6#$97#$a5#$e6#$9c#$ac#$e8#$aa#$9e,[rfUTF8]);

 // Latin1
 ExecuteSearchFailTest('^...$', #$e6#$97#$a5#$e6#$9c#$ac#$e8#$aa#$9e,[]);
 ExecuteSearchTest('^.........$', #$e6#$97#$a5#$e6#$9c#$ac#$e8#$aa#$9e,[]);
 ExecuteSearchFailTest('^...$', '.'#$e6#$9c#$ac'.',[]);
 ExecuteSearchTest('^.....$', '.'#$e6#$9c#$ac'.',[]);

 // Perl vs Posix
 ExecuteSearchFailTest('\\B(fo|foo)\\B','xfooo',[]);
 ExecuteSearchTest('(fo|foo)','foo',[]);

 // Hexadecimal escapes
 ExecuteSearchTest('\x{61}','a',[]);
 ExecuteSearchTest('\x61','a',[]);
 ExecuteSearchTest('\x{00000061}','a',[]);

 // Unicode scripts
 ExecuteSearchTest('\p{Greek}+', 'a'#$ce#$b1#$ce#$b2'b',[rfUTF8]);
 ExecuteSearchTest('\P{Greek}+', 'a'#$ce#$b1#$ce#$b2'b',[rfUTF8]);
 ExecuteSearchTest('\p{^Greek}+', 'a'#$ce#$b1#$ce#$b2'b',[rfUTF8]);
 ExecuteSearchTest('\P{^Greek}+', 'a'#$ce#$b1#$ce#$b2'b',[rfUTF8]);

 // Unicode properties.  Nd is decimal number.  N is any number.
 ExecuteSearchTest('[^0-9]+', 'abc123',[rfUTF8]);
 ExecuteSearchTest('\p{Nd}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\p{^Nd}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\P{Nd}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\P{^Nd}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\pN+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\p{N}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\p{^N}+', 'abc123'#$c2#$b2#$c2#$b3#$c2#$bc#$c2#$bd#$c2#$be#$e3#$82#$80#$e2#$82#$89,[rfUTF8]);
 ExecuteSearchTest('\p{Any}+', 'abc123',[rfUTF8]);

 // Character classes & case folding
 ExecuteSearchTest('(?i)[@-A]+','@AaB',[]); // matches @Aa but not B
 ExecuteSearchFailTest('(?i)[@-A]+','B',[]); // matches @Aa but not B
 ExecuteSearchTest('(?i)[A-Z]+','aAzZ',[]);
 ExecuteSearchTest('(?i)[A-Z]+','az',[]);
 ExecuteSearchTest('(?i)[^\\]+','Aa\',[]); // \\ is between A-Z and a-z - splits the ranges in an interesting way.
 ExecuteSearchTest('(?i)[^\\]+','Aa',[]); // \\ is between A-Z and a-z - splits the ranges in an interesting way.
 ExecuteSearchFailTest('(?i)[^\\]+','\',[]); // \\ is between A-Z and a-z - splits the ranges in an interesting way.
 ExecuteSearchTest('(?i)[acegikmoqsuwy]+','ACEGIKMOQSUWY',[]);
 ExecuteSearchTest('(?i)[acegikmoqsuwy]+','acegikmoqsuwy',[]);
 ExecuteSearchTest('(?i)[acegikmoqsuwy]+','aCeGiKmOqSuWy',[]);
 ExecuteSearchTest('(?i)[acegikmoqsuwy]+','acegikmoqsuwyACEGIKMOQSUWY',[]);
 ExecuteSearchFailTest('(?-i)acegikmoqsuwy','aCeGiKmOqSuWy',[]);

 // Character classes & case folding
 ExecuteSearchTest('[@-A]+','@AaB',[]);
 ExecuteSearchFailTest('[@-A]{4}','@AaB',[]);
 ExecuteSearchTest('[A-Z]+','aAzZ',[]);
 ExecuteSearchFailTest('[A-Z]{4}','aAzZ',[]);
 ExecuteSearchTest('[acegikmoqsuwy]+','acegikmoqsuwyACEGIKMOQSUWY',[]);
 ExecuteSearchTest('[^\\]+','Aa\',[]);

 // Anchoring
 ExecuteSearchTest('^abc','abcdef',[]);
 ExecuteSearchFailTest('^abc','aabcdef',[]);
 ExecuteSearchTest('^[ay]*[bx]+c','abcdef',[]);
 ExecuteSearchTest('^[ay]*[bx]+c','aabcdef',[]);
 ExecuteSearchTest('def$','abcdef',[]);
 ExecuteSearchFailTest('def$','abcdeff',[]);
 ExecuteSearchTest('d[ex][fy]$','abcdef',[]);
 ExecuteSearchFailTest('d[ex][fy]$','abcdeff',[]);
 ExecuteSearchTest('[dz][ex][fy]$','abcdef',[]);
 ExecuteSearchFailTest('[dz][ex][fy]$','abcdeff',[]);
 ExecuteSearchTest('(?m)^abc','abcdef',[]);
 ExecuteSearchFailTest('(?m)^abc','aabcdef',[]);
 ExecuteSearchTest('(?m)^[ay]*[bx]+c','abcdef',[]);
 ExecuteSearchTest('(?m)^[ay]*[bx]+c','aabcdef',[]);
 ExecuteSearchTest('(?m)def$','abcdef',[]);
 ExecuteSearchFailTest('(?m)def$','abcdeff',[]);
 ExecuteSearchTest('(?m)d[ex][fy]$','abcdef',[]);
 ExecuteSearchFailTest('(?m)d[ex][fy]$','abcdeff',[]);
 ExecuteSearchTest('(?m)[dz][ex][fy]$','abcdef',[]);
 ExecuteSearchFailTest('(?m)[dz][ex][fy]$','abcdeff',[]);
 ExecuteSearchTest('^','a',[]);
 ExecuteSearchTest('^^','a',[]);

 // Context
 ExecuteSearchTest('a','a',[]);
 ExecuteSearchTest('ab*','a',[]);
 ExecuteSearchTest('a\C*','a',[]);
 ExecuteSearchTest('a\C*|ba\C','baba',[]);

 // Back-reference comparison groups
 ExecuteSearchTest('(?i)(s(?-i)\p{Lu}(?i)t)(?P=1:s\p{Lu}t)','sUtsut',[]);
 ExecuteSearchFailTest('(?i)(s(?-i)\p{Lu}(?i)t)(?P=1:s\p{Lu}t)','sZtsut',[]);

 // Anchoring in alternating groups
 ExecuteSearchTest('(^| *) *abc *(,|$)','abc, foobar',[]);
 ExecuteSearchTest('(^| *) *abc *(,|$)','abc',[]);
 ExecuteSearchFailTest('(^| *) *abc *(,|$)','abca',[]);
 ExecuteSearchFailTest('(^| *) *abc *(,|$)','abc a',[]);

 // Back-references
 ExecuteSearchTest('([a-c])\1(x)(y)\3','aaxyy',[]);
 ExecuteSearchTest('([a-c])\1(x)(y)\3','aAxyy',[rfIGNORECASE]);
 ExecuteSearchFailTest('([a-c])\1(x)(y)\3','aaxyz',[]);
 ExecuteSearchFailTest('([a-c])\1(x)(y)\3','aAxyz',[rfIGNORECASE]);
 ExecuteSearchFailTest('([a-c])\1(x)(y)\3','aBxyy',[]);
 ExecuteSearchFailTest('([a-c])\1(x)(y)\3','abxyy',[rfIGNORECASE]);

 // https://github.com/BeRo1985/flre/issues/19
 ExecuteSearchTest('([A-Za-z0-9+/]){4}','0FB7',[]);
 ExecuteSearchTest('([A-Za-z0-9+/]){4}(|=)','0FB7',[]);
 ExecuteSearchTest('([A-Za-z0-9+/]){4}(|=)A','0FB7A',[]);
 ExecuteSearchTest('([A-Za-z0-9+/]){4}(|=)A','0FB7=A',[]);
 ExecuteSearchFailTest('([A-Za-z0-9+/]){4}(|=)A','0FB7B',[]);
 ExecuteSearchFailTest('([A-Za-z0-9+/]){4}(|=)A','0FB7=B',[]);

 // Unicode classes
 ExecuteSearchTest('^[^\p{Nd}\p{Nl}\p{No}\p{Lu}\p{Ll}\p{Lt}\p{Lm}\p{Lo}]$','.',[rfUTF8]);
 ExecuteSearchTest('^[\p{Nd}\p{Nl}\p{No}\p{Lu}\p{Ll}\p{Lt}\p{Lm}\p{Lo}]$','0',[rfUTF8]);
 ExecuteSearchTest('^(\p{Nd}|\p{Nl}|\p{No}|\p{Lu}|\p{Ll}|\p{Lt}|\p{Lm}|\p{Lo})$','0',[rfUTF8,rfONLYFASTOPTIMIZATIONS]);

end;

end.

