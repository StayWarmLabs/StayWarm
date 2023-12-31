import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  systems: {
    BurnSystem: {
      name: "Burn",
      openAccess: true,
    },
    GovernSystem: {
      name: "Govern",
      openAccess: true,
    },
    JoinSystem: {
      name: "Join",
      openAccess: true,
    },
    SettleGameSystem: {
      name: "SettleGame",
      openAccess: true,
    },
    SettleRoundSystem: {
      name: "SettleRound",
      openAccess: true,
    },
  },
  tables: {
    Config: {
      keySchema: {},
      valueSchema: {
        gameStartWaitingTime: "uint32",
        roundTimeLength: "uint32",
        voteTimeLength: "uint32",
        burnAmountPerRound: "uint256",
        joinFee: "uint256",
        initialBalance: "uint256",
      },
    },
    Game: {
      keySchema: {},
      valueSchema: {
        startTime: "uint32",
        ethTotalAmount: "uint256",
        currentRound: "uint32",
        executeFuncSig: "bytes32",
        executeArgs: "bytes32",
        allPlayers: "address[]",
      },
    },
    //
    Player: {
      keySchema: { key: "address" },
      valueSchema: {
        status: "PlayerStatus",
        lastCheckedTime: "uint32",
        ftBalance: "uint256",
        burnedAmount: "uint256",
      },
    },
    PlayerVote: {
      keySchema: { key: "bytes32" }, // address + proposal id
      valueSchema: {
        supportVote: "uint256",
        rejectVote: "uint256",
      },
    },
    Proposal: {
      keySchema: { id: "uint96" },
      valueSchema: {
        proposer: "address",
        startTime: "uint32",
        support: "uint32", // cannot use “for”, reserved keyword
        reject: "uint32",
        executed: "bool",
        implAddr: "address",
        systemName: "string",
        uri: "string", // ipfs://Qmxxx
      },
    },
  },
  enums: {
    PlayerStatus: ["UNINITIATED", "ALIVE", "DEAD"],
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
  ],
});
