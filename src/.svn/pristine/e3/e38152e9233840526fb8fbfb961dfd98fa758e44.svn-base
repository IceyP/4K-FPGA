library ieee;
use ieee.std_logic_1164.all;
entity shifter is port
		(
		datac : in std_logic_vector(1 to 28);
		datad : in std_logic_vector(1 to 28);
		shift : in std_logic_vector(1 to 3);
		clk : in std_logic;
		datac_out : out std_logic_vector(1 to 28);
		datad_out : out std_logic_vector(1 to 28)
		);
end shifter;
architecture behaviour of shifter is
	signal datac_out_mem, datad_out_mem : std_logic_vector(1 to 28);
begin
	process(shift,clk)
	begin
		if (clk'event and clk = '1') then
			case shift is
				when "000" =>
				  -- pas de shift, nouvelle cl¨¦
					datac_out_mem<=datac;
					datad_out_mem<=datad;
				when "100" =>
					-- pas de shift, nouvelle cl¨¦
					datac_out_mem<=datac;
					datad_out_mem<=datad;
				when "001" =>
					-- shifter 1 fois, pas de nouvelle cl¨¦
					datac_out_mem<=To_StdLogicVector(to_bitvector(datac_out_mem) rol 1);
					datad_out_mem<=To_StdLogicVector(to_bitvector(datad_out_mem) rol 1);
				when "101" =>
					-- shifter 1 fois, pas de nouvelle cl¨¦
					datac_out_mem<=To_StdLogicVector(to_bitvector(datac_out_mem) ror 1);
					datad_out_mem<=To_StdLogicVector(to_bitvector(datad_out_mem) ror 1);
				when "010" =>
					-- shifter 2 fois, pas de nouvelle cl¨¦
					datac_out_mem<=To_StdLogicVector(to_bitvector(datac_out_mem) rol 2);
					datad_out_mem<=To_StdLogicVector(to_bitvector(datad_out_mem) rol 2);
				when "110" =>
					-- shifter 2 fois, pas de nouvelle cl¨¦
					datac_out_mem<=To_StdLogicVector(to_bitvector(datac_out_mem) ror 2);
					datad_out_mem<=To_StdLogicVector(to_bitvector(datad_out_mem) ror 2);
				when others =>
				-- erreur ou pas de shift, pas de nouvelle cl¨¦
			end case;
		end if;
	end process;
	datac_out<=datac_out_mem;
	datad_out<=datad_out_mem;
end behaviour;
