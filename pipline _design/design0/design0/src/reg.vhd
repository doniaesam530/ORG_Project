


library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;


entity REG is 
	generic (N: NATURAL);    
	port(
		CLK		: in	STD_LOGIC;						
		RESET		: in	STD_LOGIC;			
		DATA_IN		: in	STD_LOGIC_VECTOR(N-1 downto 0);	
		DATA_OUT	: out	STD_LOGIC_VECTOR(N-1 downto 0)	
	);
end REG;

architecture REG_ARC of REG is        
begin
	SYNC_REG:
		process(CLK,RESET,DATA_IN)
		begin
			if(RESET = '1') then
				DATA_OUT <= (others => '0');
			elsif rising_edge(CLK) then
				DATA_OUT <= DATA_IN;
			end if;
		end process; 
end REG_ARC;
