LIBRARY ieee ;
USE ieee.std_logic_1164.all;
ENTITY ov32 IS
	PORT(
		e : in std_logic_vector (1 to 32) ;
		o1 : out std_logic_vector (1 to 32) ;
		o2 : out std_logic_vector (1 to 32) ;
		clk : in std_logic;
		sel : in std_logic
		);
END ov32 ;
ARCHITECTURE synth OF ov32 IS
BEGIN
	process(sel,clk)
	begin
		if (clk'event and clk = '1') then
			if(sel = '1') then
				o2<=e;
			end if;
		end if;
	end process;
	o1<=e;
END synth;
