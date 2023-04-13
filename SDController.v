/* For SPI
DAT0 (SD[4]) = Data Out
DAT3 (SD[7]) = Chip Select
CMD (SD[3]) = Data Input - send stuff here
CLK (SD[2]) = Clock
*/

module SDController(
    inout [7:0] SD,
    input clk,
    input [47:0] cmd,
    input start,
    output reg responseByte = 1'b0, // Toggles between 0 and 1 after each byte
    output reg [7:0] response
);
    // Drive reset low to power the SD card
    assign SD[0] = 1'b0;

    // Assume clk is provided at SD speeds
    assign SD[2] = clk;

    reg started = 1'b0;
    
    // Drive DO high
    //assign SD[4] = 1'b1;
    // Drive CS low when in use
    assign SD[7] = 1'b0;

    wire byteCntReset;
    wire [3:0] byteCnt;
    wire byteDone;
    assign byteDone = byteCnt[0] & byteCnt[1] & byteCnt[2];
    counter4 ByteCounter(byteCnt, clk, started, byteCntReset);
    assign byteCntReset = startPulse | byteCnt[3];

    reg [7:0] responseBuffer = 8'hFF;

    assign SD[3] = started ? cmdBuffer[47] : 1'b1;

    reg [47:0] cmdBuffer = 48'd0;
    
    reg startPulse = 1'b0;
    reg lastStart = 1'b0;
    always @(posedge clk) begin
        cmdBuffer <= {cmdBuffer[46:0], 1'b1};
        if (started) begin
            startPulse <= 1'b0;
            responseBuffer <= {responseBuffer[6:0], SD[4]};
            if(byteDone) begin
                responseByte <= ~responseByte;
                response <= responseBuffer;
            end
        end
        // On a positive edge of start, reset the thing
        if (start && !lastStart) begin
            started <= 1'b1;
            startPulse <= 1'b1;
            responseBuffer <= 8'hFF;
            cmdBuffer <= cmd;
        end
        lastStart <= start;
    end
endmodule