# Load environment variables from .env
include .env
export $(shell sed 's/=.*//' .env)

# Formatting and Testing prerequisite
.PHONY: check
check:
	forge fmt
	forge build --sizes
	forge test --gas-report
	forge coverage

# Deployment targets
DeployDiamond: check
	forge script script/DeployDiamond.s.sol --rpc-url holesky --account dev --broadcast --verify

UpdateDiamond: check
	forge script script/UpdateDiamond.s.sol --rpc-url holesky --account dev --broadcast --verify

DeployMockNFT: check
	forge script script/DeployMockNFT.s.sol --rpc-url holesky --account dev --broadcast --verify

DeployDiamondLocal: check
	forge script script/DeployDiamond.s.sol --rpc-url localhost --account foundry-local --broadcast

