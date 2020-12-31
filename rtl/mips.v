`timescale 1ns / 1ps


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,

	output wire [4:0] rsE,rtE,rdE,
	output wire [4:0] rsD,rtD,rdD,

	output lwstallD,branchstallD,

	output stallF,
	output flushE,stallD
);
	
	wire [5:0] opD,functD;
	wire [4:0] InstrRtD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire regwriteE,regwriteM,regwriteW;
	wire HLwriteM,HLwriteW;
	wire [7:0] alucontrolE;
	wire flushE,equalD;
	wire stallD,stallE,stallM,stallW,flushM,flushW;

	controller c(
		clk,rst,
		//取指令阶段信号
		opD,functD,InstrRtD,
		pcsrcD,branchD,jumpD,
		
        equalD,

		//运算级信号
		flushE,stallE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,

		//内存访问级信号
		memtoregM,memwriteM,
		regwriteM,HLwriteM,
		stallM,flushM,
		//写回级信号
		memtoregW,regwriteW,
		HLwriteW,stallW,flushW
	);

	datapath dp(
		clk,rst,
		//取指令阶段信号
		pcF,
		instrF,
		//指令译码阶段信号
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		InstrRtD,
		//运算级信号
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,
		//内存访问级信号
		memtoregM,
		regwriteM,
		HLwriteM,
		aluoutM,writedataM,
		readdataM,
		flushM,
		//写回级信号
		memtoregW,
		regwriteW,
		HLwriteW,
		flushW,
		rsE,rtE,rdE,
	    rsD,rtD,rdD,
		lwstallD,branchstallD,
	    stallF,
	    stallD,
		stallE,
		stallM,
		stallW
	);
	
endmodule
