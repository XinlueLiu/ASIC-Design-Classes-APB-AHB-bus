// $Id: $
// File name:   apb_slave.sv
// Created:     10/11/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: apb_slave

module apb_slave
(
	input wire clk,
	input wire n_rst,
	input wire [7:0] rx_data,
	input wire data_ready,
	input wire overrun_error,
	input wire framing_error,
	output reg data_read,
	input wire psel,
	input wire [2:0] paddr,
	input wire penable,
	input wire pwrite,
	input wire [7:0] pwdata,
	output reg [7:0] prdata,
	output reg pslverr,
	output reg [3:0] data_size,
	output reg [13:0] bit_period
);

typedef enum bit[2:0] {IDLE, READ, WRITE, ERROR} stateType;

//reg next_data_read;
reg [2:0] STATE;
reg [2:0] NXT_STATE;
reg [6:0][7:0]next_address_mapping;
reg [6:0][7:0]address_mapping;

always_ff @ (negedge n_rst, posedge clk)
	begin: REG_LOGIC
	if (!n_rst) begin
		STATE <= IDLE;
		address_mapping <= '0;
		//data_read <= 0;
	end else begin
		STATE <= NXT_STATE;
		address_mapping <= next_address_mapping;
		//data_read <= next_data_read;
	end
end

always_comb
	begin: NXT_LOGIC
	NXT_STATE = STATE;

	case (STATE)
	IDLE: begin
		/*if (((psel) && ((pwrite == 1) && !((paddr == 2) | (paddr == 3) | (paddr == 4))) |
   		((pwrite == 0) && !((paddr == 0) | (paddr == 1) | (paddr == 2) | (paddr == 3) | (paddr == 4) | (paddr == 6))))
		begin*/
		if ((psel) && (((pwrite == 1) && !((paddr == 2) | (paddr == 3) | (paddr == 4)))
		    | ((pwrite == 0) && !((paddr == 0) | (paddr == 1) | (paddr == 2) | (paddr == 3) | (paddr == 4) | (paddr == 6))))) begin
 			NXT_STATE = ERROR;
		end else if ((pwrite == 0) && (psel == 1)) begin
			NXT_STATE = READ;
		end else if ((pwrite == 1) && (psel == 1)) begin
			NXT_STATE = WRITE;
		end else begin
			NXT_STATE = IDLE;
		end
	end
	READ: begin
			NXT_STATE = IDLE;
	end
	WRITE: begin
			NXT_STATE = IDLE;
	end
	ERROR: begin
			NXT_STATE = IDLE;
	end
	endcase
end

always_comb
	begin: OUTPUT_LOGIC_INTERMEDIATE
	next_address_mapping = address_mapping;

	data_size = address_mapping[4];
        //bit_period = {address_mapping[3][13:8],address_mapping[2]};
	bit_period = {address_mapping[3],address_mapping[2]};
	
	next_address_mapping[0] = data_ready;
	next_address_mapping[5] = '0;
	next_address_mapping[6] = rx_data;
	if (framing_error) begin
		next_address_mapping[1] = 1;
	end else if (overrun_error) begin
		next_address_mapping[1] = 2;
	end else begin
		next_address_mapping[1] = 0;
	end
	case (STATE)
	WRITE: begin
		if (penable) begin
		next_address_mapping[paddr] = pwdata;
		end
	end
	endcase
end

always_comb 
	begin: FINAL_OUTPUT_LOGIC
	prdata = '0;
	//next_data_read = 0;
        data_read = 0;
	pslverr = 0;

	case (STATE)
	READ: begin
		if (penable) begin
			if (paddr == 6) begin
				if (address_mapping[4] == 8'd5) begin
					prdata = {3'b000, address_mapping[paddr][7:3]};
				end else if (address_mapping[4] == 8'd7) begin
					prdata = {1'b0, address_mapping[paddr][7:1]};
				end else begin
					prdata = address_mapping[paddr];
				end
				//next_data_read = 1;
				data_read = 1;
			end else begin
				prdata = address_mapping[paddr];
			end
		end
	end
	ERROR: begin
		pslverr = 1;
	end
	endcase 
end
endmodule 