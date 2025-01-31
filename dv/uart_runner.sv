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
        

        rx_i = 0;
        repeat (280) @(posedge clk_i);

        for (int i = 0; i <8; i++) begin
            rx_i = data[i];
            repeat (280) @(posedge clk_i);
        end

        rx_i = 1;
        repeat (280) @(posedge clk_i);
    endtask

    task automatic wait_clk(input int units);
        repeat (units) @(posedge clk_i);
    endtask

    logic [7:0] tx_byte, rx_data;
    integer tx_bit_count = 0;
    logic tx_valid, tx_ready;
   
    task automatic receive_byte;
    $display("start byte");
      //wait for start
     //while(tx_o ==1)
      //@(negedge tx_o);
      repeat(280) @(posedge clk_i);
    
    //receive 8 bits
    for (int i = 0; i <8; i++) begin
        repeat (280) @(posedge clk_i);
        rx_data[i] = tx_o;
        end
    //wait for end  bit
     repeat(280) @(posedge clk_i);
       if (tx_o !=1) begin
         $display("Error: invalid stop bit ");
       end

       $display("Received:%h",rx_data);
       
    endtask

endmodule








