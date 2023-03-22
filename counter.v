module counter6(out, clk, en, clr);
    input clk, en, clr;
    output [5:0] out;

    wire toggle2, toggle3, toggle4, toggle5;

    tff Bit1(out[0], 1'b1, clk, en, clr);
    tff Bit2(out[1], out[0], clk, en, clr);
    and Toggle2(toggle2, out[1], out[0]);
    tff Bit3(out[2], toggle2, clk, en, clr);
    and Toggle3(toggle3, out[2], out[1], out[0]);
    tff Bit4(out[3], toggle3, clk, en, clr);
    and Toggle4(toggle4, out[3], out[2], out[1], out[0]);
    tff Bit5(out[4], toggle4, clk, en, clr);
    and Toggle5(toggle5, out[4], out[3], out[2], out[1], out[0]);
    tff Bit6(out[5], toggle5, clk, en, clr);
endmodule

module tff(q, t, clk, en, clr);
    input t, clk, en, clr;
    output q;

    wire d, stayOn, toggleOn, notToggle, notOut;

    not NotToggle(notToggle, t);
    not NotOut(notOut, q);

    and StayOn(stayOn, notToggle, q);
    and ToggleOn(toggleOn, t, notOut);

    or D(d, stayOn, toggleOn);

    dffe_ref DFF(q, d, clk, en, clr);
endmodule