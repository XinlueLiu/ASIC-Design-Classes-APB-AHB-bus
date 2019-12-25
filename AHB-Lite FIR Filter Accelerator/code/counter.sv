// $Id: $
// File name:   counter.sv
// Created:     10/6/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: counter

module counter
(
	input wire clk,
	input wire n_rst,
	input wire cnt_up,
	input wire clear,
	output reg one_k_samples
);

flex_counter #(10)
	COUNTER(
	.clk(clk),
	.n_rst(n_rst),
	.clear(clear),
	.count_enable(cnt_up),
	.rollover_val(10'd2), //1000
	.rollover_flag(one_k_samples)
);

endmodule 