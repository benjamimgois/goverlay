# Pinja

Pinja is a Jinja-subset-compatible template engine for Object Pascal. It's primarily designed for usage with PasLLM for Large Language Model applications, since LLM models have often Jinja templates built-in for prompt processing. But it can be used in any Object Pascal application for other purposes as well, where a lightweight Jinja-like template engine is needed.

## Features

A lot of Jinja features are supported, including:

- **Expression Evaluation**: Full expression support with proper operator precedence
  - Arithmetic operators: `+`, `-`, `*`, `/`, `//` (floor division), `%` (modulo), `**` (power)
  - Comparison operators: `==`, `!=`, `<`, `<=`, `>`, `>=`
  - Logical operators: `and`, `or`, `not`
  - Bitwise operators: `&`, `^`, `bor`, `<<`, `>>`, `~`
  - String concatenation: `~`
  - Membership operators: `in`, `not in`
  - Identity tests: `is`, `is not`
  - Ternary expressions: `value if condition else alternative`

- **Control Flow Structures**
  - Conditional statements: `{% if %}`, `{% elif %}`, `{% else %}`, `{% endif %}`
  - For loops: `{% for item in items %}` with optional filter conditions
  - Loop control: `{% break %}`, `{% continue %}`
  - Filter blocks: `{% filter name %}...{% endfilter %}`
  - Generation blocks: `{% generation %}...{% endgeneration %}`

- **Variable Management**
  - Variable assignment: `{% set name = value %}`
  - Set blocks: `{% set name %}...{% endset %}`
  - Attribute access: `object.attribute`
  - Array/object indexing: `array[index]`
  - Slicing support: `array[start:stop:step]`

- **Macros and Callable Functions**
  - Macro definitions: `{% macro name(params) %}...{% endmacro %}`
  - Positional and keyword arguments
  - Call blocks: `{% call macro_name(args) %}...{% endcall %}`
  - Call parameters: `{% call(params) macro_name(args) %}...{% endcall %}`

- **Comprehensive Built-in Filters** (40+ filters)
  - String manipulation: `upper`, `lower`, `trim`, `strip`, `capitalize`, `title`, `replace`, `center`, `truncate`
  - String tests: `startswith`, `endswith`, `count`
  - List operations: `first`, `last`, `join`, `sort`, `reverse`, `unique`, `slice`, `batch`, `random`
  - Formatting: `format`, `indent`, `wordcount`, `striptags`, `urlize`, `pprint`
  - Type conversions: `int`, `str`/`string`, `list`, `to_json`
  - Data manipulation: `default`, `length`, `dictsort`, `groupby`
  - Escaping: `escape`/`e`, `safe`, `xmlattr`
  - Math: `round`

- **Built-in Functions** (20+ functions)
  - Type conversions: `int()`, `float()`, `str()`, `bool()`, `list()`
  - Math operations: `abs()`, `min()`, `max()`, `sum()`, `round()`
  - Sequence operations: `len()`, `range()`, `keys()`, `values()`, `items()`
  - Filtering: `select()`, `reject()`, `selectattr()`, `rejectattr()`, `map()`
  - Utilities: `namespace()`, `joiner()`, `tojson()`, `equalto()`, `in()`, `raise_exception()`

- **Data Types**
  - Null values
  - Booleans
  - Integers (64-bit)
  - Floating-point numbers
  - Strings (UTF-8 encoded)
  - Arrays (dynamic lists)
  - Objects (key-value dictionaries)
  - Callable objects (functions and macros)

- **Safety and Escaping**
  - HTML escaping for safe output
  - JSON serialization support
  - Safe filter to bypass auto-escaping

- **LLM Integration**
  - Compatible with Jinja2/3 chat template formats used by Large Language Models
  - Separate `PinjaChatTemplate` unit for LLM-specific functionality
  - Designed for prompt processing in AI applications

- **Object Pascal Features**
  - Compatible with Delphi ≥11.2 and FreePascal ≥3.3.1
  - No external dependencies except PasJSON and PasDblStrUtils
  - Cross-platform support (32-bit and 64-bit)
  - zlib license for flexible usage

Missing features compared to full Jinja2:

- No support for asynchronous templates
- Limited support for custom filters and tests
- Some advanced features like template inheritance are not fully implemented
- Inclusion of external templates is not supported
- And some more... but for LLM prompt processing, this is usually sufficient and already more than needed.

## License

It's licensed under the zlib license. See the source code headers for details.

