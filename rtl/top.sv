`timescale 1ns / 1ps

module top #(
    parameter int ClkFreq = 18000000,
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

    logic [7:0] m_axis_tdata, s_axis_tdata;  
    logic [0:0] m_axis_tvalid, m_axis_tready, s_axis_tvalid, s_axis_tready;

    uart_rx #(
        .DATA_WIDTH(8)
    ) rx_inst (
        .clk          (clk_i),
        .rst          (~rst_ni),
        .m_axis_tdata (m_axis_tdata),   // interface with tx 
        .m_axis_tvalid(m_axis_tvalid),   
        .m_axis_tready(m_axis_tready),   
        .rxd          (rx_i),
        .busy         (),
        .overrun_error(),
        .frame_error  (),
        .prescale     (uart_prescale)
    );

    uart_alu #() ua_inst (
        .clk_i(clk_i),
        .reset_i(~rst_ni),
        .valid_i(m_axis_tvalid),
        .data_i(m_axis_tdata),
        .ready_o(m_axis_tready),
        .ready_i(s_axis_tready),
        .data_o(s_axis_tdata),
        .valid_o(s_axis_tvalid)
    );

    uart_tx #(
        .DATA_WIDTH(8)
    ) inst_tx (
        .clk          (clk_i),
        .rst          (~rst_ni),
        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .txd          (tx_o),
        .busy         (),
        .prescale     (uart_prescale)
    );

endmodule

