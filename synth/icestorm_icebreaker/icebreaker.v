
module icebreaker (
    input  wire CLK,
    input  wire  RX,
    output wire  TX,
    input wire BTN_N
);

wire clk_12 = CLK;

  // pll 12Mhz to 18Mhz
  // Based on max allowed speed from nextpnr
  //
  // FILTER_RANGE: 1 (3'b001)
  //
  // F_PLLIN:    12.000 MHz (given)
  // F_PLLOUT:   18.000 MHz (requested)
  // F_PLLOUT:   18.000 MHz (achieved)
  //
  // FEEDBACK: SIMPLE                           
  // F_PFD:   12.000 MHz
  // F_VCO:  576.000 MHz                                
  //
  // DIVR:  0 (4'b0000)            
  // DIVF: 47 (7'b0101111)      
  // DIVQ:  5 (3'b101)
  //
  // FILTER_RANGE: 1 (3'b001)   

    wire [0:0] clk_18;
    SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .PLLOUT_SELECT("GENCLK"),
        .DIVR(4'd0),
        .DIVF(7'd47),
        .DIVQ(3'd5),
        .FILTER_RANGE(3'd1)
    ) pll (
        .PACKAGEPIN(clk_12),
        .PLLOUTGLOBAL(clk_18),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    reg [0:0] sync_rx_q1, sync_rx_q2;
    always @(posedge clk_18) begin
        sync_rx_q1 <= RX;
        sync_rx_q2 <= sync_rx_q1;
    end

    top #(
        .ClkFreq(18000000),// achieved Freq
        .BaudRate(115200)
    ) top (
        .clk_i (clk_18),
        .rst_ni(1'b1),
        .rx_i(sync_rx_q2),
        .tx_o(TX)
    );

endmodule

