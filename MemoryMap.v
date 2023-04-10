module MemoryMap(
    input wire [11:0]       addr,
    input wire [31:0]       dataIn,
    output reg [31:0]       dataOut,
    input wire              writeEnable,

    input wire [31:0]       RAM_out,
    output wire             RAM_write,
    input wire [4:0]        BTN,
    input wire              SD_responseByte,
    input wire [7:0]        SD_response,
    output reg [47:0]       SD_cmd,
    output reg              SD_start);

    assign RAM_write = writeEnable && !addr[11];

    always @(addr, RAM_out, BTN, SD_responseByte, SD_response) begin
        case ({addr[11], addr[1:0]})
            3'b100: begin
                dataOut = BTN;
            end
            3'b101: begin
                dataOut = { SD_responseByte, 23'b0, SD_responseBuffer };
            end
            3'b110: begin
                dataOut = SD_cmd[31:0];
                if(writeEnable) begin
                    SD_cmd[31:0] <= dataIn;
                end
            end
            3'b111: begin
                dataOut = { SD_start, 15'b0, SD_cmd[47:32] };
                if(writeEnable) begin
                    SD_cmd[47:32] <= dataIn[15:0];
                    SD_start <= dataIn[31];
                end
            end
            default: begin
                dataOut = RAM_out;
            end
        endcase
    end

    reg [7:0] SD_responseBuffer = 8'hFF;
    always @(SD_responseByte) begin
        SD_responseBuffer <= SD_response;
    end
endmodule