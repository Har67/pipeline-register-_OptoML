module tb_pipeline_reg;

    parameter DATA_WIDTH = 32;

    // Testbench signals
    logic clk;
    logic rst_n;

    logic in_valid;
    logic in_ready;
    logic [DATA_WIDTH-1:0] in_data;

    logic out_valid;
    logic out_ready;
    logic [DATA_WIDTH-1:0] out_data;

    // Instantiate DUT
    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_data(out_data)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // ---------- VCD dump ----------
        $dumpfile("pipeline_reg.vcd");
        $dumpvars(0, tb_pipeline_reg);

        // ---------- Initialize ----------
        clk = 0;
        rst_n = 0;
        in_valid = 0;
        in_data  = 0;
        out_ready = 0;

        // ---------- Apply reset ----------
        #20;
        rst_n = 1;

        // ---------- Case 1: Normal transfer ----------
        @(posedge clk);
        in_valid = 1;
        in_data  = 32'hAAAA5555;
        out_ready = 1;

        @(posedge clk);
        in_valid = 0;

        // ---------- Case 2: Backpressure ----------
        @(posedge clk);
        in_valid = 1;
        in_data  = 32'h12345678;
        out_ready = 0;   // Consumer not ready

        repeat (3) @(posedge clk);

        out_ready = 1;   // Consumer ready again
        in_valid  = 0;

        // ---------- Finish ----------
        #20;
        $finish;
    end

endmodule

