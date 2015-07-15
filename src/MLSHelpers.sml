structure MLSHelpers = 
struct
	(* general helper functions *)

	fun pluralForm "pass" = "passes"
	  | pluralForm noun = noun ^ "s";

	fun pluralize noun n = if n = 1 then "1 " ^ noun else Int.toString(n) ^ " " ^ pluralForm noun;

	fun rep (x,0) = ""
	  | rep (x,n) = x ^ (rep (x,n-1))

	(* test-related helpers *)

	fun testSummary (pass,fail) =
		let val message =
			if fail = 0 then "All " ^ (pluralize "test" pass) ^ " passed"
			else (pluralize "pass" pass) ^ ", " ^ (pluralize "fail" fail)
		in "--> Summary: " ^ message ^ " <--"
		end; 

	(* handleResults: process the results of running a suite of tests, and interpret user configuration
	 *
	 * n.b: the output file (if to be created) starts with a summary line, with the format "errors,passes,fails"
	 * it may then be proceeded by a breakdown (depending on user config) *)
	fun handleResults (output, passes, fails, config) =
		let val (disp, write, breakdown, path) = config
		in
			(if disp then print (output ^ (testSummary (passes, fails)) ^ "\n\n") else ();
			 if write then 
			 	let val outs = TextIO.openOut path
			 		val summaryLine = "0," ^ (Int.toString passes) ^ "," ^ (Int.toString fails) 
			 	in
			 		(TextIO.output(outs, summaryLine ^ (if breakdown then output else ""));
			 		 TextIO.closeOut(outs))
			 	end
			 else ()) handle (e as Io) => print ("I/O Error, writing to path: " ^ path ^ "\n I/O Exception: " ^ (exnMessage e))
		end;

	(* expectation-related helpers *)

	fun exceptionsEqual (a,b) = ((exnName a) = (exnName b)) andalso ((exnMessage a) = (exnMessage b));

	(* stringers *)

	fun listStringer stringer lst =
		let fun csList [] = ""
			  | csList [x] = stringer x
			  | csList (x::xs) = (stringer x) ^ "," ^ (csList xs)
		in "[" ^ (csList lst) ^ "]"
		end;


	val intStringer = Int.toString;
	fun boolStringer x = if x then "true" else "false";
	fun stringStringer x = "\"" ^ x ^ "\"";

	(* 1D lists *)
	val intListStringer = listStringer intStringer;
	val boolListStringer = listStringer boolStringer;
	val stringListStringer = listStringer stringStringer;

	(* 2D lists *)
	val intListListStringer = listStringer (listStringer intStringer);
	val boolListListStringer = listStringer (listStringer boolStringer);
	val stringListListStringer = listStringer (listStringer stringStringer);

	(* tuple stringers (s is a stringer) *)
	fun pairStringer s (a,b) = "(" ^ (s a) ^ "," ^ (s b) ^ ")";
	fun tripleStringer s (a,b,c) = "(" ^ (s a) ^ "," ^ (s b) ^ "," ^ (s c) ^ ")";
	fun fourTupleStringer s (a,b,c,d) = "(" ^ (s a) ^ "," ^ (s b) ^ "," ^ (s c) ^ "," ^ (s d) ^ ")";
	fun dualTypePairStringer s1 s2 (a,b) = "(" ^ (s1 a) ^ "," ^ (s2 b) ^ ")"

	(* homogeneous pairs *)
	val intPairStringer = pairStringer intStringer;
	val boolPairStringer = pairStringer boolStringer;
	val stringPairStringer = pairStringer stringStringer;

	(* mixed pairs *)
	val intBoolPairStringer = dualTypePairStringer intStringer boolStringer;
	val intStringPairStringer = dualTypePairStringer intStringer stringStringer;
	val boolIntPairStringer = dualTypePairStringer boolStringer intStringer;
	val boolStringPairStringer = dualTypePairStringer boolStringer stringStringer;
	val stringBoolPairStringer = dualTypePairStringer stringStringer boolStringer;
	val stringIntPairStringer = dualTypePairStringer stringStringer intStringer;

	(* homogeneous triples *)
	val intTripleStringer = tripleStringer intStringer;
	val boolTripleStringer = tripleStringer boolStringer;
	val stringTripleStringer = tripleStringer stringStringer;

	(* homogeneous 4-tuples *)
	val int4TupleStringer = fourTupleStringer intStringer;
	val bool4TupleStringer = fourTupleStringer boolStringer;
	val string4TupleStringer = fourTupleStringer stringStringer
end