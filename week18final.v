// 除頻器
   module divfreq(input CLK, output reg CLK_div);
	  reg[24:0] Count;
	  always @(posedge CLK)
	    begin
		      if(Count>25000)
		 begin
				Count <= 25'b0;
				CLK_div <= ~CLK_div;
		 end
		 else
			Count <= Count + 1'b1;
	    end
   endmodule


// button除頻器
   module buttondivfreq(input CLK, Speedup, output reg CLK_div);
	  reg[24:0] Count;
	  always @(posedge CLK)
	    begin
		      if(Speedup == 0)
		 begin
			  if(Count>5000000)	//25Hz
				  begin
					Count <= 25'b0;
					CLK_div <= ~CLK_div;
				  end
		else
				Count <= Count + 1'b1;
		end
		else
		begin
			if(Count>50000000)	//50Hz
				begin
					Count <= 25'b0;
					CLK_div <= ~CLK_div;
				end
			else
				Count <= Count + 1'b1;
		end
	end
endmodule


 module week18final(
	output reg [0:27] led,
	output reg [2:0] life,
	input left,right,throw,
	input showsecondrow,
	input Speedup,
   input CLK, reset, start,
	output reg a,b,c,d,e,f,g,
	output reg [0:3] COM,
	output reg beep
);

    //分數
   reg [3:0]shiweishudigit = 4'b0000; reg [3:0]geweishudigit = 4'b0000;		
	
	reg [7:0]FBlock =  8'b11111111; reg [7:0]SBlock =  8'b00000000;
   reg [2:0]banziposition;      //初始板子只有3格
	reg [2:0]Ooooooqiuposition; reg [2:0]qiuYposition;
	

	
	reg [0:7]OBJ = 8'b00000011;
	
   //球的狀態
	reg alreadyshortornot;
	reg A_Ball; //another ball 
	reg [2:0] XpBall;  reg [2:0] YpBall;  
	
   //結束開始狀態	
	reg G_OVER; reg G_FINISH;
	
	reg pickupornot;  
	reg upP; //垂直 作為球逐漸往上的判斷依據
	
	integer ballXPosition;
	
	
	initial
	begin
	      led[0:23] = 23'b11111111111111111111;	
		led[27] = 1;	
		led[24:26] = 3'b000;	
	
	
		life = 3'b1111;
		geweishudigit = 4'b0000;               
		shiweishudigit = 4'b0000;
		G_OVER = 0; G_FINISH = 0;
		A_Ball = 0;
		pickupornot = 0;
		beep = 1'b0;
		
				
		
		banziposition = 3'b010; //x=2	
		Ooooooqiuposition = 3'b011;		//x=3
		qiuYposition = 3'b010;	//y=2 
		alreadyshortornot = 1;	//initial：no
		
		
		upP = 1;
		
		//Center
		ballXPosition = 0;			
	end
	
   //開啟除頻器
	divfreq F(CLK, divclk);
	buttondivfreq Z(CLK, Speedup, buttondivclk);
			
	integer ballNum;
	integer doubleball;
	
	always @(posedge buttondivclk)
	  begin
		  if(start)
		  begin
			  beep = 1'b0;  //close
			   if(reset)
			    begin
				  if(G_OVER || G_FINISH) //when over or win
				   begin
					FBlock = 8'b11111111;
					if(showsecondrow)
						SBlock = 8'b11111111;
					else
						SBlock = 8'b00000000;

					life = 3'b111; G_OVER = 0; G_FINISH = 0;
				end

				banziposition <= 3'b010;		//panel position
				Ooooooqiuposition <= 3'b011;		//ball position
				qiuYposition <= 3'b010;	
				alreadyshortornot = 1;				// no
				
				upP = 1;		//為後續球往上做判斷
				//center
				ballXPosition = 0;		
				
				A_Ball = 0;
				pickupornot = 0;
			end
			
			//when move the panel,the place of panel and ball will change
         if(right)
				if(banziposition<5)
				begin
					banziposition <= banziposition+1;
					if(alreadyshortornot==1)
					Ooooooqiuposition <= Ooooooqiuposition+1;
				end
			if(left)
				if(banziposition>0)
				begin
					banziposition <= banziposition-1;
					if(alreadyshortornot==1)
					Ooooooqiuposition <= Ooooooqiuposition-1;
				end
			//short the ball
			if(throw)
				if(alreadyshortornot)
				begin
					alreadyshortornot = 0;
				end
				
			if(ballNum<2)
				ballNum <= ballNum+1; //when ball<2 ballNum+1
			else
			begin
				ballNum <= 0;  //when ball>2 ==0
				if(alreadyshortornot==0)	// yes
				begin
	
						 if(upP) //the ball up gradually
						if(qiuYposition<7)	// 球沒有到最頂端
							qiuYposition <= qiuYposition+1; //持續+1往上直到7
						else
						begin
							qiuYposition <= qiuYposition-1;//到7後開始往下直到1
							upP = 0;
						end
					else
						if(qiuYposition>1) //防止球超過panel
							qiuYposition <= qiuYposition-1;
							
                 //when the ball meet the panel
					if(qiuYposition==1)
						if(Ooooooqiuposition==banziposition) //Ooooooqiuposition position=3 panel=2 when the ball meet the panel
						begin
							if(ballXPosition==0) 
							ballXPosition = -1; //球垂直下，碰到最左邊的panel，所以往左偏
							else 
							qiuYposition <= qiuYposition+1; //球再次向上
							upP = 1;  //期間球持續往上不變
						end 
						
						else if(Ooooooqiuposition==banziposition+1)//Ooooooqiuposition position=3 panel=3 when the ball meet the panel
						begin
							qiuYposition <= qiuYposition+1; //no change
							upP = 1;
						end
						
						
						
						else if(Ooooooqiuposition==banziposition+3 && ballXPosition==-1)//當球的水平位置比panel的水平位置大3且ballXPosition==2
						begin
							ballXPosition = 1;
							Ooooooqiuposition <= Ooooooqiuposition+1; //原本的位置向右
							qiuYposition <= qiuYposition+1;
							upP = 1;
						end
						
						else if(Ooooooqiuposition==banziposition-1 && ballXPosition==1) //當球的水平位置比panel的水平位置小1且ballXPosition==1
						begin
							ballXPosition = -1; // 改變變數用以下面判斷
							Ooooooqiuposition <= Ooooooqiuposition-1; //原本的位置向左
							qiuYposition <= qiuYposition+1;
							upP = 1;
						end
						
						else if(Ooooooqiuposition==banziposition+2) //Ooooooqiuposition position=3 panel=4 when the ball meet the panel
						begin
							if(ballXPosition==0) 
							ballXPosition = 1; //進入下面的判斷
							else 
							qiuYposition <= qiuYposition+1;
							upP = 1;
						end
						
						
						else
						begin
							ballXPosition = 0; //重設
							qiuYposition <= qiuYposition-1; //超過板子了
							A_Ball = 0;
							pickupornot = 1;
							
							life = life*2;		// 位元向左移並補0的操作
							if(life==3'b000)
								G_OVER = 1; //後續會畫圖
							
						end
							
							// ballXPosition
					if(ballXPosition==1)
						if(Ooooooqiuposition<7)
							Ooooooqiuposition <= Ooooooqiuposition+1;	//right
						else
						begin
							ballXPosition = -1;				
							Ooooooqiuposition <= Ooooooqiuposition-1;//over right,left
						end
						
					else if(ballXPosition==-1)
						if(Ooooooqiuposition>0) 
							Ooooooqiuposition <= Ooooooqiuposition-1;	//left
						else
						begin
							ballXPosition = 1;					
							Ooooooqiuposition <= Ooooooqiuposition+1; //over left，right
						end


					//when hit the OBJ 
					if(qiuYposition==4)
						if(OBJ[Ooooooqiuposition]==1) //check hit or not
						begin
							if(upP) 
							upP = 0; //down
							else begin //when down hit the OBJ
								ballXPosition = -ballXPosition; //change way
								upP = 1; //up
							end
							
							if(Ooooooqiuposition==0) 
							ballXPosition = 1; //right
							
							if(Ooooooqiuposition==7) 
							ballXPosition = -1; //left
							Ooooooqiuposition <= Ooooooqiuposition + ballXPosition; //update the new place
							
							if(upP) qiuYposition <= qiuYposition +1;
							else qiuYposition <= qiuYposition -1;
						end
						
						
					//hit the first OBJ
					if(qiuYposition==6)
						if(SBlock[Ooooooqiuposition]==1) //check hit or not
						begin
							beep = 1'b1;
							geweishudigit <= geweishudigit + 1'b1; //add one mark
							if(geweishudigit == 4'b1001) //mark ==9
							begin
								geweishudigit <= 4'b0; // mark=0
								shiweishudigit = shiweishudigit + 1'b1;  //mark=10
							end
							SBlock[Ooooooqiuposition] = 0; //hitted
							if(upP)  
							upP = 0;
							else begin
								ballXPosition = -ballXPosition; //change way
								upP = 1;
							end
							//邊界
							if(Ooooooqiuposition==0) 
							ballXPosition = 1;
							if(Ooooooqiuposition==7) 
							ballXPosition = -1;
							Ooooooqiuposition <= Ooooooqiuposition + ballXPosition;//update the new place
							
							if(upP) 
							qiuYposition <= qiuYposition +1;
							else 
							qiuYposition <= qiuYposition -1;
							
							//end or not
							if(SBlock == 8'b00000000 && FBlock == 8'b000000000) 
							G_FINISH = 1;
						end
						
					//hit the second OBJ
					if(qiuYposition==7)
						if(FBlock[Ooooooqiuposition]==1) //check hit or not
						begin
							beep = 1'b1;
							geweishudigit <= geweishudigit + 1'b1;
							if(geweishudigit == 4'b1001) //mark=9
							begin
								geweishudigit <= 4'b0; //mark=0
								shiweishudigit = shiweishudigit + 1'b1; //mark=10
							end
							FBlock[Ooooooqiuposition] = 0;//hitted
							
							upP = 0;
							//邊界
							if(Ooooooqiuposition==0) 
						   ballXPosition = 1;
							if(Ooooooqiuposition==7) 
							ballXPosition = -1;

							Ooooooqiuposition <= Ooooooqiuposition + ballXPosition; //update the new place
							qiuYposition <= qiuYposition -1;
							//end or not
							if(SBlock == 8'b00000000 && FBlock == 8'b00000000) G_FINISH = 1;
						end
					
						if(pickupornot == 0)
						begin
							OBJ = OBJ<<1; //往左補0
							if(OBJ == 8'b00000000)
								OBJ = 8'b00000011;
						end
				end
			end
			
			//another ball
			if(doubleball<50 && A_Ball == 0 && alreadyshortornot == 0 && pickupornot == 0)
			begin
				doubleball <= doubleball+1;
				XpBall = banziposition ;
				YpBall = 1;
			end
			else
			begin
				if(alreadyshortornot == 0)
				begin
					doubleball <= 0;
					A_Ball = 1;
					if(YpBall == 7)
					begin
						A_Ball = 0;
					end
					if(YpBall < 7)
					begin
						YpBall = YpBall + 1;
					end
						
					// hit the row6 OBJ
					if((YpBall == 6 && SBlock[XpBall] == 1))
					begin
						beep = 1'b1;
						geweishudigit <= geweishudigit + 1'b1;
						if(geweishudigit == 4'b1001)
						begin
							geweishudigit <= 4'b0;
							shiweishudigit = shiweishudigit + 1'b1;
						end
						SBlock[XpBall] = 0;
						A_Ball = 0;
						if(SBlock == 8'b00000000 && FBlock == 8'b000000000) 
						G_FINISH = 1;
					end
					
					// hit the row7 OBJ
					if((YpBall == 7 && FBlock[XpBall] == 1))
					begin
						beep = 1'b1;
						geweishudigit <= geweishudigit + 1'b1;
						if(geweishudigit == 4'b1001)
						begin
							geweishudigit <= 4'b0;
							shiweishudigit = shiweishudigit + 1'b1;
						end
						FBlock[XpBall] = 0;
						A_Ball = 0;
						if(SBlock == 8'b00000000 && FBlock == 8'b000000000)
						G_FINISH = 1;
					end
				end
			end
		end
	end
	
	
	// 顯示用
	always @(posedge divclk)
	begin
		reg [0:2]row;
		reg geweishudigit_enable;
		
		// run 0~7 row
		if(row>=7)
			row <= 3'b000; //chang to 0
		else
			row <= row + 1'b1; //add 1
		
		// settings draw n row
		led[24:26] = row;
		
		
		if(G_OVER)
		begin
			led[0:23] = 24'b111111111111111111111111;
			
			if(row==0 ) 	 
			begin 
			led[0:7]  = 8'b00000010;	
			led[8:15] = 8'b00011111; 
			end
			
			else if(row==1 ) 
			begin led[0:7]	= 8'b11001010; 
			led[8:15] = 8'b11011111; 
			end
			
			else if(row==2 ) 
			begin 
			led[0:7]	= 8'b11001000;	
			led[8:15] = 8'b11011111; 
			end
			
			else if(row==3 ) 
			begin 
			led[0:7]	= 8'b11111111;	
			led[8:15] = 8'b11111111; 
			end
			
			else if(row==4 ) 
			begin 
			led[0:7]	= 8'b00000000;
			led[8:15] = 8'b00011111; 
			end
			
			else if(row==5 ) 
			begin 
			led[0:7]	= 8'b01001010;	
			led[8:15] = 8'b01011111; 
			end
			
			else if(row==6 ) 
			begin
			led[0:7]	= 8'b00001010;	
			led[8:15] = 8'b00011111; 
			end
			
			else if(row==7 ) 
			begin 
			led[0:7]	= 8'b11111111;	
			led[8:15] =	8'b11111111; 
			end
			
			else 
			begin 
			led[0:7]	= 8'b1111111;	
			led[8:15]=8'b11111111; 
			end
		end
		
		else if(G_FINISH)
		begin
			led[0:23] = 24'b111111111111111111111111;
			if(row==0 ) 	   
			led[0:7] = 8'b11111111;
			
			else if(row==1 ) 
			led[0:7]	= 8'b11100000; 
			
			else if(row==2 ) 
			led[0:7]	= 8'b00111111;	
			
			else if(row==3 )
			led[0:7]	= 8'b11011111;	
			
			else if(row==4 ) 
			led[0:7]	= 8'b10110000;	
			
			else if(row==5 )  
			led[0:7]	= 8'b11011011;	
			
			else if(row==6 ) 
			led[0:7]	= 8'b00111101;	
			
			else if(row==7 ) 
			led[0:7]	= 8'b11110000;	
			
			else  led[0:7]	= 8'b1111111;
			
		end
		else
		begin
			// draw the panel
			if(row==banziposition || row==banziposition+1 || row==banziposition+2 || row==banziposition+3)
				led[8:15] = 8'b11111110;
			else
				led[8:15] = 8'b11111111;
				
				
			// draw the ball
			if(alreadyshortornot)
			//center
				if(row==banziposition+1)		
					led[0:7] = 8'b11111101;
				else
					led[0:7] = 8'b11111111;
			else
				if(row==Ooooooqiuposition)
				begin
					reg [7:0] map;
					case(qiuYposition)
						3'b000: map = 8'b11111110 ;
						3'b001: map = 8'b11111101 ;
						3'b010: map = 8'b11111011 ;
						3'b011: map = 8'b11110111 ;
						3'b100: map = 8'b11101111 ;
						3'b101: map = 8'b11011111 ;
						3'b110: map = 8'b10111111 ;
						3'b111: map = 8'b01111111 ; 
					endcase
					led[0:7] = map;
				end
				else
					led[0:7] = 8'b11111111;

			//draw the Block
			led[16:23] = {~FBlock[row], ~SBlock[row], 6'b111111};
			
			// draw the ball
			if(A_Ball == 1)
				if(row==XpBall)
				begin
					case(YpBall)
						3'b000: begin led[7] = 0 ; led[23] = 0; end
						3'b001: begin led[6] = 0 ; led[22] = 0; end
						3'b010: begin led[5] = 0 ; led[21] = 0; end
						3'b011: begin led[4] = 0 ; led[20] = 0; end
						3'b100: begin led[3] = 0 ; led[19] = 0; end
						3'b101: begin led[2] = 0 ; led[18] = 0; end
						3'b110: begin led[1] = 0 ; led[17] = 0; end
						3'b111: begin led[0] = 0 ; led[16] = 0; end
					endcase
				end
			
			// draw thw obj
			if(OBJ[row] == 1)
			begin
				led[3] = 0;
				led[11] = 0;
			end
			

			// display mark
			if(geweishudigit_enable == 0)
			begin
				geweishudigit_enable = 1;
				COM = 4'b1110;
			end
			else
			begin
				geweishudigit_enable = 0;
				COM = 4'b1101;
			end
		end

		
		//個位數
		if(geweishudigit_enable == 1)
		begin
			case(geweishudigit)
				4'b0000:{a,b,c,d,e,f,g}=7'b0000001;
				4'b0001:{a,b,c,d,e,f,g}=7'b1001111;
				4'b0010:{a,b,c,d,e,f,g}=7'b0010010;
				4'b0011:{a,b,c,d,e,f,g}=7'b0000110;
				4'b0100:{a,b,c,d,e,f,g}=7'b1001100;
				4'b0101:{a,b,c,d,e,f,g}=7'b0100100;
				4'b0110:{a,b,c,d,e,f,g}=7'b0100000;
				4'b0111:{a,b,c,d,e,f,g}=7'b0001111;
				4'b1000:{a,b,c,d,e,f,g}=7'b0000000;
				4'b1001:{a,b,c,d,e,f,g}=7'b0000100;
			endcase
		end
		// 十位數
		else
		begin
			case(shiweishudigit)
				4'b0000:{a,b,c,d,e,f,g}=7'b0000001;
				4'b0001:{a,b,c,d,e,f,g}=7'b1001111;
				4'b0010:{a,b,c,d,e,f,g}=7'b0010010;
				4'b0011:{a,b,c,d,e,f,g}=7'b0000110;
				4'b0100:{a,b,c,d,e,f,g}=7'b1001100;
				4'b0101:{a,b,c,d,e,f,g}=7'b0100100;
				4'b0110:{a,b,c,d,e,f,g}=7'b0100000;
				4'b0111:{a,b,c,d,e,f,g}=7'b0001111;
				4'b1000:{a,b,c,d,e,f,g}=7'b0000000;
				4'b1001:{a,b,c,d,e,f,g}=7'b0000100;
			endcase
		end
	end


endmodule

