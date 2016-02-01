library ieee;
use ieee.std_logic_1164.all;
entity state_encrypt is 
	port(
		pt : in std_logic_vector(1 TO 64);
		key : in std_logic_vector(1 TO 64);
		clk : in std_logic;
		ready : in std_logic;
		mode : in std_logic;
		reset : in std_logic;
		ct : out std_logic_vector(1 TO 64);
		out_ok : out std_logic
		);
end state_encrypt;

architecture structural of state_encrypt is
	component control_new
		port (
			reset : in std_logic;
			clk : in std_logic;
			ready : in std_logic;
			mode : in std_logic;
			load_new_pt : out std_logic;
			output_ok : out std_logic;
			shift : out std_logic_vector(1 to 3)
			);
	end component;
	component fullround
		port (
			pt : in std_logic_vector(1 TO 64);
			xkey : in std_logic_vector(1 TO 48);
			reset : in std_logic;
			clk : in std_logic;
			load_new_pt : in std_logic;
			output_ok : in std_logic;
			ct : out std_logic_vector(1 TO 64)
			);
	end component;
	component keysched
		port (
			the_key : in std_logic_vector(1 to 64);
			shift : in std_logic_vector(1 to 3);
			clk : in std_logic;
			ki : out std_logic_vector(1 to 48)
			);
	end component;
	
	signal load_new_pt : std_logic;
	signal output_ok : std_logic;
	signal shift_sig : std_logic_vector(1 to 3);
	signal ki_sig : std_logic_vector(1 to 48);
--	signal key_sig : std_logic_vector(1 to 64);
--	signal pt_sig : std_logic_vector(1 to 64);

	
begin

	out_ok <= output_ok;
	
	control_unit : control_new port map 
		(reset=>reset, 
		clk=>clk,
		ready => ready,
		mode=>mode,
		load_new_pt=>load_new_pt, 
		output_ok=>output_ok, 
		shift=>shift_sig );

	datapath : fullround port map 
		(pt=>pt, 
		xkey=>ki_sig, 
		reset=>reset,
		clk=>clk,
		load_new_pt=>load_new_pt, 
		output_ok=>output_ok, 
		ct=>ct );
	
	key_proc : keysched port map 
		(the_key=>key, 
		shift=>shift_sig, 
		clk=>clk,
		ki=>ki_sig );
	
end structural;
