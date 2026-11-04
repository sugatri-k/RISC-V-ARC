module imm_generator(
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);

    always_comb begin
        // default: sign-extended 12-bit (load, store, R-type, other)
        imm_output = {{20{imm_input[11]}}, imm_input};

        case (opcode)
            7'b1100011: // Branch: sign_extend(imm) << 1
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};

            7'b1101111: // JAL: sign_extend(imm_uj, 20-bit) << 1
                imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};

            7'b0110111, // LUI
            7'b0010111: // AUIPC
                imm_output = {imm_input_uj, 12'b0};

            7'b1100111: // JALR
                imm_output = {{20{imm_input[11]}}, imm_input};

            7'b0010011: begin // I-type ALU
                if (fn3 == 3'b001 || fn3 == 3'b101)
                    imm_output = {27'b0, imm_input[4:0]};   // shift amount
                else
                    imm_output = {{20{imm_input[11]}}, imm_input};
            end

            default:
                imm_output = {{20{imm_input[11]}}, imm_input};
        endcase
    end

endmodule