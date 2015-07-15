(* MLSExpectations
 *
 * This structure defines all the expectations (matches) that can be used within mlspec. *)
structure MLSExpectations = struct
	datatype 'a expectation = 
		StaticExpectation of ('a -> bool) * string * string (* static failure message, for general or boolean equality etc. *)
	  | TypedExpectation of ('a -> bool) * ('a -> bool -> string); (* for typed expectations with a dynamic failure message  *)

	datatype mlsResult = ExpectationPass
					   | ExpectationFail of string;

	local
		(* this is a helper to generate an equality failure message function. the argument is a stringer for the given type *)
		fun equalityFailure stringer x x' eq = 
			if eq then "Expected not to get " ^ (stringer x) ^ ", but got exactly that"
			else "Expected " ^ (stringer x) ^ ", but got " ^ (stringer x');
	in

		(* this structure provides an API for users to create their own expectations *)
		structure Constructors = struct
			(* use expectEquality to create an expectation that checks for equality (works on all equality types)
			 * the stringer argument should be of type (alpha -> string), where alpha is the type being matched *)
			fun expectEquality stringer x = TypedExpectation((fn x' => x = x'), (equalityFailure stringer) x);

			(* use staticPredicateMatch to create an expectation that checks if a predicate is matched,
			 * giving a static error message (independent of test data) in case of failure *)
			fun staticPredicateMatch p failureMessage negatedFailureMessage = StaticExpectation(p, failureMessage, negatedFailureMessage);

			(* use dynamicPredicateMatch to create an expectation that checks if a predicate is matched,
			 * generating a dynamic failure message. the failure message function should have two curried arguments:
			 * the "actual" value (of a given type), and a boolean, which will be set to the value of the predicate
			 * this is useful, since if the predicate value is true, yet the failure message funciton is called,
			 * we know that the expectation must have been negated (using doNotExpect) and failed (since the predicate was satisfied)
			 *
			 * see datatype definition of expectations (above) and the expect and doNotExpect functions (in MLSpec.sml) *)
			fun dynamicPredicateMatch p failureMessageFunc = TypedExpectation(p, failureMessageFunc);

		end

	end

	local open Constructors 
	    (* these functions construct failure messages for various built-in expectations
		 * however, we don't want to expose them to the primary namespace *)

		val eq = expectEquality; (* for brevity *)

		(* these helpers are just for cosntructing and binding equality expectations with minimal boilerplate code *)
		fun equalityPair (a,b) = (eq a, eq b);
		fun equalityTriple (a,b,c) = (eq a, eq b, eq c);
		fun equality6Tuple (a,b,c,d,e,f) = (eq a, eq b, eq c, eq d, eq e, eq f);

		fun exceptionFailure f t = (f(); "Expected an exception to be raised, but one was not")
			handle (e as _) => "Expected no exception, but " ^ (exnName e) ^ " was raised, with message " ^ (exnMessage e);

		fun expectedException e f eq = (f(); "Expected exception " ^ (exnName e) ^ ", but no exception was raised")
			handle (e' as _) =>
			  if eq then
			  	"Did not expect the exception " ^ (exnName e) ^ ", but this exception was raised with message " ^ (exnMessage e)
			  else "Expected exception " ^ (exnName e) ^ ", but exception " ^ (exnName e') ^ " was raised";

	in (* expectations below *)

		(* toBe: general equality, cannot give a specific error message because the type is unknown
		 * and ML does not have polymorphic printing *)
		fun toBe value = StaticExpectation((fn (x) => (x = value)), "Expected one thing, got another", "Did not expect one thing, but got that thing");
		val toBeTrue   = StaticExpectation((fn (x) => x), "Expected true, got false", "Expected false, got true");
		val toBeFalse  = StaticExpectation((fn (x) => not(x)), "Expected false, got true", "Expected true, got false");

		(* simple polymorphic predicate expression (again, unhelpful error messages) *)
		fun toMatchThePredicate p = StaticExpectation (p, "Predicate was not satisfied", "Expected predicate not to be satisfied, but it was");

		local open MLSHelpers (* these expectations match equality for common combinations of built-in types *)
		in
			(* simple types *)
			val (toBeTheInteger, toBeTheString) = equalityPair (intStringer, stringStringer);

			(* homogeneous pairs *) 
			val (toBeTheIntegerPair, toBeTheStringPair, toBeTheBooleanPair) = equalityTriple (intPairStringer, stringPairStringer, boolPairStringer);
			
			(* homogeneous triples *)
			val (toBeTheIntegerTriple, toBeTheStringTriple, toBeTheBooleanTriple) = equalityTriple (intTripleStringer, stringTripleStringer, boolTripleStringer);

			(* homogeneous 4-tuples *)
			val (toBeTheIntegerFourTuple, toBeTheStringFourTuple, toBeTheBooleanFourTuple) = equalityTriple (int4TupleStringer, string4TupleStringer, bool4TupleStringer);

			(* mixed pairs *)
			val (toBeTheIntegerBooleanPair, toBeTheIntegerStringPair, toBeTheStringIntegerPair, toBeTheStringBooleanPair, toBeTheBooleanIntegerPair, toBeTheBooleanStringPair) =
				equality6Tuple (intBoolPairStringer, intStringPairStringer, stringIntPairStringer, stringBoolPairStringer, boolIntPairStringer, boolStringPairStringer);

			(* lists of simple types *)
			val (toBeTheIntegerList, toBeTheBooleanList, toBeTheStringList) = equalityTriple (intListStringer, boolListStringer, stringListStringer);

			(* 2D lists of simple types *)
			val (toBeTheIntegerListList, toBeTheBooleanListList, toBeTheStringListList) =
				equalityTriple (intListListStringer, boolListListStringer, stringListListStringer);
		end

		(* expectations concerning exceptions *)
		val toRaiseAnException = TypedExpectation((fn f => (f(); false) handle _ => true), exceptionFailure);
		fun toRaiseTheException e = TypedExpectation((fn f => (f(); false) handle (e' as _) => MLSHelpers.exceptionsEqual(e,e')), 
			expectedException e);

	end;
end