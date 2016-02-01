library ieee;
use ieee.std_logic_1164.all;
entity keysched is port
		(
		the_key : in std_logic_vector(1 to 64);
		shift : in std_logic_vector(1 to 3);
		clk : in std_logic;
		ki : out std_logic_vector(1 to 48)
		);
end keysched;
architecture behaviour of keysched is
	signal c,d,c1,d1 : std_logic_vector(1 to 28);
	component pc1
		port (
			key : in std_logic_vector(1 TO 64);
			c0x,d0x : out std_logic_vector(1 TO 28)
			);
	end component;
	component shifter
		port (
			datac : in std_logic_vector(1 to 28);
			datad : in std_logic_vector(1 to 28);
			shift : in std_logic_vector(1 to 3);
			clk : in std_logic;
			datac_out : out std_logic_vector(1 to 28);
			datad_out : out std_logic_vector(1 to 28)
			);
	end component;
	component pc2
		port (
			c,d : in std_logic_vector(1 TO 28);
			k : out std_logic_vector(1 TO 48)
			);
	end component;
begin
	pc_1: pc1 port map ( key=>the_key, c0x=>c, d0x=>d );
	shifter_comp: shifter port map ( datac=>c, datad=>d, shift=>shift, clk=>clk,
		datac_out=>c1, datad_out=>d1 );
	pc_2: pc2 port map ( c=>c1, d=>d1, k=>ki );
end behaviour;
