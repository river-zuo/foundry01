- 优化前
```
╭------------------------------------------+-----------------+--------+--------+--------+---------╮
| src/nft/NFTMarket.sol:NFTMarket Contract |                 |        |        |        |         |
+=================================================================================================+
| Deployment Cost                          | Deployment Size |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| 754043                                   | 3541            |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
|                                          |                 |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| Function Name                            | Min             | Avg    | Median | Max    | # Calls |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| buyNFT                                   | 23672           | 51581  | 29277  | 101796 | 3       |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| list                                     | 27202           | 112945 | 125840 | 142928 | 5       |
╰------------------------------------------+-----------------+--------+--------+--------+---------╯
```
- 优化后
```
╭------------------------------------------+-----------------+--------+--------+--------+---------╮
| src/nft/NFTMarket.sol:NFTMarket Contract |                 |        |        |        |         |
+=================================================================================================+
| Deployment Cost                          | Deployment Size |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| 693601                                   | 3261            |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
|                                          |                 |        |        |        |         |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| Function Name                            | Min             | Avg    | Median | Max    | # Calls |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| buyNFT                                   | 23577           | 51507  | 29179  | 101766 | 3       |
|------------------------------------------+-----------------+--------+--------+--------+---------|
| list                                     | 27134           | 112931 | 125840 | 142928 | 5       |
╰------------------------------------------+-----------------+--------+--------+--------+---------╯
```
