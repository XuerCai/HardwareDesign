`timescale 1ns / 1ps
`include "defines.vh"
module maindec(
	input wire[5:0] op,
	input wire[5:0] funct,
	input wire[4:0] rt,
	output wire memtoreg,memen,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output reg jal,jr,bal,
	output reg HLwrite
	//output wire[1:0] aluop
    );
	reg[7:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump} = controls;

	//op觉得控制信号
	always @(*) begin
		jal<=0;jr<=0;bal<=0;
		if(op==`EXE_NOP)begin
			case(funct)
			//TODO

			//逻辑运算指令
			//移位指令
			//数据移动指令
			//算数运算指令
			//分支跳转指令
			`EXE_JR:begin
				controls <= 7'b0000001;
				jr<=1;
			end
			`EXE_JALR:begin
				controls <= 7'b1000001;
				jr<=1;
				jal<=1;
			end
			//访存指令
			//内陷指令
			//特权指令
			default:controls <= 7'b1100000;
		endcase
		end
		else begin
			case (op)
			//逻辑运算指令
			`EXE_ANDI,`EXE_XORI,`EXE_LUI,`EXE_ORI:controls <= 7'b1010000;
			//移位指令
			//数据移动指令
			//算数运算指令
			`EXE_ADDI,`EXE_ADDIU,`EXE_SLTI,`EXE_SLTIU:controls <= 7'b1010000;
			//分支跳转指令
			`EXE_BEQ,`EXE_BGTZ,`EXE_BLEZ,`EXE_BNE:controls <= 7'b0001000;
			`EXE_J:controls <= 7'b0000001;
			//使用了与ppt不一样的逻辑
			`EXE_JAL:begin
				controls <= 7'b1000001;
				jal<=1;
			end
			`EXE_REGIMM_INST:begin
				case(rt)
				`EXE_BLTZ,`EXE_BGEZ:controls <= 7'b0001000;
				`EXE_BLTZAL,`EXE_BGEZAL:begin
					controls <= 7'b0001000;
					bal<=1;
				end
				endcase
			end

			//访存指令
			`EXE_LW:controls <= 7'b1010010;
			`EXE_SW:controls <= 7'b0010100;
			//内陷指令
			//特权指令
			default:  controls <= 7'b0000000;
		endcase
		end
	end

	//HLwrite的逻辑
	always@(*)begin
		HLwrite<=0;
		if(op==`EXE_NOP)begin
			case(funct)
			`EXE_MTHI:HLwrite<=1;
			`EXE_MTLO:HLwrite<=1;
			`EXE_MULT:HLwrite<=1;
			`EXE_MULTU:HLwrite<=1;
			`EXE_DIV:HLwrite<=1;
			`EXE_DIVU:HLwrite<=1;
			default:HLwrite<=0;
			endcase
		end
	end
endmodule
