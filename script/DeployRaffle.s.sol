// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCooridinator,
            bytes32 gaslane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubcription = new CreateSubscription();
            subscriptionId = createSubcription.createSubscription(
                vrfCooridinator,
                deployerKey
            );

            //Fund it

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCooridinator,
                subscriptionId,
                link,
                deployerKey
            );
        }
        vm.startBroadcast(deployerKey);
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCooridinator,
            gaslane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCooridinator,
            subscriptionId,
            deployerKey
        );
        return (raffle, helperConfig);
    }
}
