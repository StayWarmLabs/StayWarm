// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/console2.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Player, Proposal, ProposalData, Config, PlayerVote} from "src/codegen/index.sol";
import {PlayerStatus} from "src/codegen/common.sol";
import {getUniqueEntity} from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";
import {ResourceId} from "@latticexyz/store/src/ResourceId.sol";
import {RESOURCE_TABLE, RESOURCE_SYSTEM} from "@latticexyz/world/src/worldResourceTypes.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";

import {WorldContextConsumer} from "@latticexyz/world/src/WorldContext.sol";

import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

import {RegisterSystemArgs} from "src/Types.sol";

import {ResourceAccess} from "@latticexyz/world/src/codegen/tables/ResourceAccess.sol";
import {SystemRegistry} from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import {Systems} from "@latticexyz/world/src/codegen/tables/Systems.sol";
import {NamespaceOwner} from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import {ResourceIds} from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import {ROOT_NAMESPACE_ID, ROOT_NAME} from "@latticexyz/world/src/constants.sol";
import {RESOURCE_NAMESPACE, RESOURCE_SYSTEM} from "@latticexyz/world/src/worldResourceTypes.sol";
import {requireInterface} from "@latticexyz/world/src/requireInterface.sol";
import {WorldContextConsumer, WORLD_CONTEXT_CONSUMER_INTERFACE_ID} from "@latticexyz/world/src/WorldContext.sol";
import {IWorldErrors} from "@latticexyz/world/src/IWorldErrors.sol";
import {ResourceId, ResourceIdInstance} from "@latticexyz/store/src/ResourceId.sol";
import {WorldResourceIdLib, WorldResourceIdInstance} from "@latticexyz/world/src/WorldResourceId.sol";

