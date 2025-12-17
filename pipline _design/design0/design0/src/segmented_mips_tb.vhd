

library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

entity SEGMENTED_MIPS_TB is
end SEGMENTED_MIPS_TB;

architecture SEGMENTED_MIPS_TB_ARC of SEGMENTED_MIPS_TB is


	component SEGMENTED_MIPS is
		port(
			CLK 	 :	in STD_LOGIC;
			RESET	 :	in STD_LOGIC
		);
	end component SEGMENTED_MIPS;


	signal CLK	: STD_LOGIC;
	signal RESET	: STD_LOGIC;

begin
	MIPS_TB:
		SEGMENTED_MIPS port map(
			CLK => CLK,
			RESET => RESET
		);

	CLK_PROC:
		process
		begin
			while true loop
				CLK <= '0';
				wait for 10 ns;
				CLK <= '1';
				wait for 10 ns;
			end loop;
		end process CLK_PROC;


	RESET_PROC:
		process
		begin
			RESET<='1';
			wait for 40 ns;
			RESET<='0';
			wait;
		end process RESET_PROC;
   	
end SEGMENTED_MIPS_TB_ARC;
