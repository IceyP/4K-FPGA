----- for TDES encrypt(en-de-en)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TDES_Top is port
	(
	clk: in std_logic;
	reset: in std_logic;-- '1' for reset, '0' for work
	mode: in std_logic; -- 3DES mode select :'0' for encrypt, '1' for decrypt
	ready: in std_logic;-- '1' for start work
	in_data: in std_logic_vector(1 to 64); -- input data
	key1: in std_logic_vector(1 to 64);
	key2: in std_logic_vector(1 to 64);
	--key3: in std_logic_vector(1 to 64);
	out_data: out std_logic_vector(1 to 64);-- output data
	output_ok : out std_logic -- signal for output enable
	);

end; 

architecture behavioral of TDES_Top is

component state_encrypt 
port
	(
	pt : in std_logic_vector(1 TO 64);		
	key : in std_logic_vector(1 TO 64);	
	clk : in std_logic;	
	ready : in std_logic;		
	mode : in std_logic;		
	reset : in std_logic;		
	ct : out std_logic_vector(1 TO 64);
	out_ok : out std_logic
	);
end component;

signal key_i: std_logic_vector(1 to 64);
signal tmp_i: std_logic_vector(1 to 64);
signal tmp_o: std_logic_vector(1 to 64);
signal des_mode : std_logic;-- DES component mode select : '0' for encrypt, '1' for decrypt
signal rdy_i: std_logic;
signal out_ok_i: std_logic;

type type_3des is (	IDLE,
					-- states of encryption
					--EN_ST1,EN_EN1,EN_OUT1,
					--EN_ST2,EN_DE,EN_OUT2,
					--EN_ST3,EN_EN2,EN_OUT3,
					-- states of decryption
					DE_ST1,DE_DE1,DE_OUT1,
					DE_ST2,DE_EN,DE_OUT2,
					DE_ST3,DE_DE2,DE_OUT3);
signal state,state_next:type_3des;

signal output_ok_reg : std_logic;
signal load_tmp_i : std_logic;
signal load_key_i : std_logic_vector (1 downto 0); 	-- load_key_i = "00"  
													--				"01" key1
													--				"10" key2
													--				"11" key3

begin

state_inst : state_encrypt port map
	(
	pt =>tmp_i,
	key=>key_i,
	clk=> clk,
	ready=>rdy_i,
	mode=>des_mode,
	reset=>reset,
	ct=>tmp_o,
	out_ok=>out_ok_i
	);

output_ok<=output_ok_reg;
--out_data<= tmp_o when output_ok_reg ='1' else x"0000000000000000";
	out_data<= tmp_o when output_ok_reg ='1';
tmp_i<=in_data when load_tmp_i='1' else tmp_o;
key_i<= key1 when load_key_i="01" else
		key2 when load_key_i="10" else 
		--key3 when load_key_i="11" else
		key1 when load_key_i="11" else
		x"0000000000000000";

process (state, ready, mode, rdy_i, out_ok_i)
begin
	case state is
		when IDLE=>
			output_ok_reg<='0';
--			out_data<=x"0000000000000000";
--			tmp_i<=(others=>'0');
			rdy_i<='0';
			load_tmp_i<='0';
			load_key_i<="00";
--			if (mode = '0' and ready='1') then -- mode =0 , 3DES encrypt
--					state_next<=EN_ST1;
--					rdy_i<='1';
--					des_mode<='0';
----					tmp_i<=in_data;
--					load_tmp_i<='1';
----					key_i<=key1;
--					load_key_i<="01";
--			elsif (mode='0' and ready='0') then
--					state_next<=IDLE;
--					rdy_i<='0';
--					des_mode<='1';
----					tmp_i<=x"0000000000000000";
--					load_tmp_i<='0';
----					key_i<=x"0000000000000000";
--					load_key_i<="00";
--			elsif (mode = '1' and ready='1') then -- mode = 1, 3DES decrypt
			if (mode = '1' and ready='1') then -- mode = 1, 3DES decrypt
					state_next<=DE_ST1;
--					state_next<=DE_DE1;
					rdy_i<='1';
					des_mode<='1';
--					tmp_i<=in_data;
					load_tmp_i<='1';
--					key_i<=key3;
					load_key_i<="11";
			elsif (mode='1' and ready='0') then
					state_next<=IDLE;
					rdy_i<='0';
					des_mode<='1';
--					tmp_i<=x"0000000000000000";
					load_tmp_i<='0';
--					key_i<=x"0000000000000000";
					load_key_i<="00";
			else
					state_next<=IDLE;
					rdy_i<='1';
					des_mode<='0';
--					tmp_i<=in_data;
					load_tmp_i<='1';
--					key_i<=key1;
					load_key_i<="01";
			end if;
		
		------------start encryption-------------------------	
