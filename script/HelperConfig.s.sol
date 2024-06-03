// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCooridinator;
        bytes32 gaslane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    event HelperConfig__CreatedMockVRFCoordinator(address vrfCoordinator);
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCooridinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gaslane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 11771,
                callbackGasLimit: 500000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCooridinator != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();

        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 linkFee = 1e9; // 1 gwei

        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            linkFee
        );

        LinkToken linkToken = new LinkToken();

        vm.stopBroadcast();

        emit HelperConfig__CreatedMockVRFCoordinator(
            address(vrfCoordinatorMock)
        );

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCooridinator: address(vrfCoordinatorMock),
                gaslane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000,
                link: address(linkToken),
                deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
            });
    }
}
