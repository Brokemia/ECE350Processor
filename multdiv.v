module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire resetCounter, useAdditionResult, extraLowBit, notExtraLowBit, subtractMultiplicand, counterDone, upperBitsOne, upperBitsZero, checkSigns, signsBad, upperBitsDiff, resultNonZero,
        booth10, boothDoSomething, isMultiplying, isDividing, gotCTRLSignal, trialSubSuccess, useAdditionResultMult, useAdditionResultDiv, predictResultSign, resultSign, divisorZero,
        dataExceptionMult, counterPastDone;
    wire [31:0] multiplicand, notMultiplicand, addResult, prodHigh, prodLow, shiftedLow, nextProdHigh, nextProdLow, multiplicandSelect, nextProdHighMult, nextProdHighDiv, shiftedLowMult, shiftedLowDiv,
        notOperandA, negatorOutput, absOperandA, useOperandA, divisionSubResult, divisionResult, negatorInput, notDivisionSubResult;
    wire [5:0] counter;
    wire [3:0] upperBitsOnePart, upperBitsZeroPart, resultNonZeroPart, divisorZeroPart;

    // Make sure the operands are positive for division
    not32 NotOperandA(notOperandA, data_operandA);
    cla NegatorCLA(negatorInput, 32'b1, 1'b0, negatorOutput);
    assign absOperandA = data_operandA[31] ? negatorOutput : data_operandA;
    assign useOperandA = isMultiplying ? data_operandA : absOperandA;

    assign negatorInput = data_resultRDY ? notDivisionSubResult : notOperandA;

    xor PredictResultSign(predictResultSign, data_operandA[31], data_operandB[31]);
    dffe_ref ResultSign(resultSign, predictResultSign, clock, gotCTRLSignal, 1'b0);

    or GotCTRLSignal(gotCTRLSignal, ctrl_MULT, ctrl_DIV);

    dffe_ref IsMultiplying(isMultiplying, ctrl_MULT, clock, gotCTRLSignal, 1'b0);
    not IsDividing(isDividing, isMultiplying);

    // Reset when the algorithm starts
    // or right after it hits 31 (so the ready signal isn't on more than a cycle)
    //and CounterDone(counterDone, counter[0], counter[1], counter[2], counter[3], counter[4]);
    and CounterPastDone(counterPastDone, counter[5], counter[0]);
    or ResetCounter(resetCounter, gotCTRLSignal, counterPastDone);
    counter6 Counter(counter, clock, 1'b1, resetCounter);
    assign data_resultRDY = counter[5];

    register32 Multiplicand(clock, gotCTRLSignal, 1'b0, data_operandB, multiplicand);
    not32 NotMultiplicand(notMultiplicand, multiplicand);

    mux2 MultiplicandSelect(multiplicandSelect, subtractMultiplicand, multiplicand, notMultiplicand);

    register32 ProductHigh(clock, 1'b1, gotCTRLSignal, nextProdHigh, prodHigh);
    register32 ProductLow(clock, 1'b1, 1'b0, nextProdLow, prodLow);
    dffe_ref ExtraLowBit(extraLowBit, prodLow[0], clock, 1'b1, gotCTRLSignal);
    assign divisionSubResult = {prodLow[30:0], trialSubSuccess};
    not32 NotDivisionSubResult(notDivisionSubResult, divisionSubResult);
    assign divisionResult = resultSign ? negatorOutput : divisionSubResult;
    assign data_result = isMultiplying ? prodLow : divisionResult;

    cla Adder(multiplicandSelect, prodHigh, subtractMultiplicand, addResult);

    assign shiftedLowMult = useAdditionResult ? {addResult[0], prodLow[31:1]} : {prodHigh[0], prodLow[31:1]};
    assign shiftedLowDiv = {prodLow[30:0], trialSubSuccess};
    assign shiftedLow = isMultiplying ? shiftedLowMult : shiftedLowDiv;

    assign nextProdHighMult = useAdditionResult ? {addResult[31], addResult[31:1]} : {prodHigh[31], prodHigh[31:1]};
    assign nextProdHighDiv = useAdditionResult ? {addResult[30:0], prodLow[31]} : {prodHigh[30:0], prodLow[31]};
    assign nextProdHigh = isMultiplying ? nextProdHighMult : nextProdHighDiv;
    mux2 NextProdLow(nextProdLow, gotCTRLSignal, shiftedLow, useOperandA);

    // Some Booth Logic
    not NotExtraLowBit(notExtraLowBit, extraLowBit);
    and Booth10(booth10, prodLow[0], notExtraLowBit);
    // If we're dividing and the divisor is already negative, don't worry about negating it
    assign subtractMultiplicand = isMultiplying ? booth10 : notMultiplicand[31];
    // 10 or 01 in booth control bits and multiplying
    xor BoothDoSomething(boothDoSomething, prodLow[0], extraLowBit);
    and UseAdditionResultMult(useAdditionResultMult, boothDoSomething, isMultiplying);
    // Trial subtraction was positive and dividing
    not TrialSubSuccess(trialSubSuccess, addResult[31]);
    and UseAdditionResultDiv(useAdditionResultDiv, trialSubSuccess, isDividing);
    or UseAdditionResult(useAdditionResult, useAdditionResultMult, useAdditionResultDiv);

    // Exception handling 
    and UpperBitsOnePart0(upperBitsOnePart[0], prodHigh[0], prodHigh[1], prodHigh[2], prodHigh[3], prodHigh[4], prodHigh[5], prodHigh[6], prodHigh[7]);
    and UpperBitsOnePart1(upperBitsOnePart[1], prodHigh[8], prodHigh[9], prodHigh[10], prodHigh[11], prodHigh[12], prodHigh[13], prodHigh[14], prodHigh[15]);
    and UpperBitsOnePart2(upperBitsOnePart[2], prodHigh[16], prodHigh[17], prodHigh[18], prodHigh[19], prodHigh[20], prodHigh[21], prodHigh[22], prodHigh[23]);
    and UpperBitsOnePart3(upperBitsOnePart[3], prodHigh[24], prodHigh[25], prodHigh[26], prodHigh[27], prodHigh[28], prodHigh[29], prodHigh[30], prodHigh[31]);
    and UpperBitsOne(upperBitsOne, upperBitsOnePart[0], upperBitsOnePart[1], upperBitsOnePart[2], upperBitsOnePart[3]);

    nor UpperBitsZeroPart0(upperBitsZeroPart[0], prodHigh[0], prodHigh[1], prodHigh[2], prodHigh[3], prodHigh[4], prodHigh[5], prodHigh[6], prodHigh[7]);
    nor UpperBitsZeroPart1(upperBitsZeroPart[1], prodHigh[8], prodHigh[9], prodHigh[10], prodHigh[11], prodHigh[12], prodHigh[13], prodHigh[14], prodHigh[15]);
    nor UpperBitsZeroPart2(upperBitsZeroPart[2], prodHigh[16], prodHigh[17], prodHigh[18], prodHigh[19], prodHigh[20], prodHigh[21], prodHigh[22], prodHigh[23]);
    nor UpperBitsZeroPart3(upperBitsZeroPart[3], prodHigh[24], prodHigh[25], prodHigh[26], prodHigh[27], prodHigh[28], prodHigh[29], prodHigh[30], prodHigh[31]);
    and UpperBitsZero(upperBitsZero, upperBitsZeroPart[0], upperBitsZeroPart[1], upperBitsZeroPart[2], upperBitsZeroPart[3]);

    or ResultNonZeroPart0(resultNonZeroPart[0], prodLow[0], prodLow[1], prodLow[2], prodLow[3], prodLow[4], prodLow[5], prodLow[6], prodLow[7]);
    or ResultNonZeroPart1(resultNonZeroPart[1], prodLow[8], prodLow[9], prodLow[10], prodLow[11], prodLow[12], prodLow[13], prodLow[14], prodLow[15]);
    or ResultNonZeroPart2(resultNonZeroPart[2], prodLow[16], prodLow[17], prodLow[18], prodLow[19], prodLow[20], prodLow[21], prodLow[22], prodLow[23]);
    or ResultNonZeroPart3(resultNonZeroPart[3], prodLow[24], prodLow[25], prodLow[26], prodLow[27], prodLow[28], prodLow[29], prodLow[30], prodLow[31]);
    or ResultNonZero(resultNonZero, resultNonZeroPart[0], resultNonZeroPart[1], resultNonZeroPart[2], resultNonZeroPart[3]);

    xor CheckSigns(checkSigns, extraLowBit, prodLow[31], multiplicand[31]);
    and SignsBad(signsBad, checkSigns, resultNonZero);

    nor UpperBitsDiff(upperBitsDiff, upperBitsOne, upperBitsZero);
    or DataExceptionMult(dataExceptionMult, upperBitsDiff, signsBad);

    nor DivisorZeroPart0(divisorZeroPart[0], multiplicand[0], multiplicand[1], multiplicand[2], multiplicand[3], multiplicand[4], multiplicand[5], multiplicand[6], multiplicand[7]);
    nor DivisorZeroPart1(divisorZeroPart[1], multiplicand[8], multiplicand[9], multiplicand[10], multiplicand[11], multiplicand[12], multiplicand[13], multiplicand[14], multiplicand[15]);
    nor DivisorZeroPart2(divisorZeroPart[2], multiplicand[16], multiplicand[17], multiplicand[18], multiplicand[19], multiplicand[20], multiplicand[21], multiplicand[22], multiplicand[23]);
    nor DivisorZeroPart3(divisorZeroPart[3], multiplicand[24], multiplicand[25], multiplicand[26], multiplicand[27], multiplicand[28], multiplicand[29], multiplicand[30], multiplicand[31]);
    and DivisorZero(divisorZero, divisorZeroPart[0], divisorZeroPart[1], divisorZeroPart[2], divisorZeroPart[3]);

    assign data_exception = isMultiplying ? dataExceptionMult : divisorZero;
endmodule