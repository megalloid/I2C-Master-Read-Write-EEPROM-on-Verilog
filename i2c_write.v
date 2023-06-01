module i2c_write (
    CLOCK,
    LED,
  RESET,
    WRITE,
    I2C_SCLK,
    I2C_SDAT,
    COUNT,
    SD_COUNTER_OUT
);
 
 input    CLOCK;
 output [3:0]  LED;
 input      RESET;
 input    WRITE;
 output         I2C_SCLK;
 inout          I2C_SDAT;
 output [6:0]   SD_COUNTER_OUT;
 output [9:0]   COUNT;
 
 wire           reset_n;
 wire    write_n;
 
 reg            GO;
 reg [6:0]      SD_COUNTER = 6'b0;
 reg            SDI     = 1;
 reg            SCLK    = 1;
 reg [9:0]    COUNT;
 
 reg [7:0]      DATA = 8'b00000000;
 
 assign         reset_n = RESET;
 assign         write_n = WRITE;
 
 always @ (posedge CLOCK or negedge reset_n)
 begin
 
   if(~reset_n)
     GO <= 0;
   else
     if(~write_n)
     GO <= 1;
 end
 
 
 always @(posedge CLOCK or negedge reset_n)
 begin
 
   if(~reset_n)
     SD_COUNTER <= 6'b0;
   else
   begin
     if(!GO)
     SD_COUNTER <= 0;
     else
     if(SD_COUNTER < 33)
       SD_COUNTER <= SD_COUNTER + 1;
   end
   
 end
 

 // I2C OPERATION
 always @(posedge CLOCK or negedge reset_n)
 begin

  if(~reset_n)
  begin
   SCLK <= 1; 
   SDI <= 1;
  end
  
  else
  case (SD_COUNTER)
   
   6'd0 : begin 
    SDI <= 1; 
    SCLK <= 1; 
   end
   
   // START   
   6'd1 : SDI <= 0;
   6'd2 : SCLK <= 0;

   // SLAVE ADDRESS
   
   6'd3 : SDI <= 1;
   6'd4 : SDI <= 0;
   6'd5 : SDI <= 1;
   6'd6 : SDI <= 0;
   6'd7 : SDI <= 0;
   6'd8 : SDI <= 0;
   6'd9 : SDI <= 0;
   6'd10 : SDI <= 0;
   6'd11 : SDI <= 1'bz;
   
   // SUB ADDRESS
   
   6'd12 : SDI <= 0;
   6'd13 : SDI <= 0;
   6'd14 : SDI <= 0;
   6'd15 : SDI <= 0;
   6'd16 : SDI <= 0;
   6'd17 : SDI <= 0;
   6'd18 : SDI <= 0;
   6'd19 : SDI <= 0;
   6'd20 : SDI <= 1'bz;
   
   // DATA
   
   6'd21 : SDI <= 1;
   6'd22 : SDI <= 0;
   6'd23 : SDI <= 0;
   6'd24 : SDI <= 0;
   6'd25 : SDI <= 0;
   6'd26 : SDI <= 0;
   6'd27 : SDI <= 1;
   6'd28 : SDI <= 1;
   6'd29 : SDI <= 1'bz;

   6'd30 : begin SDI <= 1'b0; SCLK <= 1'b1; end
   6'd31 : SDI <= 1'b1;
   
  endcase
  
 end

 assign I2C_SCLK = ((SD_COUNTER >= 4) & (SD_COUNTER <= 31))? ~CLOCK : SCLK;
 assign I2C_SDAT = SDI;

 assign SD_COUNTER_OUT = SD_COUNTER;

endmodule
