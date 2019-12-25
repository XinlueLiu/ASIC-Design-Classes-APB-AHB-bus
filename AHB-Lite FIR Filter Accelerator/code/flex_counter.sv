// $Id: $
// File name:   flex_counter.sv
// Created:     9/16/2019
// Author:      David Evans
// Lab Section: 337-02
// Version:     1.0  Initial Design Entry
// Description: Flex Counter
module flex_counter
#(parameter NUM_CNT_BITS = 4)(input wire clk, n_rst, clear, count_enable, input wire [(NUM_CNT_BITS -1):0]rollover_val,output reg[(NUM_CNT_BITS -1):0] count_out, output reg rollover_flag);
reg [(NUM_CNT_BITS - 1):0]next_count;
reg next_rollover_flag;

always_ff @ (posedge clk,negedge n_rst) 
begin: COUNT_LOGIC
   if(n_rst == 1'b0) begin
     count_out <= 'b0;
   end
   else begin
     count_out <= next_count;
   end
end

always_ff @ (posedge clk, negedge n_rst) 
begin: ROLLOVER_LOGIC
   if(n_rst == 1'b0) begin
     rollover_flag <= 1'b0;
   end
   else begin
     rollover_flag <= next_rollover_flag;
   end 
end


always_comb begin
    next_rollover_flag = rollover_flag;
    next_count = count_out;
  if(clear == 1'b1) begin
     next_count = 'b0;
  end
  else if ((next_count == rollover_val) & count_enable) begin
        next_count = 'b1;
   end
  else if (count_enable) begin 
        next_count = next_count + 1;
      end
  else begin 
    next_count = count_out;
  end
  if(next_count == rollover_val) begin
    next_rollover_flag = 1'b1;
  end
  else begin
    next_rollover_flag = 1'b0;
  end
end
endmodule 
