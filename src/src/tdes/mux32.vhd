LIBRARY ieee ;
USE ieee.std_logic_1164.all;
ENTITY mux32 IS
	PORT(
		e0 : IN std_logic_vector (1 to 32) ;
		e1 : IN std_logic_vector (1 to 32) ;
		o : OUT std_logic_vector (1 to 32) ;
		sel : IN std_logic
		);
END mux32 ;
ARCHITECTURE synth OF mux32 IS
BEGIN
	process(sel,e0,e1)
	begin
		if sel = '0' then
			o <= e0;
		else
			o <= e1;
		end if;
	end process;
END synth;



