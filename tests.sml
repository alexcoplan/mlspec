fun digitBad i = chr(i + ord #"0"); (* not very safe *)
fun digitGood i = String.sub("0123456789", i); (* safer *)

fun includes [] y = false
  | includes (x::xs) y = x=y orelse includes xs y

fun dateValid d m = d > 0 andalso
	if includes ["September","April","June","November"] m
	then d <= 30
	else if m = "February" then d <= 28 (* assume not leap year *)
	else d <= 31 andalso includes ["January","March","May","July","August","October","December"] m;

exception Cheese;

fun bomb 0 = 1
  | bomb 1 = raise Cheese
  | bomb n = n;

let
	open MLSpec
in
	test (fn (describe) => (
		describe "dateValid" (fn (it) => 
			let val months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
			fun expectCommonDaysValid [] n = []
			  | expectCommonDaysValid (m::ms) 0 = expectCommonDaysValid ms 28
			  | expectCommonDaysValid (m::ms) n = (expect (dateValid n m) toBeTrue) :: expectCommonDaysValid (m::ms) (n-1)
			in (

			it "should accept the 31st but not the 32nd of October" [
				expect (dateValid 31 "October") toBeTrue,
				expect (dateValid 32 "October") toBeFalse
			];

			it "should accept the days 1-28 for every month" (expectCommonDaysValid months 28)

			) end
		);

		describe "bomb (exception tester)" (fn (it) => (
			it "should not blow up for 0" [ expect (fn () => bomb 0) notToRaiseAnException ];
			it "should raise an exception for 1" [ expect (fn () => bomb 1) toRaiseAnException ];
			it "should raise Cheese for 1" [ expect (fn () => bomb 1) (toRaiseTheException Cheese) ]
		));

		describe "MLSpec" (fn (it) => (
			it "should say true is true" [ expect true toBeTrue ];
			it "should say false is false" [ expect false toBeFalse ];
			it "should say that 3 = 3" [ expect 3 (toBe 3) ];
			it "should say that 3 does not equal 2" [ expect 3 (toBeTheInteger 2) ] (* necessary for detailed failure reasons *)
		))
	))
end;
