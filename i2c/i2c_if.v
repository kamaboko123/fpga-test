module i2c_if(clk, start_n, mode_i2c, _scl, _sda, _err, i2c_recv_data);

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

reg [7:0] reg_addr = 8'hfa;
reg [7:0] i2c_data;

output reg[7:0] i2c_recv_data;

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
				mode_i2c = 1;
				counter = 3'h7;
				i2c_recv_data = 8'h0;
			end
			1:begin //start condition
				_scl = 1;
				_sda = 0;
				mode_i2c = 4'h2;
				i2c_addr = addr;
			end
			2:begin
				_scl = 0;
				mode_i2c = 3;
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
			9:begin //wait ack (switch sda to hi-z)
				_sda = 1'bz;
				mode_i2c = 10;
			end
			10:begin
				_scl = 1;
				mode_i2c = 11;
			end
			11:begin
				_ack = _sda;
				if(_ack == 1) begin
					//error
					_err = 1'b1;
					mode_i2c = 100;
				end
				
				else begin
					//data_send
					mode_i2c = 12;
					counter = 8;
					i2c_data = reg_addr;				
				end
			end
			
			12:begin
				_scl = 0;
				mode_i2c = 13;
			end
			13:begin
				_sda = (i2c_data & 8'b10000000) ? 1'b1 : 1'b0;
				i2c_data = i2c_data << 1;
				mode_i2c = 14;
			end
			14:begin
				_scl = 1;
				counter = counter - 4'h1;
				
				if(counter == 0) begin
					mode_i2c = 15; // end to send data
				end
				else begin
					mode_i2c = 12;
				end
			end			
			15:begin
				_scl = 0;
				mode_i2c = 16;
			end
			16:begin //receive ack
				_sda = 1'bz;
				mode_i2c = 17;
			end
			17: begin
				_ack = _sda;
				if(_sda == 1) begin
					_err = 1;
					mode_i2c = 100;
				end
				else begin
					mode_i2c = 18;
				end
			end
			
			
			18:begin //start condition (start to read)
				_scl = 1;
				_sda = 0;
				mode_i2c = 19;
				i2c_addr = addr;
				counter = 7;
			end
			19:begin
				_scl = 0;
				mode_i2c = 20;
			end
			20:begin //set sda
				_sda = (i2c_addr & 7'b1000000) ? 1'b1 : 1'b0;
				i2c_addr = i2c_addr << 1;
				mode_i2c = 21;
			end
			21:begin
				_scl = 1;
				counter = counter - 4'h1;
				if(counter == 0) mode_i2c = 22;
				else mode_i2c = 19;
			end
			22:begin //send r/w flag
				_scl = 0;
				mode_i2c = 23;
			end
			23:begin
				_sda = 1; //read
				mode_i2c = 24;
			end
			24:begin
				_scl = 1;
				mode_i2c = 25;
			end
			25:begin
				_scl = 0;
				mode_i2c = 26;
			end
			26:begin //wait ack (switch sda to hi-z)
				_sda = 1'bz;
				mode_i2c = 27;
			end
			27:begin
				_scl = 1;
				mode_i2c = 28;
			end
			28:begin
				_ack = _sda;
				if(_ack == 1) begin
					//error
					_err = 1'b1;
					mode_i2c = 100;
				end
				
				else begin
					//data_receive
					mode_i2c = 29;
					counter = 8;
					i2c_recv_data = 8'h0;				
				end
			end
			
			29:begin
				_sda = 1'bz;
				_scl = 0;
				mode_i2c = 30;
			end
			
			30:begin
				_scl = 1;
				mode_i2c = 31;
			end
			
			31:begin
				counter = counter - 4'h1;
				if(counter == 0) mode_i2c = 32;
				else begin
					i2c_recv_data = i2c_recv_data | (_sda << counter);
					mode_i2c = 29;
				end
			end
			
			32:begin //nak
				_scl = 0;
				mode_i2c = 33;
			end
			33:begin
				_sda = 1;
				mode_i2c = 34;
			end
			34:begin
				_scl = 1;
				mode_i2c = 100;
			end
			
			100:begin
				mode_i2c = 101;
			end
			101:begin //stop condition
				_scl = 0;
				mode_i2c = 102;
			end
			102:begin
				_sda = 0;
				mode_i2c = 103;
			end

			103: begin
				_scl = 1;
				mode_i2c = 104;
			end
			104:begin
				_sda = 1;
				mode_i2c = 105;
			end
			105:begin// idle mode
				_scl = 1;
				_sda = 1;
				mode_i2c = 106;
			end
		endcase
	end			
end

endmodule
