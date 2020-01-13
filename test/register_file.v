
module register_file(
    input clk,
    // Number of register to read on port 1
    input [4:0] in_reg_number_1,
    // Number of register to read on port 2
    input [4:0] in_reg_number_2,
    // Whether to write to a register in the next cycle
    input in_write_enable,
    // Which register to write to
    input [4:0] in_write_number,
    // What to write to the register
    input [32-1:0] in_write_value,
    // Value read from register on port 1
    output reg [32-1:0] out_reg_value_1,
    // Value read from register on port 2
    output reg [32-1:0] out_reg_value_2
);

logic [31:0] memory [0:31];

always_ff @(posedge clk) begin
    if (in_write_enable && in_write_number != 0)
    begin
        memory[in_write_number] <= in_write_value;
    end
end

always_comb begin
    out_reg_value_1 = memory[in_reg_number_1];
    out_reg_value_2 = memory[in_reg_number_2];

    // Concurrent write/read forwarding
    if (in_write_enable) begin
        if (in_reg_number_1 == in_write_number)
            out_reg_value_1 = in_write_value;
        if (in_reg_number_2 == in_write_number)
            out_reg_value_2 = in_write_value;
    end

    // Register x0 behavior override
    if (in_reg_number_1 == 0)
        out_reg_value_1 = 0;
    if (in_reg_number_2 == 0)
        out_reg_value_2 = 0;
end

endmodule

`default_nettype wire
