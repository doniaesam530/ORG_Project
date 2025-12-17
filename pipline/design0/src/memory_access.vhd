


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity MEMORY_ACCESS is
	port( 
		
		CLK			: in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
		WB_IN			: in WB_CTRL_REG;				
		MEM			: in MEM_CTRL_REG;			
		FLAG_ZERO		: in STD_LOGIC;					
		NEW_PC_ADDR		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		ADDRESS_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		WRITE_DATA		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		WRITE_REG_IN		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		
		WB_OUT			: out WB_CTRL_REG;				
		READ_DATA		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		ADDRESS_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		WRITE_REG_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		
		NEW_PC_ADDR_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		PCSrc			: out STD_LOGIC					
	);
end MEMORY_ACCESS;

architecture MEMORY_ACCESS_ARC of MEMORY_ACCESS is


	
	component DATA_MEMORY is
		generic (N :NATURAL :=INST_SIZE; M :NATURAL :=NUM_ADDR); 
		port(
			RESET		:	in  STD_LOGIC;				
			ADDR		:	in  STD_LOGIC_VECTOR (N-1 downto 0);	
			WRITE_DATA	:	in  STD_LOGIC_VECTOR (N-1 downto 0);	
			MemRead		:	in  STD_LOGIC;				
			MemWrite	:	in  STD_LOGIC;				
			READ_DATA	:	out STD_LOGIC_VECTOR (N-1 downto 0)	

		);
	end component DATA_MEMORY;

	component MEM_WB_REGISTERS is
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
	end component MEM_WB_REGISTERS;
	 
	 

	signal READ_DATA_AUX : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
 
begin

	OUT_MEM:	
		process(RESET,FLAG_ZERO,MEM.Branch,NEW_PC_ADDR)
		begin
			if( RESET = '1') then
				PCSrc <= '0';
				NEW_PC_ADDR_OUT <= ZERO32b;
			else
				PCSrc <= FLAG_ZERO and MEM.Branch;
				NEW_PC_ADDR_OUT <= NEW_PC_ADDR;
			end if;
		end process OUT_MEM;

	DAT_MEM:
		DATA_MEMORY generic map (N=>INST_SIZE, M=>NUM_ADDR)
	 	port map(
			RESET		=> RESET,
			ADDR		=> ADDRESS_IN,
			WRITE_DATA	=> WRITE_DATA,
			MemRead		=> MEM.MemRead,
			MemWrite	=> MEM.MemWrite,
			READ_DATA	=> READ_DATA_AUX

		);
	
	MEM_WB_REGS:
		MEM_WB_REGISTERS port map(
			
			CLK			=> CLK,
			RESET			=> RESET,
			WB			=> WB_IN,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS			=> ADDRESS_IN,
			WRITE_REG		=> WRITE_REG_IN,
			
			WB_OUT			=> WB_OUT,
			READ_DATA_OUT		=> READ_DATA,
			ADDRESS_OUT		=> ADDRESS_OUT,	
			WRITE_REG_OUT		=> WRITE_REG_OUT 
		);


end MEMORY_ACCESS_ARC;
