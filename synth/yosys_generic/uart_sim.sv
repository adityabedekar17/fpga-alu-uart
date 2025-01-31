
module uart_sim(
    
    input  logic clk_i,
    input  logic rst_ni,
    input logic rx_i,
    output logic tx_o
);

  
top #(
    .ClkFreq(32250000),
    .BaudRate(115200)
) dut (.*);

endmodule

