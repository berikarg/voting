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

    it("A valid vote should be counted", async function () {
      const voter1Choice = 'Biden';
      await this.presidentVoting.connect(voter1).vote(voter1Choice);
      let voteCount = await this.presidentVoting.getVoteCount(voter1Choice);
      expect(voteCount).to.eq(1);
    });

    it("An invalid vote should NOT be counted", async function () {
      const invalidChoice = 'Berik';
      await expect(this.presidentVoting.connect(voter1).vote(invalidChoice)).to.be.revertedWith("invalid choice");
    });

    it("One voter should NOT be able to vote more than once", async function () {
      const voter1Choice = 'Biden';
      await this.presidentVoting.connect(voter1).vote(voter1Choice);
      await expect(this.presidentVoting.connect(voter1).vote(voter1Choice)).to.be.revertedWith("only one vote per address is allowed");
    });

    it("Voters should be recorded", async function () {
      const voter1Choice = 'Biden';
      const voter2Choice = 'Obama';
      await this.presidentVoting.connect(voter1).vote(voter1Choice);
      await this.presidentVoting.connect(voter2).vote(voter2Choice);
      let voters = await this.presidentVoting.getVoters();
      expect(voters.length).to.equal(2);
      expect(voters[0]).to.equal(voter1.address);
      expect(voters[1]).to.equal(voter2.address);
    });

    it("Voting should be resetable by owner", async function () {
      await this.presidentVoting.connect(owner).reset(['new', 'choices']);
      const choices = await this.presidentVoting.getChoices();

      expect(choices.length).to.equal(2);
      expect(choices[0]).to.equal('new');
      expect(choices[1]).to.equal('choices');
    });

    it("Reset should delete old choices", async function () {
      await this.presidentVoting.connect(owner).reset(['new', 'choices']);
      await expect(this.presidentVoting.getVoteCount('Obama')).to.be.revertedWith("invalid choice");
    });

    it("Reset should empty voters list", async function () {
      await this.presidentVoting.connect(voter1).vote('Biden');
      await this.presidentVoting.connect(voter2).vote('Obama');
      let voters = await this.presidentVoting.getVoters();
      expect(voters.length).to.equal(2);

      
      await this.presidentVoting.connect(owner).reset(['new', 'choices']);
      voters = await this.presidentVoting.getVoters();
      expect(voters.length).to.equal(0);
    });
  });
});