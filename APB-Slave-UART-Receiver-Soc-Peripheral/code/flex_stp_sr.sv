// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/21/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: serial to parallel shift register

module flex_stp_sr
#(
	parameter NUM_BITS = 4, //4 bit MSB Stp shift register
	parameter SHIFT_MSB = 1 //TRUE
)

(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output reg [NUM_BITS - 1: 0] parallel_out
);
	reg [NUM_BITS - 1: 0] next_parallel_out;
always_comb begin: NEXT_STATE_LOGIC
	next_parallel_out = parallel_out;
	if(!shift_enable) begin
		next_parallel_out = parallel_out;
	end else if (SHIFT_MSB == 1) begin
		next_parallel_out = {parallel_out[NUM_BITS - 2: 0], serial_in};
	end else begin
		next_parallel_out = {serial_in, parallel_out[NUM_BITS - 1:1]};
	end
end

always_ff @(negedge n_rst, posedge clk) begin
	if(!n_rst)
		parallel_out <= '1;
	else
		parallel_out <= next_parallel_out;
	end

endmodule 

// $Id: $
// File name:   CDL_CRC_16GENERATOR.sv
// Created:     11/12/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: 16 bit rx crc generator

module CDL_CRC_16GENERATOR
(
	input wire clk,
	input wire n_rst,
	input wire input_data,
	output reg [15:0] inverted_crc
);

/*typedef enum bit {LOAD, CRC} stateType;
stateType STATE;
stateType NXT_STATE;*/
reg [15:0] original_data;
reg crc = 0;
/*reg count1 = 0;
reg count2 = 0;*/

 flex_stp_sr #(15,0)
  SHIFT_REGISTER(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(input_data),
    .shift_enable(1),
    .parallel_out(original_data)
  );



/*always_ff @ (negedge n_rst, posedge clk)
	begin: REG_LOGIC
	if (!n_rst) begin
		STATE <= LOAD;
	end else begin
		STATE <= NXT_STATE;
	end
end

always_comb
	begin: NXT_STATE_LOGIC
	NXT_STATE = STATE;
	case(STATE)
	LOAD: begin
		if (count1 < 16) begin
			NXT_STATE = LOAD;
		end else begin
			NXT_STATE = CRC;
		end
	end
	CRC: begin
		if (count2 < 16) begin
			NXT_STAE = CRC;
		end else begin
			NXT_STATE = LOAD;
		end
	end
	endcase
end
*/





endmodule 