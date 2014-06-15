describe MainController do
	before(:all) do
		@ctl = MainController.new
	end

	it "should do queries correctly" do
		@ctl.params_from_query("173").should == {number:/^173/i}
		@ctl.params_from_query("csc").should == {dept:"CSC"}
		@ctl.params_from_query("programming").should == {title:/programming/i}
		@ctl.params_from_query("csc 173").should == {dept:"CSC", number:/^173/i}
		@ctl.params_from_query("csc 173 programming").should == {title:/csc 173 programming/i}
		@ctl.params_from_query("programming 173").should == {title:/programming 173/i}
		@ctl.params_from_query("programming 173 instructor:brown").should == {title:/programming 173/i, 'sections.instructors' => /brown/i}
		@ctl.params_from_query("programming 173 term:fall").should == {title:/programming 173/i, term:0}
		@ctl.params_from_query("programming 173 term:fall crn:1234").should == {title:/programming 173/i, term:0, crn:1234}

		#random queries, should include latest even with term, so you don't get old random courses
		#@ctl.params_from_query("", 0,0,0,true).should == {latest:1}
		#@ctl.params_from_query("", 0,1,0,true).should == {latest:1, term:0}

		@ctl.params_from_query("programming", 0, 1).should == {title:/programming/i, term:0}
	end
end