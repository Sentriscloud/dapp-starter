// Read-side smoke test using viem against Sentrix.
//
// Reads:
//   1. The deployer's native SRX balance (eth_getBalance — sees 18-decimal wei)
//   2. The deployer's WSRX balance (the contract you funded with `WrapSrx.s.sol`)
//   3. The deployer's DEMO balance (the ERC-20 from `Deploy.s.sol`)
//
// Configure DEMO_TOKEN + DEPLOY_ADDRESS via env, or paste them in directly
// after the deploy.

import { createPublicClient, http, parseAbi, formatEther, getAddress } from "viem";

const RPC_URL = process.env.RPC_URL ?? "https://testnet-rpc.sentrixchain.com";
const CHAIN_ID = Number(process.env.CHAIN_ID ?? 7120);

if (!process.env.DEPLOY_ADDRESS) {
  console.error("DEPLOY_ADDRESS not set in environment");
  process.exit(1);
}
const deployer = getAddress(process.env.DEPLOY_ADDRESS);

const wsrxByChain: Record<number, `0x${string}`> = {
  7119: "0x4693b113e523A196d9579333c4ab8358e2656553",
  7120: "0x85d5E7694AF31C2Edd0a7e66b7c6c92C59fF949A",
};
const wsrx = wsrxByChain[CHAIN_ID];
if (!wsrx) {
  console.error(`Unknown CHAIN_ID ${CHAIN_ID}`);
  process.exit(1);
}

const demo = process.env.DEMO_TOKEN ? getAddress(process.env.DEMO_TOKEN) : null;

const erc20 = parseAbi([
  "function balanceOf(address) view returns (uint256)",
  "function symbol() view returns (string)",
  "function name() view returns (string)",
]);

async function main() {
  const client = createPublicClient({
    chain: { id: CHAIN_ID, name: `Sentrix ${CHAIN_ID}`, nativeCurrency: { name: "Sentrix", symbol: CHAIN_ID === 7119 ? "SRX" : "tSRX", decimals: 18 }, rpcUrls: { default: { http: [RPC_URL] } } },
    transport: http(RPC_URL),
  });

  const native = await client.getBalance({ address: deployer });
  console.log(`Native balance for ${deployer}: ${formatEther(native)} ${CHAIN_ID === 7119 ? "SRX" : "tSRX"}`);

  const wsrxBal = await client.readContract({
    address: wsrx,
    abi: erc20,
    functionName: "balanceOf",
    args: [deployer],
  });
  console.log(`WSRX balance for ${deployer}: ${formatEther(wsrxBal)} WSRX (${wsrx})`);

  if (demo) {
    const [name, symbol, bal] = await Promise.all([
      client.readContract({ address: demo, abi: erc20, functionName: "name" }),
      client.readContract({ address: demo, abi: erc20, functionName: "symbol" }),
      client.readContract({ address: demo, abi: erc20, functionName: "balanceOf", args: [deployer] }),
    ]);
    console.log(`${name} (${symbol}) balance for ${deployer}: ${formatEther(bal)} (${demo})`);
  } else {
    console.log("DEMO_TOKEN not set — skipping demo-token read.");
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
