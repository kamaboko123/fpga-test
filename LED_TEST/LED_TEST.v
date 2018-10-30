module LED_TEST(CLK, led);
	input CLK;
	output led;
	
	reg [24:0] c = 24'b0;
	reg [1:0] flg = 1'b0;
	
	assign led = flg;
	
	always @(posedge CLK) begin
		c <= c + 1;
		if(c == 24'b111111111111111111111111) begin
			c <= 0;
			flg = ~flg;
		end
	end
	
endmodule