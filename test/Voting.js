const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Voting contract", function () {
  it("Deployment should assign the choices", async function () {
    const [owner] = await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting", owner);

    const deployChoices = ['Biden', 'Trump', 'Obama'];
    const presidentVoting = await Voting.deploy(deployChoices);

    const choices = await presidentVoting.getChoices();

    expect(choices.length).to.equal(deployChoices.length);
    expect(choices[0]).to.equal(deployChoices[0]);
    expect(choices[1]).to.equal(deployChoices[1]);
    expect(choices[2]).to.equal(deployChoices[2]);
  });
});