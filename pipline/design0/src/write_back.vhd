

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity WRITE_BACK is
port( 
	
	RESET			: in STD_LOGIC;					--Reset
	WB			: in WB_CTRL_REG;				--Señales de control para esta etapa
	READ_DATA		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
	ADDRESS			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	--Posible dato a ser escribido en la memoria de registros
	WRITE_REG		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros		

	RegWrite		: out STD_LOGIC;				--WB_OUT.RegWrite
	WRITE_REG_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	--Dirección del registro a ser escrito en la memoria de registros
	WRITE_DATA		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)	--Este dato representa a READ_DATA o a ADDRESS, según lo decida WB_OUT.MemtoReg
);
end WRITE_BACK;

architecture WRITE_BACK_ARC of WRITE_BACK is 
begin

	MUX_WB: 
		process(RESET,WB.RegWrite,WRITE_REG,WB.MemtoReg,ADDRESS,READ_DATA)
		begin
			if( RESET = '1') then
				RegWrite <= '0';
				WRITE_REG_OUT <= "00000"; 
				WRITE_DATA <= ZERO32b; 
			else
				RegWrite <= WB.RegWrite;
				WRITE_REG_OUT <= WRITE_REG;
			 	if( WB.MemtoReg = '0') then
			 		WRITE_DATA <= ADDRESS; 
			 	else
			 		WRITE_DATA <= READ_DATA;
			 	end if;
			end if;
		 end process MUX_WB;
		 
end WRITE_BACK_ARC;
