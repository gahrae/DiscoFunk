/*
================================================================================
FUNCTION DISCOVERY PROGRAM
================================================================================

DESCRIPTION:
This Prolog program automatically discovers mathematical functions that map
given input-output pairs. It uses constraint solving and backtracking to find
sequences of mathematical operations that transform inputs to their corresponding
outputs.

AUTHOR: Gareth Stretton
VERSION: 2.0
DATE: 2025-07-12

FEATURES:
- Supports both unary and binary mathematical operations
- Handles integer and decimal numbers with floating-point tolerance
- Includes operation simplification (combining consecutive operations)
- Provides verification of discovered functions
- Extensible operation set (arithmetic, factorial, square root, etc.)

SUPPORTED OPERATIONS:
- Binary: +, -, *, / (addition, subtraction, multiplication, division)
- Unary: !, ^2, sqrt, abs, neg, 1/x (factorial, square, square root, 
         absolute value, negation, reciprocal)

USAGE:
?- discover_function([(Input1, Output1), (Input2, Output2), ...]).

EXAMPLES:
?- discover_function([(1, 10), (2, 12), (3, 14)]).
% Discovers: x -> x * 2 + 8 (or equivalent)

?- discover_function([(2, 8), (3, 12), (4, 16)]).
% Discovers: x -> x * 4
================================================================================
*/

/* ============================================================================
   UTILITY PREDICATES
   ============================================================================ */

/**
 * is_numeric(+X)
 * 
 * Checks if X is a numeric value (integer or float).
 * 
 * @param X - The value to check
 * @succeeds - If X is numeric
 * @fails - If X is not numeric
 * 
 * Examples:
 * ?- is_numeric(42).     % succeeds
 * ?- is_numeric(3.14).   % succeeds
 * ?- is_numeric(atom).   % fails
 */
is_numeric(X) :- number(X).

/* ============================================================================
   UNARY OPERATIONS
   ============================================================================ */

/**
 * factorial(+N, -Result)
 * 
 * Calculates the factorial of N (N!).
 * Only works for non-negative integers.
 * 
 * @param N - Non-negative integer
 * @param Result - The factorial of N
 * 
 * Examples:
 * ?- factorial(5, X).    % X = 120
 * ?- factorial(0, X).    % X = 1
 */
factorial(0, 1) :- !.
factorial(N, Result) :-
    integer(N),
    N > 0,
    N1 is N - 1,
    factorial(N1, SubResult),
    Result is N * SubResult.

/**
 * square(+X, -Result)
 * 
 * Calculates the square of X (X²).
 * 
 * @param X - Numeric value
 * @param Result - X squared
 * 
 * Examples:
 * ?- square(5, X).       % X = 25
 * ?- square(-3, X).      % X = 9
 */
square(X, Result) :-
    is_numeric(X),
    Result is X * X.

/**
 * sqrt_op(+X, -Result)
 * 
 * Calculates the square root of X.
 * Only works for non-negative numbers.
 * 
 * @param X - Non-negative numeric value
 * @param Result - Square root of X
 * 
 * Examples:
 * ?- sqrt_op(16, X).     % X = 4.0
 * ?- sqrt_op(2, X).      % X = 1.414...
 */
sqrt_op(X, Result) :-
    is_numeric(X),
    X >= 0,
    Result is sqrt(X).

/**
 * abs_op(+X, -Result)
 * 
 * Calculates the absolute value of X.
 * 
 * @param X - Numeric value
 * @param Result - Absolute value of X
 * 
 * Examples:
 * ?- abs_op(-5, X).      % X = 5
 * ?- abs_op(3, X).       % X = 3
 */
abs_op(X, Result) :-
    is_numeric(X),
    Result is abs(X).

/**
 * negate(+X, -Result)
 * 
 * Calculates the negation of X (-X).
 * 
 * @param X - Numeric value
 * @param Result - Negation of X
 * 
 * Examples:
 * ?- negate(5, X).       % X = -5
 * ?- negate(-3, X).      % X = 3
 */
negate(X, Result) :-
    is_numeric(X),
    Result is -X.

/**
 * reciprocal(+X, -Result)
 * 
 * Calculates the reciprocal of X (1/X).
 * X must be non-zero.
 * 
 * @param X - Non-zero numeric value
 * @param Result - Reciprocal of X
 * 
 * Examples:
 * ?- reciprocal(2, X).   % X = 0.5
 * ?- reciprocal(0.5, X). % X = 2.0
 */
reciprocal(X, Result) :-
    is_numeric(X),
    X =\= 0,
    Result is 1 / X.

/* ============================================================================
   BINARY OPERATIONS
   ============================================================================ */

/**
 * add(?Op1, ?Op2, ?Result)
 * 
 * Performs addition with constraint solving capability.
 * Can solve for any one unknown variable given the other two.
 * 
 * @param Op1 - First operand (can be variable)
 * @param Op2 - Second operand (can be variable)
 * @param Result - Sum (can be variable)
 * 
 * Examples:
 * ?- add(3, 4, X).       % X = 7
 * ?- add(X, 4, 7).       % X = 3
 * ?- add(3, Y, 7).       % Y = 4
 */
