program TestExample;

{$ifdef fpc}{$mode delphi}{$endif}

{$apptype console}

uses
  SysUtils,
  Classes,
  PasDblStrUtils in '..\externals\pasdblstrutils\src\PasDblStrUtils.pas',
  PasJSON in '..\externals\pasjson\src\PasJSON.pas',
  Pinja;

procedure TestBasicTemplate;
var
  Template: TPinja.TTemplate;
  Context: TPinja.TContext;
  Output: string;
begin
  WriteLn('Test 1: Basic Variable Substitution');
  WriteLn('====================================');
  
  // Create a simple template
  Template := TPinja.TTemplate.Create('Hello, {{ name }}! You are {{ age }} years old.', []);
  try
    Context := TPinja.TContext.Create;
    try
      // Set variables in context
      Context.SetVariable('name', TPinja.TValue.From('Alice'));
      Context.SetVariable('age', TPinja.TValue.From(25));
      
      // Render template
      Output := Template.RenderToString(Context);
      WriteLn('Output: ', Output);
    finally
      Context.Free;
    end;
  finally
    Template.Free;
  end;
  WriteLn;
end;

procedure TestForLoop;
var
  Template: TPinja.TTemplate;
  Context: TPinja.TContext;
  Items: TPinja.TValue;
  Output: string;
  I: Integer;
begin
  WriteLn('Test 2: For Loop');
  WriteLn('================');
  
  // Create template with for loop
  Template := TPinja.TTemplate.Create(
    '{% for item in items %}' +
    '  - {{ item }}' + #10 +
    '{% endfor %}', 
    []
  );
  try
    Context := TPinja.TContext.Create;
    try
      // Create an array
      Items := TPinja.TValue.NewArray;
      Items.Append(TPinja.TValue.From('Apple'));
      Items.Append(TPinja.TValue.From('Banana'));
      Items.Append(TPinja.TValue.From('Cherry'));
      
      Context.SetVariable('items', Items);
      
      // Render template
      Output := Template.RenderToString(Context);
      WriteLn('Output:');
      WriteLn(Output);
    finally
      Context.Free;
    end;
  finally
    Template.Free;
  end;
  WriteLn;
end;

procedure TestConditional;
var
  Template: TPinja.TTemplate;
  Context: TPinja.TContext;
  Output: string;
begin
  WriteLn('Test 3: Conditional Statements');
  WriteLn('==============================');
  
  // Create template with if/else
  Template := TPinja.TTemplate.Create(
    '{% if score >= 90 %}' +
    'Grade: A' +
    '{% elif score >= 80 %}' +
    'Grade: B' +
    '{% elif score >= 70 %}' +
    'Grade: C' +
    '{% else %}' +
    'Grade: F' +
    '{% endif %}', 
    []
  );
  try
    Context := TPinja.TContext.Create;
    try
      // Test with score = 85
      Context.SetVariable('score', TPinja.TValue.From(85));
      Output := Template.RenderToString(Context);
      WriteLn('Score 85: ', Output);
      
      // Test with score = 95
      Context.SetVariable('score', TPinja.TValue.From(95));
      Output := Template.RenderToString(Context);
      WriteLn('Score 95: ', Output);
    finally
      Context.Free;
    end;
  finally
    Template.Free;
  end;
  WriteLn;
end;

procedure TestFilters;
var
  Template: TPinja.TTemplate;
  Context: TPinja.TContext;
  Output: string;
begin
  WriteLn('Test 4: Filters');
  WriteLn('===============');
  
  // Create template with filters
  Template := TPinja.TTemplate.Create(
    'Original: {{ text }}' + #10 +
    'Upper: {{ text|upper }}' + #10 +
    'Lower: {{ text|lower }}', 
    []
  );
  try
    Context := TPinja.TContext.Create;
    try
      Context.SetVariable('text', TPinja.TValue.From('Hello World'));
      Output := Template.RenderToString(Context);
      WriteLn(Output);
    finally
      Context.Free;
    end;
  finally
    Template.Free;
  end;
  WriteLn;
end;

procedure TestObject;
var
  Template: TPinja.TTemplate;
  Context: TPinja.TContext;
  User: TPinja.TValue;
  Output: string;
begin
  WriteLn('Test 5: Object Access');
  WriteLn('=====================');
  
  // Create template accessing object properties
  Template := TPinja.TTemplate.Create(
    'User: {{ user.name }} ({{ user.email }})', 
    []
  );
  try
    Context := TPinja.TContext.Create;
    try
      // Create an object
      User := TPinja.TValue.NewObject;
      User.ObjSet('name', TPinja.TValue.From('Bob'));
      User.ObjSet('email', TPinja.TValue.From('bob@example.com'));
      
      Context.SetVariable('user', User);
      
      Output := Template.RenderToString(Context);
      WriteLn('Output: ', Output);
    finally
      Context.Free;
    end;
  finally
    Template.Free;
  end;
  WriteLn;
end;

begin
  WriteLn('Pinja Template Engine Test Examples');
  WriteLn('====================================');
  WriteLn;
  
  try
    TestBasicTemplate;
    TestForLoop;
    TestConditional;
    TestFilters;
    TestObject;
    
    WriteLn('All tests completed successfully!');
  except
    on E: Exception do
    begin
      WriteLn('Error: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
  
  {$ifndef fpc}
  // Delphi only: wait for enter key
  WriteLn;
  WriteLn('Press Enter to exit...');
  ReadLn;
  {$endif}
end.
