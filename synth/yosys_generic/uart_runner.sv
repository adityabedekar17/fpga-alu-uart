`timescale 1ns / 1ps

module uart_runner;
    logic clk_i;
    logic rst_ni;
    logic rx_i;
    logic tx_o;

    initial begin
        clk_i = 0;
        forever #15.5 clk_i = ~clk_i;  // 32.256 MHz clock
    end

    uart_sim #() dut (.*);

    task automatic reset;
        rx_i = 1;
        rst_ni = 0;
        repeat (5) @(posedge clk_i);
        rst_ni = 1;
    endtask

    task automatic send_byte(input logic [7:0] data);
        integer i;

        rx_i = 0;
        repeat (280) @(posedge clk_i);

        for (i = 0; i <8; i++) begin
            rx_i = data[i];
            repeat (280) @(posedge clk_i);
        end

        rx_i = 1;
        repeat (280) @(posedge clk_i);
    endtask

    task automatic wait_clk(input int units);
        repeat (units) @(posedge clk_i);
    endtask
endmodule








