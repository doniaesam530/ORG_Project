


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;


entity SEGMENTED_MIPS is
	port(
		CLK 	: in STD_LOGIC;
		RESET	: in STD_LOGIC
	);
end SEGMENTED_MIPS;

architecture SEGMENTED_MIPS_ARC of SEGMENTED_MIPS is	


		component INSTRUCTION_FETCHING is
		 port(
			
			CLK		:	in STD_LOGIC;					
			RESET		:	in STD_LOGIC;					
			PCSrc		:	in STD_LOGIC;					
			NEW_PC_ADDR_IN	:	in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
			
			NEW_PC_ADDR_OUT	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
			INSTRUCTION 	:	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)	
		 );
		end component INSTRUCTION_FETCHING;
	
		component INSTRUCTION_DECODING is
		port(
			CLK			:	in	STD_LOGIC;				
			RESET			:	in	STD_LOGIC;				
			
			INSTRUCTION		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			NEW_PC_ADDR_IN		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
				  
			RegWrite		:	in	STD_LOGIC;						 
			WRITE_DATA		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			WRITE_REG 		:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
			
			NEW_PC_ADDR_OUT		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			
			OFFSET			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			RT_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
			RD_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
			
			RS	 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			RT 			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			
			WB_CR			:	out	WB_CTRL_REG;				
			MEM_CR			:	out	MEM_CTRL_REG;				
			EX_CR			:	out	EX_CTRL_REG				     
		);
		end component INSTRUCTION_DECODING;
	
		component EXECUTION is
		port( 
			
     			CLK			:	in STD_LOGIC;					
			RESET			:	in STD_LOGIC;					
     			WB_CR			:	in WB_CTRL_REG; 				
			MEM_CR			:	in MEM_CTRL_REG;				
			EX_CR			:	in EX_CTRL_REG;						     	
			NEW_PC_ADDR_IN		:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
			RS	 		:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
		    	RT 			:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
			OFFSET			:	in STD_LOGIC_vector (INST_SIZE-1 downto 0);	--Offset   [15-0]
			RT_ADDR			:	in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	-- RT [20-16]
			RD_ADDR			:	in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	-- RD [15-11]			 				
					     	      
			--Salidas
			WB_CR_OUT		:	out WB_CTRL_REG; 				
			MEM_CR_OUT		:	out MEM_CTRL_REG;				
			NEW_PC_ADDR_OUT		:	out STD_LOGIC_vector (INST_SIZE-1 downto 0);	
			ALU_FLAGS_OUT		:	out ALU_FLAGS;					
			ALU_RES_OUT		:	out STD_LOGIC_vector(INST_SIZE-1 downto 0);	
			RT_OUT			:	out STD_LOGIC_vector (INST_SIZE-1 downto 0);	
			RT_RD_ADDR_OUT		:	out STD_LOGIC_vector (ADDR_SIZE-1 downto 0)	
					
		);
		end component EXECUTION;
		
		component MEMORY_ACCESS is
		port( 
				--Entradas
				CLK			: in STD_LOGIC;
				RESET			: in STD_LOGIC;					
				WB_IN			: in WB_CTRL_REG;				
				MEM			: in MEM_CTRL_REG;				
				FLAG_ZERO		: in STD_LOGIC;					--Flag Zero  ALU
				NEW_PC_ADDR		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				ADDRESS_IN		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				WRITE_DATA		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				WRITE_REG_IN		: in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	
			
				WB_OUT			: out WB_CTRL_REG;				
				READ_DATA		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				ADDRESS_OUT		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				WRITE_REG_OUT		: out STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	
				
				NEW_PC_ADDR_OUT		: out STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				PCSrc			: out STD_LOGIC					
			);
		end component MEMORY_ACCESS;
	
		component WRITE_BACK is
		port( 
				
				RESET			: in STD_LOGIC;					
				WB			: in WB_CTRL_REG;				
				READ_DATA		: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				ADDRESS			: in STD_LOGIC_vector (INST_SIZE-1 downto 0);	
				WRITE_REG		: in STD_LOGIC_vector (ADDR_SIZE-1 downto 0);			
				
				RegWrite		: out STD_LOGIC;				--WB_OUT.RegWrite
				WRITE_REG_OUT		: out STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	
				WRITE_DATA		: out STD_LOGIC_vector (INST_SIZE-1 downto 0)	
		);
		end component WRITE_BACK;
	

	
		
		
		-- MEM/IF
		signal PCSrc_AUX		: STD_LOGIC;
		signal NEW_PC_ADDR_AUX4		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- IF/ID
		signal NEW_PC_ADDR_AUX1		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal INSTRUCTION_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- WB/ID
		signal RegWrite_AUX		: STD_LOGIC;
		signal WRITE_REG_AUX2		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal WRITE_DATA_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		-- ID/EX
		signal NEW_PC_ADDR_AUX2		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal OFFSET_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_ADDR_AUX		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal RD_ADDR_AUX 		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		signal RS_AUX	 		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_AUX1 			: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal WB_CR_AUX1		: WB_CTRL_REG;
		signal MEM_CR_AUX1		: MEM_CTRL_REG;
		signal EX_CR_AUX		: EX_CTRL_REG;
		-- EX/MEM
		signal WB_CR_AUX2		: WB_CTRL_REG;
		signal MEM_CR_AUX2		: MEM_CTRL_REG;
		signal NEW_PC_ADDR_AUX3		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal ALU_FLAGS_AUX		: ALU_FLAGS;
		signal ALU_RES_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_AUX2			: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal RT_RD_ADDR_AUX		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);
		--MEM/WB
		signal WB_CR_AUX3		: WB_CTRL_REG;
		signal READ_DATA_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal ADDRESS_AUX		: STD_LOGIC_vector (INST_SIZE-1 downto 0);
		signal WRITE_REG_AUX1		: STD_LOGIC_vector (ADDR_SIZE-1 downto 0);	
	 
