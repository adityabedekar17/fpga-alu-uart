`timescale 1ns / 1ps

module top #(
    parameter int ClkFreq = 32256000,
    parameter int BaudRate = 115200  
    // from piazza post clk freq is 32.256 Mhz
    // Baudrate is standard as per the post
    /*prescale = clk frequency /(baud rate*8)-1;*/
   /* from Sifferman/Piazza*/
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
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic rx_i,
    output logic tx_o
);

    // Prescale from third party Ip
    localparam logic [15:0] uart_prescale = 16'(ClkFreq / (BaudRate*8)); 

    logic [7:0] axis_data;  
    logic       axis_valid;  
    logic       axis_ready; 
    uart_rx #(
        .DATA_WIDTH(8)
    ) rx_inst (
        .clk          (clk_i),
        .rst          (~rst_ni),
        .m_axis_tdata (axis_data),   // interface with tx 
        .m_axis_tvalid(axis_valid),   
        .m_axis_tready(axis_ready),   
        .rxd          (rx_i),
        .busy         (),
        .overrun_error(),
        .frame_error  (),
        .prescale     (uart_prescale)
    );

    uart_tx #(
        .DATA_WIDTH(8)
    ) inst_tx (
        .clk          (clk_i),
        .rst          (~rst_ni),
        .s_axis_tdata (axis_data),
        .s_axis_tvalid(axis_valid),
        .s_axis_tready(axis_ready),
        .txd          (tx_o),
        .busy         (),
        .prescale     (uart_prescale)
    );

endmodule

