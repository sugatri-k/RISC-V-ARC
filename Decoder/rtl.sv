module decoder(
    input  logic [31:0] instruction,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [6:0]  opcode,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3,
    output logic [11:0] imm,
    output logic [19:0] imm_uj,
    output logic        fn7_5
);

    assign opcode = instruction[6:0];

    always_comb begin
        // defaults: everything except opcode is 0 (no latches)
        rs1     = 5'b0;
        rs2     = 5'b0;
        rd      = 5'b0;
        imm11_5 = 7'b0;
        fn3     = 3'b0;
        imm     = 12'b0;
        imm_uj  = 20'b0;
        fn7_5   = 1'b0;

        case (instruction[6:0])
            7'b0110011: begin // R-type
                rd    = instruction[11:7];
                fn3   = instruction[14:12];
                rs1   = instruction[19:15];
                rs2   = instruction[24:20];
                fn7_5 = instruction[30];
            end

            7'b0010011: begin // I-type ALU
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
                imm11_5 = instruction[31:25];
            end

            7'b0000011: begin // Load
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end

            7'b0100011: begin // Store
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {instruction[31:25], instruction[11:7]};
            end

            7'b1100011: begin // Branch
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                imm = {instruction[31], instruction[7],
                       instruction[30:25], instruction[11:8]};
            end

            7'b1101111: begin // JAL
                rd     = instruction[11:7];
                imm_uj = {instruction[31], instruction[19:12],
                          instruction[20], instruction[30:21]};
            end

            7'b1100111: begin // JALR
                rd  = instruction[11:7];
                fn3 = instruction[14:12];
                rs1 = instruction[19:15];
                imm = instruction[31:20];
            end

            7'b0110111: begin // LUI
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end

            7'b0010111: begin // AUIPC
                rd     = instruction[11:7];
                imm_uj = instruction[31:12];
            end

            default: ; // unsupported: all outputs stay 0 except opcode
        endcase
    end

endmodule