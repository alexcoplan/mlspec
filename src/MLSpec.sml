structure MLSpec = struct
	open MLSExpectations; (* these should be accesible to the user, and therefore get imported into the primary namespace *)

	fun test specBlock =
		let val mlTestOutput = ref "\n\n--> MLSpec Test Output <--\n\n"
			fun describe thing descBlock =
			(* the expectBlock is passed to each itBlock as the "expect" method *)
			let val output = ref ""
				val indent = ref 0;
				fun rep (x,0) = ""
				  | rep (x,n) = x ^ (rep (x,n-1))
				fun printIndent str = output := !output ^ (rep(" ",!indent)) ^ str
				fun putsIndent str = printIndent (str ^ "\n")
				fun puts str = output := !output ^ str ^ "\n"
			    fun itter does results =
			    	let val failed = ref false
			    	 	fun summarize [] assertCount = "Pass (" ^ (MLSHelpers.pluralize "assertion" assertCount) ^ ")"
			    		  | summarize (r::rs) assertCount =
			    		 	case r of ExpectationPass => summarize rs (assertCount+1)
			    		 			| (ExpectationFail(msg)) => (failed := true;
			    		 				"Failed on assertion " ^ Int.toString(assertCount + 1) ^ " -> " ^ msg)
			    		val summary = summarize results 0
					in if !failed then
							(putsIndent (does ^ ": ");
							indent := !indent + 4; 
							putsIndent (summarize results 0); 
							indent := !indent - 4)
						else
							(printIndent (does ^ ": "); puts (summarize results 0))
					end
			in (puts (thing ^ ":"); 
				indent := !indent + 2; 
				descBlock(itter); 
				mlTestOutput := !mlTestOutput ^ !output ^ "\n\n")
			end
		in (specBlock(describe); print (!mlTestOutput))
		end;

	fun expect candidate (StaticExpectation(func,msg)) =
		if func candidate then ExpectationPass
		else ExpectationFail(msg)
	  | expect candidate (TypedExpectation(func,msgFunc)) =
	  	if func candidate then ExpectationPass
	  	else ExpectationFail(msgFunc candidate);
end;
