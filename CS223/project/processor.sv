    `timescale 1ns / 1ps


    module three_bit_mux(
        input logic s, [2:0] a, [2:0] b,
        output logic [2:0] out 
    );
    
        always@ (s or a or b )
        begin
            if( s == 0 )
               out = a;
            else 
               out = b;  
        end     
         
    endmodule
    
    module four_bit_mux(
        input logic s, [3:0] a, [3:0] b,
        output logic [3:0] out 
    );
    
        always@ (s or a or b )
        begin
            if( s == 0 )
                out = a;
            else 
                out = b;  
        end     
         
    endmodule 
    
  
    
    module clockDivider( input logic clk, output logic [31:0] ctrx, output logic outClk );
         logic [27:0] ctr = 1;
         logic temporaryClk = 0;
         always @ (posedge clk)
            begin
                if(ctr == 250000000)
                    begin
                         ctr <= 0;
                        temporaryClk = ~temporaryClk;
                     end
                 else
                    ctr <= ctr + 1;
             end
          assign outClk = temporaryClk;
          assign ctrx = ctr;
     endmodule
    
    module program_counter(
        input logic clk, reset, increment,
        output logic [2:0] pco
    );
    
    always_ff @( posedge clk )
    begin 
       if( reset )
          pco <= 3'b000;  
       else if( increment )
        begin
          if(pco == 111)
                pco <= 3'b000;
            else
                pco <= pco + 1;
        end
    end
    endmodule
    
    
    module instruction_register(
        input logic clk, reset, [2:0] iri,
        output logic [2:0] iro
    );
    
    always_ff @( posedge clk )
    begin 
        if( reset )
            iro <= 3'b000;
        else    
            iro <= iri;
    end
    endmodule
    
    module instruction_memory(
        input logic clk, reset, [2:0] pc0, ld_IM, proceed, [2:0] swop,
        output logic [2:0] imo
    );
    
    logic [7:0] [2:0] IM;
    
    
           always_ff@(posedge clk)
        begin
           if ( reset )
           begin
                IM[0] <= 3'b000;
                IM[1] <= 3'b000;
                IM[2] <= 3'b000;
                IM[3] <= 3'b000;
                IM[4] <= 3'b000;
                IM[5] <= 3'b000;
                IM[6] <= 3'b000;
                IM[7] <= 3'b000;
           end
            else 
            begin
                if( ld_IM )
                begin 
                    IM[7] <= IM[6];
                    IM[6] <= IM[5];
                    IM[5] <= IM[4];
                    IM[4] <= IM[3];
                    IM[3] <= IM[2];
                    IM[2] <= IM[1];
                    IM[1] <= IM[0];
                    IM[0] <= swop;
                end
               
                else if( proceed )
                begin 
                case(pc0)
                    3'b000: imo = IM[0]; 
                    3'b001: imo = IM[1]; 
                    3'b010: imo = IM[2]; 
                    3'b011: imo = IM[3]; 
                    3'b100: imo = IM[4]; 
                    3'b101: imo = IM[5]; 
                    3'b110: imo = IM[6]; 
                    3'b111: imo = IM[7]; 
                endcase
                end
            end   
       
        end
        

    endmodule
    
    module controller(
        input logic isexternal, [6:0]sw, clk, [2:0] IR  , reset, ldRF, ldIM, process,
        output logic M_re,  M_we, RF_we, RF_re, RF_oc, pc_clr , increment, [1:0] ALU_op, RF_mux_s, isDisplay, [3:0] swd, ld_RF, ld_IM, Proceed, [2:0] swop
        );
        
        typedef enum logic [ 2:0 ] { Init, LoadRF, LoadIM, Fetch, External, Decode } statetype;
        statetype state, nextstate;
        
        logic [2:0] op;
        //assign isDisplay = 0;
        
        always_ff@(posedge clk)
        begin
            if( reset )
                begin 
                    state <= Init;
                    pc_clr <= 1;
                end 
            else
                state <= nextstate;   
        end    
        
        always_comb
        begin
            case( state )
                Init: 
                    if(ldRF)
                    begin
                        RF_we <= 1;
                        swd <= sw[6:3]; 
                        ld_RF <= ldRF;
                        nextstate <= LoadRF;
                    end
                    else if(ldIM)
                    begin
                        ld_IM <= ldIM;
                        swop <= sw[2:0];
                        nextstate <= LoadIM;
                    end
                    else if(isexternal )
                    begin
                        op <= sw[2:0];
                        nextstate <= External;
                    end
                    else if( process) 
                        nextstate <= Fetch ;   
                    else 
                        nextstate <= Init;
                        
                        
                LoadRF:
                begin 
                end
                
                LoadIM:
                begin 
                end 
                
                External: 
                    begin
                        op <= sw[2:0];
                         increment <= 0;
                        nextstate <= Decode;
                    end
                    
                Fetch: 
                    begin
                        op <= IR;
                        increment <= 1;
                        nextstate <= Decode;
                    end
                    
                Decode: 
                begin
           
                       case( op )
    
                            3'b000:  //Load
                            begin 
                                M_re <= 1;
                                M_we <= 0;
                                RF_we <= 1;
                                RF_re <= 0;
                                RF_oc <= 0;
                                RF_mux_s = 1;
                                isDisplay <= 0;
                                
                                nextstate <= External;
                            end 
                            
                            3'b001:  //Store
                            begin
                                M_re <= 0;
                                M_we <= 1;
                                RF_we <= 0;
                                RF_re <= 1;
                                RF_oc <= 0;
                                isDisplay <= 0;
                                //RF_mux_s = 1;
                              
                                nextstate <= External;
                            end 
                            3'b010:  //Subtract
                            begin
                                ALU_op <= 2'b00;
                                RF_mux_s = 0;
                                RF_we <= 0; 
                                RF_re <= 1;
                                RF_oc <= 1;
                                M_re <= 0;
                                M_we <= 0;
                                isDisplay <= 0;
                                
                                nextstate <= External;
                            end   
                            
                            3'b011:   //Add
                           
                            begin   
                                ALU_op <= 2'b01;
                                RF_mux_s = 0;
                                RF_we <= 0;
                                RF_re <= 1;
                                RF_oc <= 1;
                                M_re <= 0;
                                M_we <= 0;
                                isDisplay <= 0;
                                
                                nextstate <= External;
                            end
                            
                            3'b100:   // Multiply
                            begin
                                ALU_op <= 2'b10;
                                RF_mux_s = 0;
                                RF_we <= 0;
                                RF_re <= 1;
                                RF_oc <= 1;
                                M_re <= 0;
                                M_we <= 0;
                                isDisplay <= 0;
                                
                                nextstate = External;
                            end
                                      
                            3'b101:   //Divide
                            begin   
                                ALU_op <= 2'b11; 
                                RF_mux_s = 0;
                                RF_we <= 0;
                                RF_re <= 1;
                                RF_oc <= 1;
                                M_re <= 0;
                                M_we <= 0;
                                isDisplay <= 0;
                                
                                nextstate = External;
                            end
                            
                            3'b110:  //Display
                            begin
                                RF_mux_s = 1;
                                RF_we <= 0;
                                RF_re <= 1;
                                RF_oc <= 0;
                                M_re <= 0;
                                M_we <= 0;
                                isDisplay <= 1;
                                
                                nextstate = External;
                            end
                           
                          
                            endcase 
                            end
                            endcase
                            end
    endmodule
    
    
    
    module control_unit(    
        /*input logic pc_sel,*/
        input logic clk,
        input logic reset,
        input logic isexternal, ldIM, ldRF, process,
        input logic [6:0] sw,
   
        output logic RF_we,
        output logic [3:0] swd,
        output logic RF_re, RF_oc,
        output logic M_re,
        output logic M_we,
        output logic[1:0] ALU_op,
        output logic isDisplay, ld_RF
        );
        
    
        logic [2:0] iro;
        logic [2:0] pco;
        //logic [2:0] swd;
        logic [2:0] swop;
        
         
           
        instruction_memory IM( clk, reset, pco, ld_IM, proceed, swop, imo );
        
        instruction_register IR( clk, reset, imo, iro );
        controller CTR( isexternal, sw, clk, iro, reset, ldRF, ldIM, process, M_re,  M_we, RF_we, RF_re, RF_oc, pc_clr, increment, ALU_op, RF_mux_s, isDisplay, swd, ld_RF, ld_IM, Proceed, swop  );
    program_counter PC( clk, reset, increment, pco ); 
    endmodule 
    
    
    
    module data_memory ( 
        input logic clk, reset, M_re, M_we, M_wd,
        output logic [3:0] M_rd 
        );
        
        logic [15:0] [3:0] D;
        
        always_ff@(posedge clk)
        begin
        if( reset ) 
        begin 
            D[0] <= 4'b0000;
            D[1] <= 4'b0000;
            D[2] <= 4'b0000;
            D[3] <= 4'b0000;
            D[4] <= 4'b0000;
            D[5] <= 4'b0000;
            D[6] <= 4'b0000;
            D[7] <= 4'b0000;
            D[8] <= 4'b0000;
            D[9] <= 4'b0000;
            D[10] <= 4'b0000;
            D[11] <= 4'b0000;
            D[12] <= 4'b0000;
            D[13] <= 4'b0000;
            D[14] <= 4'b0000;
            D[15] <= 4'b0000;
        end
        
        else if( M_re )
        begin
            M_rd  <= D[15];
            D[15] <= D[14];
            D[14] <= D[13];
            D[13] <= D[12];
            D[12] <= D[11];
            D[11] <= D[10];
            D[10] <= D[9];
            D[9] <= D[8];
            D[8] <= D[7];
            D[7] <= D[6];
            D[6] <= D[5];
            D[5] <= D[4];
            D[4] <= D[3];
            D[3] <= D[2];
            D[2] <= D[1];
            D[1] <= D[0];
            D[0] <= 4'b0000;
        end    
        else if( M_we )
        begin   
            D[0] <= D[1];
            D[1] <= D[2];
            D[2] <= D[3];
            D[3] <= D[4];
            D[4] <= D[5];
            D[5] <= D[6];
            D[6] <= D[7];
            D[7] <= D[8];
            D[8] <= D[9];
            D[9] <= D[10];
            D[10] <= D[11];
            D[11] <= D[12];
            D[12] <= D[13];
            D[13] <= D[14];
            D[14] <= D[15];
            D[15] <= M_wd;
        end
        end
    endmodule
    
    module register_file (
        input logic clk, [3:0] RF_wd, input logic RF_we, RF_re, RF_oc, reset, ldRF, [3:0] swd,
        output logic  [3:0] RF_d1, [3:0] RF_d2
        );
        logic [7:0] [3:0] RF;
        
        always_ff@(posedge clk)
        begin
           if ( reset )
           begin
                RF[0] <= 4'b0000;
                RF[1] <= 4'b0000;
                RF[2] <= 4'b0000;
                RF[3] <= 4'b0000;
                RF[4] <= 4'b0000;
                RF[5] <= 4'b0000;
                RF[6] <= 4'b0000;
                RF[7] <= 4'b0000;
           end
            else if( RF_we == 1 )
            begin
                if( ldRF )
                begin 
                    RF[0] <= RF[1];
                    RF[1] <= RF[2];
                    RF[2] <= RF[3];
                    RF[3] <= RF[4];
                    RF[4] <= RF[5];
                    RF[5] <= RF[6];
                    RF[6] <= RF[7];
                    RF[7] <= swd;
                end
               
                else
                begin 
                    RF[0] <= RF[1];
                    RF[1] <= RF[2];
                    RF[2] <= RF[3];
                    RF[3] <= RF[4];
                    RF[4] <= RF[5];
                    RF[5] <= RF[6];
                    RF[6] <= RF[7];
                    RF[7] <= RF_wd;
                end
            end   
            
            
            else if( RF_re == 1 )
            begin 
                if( RF_oc == 1)
                begin 
                    RF_d1 <= RF[7];
                    RF_d2 <= RF[6];
                    RF[7] <= RF[5];
                    RF[6] <= RF[4];
                    RF[5] <= RF[3];
                    RF[4] <= RF[2];
                    RF[3] <= RF[1];
                    RF[2] <= RF[0];
                    RF[1] <= 4'b0000;
                    RF[0] <= 4'b0000;
                end
                else if( RF_oc ==0 )
                begin
                    RF_d1 <= RF[7];
                    RF[7] <= RF[6];
                    RF[6] <= RF[5];
                    RF[5] <= RF[4];
                    RF[4] <= RF[3];
                    RF[3] <= RF[2];
                    RF[2] <= RF[1];
                    RF[1] <= RF[0];
                    RF[0] <= 4'b0000;
                end
            end
        end
    endmodule 
    
    module ALU (
        input logic [3:0] ALU_d1,  [3:0] ALU_d2, [1:0] ALU_op, isDisplay,
        output logic [3:0] ALU_out1, [3:0] ALU_out2, [3:0] out_a, [3:0] out_b
        ); 
        always_comb
        begin 
        
        out_a = ALU_d1;
        out_b = ALU_d2;
        
        if( isDisplay )
            out_b = ALU_d1;       
        
        case(ALU_op)
        00: //sub 
        //subtracter
        begin 
            ALU_out1 = 4'b0000;
            ALU_out2 = ALU_d1 - ALU_d2;  
        end 
        01: //add
        begin
            ALU_out1 = 4'b0000;
            ALU_out2 = ALU_d1 + ALU_d2;
        end 
        10: //multip
        begin 
            ALU_out1 = 4'b0000;
            ALU_out2 = ALU_d1 * ALU_d2;
        end 
        11 : //div
        begin 
            ALU_out1 = ALU_d1 / ALU_d2;
            ALU_out2 = ALU_d1 - ( ALU_out1 * ALU_d2 ); 
        end
        endcase
        end 
        
    endmodule 
    
    module datapath ( 
       input logic clk, reset, RF_mux_s, ALU_src_sel, [1:0] ALU_op, RF_we, M_re, RF_oc, M_wd, isDisplay, ldRF, [3:0] swd,
       output logic [3:0] ALU_out1, [3:0] ALU_out2, [3:0] out_a, [3:0] out_b
       ); 
       
       logic [3:0] M_rd;
       logic [3:0] ALU_d1;
       logic [3:0] ALU_d2;
      
       logic [3:0] RF_wd;
       logic [3:0] LED_a;
       logic [3:0] LED_b;
       
       data_memory DM ( clk, reset, M_re, M_we, M_wd, M_rd );
        
        
       register_file RF ( clk, RF_wd, RF_we, RF_re, RF_oc, reset, ldRF, swd, RF_d1, RF_d2 );
       
       ALU ALU ( ALU_d1, ALU_d2, ALU_op, isDisplay, ALU_out1, ALU_out2, out_a , out_b );
       
       four_bit_mux RF_mux( RF_mux_s, ALU_out, M_rd, RF_wd );
        
    endmodule    
    
    module processor ( 
        input  clk,
        input  reset,
        input isexternal, ldIM, ldRF, process,
        input logic [6:0] sw,
        output logic [6:0] seg, output logic [3:0] an , output logic Clk 
        );
        
         
         logic outClk, clk_debounce; 
         logic [27:0] ctr;
         logic RF_we;
         logic [3:0] RF_wd;
         logic RF_re;
         logic ld_RF;
         logic M_re;
         logic M_we;
         logic [1:0] ALU_op;
         logic [3:0] ALU_out;
         logic [3:0] out_a;
         logic [3:0] out_b;
         logic [3:0] out;
         logic isExternal, ld_im, ld_rf,Process,Reset;
            
         clockDivider cD( clk, ctr, outClk );
         assign Clk = outClk ;
         clock_enable( clk,clk_debounce );
         debounce ie (isexternal  ,clk_debounce, isExternal );
         debounce ldim(ldIM  ,clk_debounce, ld_im );
         debounce ldrf(ldRF  ,clk_debounce, ld_rf );
         debounce processx( process ,clk_debounce,Process );
         debounce  reset(reset ,clk_debounce,Reset);
         
        control_unit ctrl ( outClk, Reset, isExternal, ld_im, ld_rf, Process, sw, RF_we, swd, RF_re, RF_oc, M_re, M_we, ALU_op, isDisplay, ld_RF );
    

        datapath dp ( outClk, Reset, RF_mux_s, ALU_src_sel, ALU_op, RF_we, M_re, RF_oc, M_wd, isDisplay, ld_RF, swd, ALU_out1, ALU_out2, out_a, out_b );
        
    always_comb 
    begin
        case( ctr[20:19] )
        2'b00: begin
            an = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            out = out_a;
            // the first hex-digit of the 16-bit number
             end
        2'b01: begin
            an = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            out = out_b;
            // the second hex-digit of the 16-bit number
                end
        2'b10: begin
            an = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            out = ALU_out1;
             // the third hex-digit of the 16-bit number
              end
        2'b11: begin
            an = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
             out = ALU_out2;
             // the fourth hex-digit of the 16-bit number 
               end   
        default:begin
             an = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            out = 4'b0000;
            // the first hex-digit of the 16-bit number
            end
        endcase
    end
    
    sevenseg seg( out, seg );
    
    endmodule
    
module sevenseg(
    input logic[3:0] a, 
    output logic[6:0] LED_out
);
     
     always_comb begin
        case(a)
         4'b0000: LED_out = 7'b0000001; // "0"  
         4'b0001: LED_out = 7'b1001111; // "1" 
         4'b0010: LED_out = 7'b0010010; // "2" 
         4'b0011: LED_out = 7'b0000110; // "3" 
         4'b0100: LED_out = 7'b1001100; // "4" 
         4'b0101: LED_out = 7'b0100100; // "5" 
         4'b0110: LED_out = 7'b0100000; // "6" 
         4'b0111: LED_out = 7'b0001111; // "7" 
         4'b1000: LED_out = 7'b0000000; // "8"  
         4'b1001: LED_out = 7'b0000100; // "9" 
         default: LED_out = 7'b0000001; // "0"
        endcase
    end         
endmodule

module debounce (input button ,clk,output buttono);

logic Q1,Q2,Q2_bar,Q0;
clockDivider cd(clk, ctr, outClk);
dff d0(clk,outClk,button,Q0);

dff d1(clk,outClk,Q0,Q1);
dff d2(clk,outClk,Q1,Q2);

assign Q2_bar = ~Q2;
assign  buttono = Q1 & Q2_bar;
endmodule


module dff(input clk, outClock,D, output logic Q=0);
  always @ (posedge clk) 
  begin
  if(outClock==1) 
           Q <= D;
  end
endmodule 

module clock_enable(input Clk_100M,output slow_clk_en);
    logic [24:0]counter=0;
    always @(posedge Clk_100M)
    begin
       counter <= (counter>=15999999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 15999999)?1'b1:1'b0;
endmodule
