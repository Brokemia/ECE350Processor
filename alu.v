module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire SameSignOps, DiffSignRes, DiffSignOps, triviallyLessThan, sameOpsNegRes;
    wire [31:0] NotArgB, anded, ored, SLLed, SRAed, arithmeticResult;
    wire [3:0] ZeroSections;

    generate
        for(genvar i = 0; i < 32; i = i + 1) begin
            not NotArgBCalc(NotArgB[i], data_operandB[i]);
            and AndAB(anded[i], data_operandA[i], data_operandB[i]);
            or OrAB(ored[i], data_operandA[i], data_operandB[i]);
        end
    endgenerate

    ShiftLeftLogical SLL(SLLed, data_operandA, ctrl_shiftamt);
    ShiftRightArithmetic SRA(SRAed, data_operandA, ctrl_shiftamt);
    
    cla adder(data_operandA, ctrl_ALUopcode[0] ? NotArgB : data_operandB, ctrl_ALUopcode[0] ? 1'b1 : 1'b0, arithmeticResult);

    xnor SameSignOperands(SameSignOps, data_operandA[31], data_operandB[31]);
    xor DiffSignOperands(DiffSignOps, data_operandA[31], data_operandB[31]);
    xor DiffSignResult(DiffSignRes, data_result[31], data_operandA[31]);
    and OverflowCalc(overflow, ctrl_ALUopcode[0] ? DiffSignOps : SameSignOps, DiffSignRes, ctrl_ALUopcode[4:1] == 4'b0);

    // If any of the ouput bits are 1, the operands are not equal
    nor ZeroSection0(ZeroSections[0], data_result[0], data_result[1], data_result[2], data_result[3], data_result[4], data_result[5], data_result[6], data_result[7]);
    nor ZeroSection1(ZeroSections[1], data_result[8], data_result[9], data_result[10], data_result[11], data_result[12], data_result[13], data_result[14], data_result[15]);
    nor ZeroSection2(ZeroSections[2], data_result[16], data_result[17], data_result[18], data_result[19], data_result[20], data_result[21], data_result[22], data_result[23]);
    nor ZeroSection3(ZeroSections[3], data_result[24], data_result[25], data_result[26], data_result[27], data_result[28], data_result[29], data_result[30], data_result[31]);
    nand isNotEqualCalc(isNotEqual, ZeroSections[0], ZeroSections[1], ZeroSections[2], ZeroSections[3]);

    and TriviallyLessThan(triviallyLessThan, data_operandA[31], NotArgB[31]);
    and SameOpsNegRes(sameOpsNegRes, SameSignOps, data_result[31]);
    or IsLessThan(isLessThan, triviallyLessThan, sameOpsNegRes);

    mux8 OpSelect(data_result, ctrl_ALUopcode[2:0], arithmeticResult, arithmeticResult, anded, ored, SLLed, SRAed, arithmeticResult, arithmeticResult);
endmodule