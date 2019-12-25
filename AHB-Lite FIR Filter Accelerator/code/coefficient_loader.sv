// $Id: $
// File name:   coefficient_loader.sv
// Created:     10/20/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: coefficient_loader

module coefficient_loader
(
	input wire clk,
	input wire n_reset,
	input wire new_coefficient_set,
	input wire modwait,
	output reg load_coeff,
	output reg [1:0] coefficient_num
);

typedef enum bit[2:0] {IDLE, LOAD1, WAIT1, LOAD2, WAIT2, LOAD3, WAIT3, LOAD4} stateType;
reg [2:0] STATE;
reg [2:0] NXT_STATE;


always_ff @ (negedge n_reset, posedge clk)
	begin: REG_LOGIC
	if (!n_reset) begin
		STATE <= IDLE;
	end else begin
		STATE <= NXT_STATE;
	end
end


always_comb
	begin: NEXT_LOGIC
	NXT_STATE = STATE;
	case(STATE)
	IDLE: begin
		//((!modwait) | (new_coefficient_set)) previously
		if ((!modwait) & (new_coefficient_set)) begin
			NXT_STATE = LOAD1;
		end else begin
			NXT_STATE = IDLE;
		end
	end
	LOAD1: begin
		NXT_STATE = WAIT1;
	end
	WAIT1: begin
		//used if (new_coefficient_set)
		if (!modwait) begin
			NXT_STATE = LOAD2;
		end else  begin
			NXT_STATE = WAIT1;
		end
	end
	LOAD2: begin
		NXT_STATE = WAIT2;
		end
	WAIT2: begin
		if (!modwait) begin
			NXT_STATE = LOAD3;
		end else begin
			NXT_STATE = WAIT2;
		end
	end
	LOAD3: begin
		NXT_STATE = WAIT3;
		end
	WAIT3: begin
		if (!modwait) begin
			NXT_STATE = LOAD4;
		end else begin
			NXT_STATE = WAIT3;
		end
	end
	LOAD4: begin
		NXT_STATE = IDLE;
	end
	endcase
end

always_comb
	begin: OUTPUT_LOGIC
	load_coeff = 1;
	coefficient_num = 2'b00;

	case(STATE)
	IDLE: begin
		load_coeff = 0;
	end
	LOAD1: begin
		coefficient_num = 2'b00;
		end
	WAIT1: begin
		load_coeff = 0;
		coefficient_num = 2'b00;
		end
	LOAD2: begin
		coefficient_num = 2'b01;
		end
	WAIT2: begin
		load_coeff = 0;
		coefficient_num = 2'b01;
		end
	LOAD3: begin
		coefficient_num = 2'b10;
		end
	WAIT3: begin
		load_coeff = 0;
		coefficient_num = 2'b10;
		end
	LOAD4: begin
		coefficient_num = 2'b11;
		end 
	endcase
end

endmodule 