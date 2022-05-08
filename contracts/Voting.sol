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

    function getVoteCount(string memory choice) external view validChoice(choice) returns (uint){
        return votes[choice];
    }

    function getChoices() external view returns (string[] memory) {
        return choices;
    }

    function getVoters() external view returns (address[] memory) {
        return voters;
    }

    function reset(string[] memory _choices) external onlyOwner {
        emptyVoters();
        emptyVotes();
        choices = _choices;
    }

    function emptyVoters() private {
        uint votersLength = voters.length;
        for (uint i; i < votersLength; i++) {
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
        require(!isAddressInArray(voters, msg.sender), "only one vote per address is allowed");
        _;
    }

    modifier validChoice(string memory choice) {
        require(isStringInArray(choices, choice), "invalid choice");
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