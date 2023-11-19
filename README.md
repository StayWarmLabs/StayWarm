# StayWarm

## Stay warm?
"Stay Warm" is an innovative fully on-chain metagame where players manage tokens to survive and influence the game.
Every period in the game, a player has to burn some tokens to stay in the game for the next round.
But, rules can change and be voted in, changing the dynamic ruleset and challenging players to pay attention, or they might not survive!

After an initial ETH deposit, they strategize to be the last one standing, shaping the rules.
The last remaining player wins all participants' deposits.

### Technologies Used
This project uses the following tools (we mentioned partner technologies later):

### Backend
- `MUD`: Developed by lattice for autonomous worlds and fully on-chain gaming, this framework enables the use of the Entity Component System (ECS) architecture. ECS architecture allows for the independent implementation of each system, facilitating secure and flexible modifications and upgrades.
- `@latticexyz`: Essential for harnessing the capabilities of the MUD framework.
- `foundry/forge`: Employed for the efficient building, testing, and deployment of smart contracts, ensuring ease of use and precision.

## Frontend
- `Sveltekit`: For the frontend, we chose Svelte(kit) for its innovative approach to UI development. Its compile-time framework converts components into efficient code that directly updates the DOM, leading to faster load times and a responsive interface. The reactive nature of Svelte simplifies state management, allowing for a seamless integration with our backend systems.
- `@latticexyz` : We also use this package in frontend to connect with backend.
- `@web3-storage` : We use this for storing proposal contents.

## Partner Technologies
- MaskNetwork : 
- Push Protocol : send notification if there is a new proposal.
- Metamask : using snap with push protocol.
- WalletConnect : connect wallet.
- IPFS/Filecoin : use web3-storage to store the content of porposal.

## Chains
- Ethereum
- Base
- Scroll
- polygon

## Notable Implementations

Governing method to upgrade world in MUD framework.

Challenges and Solutions:

The original access control of mud is complex and can't be used for voting and upgrading directly. We implement the voting and upgrading by ousrselves.
The frontend framework solutions we created to adapt Sveltekit to MUD and a solution for the wallets are generalizable and composable.


## To run
```shell
$ pnpm i
$ pnpm dev
```

## To test
```shell
$ cd packages/contracts
$ pnpm mud test
```

## To deploy

deploy on scroll sepolia

```bash
cd packages/contracts
pnpm run deploy:scrollSepolia
```


deploy on base sepolia


```bash
cd packages/contracts
pnpm run deploy:baseSepolia
```

