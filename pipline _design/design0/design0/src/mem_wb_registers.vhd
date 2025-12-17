

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;


entity MEM_WB_REGISTERS is
 	port(
		
		CLK		: in STD_LOGIC;
		RESET		: in STD_LOGIC;
		WB		: in WB_CTRL_REG;
		READ_DATA	: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		ADDRESS		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		WRITE_REG	: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		
		WB_OUT		: out WB_CTRL_REG;
		READ_DATA_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		ADDRESS_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		WRITE_REG_OUT	: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)
	);
end MEM_WB_REGISTERS;

architecture MEM_WB_REGISTERS_ARC of MEM_WB_REGISTERS is        
begin
	SYNC_MEM_WB:
		process(CLK,RESET,WB,READ_DATA,ADDRESS,WRITE_REG)
		begin
			if RESET = '1' then
			    	WB_OUT		<= ('0','0');
				READ_DATA_OUT	<= ZERO32b;
				ADDRESS_OUT	<= ZERO32b;
				WRITE_REG_OUT	<= "00000";
			elsif rising_edge(CLK) then
			    	WB_OUT		<= WB;
				READ_DATA_OUT	<= READ_DATA;
				ADDRESS_OUT	<= ADDRESS;
				WRITE_REG_OUT	<= WRITE_REG;
			end if;
		end process; 

end MEM_WB_REGISTERS_ARC;
