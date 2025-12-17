library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.segm_mips_const_pkg.all;


entity IF_ID_REGISTERS is 
    port(
	        CLK		: in	STD_LOGIC;			
		RESET		: in	STD_LOGIC;			
	        NEW_PC_ADDR_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
	        INST_REG_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
	        NEW_PC_ADDR_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
	        INST_REG_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)
        );
end IF_ID_REGISTERS;

architecture IF_ID_REGISTERS_ARC of IF_ID_REGISTERS is        
begin
	SYNC_IF_ID:	
		process(CLK,RESET,NEW_PC_ADDR_IN,INST_REG_IN)
		begin
			if RESET = '1' then
				NEW_PC_ADDR_OUT	<= (others => '0');
				INST_REG_OUT	<= (others => '0');
			elsif rising_edge(CLK) then
				NEW_PC_ADDR_OUT	<= NEW_PC_ADDR_IN;
				INST_REG_OUT<= INST_REG_IN;
			end if;
		end process; 
end IF_ID_REGISTERS_ARC;
