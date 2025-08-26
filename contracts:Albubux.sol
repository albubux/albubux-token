// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Albubux (BUBX)
 * @notice Simple BEP20 token for BNB Smart Chain with optional sell-fee (default 1%) and 0% buy/transfer fee.
 *         The fee, if enabled, is taken only when the recipient is marked as an AMM pair (sell on DEX).
 *         No minting after deployment; total supply is fixed.
 */
contract Albubux is ERC20, Ownable {
    // 400,000,000,000,000 BUBX total supply (18 decimals)
    uint256 private constant INITIAL_SUPPLY = 400_000_000_000_000 * 1e18;

    // Fee in basis points (100 = 1%). Applied only on sells (recipient is an AMM pair).
    uint256 public sellFeeBps = 100; // 1% by default
    uint256 public constant MAX_FEE_BPS = 300; // hard cap 3%

    address public feeReceiver;

    // Mark DEX pairs (PancakeSwap, etc.). If recipient is pair -> it's a sell
    mapping(address => bool) public isAMMPair;

    // Exemptions (owner, contract, receiver etc. can be excluded)
    mapping(address => bool) public isFeeExempt;

    event FeeReceiverUpdated(address indexed newReceiver);
    event SellFeeUpdated(uint256 newFeeBps);
    event AMMPairSet(address indexed pair, bool isPair);
    event FeeExemptSet(address indexed account, bool isExempt);

    constructor(address _feeReceiver) ERC20("Albubux", "BUBX") {
        require(_feeReceiver != address(0), "Receiver=0");
        feeReceiver = _feeReceiver;

        // Mint fixed supply to the deployer (owner)
        _mint(msg.sender, INITIAL_SUPPLY);

        // Common sense defaults
        isFeeExempt[msg.sender] = true; // owner
        isFeeExempt[address(this)] = true; // token contract
        isFeeExempt[_feeReceiver] = true; // marketing/treasury
    }

    /**
     * @dev Override ERC20 _transfer to apply a sell fee when recipient is an AMM pair.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if (amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }

        uint256 feeAmount = 0;

        // Apply only if neither side is exempt
        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            // Selling to a DEX pair -> take fee
            if (isAMMPair[recipient] && sellFeeBps > 0) {
                feeAmount = (amount * sellFeeBps) / 10_000;
            }
        }

        if (feeAmount > 0) {
            super._transfer(sender, feeReceiver, feeAmount);
            amount -= feeAmount;
        }

        super._transfer(sender, recipient, amount);
    }

    // ---------------- Admin functions (owner) ----------------

    function setFeeReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Receiver=0");
        feeReceiver = _receiver;
        emit FeeReceiverUpdated(_receiver);
    }

    function setSellFeeBps(uint256 _bps) external onlyOwner {
        require(_bps <= MAX_FEE_BPS, "Fee too high");
        sellFeeBps = _bps;
        emit SellFeeUpdated(_bps);
    }

    function setAMMPair(address pair, bool value) external onlyOwner {
        require(pair != address(0), "pair=0");
        isAMMPair[pair] = value;
        emit AMMPairSet(pair, value);
    }

    function setFeeExempt(address account, bool value) external onlyOwner {
        isFeeExempt[account] = value;
        emit FeeExemptSet(account, value);
    }
}
