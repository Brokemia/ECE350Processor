// clk is expected to be the full 100MHz clock
// 100_000_000 / 115_200 = 868.0556
module UART_simple(input clk, input serialIn, output serialOut, output err, output [7:0] lastByte);
    reg [11:0] timer = 12'b0;
    reg waitingForBit = 1'b1;
    reg [3:0] bitCounter = 1'd0;
    reg errored = 1'b0;
    assign err = errored;

    reg [7:0] data = 32'b0;
    assign lastByte = data;
    reg [7:0] byte = 8'b0;

    always @(posedge clk) begin
        timer <= timer - 1;
        if (waitingForBit) begin
            // Falling edge of start bit
            if (!serialIn) begin
                // Wait 1.5 bits to end up in the middle of the first data bit
                timer <= 12'd1302;
                waitingForBit <= 1'b0;
                bitCounter <= 4'd0;
            end
        end else begin
            if (timer == 12'd0) begin
                timer <= 12'd868;
                bitCounter <= bitCounter + 1;
                // 9th bit is stop bit
                if (bitCounter == 4'd8) begin
                    waitingForBit <= 1'b1;
                    data <= byte;
                    if (!serialIn) begin
                        errored <= 1'b1;
                    end
                end else begin
                    byte = {serialIn, byte[7:1]};
                end
            end
        end
    end
endmodule