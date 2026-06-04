# POCA Language Support for VS Code

POCA is a powerful, JavaScript/ECMAScript-like scripting language with advanced features including prototype-based and class-based OOP, functional programming, coroutines, and multithreading support. Implemented in Object Pascal, POCA offers JIT compilation for enhanced performance on x86-32/x86-64 platforms.

## Features

The VS Code extension provides comprehensive language support for POCA:

- **Syntax Highlighting** - Color-coded syntax for keywords, operators, strings, numbers, and comments
- **Language Configuration** - Automatic indentation and bracket matching

## Language Overview

### Key Features

- **JavaScript/ECMAScript-like syntax** with enhanced capabilities
- **Dynamic typing** with weak type coercion
- **Multiple programming paradigms**: OOP (prototype and class-based), functional, procedural
- **Everything is an expression** - even statements return values
- **Advanced scoping**: `var` (function-scoped), `let` and `const` (block-scoped)
- **Coroutines and threads** for concurrent programming
- **Regular expressions**, exceptions, pattern matching
- **First-class functions** and closures
- **Just-In-Time (JIT) compilation** for improved performance on x86-32/x86-64 platforms
- **Fast functions** for performance-critical code
- **Modules and namespaces** for code organization
- **Built-in standard library** for common tasks
- **Interoperability** with Pascal code

### Variable Declaration

```javascript
var x = 10;      // Function-scoped, stored in hash table
let y = 20;      // Block-scoped, stored in registers/frame storage
const PI = 3.14; // Block-scoped constant
```

### Functions

```javascript
// Standard function
function add(a, b) {
  return a + b;
}

// Fast function (optimized, no var support)
fastfunction multiply(let a, let b) {
  return a * b;
}

// Lambda expressions
let square = (x) => x * x;
let cube = (x) => x * x * x;

// Closures
function makeCounter() {
  let count = 0;
  return function() {
    count += 1;
    return count;
  };
}

let counter = makeCounter();
puts(counter()); // 1
puts(counter()); // 2

// And more...

```

### Object-Oriented Programming

```javascript
// Prototype-based
let proto = {
  greet: function() {
    puts("Hello!");
  }
};

// Class-based
class Person {
  var name;
  
  constructor(let n) {
    this.name = n;
  }
  
  function sayHello() {
    puts("Hello, I'm " ~ this.name);
  }
}
```

### Control Flow

```javascript
// Standard if/else, for, while
if (x > 0) {
  puts("Positive");
} else {
  puts("Non-positive");
}

// Pattern matching with when
when(value) {
  case(1..10) { puts("1-10"); }
  case(20, 30, 40) { puts("20, 30, or 40"); }
  else { puts("Other"); }
}

// Exception handling
try {
  // risky code
} catch(error) {
  // handle error
} finally {
  // cleanup
}
```

## Getting Started

1. **Install the extension** in VS Code
2. **Open or create** a `.poca` file
3. **Start coding** with syntax highlighting and IntelliSense support

## Documentation

For comprehensive documentation, see:
- [Syntax Guide](../docs/syntax.adoc) - Complete language syntax reference
- [Script API](../docs/scriptapi.adoc) - Built-in functions and APIs
- [Examples](../examples/) - Sample POCA programs

## Building POCA

To compile and run POCA programs:

```bash
# Compile the POCA compiler/interpreter (requires Free Pascal or Delphi)
cd src
fpc -O3 -Sd pocarun.dpr

# Run a POCA script
./pocarun yourscript.poca
```

## Requirements

- VS Code 1.50.0 or higher
- POCA interpreter (for running scripts)

## Extension Settings

This extension contributes the following settings:

* Language association for `.poca` files
* Syntax highlighting theme
* Code formatting preferences

## Known Issues

Please report issues at: [GitHub Issues](https://github.com/BeRo1985/poca/issues)

## License

See the POCA.pas beginning for licensing information.

---

**Enjoy coding in POCA!**
