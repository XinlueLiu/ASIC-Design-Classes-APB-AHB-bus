// $Id: $
// File name:   ahb_lite_fir_filter.sv
// Created:     10/20/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: ahb_lite fir filter accelerator
module ahb_lite_fir_filter
(
	input wire clk,
	input wire n_rst,
	input wire hsel,
	input wire [3:0] haddr,
	input wire hsize,
	input wire [1:0] htrans,
	input wire hwrite,
	input wire [15:0] hwdata,
	output reg [15:0] hrdata,
	output reg hresp
);

reg [15:0] fir_out;
reg err;
reg data_ready;
reg [15:0] sample_data;
reg modwait;
reg new_coefficient_set;
reg [1:0] coefficient_num;
reg [15:0] fir_coefficient;
reg load_coeff;

ahb_lite_slave
	AHB_LITE_SLAVE(
	.clk(clk),
	.n_rst(n_rst),
	.sample_data(sample_data),
	.data_ready(data_ready),
	.new_coefficient_set(new_coefficient_set),
	.coefficient_num(coefficient_num),
	.fir_coefficient(fir_coefficient),
	.modwait(modwait),
	.fir_out(fir_out),
	.err(err),
	.hsel(hsel),
	.haddr(haddr),
	.hsize(hsize),
	.htrans(htrans),
	.hwrite(hwrite),
	.hwdata(hwdata),
	.hrdata(hrdata),
	.hresp(hresp)
);

coefficient_loader
	COEFFICIENT_LOADER(
	.clk(clk),
	.n_reset(n_rst),
	.new_coefficient_set(new_coefficient_set),
	.modwait(modwait),
	.load_coeff(load_coeff),
	.coefficient_num(coefficient_num)
);


fir_filter
	FIR_FILTER(
	.clk(clk),
	.n_reset(n_rst),
	.sample_data(sample_data),
	.data_ready(data_ready),
	.fir_coefficient(fir_coefficient),
	.load_coeff(load_coeff),
	.one_k_samples(one_k_samples),
	.modwait(modwait),
	.fir_out(fir_out),
	.err(err)
);













endmodule 