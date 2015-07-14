(* this is a suite of example tests which demonstrate some of the various expectations in MLSpec *)

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
exception Olive;

fun bomb 0 = 1
  | bomb 1 = raise Cheese
  | bomb 2 = raise Olive
  | bomb n = n;

let
	open MLSpec
in
	test (fn (describe) => (
		describe "MLSpec (general)" (fn (it) => (
			it "should say true is true" [ expect true toBeTrue ];
			it "should say false is false" [ expect false toBeFalse ];
			it "should say that 3 = 3 (using a primitive expectation)" [ expect 3 (toBe 3) ];
			it "should say that 3 does not equal 2" [ doNotExpect 3 (toBeTheInteger 2) ];
			it "should say that 2 + 2 = 4" [ expect (2+2) (toBeTheInteger 4) ]
		))

		describe "bomb (exception tester)" (fn (it) => (
			it "should not blow up for 0" [ doNotExpect (fn () => bomb 0) toRaiseAnException ];
			it "should raise an exception for 1" [ expect (fn () => bomb 1) toRaiseAnException ];
			it "should raise Cheese for 1" [ expect (fn () => bomb 1) (toRaiseTheException Cheese) ];
			it "should not raise Cheese for 2" [ doNotExpect (fn () => bomb 2) (toRaiseTheException Cheese) ];
			it "should not raise Olive for 3" [ doNotExpect (fn () => bomb 3) (toRaiseTheException Olive) ];
			it "should raise Olive for 2" [ expect (fn () => bomb 2) (toRaiseTheException Olive) ]
		));

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

		(* used for testing failure messages in MLSpec (clearly, many of these intentionally fail)...

		describe "MLSpec (exceptions)" (fn (it) => (
			it "should blow up for 0" [ expect (fn () => bomb 0) toRaiseAnException ];
			it "should not blow up for 0" [ doNotExpect (fn () => bomb 0) toRaiseAnException ];
			it "should blow up for 1" [ expect (fn () => bomb 1) toRaiseAnException ];
			it "should not blow up for 1" [ doNotExpect (fn () => bomb 1) toRaiseAnException ];

			it "should raise Cheese for 0" [ expect (fn () => bomb 0) (toRaiseTheException Cheese) ];
			it "should not raise Cheese for 0" [ doNotExpect (fn () => bomb 0) (toRaiseTheException Cheese) ];
			it "should raise Cheese for 1" [ expect (fn () => bomb 1) (toRaiseTheException Cheese) ];
			it "should not raise Cheese for 1" [ doNotExpect (fn () => bomb 1) (toRaiseTheException Cheese) ];
			it "should raise Cheese for 2" [ expect (fn () => bomb 2) (toRaiseTheException Cheese) ];
			it "should not raise Cheese for 2" [ doNotExpect (fn () => bomb 2) (toRaiseTheException Cheese) ]
		));

		*)
	))
end;