add(Op1, Op2, R) :-
    (var(Op1), is_numeric(R), is_numeric(Op2), Op1 is R - Op2);
    (var(Op2), is_numeric(R), is_numeric(Op1), Op2 is R - Op1);
    (var(R), is_numeric(Op1), is_numeric(Op2), R is Op1 + Op2);
    (is_numeric(R), is_numeric(Op1), is_numeric(Op2), X is Op1 + Op2, R = X).

/**
 * multiply(?Op1, ?Op2, ?Result)
 * 
 * Performs multiplication with constraint solving capability.
 * Can solve for any one unknown variable given the other two.
 * 
 * @param Op1 - First operand (can be variable)
 * @param Op2 - Second operand (can be variable)  
 * @param Result - Product (can be variable)
 * 
 * Examples:
 * ?- multiply(3, 4, X).  % X = 12
 * ?- multiply(X, 4, 12). % X = 3
 * ?- multiply(3, Y, 12). % Y = 4
 */
multiply(Op1, Op2, R) :-
    (var(Op1), is_numeric(R), is_numeric(Op2), Op2 =\= 0, Op1 is R / Op2);
    (var(Op2), is_numeric(R), is_numeric(Op1), Op1 =\= 0, Op2 is R / Op1);
    (var(R), is_numeric(Op1), is_numeric(Op2), R is Op1 * Op2);
    (is_numeric(R), is_numeric(Op1), is_numeric(Op2), X is Op1 * Op2, R = X).

/**
 * subtract(?Op1, ?Op2, ?Result)
 * 
 * Performs subtraction with constraint solving capability.
 * Can solve for any one unknown variable given the other two.
 * 
 * @param Op1 - Minuend (can be variable)
 * @param Op2 - Subtrahend (can be variable)
 * @param Result - Difference (can be variable)
 * 
 * Examples:
 * ?- subtract(7, 3, X).  % X = 4
 * ?- subtract(X, 3, 4).  % X = 7
 * ?- subtract(7, Y, 4).  % Y = 3
 */
subtract(Op1, Op2, R) :-
    (var(Op1), is_numeric(R), is_numeric(Op2), Op1 is R + Op2);
    (var(Op2), is_numeric(R), is_numeric(Op1), Op2 is Op1 - R);
    (var(R), is_numeric(Op1), is_numeric(Op2), R is Op1 - Op2);
    (is_numeric(R), is_numeric(Op1), is_numeric(Op2), X is Op1 - Op2, R = X).

/**
 * divide(?Op1, ?Op2, ?Result)
 * 
 * Performs division with constraint solving capability.
 * Can solve for any one unknown variable given the other two.
 * Includes division by zero protection.
 * 
 * @param Op1 - Dividend (can be variable)
 * @param Op2 - Divisor (can be variable, must be non-zero)
 * @param Result - Quotient (can be variable)
 * 
 * Examples:
 * ?- divide(12, 3, X).   % X = 4
 * ?- divide(X, 3, 4).    % X = 12
 * ?- divide(12, Y, 4).   % Y = 3
 */
divide(Op1, Op2, R) :-
    (var(Op1), is_numeric(R), is_numeric(Op2), Op2 =\= 0, Op1 is R * Op2);
    (var(Op2), is_numeric(R), is_numeric(Op1), Op1 =\= 0, R =\= 0, Op2 is Op1 / R);
    (var(R), is_numeric(Op1), is_numeric(Op2), Op2 =\= 0, R is Op1 / Op2);
    (is_numeric(R), is_numeric(Op1), is_numeric(Op2), Op2 =\= 0, X is Op1 / Op2, R = X).

/* ============================================================================
   OPERATION APPLICATION
   ============================================================================ */

/**
 * do_op(+Op, +Op1, +Op2, -Result)
 * 
 * Applies a binary operation to two operands.
 * 
 * @param Op - Operation symbol ('+', '-', '*', '/')
 * @param Op1 - First operand
 * @param Op2 - Second operand
 * @param Result - Result of the operation
 * 
 * Examples:
 * ?- do_op('+', 3, 4, X).    % X = 7
 * ?- do_op('*', 5, 6, X).    % X = 30
 */
do_op('+', Op1, Op2, Result) :- add(Op1, Op2, Result).
do_op('-', Op1, Op2, Result) :- subtract(Op1, Op2, Result).
do_op('*', Op1, Op2, Result) :- multiply(Op1, Op2, Result).
do_op('/', Op1, Op2, Result) :- divide(Op1, Op2, Result).

/**
 * do_unary_op(+Op, +X, -Result)
 * 
 * Applies a unary operation to a single operand.
 * 
 * @param Op - Operation symbol ('!', '^2', 'sqrt', 'abs', 'neg', '1/x')
 * @param X - Input value
 * @param Result - Result of the operation
 * 
 * Examples:
 * ?- do_unary_op('^2', 5, X).   % X = 25
 * ?- do_unary_op('!', 4, X).    % X = 24
 * ?- do_unary_op('sqrt', 9, X). % X = 3.0
 */
do_unary_op('!', X, Result) :- factorial(X, Result).
do_unary_op('^2', X, Result) :- square(X, Result).
do_unary_op('sqrt', X, Result) :- sqrt_op(X, Result).
do_unary_op('abs', X, Result) :- abs_op(X, Result).
do_unary_op('neg', X, Result) :- negate(X, Result).
do_unary_op('1/x', X, Result) :- reciprocal(X, Result).

/* ============================================================================
   OPERATION SIMPLIFICATION
   ============================================================================ */

