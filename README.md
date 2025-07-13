# DiscoFunk
This Prolog program automatically discovers mathematical functions that map given input-output pairs. It uses constraint solving and backtracking to find sequences of mathematical operations that transform inputs to their corresponding outputs.

## Usage

```
Simple Linear Function:
   ?- discover_function([(1, 3), (2, 5), (3, 7)]).
   % Expected: Found function: (* 2)(+ 1)
   % Meaning: f(x) = 2x + 1

Quadratic Function:
   ?- discover_function([(1, 2), (2, 5), (3, 10)]).
   % Expected: Found function: (^2)(+ 1)
   % Meaning: f(x) = x² + 1

Reciprocal Function:
   ?- discover_function([(1, 1), (2, 0.5), (4, 0.25)]).
   % Expected: Found function: (1/x)
   % Meaning: f(x) = 1/x

Exponential-like Function:
   ?- discover_function([(1, 1), (2, 4), (3, 9)]).
   % Expected: Found function: (^2)
   % Meaning: f(x) = x²
```

## Read about this on Medium

https://medium.com/@gareth.stretton/prolog-function-discovery-b64c41ad2012
