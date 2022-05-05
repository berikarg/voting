const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Voting contract", function () {
  let owner, voter1, voter2, voter3, voter4;
  beforeEach(async function () {
    [owner, voter1, voter2, voter3, voter4] = await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting", owner);

    this.presidentVoting = await Voting.deploy(['Biden', 'Trump', 'Obama']);
  });

  describe("VotingTest", () => {
    it("Deployment should assign the choices", async function () {
      const choices = await this.presidentVoting.getChoices();

      expect(choices.length).to.equal(3);
      expect(choices[0]).to.equal('Biden');
      expect(choices[1]).to.equal('Trump');
      expect(choices[2]).to.equal('Obama');
    });

    it("Should set the deployer account as the owner at deployment", async function () {
      expect(await this.presidentVoting.owner()).to.eq(owner.address);
    });

    it("A proper vote should be counted", async function () {
      const voter1Choice = 'Biden';
      await this.presidentVoting.connect(voter1).vote(voter1Choice);
      let voteCount = await this.presidentVoting.getVoteCount(voter1Choice);
      expect(voteCount).to.eq(1);
    });
  });
});