/**
 * simplify_operations(+Operations, -SimplifiedOps)
 * 
 * Simplifies a list of operations by combining consecutive additions/subtractions.
 * This is an alias for combine_add_sub/2.
 * 
 * @param Operations - List of operations to simplify
 * @param SimplifiedOps - Simplified list of operations
 * 
 * Examples:
 * ?- simplify_operations([binary('+', 5), binary('+', 3)], X).
 * % X = [binary('+', 8)]
 */
simplify_operations(Operations, SimplifiedOps) :-
    combine_add_sub(Operations, SimplifiedOps).

/**
 * combine_add_sub(+Operations, -Result)
 * 
 * Combines consecutive addition and subtraction operations into single operations.
 * 
 * @param Operations - List of operations
 * @param Result - List with combined add/sub operations
 * 
 * Algorithm:
 * 1. Identifies consecutive addition/subtraction operations
 * 2. Calculates net effect of these operations
 * 3. Replaces them with a single equivalent operation
 * 4. Preserves other operations unchanged
 */
combine_add_sub([], []) :- !.
combine_add_sub([binary('+', Val)|Rest], Result) :-
    !,
    collect_add_sub_ops([binary('+', Val)|Rest], AddSubOps, Remaining),
    combine_add_sub_list(AddSubOps, CombinedOp),
    combine_add_sub(Remaining, RestResult),
    Result = [CombinedOp|RestResult].
combine_add_sub([binary('-', Val)|Rest], Result) :-
    !,
    collect_add_sub_ops([binary('-', Val)|Rest], AddSubOps, Remaining),
    combine_add_sub_list(AddSubOps, CombinedOp),
    combine_add_sub(Remaining, RestResult),
    Result = [CombinedOp|RestResult].
combine_add_sub([Op|Rest], [Op|RestResult]) :-
    % Not an add/sub operation, keep it and process the rest
    combine_add_sub(Rest, RestResult).

/**
 * collect_add_sub_ops(+Operations, -AddSubOps, -Remaining)
 * 
 * Collects consecutive addition and subtraction operations from the beginning
 * of the operation list.
 * 
 * @param Operations - Input operation list
 * @param AddSubOps - Collected add/sub operations
 * @param Remaining - Remaining operations after add/sub sequence
 */
collect_add_sub_ops([], [], []) :- !.
collect_add_sub_ops([binary('+', Val)|Rest], [binary('+', Val)|More], Remaining) :-
    !,
    collect_add_sub_ops(Rest, More, Remaining).
collect_add_sub_ops([binary('-', Val)|Rest], [binary('-', Val)|More], Remaining) :-
    !,
    collect_add_sub_ops(Rest, More, Remaining).
collect_add_sub_ops(Other, [], Other) :- !.

/**
 * combine_add_sub_list(+AddSubOps, -CombinedOp)
 * 
 * Combines a list of addition and subtraction operations into a single operation.
 * 
 * @param AddSubOps - List of add/sub operations
 * @param CombinedOp - Single equivalent operation
 * 
 * Logic:
 * - Calculates net value of all operations
 * - Returns appropriate single operation (+ or -)
 * - Handles zero result case
 */
combine_add_sub_list([Op], Op) :- !.  % Single operation, return as-is
combine_add_sub_list(AddSubOps, CombinedOp) :-
    calculate_net_value(AddSubOps, 0, NetValue),
    (NetValue =:= 0 ->
        CombinedOp = binary('+', 0)
    ; NetValue > 0 ->
        CombinedOp = binary('+', NetValue)
    ;
        AbsValue is abs(NetValue),
        CombinedOp = binary('-', AbsValue)
    ).

/**
 * calculate_net_value(+AddSubOps, +Acc, -NetValue)
 * 
 * Calculates the net numerical effect of a list of addition/subtraction operations.
 * 
 * @param AddSubOps - List of add/sub operations
 * @param Acc - Accumulator for the calculation
 * @param NetValue - Final net value
 */
calculate_net_value([], Acc, Acc) :- !.
calculate_net_value([binary('+', Val)|Rest], Acc, NetValue) :-
    NewAcc is Acc + Val,
    calculate_net_value(Rest, NewAcc, NetValue).
calculate_net_value([binary('-', Val)|Rest], Acc, NetValue) :-
    NewAcc is Acc - Val,
    calculate_net_value(Rest, NewAcc, NetValue).

/**
 * combine_mult_div(+Operations, -Result)
 * 
 * Combines consecutive multiplication and division operations into single operations.
 * Similar to combine_add_sub but for multiplicative operations.
 * 
 * @param Operations - List of operations
 * @param Result - List with combined mult/div operations
 */
combine_mult_div([], []) :- !.
combine_mult_div([binary('*', Val)|Rest], Result) :-
    !,
    collect_mult_div_ops([binary('*', Val)|Rest], MultDivOps, Remaining),
    combine_mult_div_list(MultDivOps, CombinedOp),
    combine_mult_div(Remaining, RestResult),
    Result = [CombinedOp|RestResult].
combine_mult_div([binary('/', Val)|Rest], Result) :-
    !,
    collect_mult_div_ops([binary('/', Val)|Rest], MultDivOps, Remaining),
    combine_mult_div_list(MultDivOps, CombinedOp),
    combine_mult_div(Remaining, RestResult),
    Result = [CombinedOp|RestResult].
