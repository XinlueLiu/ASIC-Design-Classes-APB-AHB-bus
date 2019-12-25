// $Id: $
// File name:   controller.sv
// Created:     10/5/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: controller

module controller
(
	input wire clk,
	input wire n_rst,
	input wire dr,
	input wire lc,
	input wire overflow,
	output reg cnt_up,
	output reg clear,
	output reg modwait,
	output reg [2:0] op,
	output reg [3:0] src1,
	output reg [3:0] src2,
	output reg [3:0] dest,
	output reg err
);

typedef enum bit [6:0] {IDLE, STOREC1, WAIT1, STOREC2, WAIT2, STOREC3, WAIT3, STOREC4,
			STORED1, ZERO, SORT1, SORT2, SORT3, SORT4, MUL1, ADD1, MUL2, SUB1, MUL3, ADD2,
			MUL4, SUB2, EIDLE} stateType;

reg [6:0] STATE;
reg [6:0] NXT_STATE;
//reg next_modwait;

always_ff @ (negedge n_rst, posedge clk)
	begin: REG_LOGIC
	if(!n_rst) begin
		STATE <= IDLE;
		//modwait <= 0;
	end else begin
		//modwait <= next_modwait;
		STATE <= NXT_STATE;
	end
end

always_comb
	begin: NXT_LOGIC
	NXT_STATE = STATE;
	//next_modwait = 0;
	case(STATE)
	IDLE: begin
		if (dr == 1) begin
			NXT_STATE = STORED1;
		end else if (lc == 1) begin
			NXT_STATE = STOREC1;
		end else begin
			NXT_STATE = IDLE;
		end
		end
	STOREC1: begin
			//next_modwait = 1;
			NXT_STATE = WAIT1;
		end
	WAIT1: 	begin
		if (lc == 1)
			NXT_STATE = STOREC2;
		else
			NXT_STATE = WAIT1;
		end
	STOREC2: begin
			//next_modwait = 1;
			NXT_STATE = WAIT2;
		end
	WAIT2: 	begin
		if (lc == 1)
			NXT_STATE = STOREC3;
		else
			NXT_STATE = WAIT2;
		end
	STOREC3: begin
			//next_modwait = 1;
			NXT_STATE = WAIT3;
		end
	WAIT3: begin
		if (lc == 1)
			NXT_STATE = STOREC4;
		else
			NXT_STATE = WAIT3;
		end
	STOREC4: begin
			//next_modwait = 1;
			NXT_STATE = IDLE;
		end
	STORED1: begin
		//next_modwait = 1;
		if (dr == 0)
			NXT_STATE = EIDLE;
		else
			NXT_STATE = ZERO;
		end
	ZERO: 	begin
			//next_modwait = 1;
			NXT_STATE = SORT1;
		end
	SORT1: 	begin
			//next_modwait = 1;
			NXT_STATE = SORT2;
		end
	SORT2:	begin
			//next_modwait = 1;
			NXT_STATE = SORT3;
		end
	SORT3: begin
			//next_modwait = 1;
			NXT_STATE = SORT4;
		end
	SORT4: begin
			//next_modwait = 1;
			NXT_STATE = MUL1;
		end
	MUL1: begin
			//next_modwait = 1;
			NXT_STATE = ADD1;
		end
	ADD1: begin
			//next_modwait = 1;
			if (overflow == 1)
				NXT_STATE = EIDLE;
			else
				NXT_STATE = MUL2;
		end
	MUL2: begin
			//next_modwait = 1;
			NXT_STATE = SUB1;
		end
	SUB1: begin
			//next_modwait = 1;
			if (overflow == 1)
				NXT_STATE = EIDLE;
			else
				NXT_STATE = MUL3;
		end
	MUL3: begin
			//next_modwait = 1;
			NXT_STATE = ADD2;
		end
	ADD2: begin
			//next_modwait = 1;
			if (overflow == 1)
				NXT_STATE = EIDLE;
			else
		 		NXT_STATE = MUL4;
		end
	MUL4: begin
			//next_modwait = 1;
			NXT_STATE = SUB2;
		end
	SUB2: begin
			//next_modwait = 1;		
			if (overflow == 1)
				NXT_STATE = EIDLE;
			else
		 		NXT_STATE = IDLE;
		end
	EIDLE: begin
			if (dr == 1)
				NXT_STATE = STORED1;
			else
				NXT_STATE = EIDLE;
		end
	endcase
