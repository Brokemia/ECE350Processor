// clk is expected to be the full 100MHz clock
// 100_000_000 / 115_200 = 868.0556
module UART(input clk, input serialIn, output serialOut, input setAddr, input [11:0] startAddr, output err, output [11:0] writeAddr, output [31:0] writeData, output writeEnable);
    reg [11:0] timer = 12'b0;
    reg waitingForBit = 1'b1;
    reg [3:0] bitCounter = 1'd0;
    reg errored = 1'b0;
    assign err = errored;

    reg [1:0] currentByte = 2'b0;
    reg [31:0] data = 32'b0;
    assign writeData = data;
    reg [7:0] byte = 8'b0;
    reg writeOut = 1'b0;
    reg [11:0] addrOut = 12'b0;
    assign writeAddr = addrOut;

    assign writeEnable = writeOut;

    always @(posedge clk) begin
        if (setAddr) begin
            addrOut <= startAddr;
            currentByte <= 2'b0;
            data <= 32'b0;
        end
        if (writeOut) begin
            writeOut <= 1'b0;
            if (currentByte == 2'b0) begin
                addrOut <= addrOut + 1;
                data <= 32'b0;
            end
        end
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
                if (bitCounter == 4'd9) begin
                    waitingForBit <= 1'b1;
                    data[8*currentByte +: 8] <= byte;
                    // Write the current word to memory after each byte
                    writeOut = 1'b1;
                    currentByte <= currentByte + 1;
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