combine_mult_div([Op|Rest], [Op|RestResult]) :-
    % Not a mult/div operation, keep it and process the rest
    combine_mult_div(Rest, RestResult).

/**
 * collect_mult_div_ops(+Operations, -MultDivOps, -Remaining)
 * 
 * Collects consecutive multiplication and division operations.
 * 
 * @param Operations - Input operation list
 * @param MultDivOps - Collected mult/div operations
 * @param Remaining - Remaining operations after mult/div sequence
 */
collect_mult_div_ops([], [], []) :- !.
collect_mult_div_ops([binary('*', Val)|Rest], [binary('*', Val)|More], Remaining) :-
    !,
    collect_mult_div_ops(Rest, More, Remaining).
collect_mult_div_ops([binary('/', Val)|Rest], [binary('/', Val)|More], Remaining) :-
    !,
    collect_mult_div_ops(Rest, More, Remaining).
collect_mult_div_ops(Other, [], Other) :- !.

/**
 * combine_mult_div_list(+MultDivOps, -CombinedOp)
 * 
 * Combines a list of multiplication and division operations into a single operation.
 * 
 * @param MultDivOps - List of mult/div operations
 * @param CombinedOp - Single equivalent operation
 */
combine_mult_div_list([Op], Op) :- !.  % Single operation, return as-is
combine_mult_div_list(MultDivOps, CombinedOp) :-
    calculate_net_multiplier(MultDivOps, 1, NetMultiplier),
    (NetMultiplier =:= 1 ->
        CombinedOp = binary('*', 1)
    ; NetMultiplier > 1 ->
        CombinedOp = binary('*', NetMultiplier)
    ; NetMultiplier > 0 ->
        Divisor is 1 / NetMultiplier,
        CombinedOp = binary('/', Divisor)
    ;
        CombinedOp = binary('*', NetMultiplier)
    ).

/**
 * calculate_net_multiplier(+MultDivOps, +Acc, -NetMultiplier)
 * 
 * Calculates the net multiplicative effect of a list of mult/div operations.
 * 
 * @param MultDivOps - List of mult/div operations
 * @param Acc - Accumulator for the calculation
 * @param NetMultiplier - Final net multiplier
 */
calculate_net_multiplier([], Acc, Acc) :- !.
calculate_net_multiplier([binary('*', Val)|Rest], Acc, NetMultiplier) :-
    NewAcc is Acc * Val,
    calculate_net_multiplier(Rest, NewAcc, NetMultiplier).
calculate_net_multiplier([binary('/', Val)|Rest], Acc, NetMultiplier) :-
    Val =\= 0,
    NewAcc is Acc / Val,
    calculate_net_multiplier(Rest, NewAcc, NetMultiplier).

/**
 * full_simplify(+Operations, -SimplifiedOps)
 * 
 * Performs complete simplification by combining both addition/subtraction
 * and multiplication/division operations.
 * 
 * @param Operations - List of operations to simplify
 * @param SimplifiedOps - Fully simplified list of operations
 * 
 * Process:
 * 1. First combines add/sub operations
 * 2. Then combines mult/div operations
 * 3. Results in maximally simplified operation sequence
 */
full_simplify(Operations, SimplifiedOps) :-
    combine_add_sub(Operations, Step1),
    combine_mult_div(Step1, SimplifiedOps).

/* ============================================================================
   FUNCTION APPLICATION AND TESTING
   ============================================================================ */

/**
 * apply_operations(+Input, -Output, +Operations)
 * 
 * Applies a sequence of operations to transform an input value to an output value.
 * This is the core execution engine for discovered functions.
 * 
 * @param Input - Starting value
 * @param Output - Final result after applying all operations
 * @param Operations - List of operations to apply in sequence
 * 
 * Operation Formats Supported:
 * - binary(Op, Operand): Binary operations with explicit type
 * - unary(Op): Unary operations with explicit type
 * - (Op, Operand): Legacy binary format for backward compatibility
 * 
 * Examples:
 * ?- apply_operations(5, X, [binary('+', 3), binary('*', 2)]).
 * % X = 16 (i.e., (5 + 3) * 2)
 * 
 * ?- apply_operations(4, X, [unary('^2'), binary('-', 1)]).
 * % X = 15 (i.e., 4² - 1)
 */
apply_operations(Value, Value, []) :- !.
apply_operations(Input, Output, [binary(Op, Operand)|Rest]) :-
    do_op(Op, Input, Operand, Intermediate),
    apply_operations(Intermediate, Output, Rest).
apply_operations(Input, Output, [unary(Op)|Rest]) :-
    do_unary_op(Op, Input, Intermediate),
    apply_operations(Intermediate, Output, Rest).
% Legacy support for old format (assumes binary operations)
apply_operations(Input, Output, [(Op, Operand)|Rest]) :-
    do_op(Op, Input, Operand, Intermediate),
    apply_operations(Intermediate, Output, Rest).

