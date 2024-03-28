`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.06.2023 14:10:38
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench(

    );

    
        logic  clk,
          reset,
         isexternal, ldIM, ldRF, process;
         logic [6:0] sw;
        logic [6:0] seg;
        logic [3:0] an ;
        logic Clk; 
       
    processor dut(clk,
          reset,
         isexternal, ldIM, ldRF, process,
    sw,
         seg,
          an ,
        Clk
       );
    
    initial begin
    clk = 0;#1;
    reset = 0;#1;
    clk = 1;#1;
    reset = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    isexternal = 0;#1
    clk = 0;#1;
    clk = 1;#1;
    reset = 0; #1;
    clk = 0;#1; 
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    ldRF = 1;#1;
    sw[6:3] = 3'b001; #1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    reset = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    reset = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    sw[2:0] = 110; 
   /* clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1 
    button = 1;#1; 
    reset = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    button = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    button = 1;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    reset = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    switches = 12'b101_001_000_010;#1
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1
    button = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;  
    switches = 12'b101_001_000_001;#1;
    button = 1;#1;  
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1; 
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1; 
    clk = 1;#1;
    clk = 0;#1; 
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    button = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    isexternal = 1;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;
    clk = 1;#1;
    clk = 0;#1;     */
    end
endmodule   
