

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package SEGM_MIPS_CONST_PKG is

	
	
	constant INST_SIZE	: INTEGER := 32;		
	constant ADDR_SIZE	: INTEGER := 5;			
	constant NUM_REG	: INTEGER := 32;		
	
	constant NUM_ADDR	: INTEGER := 1024;		
	
	constant PC_COUNT	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000100";	

	constant ZERO32b	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000000";	
	constant ZERO16b	: STD_LOGIC_VECTOR(15 downto 0) :=  "0000000000000000";
	constant ONE32b		: STD_LOGIC_VECTOR(31 downto 0) :=  "11111111111111111111111111111111";	
	constant ONE16b		: STD_LOGIC_VECTOR(15 downto 0) :=  "1111111111111111";	

end SEGM_MIPS_CONST_PKG;
