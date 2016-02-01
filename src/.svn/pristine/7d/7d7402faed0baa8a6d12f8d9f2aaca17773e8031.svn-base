library ieee;
use ieee.std_logic_1164.all;
entity fullround is port
		(
		pt : in std_logic_vector(1 TO 64);
		xkey : in std_logic_vector(1 TO 48);
		reset : in std_logic;
		clk : in std_logic;
		load_new_pt : in std_logic;
		output_ok : in std_logic;
		ct : out std_logic_vector(1 TO 64)
		);
end fullround;
architecture behavior of fullround is
	component mux32
		port (
			e0 : in std_logic_vector (1 to 32) ;
			e1 : in std_logic_vector (1 to 32) ;
			o : out std_logic_vector (1 to 32) ;
			sel : in std_logic
			);
	end component;
	component roundfunc
		port (
			clk : in std_logic;
			reset : in std_logic;
			li,ri : in std_logic_vector(1 to 32);
			k : in std_logic_vector(1 to 48);
			lo,ro : out std_logic_vector(1 to 32)
			);
	end component;
	component ov32
		port (
			e : in std_logic_vector (1 to 32) ;
			o1 : out std_logic_vector (1 to 32) ;
			o2 : out std_logic_vector (1 to 32) ;
			clk : in std_logic;
			sel : in std_logic
			);
	end component;
	component fp
		port (
			l,r : in std_logic_vector(1 to 32);
			ct : out std_logic_vector(1 to 64)
			);
	end component;
	component ip
		port (
			pt : in std_logic_vector(1 TO 64);
			l0x : out std_logic_vector(1 TO 32);
			r0x : out std_logic_vector(1 TO 32)
			);
	end component;
	signal left_in : std_logic_vector(1 to 32);
	signal right_in : std_logic_vector(1 to 32);
	signal mux_l_to_round : std_logic_vector(1 to 32);
	signal mux_r_to_round : std_logic_vector(1 to 32);
	signal round_l_to_ov : std_logic_vector(1 to 32);
	signal round_r_to_ov : std_logic_vector(1 to 32);
	signal ov_l_to_mux : std_logic_vector(1 to 32);
	signal ov_r_to_mux : std_logic_vector(1 to 32);
	signal ov_l_to_fp : std_logic_vector(1 to 32);
	signal ov_r_to_fp : std_logic_vector(1 to 32);
begin
--initial_p: ip port map ( pt=>pt, l0x=>left_in, r0x=>right_in );
  initial_p: ip port map ( pt=>pt, l0x=>left_in, r0x=>right_in );
	mux_left: mux32 port map ( e0=>ov_l_to_mux, e1=>left_in,
		o=>mux_l_to_round, sel=>load_new_pt );
	mux_right: mux32 port map ( e0=>ov_r_to_mux, e1=>right_in,
		o=>mux_r_to_round, sel=>load_new_pt );
	round: roundfunc port map ( clk=>clk, reset=>reset,
		li=>mux_l_to_round, ri=>mux_r_to_round, k=>xkey, lo=>round_l_to_ov,
		ro=>round_r_to_ov );
	ov_left: ov32 port map ( e=>round_l_to_ov, o1=>ov_l_to_mux,
		o2=>ov_l_to_fp, clk=>clk, sel=>output_ok );
	ov_right: ov32 port map ( e=>round_r_to_ov, o1=>ov_r_to_mux,
		o2=>ov_r_to_fp, clk=>clk, sel=>output_ok );
	final_p: fp port map ( l=>ov_r_to_fp, r=>ov_l_to_fp, ct=>ct );
end behavior;
