# HPB-Lottery-Breaker

This project demonstrates the vulnerabilities related to improper handling of randomness. Credit to [@pvrego](https://github.com/pvrego) for the original contract, deployed on High Performance Blockchain to leverage its proprietary per-block randomness.

## Attack vector 1 - Lottery.sol
Using an auxiliary contract ``AttackOne.sol``, we are able to call the underlying contract's ``enter`` method, and revert if the outcome is not to our liking

To perform the attack:
- Create a local dev chain using ganache, or by running ``npx hardhat node`` in a terminal window
- Run the attack script - ``npx hardhat run ./scripts/attackOne.js --network localhost``

To resist this attack vector, ``LotteryV2.sol`` adds an ``OnlyEOA`` modifier to prevent malicious smart contracts from calling the ``enter`` function. However, this is still not perfect:

## Attack vector 2 - LotteryV2.sol
Performed by a node/miner/block producer, this attack relies on this entity having prior knowledge of the random outcome at the top of the block. In the case of HPB, a block producer could see the ``block.random`` produced at the top of the block, and use this information to decide whether or not to join the lottery.

To perform the attack:
- Create a local dev chain using ganache, or by running ``npx hardhat node`` in a terminal window
- Run the attack script - ``npx hardhat run ./scripts/attackTwo.js --network localhost``

## SafeLottery.sol + SafeRetrieveRandom.sol
These contracts illustrate a hypothetical solution (not currently possible due to limitations with the HPB blockchain), whereby a future block is chosen as the source of randomness, and is resolved later via the ``revealWinner`` function. This has the advantage of deterministic randomness (the random result cannot be changed after a user buys a lottery ticket), yet the outcome cannot be determined by malicious nodes or other attackers at the time a commitment is made.

In this model, we require 2 blocks to have passed between the final ticket sale, and any subsequent call to resolve the randomness. This has the effect of requiring malicious nodes to be able to mine several blocks in a row to be able to undo a commitment if it turns out to be a loss after ``revealWinner`` is called.

***To implement this model in a 100% secure and decentralized way, HPB must allow the ``block.random`` method to accept a ``blockNumber`` as a parameter. Currently it is only possible to retrieve the current block number, and it is not possible to retrieve random outputs from previous blocks (as you would on Ethereum or other chains, who cache the latest 256 block hashes)***
