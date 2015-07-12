structure MLSpec = struct
	open MLSExpectations; (* these should be accesible to the user, and therefore get imported into the primary namespace *)

	(* user-configurable *)
	structure Config = struct
		val printResults = ref true; (* whether or not to print results to the console *)
		val createResultsFile = ref false; (* whether or not to create a file detailing the reuslts of the tests *)
		val includeBreakdown = ref false; (* whether or not to include the breakdown in this results file *)
		val outputPath = ref ""; (* where to write the output results to *)

		(* convenient function to configure an output file to write to 
		 * note that this function also disables output to the console *)
		fun writeToFile str = (createResultsFile := true; printResults := false; outputPath := str);

		fun enableBreakdown () = includeBreakdown := true;
		fun disableBreakdown () = includeBreakdown := false;

		(* convenient way of passing config to the helper function *)
		fun getConfigTuple () = (!printResults, !createResultsFile, !includeBreakdown, !outputPath);
	end

	fun test specBlock =
		let val mlTestOutput = ref "\n--> MLSpec Test Output <--\n\n"
			val fails = ref 0;
			val passes = ref 0;

			fun describe thing descBlock =

			let val output = ref ""
				val indent = ref 0;

				fun printIndent str = output := !output ^ (MLSHelpers.rep(" ",!indent)) ^ str
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
							fails := !fails + 1;
							indent := !indent - 4)
						else
							(printIndent (does ^ ": ");
							passes := !passes + 1;
							puts (summarize results 0))
					end
			in (puts (thing ^ ":"); 
				indent := !indent + 2; 
				descBlock(itter); 
				mlTestOutput := !mlTestOutput ^ !output ^ "\n")			
			end
		in (specBlock(describe); 
			MLSHelpers.handleResults(!mlTestOutput, !passes, !fails, Config.getConfigTuple () ))
		end;

	fun expect candidate (StaticExpectation(func,msg)) =
		if func candidate then ExpectationPass
		else ExpectationFail(msg)
	  | expect candidate (TypedExpectation(func,msgFunc)) =
	  	if func candidate then ExpectationPass
	  	else ExpectationFail(msgFunc candidate);
end;
