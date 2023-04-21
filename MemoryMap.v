module MemoryMap(
    input clk,
    input wire [11:0]       addr,
    input wire [31:0]       dataIn,
    output reg [31:0]       dataOut,
    input wire              writeEnable,

    input wire [31:0]       RAM_out,
    output wire             RAM_write,
    input wire [4:0]        BTN,
    input wire              SD_responseByte,
    input wire [7:0]        SD_response,
    output     [47:0]       SD_cmd,
    output reg              SD_start,
    output reg              UART_setAddr,
    output     [11:0]       UART_addr,
    input wire [7:0]        UART_lastByte);

    assign RAM_write = writeEnable && !addr[11];
    assign UART_addr = dataIn[11:0];

    reg [47:0] SD_cmd_reg = 48'b0;
    always @(posedge clk) begin
        UART_setAddr = 1'b0;
        if(writeEnable) begin
            case ({addr[11], addr[2:0]})
                3'b1010: begin
                    SD_cmd_reg[31:0] <= dataIn;
                end
                3'b1011: begin
                    SD_cmd_reg[47:32] <= dataIn[15:0];
                    SD_start <= dataIn[31];
                end
                3'b1100: begin
                    UART_setAddr = 1'b1;
                end
            endcase
        end
    end
    always @(addr, RAM_out, BTN, SD_responseByte, SD_response) begin
        case ({addr[11], addr[2:0]})
            3'b1000: begin
                dataOut = BTN;
            end
            3'b1001: begin
                dataOut = { SD_responseByte, 23'b0, SD_responseBuffer };
            end
            3'b1010: begin
                dataOut = SD_cmd_reg[31:0];
            end
            3'b1011: begin
                dataOut = { SD_start, 15'b0, SD_cmd_reg[47:32] };
            end
            3'b1100: begin
                dataOut = UART_lastByte;
            end
            default: begin
                dataOut = RAM_out;
            end
        endcase
    end

    assign SD_cmd = SD_cmd_reg;

    reg [7:0] SD_responseBuffer = 8'hFF;
    always @(SD_responseByte) begin
        SD_responseBuffer <= SD_response;
    end
endmodule