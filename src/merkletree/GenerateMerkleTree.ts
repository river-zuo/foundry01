import { keccak256, toBytes, toHex } from 'viem';
import { MerkleTree } from 'merkletreejs';

// ✅ 白名单地址列表
const whitelist = [
  '0x709fCA731675b619CC24c284eeB5AEF1D7527c77',
  // '0x2222222222222222222222222222222222222222',
  // '0x3333333333333333333333333333333333333333',
];

// ✅ 计算 leaf 节点（使用 keccak256 + abi.encodePacked 风格）
const leaves = whitelist.map((addr) => keccak256(toBytes(addr)));

// ✅ 构造 Merkle 树（使用 sorted pairs 确保和合约逻辑一致）
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// ✅ 获取 Merkle 根
const root = tree.getHexRoot();
console.log('Merkle Root:', root);

// ✅ 输出每个地址的 Merkle proof
for (const address of whitelist) {
  const leaf = keccak256(toBytes(address));
  const proof = tree.getHexProof(leaf);
  console.log(`\nAddress: ${address}`);
  console.log(`Leaf: ${leaf}`);
  console.log('Proof:', proof);
}
// 执行 

