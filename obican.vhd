-------------------------------------------------------------
-- Ime i prezime:	Milan Milošev
-- Broj indeksa:	PR 11/2023
-- Grupa na vežbama: 1
-- Asistent:	Milica Vujanić
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;

entity lprs1_homework3 is
	port (	
				iCLK	  : in  std_logic;
				iRST    : in  std_logic;
				iRUN    : in  std_logic;
				
				oRED    : out std_logic;
				oYELLOW : out std_logic;
				oGREEN  : out std_logic;
				
				oDIS    : out std_logic_vector(1 downto 0);
				o7SEGM  : out std_logic_vector(6 downto 0)
		);
end entity;

architecture Behavioral of lprs1_homework3 is

type tSTATE is (IDLE, RED,  YELLOW, GREEN, ERROR);
signal sSTATE, sNEXT_STATE : tSTATE;

signal sRED_UNITS_CNT	: std_logic_vector(3 downto 0);
signal sRED_TENS_CNT		: std_logic_vector(3 downto 0);
signal sRED_PREV_CNT		: std_logic_vector(3 downto 0);
signal sRED_TENS_EN		: std_logic;
signal sRED_DONE			: std_logic;

signal sGREEN_UNITS_CNT	: std_logic_vector(3 downto 0);
signal sGREEN_TENS_CNT	: std_logic_vector(3 downto 0);
signal sGREEN_PREV_CNT	: std_logic_vector(3 downto 0);
signal sGREEN_TENS_EN	: std_logic;
signal sGREEN_DONE		: std_logic;

constant cSECOND			: std_logic_vector(23 downto 0):="101101110001101100000000"; --  --000000000000000000001100 101101110001101100000000

signal sRED_TIMER			: std_logic_vector(23 downto 0);
signal sRED_COUNT_EN		: std_logic;

signal sGREEN_TIMER		: std_logic_vector(23 downto 0);
signal sGREEN_COUNT_EN	: std_logic;

signal sYELLOW_CNT		: std_logic_vector(23 downto 0);
signal sYELLOW_TC			: std_logic;

signal sRUN					: std_logic;
signal sCURRENT_STATE	: std_logic;
signal sPREV_STATE		: std_logic;

-- ==================== PRIKAZ NA DISPLAJU ====================
signal sTC					: std_logic;  -- dozvole za displej
signal sDIS_SEL 			: std_logic_vector(1 downto 0);
signal sDIS_CNT 			: std_logic_vector(14 downto 0);
constant cDIS_MAX			: std_logic_vector(14 downto 0) := "111111111111111";

signal sDISPLAY_0			: std_logic_vector(6 downto 0);
signal sDISPLAY_1			: std_logic_vector(6 downto 0);
signal sDISPLAY_2			: std_logic_vector(6 downto 0);
signal sDISPLAY_3			: std_logic_vector(6 downto 0);

-- ukoliko je brojač neaktivan da li se njegova vrijednost šalje na prikaz ili je displej isključen
signal sRED_TENS_DISPLAY	: std_logic_vector(3 downto 0); 
signal sRED_UNITS_DISPLAY	: std_logic_vector(3 downto 0); 
signal sGREEN_TENS_DISPLAY	: std_logic_vector(3 downto 0);
signal sGREEN_UNITS_DISPLAY	: std_logic_vector(3 downto 0);


