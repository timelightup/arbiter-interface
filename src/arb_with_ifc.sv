module arb_with_ifc (arb_if.DUT arbif);
	always @(posedge arbif.clk or posedge arbif.rst) begin
		if (arbif.rst)
			arbif.grant <= '0;
		else if (arbif.request[0])
			arbif.grant <= 2'b01;
		else if (arbif.request[1])
			arbif.grant <= 2'b10;
		else
			arbif.grant <= '0;
	end
endmodule