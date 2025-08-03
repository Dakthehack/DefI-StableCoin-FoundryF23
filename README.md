# DSC - Decentralized Stablecoin

A decentralized, algorithmically stabilized cryptocurrency pegged to the US Dollar. The DSC protocol maintains a $1.00 peg through overcollateralized positions using ETH and BTC as backing assets, similar to MakerDAO's DAI but without governance, fees, and with a simplified collateral model.

## Protocol Design

**Stability Properties:**
1. **Relative Stability**: Anchored/Pegged → $1.00 USD
   - Chainlink Price Feeds for accurate pricing
   - Exchange mechanisms for ETH and BTC collateral
2. **Stability Mechanism**: Algorithmic (Decentralized)
   - Users can only mint DSC with sufficient collateral
   - Liquidation mechanisms maintain protocol health
3. **Collateral Type**: Exogenous (Cryptocurrency)
   - Wrapped Ethereum (wETH)
   - Wrapped Bitcoin (wBTC)

## Key Features

- **Overcollateralized Minting**: Users must maintain >200% collateralization ratio
- **Liquidation Protection**: Automatic liquidation when health factor drops below 1.0
- **Oracle Security**: Integrated Chainlink price feeds with staleness checks
- **Gas Optimized**: Efficient smart contract design for lower transaction costs
- **Admin Controls**: Owner functions for emergency response and protocol upgrades
- **Comprehensive Testing**: 128 tests with 99%+ coverage

- [DSC - Decentralized Stablecoin](#dsc---decentralized-stablecoin)
  - [Protocol Design](#protocol-design)
  - [Key Features](#key-features)
  - [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Quickstart](#quickstart)
      - [Optional Gitpod](#optional-gitpod)
  - [Usage](#usage)
    - [Testing](#testing)
      - [Test Coverage](#test-coverage)
    - [Deployment](#deployment)
  - [Security](#security)
    - [Audit Reports](#audit-reports)
    - [Known Issues](#known-issues)
  - [Protocol Mechanics](#protocol-mechanics)
    - [Minting DSC](#minting-dsc)
    - [Liquidations](#liquidations)
    - [Health Factor](#health-factor)
  - [Smart Contract Architecture](#smart-contract-architecture)
  - [Audit Scope Details](#audit-scope-details)
    - [Compatibilities](#compatibilities)
  - [Roles](#roles)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```bash
git clone https://github.com/Cyfrin/foundry-defi-stablecoin-f23
cd foundry-defi-stablecoin-f23
forge build
```

### Optional Gitpod

If you can't or don't want to run and install locally, you can work with this repo in Gitpod. If you do this, you can skip the `clone this repo` part.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/Cyfrin/foundry-defi-stablecoin-f23)

# Usage

## Testing

```bash
forge test
```

### Test Coverage

```bash
forge coverage
```

For detailed coverage reports:

```bash
forge coverage --report debug
```

Current test metrics:
- **Total Tests**: 128 passing
- **DSCEngine Coverage**: 99.28% lines, 100% functions
- **DecentralizedStableCoin Coverage**: 100% all metrics
- **Invariant Testing**: 256 runs with 128,000 calls each

## Deployment

Deploy to local Anvil chain:
```bash
make deploy
```

Deploy to testnet:
```bash
forge script script/DeployDsc.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

# Security

## Audit Reports

- [Professional Security Audit](SECURITY_AUDIT_REPORT.md) - Comprehensive security review
- [Security Fixes Summary](SECURITY_FIXES_SUMMARY.md) - Applied security improvements

**Security Improvements Implemented:**
- ✅ Oracle price validation with staleness checks
- ✅ Constructor parameter validation  
- ✅ Access control with admin functions
- ✅ Enhanced event emissions for monitoring
- ✅ Gas optimizations and precision fixes

## Known Issues

The protocol has undergone security review and fixes. See [Security Fixes Summary](SECURITY_FIXES_SUMMARY.md) for details on addressed vulnerabilities.

**Future Considerations:**
- Token decimal handling for non-18 decimal tokens
- More sophisticated liquidation mechanisms
- Circuit breaker patterns for extreme market conditions

# Protocol Mechanics

## Minting DSC

1. **Deposit Collateral**: Users deposit wETH or wBTC as collateral
2. **Mint DSC**: Users can mint DSC up to 50% of their collateral value
3. **Health Factor**: Must maintain health factor above 1.0 (200% collateralization)

```solidity
// Example: Deposit 1 ETH ($2000) → Can mint up to 1000 DSC
dscEngine.depositCollateralAndMintDsc(weth, 1e18, 1000e18);
```

## Liquidations

When a user's health factor drops below 1.0:
- Anyone can liquidate the position
- Liquidator receives 10% bonus from collateral
- Liquidator must pay off user's debt in DSC
- Improves protocol health by removing bad debt

## Health Factor

```
Health Factor = (Collateral Value × Liquidation Threshold) / Total DSC Minted
```

- **Liquidation Threshold**: 50% (users must be 200% overcollateralized)
- **Health Factor < 1.0**: Position can be liquidated
- **Health Factor ≥ 1.0**: Position is safe

# Smart Contract Architecture

```
DSCEngine.sol              - Core protocol logic
├── Collateral Management  - Deposit/withdraw collateral
├── DSC Minting           - Mint/burn stablecoin
├── Liquidation System    - Health factor monitoring
├── Price Feeds           - Chainlink oracle integration
└── Admin Functions       - Protocol management

DecentralizedStableCoin.sol - ERC20 stablecoin token
├── Minting Controls      - Only DSCEngine can mint
├── Burning Logic         - Burn from DSCEngine balance
└── Standard ERC20        - Transfer, approve, etc.

OracleLib.sol             - Price feed validation
├── Staleness Checks      - Prevent old price data
├── Circuit Breakers      - Handle oracle failures
└── Price Validation      - Ensure data integrity
```

# Audit Scope Details

- **Commit Hash**: Latest main branch
- **In Scope**:

```
./src/
├── DSCEngine.sol
├── DecentralizedStableCoin.sol
└── libraries/
    └── OracleLib.sol
```

## Compatibilities

- **Solidity Version**: ^0.8.20
- **Networks**: Ethereum, Sepolia, Arbitrum, Polygon
- **Collateral**: wETH, wBTC (ERC20 compatible)

# Roles

- **Owner/Admin**: Deployer of the protocol
  - Update price feeds in emergency situations
  - Add new collateral tokens to the protocol
  - No ability to drain funds or mint unbacked DSC
  
- **Users**: Anyone can interact with the protocol
  - Deposit collateral and mint DSC
  - Redeem collateral and burn DSC
  - Liquidate undercollateralized positions

- **Liquidators**: Specialized users who maintain protocol health
  - Monitor positions for liquidation opportunities
  - Execute liquidations to earn bonus rewards
  - Help maintain the stability of the DSC peg
   