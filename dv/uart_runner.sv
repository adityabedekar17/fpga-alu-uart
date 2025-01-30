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

    uart_echo #(
      .DATA_WIDTH(8)
    ) dut (.*);

    task automatic reset;
        rx_i = 1;
        rst_ni = 0;
        @(posedge clk_i);
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

    logic [7:0] tx_byte, tx_data;
    integer tx_bit_count = 0;
    logic tx_valid, tx_ready;
    task automatic  receive_byte;
    while (tx_o ==0) @(posedge clk_i);
    
     //always @(negedge tx_o) begin
        if (tx_bit_count == 0 && tx_o == 0) begin
            tx_bit_count <= 1;
        end else if (tx_bit_count <= 8) begin
            tx_byte[tx_bit_count-1] <= tx_o;
            tx_bit_count <= tx_bit_count + 1;
        end else if (tx_o ==1) begin
            $display("TX byte received: %h", tx_byte);
            tx_bit_count <= 0;
        end
    

    while(tx_valid && tx_ready==0) @(posedge clk_i); 
        
            $display("Echoed byte: %h", tx_data);
       
    
    endtask

endmodule