begin

	
			
	INST_FETCH:
		INSTRUCTION_FETCHING port map(
			
			CLK		=> CLK,
			RESET		=> RESET,
			PCSrc		=> PCSrc_AUX,
			NEW_PC_ADDR_IN	=> NEW_PC_ADDR_AUX4,
			
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_AUX1,
			INSTRUCTION	=> INSTRUCTION_AUX
		);	

	INST_DECOD:
		INSTRUCTION_DECODING port map(
			
			CLK		=> CLK,
			RESET		=> RESET,
			INSTRUCTION	=> INSTRUCTION_AUX,
			NEW_PC_ADDR_IN	=> NEW_PC_ADDR_AUX1,
			RegWrite	=> RegWrite_AUX,  
			WRITE_DATA	=> WRITE_DATA_AUX, 
			WRITE_REG 	=> WRITE_REG_AUX2,
			
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_AUX2,
			OFFSET		=> OFFSET_AUX,
			RT_ADDR		=> RT_ADDR_AUX,
			RD_ADDR		=> RD_ADDR_AUX,
			RS 		=> RS_AUX,
			RT 		=> RT_AUX1,
			WB_CR		=> WB_CR_AUX1,
			MEM_CR		=> MEM_CR_AUX1,
			EX_CR		=> EX_CR_AUX
		);

	EXE:
		EXECUTION port map( 
			
			CLK			=> CLK,
			RESET			=> RESET,
			WB_CR			=> WB_CR_AUX1,
			MEM_CR			=> MEM_CR_AUX1,
			EX_CR			=> EX_CR_AUX, 	     	
			NEW_PC_ADDR_IN		=> NEW_PC_ADDR_AUX2,
			RS	 		=> RS_AUX,
		    	RT 			=> RT_AUX1,
			OFFSET			=> OFFSET_AUX,
			RT_ADDR			=> RT_ADDR_AUX,
			RD_ADDR			=> RD_ADDR_AUX,			 				
			--Salidas
			WB_CR_OUT		=> WB_CR_AUX2,
			MEM_CR_OUT		=> MEM_CR_AUX2,
			NEW_PC_ADDR_OUT		=> NEW_PC_ADDR_AUX3,
			ALU_FLAGS_OUT		=> ALU_FLAGS_AUX,
			ALU_RES_OUT		=> ALU_RES_AUX,
			RT_OUT			=> RT_AUX2,
			RT_RD_ADDR_OUT		=> RT_RD_ADDR_AUX
		);

	MEM_ACC:
		MEMORY_ACCESS port map( 
			--Entradas
			CLK			=> CLK,
			RESET			=> RESET,
			WB_IN			=> WB_CR_AUX2,
			MEM			=> MEM_CR_AUX2,
			FLAG_ZERO		=> ALU_FLAGS_AUX.Zero,
			NEW_PC_ADDR		=> NEW_PC_ADDR_AUX3,
			ADDRESS_IN		=> ALU_RES_AUX,
			WRITE_DATA		=> RT_AUX2,
			WRITE_REG_IN		=> RT_RD_ADDR_AUX,
		
			WB_OUT			=> WB_CR_AUX3,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS_OUT		=> ADDRESS_AUX,
			WRITE_REG_OUT		=> WRITE_REG_AUX1,
		
			NEW_PC_ADDR_OUT		=> NEW_PC_ADDR_AUX4,
			PCSrc			=> PCSrc_AUX	
		);

	WR_BK:
		WRITE_BACK port map( 
					
			RESET			=> RESET,
			WB			=> WB_CR_AUX3,
			READ_DATA		=> READ_DATA_AUX,
			ADDRESS			=> ADDRESS_AUX,
			WRITE_REG		=> WRITE_REG_AUX1,
			
			RegWrite		=> RegWrite_AUX,
			WRITE_REG_OUT		=> WRITE_REG_AUX2,
			WRITE_DATA		=> WRITE_DATA_AUX
		);


end SEGMENTED_MIPS_ARC;			
