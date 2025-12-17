library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;


entity ID_EX_REGISTERS is 
	port(
		
		CLK				: in	STD_LOGIC;				
		RESET				: in	STD_LOGIC;				
      	
		NEW_PC_ADDR_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		OFFSET_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RD_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
	
		RS_IN	 			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_IN 				: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		WB_IN				: in	WB_CTRL_REG;				
		M_IN				: in	MEM_CTRL_REG;				
		EX_IN				: in	EX_CTRL_REG;				
	      
	
		NEW_PC_ADDR_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		OFFSET_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RD_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		RS_OUT	 			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_OUT 				: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		WB_OUT				: out	WB_CTRL_REG;				
		M_OUT				: out	MEM_CTRL_REG;				
		EX_OUT				: out	EX_CTRL_REG				
	);
end ID_EX_REGISTERS;

architecture ID_EX_REGISTERS_ARC of ID_EX_REGISTERS is
begin
	SYNC_ID_EX:
	  process(CLK,RESET,NEW_PC_ADDR_IN,OFFSET_IN,RT_ADDR_IN,RD_ADDR_IN,RS_IN,RT_IN,WB_IN,M_IN,EX_IN)
	  begin
		if RESET = '1' then
				NEW_PC_ADDR_OUT		<= (others => '0');
				OFFSET_OUT		<= (others => '0');
				RT_ADDR_OUT		<= (others => '0');
				RD_ADDR_OUT		<= (others => '0');
				RS_OUT	 		<= (others => '0');
				RT_OUT 			<= (others => '0');
				WB_OUT			<= ('0','0');
				M_OUT			<= ('0','0','0');
				EX_OUT			<= ('0',('0','0','0'),'0');
		elsif rising_edge(CLK) then
				NEW_PC_ADDR_OUT		<= NEW_PC_ADDR_IN;
				OFFSET_OUT		<= OFFSET_IN;
				RT_ADDR_OUT		<= RT_ADDR_IN;
				RD_ADDR_OUT		<= RD_ADDR_IN;	
				RS_OUT	 		<= RS_IN;
				RT_OUT 			<= RT_IN;
				WB_OUT			<= WB_IN;
				M_OUT			<= M_IN;
				EX_OUT			<= EX_IN;
		end if;
	  end process;

end ID_EX_REGISTERS_ARC;
