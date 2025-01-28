
module blinky_sim (
    
    input  logic clk_i,
    input  logic rst_ni,
    input logic rx_i,
    output logic tx_o
);

  
uart_echo #(
    .DATA_WIDTH(8)
)  dut (.*);

endmodule

