// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract CreateSubscription is Script {
    function createSubsciptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCooridinator, , , , ) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCooridinator);
    }

    function createSubscription(
        address vrfCooridinator
    ) public returns (uint64) {
        vm.startBroadcast();
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
            address link
        ) = helperConfig.activeNetworkConfig();
        console.log("Before Funding subscription with id: ", subscriptionId);
        console.log("Using vrfCooridinator ", vrfCooridinator);
        console.log("On Chain Id ", block.chainid);
        fundSubscription(vrfCooridinator, subscriptionId, link);
    }

    function fundSubscription(
        address vrfCooridinator,
        uint64 subscriptionId,
        address link
    ) public {
        console.log("Funding subscription with id: ", subscriptionId);
        console.log("Using vrfCooridinator ", vrfCooridinator);
        console.log("On Chain Id ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCooridinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
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
