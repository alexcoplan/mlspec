(* this example demonstrates using MLSpec to test a custom datatype, using the Constructors API *)

datatype ''a tree = Leaf | Branch of ''a * ''a tree * ''a tree;

(* this function prints a tree, making the structure clear *)
fun treeStringer s Leaf = ""
  | treeStringer s (Branch(v,l,r)) =
  	let val lStr = treeStringer s l
  		val rStr = treeStringer s r
  	in
  		if lStr = "" andalso rStr = "" then s v
  		else (s v) ^ " -> (" ^ lStr ^ " | " ^ rStr ^ ")"
  	end;

val t1 = Branch(4, Branch(2, Leaf, Leaf), Branch(6, Leaf, Leaf));
val t2 = Branch(5, Branch(3, Leaf, Leaf), Leaf);

fun even n = (n mod 2) = 0;

(* this function sums a tree of integers *)
fun treeSum Leaf = 0
  | treeSum (Branch(v,l,r)) = v + (treeSum l) + (treeSum r);

(* this predicate tests whether a tree has all even integers: *)
fun evenTree Leaf = true
  | evenTree (Branch(v,l,r)) = (even v) andalso (evenTree l) andalso (evenTree r);

let open MLSpec
	val toBeTheIntTree = Constructors.expectEquality (treeStringer Int.toString)
	val toOnlyContainEvenIntegers = Constructors.staticPredicateMatch evenTree "Tree contains an odd integer" "Tree contains an even integer";

	fun treeSumFailure i t eq = 
		if eq then "Expected the sum of the tree not to be " ^ (Int.toString i) ^ ", but it was exactly that"
		else "Expected the sum of the tree to be " ^ (Int.toString i) ^ ", but it was " ^ (Int.toString (treeSum t));

	fun toSumToTheInteger i = Constructors.dynamicPredicateMatch (fn t => (treeSum t) = i)  (treeSumFailure i)
in
	test(fn (describe) => (
		describe "MLSpec" (fn (it) => (
			it "should say that t1 is equal to itself" [ expect t1 (toBeTheIntTree t1) ];
			it "should say that t1 is not equal to t2" [ doNotExpect t1 (toBeTheIntTree t2) ];
			it "should fail when expecting t1 to be t2" [ expect t1 (toBeTheIntTree t2) ];
			it "should say that t1 is an even tree" [ expect t1 toOnlyContainEvenIntegers ];
			it "should say that t2 is not an even tree" [ doNotExpect t2 toOnlyContainEvenIntegers ];
			it "should fail when expecting t1 to sum to 20" [ expect t1 (toSumToTheInteger 20) ];
			it "should say that t2 sums to 8" [ expect t2 (toSumToTheInteger 8) ]
		))
	))
end