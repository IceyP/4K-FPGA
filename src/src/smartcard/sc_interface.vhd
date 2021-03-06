library IEEE;
use IEEE.std_logic_1164.all;
PACKAGE cm_pack IS
	FUNCTION bool2stdlogic (b : BOOLEAN) RETURN STD_LOGIC;
END cm_pack;

PACKAGE BODY cm_pack IS
	FUNCTION bool2stdlogic (b : BOOLEAN) RETURN STD_LOGIC IS
		VARIABLE temp : STD_LOGIC;
	BEGIN
		if (b) then
			temp := '1';
		else
			temp := '0';
		end if;
		return temp;
	END;
END cm_pack;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.cm_pack.all;


entity SC_INTERFACE is
    port (
    	reset : in std_logic;
    	PCI_CLK: in STD_LOGIC;
        SC_SCK: out STD_LOGIC;
        HOST_ADD: in STD_LOGIC_VECTOR (9 downto 0);
		HOST_WE: in STD_LOGIC;
		HOST_RD: in STD_LOGIC;
        CS: in STD_LOGIC;
        WDATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
        WDATA_OUT: out STD_LOGIC_VECTOR (7 downto 0);
		--SC_DATA: inout STD_LOGIC; -- smart card input / output data
		SC_DATA_I: in STD_LOGIC;
		SC_DATA_O: out STD_LOGIC;
	
        SC_RST_O: out STD_LOGIC;
		SC_SW: in STD_LOGIC;
		SC_ON: out STD_LOGIC;
		SC_SEL35: out STD_LOGIC;
		SC_INTP: out STD_LOGIC
		-----------------
		--CW_add: in std_logic_vector(3 downto 0);
		--CW_out: out std_logic_vector(7 downto 0)
		-----------------
    );
end SC_INTERFACE;

architecture SC_INTERFACE_arch of SC_INTERFACE is

--component SC_BUFFER
--	PORT
--	(
--		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		wren_a		: IN STD_LOGIC  := '1';
--		address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
--		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
--		wren_b		: IN STD_LOGIC  := '1';
--		clock		: IN STD_LOGIC ;
--		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
--		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
--	);
--end component;

