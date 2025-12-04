#!/bin/bash
# Script to switch from CachyOS FPC to standard Arch Linux FPC
# This fixes the thread creation bug

set -e

echo "=== FPC/Lazarus Fix Script ==="
echo ""
echo "This script will:"
echo "1. Remove CachyOS znver4-optimized FPC packages"
echo "2. Install standard Arch Linux FPC and Lazarus"
echo "3. Test thread creation"
echo "4. Build Goverlay"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Checking current packages..."
pacman -Q fpc lazarus 2>/dev/null || echo "Some packages not installed"

echo ""
echo "Step 2: Installing from standard Arch repos..."
echo "This will force installation from [extra] repository"

# Install from specific repo
sudo pacman -S extra/fpc extra/lazarus-qt6 --needed

echo ""
echo "Step 3: Verifying installation..."
pacman -Q fpc lazarus

echo ""
echo "Step 4: Testing thread creation..."
cat > /tmp/test_fix.pas <<'EOF'
program TestFix;
{$mode objfpc}{$H+}
uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes;
type
  TTest = class(TThread)
    procedure Execute; override;
  end;
procedure TTest.Execute;
begin
  WriteLn('Thread OK!');
end;
var T: TTest;
begin
  T := TTest.Create(False);
  T.WaitFor;
  T.Free;
  WriteLn('SUCCESS!');
end.
EOF

fpc /tmp/test_fix.pas -o/tmp/test_fix
if /tmp/test_fix; then
    echo "✓ Thread creation works!"
else
    echo "✗ Thread creation still fails"
    exit 1
fi

echo ""
echo "Step 5: Checking lazbuild..."
which lazbuild
lazbuild --version

echo ""
echo "Step 6: Cleaning and building Goverlay..."
cd "$(dirname "$0")"
make clean
make

if [ -f ./goverlay ]; then
    echo ""
    echo "=========================================="
    echo "✓ SUCCESS! Goverlay built successfully!"
    echo "=========================================="
    echo ""
    echo "You can now run: ./goverlay"
    echo ""
else
    echo ""
    echo "Build failed. Check errors above."
    exit 1
fi
