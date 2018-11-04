module dec7seg(data, LED);
	input [4:0] data;
	output reg [6:0] LED;

	always @(data) begin
		case (data)
			4'h0:	LED = 7'b1000000;
			4'h1:	LED = 7'b1111001;
			4'h2:	LED = 7'b0100100;
			4'h3:	LED = 7'b0110000;
			4'h4:	LED = 7'b0011001;
			4'h5:	LED = 7'b0010010;
			4'h6:	LED = 7'b0000010;
			4'h7:	LED = 7'b1111000;
			4'h8:	LED = 7'b0000000;
			4'h9:	LED = 7'b0010000;
			4'ha:	LED = 7'b0001000;
			4'hb:	LED = 7'b0000011;
			4'hc:	LED = 7'b1000110;
			4'hd:	LED = 7'b0100001;
			4'he:	LED = 7'b0000110;
			4'hf:	LED = 7'b0001110;
			default: LED = 7'b1111111;
		endcase
	end
	
endmodule
