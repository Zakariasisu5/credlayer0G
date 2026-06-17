credlayer/
├── .env                        # Environment variables (Keys, RPCs, Provider addresses)
├── .gitignore                  # Standard ignore file (node_modules, .env, artifacts)
├── README.md                   # Hackathon pitch, architecture diagram, and run instructions
├── package.json                # Node dependencies and run scripts
├── tsconfig.json               # TypeScript configuration
├── hardhat.config.ts           # Hardhat config pointing to 0G Testnet
│
├── contracts/                  # 0G Chain (Verification Layer)
│   └── CredLayerTrust.sol      # Smart contract that writes trust scores on-chain 
│
├── scripts/                    # Blockchain deployment & utility scripts
│   ├── deploy.ts               # Deploys CredLayerTrust to 0G Testnet
│   └── seedMockData.ts         # Optional: Mints fake scores to test your UI/indexer
│
├── test/                       # Smart contract unit tests
│   └── CredLayerTrust.test.ts  # Ensures your access control and events work locally
│
├── src/                        # Off-chain Agent & 0G Integration Logic
│   ├── compute/                # 0G Compute (Scoring Layer) 
│   │   ├── broker.ts           # Initializes the ZGComputeNetworkBroker 
│   │   └── inference.ts        # Prompts the 0G AI model to evaluate agent risk
│   │
│   ├── storage/                # 0G Storage (Data Layer) 
│   │   └── client.ts           # Fetches/uploads behavioral logs from 0G Storage 
│   │
│   ├── agent/                  # The Orchestrator (The main execution loop)
│   │   └── index.ts            # Fetches data -> Runs inference -> Writes to smart contract
│   │
│   └── utils/                  # Shared utilities
│       ├── constants.ts        # Contract addresses, 0G endpoints, model names
│       └── types.ts            # TypeScript interfaces for your data structures
│
└── frontend/                   # (Optional but highly recommended for the demo)
    ├── src/
    │   ├── app/                # Next.js pages (e.g., a simple search bar to look up an Agent's ID)
    │   └── components/         # UI components showing the Verification status
    └── package.json            # Frontend specific dependencies