# smart-duck-farm :duck:

[![Hardhat - Build & Test](https://github.com/kampanosg/smart-duck-farm/actions/workflows/hardhat.yml/badge.svg)](https://github.com/kampanosg/smart-duck-farm/actions/workflows/hardhat.yml)

<p align="center">
  <img src="https://user-images.githubusercontent.com/30287348/231542806-4212e8da-5134-40ad-b196-24f3695a9dd1.png" />
</p>

## Overview

A $DUCKing NFT that lays `$EGG`. Buy `$FEED` with your `$EGG` and give it to your duckling to make it bigger. A bigger `$DUCK` lays more `$EGG`.

### Model
The Smart Duck Farm project is inspired by the [chikn.farm](chikn.farm) project and their [tokenomics model](https://docs.chikn.farm/). 

At its core `smart-duck-farm`, is a Blockchain Play-to-Earn (P2E) game that players can participate by minting (or buying) a `$DUCK` token. The duckling then lays `$EGG` which can be exchanged for `$BREAD`. Finally, the `$BREAD` can be given to the duckling to make it bigger. In turn, the `$DUCK` will produce more `$EGG`.

There is a set number of ducklings that can be minted. Once that number is reached, then the only way to acquire a `$DUCK` is by purchasing it on the open market. Players that own a `$DUCK` can put their ducklings for sale **but** they won't be earning any `$EGG` from it. 

<p align="center">
  <img src="https://3229867498-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FF8OuqlG4SiJ3bLJ9JiW1%2Fuploads%2F1R1Rr8cFhMxfQMdFtKdh%2Fimage.png?alt=media&token=538f5265-3d55-46cb-ae9b-8acdf58edbb8" />
  <br />
  <span><i>The chikn.farm tokenomics model</i></span>
</p>

:warning: Needless to say but I am not trying to steal their work or profit from it - I wanted explore how they've implemented it.

### Future Work
The chikn.farm creators have talked about the Bokchain - a VM in the Avalanche network, that other NFT projects could participate by using the `$EGG` token. In theory, if `$DUCK` was laying the actual `$EGG` token ([0x7761..E611](https://snowtrace.io/address/0x9C846D808A41328A209e235B5e3c4E626DAb169E)) it could be part of the Bokchain. However, I haven't seen any updates on the progress of the Bokchain.

### Limitations
* This doesn't come with any UI. This project is only the `solidity` smart contracts. I am not planning on building any UI such as the marketplace
* This is a Proof of Concept (PoC) and no parts of this should be considered "production-ready". Feel free to use as much of the code as you like but make sure you test it and vet it before deploying it to the blockchain.

## Building & Testing
### Requirements
* `yarn`

You can run `yarn install` and all the required dependencies will be installed.

### Building
To build the Smart Contracts from source, you can run the following
```
make compile
```
However, if you don't like `make`, you can use Hardhat directly
```
npx hardhat compile
```

### Testing
The project comes with a full suite of unit tests. You can run them as such:
```
make test
```
Again, if you don't like `make`, run them with Hardhat
```
npx hardhat test
```