end

always_comb
	begin: OUT_LOGIC
		cnt_up = 1'b0;
		clear = 1'b0; 
		op[2:0] = 3'b000;
		src1[3:0] = 4'b1111;
		src2[3:0] = 4'b1111;
		dest[3:0] = 4'b1111;
		err = 0;
                modwait = 0;
      	case(STATE)
	EIDLE: begin
		err = 1;
		end
	STOREC1: begin //F0
		clear = 1'b1;
		dest = 4'b0110; //6
		op = 3'b011; //LOAD2
		modwait = 1;
		end
	STOREC2: begin //F1
		clear = 1'b1;
		dest = 4'b0111; //7
		op = 3'b011; //LOAD2
		modwait = 1;
		end
	STOREC3: begin //F2
		clear = 1'b1;
		dest = 4'b1000; //8
		op = 3'b011; //LOAD2
		modwait = 1;
		end
	STOREC4: begin //F3
		clear = 1'b1;
		dest = 4'b1001; //9
		op = 3'b011; //LOAD2
		modwait = 1;
		end
	STORED1: begin
		cnt_up = 1'b1;
		dest = 4'b0101; //5
		op = 3'b010; //LOAD1
		end
	ZERO: 	begin
		src1 = 4'b0000;
		src2 = 4'b0000;
		dest = 4'b0000;
		op = 3'b101; //SUB
		modwait = 1;
		end
	SORT1:	begin
		src1 = 4'b0010;
		dest = 4'b0001;
		op = 3'b001;
		modwait = 1;
		end
	SORT2:	begin
		src1 = 4'b0011;
		dest = 4'b0010;
		op = 3'b001;
		modwait = 1;
		end
	SORT3:	begin
		src1 = 4'b0100;
		dest = 4'b0011;
		op = 3'b001;
		modwait = 1;
		end
	SORT4:	begin
		src1 = 4'b0101;
		dest = 4'b0100;
		op = 3'b001;
		modwait = 1;
		end
	MUL1:	begin
		src1 = 4'b0001;
		src2 = 4'b1001; //9
		dest = 4'b1010;
		op = 3'b110;
		modwait = 1;
		end
	ADD1: 	begin
		src1 = 4'b0000;
		src2 = 4'b1010; 
		dest = 4'b0000;
		op = 3'b100;
		modwait = 1;
		end
	MUL2: 	begin
		src1 = 4'b0010;
		src2 = 4'b1000; //8
		dest = 4'b1010;
		op = 3'b110;
		modwait = 1;
		end
	SUB1: 	begin
		src1 = 4'b0000;
		src2 = 4'b1010;
		dest = 4'b0000;
		op = 3'b101;
		modwait = 1;
		end
	MUL3: 	begin
		src1 = 4'b0011;
		src2 = 4'b0111; //7
		dest = 4'b1010;
		op = 3'b110;
		modwait = 1;
		end
	ADD2: 	begin
		src1 = 4'b0000;
		src2 = 4'b1010;
		dest = 4'b0000;
		op = 3'b100;
		modwait = 1;
		end
	MUL4: 	begin
		src1 = 4'b0100;
		src2 = 4'b0110; //6
		dest = 4'b1010;
		op = 3'b110;
		modwait = 1;	
		end
	SUB2: 	begin
		src1 = 4'b0000;
		src2 = 4'b1010;
		dest = 4'b0000;
		op = 3'b101;
		modwait = 1;
		end
endcase
end
endmodule 