library ieee;
use ieee.std_logic_1164.all;

entity lprs1_homework3_tb is
end entity;
 
architecture Test of lprs1_homework3_tb is
	--Inputs
   signal sCLK : std_logic := '0';
   signal sRST : std_logic := '0';
   signal sRUN : std_logic := '1';
  
 	--Outputs
   signal sRED    : std_logic;
   signal sYELLOW : std_logic;
	signal sGREEN  : std_logic;
	
	signal sDIS  : std_logic_vector(1 downto 0);
	signal s7SEGM : std_logic_vector(6 downto 0);
	
	constant iCLK_PERIOD : time := 10 ns;
	
   component lprs1_homework3 is  
		port (
			iCLK 		: in  std_logic;
			iRST 		: in  std_logic;
			iRUN     : in  std_logic;
			
			oRED    : out std_logic;
			oYELLOW : out std_logic;
			oGREEN  : out std_logic;
				
			oDIS  : out std_logic_vector(1 downto 0);
			o7SEGM : out std_logic_vector(6 downto 0)
		);
   end component;

begin

   uut: lprs1_homework3 port map (
         iCLK => sCLK,
         iRST => sRST,
         iRUN => sRUN,
         oRED => sRED,

         oYELLOW => sYELLOW,
         oGREEN => sGREEN,
			oDIS => sDIS,
			o7SEGM => s7SEGM
        );
	
	--takt process
	clk_proc : process
	begin
		sCLK <= '1';
		wait for iCLK_PERIOD / 2;
		sCLK <= '0';
		wait for iCLK_PERIOD / 2;
	end process;
	
   stimulus : process
   begin
	
		sRST <= '1';
		wait for iCLK_PERIOD;
		sRST <= '0';
		
		sRUN <= '1';
		wait for 350 * iCLK_PERIOD; -- 350 jer imamo 6 perioda za svaki sekund RED_TIMER
		sRUN <= '0';								-- 9 perioda za YELLLOW_TIMER; i 6 perioda za svaki sekund GREEN_TIMER
		
		
		sRST <= '1';
		wait for iCLK_PERIOD;
		sRST <= '0';
		
		sRUN <= '1';
		wait for 350 * iCLK_PERIOD; --drugi put
		sRUN <= '0';								
		
	wait;
   end process;
end architecture;