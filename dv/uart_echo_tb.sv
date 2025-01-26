`timescale 1ns/1ps
module uart_echo_tb
 #( parameter DATA_WIDTH = 8,
   /*prescale = clk frequency /(baud rate*8)-1;*/
   /* from Sifferman/Piazza*/
    parameter int BAUD_RATE = 115200,
    parameter [15:0] PRESCALE = 16,
    parameter CLK_FREQ = 8.0 * PRESCALE * BAUD_RATE,
    parameter CLK_PERIOD = (1.0/CLK_FREQ)
 );
   //https://support.sbg-systems.com/sc/kb/latest/technology-insights/uart-baud-rate-and-output-rate
 /*
    Baud rate =  number of bytes * total bits per frame * output rate of message in Hz
    total bits per frame = data bits + start bit + stop bit + parity ( optional)
    8 bits of data + 1start + 1stop = 10 bits per frame
    in our case: 
    total bits per frame - 10  
    output rate of message in Hz - ? TBD
    number of bytes - ? TBD
    */
    

    reg clk = 0;
    reg rst = 1;
    reg rxd = 1;
    wire txd;

    reg[7:0] test_data = 8'hC4;

    uart_echo  dut(
        .clk_i(clk),
        .rst_i(rst),
        .prescale_i(PRESCALE),
        .rxd_i(rxd),
        .txd_o(txd)
    );
    always #(CLK_PERIOD*1s/2) clk = ~clk;

    initial begin
        $dumpfile("uart_echo.vcd");
        $dumpvars(0,uart_echo_tb);

        #100 rst=0;
        #100;
        // begin sending
        rxd=0;//start bit
        #(8.68us);

        rxd = test_data[0]; #(8.68us); //1bit wait time
        rxd = test_data[1]; #(8.68us);
        rxd = test_data[2]; #(8.68us);
        rxd = test_data[3]; #(8.68us);
        rxd = test_data[4]; #(8.68us);
        rxd = test_data[5]; #(8.68us);
        rxd = test_data[6]; #(8.68us);
        rxd = test_data[7]; #(8.68us);
        
        rxd =1; //stop
        #(8.68us);

        #(100us);
        $finish;
    end



initial begin
     $display("Simulation parameters:");
    $display("Clock frequency: %0f Hz", CLK_FREQ);
    $display("Clock period: %0f s", CLK_PERIOD);
    $display("Baud rate: %0d bps", BAUD_RATE);
    $display("Prescale value: %0d", PRESCALE);
    end  
endmodule
