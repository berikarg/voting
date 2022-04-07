// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    mapping(string => uint) public votes; // name of cryptocurrency => number of votes
    mapping(address => string) public whoVotedWhat;
    string[] public choices;

    constructor(string[] memory _choices) {
        choices = _choices;
    }

    function reset(string[] memory _choices) external onlyOwner {
        choices = _choices;

    }

    function vote(string memory choice) external onlyOnce validChoice(choice){
        votes[choice] += 1;
        whoVotedWhat[msg.sender] = choice;
    }

    modifier onlyOnce {
        require(areStringsEqual(whoVotedWhat[msg.sender], ""));
        _;
    }

    function areStringsEqual(string memory a, string memory b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        return keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)));
    }

    modifier validChoice(string memory choice) {
        require(isStringInArray(choices, choice));
        _;
    }

    function isStringInArray(string[] memory items, string memory item) internal pure returns (bool) {
        for (uint i = 0; i < items.length; i++) {
            if (areStringsEqual(items[i], item)) {
                return true;
            }
        }
        return false;
    }
}