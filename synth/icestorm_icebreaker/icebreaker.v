
module icebreaker (
    input  wire CLK,
    input  wire  RX,
    output wire  TX,
    input wire BTN_N
);

wire clk_12 = CLK;
wire clk_32_256;// 32.256 Mhz clock from piazza

/*icepll -i 12 -o 32.256
 icepll -i 12 -o 32.256

F_PLLIN:    12.000 MHz (given)
F_PLLOUT:   32.256 MHz (requested)
F_PLLOUT:   32.250 MHz (achieved)

FEEDBACK: SIMPLE
F_PFD:   12.000 MHz
F_VCO: 1032.000 MHz

DIVR:  0 (4'b0000)
DIVF: 85 (7'b1010101)
DIVQ:  5 (3'b101)*/
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd85),
    .DIVQ(3'd5),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTCORE(clk_32_256)
);
top #(
    .ClkFreq(32250000),// achieved Freq
    .BaudRate(115200)
) top (
    .clk_i (clk_32_256),
    .rst_ni(BTN_N),
    .rx_i(RX),
    .tx_o(TX)
);

endmodule

