`timescale 1 ns / 100 ps
module SDController_tb();
    wire [7:0] SD;
    reg clk = 1'b0;
    reg [47:0] cmd = 48'hAAAAAAAAAAAA;
    reg start = 1'b0;
    wire responseByte;
    wire [7:0] response;
    SDController SD_test(
        SD,
        clk,
        cmd,
        start,
        responseByte,
        response
    );

    integer responseIdx = 0;
    reg [12:0] responseBuffer = 12'b101100011101;
    assign SD[4] = responseBuffer[responseIdx];

    integer started = 0;
    initial begin
        #20;
        start <= 1'b1;
        #4
        started = 1;
        #40;
        start <= 1'b0;
        #400;
        $finish;

    end

    initial begin
        for(integer i = 0; 1'b1; i++) begin
            #2;
            clk <= ~clk;
            if (started && !clk) begin
                if(responseIdx >= 11) begin
                    responseIdx = 0;
                end else begin
                    responseIdx = responseIdx + 1;
                end
            end
        end
    end

    initial begin
        $dumpfile("SDController.vcd");
        $dumpvars(0, SDController_tb);
    end
endmodule