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

    parameter Prescale = 16'(32250000/(115200 * 8));

    uart_sim #() dut (.*);
    
    logic [7:0] m_axis_tdata;
    logic [0:0] m_axis_tvalid;

    logic [7:0] s_axis_tdata;
    logic [0:0] s_axis_tvalid, s_axis_tready;


    uart_tx #() uart_tx_inst(
        .clk(clk_i),
        .rst(~rst_ni),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .txd(rx_i),
        .busy(),
        .prescale(Prescale)
    );

    uart_rx #() uart_rx_inst(
        .clk(clk_i),
        .rst(~rst_ni),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(1'b1),
        .rxd(tx_o),
        .busy(),
        .overrun_error(),
        .frame_error(),
        .prescale(Prescale)
    );


    task automatic reset;
        rx_i = 1;
        rst_ni = 0;
        repeat (5) @(posedge clk_i);
        rst_ni = 1;
    endtask

    localparam repeat_cnt = Prescale * 8;

    int rnd_cnt = 0;
    int rnd_num = 0;
    logic [7:0] rnd_num_bytes [4];
    logic [15:0] bytes_send;
    int rand_opcode = 0;
    longint expected = 0;
    int tmp_exp = 0;
    logic [7:0] data_task_header [4];

    task automatic send_msg();
    begin
        expected = 0;
        while (~s_axis_tready) @(negedge clk_i);
        // randomly generate at least 2 operands, upto 4 additional
        rnd_cnt = ({$random()} % 4 + 2);
        // bytes to send are 4 (header) + 4 per operand
        bytes_send = 16'((4 * rnd_cnt) + 4);
        assert(bytes_send % 4 == 0)
        // choose randomly from opcodes
        rand_opcode = {$random()} % 3;
        // rand_opcode = 0;
        case (rand_opcode)
            0: begin 
              //$display("Opcode: Add"); 
              data_task_header[0] = 8'had;
            end
            1: begin
              //$display("Opcode: Mul"); 
              data_task_header[0] = 8'h63;
            end
            // divide special case: only two operands
            2: begin
              //$display("Opcode: Div");
              rnd_cnt = 2;
              bytes_send = 16'((4 * rnd_cnt) + 4);
              data_task_header[0] = 8'h5b;
            end
            default: begin 
              //$display("Bad opcode");
              $finish();
            end
        endcase
        data_task_header[1] = 8'h00;
        data_task_header[2] = bytes_send[7:0];
        data_task_header[3] = bytes_send[15:8];
        //$write("Command: ");

        // send the header
        for (int i = 0; i < 4; i ++) begin
            //$write("%h", data_task_header[i]);
            s_axis_tdata = data_task_header[i];
            s_axis_tvalid = 1'b1;
            while (~s_axis_tready) @(negedge clk_i);
            @(negedge s_axis_tready);
            s_axis_tvalid = 1'b0;
            @(negedge clk_i);
        end

        for (int i = 0; i < rnd_cnt; i ++) begin
            // genrate random 32 bit number and split into bytes
            rnd_num = $random();
            //$display("operand %d: %d", i, rnd_num);
            rnd_num_bytes[0] = rnd_num[7:0];
            rnd_num_bytes[1] = rnd_num[15:8];
            rnd_num_bytes[2] = rnd_num[23:16];
            rnd_num_bytes[3] = rnd_num[31:24];
            case (rand_opcode)
                0: expected[31:0] = expected[31:0] + rnd_num;
                1: begin
                  if (i == 0) begin
                    expected[31:0] = rnd_num;
                  end else begin
                    expected = expected[31:0] * rnd_num;
                  end
                end
                2: begin
                  if (i == 0) begin
                    tmp_exp = rnd_num;
                  end else begin
                    expected[31:0] = tmp_exp / rnd_num;
                    expected[63:32] = tmp_exp % rnd_num;
                  end
              end
            endcase

            // send operand
            for (int j = 0; j < 4; j ++) begin
                //$write("%h", rnd_num_bytes[j]);
                s_axis_tdata = rnd_num_bytes[j];
                s_axis_tvalid = 1'b1;
                while (~s_axis_tready) @(negedge clk_i);
                s_axis_tvalid = 1'b0;
                @(negedge clk_i);
            end
        end
        //$display("");
    end
    endtask

    longint actual = 0;
    int read_cnt = 0;
    logic [0:0] fail = 1'b0;

    task automatic receive_msg();
    begin
        actual = 0;
        case (rand_opcode)
            0, 1: read_cnt = 4;
            2: read_cnt = 8;
        endcase
        for (int i = 0; i < read_cnt; i ++) begin
            while (~m_axis_tvalid) @(negedge clk_i);
            actual |= m_axis_tdata << (i * 8);
            @(negedge clk_i);
        end
        case (rand_opcode) 
            0, 1: begin
              $display("Expected: %h\nGot:\t %h", expected[31:0], actual[31:0]);
              fail = (expected[31:0] != actual[31:0]);
            end
            2: begin
              $display("Expected: %h\nGot:\t %h", expected[63:0], actual[63:0]);
              fail = (expected[63:0] != actual[63:0]);
            end
        endcase
        if (fail) begin
            $display("\033[0;31mSIM FAILED\033[0m");
            $finish();
        end
        //$display("");
        repeat(10) repeat (repeat_cnt) @(negedge clk_i);
    end
    endtask
endmodule
