module i2c(clk, sw, led_7seg0, led_7seg1,led, scl, sda);
	input clk;
	input sw;
	output [6:0] led_7seg0;
	output [6:0] led_7seg1;
	output [2:0] led;
	output scl;
	inout sda;
	
	wire [7:0] mode;

	reg clk_i2c = 0;
	
	// 50MHz / 100KHz / 2 = 250(0xFA)
	reg [23:0] i2c_clk_count = 0;
	
	assign led[0] = scl;
	assign led[1] = sda;
	
	
	dec7seg out7seg_0(
		.data(mode[3:0]),
		.LED(led_7seg0)
	);
	
	dec7seg out7seg_1(
		.data(mode[7:4]),
		.LED(led_7seg1)
	);
	
	i2c_if i2c_test(
		.clk(clk_i2c),
		.start_n(sw),
		.mode_i2c(mode),
		._scl(scl),
		._sda(sda),
		._err(led[2])
	);
	
	always @(posedge clk)
	begin
		i2c_clk_count = i2c_clk_count + 8'h1;		
		
		if(i2c_clk_count == 24'hfa) begin
		//if(i2c_clk_count == 24'hffffff) begin
			i2c_clk_count = 24'h0;
			clk_i2c <= ~clk_i2c;
		end
		/*
		if(i2c_clk_count == 8'hfa) begin
			i2c_clk_count = 8'h0;
			clk_i2c <= ~clk_i2c;
		end
		*/
		
	end	
endmodule