/**
 * generate_operations(-Operations, +N)
 * 
 * Generates all possible sequences of operations up to length N.
 * This is the core generation engine for function discovery.
 * 
 * @param Operations - Generated list of operations
 * @param N - Maximum length of operation sequence
 * 
 * Generation Strategy:
 * - Binary operations: Uses operands from -10 to 10 (integers)
 * - Also generates decimal operands: -5.0 to 5.0 with 0.1 increments
 * - Unary operations: No operands needed
 * - Avoids division by zero by excluding zero operands for division
 * 
 * Operation Types Generated:
 * - Binary: '+', '-', '*', '/'
 * - Unary: '!', '^2', 'sqrt', 'abs', 'neg', '1/x'
 * 
 * Examples:
 * ?- generate_operations(Ops, 2).
 * % Generates all 2-operation sequences like:
 * % [binary('+', 1), binary('*', 2)]
 * % [unary('^2'), binary('-', 5)]
 * % etc.
 */
generate_operations([], 0) :- !.
generate_operations([binary(Op, Operand)|Rest], N) :-
    N > 0,
    N1 is N - 1,
    member(Op, ['+', '-', '*', '/']),
    % Generate both integer and decimal operands
    (between(-10, 10, Operand) ; 
     (between(-50, 50, IntPart), between(0, 9, DecPart), Operand is IntPart + DecPart/10)),
    Operand =\= 0,  % Avoid division by zero
    generate_operations(Rest, N1).
generate_operations([unary(Op)|Rest], N) :-
    N > 0,
    N1 is N - 1,
    member(Op, ['!', '^2', 'sqrt', 'abs', 'neg', '1/x']),
    generate_operations(Rest, N1).

/**
 * test_operations(+InputOutputPairs, +Operations)
 * 
 * Tests whether a sequence of operations correctly maps all input-output pairs.
 * Uses floating-point tolerance for comparison.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples to test
 * @param Operations - Operation sequence to test
 * 
 * Tolerance: 0.0001 for floating-point comparison
 * 
 * @succeeds - If operations work for all pairs within tolerance
 * @fails - If any pair fails the test
 * 
 * Examples:
 * ?- test_operations([(1, 4), (2, 8)], [binary('*', 4)]).
 * % Succeeds: 1*4=4, 2*4=8
 * 
 * ?- test_operations([(1, 2), (2, 5)], [binary('+', 1), binary('*', 2)]).
 * % Fails: (1+1)*2=4≠2, (2+1)*2=6≠5
 */
test_operations([], _) :- !.
test_operations([(Input, Output)|Rest], Operations) :-
    apply_operations(Input, Result, Operations),
    % Use tolerance for floating point comparison
    abs(Result - Output) < 0.0001,
    test_operations(Rest, Operations).

/* ============================================================================
   MAIN FUNCTION DISCOVERY ENGINE
   ============================================================================ */

/**
 * find_function(+InputOutputPairs, -Operations)
 * 
 * Main engine for discovering functions that map input-output pairs.
 * Uses depth-limited search with default maximum depth of 5.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples
 * @param Operations - Discovered operation sequence
 * 
 * Search Strategy:
 * 1. Tries operation sequences of increasing length (1 to 5)
 * 2. For each length, generates all possible sequences
 * 3. Tests each sequence against all input-output pairs
 * 4. Returns first sequence that works for all pairs
 * 5. Uses cut (!) to prevent backtracking after first solution
 * 
 * Examples:
 * ?- find_function([(1, 3), (2, 6), (3, 9)], Ops).
 * % Ops = [binary('*', 3)]
 * 
 * ?- find_function([(1, 2), (2, 5), (3, 10)], Ops).
 * % Ops = [unary('^2'), binary('+', 1)] or equivalent
 */
find_function(InputOutputPairs, Operations) :-
    find_function_limited(InputOutputPairs, Operations, 5).  % Limit depth to 5

/**
 * find_function_limited(+InputOutputPairs, -Operations, +MaxDepth)
 * 
 * Function discovery with configurable depth limit.
 * Allows tuning of search depth for different complexity requirements.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples
 * @param Operations - Discovered operation sequence
 * @param MaxDepth - Maximum number of operations to try
 * 
 * Performance Considerations:
 * - Higher MaxDepth = more thorough search but exponentially slower
 * - Lower MaxDepth = faster but might miss complex functions
 * - Recommended: 3-5 for most practical applications
 * 
 * Examples:
 * ?- find_function_limited([(1, 1), (2, 8), (3, 27)], Ops, 3).
 * % Might find: [unary('^2'), binary('*', X)] for cubic function
 */
find_function_limited(InputOutputPairs, Operations, MaxDepth) :-
    between(1, MaxDepth, Length),
    generate_operations(Operations, Length),
    test_operations(InputOutputPairs, Operations),
    !.  % Stop at first solution

/* ============================================================================
   OUTPUT FORMATTING AND DISPLAY
   ============================================================================ */

/**
 * print_function(+Operations)
 * 
 * Pretty-prints a discovered function in human-readable format.
 * Handles both new and legacy operation formats.
 * 
 * @param Operations - List of operations to display
 * 
 * Output Format:
 * - Binary operations: (+ 5), (* 2.5), (/ 3)
 * - Unary operations: (^2), (sqrt), (abs)
 * - Decimal numbers formatted to 2 decimal places
 * - Integer numbers displayed without decimal point
 * 
 * Examples:
 * ?- print_function([binary('+', 3), unary('^2')]).
 * % Outputs: (+ 3)(^2)
 * 
 * ?- print_function([binary('*', 2.5), binary('-', 1)]).
 * % Outputs: (* 2.50)(- 1)
 */
print_function([]) :- !.
print_function([binary(Op, Operand)|Rest]) :-
    write('('), write(Op), write(' '),
    (integer(Operand) -> write(Operand) ; format('~2f', [Operand])),
    write(')'),
    print_function(Rest).
