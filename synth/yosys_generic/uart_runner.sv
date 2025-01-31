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

    parameter Prescale = (32250000 / (115200 * 8));
    localparam ByteCycles = Prescale * 8;

    logic [7:0] tx_byte;
    task automatic receive_byte;
        $display("Waiting for start bit..");
        tx_byte = '0;
        //wait for start
        while(tx_o == 1'b1) @(posedge clk_i);
        repeat(ByteCycles / 2) @(posedge clk_i);
        repeat(ByteCycles) @(posedge clk_i);
 
        //receive 8 bits
        for (int i = 0; i < 8; i++) begin
            tx_byte[i] = tx_o;
            repeat (ByteCycles) @(posedge clk_i);
        end

        //wait for stop  bit
        repeat (ByteCycles) @(posedge clk_i);
        if (tx_o !=1) begin
            $display("Error: invalid stop bit ");
        end

        $display("Received: %h",tx_byte);
    endtask

endmodule








