import {
  createWalletClient,
  custom,
  encodeFunctionData,
  keccak256,
  toBytes,
  encodePacked,
  parseEther,
  type Hex
} from 'viem'
import { sepolia } from 'viem/chains'

const nftMarketAbi = [
  {
    name: 'listWithSig',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'nft', type: 'address' },
      { name: 'tokenId', type: 'uint256' },
      { name: 'price', type: 'uint256' },
      { name: 'signature', type: 'bytes' }
    ],
    outputs: []
  }
] as const;

type ListParams = {
  nft: `0x${string}`
  tokenId: bigint
  price: bigint
  marketAddress: `0x${string}`
};

function getMessageHash(nft: `0x${string}`, tokenId: bigint, price: bigint): Hex {
  const encoded = encodePacked(
    ['address', 'uint256', 'uint256'],
    [nft, tokenId, price]
  )
  return keccak256(encoded)
}
;

export async function listWithSignature({
  nft,
  tokenId,
  price,
  marketAddress
}: ListParams): Promise<`0x${string}`> {
  // 连接钱包客户端（浏览器中使用 Metamask 的 provider）
  const walletClient = createWalletClient({
    chain: sepolia,
    transport: custom(window.ethereum)
  })

  const [account] = await walletClient.getAddresses()

  // 签名消息
  const hash = getMessageHash(nft, tokenId, price)
  const signature = await walletClient.signMessage({
    account,
    message: toBytes(hash)
  });

  // 准备调用数据
  const callData = encodeFunctionData({
    abi: nftMarketAbi,
    functionName: 'listWithSig',
    args: [nft, tokenId, price, signature]
  })

  // 发送交易
  const txHash = await walletClient.sendTransaction({
    account,
    to: marketAddress,
    data: callData
  })

  return txHash
}