--		when EN_ST1=> 
----			tmp_i<=in_data;
--			load_tmp_i<='1';
----			key_i<=key1;
--			load_key_i<="01";
--			output_ok_reg<='0';
--			des_mode<='0';
--			rdy_i<='0';
----			out_data<=x"0000000000000000";
--			state_next<=EN_EN1;
--
--		when EN_EN1=>
----			tmp_i<=in_data;
--			load_tmp_i<='1';
----			key_i<=key1;
--			load_key_i<="01";
--			output_ok_reg<='0';
--			des_mode<='0';
--			rdy_i<='0';
----			out_data<=x"0000000000000000";
--			if (out_ok_i = '1') then
--				state_next<=EN_OUT1;				
--			else
--				state_next<=EN_EN1;
--			end if;
--		
--		when EN_OUT1=>
----			tmp_i<=tmp_o;
--			load_tmp_i<='0';
----			key_i<=key2;
--			load_key_i<="10";
--			output_ok_reg<='0';
--			des_mode<='1';
--			rdy_i<='1';
----			out_data<=x"0000000000000000";
--			state_next<=EN_ST2;
--		
--		when EN_ST2=>
----			tmp_i<=tmp_o;
--			load_tmp_i<='0';
----			key_i<=key2;
--			load_key_i<="10";
--			output_ok_reg<='0';
--			des_mode<='1';
--			rdy_i<='0';
----			out_data<=x"0000000000000000";
--			state_next<=EN_DE;
--		
--		when EN_DE=>
--			tmp_i<=tmp_i;
--			load_tmp_i<='0';
--			key_i<=key2;
--			load_key_i<="10";
--			output_ok_reg<='0';
--			des_mode<='1';
--			rdy_i<='0';
--			out_data<=x"0000000000000000";
--			if (out_ok_i='1') then
--				state_next<=EN_OUT2;
--			else
--				state_next<=EN_DE;
--			end if;
--		
--		when EN_OUT2=>
----			tmp_i<=tmp_o;
--			load_tmp_i<='0';
----			key_i<=key3;
--			load_key_i<="11";
--			output_ok_reg<='0';
--			des_mode<='0';
--			rdy_i<='1';
----			out_data<=x"0000000000000000";
--			state_next<=EN_ST3;
--		
--		when EN_ST3=>
----			tmp_i<=tmp_o;
--			load_tmp_i<='0';
----			key_i<=key3;
--			load_key_i<="11";
--			output_ok_reg<='0';
--			des_mode<='0';
--			rdy_i<='0';
----			out_data<=x"0000000000000000";
--			state_next<=EN_EN2;
--			
--		when EN_EN2=>
----			tmp_i<=tmp_i;
--			load_tmp_i<='0';
----			key_i<=key3;
--			load_key_i<="11";
--			output_ok_reg<='0';
--			des_mode<='0';
--			rdy_i<='0';
----			out_data<=x"0000000000000000";
--			if (out_ok_i='1') then
--				state_next<=EN_OUT3;
--			else
--				state_next<=EN_EN2;			 	
--			end if;
--		
--		when EN_OUT3=>
----			tmp_i<=tmp_i;
--			load_tmp_i<='0';
----			key_i<=key3;
--			load_key_i<="11";
--			des_mode<='0';
--			rdy_i<='0';
--			output_ok_reg<='1'; ---- output 3DES encrypt result
----			out_data<=tmp_o;
--			state_next<=IDLE;
		
		
		-------------start decryption----------------------
		when DE_ST1=>
--			tmp_i<=in_data;
			load_tmp_i<='1';
--			key_i<=key3;
			load_key_i<="11";
			output_ok_reg<='0';
			des_mode<='1';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			state_next<=DE_DE1;
			
		when DE_DE1=>
--			tmp_i<=in_data;
			load_tmp_i<='1';
--			key_i<=key3;
			load_key_i<="11";
			output_ok_reg<='0';
			des_mode<='1';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			if (out_ok_i = '1') then
				state_next<=DE_OUT1;				
			else
				state_next<=DE_DE1;
			end if;

		when DE_OUT1=>
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key2;
			load_key_i<="10";
			output_ok_reg<='0';
			des_mode<='0';
			rdy_i<='1';
--			out_data<=x"0000000000000000";
			state_next<=DE_ST2;
--			state_next<=DE_EN;
			
		when DE_ST2=>
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key2;
			load_key_i<="10";
			output_ok_reg<='0';
			des_mode<='0';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			state_next<=DE_EN;
		
		when DE_EN=>

--			tmp_i<=tmp_i;
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key2;
			load_key_i<="10";
			output_ok_reg<='0';
			des_mode<='0';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			if (out_ok_i='1') then
				state_next<=DE_OUT2;
			else
				state_next<=DE_EN;
			end if;
		
		when DE_OUT2=>
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key1;
			load_key_i<="01";
			output_ok_reg<='0';
			des_mode<='1';
			rdy_i<='1';
--			out_data<=x"0000000000000000";
			state_next<=DE_ST3;
--			state_next<=DE_DE2;
		
		when DE_ST3=>
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key1;
			load_key_i<="01";
			output_ok_reg<='0';
			des_mode<='1';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			state_next<=DE_DE2;
		
		when DE_DE2=>
--			tmp_i<=tmp_i;
--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key1;
			load_key_i<="01";
			output_ok_reg<='0';
			des_mode<='1';
			rdy_i<='0';
--			out_data<=x"0000000000000000";
			if (out_ok_i='1') then
				state_next<=DE_OUT3;
			else
				state_next<=DE_DE2;			 	
			end if;
		
		when DE_OUT3=>

--			tmp_i<=tmp_o;
			load_tmp_i<='0';
--			key_i<=key1;
			load_key_i<="01";
			output_ok_reg<='1';
			des_mode<='1';
			rdy_i<='0';
--			out_data<=tmp_o; ---- output 3DES decrypt result
			state_next<=IDLE;
			
		when others=>
			NULL;

	end case;
end process;

process (clk,reset)
begin
--	if (clk'event and clk = '1') then
--		state<=state_next;
--	end if;
--	if(reset='1') then
--		state<=IDLE;	
--	end if;	
	if (clk'event and clk = '1') then
		if (reset = '1') then
			state<=IDLE;
		else
			state<=state_next;
		end if;
	end if;
end process;

end behavioral;

