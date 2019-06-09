pragma solidity >0.4.99;
contract Betting {
   address payable public owner;
   uint256 public minimumBet;
   uint256 public totalBetsOne;
   uint256 public totalBetsTwo;
   address payable[] public players;
   struct Player {
      uint256 amountBet;
      uint16 teamSelected;
    }
// adresa igraca
   mapping(address => Player) public playerInfo;
   function() external payable {}
   
  constructor() public {
      owner = msg.sender;
      minimumBet = 100000000000000;
    }
    
function checkPlayerExists(address payable player) public view returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
    }
function bet(uint8 _teamSelected) public payable {
      //Prvi require se koristi za provjeru postoji li igrač već prisutan
      require(!checkPlayerExists(msg.sender));
      //Drugi se koristi kako bi se vidjelo je li vrijednost koju je dao igrač viša od minimalne vrijednosti
      require(msg.value >= minimumBet);
 //Postavili smo podatke o igraču: iznos uloga i odabrani tim
      playerInfo[msg.sender].amountBet = msg.value;
      playerInfo[msg.sender].teamSelected = _teamSelected;
//dodamo adresu igrača u polje igrača
      players.push(msg.sender);
//na kraju povećavamo uloge momčadi odabrane s igračkom okladom
      if ( _teamSelected == 1){
          totalBetsOne += msg.value;
      }
      else{
          totalBetsTwo += msg.value;
      }
    }

    function distributePrizes(uint16 teamWinner) public {
    //Moramo stvoriti privremeno polje memorije s fiksnom veličinom npr. 1000
      address payable[1000] memory winners;
      uint256 count = 0; // Zbroj dobitnika
      uint256 LoserBet = 0; //vrijednost svih oklada gubitnika
      uint256 WinnerBet = 0; //vrijednost svih oklada dobitnika
      address add;
      uint256 bet1;
      address payable playerAddress;
      //Prolazimo kroz polje igrača kako bismo provjerili tko je odabrao pobjednički tim
      for(uint256 i = 0; i < players.length; i++){
         playerAddress = players[i];
        // Ako je igrač odabrao pobjednički tim, njegovu adresu dodajemo nizu dobitnika
         if(playerInfo[playerAddress].teamSelected == teamWinner){
            winners[count] = playerAddress;
            count++;
         }
      }
    // Definiramo koji je iznos oklada gubitnički,a koji je pobjednički
      if ( teamWinner == 1){
         LoserBet = totalBetsTwo;
         WinnerBet = totalBetsOne;
      }
      else{
          LoserBet = totalBetsOne;
          WinnerBet = totalBetsTwo;
      }
    //Iteriramo kroz polje pobjednika
      for(uint256 j = 0; j < count; j++){
          //provjera da adresa nije prazna
         if(winners[j] != address(0))
            add = winners[j];
            bet1 = playerInfo[add].amountBet;
            // transfer novca pobjedniku
            winners[j].transfer(    (bet1*(10000+(LoserBet*10000/WinnerBet)))/10000 );
      }
      

      LoserBet = 0;
      WinnerBet = 0;
      totalBetsOne = 0;
      totalBetsTwo = 0;
    }
}