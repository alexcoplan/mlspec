(* MLSExpectations
 *
 * This structure defines all the expectations (matches) that can be used within mlspec. *)
structure MLSExpectations = struct
	datatype 'a expectation = 
		StaticExpectation of ('a -> bool) * string * string (* static failure message, for general or boolean equality etc. *)
	  | TypedExpectation of ('a -> bool) * ('a -> bool -> string); (* for typed expectations with a dynamic failure message  *)

	datatype mlsResult = ExpectationPass
					   | ExpectationFail of string;

	local (* these functions construct failure messages for various expectations
		   * however, we don't want to expose them to the primary namespace *)

		(* this generates an equality failure message function. 
		 * the argument is a stringer for the given type *)
		fun equalityFailure stringer x x' eq = 
			if eq then "Expected not to get " ^ (stringer x) ^ ", but got exactly that"
			else "Expected " ^ (stringer x) ^ ", but got " ^ (stringer x');

		(* each of the dynamic equality matchers has the same test, but a different failure message
		 * this function contains the base functionality *)
		fun expectEquality stringer x = TypedExpectation((fn x' => x = x'), (equalityFailure stringer) x);

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

		(* dynamic equality matchers *)
		val toBeTheInteger     = expectEquality (MLSHelpers.intStringer);
		val toBeTheIntegerPair = expectEquality (MLSHelpers.intPairStringer);
		val toBeTheIntegerList = expectEquality (MLSHelpers.intListStringer);
		val toBeTheBooleanList = expectEquality (MLSHelpers.boolListStringer);
		val toBeTheStringList  = expectEquality (MLSHelpers.stringListStringer);

		(* expectations concerning exceptions *)
		val toRaiseAnException = TypedExpectation((fn f => (f(); false) handle _ => true), exceptionFailure);
		fun toRaiseTheException e = TypedExpectation((fn f => (f(); false) handle (e' as _) => MLSHelpers.exceptionsEqual(e,e')),
			expectedException e);

	end;
end