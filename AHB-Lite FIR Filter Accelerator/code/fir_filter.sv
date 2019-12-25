// $Id: $
// File name:   fir_filter.sv
// Created:     10/6/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: fir_filter

module fir_filter
(	input wire clk,
	input wire n_reset,
	input wire [15:0] sample_data,
	input wire [15:0] fir_coefficient,
	input wire load_coeff,
	input wire data_ready,
	output reg one_k_samples,
	output reg modwait,
	output reg [15:0] fir_out,
	output reg err
);
	reg cnt_up;
	reg clear;
	reg [2:0] op;
	reg [3:0] src1;
	reg [3:0] src2;
	reg [3:0] dest;
	reg overflow;
	reg [16:0]outreg_data;

controller
	CONTROLLER(
	.clk(clk),
	.n_rst(n_reset),
	.dr(data_ready),
	.lc(load_coeff),
	.overflow(overflow),
	.cnt_up(cnt_up),
	.clear(clear),
	.modwait(modwait),
	.op(op),
	.src1(src1),
	.src2(src2),
	.dest(dest),
	.err(err)
);

counter
	COUNTER(
	.clk(clk),
	.n_rst(n_reset),
	.cnt_up(cnt_up),
	.clear(clear),
	.one_k_samples(one_k_samples)
);

datapath
	DATAPATH(
	.clk(clk), 
	.n_reset(n_reset),
	.op(op),
	.src1(src1),
	.src2(src2),
	.dest(dest),
	.ext_data1(sample_data),
	.ext_data2(fir_coefficient),
	.outreg_data(outreg_data),
	.overflow(overflow)
);

magnitude
	MAGNITUDE(
	.in(outreg_data),
	.out(fir_out)
);

endmodule 