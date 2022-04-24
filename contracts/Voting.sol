// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    mapping(string => uint) public votes; // choice => number of votes
    address[] public voters;
    string[] public choices;

    constructor(string[] memory _choices) {
        choices = _choices;
    }

    function getChoices() external view returns (string[] memory){
        return choices;
    }

    function reset(string[] memory _choices) external onlyOwner {
        choices = _choices;
        emptyVoters();
        emptyVotes();
    }

    function emptyVoters() private {
        for (uint i; i < voters.length; i++) {
            voters.pop();
        }
    }

    function emptyVotes() private {
        for (uint i; i < choices.length; i++) {
            votes[choices[i]] = 0;
        }
    }

    function vote(string memory choice) external onlyOnce validChoice(choice){
        votes[choice] += 1;
        voters.push(msg.sender);
    }

    modifier onlyOnce {
        require(!isAddressInArray(voters, msg.sender));
        _;
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

    function areStringsEqual(string memory a, string memory b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        return keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)));
    }

    function isAddressInArray(address[] memory addrs, address addr) internal pure returns (bool) {
        for (uint i = 0; i < addrs.length; i++) {
            if (addrs[i] == addr) {
                return true;
            }
        }
        return false;
    }
}