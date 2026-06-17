import { generateTrustScore } from "./src/compute/inference";

async function main() {
    const mockActivity = "User executed 5 successful DeFi loans, no liquidations, holding 10 ETH, wallet age 3 years.";
    await generateTrustScore("0x123...abc", mockActivity);
}

main();