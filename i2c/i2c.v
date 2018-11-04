module i2c(sw, led, clk);
	input sw;
	input clk;

	output [6:0] led;
	reg [3:0] data = 0;
	
	reg [23:0] counter = 0;
	
	dec7seg(
		data,
		led
	);
	
	always @(posedge clk)
	begin
		counter = counter + 1;
		if(counter	== 24'hffffff) begin
			data = data + 1;
		end
	end
	
endmodule
