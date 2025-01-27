`timescale 1ns / 1ps

module uart_echo_tb;
    logic clk_i;
    logic rst_ni;
    logic rx_i;
    logic tx_o;

    initial begin
        clk_i = 0;
        forever #15.5 clk_i = ~clk_i;  // 32.256 MHz clock
    end

    // waveform fst file
    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0, uart_echo_tb);
        $dumpvars(1, dut);
    end

    uart_echo dut (.*);


    initial begin
        rx_i   = 1;
        rst_ni = 0;

        repeat (100) @(posedge clk_i);
        rst_ni = 1;

        repeat (1000) @(posedge clk_i);

        // send 'A' (0x41)
        $display("Sending A...");
        send_byte(8'h41);

        repeat (80000) @(posedge clk_i);
        $display("Done");
        $finish;
    end

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

    logic [7:0] tx_byte;
    integer tx_bit_count = 0;
     
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
        if (dut.tx_valid && dut.tx_ready) begin
            $display("Echoed byte: %h", dut.tx_data);
        end
    end
endmodule