contract GovernSystem is System, IWorldErrors {
    using ResourceIdInstance for ResourceId;
    using WorldResourceIdInstance for ResourceId;

    function makeProposal(address implAddr, string memory systemName, string calldata uri)
        public
        returns (uint96 proposalId)
    {        
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        address player = _msgSender();
        // must be token holder
        require(Player.getFtBalance(player) > 0, "GovernSystem: Not FT Holder");
        // must be alive
        require(Player.getStatus(player) == PlayerStatus.ALIVE, "GovernSystem(Proposal): Player is DEAD");

        proposalId = uint96(uint256(getUniqueEntity()));

        Proposal.set(proposalId, player, uint32(block.timestamp), 0, 0, false, implAddr, systemName, uri);
    }

    function vote(uint96 proposalId, uint256 votingPower, bool support) public {
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        address player = _msgSender();
        uint256 votingLength = Config.getVoteTimeLength();
        ProposalData memory proposalDetail = Proposal.get(proposalId);

        // check whether player is alive
        require(Player.getStatus(player) == PlayerStatus.ALIVE, "GovernSystem(Voting): Player is DEAD");

        // check whether time is in voting period
        require(block.timestamp < proposalDetail.startTime + votingLength, "GovernSystem: Voting end");

        bytes32 playerVoteId = encodePlayerVoteId(player, proposalId);

        // record result
        if (support) {
            // get previous vote
            uint256 preVote = PlayerVote.getSupportVote(playerVoteId);

            // charge token or refund token
            Player.setFtBalance(player, Player.getFtBalance(player) + preVote * preVote - votingPower * votingPower);

            Proposal.setSupport(proposalId, uint32(proposalDetail.support + votingPower - preVote));
        } else {
            // get previous vote
            uint256 preVote = PlayerVote.getRejectVote(playerVoteId);

            // charge token or refund token
            Player.setFtBalance(player, Player.getFtBalance(player) + preVote * preVote - votingPower * votingPower);

            Proposal.setReject(proposalId, uint32(proposalDetail.reject + votingPower - preVote));
        }
    }

    /**
     * @notice for now, only support upgrade system
     */
    function executeProposal(uint96 proposalId) public {
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        // check whether the proposal can be executed
        address player = _msgSender();
        uint256 votingLength = Config.getVoteTimeLength();
        ProposalData memory proposalDetail = Proposal.get(proposalId);

        // check whether voting is end
        require(block.timestamp > proposalDetail.startTime + votingLength, "GovernSystem: Voting not end");

        // check whether support is larger than reject
        require(proposalDetail.support > proposalDetail.reject, "GovernSystem: proposal not pass");

        // get system resource id
        ResourceId systemId = ResourceId.wrap(
            bytes32(abi.encodePacked(RESOURCE_SYSTEM, bytes14(0), bytes16(abi.encodePacked(proposalDetail.systemName))))
        );

        registerSystem(systemId, WorldContextConsumer(proposalDetail.implAddr), true);
    }

    /**
     * @notice modified from origin register but bypass owner check
     * @notice Registers a system
     * @dev Registers or upgrades a system at the given ID
     * If the namespace doesn't exist yet, it is registered.
     * The system is granted access to its namespace, so it can write to any
     * table in the same namespace.
     * If publicAccess is true, no access control check is performed for calling the system.
     * This function doesn't check whether a system already exists at the given selector,
     * making it possible to upgrade systems.
     * @param systemId The unique identifier for the system
     * @param system The system being registered
     * @param publicAccess Flag indicating if access control check is bypassed
     */
    function registerSystem(ResourceId systemId, WorldContextConsumer system, bool publicAccess) internal virtual {
        // Require the provided system ID to have type RESOURCE_SYSTEM
        if (systemId.getType() != RESOURCE_SYSTEM) {
            revert World_InvalidResourceType(RESOURCE_SYSTEM, systemId, systemId.toString());
        }

        // Require the provided address to implement the WorldContextConsumer interface
        requireInterface(address(system), WORLD_CONTEXT_CONSUMER_INTERFACE_ID);

        // Require the name to not be the namespace's root name
        if (systemId.getName() == ROOT_NAME) revert World_InvalidResourceId(systemId, systemId.toString());

        // Require this system to not be registered at a different system ID yet
        ResourceId existingSystemId = SystemRegistry._get(address(system));
        if (
            ResourceId.unwrap(existingSystemId) != 0
                && ResourceId.unwrap(existingSystemId) != ResourceId.unwrap(systemId)
        ) {
            revert World_SystemAlreadyExists(address(system));
        }

        // If the namespace doesn't exist yet, register it
        ResourceId namespaceId = systemId.getNamespaceId();
        if (!ResourceIds._getExists(namespaceId)) {
            registerNamespace(namespaceId);
        } else {
            // otherwise require caller to own the namespace
            // AccessControl.requireOwner(namespaceId, _msgSender());
        }

        // Check if a system already exists at this system ID
        address existingSystem = Systems._getSystem(systemId);

        // If there is an existing system with this system ID, remove it
        if (existingSystem != address(0)) {
            // Remove the existing system from the system registry
            SystemRegistry._deleteRecord(existingSystem);

            // Remove the existing system's access to its namespace
            ResourceAccess._deleteRecord(namespaceId, existingSystem);
        } else {
            // Otherwise, this is a new system, so register its resource ID
            ResourceIds._setExists(systemId, true);
        }

        // Systems = mapping from system ID to system address and public access flag
        Systems._set(systemId, address(system), publicAccess);

        // SystemRegistry = mapping from system address to system ID
        SystemRegistry._set(address(system), systemId);

        // Grant the system access to its namespace
        ResourceAccess._set(namespaceId, address(system), true);
    }

    /**
     * @notice Registers a new namespace
     * @dev Creates a new namespace resource with the given ID
     * @param namespaceId The unique identifier for the new namespace
     */
    function registerNamespace(ResourceId namespaceId) internal virtual {
        // Require the provided namespace ID to have type RESOURCE_NAMESPACE
        if (namespaceId.getType() != RESOURCE_NAMESPACE) {
            revert World_InvalidResourceType(RESOURCE_NAMESPACE, namespaceId, namespaceId.toString());
        }

        // Require namespace to not exist yet
        if (ResourceIds._getExists(namespaceId)) {
            revert World_ResourceAlreadyExists(namespaceId, namespaceId.toString());
        }

        // Register namespace resource ID
        ResourceIds._setExists(namespaceId, true);

        // Register caller as the namespace owner
        NamespaceOwner._set(namespaceId, _msgSender());

        // Give caller access to the new namespace
        ResourceAccess._set(namespaceId, _msgSender(), true);
    }

    function encodePlayerVoteId(address player, uint96 proposalId) public view returns (bytes32 id) {
        bytes memory b = abi.encodePacked(player, proposalId);

        assembly {
            id := mload(add(b, 32))
        }
    }
}
