// $Id: $
// File name:   apb_uart_rx.sv
// Created:     10/12/2019
// Author:      Xinlue LIu
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: apb_uart receiver peripheral

module apb_uart_rx
(
	input wire clk,
	input wire n_rst,
	input wire serial_in,
	input wire psel,
	input wire [2:0]paddr,
	input wire penable,
	input wire pwrite,
	input wire [7:0]pwdata,
	output reg [7:0]prdata,
	output reg pslverr
);
	reg overrun_error;
	reg framing_error;
	reg data_ready;
	reg data_read;
	reg [3:0] data_size;
	reg [13:0] bit_period;
	reg [7:0] rx_data;

rcv_block
  UART_RECEIVER(
    .clk(clk),
    .n_rst(n_rst),
    .data_size(data_size),
    .bit_period(bit_period),
    .serial_in(serial_in),
    .data_read(data_read),
    .rx_data(rx_data), //output and the rest
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error)
  );

apb_slave
  APB_SLAVE(
    .clk(clk),
    .n_rst(n_rst),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .overrun_error(overrun_error),
    .framing_error(framing_error),
    .data_read(data_read), //output
    .psel(psel),
    .paddr(paddr),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata), //output and the rest
    .pslverr(pslverr),
    .data_size(data_size),
    .bit_period(bit_period)
  );

endmodule 