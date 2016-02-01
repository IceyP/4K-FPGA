library ieee;
use ieee.std_logic_1164.all;
entity roundfunc is port
		(
		clk : in std_logic;
		reset : in std_logic;
		li,ri : in std_logic_vector(1 to 32);
		k : in std_logic_vector(1 to 48);
		lo,ro : out std_logic_vector(1 to 32)
		);
end roundfunc;
architecture behaviour of roundfunc is
	signal xp_to_xor : std_logic_vector(1 to 48);
	signal b1x,b2x,b3x,b4x,b5x,b6x,b7x,b8x
	: std_logic_vector(1 to 6);
	signal so1x,so2x,so3x,so4x,so5x,so6x,so7x,so8x
	: std_logic_vector(1 to 4);
	signal ppo,r_toreg32,l_toreg32 : std_logic_vector(1 to 32);
	component xp
		port (
			ri : in std_logic_vector(1 TO 32);
			e : out std_logic_vector(1 TO 48)
			);
	end component;
	
	component desxor1
		port (
			e : in std_logic_vector(1 TO 48);
			b1x,b2x,b3x,b4x,b5x,b6x,b7x,b8x
			: out std_logic_vector (1 TO 6);
			k : in std_logic_vector (1 TO 48)
			);
	end component;
	
	
	component s1_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s2_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s3_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s4_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s5_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s6_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s7_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component s8_box
		port (
			A : in std_logic_vector(1 to 6);
			SPO : out std_logic_vector(1 to 4)
			);
	end component;
	
	component pp
		port (
			so1x,so2x,so3x,so4x,so5x,so6x,so7x,so8x
			: in std_logic_vector(1 to 4);
			ppo : out std_logic_vector(1 to 32)
			);
	end component;
	
	component desxor2
		port (
			d,l : in std_logic_vector(1 to 32);
			q : out std_logic_vector(1 to 32)
			);
	end component;
	
	component reg32
		port (
			a : in std_logic_vector (1 to 32);
			q : out std_logic_vector (1 to 32);
			reset : in std_logic;
			clk : in std_logic
			);
	end component;
	
begin
	xpension: xp port map ( ri=>ri,e=>xp_to_xor );
		
	des_xor1: desxor1 port map ( e=>xp_to_xor, k=>k,
		b1x=>b1x, b2x=>b2x, b3x=>b3x, b4x=>b4x, b5x=>b5x, b6x=>b6x,
		b7x=>b7x, b8x=>b8x );
		
	s1a: s1_box port map ( A=>b1x, SPO=>so1x
		);
	s2a: s2_box port map ( A=>b2x, SPO=>so2x
		);
	s3a: s3_box port map ( A=>b3x, SPO=>so3x
		);
	s4a: s4_box port map ( A=>b4x, SPO=>so4x
		);
	s5a: s5_box port map ( A=>b5x, SPO=>so5x
		);
	s6a: s6_box port map ( A=>b6x, SPO=>so6x
		);
	s7a: s7_box port map ( A=>b7x, SPO=>so7x
		);
	s8a: s8_box port map ( A=>b8x, SPO=>so8x
		);
		
	pperm: pp port map ( so1x=>so1x, so2x=>so2x,
		so3x=>so3x, so4x=>so4x, so5x=>so5x, so6x=>so6x, so7x=>so7x, so8x=>so8x,
		ppo=>ppo );
		
	des_xor2: desxor2 port map ( d=>ppo,
		l=>li, q=>r_toreg32 );
		
	l_toreg32<=ri;
	
	register32_left: reg32 port map ( a=>l_toreg32, q=>lo,
		reset=>reset, clk=>clk );
		
	register32_right: reg32 port map ( a=>r_toreg32, q=>ro,
		reset=>reset, clk=>clk );
end;