print_function([unary(Op)|Rest]) :-
    write('('), write(Op), write(')'),
    print_function(Rest).
% Legacy support for old format
print_function([(Op, Operand)|Rest]) :-
    write('('), write(Op), write(' '),
    (integer(Operand) -> write(Operand) ; format('~2f', [Operand])),
    write(')'),
    print_function(Rest).

/* ============================================================================
   MAIN DISCOVERY INTERFACE
   ============================================================================ */

/**
 * discover_function(+InputOutputPairs)
 * 
 * Main interface for function discovery. Discovers, displays, and verifies
 * a mathematical function that maps the given input-output pairs.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples
 * 
 * Process:
 * 1. Searches for a function using find_function/2
 * 2. Displays the discovered function in readable format
 * 3. Verifies the function works for all input pairs
 * 4. Shows verification results with checkmarks/crosses
 * 
 * Output Format:
 * - "Found function: " followed by operation sequence
 * - "Verification:" followed by test results
 * - Each test shows: Input -> ActualOutput ✓/✗
 * 
 * Examples:
 * ?- discover_function([(1, 4), (2, 8), (3, 12)]).
 * % Output:
 * % Found function: (* 4)
 * % Verification:
 * % 1 -> 4.0000 ✓
 * % 2 -> 8.0000 ✓
 * % 3 -> 12.0000 ✓
 * 
 * ?- discover_function([(2, 5), (3, 10), (4, 17)]).
 * % Output:
 * % Found function: (^2)(+ 1)
 * % Verification:
 * % 2 -> 5.0000 ✓
 * % 3 -> 10.0000 ✓
 * % 4 -> 17.0000 ✓
 */
discover_function(InputOutputPairs) :-
    find_function(InputOutputPairs, Operations),
    !,  % Cut to prevent backtracking
    write('Found function: '),
    print_function(Operations),
    nl,
    write('Verification:'), nl,
    verify_function(InputOutputPairs, Operations).

/**
 * discover_function_with_simplification(+InputOutputPairs)
 * 
 * Enhanced version of discover_function/1 that includes operation simplification.
 * Attempts to simplify the discovered function by combining operations.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples
 * 
 * Process:
 * 1. Discovers function using standard method
 * 2. Attempts to simplify the operation sequence
 * 3. Displays both original and simplified versions (if different)
 * 4. Includes error handling for simplification failures
 * 5. Verifies using original (unsimplified) function
 * 
 * Simplification Features:
 * - Combines consecutive additions/subtractions
 * - Combines consecutive multiplications/divisions
 * - Reduces operation count where possible
 * - Preserves mathematical equivalence
 * 
 * Examples:
 * ?- discover_function_with_simplification([(1, 8), (2, 9), (3, 10)]).
 * % Might find: (+ 2)(+ 3)(+ 2) 
 * % Simplified: (+ 7)
 * 
 * Warning: Simplification is experimental and may not always work correctly.
 * Use discover_function/1 for reliable results.
 */
discover_function_with_simplification(InputOutputPairs) :-
    find_function(InputOutputPairs, Operations),
    !,  % Cut to prevent backtracking
    write('Found function: '),
    print_function(Operations),
    nl,
    % Try simplification with error handling
    catch(
        (full_simplify(Operations, SimplifiedOps),
         (SimplifiedOps \= Operations ->
            write('Simplified function: '),
            print_function(SimplifiedOps),
            nl
         ; true)
        ),
        Error,
        (write('Simplification failed: '), write(Error), nl)
    ),
    write('Verification:'), nl,
    verify_function(InputOutputPairs, Operations).

/**
 * discover_function_raw(+InputOutputPairs)
 * 
 * Raw version of function discovery without any post-processing.
 * Useful for debugging or when you need the exact discovered sequence.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples
 * 
 * Features:
 * - No simplification attempted
 * - Shows exactly what the search algorithm found
 * - Includes full verification output
 * - Useful for understanding search behavior
 * 
 * Examples:
 * ?- discover_function_raw([(1, 5), (2, 10)]).
 * % Found function (raw): (* 5)
 * % Verification:
 * % 1 -> 5.0000 ✓
 * % 2 -> 10.0000 ✓
 */
discover_function_raw(InputOutputPairs) :-
    find_function(InputOutputPairs, Operations),
    !,  % Cut to prevent backtracking
    write('Found function (raw): '),
    print_function(Operations),
    nl,
    write('Verification:'), nl,
    verify_function(InputOutputPairs, Operations).

/**
 * verify_function(+InputOutputPairs, +Operations)
 * 
 * Verifies that a discovered function works correctly for all input-output pairs.
 * Displays detailed verification results with visual indicators.
 * 
 * @param InputOutputPairs - List of (Input, Output) tuples to verify
 * @param Operations - Operation sequence to test
 * 
 * Output Format:
 * - Each line shows: Input -> CalculatedOutput ✓/✗
 * - ✓ indicates successful match (within tolerance)
 * - ✗ indicates mismatch (difference > 0.0001)
 * - Results formatted to 4 decimal places for clarity
 * 
 * Tolerance: 0.0001 for floating-point comparison
 * 
 * Examples:
 * ?- verify_function([(1, 2), (2, 4)], [binary('*', 2)]).
 * % Output:
 * % 1 -> 2.0000 ✓
 * % 2 -> 4.0000 ✓
 * 
 * ?- verify_function([(1, 3), (2, 5)], [binary('+', 1)]).
 * % Output:
 * % 1 -> 2.0000 ✗
 * % 2 -> 3.0000 ✗
 */