begin

	-- update stanja
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sSTATE <= IDLE;
		elsif(rising_edge(iCLK)) then
			sSTATE <= sNEXT_STATE;
		end if;
	end process;

	-- registar prev_state cuva ulaz iRUN
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sPREV_STATE <= '0';
		elsif(rising_edge(iCLK)) then
			sPREV_STATE <= iRUN;
		end if;
	end process;
			
	sRUN <= '1' when sPREV_STATE = '0' and iRUN = '1';
	
	sCURRENT_STATE <= '1' when sRUN = '1' else '0';
	
	-- red timer
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sRED_TIMER <= (others => '0');
		elsif(rising_edge(iCLK)) then
			if(sSTATE = RED) then
				if(sRED_TIMER = "0110") then
					sRED_TIMER <= (others => '0');
				else	
					sRED_TIMER <= sRED_TIMER + 1;
				end if;
			else
				sRED_TIMER <= (others => '0');
			end if;
		end if;
	end process;
	
	sRED_COUNT_EN <= '1' when sRED_TIMER = "0110" else '0';
	
	-- brojac red; jedinice
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sRED_UNITS_CNT <= "1001";
		elsif(rising_edge(iCLK)) then
			if(sRED_COUNT_EN = '1') then
				if(sRED_UNITS_CNT = 0) then
					sRED_UNITS_CNT <= "1001";
				else
					sRED_UNITS_CNT <= sRED_UNITS_CNT - 1;
				end if;
			elsif(sRED_DONE = '1') then
				sRED_UNITS_CNT <= "1001";
			end if;
		end if;
	end process;
	
	-- registar prev cnt
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sRED_PREV_CNT <= "1001";
		elsif(rising_edge(iCLK)) then
			sRED_PREV_CNT <= sRED_UNITS_CNT;
		end if;
	end process;
	
	sRED_TENS_EN  <= '1' when sRED_UNITS_CNT = 0 and sRED_TIMER = "0110" else '0';

	-- brojac red desetice
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sRED_TENS_CNT <= "0010";
		elsif(rising_edge(iCLK)) then
			if(sRED_TENS_EN = '1') then
				if(sRED_TENS_CNT = 0) then
					sRED_TENS_CNT <= "0010";
				else
					sRED_TENS_CNT <= sRED_TENS_CNT - 1;
				end if;
			elsif(sRED_DONE = '1') then
				sRED_TENS_CNT <= "0010";
			end if;
		end if;
	end process;
	
	
	sRED_DONE <= '1' when sSTATE = RED and sRED_TENS_CNT = 0 and sRED_PREV_CNT = 0 else '0';
	
	-- yellow timer
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sYELLOW_CNT <= (others => '0');
		elsif(rising_edge(iCLK)) then
			if(sSTATE = YELLOW) then
				if(sYELLOW_CNT = "1001") then
					sYELLOW_CNT <= (others => '0');
				else	
					sYELLOW_CNT <= sYELLOW_CNT + 1;
				end if;
			else
				sYELLOW_CNT <= (others => '0');
			end if;
		end if;
	end process;
	
	sYELLOW_TC <= '1' when sYELLOW_CNT = "1001" else '0';
	
	-- green timer
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sGREEN_TIMER <= (others => '0');
		elsif(rising_edge(iCLK)) then
			if(sSTATE = GREEN) then
				if(sGREEN_TIMER = "0110") then
					sGREEN_TIMER <= (others => '0');
				else	
					sGREEN_TIMER <= sGREEN_TIMER + 1;
				end if;
			else
				sGREEN_TIMER <= (others => '0');
			end if;
		end if;
	end process;

	sGREEN_COUNT_EN <= '1' when sGREEN_TIMER = "0110" else '0';
	
	-- brojac green jedinice
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sGREEN_UNITS_CNT <= "1001";
		elsif(rising_edge(iCLK)) then
			if(sGREEN_COUNT_EN = '1') then
				if(sGREEN_UNITS_CNT = 0) then
					sGREEN_UNITS_CNT <= "1001";
				else
					sGREEN_UNITS_CNT <= sGREEN_UNITS_CNT - 1;
				end if;
			elsif(sGREEN_DONE = '1') then
				sGREEN_UNITS_CNT <= "1001";
			end if;
		end if;
	end process;
	
	-- registar prev cnt green
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sGREEN_PREV_CNT <= "1001";
		elsif(rising_edge(iCLK) and sSTATE = GREEN) then
			sGREEN_PREV_CNT <= sGREEN_UNITS_CNT;
		end if;
	end process;
	
	sGREEN_TENS_EN  <= '1' when sGREEN_UNITS_CNT = 0 and sGREEN_TIMER = "0110" else '0';
	
	
	-- brojac green desetice
	process(iCLK, iRST)
	begin
		if(iRST = '1') then
			sGREEN_TENS_CNT <= "0001";
		elsif(rising_edge(iCLK)) then
			if(sGREEN_TENS_EN = '1') then
				if(sGREEN_TENS_CNT = 0) then
					sGREEN_TENS_CNT <= "0001";
				else
					sGREEN_TENS_CNT <= sGREEN_TENS_CNT - 1;
				end if;
			elsif(sGREEN_DONE = '1') then
				sGREEN_TENS_CNT <= "0001";
			end if;
		end if;
	end process;
	
	sGREEN_DONE <= '1' when sSTATE = GREEN and sGREEN_TENS_CNT = 0 and sGREEN_PREV_CNT = 0 else '0';
	
	-- selekcija stanja
	process(sCURRENT_STATE, sYELLOW_TC, sRED_DONE, sGREEN_DONE, sSTATE)
	begin
		case sSTATE is
			when IDLE =>

			
				if(sCURRENT_STATE = '1') then
					sNEXT_STATE <= RED;
				else
					sNEXT_STATE <= ERROR;
				end if;
			
			when RED =>
			
				if(sRED_DONE = '1') then
					sNEXT_STATE <= YELLOW;
				else
					sNEXT_STATE <= RED;
				end if;
			
			when YELLOW =>

			
				if(sYELLOW_TC = '1') then
					sNEXT_STATE <= GREEN;
				else
					sNEXT_STATE <= YELLOW;
				end if;
			
			when GREEN =>
				
				if(sGREEN_DONE = '1') then	
					sNEXT_STATE <= IDLE;
				else
					sNEXT_STATE <= GREEN;
				end if;
			
			when ERROR => sNEXT_STATE <= IDLE;
			when others => sNEXT_STATE <= IDLE;
		end case;
	end process;
	
	oRED <= '1' when sSTATE = RED else '0';
	oGREEN <= '1' when sSTATE = GREEN else '0';
	oYELLOW<= '1' when sSTATE = YELLOW else '0';
	
	
	sRED_UNITS_DISPLAY <= sRED_UNITS_CNT when sSTATE = RED else "1111";
	sRED_TENS_DISPLAY <= sRED_TENS_CNT when sSTATE = RED else "1111";
	
	sGREEN_UNITS_DISPLAY <= sGREEN_UNITS_CNT when sSTATE = GREEN else "1111";
	sGREEN_TENS_DISPLAY <= sGREEN_TENS_CNT when sSTATE = GREEN else "1111";
	
	process(iCLK, iRST)
	begin
		if(iRST='1') then
			sDIS_CNT<=(others=>'0');
			
		elsif(rising_edge(iCLK)) then
		
			if(sDIS_CNT = cDIS_MAX) then
				sDIS_CNT <= (others => '0');
			else
				sDIS_CNT <= sDIS_CNT + 1;
			end if;
			
		end if;
		
	end process;
	
	sTC <= '1' when sDIS_CNT = cDIS_MAX else '0';

	process (iCLK, iRST)
	begin
		if(iRST = '1') then
			sDIS_SEL <= "11";
		elsif(rising_edge(iCLK)) then
		
			if(sTC = '1') then
			
				if(sDIS_SEL = 0) then
					sDIS_SEL <= "11";
				else	
					sDIS_SEL <= sDIS_SEL - 1;
				end if;	
				
			end if;
			
		end if;
	end process;
	

	oDIS <= sDIS_SEL;
	

			sDISPLAY_0 <= "0000001" when sRED_UNITS_DISPLAY = "0000" else
							  "1001111" when sRED_UNITS_DISPLAY = "0001" else
							  "0010010" when sRED_UNITS_DISPLAY = "0010" else
							  "0000110" when sRED_UNITS_DISPLAY = "0011" else
							  "1001100" when sRED_UNITS_DISPLAY = "0100" else
							  "0100100" when sRED_UNITS_DISPLAY = "0101" else
							  "0100000" when sRED_UNITS_DISPLAY = "0110" else
							  "0001111" when sRED_UNITS_DISPLAY = "0111" else
							  "0000000" when sRED_UNITS_DISPLAY = "1000" else
							  "0000100" when sRED_UNITS_DISPLAY = "1001" else
							  "1111111" when sRED_UNITS_DISPLAY = "1111";
	
			sDISPLAY_1 <= "0000001" when sRED_TENS_CNT = "0000" else
							  "1001111" when sRED_TENS_CNT = "0001" else
							  "0010010" when sRED_TENS_CNT = "0010" else
							  "1111111" when sRED_TENS_CNT = "1111";
							  
			sDISPLAY_2 <= "0000001" when sGREEN_UNITS_CNT = "0000" else
							  "1001111" when sGREEN_UNITS_CNT = "0001" else
							  "0010010" when sGREEN_UNITS_CNT = "0010" else
							  "0000110" when sGREEN_UNITS_CNT = "0011" else
							  "1001100" when sGREEN_UNITS_CNT = "0100" else
							  "0100100" when sGREEN_UNITS_CNT = "0101" else
							  "0100000" when sGREEN_UNITS_CNT = "0110" else
							  "0001111" when sGREEN_UNITS_CNT = "0111" else
							  "0000000" when sGREEN_UNITS_CNT = "1000" else
							  "0000100" when sGREEN_UNITS_CNT = "1001" else
							  "1111111" when sGREEN_UNITS_CNT = "1111";
							  
			sDISPLAY_3 <= "0000001" when sGREEN_TENS_CNT = "0000" else
							  "1001111" when sGREEN_TENS_CNT = "0001" else
							  "0010010" when sGREEN_TENS_CNT = "0010" else
							  "1111111" when sGREEN_TENS_CNT = "1111";

	process(sDIS_SEL) begin
		case sDIS_SEL is 
			when "11" => o7SEGM <= sDISPLAY_0; 
			when "10" => o7SEGM <= sDISPLAY_1; 
			when "01" => o7SEGM <= sDISPLAY_2; 
			when "00" => o7SEGM <= sDISPLAY_3; 
			when others => o7SEGM <= "1111111";
		end case;
end process;
	
	
end Behavioral;