#!/bin/bash
# Diagnostic script to compare user vs root thread creation capabilities

echo "=== Thread Creation Diagnostic ==="
echo ""

echo "1. Current User: $(whoami)"
echo "2. UID: $(id -u)"
echo ""

echo "=== Process Limits ==="
echo "User process limit: $(ulimit -u)"
cat /proc/self/limits | grep "Max processes"
echo ""

echo "=== Systemd Limits ==="
systemctl show user@$(id -u).service 2>/dev/null | grep -E "(TasksMax|MemoryMax|CPUQuota)" || echo "Could not query user service"
echo ""

echo "=== Thread Capability Test ==="
cat > /tmp/test_thread.pas <<'EOF'
program TestThread;
{$mode objfpc}{$H+}
uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes, SysUtils;

type
  TTestThread = class(TThread)
  protected
    procedure Execute; override;
  end;

procedure TTestThread.Execute;
begin
  WriteLn('Thread created successfully!');
end;

var
  Thread: TTestThread;
begin
  try
    WriteLn('Attempting to create thread...');
    Thread := TTestThread.Create(False);
    Thread.WaitFor;
    Thread.Free;
    WriteLn('SUCCESS: Thread creation works!');
  except
    on E: Exception do
    begin
      WriteLn('FAILED: ', E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
EOF

echo "Compiling test program..."
fpc -O2 /tmp/test_thread.pas -o/tmp/test_thread 2>&1 | grep -E "(Error|Warning|Compiling|Linking)" || true

if [ -f /tmp/test_thread ]; then
    echo ""
    echo "Running test as current user..."
    /tmp/test_thread
    TEST_RESULT=$?

    if [ $TEST_RESULT -eq 0 ]; then
        echo "✓ Basic thread creation WORKS"
    else
        echo "✗ Basic thread creation FAILED"
    fi
else
    echo "✗ Test compilation failed"
fi

echo ""
echo "=== CachyOS Specific Checks ==="
echo "Kernel: $(uname -r)"
echo "Scheduler: $(cat /sys/kernel/debug/sched/features 2>/dev/null | head -1 || echo 'Cannot read scheduler features')"
cat /proc/cmdline | grep -o "sched[^ ]*" || echo "No scheduler parameters in cmdline"

echo ""
echo "=== Recommendation ==="
echo "If thread creation works above but lazbuild fails, the issue is likely:"
echo "1. A bug in the Arch Linux lazarus 4.4-1.1 package"
echo "2. Specific to lazbuild binary compilation flags"
echo ""
echo "Try running this script with sudo to compare:"
echo "  sudo bash $0"
