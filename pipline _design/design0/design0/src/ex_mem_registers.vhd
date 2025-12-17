library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity EX_MEM_REGISTERS is 
    port(
		CLK		:	in STD_LOGIC;					
		RESET		:	in STD_LOGIC;					
		WB_CR_IN	:	in WB_CTRL_REG; 				
		MEM_CR_IN	:	in MEM_CTRL_REG;				
		NEW_PC_ADDR_IN	:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		ALU_FLAGS_IN	:	in ALU_FLAGS;					
		ALU_RES_IN	:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_IN		:	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_ADDR_IN	:	in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		 						     	      
		WB_CR_OUT	:	out WB_CTRL_REG; 				
		MEM_CR_OUT	:	out MEM_CTRL_REG;				
		NEW_PC_ADDR_OUT	:	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		ALU_FLAGS_OUT	:	out ALU_FLAGS;					
		ALU_RES_OUT	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_OUT		:	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_ADDR_OUT	:	out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)	
	        
        );
end EX_MEM_REGISTERS;

architecture EX_MEM_REGISTERS_ARC of EX_MEM_REGISTERS is        
begin 

	SYNC_EX_MEM:
	  process(CLK,RESET,WB_CR_IN,MEM_CR_IN,NEW_PC_ADDR_IN,ALU_FLAGS_IN,ALU_RES_IN,RT_IN,RT_RD_ADDR_IN)
	  begin
		if RESET = '1' then
	    		WB_CR_OUT	<= ('0','0');
			MEM_CR_OUT	<= ('0','0','0');
			NEW_PC_ADDR_OUT	<= ZERO32b;
			ALU_FLAGS_OUT	<= ('0','0','0','0');
			ALU_RES_OUT	<= ZERO32b;
			RT_OUT		<= ZERO32b;
			RT_RD_ADDR_OUT	<= "00000";
		elsif rising_edge(CLK) then
	    		WB_CR_OUT	<= WB_CR_IN;
			MEM_CR_OUT	<= MEM_CR_IN;
			NEW_PC_ADDR_OUT	<= NEW_PC_ADDR_IN;
			ALU_FLAGS_OUT	<= ALU_FLAGS_IN;
			ALU_RES_OUT	<= ALU_RES_IN;
			RT_OUT		<= RT_IN;
			RT_RD_ADDR_OUT	<= RT_RD_ADDR_IN;
		end if;
	  end process; 

end EX_MEM_REGISTERS_ARC;
