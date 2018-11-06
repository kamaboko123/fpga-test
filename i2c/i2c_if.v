module i2c_if(clk, start_n, mode_i2c, _scl, _sda, _err);

input clk;
input start_n;
reg [6:0] addr = 7'b1110110;
reg [6:0] i2c_addr;
reg rw = 1'b0; // r=0, w=1
output reg _err = 1'b0;
output reg _scl;
inout reg _sda;
output reg [7:0] mode_i2c;
reg [3:0] counter;
reg _ack;

always@(posedge clk or negedge start_n) begin
	if (start_n == 0) begin
		mode_i2c = 0;
	end
	else begin
		case(mode_i2c)
			0:begin
				_scl = 1;
				_sda = 1;
				_err = 0;
				mode_i2c = 4'h1;
				counter = 3'h7;
			end
			1:begin //start condition
				_scl = 1;
				_sda = 0;
				mode_i2c = 4'h2;
				i2c_addr = addr;
			end
			2:begin
				_scl = 0;
				mode_i2c = 4'h3;
			end
			3:begin //set sda
				_sda = (i2c_addr & 7'b1000000) ? 1'b1 : 1'b0;
				i2c_addr = i2c_addr << 1;
				mode_i2c = 4;
			end
			4:begin
				_scl = 1;
				counter = counter - 4'h1;
				if(counter == 0) mode_i2c = 5;
				else mode_i2c = 2;
			end
			5:begin //send r/w flag
				_scl = 0;
				mode_i2c = 6;
			end
			6:begin
				_sda = rw;
				mode_i2c = 7;
			end
			7:begin
				_scl = 1;
				mode_i2c = 8;
			end
			8:begin
				_scl = 0;
				mode_i2c = 9;
			end
			9: begin //wait ack (switch sda to hi-z)
				_sda = 1'bz;
				mode_i2c = 10;
			end
			10: begin
				_scl = 1;
				mode_i2c = 11;
			end
			11: begin
				_ack = _sda;
				if(_ack == 1) begin
					mode_i2c = 27;
				end
			end
			
			
			
			27:begin
				_err = 1'b1;
				mode_i2c = 28;
			end
			28:begin //stop condition
				_scl = 0;
				mode_i2c = 29;
			end
			29:begin //stop condition
				_sda = 0;
				mode_i2c = 30;
			end

			30: begin
				_scl = 1;
				mode_i2c = 31;
			end
			31:begin
				_sda = 1;
				mode_i2c = 32;
			end
			32:begin// idle mode
				_scl = 1;
				_sda = 1;
				mode_i2c = 33;
			end
		endcase
	end			
end

endmodule
