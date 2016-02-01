-------------------------
--  DES Encrypt control
-------------------------
library ieee;
use ieee.std_logic_1164.all;
entity control_new is port
		(
		reset : in std_logic;
		clk : in std_logic;
		ready : in std_logic;
		mode : in std_logic;
		load_new_pt : out std_logic;
		output_ok : out std_logic;
		shift : out std_logic_vector(1 to 3)
		);
end control_new;

architecture behavior of control_new is
	type typeetat is (INIT, R1, R2, R3, R4, R5, R6,
	R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R_OUT, IDLE);
	signal etat, etatfutur : typeetat; --etat的类型是上面定义的typeetat枚举类型数据。
	signal shift_in : std_logic_vector(1 to 2);
begin
	process(etat, ready, mode)
	begin
		case etat is

		  when IDLE =>
		    	load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "00";
		    if(ready = '1') then
		      etatfutur <= INIT;
		    else
		      etatfutur <= IDLE;
		    end if;
			when INIT =>
				load_new_pt <= '0';
				output_ok<= '0';
				if(mode = '0') then
				  shift_in <= "01";
				else
				  shift_in <= "00";
				end if;
				etatfutur <= R1;
			when R1 =>-- 16 round
				load_new_pt <= '1';
				output_ok<= '0';
				shift_in <= "01";
				etatfutur <= R2;
			when R2 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R3;
			when R3 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R4;
			when R4 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R5;
			when R5 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R6;
			when R6 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R7;
			when R7 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R8;
			when R8 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "01";
				etatfutur <= R9;
			when R9 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R10;
			when R10 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R11;
			when R11 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R12;
			when R12 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R13;
			when R13 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R14;
			when R14 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "10";
				etatfutur <= R15;
			when R15 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "01";
				etatfutur <= R16;
			when R16 =>
				load_new_pt <= '0';
				output_ok<= '0';
				shift_in <= "00";
				etatfutur <= R_OUT;
			when R_OUT =>-- output data
        load_new_pt <= '0';
        output_ok<= '1';
        shift_in <= "00";
        etatfutur <= IDLE;
    end case;
	end process;
	
	process (clk, reset)
	begin
--		if (clk'event and clk = '1') then
--			etat <= etatfutur;
--		end if;
--		if(reset='1') then
--			etat<=IDLE;
--		end if;
		if (clk'event and clk = '1') then
			if (reset = '1') then
				etat<=IDLE;
			else
				etat<=etatfutur;
			end if;
		end if;
	end process;
	
	shift <= mode & shift_in;
	
end behavior;
