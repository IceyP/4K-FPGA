-------------------------------------
-- This is the top level between 8051 and 3DES
-------------------------------------
--
-- Data bus 8 bits
-- Address bus 12 bits 
-- 0x200 ~ x207 : 	input register 
-- 0x208 : 			CW_add register (low 6 bits is address for send CW to next block
--									 high 2 bits is index of scrambler)
-- 0x209 :			control register 
--					RESET when contrl register = "00000" 
-- 0x210~0x21f	:   output register
-- 0x220~0x22f	:	dsk XOR data(input from 8051)
-- DCK=key(DSK)+data(input), nomorly only once 
-- CW=key(DCK)+data(input), use DCK1 and DCK2 
-------------------------------------
-------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library XilinxCoreLib;

entity security_module is port
(
	clock: 	in std_logic;
	reset:	in std_logic;							-- '0' reset							
	wen :  in std_logic;							-- 8051 write en
	ren :  in std_logic;							-- 8051 read en 
	in_data:	in std_logic_vector(7 downto 0);	-- data bus
	address:in std_logic_vector(11 downto 0);		-- add bus 
	r_data: out std_logic_vector(7 downto 0); 		-- data/state for 8051 read back
	out_data: out std_logic_vector(7 downto 0); 	-- data output to scrambler
	out_cw_add: out std_logic_vector(8 downto 0); 	-- CW address output to scrambler
	swen : out std_logic;							-- write cw enable signal for scrambler, when '1' output data
	scram_n : out std_logic_vector(1 downto 0);		-- index of scrambler (selected by 8051)
	--------------------------
	-- DSK rom
	dsk_add : out std_logic_vector(5 downto 0);
	dsk_data : in std_logic_vector(7 downto 0)
);
end security_module;

architecture behavioral of security_module is

component TDES_Top port
	(	
	clk: in std_logic;
	reset: in std_logic;
	ready: in std_logic;
	in_data: in std_logic_vector(63 downto 0);
	key1: in std_logic_vector(63 downto 0);
	key2: in std_logic_vector(63 downto 0);
	mode: in std_logic;
	out_data: out std_logic_vector(63 downto 0);
	output_ok : out std_logic
	);
end component;

component dck_ram port 
	(
	addra: IN std_logic_VECTOR(3 downto 0);-- write address 
	addrb: IN std_logic_VECTOR(3 downto 0);-- read address
	clka: IN std_logic;-- clock
	clkb: IN std_logic;-- clock
	dina: IN std_logic_VECTOR(7 downto 0);-- input data
	doutb: OUT std_logic_VECTOR(7 downto 0);-- output data
	wea: IN std_logic_VECTOR(0 downto 0)-- wen
	);
end component;

--component dsk_rom IS
--	port (
--	addr: IN std_logic_VECTOR(3 downto 0);
--	clk: IN std_logic;
--	dout: OUT std_logic_VECTOR(7 downto 0));
--end component;

---------------------------------------------------
constant mode : std_logic:='1';

signal tdes_in_data, tdes_out_data : std_logic_vector(63 downto 0);
signal key1, key2: std_logic_vector(63 downto 0);
signal skey, dck_out, tdes_result: std_logic_vector(7 downto 0);
signal tdes_mode: std_logic_vector(2 downto 0);
signal ctrl_reg : std_logic_vector(7 downto 0);
--bit 0: =1 reset, or use glable reset signal
--bit 1: =1 start tdes
--bit 4,3,2: ="000" dck1
--           ="001" dck2
--           ="010" tsk1
--           ="011" tsk2
--           ="100" cw
--bit 5 RO  tdes_ok

signal cw_add_reg : std_logic_vector(5 downto 0); -- low 5 bits is cw address register, (00000~11111) 32 * 64 bit, address = C48
signal tdes_out_ok, tdes_ok_reg, tdes_reset, tdes_start, tdes_load_key, dck_wen : std_logic;
--------------------
-- State machine
type state_lw is (	idle,
					load_key, 
					load_end,
					write_result,
					write_end);
signal st_lw: state_lw;
--------------------
signal lw_add: std_logic_vector(3 downto 0); -- dsk_rom add and dck_ram add

