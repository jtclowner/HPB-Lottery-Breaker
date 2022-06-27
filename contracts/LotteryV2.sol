pragma solidity ^0.8.4;
import "./libs/Ownable.sol";
import "./RetrieveRandom.sol";

contract LotteryV2 is Ownable {
    
    address[] public players; /// Players of the current contest round
    uint256 quorum; /// Number of participants to automatically trigger the winner picking
    uint256 feePct; /// Participation fee (in integer percentage)
    uint256 price; /// Ticket price
    RetrieveRandom private randGen;

    
    // Modifier to prevent smart contract interactions. This prevents malicious contracts from
    // calling functions then reverting if the conditions are not favourable 
    modifier onlyEOA {
        require(msg.sender == tx.origin, "EOAs only. No contracts.");
        _;
    }

    constructor(
        uint256 _quorum,
        uint256 _feePct,
        uint256 _price
    ) {
        require(
            _quorum > 1 && _feePct > 0 && _price > 0,
            "Initialization parameters failed."
        );
        quorum = _quorum;
        feePct = _feePct;
        price = _price;

        randGen = new RetrieveRandom();
    }

    function enter() public payable onlyEOA {
        require(msg.value >= price);
        players.push(msg.sender);

        if (players.length >= quorum) pickWinner();
    }

    function pickWinner()
        public
        payable
        RequireOwnershipOrCondition(players.length >= quorum)
    {
        uint256 indexWinner = randGen.getRandomFromRange(0, players.length - 1);

        uint256 winnerBalance = ((address(this).balance) * (100 - feePct)) /
            100;
        payable(players[indexWinner]).transfer(winnerBalance);
        payable(__owner).transfer(address(this).balance);

        // Create a new array of players after running pickWinner
        players = new address[](0);
    }

    function getRoundPlayers() public view returns (address[] memory) {
        return players;
    }

    function getRoundBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function changeConfigs(
        uint256 _quorum,
        uint256 _feePct,
        uint256 _price
    ) public RequireOwnership {
        require(
            players.length == 0,
            "The execution of this function requires that the current round "
            "has no player. In order to force proceed with pickWinner before, "
            "to distribute the current pool."
        );

        quorum = _quorum;
        feePct = _feePct;
        price = _price;
    }
}