------------------------------
-- Data Buffer for input/output data 
-- between FPGA and Smart Card interface Chip
------------------------------
component cw_ram port 
	(
	addra: IN std_logic_VECTOR(8 downto 0);
	addrb: IN std_logic_VECTOR(8 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR(7 downto 0);
	dinb: IN std_logic_VECTOR(7 downto 0);
	douta: OUT std_logic_VECTOR(7 downto 0);
	doutb: OUT std_logic_VECTOR(7 downto 0);
	ena: IN std_logic;
	enb: IN std_logic;
	wea: IN std_logic_VECTOR(0 downto 0);
	web: IN std_logic_VECTOR(0 downto 0)
	);
end component;

------------------------
--component cw_filter
--    port (F_DataIn: in  std_logic_vector(7 downto 0); 
--        F_DataOut: out  std_logic_vector(7 downto 0);
--        Addr: in  std_logic_vector(8 downto 0); 
--        Clk: in  std_logic; 
--        WEN: in  std_logic;
--		O_E: in std_logic;
--		status_3a: out std_logic;
--		CW_add: in std_logic_vector(3 downto 0);
--		CW_out: out std_logic_vector(7 downto 0)
--		); 
--end component;
-----------------------
signal sck: std_logic;
signal sck_dv: std_logic_vector(2 downto 0);
--signal SC_DATA_O: STD_LOGIC;
--signal SC_DATA_I: STD_LOGIC;
signal SC_INT, SC_INT_d:  STD_LOGIC_VECTOR(2 downto 0);

signal scbuf_wea: std_logic;
signal scbuf_oe: std_logic;
signal scbuf_doa: std_logic_vector(7 downto 0);
signal SC_READBACK_DATA: STD_LOGIC_VECTOR (7 downto 0);
signal SC_READBACK_WEB: std_logic;
signal SC_WRITE_DATA: STD_LOGIC_VECTOR (7 downto 0);
signal SC_READER_ADD: STD_LOGIC_VECTOR (8 downto 0);

signal cmd, status: std_logic_vector(7 downto 0);
signal wdata: std_logic_vector(8 downto 0);
signal cmd_cs, cmd_oe, cmd_we: std_logic;
signal status_cs, status_oe, status_we: std_logic;
signal wdata_csl, wdata_oel, wdata_wel: std_logic;
signal wdata_csh, wdata_oeh, wdata_weh: std_logic;
signal sc_idle, sc_reset, sc_send_data, sc_get_data, sc_wait: std_logic;
signal sc_state:std_logic_vector(4 downto 0);
signal reset_end, send_data_end, get_data_end, wait_end: std_logic;

signal etu_dv: std_logic_vector(8 downto 0);
signal etu_f, etu_hf: std_logic;
signal reset_cnt: std_logic_vector(1 downto 0);
signal sradd: std_logic_vector(8 downto 0);
signal srw: std_logic;
signal wait_start_bit_d, get_data_bit,wait_start_bit,start_bit: std_logic;--
signal db_in, db_out:std_logic_vector(7 downto 0);
signal bit_cnt: std_logic_vector(3 downto 0);
signal sdo, par_bit: std_logic;
signal swd: std_logic;
signal no_response: std_logic;
signal nr_cnt: std_logic_vector(5 downto 0);
signal etu_cnt: std_logic_vector(15 downto 0);
signal get_finish, wait_start_bit_end, get_data_bit_end:std_logic;
signal continue_wait: std_logic;
signal wdata_outm: std_logic_vector(7 downto 0);
signal WADD: STD_LOGIC_VECTOR (2 downto 0);
signal WWEB: STD_LOGIC;
signal WOEB: STD_LOGIC;
signal sc_switch: std_logic;
signal sc_sw_cnt: std_logic_vector(15 downto 0);
signal last_wait: std_logic;

signal etu_f_cnt: std_logic_vector(3 downto 0);
signal etu_f_cnt_flag: std_logic;
signal get_bit_cnt: std_logic_vector(3 downto 0);

signal sc_int_out,  sc_writeint: std_logic; --sc_readint,
signal sc_int_mask, sc_int_reg: std_logic_vector(1 downto 0);
signal sc_pctl_reg: std_logic_vector(1 downto 0);
signal O_E : std_logic;
signal status_3a: std_logic;


constant st_idle:std_logic_vector(4 downto 0)        :=("10000");
constant st_reset:std_logic_vector(4 downto 0)       :=("01000");
constant st_send_data:std_logic_vector(4 downto 0)   :=("00100");
constant st_get_data:std_logic_vector(4 downto 0)    :=("00010");
constant st_wait:std_logic_vector(4 downto 0)        :=("00001");

--signal F_DataOut: std_logic_vector(7 downto 0);

begin
WADD <= HOST_ADD(2 downto 0);
WWEB <= HOST_WE and HOST_ADD(9) and CS;
WOEB <= HOST_RD and HOST_ADD(9) and CS;
scbuf_wea<=(HOST_WE and not(HOST_ADD(9)) and cs);
scbuf_oe<=(HOST_RD and not(HOST_ADD(9)) and cs);
--SC_DATA_I<=SC_DATA;
--SC_DATA<=SC_DATA_O when SC_DATA_O = '0' else 'Z';


WDATA_OUT<=wdata_outm when (WOEB)='1' else scbuf_doa;

-----------------------------------------------
-- Data Buffer for input/output data 
-- between FPGA and Smart Card interface Chip
-----------------------------------------------
SC_BUFFER_inst:  cw_ram port map
	(
	addra	=>HOST_ADD(8 downto 0), --write address(8051 to smart card)
	addrb	=>SC_READER_ADD, 		--address (smart card to 8051)
	clka	=>PCI_CLK, 				--write address
	clkb	=>PCI_CLK,				--read address
	dina	=>WDATA_IN,				--write data from 8051 to smart card
	dinb	=>SC_READBACK_DATA,		--write data from smart card to 8051
	douta	=>scbuf_doa,			--Read data from 8051 tosmart card
	doutb	=>SC_WRITE_DATA,		--Read data from smart card to 8051
	ena		=>'1',
	enb		=>'1',
	wea(0)  =>scbuf_wea,			--write enable from 8051
	web(0)  =>SC_READBACK_WEB		--write enable from ??
	);

---------------------
--cw_filter_inst: cw_filter
--    port map(
--		F_DataIn=>SC_READBACK_DATA,
--		F_DataOut=>F_DataOut,
--		Addr=>SC_READER_ADD,
--		Clk=>sck, ---PCI_CLK,
--		WEN=>SC_READBACK_WEB,
--		O_E=>O_E,
--		status_3a=>status_3a,
--		CW_add=>CW_add,
--		CW_out=>CW_out
--		);
------------------------

sck <= sck_dv(2); -- 8 divider
SC_SCK <= sck;
SC_RST_O <= not(sc_reset);
--SC_DATA_O <= sdo; -- smart card output data
SC_DATA_O <= sdo when reset='1' else '0'; -- smart card output data
--SC_INT<= get_finish or no_response;
SC_INT(0)<=sc_idle and (get_finish or no_response);
SC_INT(1)<=sc_switch;
SC_INT(2)<=not(sc_switch);
--SC_DATA_T <= '1';
--SC_ON <= not(sc_switch); --poweron when SC_ON is low
SC_ON <= not (sc_pctl_reg(0) and sc_switch); --CMDVCC is active low
sc_int_out <= (sc_int_reg(0) and sc_int_mask(0)) or  (sc_int_reg(1) and sc_int_mask(1));
SC_INTP <= sc_int_out;
SC_SEL35 <= sc_pctl_reg(1);
-----------
SC_READBACK_DATA <= db_in;
SC_READER_ADD <= sradd;
SC_READBACK_WEB <= srw;
----------


cmd_cs <= bool2stdlogic(WADD="000") and cs;
status_cs <= bool2stdlogic(WADD="001") and cs;
wdata_csl <= bool2stdlogic(WADD="010") and cs;
wdata_csh <= bool2stdlogic(WADD="011") and cs;

cmd_we <= cmd_cs and WWEB;
status_we <= status_cs and WWEB;
wdata_wel <= wdata_csl and WWEB;
wdata_weh <= wdata_csh and WWEB;
sc_writeint <= bool2stdlogic(WADD="110") and cs and WWEB;
-------------------
sc_idle <= sc_state(4);
sc_reset <= sc_state(3); 
sc_send_data <= sc_state(2);
sc_get_data <= sc_state(1);
sc_wait <= sc_state(0);
-------------------

--process(cmd, status, wdata,sradd, WADD)
--begin
--	case WADD is
--	with WADD select 
--	when "000" =>
--		wdata_outm <= cmd;
--	when "001" =>
--		wdata_outm <= status;
--	when "010" =>
--		wdata_outm <= wdata(7 downto 0) ;
--	when "011" =>
--		wdata_outm <= "0000000" & wdata(8) ;
--	when "100" =>
--		wdata_outm <= sradd(7 downto 0) ;
--	when "101" =>
--		wdata_outm <= "0000000" & sradd(8) ;
--	when "110" =>
--		wdata_outm <= "00" & sc_pctl_reg & sc_int_mask & sc_int_reg;
--	when others => NULL;
--	end case;
--end process;

	with WADD select 
	wdata_outm<= cmd when "000",
				status when "001",
				wdata(7 downto 0)when "010",
				"0000000" & wdata(8) when "011",
				sradd(7 downto 0) when "100",
				"0000000" & sradd(8) when "101",
				"00" & sc_pctl_reg & sc_int_mask & sc_int_reg when "110",
				"00000000" when others;

--Smartcard命令寄存器：
--Bit0: 置1时，复位Smartcard，IC卡返回的复位序列自动写入缓冲区，
--      接收到的字节数存放在SC_RDATA中。该比特能自动清零。
--Bit1: 开始向SmartCard发送数据，发送字节数由SC_WDATA设定。
--      发送完毕后，自动转入接收IC卡返回数据模式。该比特能自动清零。
--Bit2: 进入接收IC卡数据状态，该比特能自动清零。
--Bit3: 中止接收等待。该比特自动能自动清零。
--Bit4: =1: 设定IC卡通信采用反向约定，＝0：采用正向约定。
--Bit5: =1: 等待超时的时限设定为IC卡复位模式
--      =0: IC卡正常传输模式。
--          当超过时限后，则停止等待。
--Bit7,6: =00: 9600baud
--		  =01: 38400baud
--		  =10: 57600baud
--		  =11: 115200baud

--IntReg
--Bit0：读取SmartCard返回的数据结束'1'清零'0'
--Bit1：发生了SmartCard插入或者拔出，写入'1'清零，写'0'无效
--Bit2：Bit0的Mask
--Bit3：Bit1的Mask
--Bit4: =0: power off
--      =1: power on
--Bit5: =0: set card power supply to 3V
--      =1: set card power supply to 5V

--Smartcard状态寄存器：
--Bit0：＝1：空闲状态
--Bit1：＝1：复位状态
--Bit2：＝1：发送数据
--Bit3：＝1：接收数据
--Bit4：＝1：等待数据
--Bit5：＝1：IC没有响应
--Bit6：＝1：接收数据完毕
--Bit7：=1;

process(PCI_CLK, reset)
begin
if (reset='0') then
	cmd<=x"00";
	sck_dv<="000";
	status<=x"00";
	wdata<="000000000";
	sc_int_mask<="00";
	sc_pctl_reg<="00";
else
	if(PCI_CLK'EVENT and PCI_CLK='1')then
		sck_dv <= sck_dv + '1';
		status(7) <= SC_SW;
		status(6) <= get_finish;
		status(5) <= no_response;
		status(4) <= sc_wait;
		status(3) <= sc_get_data;
		status(2) <= sc_send_data;
		status(1) <= sc_reset;
		status(0) <= sc_idle;	

		if(cmd_we='1')then
--			if(sck_dv/=3)then
				cmd(7 downto 3) <= WDATA_IN(7 downto 3);
--			if(sc_state=st_idle) then
				cmd(2 downto 0)<= WDATA_IN(2 downto 0);
--			end if;
--			end if;
		elsif (sc_state/=st_idle) then
			cmd(2 downto 0) <= "000";
			if(get_data_end='1')then
				cmd(3) <= '0';
			end if;
		end if;

		if(wdata_wel='1')then
			wdata(7 downto 0) <= WDATA_IN;
		end if;

		if(wdata_weh='1')then
			wdata(8) <= WDATA_IN(0);
		end if;
		
		if(sc_writeint='1')then
			sc_int_mask<=WDATA_IN(3 downto 2);
			sc_pctl_reg<=WDATA_IN(5 downto 4);
		end if;
	end if;	
end if;
end process;

sc_int_proc: process(PCI_CLK, reset)
begin
if (reset='0') then
	sc_int_reg<="00";
else
	if(PCI_CLK'event) and (PCI_CLK='1')then
		SC_INT_d <= SC_INT;
		if(sc_int_reg(0)='0')then
			if(SC_INT(0)='1' and SC_INT_d(0)='0')then
				sc_int_reg(0)<='1';
			end if;
		else
			if(sc_writeint='1' and WDATA_IN(0)='1')then
				sc_int_reg(0)<='0';
			end if;
		end if;
		if(sc_int_reg(1)='0')then
			if ((SC_INT(1)xor SC_INT_d(1))='1')then
				sc_int_reg(1)<='1';
			end if;
		else
			if(sc_writeint='1' and WDATA_IN(1)='1')then
				sc_int_reg(1)<='0';
			end if;
		end if;
	end if;
end if;
end process sc_int_proc;


process(sck, reset)

begin
if (reset='0') then
	sc_state<=st_idle;
else
	if(sck'event and sck='1')then
--	if(PCI_CLK'event) and (PCI_CLK='1')then
		case sc_state is
			when st_idle =>
				if(cmd(0)='1')then
					sc_state <= st_reset;
				elsif(cmd(1)='1')then
					sc_state <= st_send_data;
				elsif(cmd(2)='1')then
					sc_state <= st_wait;--continue to wait for getting data
				end if;

			when st_send_data =>
				if(send_data_end='1') then
					sc_state <= st_wait;
				end if;

			when st_reset =>
				if(reset_end='1') then
					sc_state <= st_wait;
				end if;

			when st_wait =>
				if(wait_end='1')then
					if(no_response='1')then
						sc_state <= st_idle;
					else
						sc_state <= st_get_data;
					end if;
				end if;

			when st_get_data =>
				if(get_data_end = '1') then
					if(continue_wait ='1')then
						sc_state <= st_wait;
					else
						sc_state <= st_idle;
					end if;
				end if;
			when others=>
				sc_state <= st_idle;
		end case;				
	end if;
end if;
end process;


reset_proc: process(sck, reset, sc_reset)
begin
if (reset='0') then
	reset_end <= '0';
else
	if(sc_reset = '0') then
		reset_end <= '0';
	else
		if(sck'event and sck='1')then
			if(etu_cnt(2 downto 0) = "100") then  --4 etus
				reset_end <= '1';
			end if;
		end if;
	end if;
end if;
end process reset_proc;


send_data_proc: process(sck, reset, sc_send_data, bit_cnt)
variable itemp: integer;
begin
	itemp := CONV_INTEGER(bit_cnt);		
if (reset='0') then
		send_data_end <= '0';	
		bit_cnt <= "0000";
		sdo <= '1';
		db_out <= "00000000";
		par_bit <= '0';
		swd <= '0';
else
	if(sc_send_data)='0'then
		send_data_end <= '0';	
		bit_cnt <= "0000";
		sdo <= '1';
		db_out <= "00000000";
		par_bit <= '0';
		swd <= '0';
		
	else
		if(sck'event and sck='1')then
			if(etu_f='1')then
--				if(bit_cnt = "1011")then
				if(bit_cnt = "1101")then
					bit_cnt <= "0000";
				else
					bit_cnt <= bit_cnt + '1';
				end if;

				case (itemp) is
	
				when 0 =>
					db_out <= SC_WRITE_DATA;
					if(sradd="000000001" and status_3a='1')then 
						O_E<=SC_WRITE_DATA(0); 
					end if;

					par_bit <= '0';
					sdo <= '0';
				
				when 1 to 8 =>
					if(cmd(4)='1')then
						sdo <=not(db_out(7));
						db_out(7 downto 1) <= db_out(6 downto 0);
						db_out(0) <= '0';
					else
						sdo <= (db_out(0));
						db_out(6 downto 0) <= db_out(7 downto 1);
						db_out(7) <= '0';
					end if;
					par_bit <= par_bit xor sdo;
			
				when 9=>
					if(cmd(4)='1')then
						sdo <= not ((par_bit) xor sdo);
					else 
						sdo <= ((par_bit) xor sdo);
					end if;
	
				when others =>
					sdo <= '1';
				end case;
			
			end if;
			
			if(bit_cnt="1011" and etu_f = '1') then
				swd <= '1';
			else
				swd <= '0';
			end if;
			
			if(sradd=wdata)then
				send_data_end <= '1';	
			end if;
		end if;
	end if;
end if;
end process send_data_proc;

wait_proc: process(sck, reset,sc_wait)
begin
if (reset='0') then
	wait_end<='0';
	no_response<='0';
else
	if(sc_wait='0')then
		wait_end <= '0';
--		no_response <= '0';
	else
		if(sck'event and sck='1')then
			if(SC_DATA_I='0')then
				wait_end <= '1';
				no_response <= '0';
			else
--				if(cmd(5)='0' and etu_cnt(13 downto 11)="101") or (cmd(5)='1' and etu_cnt(7)='1') then
				if(cmd(5)='0' and etu_cnt(15 downto 14)="11") or (cmd(5)='1' and etu_cnt(10)='1') then
					wait_end <= '1';
					no_response <= '1';
				end if;
			end if;
		end if;
	end if;
end if;
end process wait_proc;

get_data_proc: process(sck, reset, sc_get_data)
begin
if (reset='0') then
	get_data_end <= '0';
	wait_start_bit <= '0';
	get_data_bit<='1';	
	wait_start_bit_end <= '0';
	get_data_bit_end<='0';	
	continue_wait <= '0';
	get_bit_cnt<="0000";
else
	if(sc_get_data)='0'then
		get_data_end <= '0';
		wait_start_bit <= '0';
		get_data_bit<='1';	
		wait_start_bit_end <= '0';
		get_data_bit_end<='0';	
		continue_wait <= '0';
		get_bit_cnt<="0000";
	else
		if(sck'event and sck='1')then
			if(wait_start_bit_end ='1')then
				wait_start_bit_end <= '0';
			end if;

			if(get_data_bit_end ='1')then
				get_data_bit_end <= '0';
			end if;
--------------------get_data_bit------------
					
--			if(get_data_bit='1' and sc_reset = '0')then
			if(get_data_bit='1')then	
				--if get_bit_cnt="1100" then --Wrong!!!
				if get_bit_cnt="1011" then
					get_data_bit <= '0';
					wait_start_bit <= '1';
					get_data_bit_end <= '1';
				end if;
				
				if(etu_f='1') then 
					get_bit_cnt<=get_bit_cnt+1;
				end if;
				
				if(etu_hf='1')then
					if(cmd(4)='1')then
						db_in(0)<= not(SC_DATA_I);
						db_in(7 downto 1) <= db_in(6 downto 0);
					else
						db_in(7)<= (SC_DATA_I);
						db_in(6 downto 0) <= db_in(7 downto 1);
					end if;
				end if;
				
				if (etu_f='1') and (get_bit_cnt="1000") then
					srw <= '1';
				else
					srw <= '0';
				end if;
			
			else
				get_bit_cnt<="0000";
			end if;	
			--if(srw='1')and (sradd="00000000") and (db_in="01100000")then -- 0x60: NULL procedure
			--if(srw='1') and (db_in="01100000")then -- 0x60: NULL procedure
			if(srw='1')then   --刚收到1个字节
				if(db_in=X"60")then
					if(sradd=0)then   --第一个字节
						continue_wait <= '1';  --延长时间
						last_wait <= '1';   --设置标志位
					else --不是第一个字节
						if(last_wait='1') then   --上次
							continue_wait <= '1';  --延长时间
						end if;
					end if;
				else
					last_wait <= '0';  --遇到不是0x60，那么就清除标志
				end if;
			end if;
			

--------------------wait_start_bit------------
			if(wait_start_bit='1')then
				if(SC_DATA_I='1')then
					if((cmd(5)='0' and etu_cnt(4 downto 3)="11") or (cmd(5)='1'and etu_cnt(13 downto 11)="101"))then
							get_finish <= '1';
							get_data_end <= '1';
					end if;
				else
					wait_start_bit<='0';
					wait_start_bit_end <='1';
					get_data_bit <= '1';
					get_finish <= '0';
				end if;

				if cmd(3)='1' then
					get_data_end <= '1';
				end if;

			end if;

		end if;
	end if;
end if;
end process get_data_proc;


SC_READER_ADD_proc: process(sck, reset,send_data_end, cmd)--,reset_end)
begin
if (reset='0') then
	sradd <="000000000";
else
--	if (send_data_end or reset_end or cmd(1)) = '1' then
	if((cmd(2) or cmd(1) or cmd(0) or send_data_end) = '1') then
		sradd <="000000000";
	else
		if(sck'event and sck='1')then
			if (srw='1') or (swd = '1') then
				sradd <= sradd+'1';
			end if;	
		end if;
	end if;
end if;
end process SC_READER_ADD_proc;

----------------------


etu_f <= bool2stdlogic(etu_dv=371) when cmd(7)='0' and cmd(6)='0'   --9600
    else 	bool2stdlogic(etu_dv=185) when cmd(7)='0' and cmd(6)='1' --19200;
--	else 	bool2stdlogic(etu_dv=92) when cmd(7)='0' and cmd(6)='1' --38400;
	else 	bool2stdlogic(etu_dv=61) when cmd(7)='1' and cmd(6)='0' --57600;
	else 	bool2stdlogic(etu_dv=30);                               --115200;
	 
etu_hf <= bool2stdlogic(etu_dv=185) when cmd(7)='0' and cmd(6)='0'   --9600
    else 	bool2stdlogic(etu_dv=92) when cmd(7)='0' and cmd(6)='1' --19200;
--	else 	bool2stdlogic(etu_dv=46) when cmd(7)='0' and cmd(6)='1' --38400;
	else 	bool2stdlogic(etu_dv=30) when cmd(7)='1' and cmd(6)='0' --57600;
	else 	bool2stdlogic(etu_dv=15);                               --115200;

etu_f_cnt_flag <= bool2stdlogic(etu_f_cnt=0) when cmd(7)='0' and cmd(6)='0'   --9600
	else 	bool2stdlogic(etu_f_cnt=1) when cmd(7)='0' and cmd(6)='1' --19200;
--    else 	bool2stdlogic(etu_f_cnt=3) when cmd(7)='0' and cmd(6)='1' --38400;
	else 	bool2stdlogic(etu_f_cnt=5) when cmd(7)='1' and cmd(6)='0' --57600;
	else 	bool2stdlogic(etu_f_cnt=11);                               --115200;
	 
etu_divider: process(sck, reset, sc_idle, wait_end, wait_start_bit_end)
begin
if (reset='0') then
	etu_dv<="000000000";
	etu_f_cnt<="0000";
else
	if(sc_idle or wait_end or wait_start_bit_end)='1' then
		etu_dv<="000000000";
		etu_f_cnt<="0000";
	else
		if(sck'event and sck='1')then
			if (etu_f) ='1' then
				etu_dv<="000000000";
				if(etu_f_cnt_flag='1')then
					etu_f_cnt<="0000";
				else
					etu_f_cnt<=etu_f_cnt+1;
				end if;
			else
				etu_dv<=etu_dv+'1';
			end if;
		end if;
	end if;
end if;
end process etu_divider;


etu_cnt_proc: process(sck,reset, sc_idle, wait_end, get_data_bit_end, wait_start_bit_end, reset_end, send_data_end)
begin
if (reset='0') then
	etu_cnt<=X"0000";
else
	if(sc_idle or wait_end or get_data_bit_end or wait_start_bit_end or reset_end or send_data_end)='1' then
		etu_cnt <= (others=>'0');
	else
		if(sck'event and sck='1')then
--			if (etu_f = '1') and ( cmd(6)='0' or etu_f_cnt=11  ) then
--  the condition: cmd(6)='0' or etu_f_cnt=11 may correct the time difference caused by baud rate
--			if (etu_f = '1') then  -- not need correction?
			if (etu_f = '1') and (etu_f_cnt_flag = '1') then 
				etu_cnt <= etu_cnt + '1';
			end if;
		end if;
	end if;
end if;
end process etu_cnt_proc;


sc_switch_proc: process(sck, reset)
begin 
if (reset='0') then
	sc_sw_cnt<=X"0000";
	sc_switch<='0';
elsif(sck'event and sck='1')then
		if(SC_SW='1')then
			if(sc_sw_cnt=65535)then
				sc_sw_cnt<=sc_sw_cnt;
				sc_switch<='1';
			else
				sc_sw_cnt<=sc_sw_cnt+1;
			end if;
		else
			if(sc_sw_cnt=0)then
				sc_sw_cnt<=sc_sw_cnt;
				sc_switch<='0';
			else
				sc_sw_cnt<=sc_sw_cnt-1;
			end if;
		end if;
end if;

end process sc_switch_proc;			

end SC_INTERFACE_arch;