-----------------------GX 2007.12.4----------
signal st_lw_delay: state_lw;
signal lw_add_x: std_logic_vector(3 downto 0); -- dsk_rom add and dck_ram add
signal lw_add_delay: std_logic_vector(3 downto 0);--dsk_rom add and dck_ram add delayed for one clock cycle
---------------------------------------------

signal ram_wadd : std_logic_vector(3 downto 0);
signal scram_n_reg : std_logic_vector (1 downto 0); -- index of scrambler
---------------------------------
-- DSK rom signal
--signal dsk_add : std_logic_vector(3 downto 0);
signal dsk_dx1, dsk_dx2 : std_logic_vector(63 downto 0);
---------------------------------

begin
--------SIGNAL------------------------
out_cw_add<=cw_add_reg & lw_add(2 downto 0);-- CW address( 9 bits) to scarmbler
ram_wadd<=tdes_mode(0) & lw_add(2 downto 0); -- ram write address (4 bits)
out_data<=tdes_result;						-- 8 bits, output of tdes from 64 to 8
swen<='1' when st_lw=write_result and tdes_mode="100" else '0'; -- mode is cw
dck_wen<='1' when st_lw=write_result and (tdes_mode="000" or tdes_mode="001") else '0'; -- mode is dck1 or dck2
--tdes_reset<=ctrl_reg(0); -- Reset signal
tdes_reset<=(not(reset)) or ctrl_reg(0);
tdes_load_key<=ctrl_reg(1) ; -- Start of tdes process
tdes_start<='1' when st_lw=load_end else '0'; -- Start tdes process after load key(dsk or dck)
scram_n<=scram_n_reg; 

tdes_mode<=ctrl_reg(4 downto 2);
-------------------------------------------

-----------------------EDIT BY GX ON 2007.12.4----------
lw_add_x<=lw_add;
process(clock)
begin 
if clock'event and clock='1' then
st_lw_delay<=st_lw;
lw_add_delay<=lw_add_x;
end if;
end process;
-------------use lw_add_delay instead of lw_add for opne cycle delay-------------

skey<= 	(dsk_data XOR dsk_dx1(63 downto 56)) when lw_add_delay=x"0" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(55 downto 48)) when lw_add_delay=x"1" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(47 downto 40)) when lw_add_delay=x"2" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(39 downto 32)) when lw_add_delay=x"3" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(31 downto 24)) when lw_add_delay=x"4" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(23 downto 16)) when lw_add_delay=x"5" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1(15 downto  8)) when lw_add_delay=x"6" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx1( 7 downto  0)) when lw_add_delay=x"7" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(63 downto 56)) when lw_add_delay=x"8" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(55 downto 48)) when lw_add_delay=x"9" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(47 downto 40)) when lw_add_delay=x"a" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(39 downto 32)) when lw_add_delay=x"b" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(31 downto 24)) when lw_add_delay=x"c" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(23 downto 16)) when lw_add_delay=x"d" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2(15 downto  8)) when lw_add_delay=x"e" and (tdes_mode="000" or tdes_mode="001") else
		(dsk_data XOR dsk_dx2( 7 downto  0)) when lw_add_delay=x"f" and (tdes_mode="000" or tdes_mode="001") else
		dck_out;
-------------------------------------		
dsk_add(3 downto 0)<=lw_add when tdes_mode="000" or tdes_mode="001" else x"0"; -- dsk_rom address
dsk_add(5 downto 4)<=ctrl_reg(7 downto 6);
---------PROCESS-----------------------
dck_inst: dck_ram port map
	(
	addra=>ram_wadd,-- write address 
	addrb=>lw_add,-- read address
	clka=>clock,-- clock
	clkb=>clock,-- clock
	dina=>tdes_result,-- input data
	doutb=>dck_out,-- output data
	wea(0)=>dck_wen-- wen
	);

--dsk_inst: dsk_rom port map
--	(
--	addr=>lw_add,
--	clk=>clock,
--	dout=>dsk_out
--	);

tdes_top_inst: TDES_Top port map 
	( 
	clk=>clock,
	key1=>key1,  
	key2=>key2,
	mode=>mode,
	reset=>tdes_reset,
	ready=>tdes_start,
	in_data=>tdes_in_data,
	out_data=>tdes_out_data,
	output_ok=>tdes_out_ok
	);


