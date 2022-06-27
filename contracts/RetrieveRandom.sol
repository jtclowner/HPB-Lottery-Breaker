import "hardhat/console.sol";
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract HRNG {
    function getRandom() public view virtual returns (bytes32);

    function getRandomFromRange(uint256 _min, uint256 _max)
        public
        view
        virtual
        returns (bytes32);
}

contract RetrieveRandom {
    address hrngAddr = 0xc8bcd7414e744cfF7317Ee68EbA3fFA836b23F3f;
    HRNG hrng;

    constructor(/*address hrngaddr*/) {
        //hrngAddr = hrngaddr;
        hrng = HRNG(hrngAddr);
    }

    function getRandom() public view returns (uint256) {
        uint256 random;

        if (block.chainid == 269) // 269 is HPB's
            random = uint256(hrng.getRandom());
        else
            random = uint256(blockhash(block.number-1));
        return random;
    }

    function getRandomFromRange(uint256 _min, uint256 _max)
        public
        view
        returns (uint256)
    {
        uint256 random;
        if (block.chainid == 269) // 269 is HPB's
            random = uint256(hrng.getRandomFromRange(_min, _max));
        else random = getRandom() % (_max + 1);
        console.log(random);    
            
        return random;
    }
}
