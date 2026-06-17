import { ethers } from 'ethers';
import { createZGComputeNetworkBroker } from '@0gfoundation/0g-compute-ts-sdk';
import * as dotenv from 'dotenv';

dotenv.config();

export async function generateTrustScore(walletAddress: string, activityData: string) {
    try {
        console.log(`Evaluating trust score for ${walletAddress}...`);

        // 1. Initialize the Provider and Wallet
        const provider = new ethers.JsonRpcProvider('https://evmrpc-testnet.0g.ai');
        const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
        
        // 2. Create the 0G Broker (Wallet-based Auth)
        const broker = await createZGComputeNetworkBroker(wallet);
        const providerAddress = process.env.PROVIDER_ADDRESS!;

        // 3. Fetch Service Metadata and Cryptographic Headers
        const { endpoint, model } = await broker.inference.getServiceMetadata(providerAddress);
        const headers = await broker.inference.getRequestHeaders(providerAddress);

        // 4. Craft the CredLayer Prompt
        const systemPrompt = "You are the CredLayer Trust AI. Analyze the provided on-chain activity data and output a JSON object with a single key 'trust_score' containing an integer from 1 to 100 representing the risk profile.";
        const userPrompt = `Activity data for ${walletAddress}: ${activityData}`;

        // 5. Send the Request to the 0G Provider
        const res = await fetch(`${endpoint}/chat/completions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', ...headers },
            body: JSON.stringify({ 
                model, 
                messages: [
                    { role: 'system', content: systemPrompt },
                    { role: 'user', content: userPrompt }
                ] 
            }),
        });

        const data = await res.json();
        const aiResponse = data.choices[0].message.content;
        
        console.log("0G Compute Response:", aiResponse);
        return aiResponse;

    } catch (error) {
        console.error("Error generating trust score via 0G Compute:", error);
        throw error;
    }
}