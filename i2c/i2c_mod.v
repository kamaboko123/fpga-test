module i2c_if(clk, start_n);

input clk;
input start_n;
reg [7:0] mode_i2c;

always@(posedge clk or negedge start_n) begin
	if (start_n == 0) begin
		mode_i2c = 0;
	end
end

endmodule
