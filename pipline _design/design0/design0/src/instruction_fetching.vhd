

library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity INSTRUCTION_FETCHING is
	port(
		
		CLK		: in STD_LOGIC;					
		RESET		: in STD_LOGIC;					
		PCSrc		: in STD_LOGIC;					
		NEW_PC_ADDR_IN	: in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		
		NEW_PC_ADDR_OUT	: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		INSTRUCTION 	: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)	
	);
end INSTRUCTION_FETCHING;

architecture INSTRUCTION_FETCHING_ARC of INSTRUCTION_FETCHING is	



	component ADDER is 
		generic (N:NATURAL := INST_SIZE);
		port(
			X	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN	: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component ADDER;

	component REG is 
		generic (N:NATURAL := INST_SIZE); -- N = Tamaño del registro
		port(
			CLK		: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			DATA_IN		: in	STD_LOGIC_VECTOR(N-1 downto 0);
			DATA_OUT	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component REG;

	component IF_ID_REGISTERS is   
		port(
			CLK		: in	STD_LOGIC;
			RESET		: in	STD_LOGIC;
			NEW_PC_ADDR_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			INST_REG_IN	: in	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			NEW_PC_ADDR_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
			INST_REG_OUT	: out	STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)
		);
	end component IF_ID_REGISTERS;

	component INSTRUCTION_MEMORY is
		port(
			RESET		: in	STD_LOGIC;
  			READ_ADDR	: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
  			INST		: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)
		);
	end component INSTRUCTION_MEMORY;


	signal PC_ADDR_AUX1	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	signal PC_ADDR_AUX2	: STD_LOGIC_VECTOR (INST_SIZE downto 0);	
	signal PC_ADDR_AUX3	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal INST_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	
begin

	--Port maps
	
	myADDER :
		ADDER generic map (N => INST_SIZE)
		port map(
			X	=> PC_ADDR_AUX1,
			Y	=> PC_COUNT, 
			CIN	=> '0',
			COUT	=> PC_ADDR_AUX2(INST_SIZE),
			R	=> PC_ADDR_AUX2(INST_SIZE-1 downto 0)
		);

	MUX_PC:
		process(PCSrc,PC_ADDR_AUX2,NEW_PC_ADDR_IN)
		begin
			if( PCSrc = '0') then
				PC_ADDR_AUX3 <= PC_ADDR_AUX2(INST_SIZE-1 downto 0); 
			else
				PC_ADDR_AUX3 <= NEW_PC_ADDR_IN;
			end if;
		end process MUX_PC; 

	PC : 
		REG generic map (N => INST_SIZE)
		port map(
			CLK		=> CLK,
			RESET		=> RESET,
			DATA_IN		=> PC_ADDR_AUX3,
			DATA_OUT	=> PC_ADDR_AUX1
		);
	
	INST_MEM:
		INSTRUCTION_MEMORY port map(
			RESET		=>	RESET,
			READ_ADDR	=>	PC_ADDR_AUX1,
			INST		=> 	INST_AUX
		);
		
	IF_ID_REG:
		IF_ID_REGISTERS port map(
			CLK		=> CLK,
			RESET		=> RESET,
			NEW_PC_ADDR_IN	=> PC_ADDR_AUX2(INST_SIZE-1 downto 0),
			INST_REG_IN	=> INST_AUX,
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			INST_REG_OUT	=> INSTRUCTION
		);	

end INSTRUCTION_FETCHING_ARC;
