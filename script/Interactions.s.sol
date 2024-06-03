// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubsciptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCooridinator,
            ,
            ,
            ,
            ,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCooridinator, deployerKey);
    }

    function createSubscription(
        address vrfCooridinator,
        uint256 deployerKey
    ) public returns (uint64) {
        vm.startBroadcast(deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCooridinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription id is: ", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint64) {
        return createSubsciptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 1 ether;

    function fundSubsciptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCooridinator,
            ,
            uint64 subscriptionId,
            ,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        console.log("Before Funding subscription with id: ", subscriptionId);
        console.log("Using vrfCooridinator ", vrfCooridinator);
        console.log("On Chain Id ", block.chainid);
        fundSubscription(vrfCooridinator, subscriptionId, link, deployerKey);
    }

    function fundSubscription(
        address vrfCooridinator,
        uint64 subscriptionId,
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription with id: ", subscriptionId);
        console.log("Using vrfCooridinator ", vrfCooridinator);
        console.log("On Chain Id ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCooridinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCooridinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        return fundSubsciptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCooridinator,
            ,
            uint64 subscriptionId,
            ,
            ,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(raffle, vrfCooridinator, subscriptionId, deployerKey);
    }

    function addConsumer(
        address raffle,
        address vrfCooridinator,
        uint64 subscriptionId,
        uint256 deployerKey
    ) public {
        console.log("Adding Consumer: ", raffle);
        console.log("Using vrfCooridinator ", vrfCooridinator);
        console.log("On Chain Id ", block.chainid);

        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCooridinator).addConsumer(
            subscriptionId,
            raffle
        );
        vm.stopBroadcast();
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}
