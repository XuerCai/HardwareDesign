`timescale 1ns / 1ps
`include "defines.vh"
//分支部分参考ppt
module maindec(
	input wire[5:0] op,
	input wire[5:0] funct,
	input wire[4:0] rt,
	input [31:0] instr,
	input stallD,
	output wire memtoreg,memen,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire cp0we,cp0read,eret,syscall,break,
	output reg jal,jr,bal,writeTo31,
	output reg HLwrite
	//output wire[1:0] aluop
    );
	reg[6:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump} = controls;
	//错误0106：极其严重错误，括号加错导致逻辑错误，很难找到的bug。导致取值与取数据冲突，从而取出错误的指令
	/*[5961634 ns] Error!!!
    reference: PC = 0xbfc00d84, wb_rf_wnum = 0x0b, wb_rf_wdata = 0x00000000
    mycpu    : PC = 0xbfc00d7c, wb_rf_wnum = 0x08, wb_rf_wdata = 0xffffffff
	*/
	assign memen =( (op == `EXE_LB)||(op == `EXE_LBU)||(op == `EXE_LH)||
                (op == `EXE_LHU)||(op == `EXE_LW)||(op == `EXE_SB)||(op == `EXE_SH)||(op == `EXE_SW))&& ~stallD;

	//op觉得控制信号
	always @(*) begin
		jal<=0;jr<=0;bal<=0;writeTo31<=0;
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
			//选择正常的路径
			`EXE_JALR:begin
				controls <= 7'b1100000;
				jr<=1;
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
				controls <= 7'b1000000;
				jal<=1;
				writeTo31<=1;
			end
			`EXE_REGIMM_INST:begin
				case(rt)
				`EXE_BLTZ,`EXE_BGEZ:controls <= 7'b0001000;
				`EXE_BLTZAL,`EXE_BGEZAL:begin
					//错误：未把regwrite置位1
					controls <= 7'b1001000;
					bal<=1;
					writeTo31<=1;
				end
				endcase
			end

			//访存指令
			`EXE_LW,`EXE_LB,`EXE_LBU,`EXE_LH,`EXE_LHU,`EXE_LW:controls <= 7'b1010010;
			`EXE_SW,`EXE_SB,`EXE_SH:controls <= 7'b0010100;
			//错误0104逻辑没有添加
			//错误0104 应该为00000
			//错误0104，此外的逻辑beginend
			6'b010000:begin if(instr[25:21]==5'b00000)controls<=7'b1000000;//MFC0
			else controls<=7'b0000000;//除MFC0
			end
			//内陷指令
			//特权指令
			default:  controls <= 7'b0000000;
		endcase
		end
		////////////////////////////////////////
		//错误0106：及其严重的bug，导致了一天的debug
		//只能在不stall的时候出结果，否则trace无法判断。其实不算bug。
		if(stallD)begin
			controls[6]<=0;
			controls[4]<=0;
			controls[1]<=0;
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

assign break = (op == `EXE_SPECIAL_INST && funct == `EXE_BREAK)&& ~stallD;

assign syscall = (op == `EXE_SPECIAL_INST && funct == `EXE_SYSCALL)&& ~stallD;

assign eret = (instr == `EXE_ERET)&& ~stallD;

assign cp0we = (instr[31:21] == 11'b01000000100 && instr[10:0] == 11'b00000000000); //MTC0

assign cp0read = (instr[31:21] == 11'b01000000000 && instr[10:0] == 11'b00000000000); //MFC0
endmodule
