module uart_echo
    import config_pkg::*;
#(
    parameter DATA_WIDTH = 8  
    // third party ip has datawidth set to 8 bits per frame
    // my guess is it follows the standard 8 + 1 +1 per frame
    // meaning 1 start bit, 8 bits of data,1 stop bit
) (
    input  logic clk_i,
    input  logic rst_ni,
    output logic rx_i,
    output logic tx_o
);

    logic tx_data;
    logic tx_valid;
    logic tx_ready;

    logic rx_data;
    logic rx_valid;
    logic rx_ready;

    uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) inst_tx (
        .clk(clk_i),
        .rst(rst_ni),
        .s_axis_tdata(tx_data),
        .s_axis_tvalid(tx_valid),
        .s_axis_tready(tx_ready),
        .txd(tx_o),
        .busy(),
        .prescale(8'd16)
    );

    uart_rx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) inst_rx (
        .clk(clk_i),
        .rst(rst_ni),
        .m_axis_tdata(rx_data),
        .m_axis_tvalid(rx_valid),
        .m_axis_tready(rx_ready),
        .rxd(rx_i),
        .busy(),
        .overrun_error(),
        .frame_error(),
        .prescale(8'd16)
    );
    assign tx_data = rx_data;
    assign tx_valid = rx_valid;
    assign rx_ready = tx_ready;

endmodule
