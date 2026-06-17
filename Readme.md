1. Get your test tokens: https://faucet.0g.ai/
2. Add your private key in .env and provider address PROVIDER_ADDRESS="0xa48f01287233509FD694a22Bf840225062E67836"
3. Run these commands in your terminal to set up the 0G network, deposit your testnet tokens, and lock them with a specific AI provider.

# Run with npx (e.g., npx 0g-compute-cli setup-network )
```bash
# 1. Setup network and login using the PRIVATE_KEY in your .env
0g-compute-cli setup-network
0g-compute-cli login

# 2. Deposit 3 testnet tokens into the main 0G Compute ledger
0g-compute-cli deposit --amount 3

# 3. List available AI providers
0g-compute-cli inference list-providers

Note: Look at the terminal output and copy the Provider Address of a model you want to use (e.g., Qwen 2.5 7B).

Bash
# 4. Save that provider address as a variable (replace with the one you copied)
export PROVIDER=0xa48f01287233509FD694a22Bf840225062E67836

# 5. Lock 1 token with that specific provider so your agent can pay for inference
0g-compute-cli transfer-fund --provider $PROVIDER --amount 1
0g-compute-cli inference acknowledge-provider --provider $PROVIDER

4. Run npx ts-node testInference.ts to test setup. 