// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

/**
 * title A sample Raffle Contract
 * @author Muhammad Abdul Rehman (following cyfrin foundry 101 - Patrick Collins)
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFV2
 */

contract Raffle {
    error Raffle__NotEnoughEthSent();

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "You must pay the entrance fee to enter the raffle");
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }

    // 1. Get a random number
    // 2. Pick a winner
    function pickWinner() external view {
        //check to see if enough time has

        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert();
        }
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
