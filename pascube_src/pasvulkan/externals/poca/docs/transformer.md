
## POCA Transformer Deep Dive

The **Transformer** is a sophisticated token stream manipulation stage that sits between the lexer and parser. It performs **syntactic desugaring** and **normalization** by rewriting token sequences into simpler, canonical forms that the parser can handle more easily. In essence, it transforms high-level language constructs into more primitive ones, for to keeping the parser simpler and more focused on core semantics.

### Main Entry Point

```pascal
procedure ProcessTransformer(var Parser:TPOCAParser);
begin
  ResetTokenVisited;
  TransformAtThis;         // Transform @ shorthand
  TransformLambdaFunction; // Transform lambda syntax
  TransformBlock(Parser.Tree.Children,[],false); // Transform everything else
end;
```

### Core Transformations

#### 1. **`TransformAtThis` - Property Access Shorthand**
Converts standalone `@` tokens into `this.`:

```js
@propertyName  /* becomes */ this.propertyName
@              /* becomes */ this.
```

This only applies when `@` isn't preceded by valid expressions (symbols, literals, closing braces, etc.). It's syntactic sugar for accessing object properties.

---

#### 2. **`TransformLambdaFunction` - Lambda to Function Conversion**
Converts arrow function syntax into regular function declarations:

```js
let add = (a, b) => a + b;
// becomes
let add = function add(a, b) { return a + b; };

let square = (x) => x * x;
// becomes
let square = function square(x) { return x * x; };

let double = x => x * 2; // without parentheses, single parameter
// becomes
let double = function double(x) { return x * 2; };

let otherSquare(x) => x * x;
// becomes
let otherSquare = function otherSquare(x) { return x * x; };

```

Key operations:
- Converts `ptLAMBDA` to `ptFUNCTION` and `ptFASTLAMBDA` to `ptFASTFUNCTION`
- Moves the function keyword before the parameter list
- Adds assignment operators when assigning to variables
- Automatically names anonymous functions when assigned to symbols

---

#### 3. **`TransformBlock` - Complex Structural Transformations**

This is the workhorse that handles most language constructs. It recursively processes token streams and applies dozens of transformations:

##### **A. `super` Keyword Transformation**
```js
super.methodName()  /* becomes */ this@.SUPER_CODE_SYMBOL
super()             /* becomes */ this@.SUPER_CODE_SYMBOL()
```
Converts `super` into internal representation for base class method calls.

##### **B. `constructor` Keyword**
```js
constructor(args) { ... }  
// becomes  
function __CONSTRUCTOR_VALUE__(args) { ... }
```
Replaces `constructor` with a special symbol name for class constructors.

##### **C. `import` Statement Desugaring**

Multiple complex forms get normalized:

**Simple import:**
```js
import "module.poca"  
// becomes
import("module.poca");
```

**Selective import:**
```js
import { foo, bar } from "module";
// becomes
var foo = import("module").exports.foo;
var bar = import("module").exports.bar;
```

**Wildcard import:**
```js
import * from "module";
// becomes
import("module", ["*"]);
```

**Path-based import:**
```js
import x from a.b.c;
// becomes
var x = a.b.c.exports.x;
```

The path tokens after `from` get converted after being used to construct the assignment.

##### **D. `export` Statement**
```js
export foo, bar, baz;
// becomes
exports.foo = foo;
exports.bar = bar;
exports.baz = baz;
```

##### **E. `foreach`/`forkey`/`forindex` - Iterator Syntax**
```js
foreach (item in collection)
// becomes
foreach (item; collection)
```
Converts `in` keyword to semicolon separator for easier parsing.

##### **F. Function Declaration Normalization**

**Method-style functions:**
```js
function obj.method(x) { ... }
// becomes
obj.method = function method(x) { ... };
```

**Standalone named functions:**
```js
function myFunc(x) { ... }
// becomes
var myFunc = function myFunc(x) { ... };
```

Handles `::` operator (converts to `.` for prototype methods).

##### **G. Class/Module Transformation**

This is **extremely complex**. Classes get transformed into function calls with closures:

```js
class MyClass extends BaseClass {
  var x = 10;
  constructor(v) { this.x = v; }
  function method() { ... }
  ...
}

function MyClass.testMethod() { ... }

function MyClass::otherMethod() { ... }
```

Becomes roughly:
```js
var MyClass = (classfunction(let PROTO) {
  local.hashKind = CLASS_KIND;
  local.className = "MyClass";
  local.classType = local;
  local.prototype = PROTO;
  local.constructor = PROTO;
  local.x = 10;
  local.create = function MyClass(v) { this.x = v; };
  local.method = function method() { ... };
  // ... class body ...
})(BaseClass);

myClass.testMethod = function testMethod() { ... };

myClass.otherMethod = function otherMethod() { ... };
```

Key operations:
- Inserts `local.hashKind`, `local.className`, `local.classType` so that the runtime knows it's actually a class
- Sets up `local.prototype` and `local.constructor`
- For modules: adds `local.exports = {}`
- Handles `extends` clause by passing parent class as argument

**The Big Picture:**  
Technically, classes and modules become **immediately-invoked function expressions (IIFEs)** that return constructor functions with properly set up prototypes and inheritance chains. Since POCA is fundamentally prototype-based under the hood, the class syntax is syntactic sugar. This transformation bridges the gap, as it desugars familiar class syntax into the underlying prototype-based machinery, letting developers write clean object-oriented code while the runtime operates on prototypes.

##### **H. Variable Declaration Normalization**

```js
var a = 1, b = 2, c = 3;
// becomes
code {
  var a = 1;
  var b = 2;
  var c = 3;
}
```

Multiple comma-separated declarations get split into individual statements wrapped in a `code` block. Uninitialized variables get `= null` added:

```js
var x;  
// becomes
var x = null;
```

---

### Utility Functions

The transformer has rich token manipulation utilities:

- **InsertAfter/InsertBefore** - Insert tokens at specific positions
- **InsertNumAfter/InsertSymbolAfter/InsertStringAfter** - Insert typed values
- **RemoveToken** - Delete tokens from stream
- **MoveToAfter/MoveToBefore** - Relocate existing tokens
- **SkipBraces** - Navigate matched bracket pairs

---

### Why This Matters

The transformer **simplifies the parser** by:

1. **Eliminating syntactic sugar** - Lambda arrows, `@` shorthand, `import`/`export` become simpler constructs
2. **Normalizing variants** - Multiple ways to write the same thing become one canonical form
3. **Explicit structure** - Implicit operations (like uninitialized variables) become explicit
4. **Flattening complexity** - Classes/modules decompose into function calls and assignments

This lets the parser focus on **semantic analysis** rather than handling dozens of special syntactic cases, making the overall compilation pipeline more maintainable and robust, as well as easier to extend with new language features in the future. It keeps the parser simpler and more focused on the core language semantics.

---

### Summary

The transformer is essentially a **macro expansion and rewriting engine** that:
- Converts **syntactic sugar** into **core language primitives**
- **Desugars** high-level constructs (classes, modules, imports) into function calls and assignments
- **Normalizes** token sequences for consistent parser input
- Acts as a **preprocessing compiler pass** that bridges lexical and syntactic analysis

It's one of the most critical and complex stages in POCA's compilation pipeline, handling much of what makes POCA feel like a modern scripting language while keeping the parser relatively straightforward.