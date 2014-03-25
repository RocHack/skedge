describe Course do
	it "should linkify correctly" do
		Course::Formatter.linkify("CSC", "CSC 171").should == "<a href='/?q=CSC+171'>CSC 171</a>"
		Course::Formatter.linkify("CSC", "171").should == "<a href='/?q=CSC+171'>171</a>"
		Course::Formatter.linkify("CSC", ",CSC 171").should == ",<a href='/?q=CSC+171'>CSC 171</a>"
		Course::Formatter.linkify("CSC", ")CSC 171").should == ")<a href='/?q=CSC+171'>CSC 171</a>"
		Course::Formatter.linkify("REL", "101 or MTH 141").should == "<a href='/?q=REL+101'>101</a> or <a href='/?q=MTH+141'>MTH 141</a>"
	end
end