---------------------------------------
-- Input DATA for TDES
---------------------------------------
process(clock, reset)
begin
if (reset='0') then
	tdes_in_data<=x"0000000000000000";
	cw_add_reg<="000000";
	scram_n_reg<="00";
	ctrl_reg<=x"00";
elsif(clock'event and clock='1')then
		if(wen='0')then
			case address is 
		---------------------------------------
			when X"E07" => tdes_in_data(7  downto 0)<=in_data;
			when X"E06" => tdes_in_data(15 downto 8)<=in_data;
			when X"E05" => tdes_in_data(23 downto 16)<=in_data;
			when X"E04" => tdes_in_data(31 downto 24)<=in_data;
			when X"E03" => tdes_in_data(39 downto 32)<=in_data;
			when X"E02" => tdes_in_data(47 downto 40)<=in_data;
			when X"E01" => tdes_in_data(55 downto 48)<=in_data;
			when X"E00" => tdes_in_data(63 downto 56)<=in_data;
		----------------------------------------
			when X"E08" => cw_add_reg<=in_data(5 downto 0);
						   scram_n_reg<=in_data(7 downto 6);
			when X"E09" => ctrl_reg<=in_data;
		----------------------------------------
			when X"E27" => dsk_dx1(7  downto 0) <=in_data;
			when X"E26" => dsk_dx1(15 downto 8) <=in_data;
			when X"E25" => dsk_dx1(23 downto 16)<=in_data;
			when X"E24" => dsk_dx1(31 downto 24)<=in_data;
			when X"E23" => dsk_dx1(39 downto 32)<=in_data;
			when X"E22" => dsk_dx1(47 downto 40)<=in_data;
			when X"E21" => dsk_dx1(55 downto 48)<=in_data;
			when X"E20" => dsk_dx1(63 downto 56)<=in_data;
			
			when X"E2F" => dsk_dx2(7  downto 0) <=in_data;
			when X"E2E" => dsk_dx2(15 downto 8) <=in_data;
			when X"E2D" => dsk_dx2(23 downto 16)<=in_data;
			when X"E2C" => dsk_dx2(31 downto 24)<=in_data;
			when X"E2B" => dsk_dx2(39 downto 32)<=in_data;
			when X"E2A" => dsk_dx2(47 downto 40)<=in_data;
			when X"E29" => dsk_dx2(55 downto 48)<=in_data;
			when X"E28" => dsk_dx2(63 downto 56)<=in_data;
			
			when others => NULL;
			end case;
		end if; 
                        
		if(ctrl_reg(1)='1' and st_lw/=idle)then 
			ctrl_reg(1)<='0';
		end if;
		
end if;
end process;

proc_load_write: process(clock, reset)
begin
if (reset='0') then
	st_lw<=idle;
elsif(clock'event and clock='1')then
	case st_lw is
		when idle=>
			if(tdes_load_key='1')then
				st_lw<=load_key;
			end if;
			if(tdes_out_ok='1')then
				st_lw<=write_result;
			end if;
		when load_key=>
			if(lw_add=15)then
				st_lw<=load_end;
			end if;
		when write_result=>
			if(lw_add=7)then
				st_lw<=write_end;
			end if;
		when load_end=>	st_lw<=idle;
		when write_end=>st_lw<=idle;
		when others=>   st_lw<=idle;
	end case;
end if;
end process proc_load_write;

proc_lw_add: process(clock, reset)
begin
if (reset='0') then
	lw_add<="0000";
elsif(clock'event and clock='1')then
	if(st_lw=load_key or st_lw=write_result)then
		lw_add<=lw_add+1;
	else 
		lw_add<="0000";
	end if;
end if;
end process proc_lw_add;


------------DSK XOR---------------

----------------------------------

--------------------
-- key
--skey<= dsk_out when tdes_mode="000" or tdes_mode="001" else dck_out;

--------------------
proc_load_key: process(clock, reset)
begin
if (reset='0') then
	key1<=x"0000000000000000";
	key2<=x"0000000000000000";
elsif(clock'event and clock='1')then
		if(st_lw_delay=load_key) then  --- EDIT BY GX st_lw=>st_lw_delay
			case lw_add_delay is  ---------- EDIT BY GX ON 2007.12.4  lw_add=>lw_add_delay
			when X"0"=>key1(63 downto 56)<= skey;     
			when X"1"=>key1(55 downto 48)<= skey;     
			when X"2"=>key1(47 downto 40)<= skey;     
			when X"3"=>key1(39 downto 32)<= skey;     
			when X"4"=>key1(31 downto 24)<= skey;     
			when X"5"=>key1(23 downto 16)<= skey;     
			when X"6"=>key1(15 downto  8)<= skey;     
			when X"7"=>key1( 7 downto  0)<= skey;     
			when X"8"=>key2(63 downto 56)<= skey;     
			when X"9"=>key2(55 downto 48)<= skey;     
			when X"a"=>key2(47 downto 40)<= skey;     
			when X"b"=>key2(39 downto 32)<= skey;     
			when X"c"=>key2(31 downto 24)<= skey;     
			when X"d"=>key2(23 downto 16)<= skey;     
			when X"e"=>key2(15 downto  8)<= skey;     
			when X"f"=>key2( 7 downto  0)<= skey;
			when others=> null;
			end case;     
		end if;
end if;
end process proc_load_key;

-------------------------------
-- Output TDES output ok signal
proc_tdes_ok: process(clock, reset)
begin
if (reset='0') then
	tdes_ok_reg<='0';
elsif(clock'event and clock='1')then
	if(tdes_out_ok='1')then
		tdes_ok_reg<='1';
	elsif(tdes_start='1') then
		tdes_ok_reg<='0';
	end if;
end if;
end process proc_tdes_ok;

---------------------------------
-- Output DATA
---------------------------------
-- 2007.11.1 
-- TDES Output exchange high 4 Byte and low 4 Byte
-- 8 bytes
-- 0 1 2 3  4 5 6 7
-- -------  -------
--       \  /
--        \/
--        /\
--       /  \
-- -------  -------
-- 4 5 6 7  0 1 2 3
---------------------------------
WITH lw_add SELECT

	tdes_result <= 	tdes_out_data(63 downto 56) WHEN X"4",
			tdes_out_data(55 downto 48) WHEN X"5",
			tdes_out_data(47 downto 40) WHEN X"6",
			tdes_out_data(39 downto 32) WHEN X"7",
			tdes_out_data(31 downto 24) WHEN X"0",
			tdes_out_data(23 downto 16) WHEN X"1",
			tdes_out_data(15 downto  8) WHEN X"2",
			tdes_out_data( 7 downto  0) WHEN X"3",
			X"00" when others;
--------------------------------------
-- Read input and output data for test
--------------------------------------
with address select 
	r_data<=tdes_in_data(7  downto 0)  when x"E07",  -- read input data
        	tdes_in_data(15 downto 8)  when x"E06",  
	     	tdes_in_data(23 downto 16) when x"E05",  
    	    tdes_in_data(31 downto 24) when x"E04", 
        	tdes_in_data(39 downto 32) when x"E03", 
            tdes_in_data(47 downto 40) when x"E02", 
            tdes_in_data(55 downto 48) when x"E01", 
	     	tdes_in_data(63 downto 56) when x"E00",
	       
            "00" & cw_add_reg          when x"E08", -- read input cw add
            "00" & tdes_ok_reg & ctrl_reg(4 downto 0) when x"E09", -- read input control register
------------------------------------------------
-- 2007.11.1 new
		-- read output data 
            tdes_out_data(63 downto 56)when x"E14", 
			tdes_out_data(55 downto 48)when x"E15",
            tdes_out_data(47 downto 40)when x"E16", 
            tdes_out_data(39 downto 32)when x"E17", 
            tdes_out_data(31 downto 24)when x"E10", 
            tdes_out_data(23 downto 16)when x"E11", 
            tdes_out_data(15 downto 8) when x"E12", 
			tdes_out_data(7  downto 0) when x"E13", 
-----------------------------------------------
            X"00"			   when others; 
end behavioral;

