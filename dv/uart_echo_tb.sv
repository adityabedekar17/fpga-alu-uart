`timescale 1ns / 1ps

module uart_echo_tb;
    // waveform fst file
    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0, uart_runner);
    end

    uart_runner uart_runner (); 

    initial begin
        uart_runner.reset();
       
        repeat (10) begin
            uart_runner.send_msg();
            uart_runner.receive_msg();
        end

        $display("Done");
        $finish;
    end

    /*
    task send_byte(input logic [7:0] data);
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
    */

   /*
    logic [7:0] tx_byte, tx_data;
    integer tx_bit_count = 0;
    logic tx_valid, tx_ready;
     always @(negedge tx_o) begin
        if (tx_bit_count == 0 && tx_o == 0) begin
            tx_bit_count <= 1;
        end else if (tx_bit_count <= 8) begin
            tx_byte[tx_bit_count-1] <= tx_o;
            tx_bit_count <= tx_bit_count + 1;
        end else if (tx_o ==1) begin
            $display("TX byte received: %h", tx_byte);
            tx_bit_count <= 0;
        end
    end

    always @(posedge clk_i) begin
        if (tx_valid && tx_ready) begin
            $display("Echoed byte: %h", tx_data);
        end
    end
    */
endmodule