verify_function([], _) :- !.
verify_function([(Input, Output)|Rest], Operations) :-
    apply_operations(Input, Result, Operations),
    write(Input), write(' -> '),
    (integer(Result) -> write(Result) ; format('~4f', [Result])),
    Diff is abs(Result - Output),
    (Diff < 0.0001 -> write(' ✓') ; write(' ✗')),
    nl,
    verify_function(Rest, Operations).

/* ============================================================================
   EXAMPLE USAGE AND TESTING
   ============================================================================ */

/**
 * example1
 * 
 * Example 1: Linear function discovery
 * Tests discovery of a linear function with negative slope.
 * 
 * Input-Output Pairs: 5->24, 7->22
 * Expected Pattern: Decreasing linear function
 * Possible Function: x -> -x + 29 or equivalent
 * 
 * Usage: ?- example1.
 */
example1 :-
    write('Example 1: Finding function for 5->24, 7->22'), nl,
    discover_function([(5, 24), (7, 22)]).

/**
 * example2
 * 
 * Example 2: Linear function with multiple points
 * Tests discovery of a linear function with positive slope.
 * 
 * Input-Output Pairs: 1->10, 2->12, 3->14
 * Expected Pattern: Linear function with slope 2
 * Possible Function: x -> 2x + 8
 * 
 * Usage: ?- example2.
 */
example2 :-
    write('Example 2: Finding function for 1->10, 2->12, 3->14'), nl,
    discover_function([(1, 10), (2, 12), (3, 14)]).

/**
 * example3
 * 
 * Example 3: Simple multiplication
 * Tests discovery of a simple multiplicative function.
 * 
 * Input-Output Pairs: 2->8, 3->12, 4->16
 * Expected Pattern: Multiplication by 4
 * Expected Function: x -> 4x
 * 
 * Usage: ?- example3.
 */
example3 :-
    write('Example 3: Finding function for 2->8, 3->12, 4->16'), nl,
    discover_function([(2, 8), (3, 12), (4, 16)]).

/**
 * example12
 * 
 * Example 12: Reciprocal function
 * Tests discovery of reciprocal (inverse) function.
 * 
 * Input-Output Pairs: 1->1, 2->0.5, 4->0.25
 * Expected Pattern: Reciprocal function
 * Expected Function: x -> 1/x
 * 
 * Usage: ?- example12.
 */
example12 :-
    write('Example 12: Finding function for 1->1, 2->0.5, 4->0.25 (should find reciprocal)'), nl,
    discover_function([(1, 1), (2, 0.5), (4, 0.25)]).

/**
 * example13
 * 
 * Example 13: Simplification test - multiple additions
 * Tests the simplification system with consecutive additions.
 * 
 * Input-Output Pairs: 1->11, 2->12, 3->13
 * Expected Pattern: Addition by 10
 * Purpose: Test if multiple additions are combined into single operation
 * 
 * Usage: ?- example13.
 */
example13 :-
    write('Example 13: Testing simplification - should reduce multiple additions'), nl,
    discover_function([(1, 11), (2, 12), (3, 13)]).

/**
 * example14
 * 
 * Example 14: Simplification test - mixed operations
 * Tests simplification with mixed addition and subtraction.
 * 
 * Input-Output Pairs: 5->8, 10->13, 15->18
 * Expected Pattern: Addition by 3
 * Purpose: Test if mixed add/subtract operations are simplified
 * 
 * Usage: ?- example14.
 */
example14 :-
    write('Example 14: Testing simplification - mixed add/subtract'), nl,
    discover_function([(5, 8), (10, 13), (15, 18)]).

/**
 * example15
 * 
 * Example 15: Multiplication simplification
 * Tests simplification of multiplication operations.
 * 
 * Input-Output Pairs: 1->6, 2->12, 3->18
 * Expected Pattern: Multiplication by 6
 * Purpose: Test if multiple multiplications are combined
 * 
 * Usage: ?- example15.
 */
example15 :-
    write('Example 15: Testing multiplication simplification'), nl,
    discover_function([(1, 6), (2, 12), (3, 18)]).

/* ============================================================================
   UTILITY AND TESTING PREDICATES
   ============================================================================ */

/**
 * test_custom(+Pairs)
 * 
 * Interactive predicate for testing custom input-output pairs.
 * Allows users to test their own data sets easily.
 * 
 * @param Pairs - List of (Input, Output) tuples to test
 * 
 * Features:
 * - Displays the input pairs being tested
 * - Runs full function discovery process
 * - Useful for interactive exploration
 * 
 * Examples:
 * ?- test_custom([(1, 5), (2, 10), (3, 15)]).
 * % Testing custom pairs: [(1, 5), (2, 10), (3, 15)]
 * % Found function: (* 5)
 * % Verification: ...
 */
test_custom(Pairs) :-
    write('Testing custom pairs: '), write(Pairs), nl,
    discover_function(Pairs).

