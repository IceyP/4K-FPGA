
	   );
   PROCESS(CLKB)
   BEGIN
      IF(RISING_EDGE(CLKB)) THEN
         IF(RSTB='1') THEN
		    CHECKER_ENB_R <= '0';
	     ELSE
		    CHECKER_ENB_R <= CHECK_DATA_TDP(1) AFTER 50 ns;
         END IF;
      END IF;
   END PROCESS;



    BMG_STIM_GEN_INST:ENTITY work.BMG_STIM_GEN
      PORT MAP(
        CLKA => CLKA,
        CLKB => CLKB,
     	TB_RST => RSTA,
        ADDRA  => ADDRA,
        DINA => DINA,
        WEA => WEA,
        WEB => WEB,
        ADDRB => ADDRB,
        DINB => DINB,
        CHECK_DATA => CHECK_DATA_TDP
      );

      PROCESS(CLKA)
      BEGIN
        IF(RISING_EDGE(CLKA)) THEN
		  IF(RESET_SYNC_R3='1') THEN
			STATUS(8) <= '0';
			iter_r2 <= '0';
			iter_r1 <= '0';
			iter_r0 <= '0';
		  ELSE
			STATUS(8) <= iter_r2;
			iter_r2 <= iter_r1;
			iter_r1 <= iter_r0;
			iter_r0 <= STIMULUS_FLOW(8);
	      END IF;
	    END IF;
      END PROCESS;


      PROCESS(CLKA)
      BEGIN
        IF(RISING_EDGE(CLKA)) THEN
		  IF(RESET_SYNC_R3='1') THEN
		      STIMULUS_FLOW <= (OTHERS => '0'); 
           ELSIF(WEA(0)='1') THEN
		      STIMULUS_FLOW <= STIMULUS_FLOW+1;
         END IF;
	    END IF;
      END PROCESS;


      PROCESS(CLKA)
      BEGIN
        IF(RISING_EDGE(CLKA)) THEN
		  IF(RESET_SYNC_R3='1') THEN
            WEA_R  <= (OTHERS=>'0') AFTER 50 ns;
            DINA_R <= (OTHERS=>'0') AFTER 50 ns;
  
            WEB_R <= (OTHERS=>'0') AFTER 50 ns;
            DINB_R <= (OTHERS=>'0') AFTER 50 ns;
          

           ELSE
            WEA_R  <= WEA AFTER 50 ns;
            DINA_R <= DINA AFTER 50 ns;
  
            WEB_R <= WEB AFTER 50 ns;
            DINB_R <= DINB AFTER 50 ns;

         END IF;
	    END IF;
      END PROCESS;


      PROCESS(CLKA)
      BEGIN
        IF(RISING_EDGE(CLKA)) THEN
		  IF(RESET_SYNC_R3='1') THEN
            ADDRA_R <= (OTHERS=> '0') AFTER 50 ns;
            ADDRB_R <= (OTHERS=> '0') AFTER 50 ns;
          ELSE
            ADDRA_R <= ADDRA AFTER 50 ns;
            ADDRB_R <= ADDRB AFTER 50 ns;
          END IF;
	    END IF;
      END PROCESS;


    BMG_PORT: tdpram_w8d32_exdes PORT MAP ( 
      --Port A
      WEA        => WEA_R,
      ADDRA      => ADDRA_R,
      DINA       => DINA_R,
      DOUTA      => DOUTA,
      CLKA       => CLKA,
      --Port B
  
      WEB        => WEB_R,
      ADDRB      => ADDRB_R,
  
      DINB       => DINB_R,
      DOUTB      => DOUTB,
      CLKB       => CLKB

    );
END ARCHITECTURE;
