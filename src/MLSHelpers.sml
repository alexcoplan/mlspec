structure MLSHelpers = 
struct
	fun pluralize thing n = if n = 1 then "1 " ^ thing else Int.toString(n) ^ " " ^ thing ^ "s";

	fun exceptionsEqual (a,b) = ((exnName a) = (exnName b)) andalso ((exnMessage a) = (exnMessage b));

	fun listStringer stringer lst =
		let fun csList [] = ""
			  | csList [x] = stringer x
			  | csList (x::xs) = (stringer x) ^ "," ^ (csList xs)
		in "[" ^ (csList lst) ^ "]"
		end;

	val intStringer = Int.toString;
	fun boolStringer x = if x then "true" else "false";
	fun stringStringer x = "\"" ^ x ^ "\"";

	val intListStringer = listStringer intStringer
	val boolListStringer = listStringer boolStringer
	val stringListStringer = listStringer stringStringer

	fun pairStringer stringer (a,b) = "(" ^ (stringer a) ^ "," ^ (stringer b) ^ ")";

	val intPairStringer = pairStringer intStringer;
end