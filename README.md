# MLSpec

is a lightweight testing library for Standard ML, inspired by [RSpec](http://rspec.info/).

## Usage

MLSpec has only been tested thus far with [Poly/ML](http://www.polyml.org). To use the library, you should call the `PolyML.make` function, like so:

```
PolyML.make "mlspec/src";
```

MLSpec makes use of anonymous functions to act as an analogue of Ruby blocks. This provides a convenient way to write specification-based tests, using a similar style to tests that one would write using RSpec.

The most convenient way to write tests using MLSpec is best seen by example. Suppose we are testing a function, `add`, which simply adds two integers:

```
fun add x y = x + y;

let open MLSpec
in
	test (fn (describe) =>
		describe "add" (fn (it) => (
			it "should say that 2 + 2 is 4" [ expect (add 2 2) (toBeTheInteger 4) ]
		)
	)
end;
```

Tests in MLSpec are structured in three levels. At the outermost level, a testing "block" (a term that will now be used synonymously with anonymous function) is defined, as an argument to the `MLSpec.test` function. It takes a parameter, the name of which is given by the user, but is conventionally `describe`. This argument may then be called (any number of times) with a string and another block as arguments, to form a "describe block". In a describe block, the user (writing the tests) may specify the expected behaviour for a given component of the software in question, such as a function or structure. The first argument to the describe function is a string, detailing the component that the describe block specifies (often just the name of said component). The second is a block that forms the describe block itself, taking an argument which is conventionally named "it".

The reason behind these parameters and their naming conventions is the pseudo-natural-language specification syntax which may be achieved as a result. It is natural to describe a given component by listing the things it should do, for example. Structuring the specification in this way also enables informative and easily-understood feedback in the event that a test fails.

Returning to our syntactic description; within each describe block, a series of calls to the block parameter (conventionally named `it`) are made, detailing the various things that the component should do (or properties which it should possess). The `it` function takes a string (see the example above), and a list of calls to the `expect` and `doNotExpect` fucntions (assertions). The `expect` function takes two (curried) parameters. The first is the "actual", or "obtained" value (normally obtained by a call to or involving the component that is being specified). The second is an expectation. Expectations match properties of values. They are defined in the file `MLSExpectations.sml` and documented below.

The above is perhaps better understood with an example. To that end, an example test suite is given in `example.sml`.

## Expectations

Expectations are matchers within MLSpec tests. They match some "expected" property against "actual" data. Examples are `toBeTrue`, `toThrowAnException`, and `toBeTheInteger 6`.

Expectations are asserted by means of the functions `expect` and `doNotExpect`. These constructs form specifications that are highly readable. Two simple examples of assertions using boolean expectations are `expect true toBeTrue`, or `doNotExpect true toBeFalse`. Many more examples are available in `example.sml`.

The following expectations are currently available:

* Equivalence Expectations *

 - `toBe (value)` : polymorphic equality matcher. use of this expectation is generally not advisable, since it cannot provide useful error messages, since ML does not support polymorphic printing
 - `toBeTrue` : asserts the truth of a boolean value
 - `toBeFalse` : asserts the falsehood of a boolean value
 - `toBeTheInteger i` : asserts equality with the integer i, providing a clear failure message, giving the expected and actual values.
 - `toBeTheIntegerPair x`, `toBeTheIntegerList x`, `toBeTheBooleanList x`, `toBeTheStringList x` : all take a value x and perform equivalence matching, exactly like `toBeTheInteger i` for the type indicated by the name of the function

 * Exception Expectations *
 - `toRaiseAnException` : asserts that a function of type `unit -> 'a` raises an exception
 - `toRaiseTheException e` : asserts that a function of type `unit -> 'a` raises the exception e

_ Note: Contributing expectations (especially equality matchers) to the project at this point is strongly encouraged. _

