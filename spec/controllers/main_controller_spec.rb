describe MainController do
	before(:all) do
		@ctl = MainController.new
	end

	it "should do queries correctly" do
		@ctl.params_from_query("173").should == {number:/173.*/, latest:1}
		@ctl.params_from_query("csc").should == {dept:"CSC", latest:1}
		@ctl.params_from_query("programming").should == {title:/.*programming.*/i, latest:1}
		@ctl.params_from_query("csc 173").should == {dept:"CSC", number:/173.*/, latest:1}
		@ctl.params_from_query("csc 173 programming").should == {title:/.*csc 173 programming.*/i, latest:1}
		@ctl.params_from_query("programming 173").should == {title:/.*programming 173.*/i, latest:1}
		@ctl.params_from_query("programming 173 instructor:brown").should == {title:/.*programming 173.*/i, 'sections.instructors' => /.*brown.*/i, latest:1}
		@ctl.params_from_query("programming 173 term:fall").should == {title:/.*programming 173.*/i, term:0}

		#random queries, should include latest even with term, so you don't get old random courses
		@ctl.params_from_query("", 0,0,0,true).should == {latest:1}
		@ctl.params_from_query("", 0,1,0,true).should == {latest:1, term:0}

		@ctl.params_from_query("programming", 0, 1).should == {title:/.*programming.*/i, term:0}
	end
end