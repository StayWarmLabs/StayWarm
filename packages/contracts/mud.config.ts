import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    Config: {
      keySchema: {},
      valueSchema: {
        gameStartWaitingTime: "uint32",
        roundTimeLength: "uint32",
        voteTimeLength: "uint32",
        burnAmountPerRound: "uint256",
      },
    },
    Game: {
      keySchema: {},
      valueSchema: {
        startTime: "uint32",
        ethTotalAmount: "uint256",
        currentRound: "uint32",
        ExecuteFuncSig: "bytes32",
        ExecuteArgs: "bytes32",
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
    Proposal: {
      keySchema: { id: "bytes32" },
      valueSchema: {
        proposer: "address",
        startTime: "uint32",
        for: "uint32",
        against: "uint32",
        executed: "bool",
        register: "bytes32[]",
        unregister: "bytes32[]",
        uri: "string", // ipfs://Qmxxx
      },
    },
    Register: {
      keySchema: { id: "bytes32" },
      valueSchema: {
        resourcesId: "bytes32",
        implAddr: "address",
      },
    },
    Unregister: {
      keySchema: { id: "bytes32" },
      valueSchema: {
        resourcesId: "bytes32",
      },
    },
  },
  enums: {
    PlayerStatus: ["UNINITIATED", "ALIVE", "DEAD"],
  },
});