/**
 * test_simplification(+Operations)
 * 
 * Manual testing of the simplification system.
 * Useful for debugging and understanding simplification behavior.
 * 
 * @param Operations - List of operations to simplify
 * 
 * Output:
 * - Shows original operation sequence
 * - Shows simplified operation sequence
 * - Useful for development and debugging
 * 
 * Examples:
 * ?- test_simplification([binary('+', 5), binary('+', 3), binary('-', 2)]).
 * % Original: (+ 5)(+ 3)(- 2)
 * % Simplified: (+ 6)
 * 
 * ?- test_simplification([binary('*', 2), binary('*', 3), binary('/', 2)]).
 * % Original: (* 2)(* 3)(/ 2)
 * % Simplified: (* 3)
 */
test_simplification(Operations) :-
    write('Original: '), print_function(Operations), nl,
    full_simplify(Operations, Simplified),
    write('Simplified: '), print_function(Simplified), nl.

/**
 * test_operations_manual(+Input, +Operations, +ExpectedOutput)
 * 
 * Manual testing of operation sequences against expected results.
 * Useful for debugging and verifying specific operation combinations.
 * 
 * @param Input - Input value to test
 * @param Operations - Operation sequence to apply
 * @param ExpectedOutput - Expected result
 * 
 * Output:
 * - Shows input, operations, actual result, and success/failure indicator
 * - Useful for step-by-step debugging
 * 
 * Examples:
 * ?- test_operations_manual(5, [unary('^2'), binary('+', 1)], 26).
 * % Input: 5, Operations: (^2)(+ 1), Result: 26 ✓
 * 
 * ?- test_operations_manual(3, [binary('*', 2), binary('-', 1)], 5).
 * % Input: 3, Operations: (* 2)(- 1), Result: 5 ✓
 */
test_operations_manual(Input, Operations, Output) :-
    apply_operations(Input, Result, Operations),
    write('Input: '), write(Input),
    write(', Operations: '), print_function(Operations),
    write(', Result: '), write(Result),
    (abs(Result - Output) < 0.0001 -> write(' ✓') ; write(' ✗')),
    nl.

/* ============================================================================
   USAGE EXAMPLES AND DOCUMENTATION
   ============================================================================ */

/*
================================================================================
COMPREHENSIVE USAGE EXAMPLES
================================================================================

BASIC USAGE:
------------

1. Simple Linear Function:
   ?- discover_function([(1, 3), (2, 5), (3, 7)]).
   % Expected: Found function: (* 2)(+ 1)
   % Meaning: f(x) = 2x + 1

2. Quadratic Function:
   ?- discover_function([(1, 2), (2, 5), (3, 10)]).
   % Expected: Found function: (^2)(+ 1)
   % Meaning: f(x) = x² + 1

3. Reciprocal Function:
   ?- discover_function([(1, 1), (2, 0.5), (4, 0.25)]).
   % Expected: Found function: (1/x)
   % Meaning: f(x) = 1/x

4. Exponential-like Function:
   ?- discover_function([(1, 1), (2, 4), (3, 9)]).
   % Expected: Found function: (^2)
   % Meaning: f(x) = x²

ADVANCED USAGE:
--------------

5. Testing Custom Data:
   ?- test_custom([(0, 1), (1, 2), (2, 5), (3, 10)]).
   % Tests your own input-output pairs

6. Manual Operation Testing:
   ?- test_operations_manual(5, [binary('+', 3), unary('^2')], 64).
   % Tests: (5 + 3)² = 64

7. Simplification Testing:
   ?- test_simplification([binary('+', 2), binary('+', 3), binary('-', 1)]).
   % Tests: + 2 + 3 - 1 = + 4

8. Raw Function Discovery:
   ?- discover_function_raw([(1, 4), (2, 8)]).
   % Shows unsimplified results

COMPLEX FUNCTIONS:
-----------------

9. Polynomial Functions:
   ?- discover_function([(1, 6), (2, 11), (3, 18)]).
   % May find: x² + 2x + 3

10. Mixed Operations:
    ?- discover_function([(2, 3), (4, 5), (6, 7)]).
    % May find: x/2 + 2

11. Factorial-based:
    ?- discover_function([(3, 7), (4, 25)]).
    % May find: x! + 1

TROUBLESHOOTING:
---------------

12. No Function Found:
    - Try simpler input-output pairs
    - Check if relationship is too complex (>5 operations)
    - Verify input data is correct

13. Unexpected Results:
    - Remember the system finds ANY valid function, not necessarily the simplest
    - Multiple valid functions may exist
    - Use raw discovery to see exact search results

14. Performance Issues:
    - Large depth limits (>5) can be very slow
    - Try with fewer input-output pairs first
    - Consider if the relationship is actually mathematical

LIMITATIONS:
-----------

- Maximum operation depth: 5 (configurable)
- Floating-point precision: 0.0001 tolerance
- Operation set is fixed (but extensible)
- May not find the most intuitive function representation
- Cannot handle truly random or non-mathematical relationships

EXTENDING THE SYSTEM:
--------------------

To add new operations:
1. Add the operation implementation (e.g., cube/2)
2. Add it to do_unary_op/3 or do_op/4
3. Add it to the generation list in generate_operations/2
4. Test with appropriate examples

Example new operation:
cube(X, Result) :- is_numeric(X), Result is X * X * X.
do_unary_op('^3', X, Result) :- cube(X, Result).
% Add '^3' to the member list in generate_operations/2

================================================================================
*/
