unit UnitVersion;
{$i ..\..\PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

const ProjectManagerVersion='1.00.2022.12.07.02.58.0000';

      ProjectManagerCopyright='Copyright (C) 2018-2022, Benjamin ''BeRo'' Rosseaux';

implementation

end.

