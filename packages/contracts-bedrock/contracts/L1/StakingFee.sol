// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingFee is Ownable {
    bytes[] public depositValidators;
    address public OptimismPortal;
    address Oracle;
    uint256 rewards = 0;
    uint256 ethDeposited = 0;
    uint256 ethMintedOptimism = 0;
    uint256 ethSlashed = 0;

    struct ValidatorSlashed {
        bytes publicKey;
        uint256 amount;
    }

    error NotOptimismPortal();
    modifier onlyOptimismPortal(address sender){
        if (sender != OptimismPortal) {
            revert NotOptimismPortal();
        }
        _;
    }
    error NotOracle();
    modifier onlyOracle(address sender){
        if (sender != Oracle) {
            revert NotOracle();
        }
        _;
    }

    constructor(address _portal) public {
        OptimismPortal = _portal;
    }

    receive() external payable {
        rewards += msg.value;
    }

    function setOracle(address _oracle) external onlyOwner {
        Oracle = _oracle;
    }

    function updateDeposit(uint256 _ethDeposited, uint256 _ethMinted) external onlyOptimismPortal (msg.sender) {
        ethDeposited += _ethDeposited;
        ethMintedOptimism += _ethMinted;
    }

    function getPrice() external view returns (uint256 price){
        if (ethDeposited == 0) {
            price = 1e18;
        }
        else {
            price = uint256((ethDeposited + rewards - ethSlashed) * 1e18 / ethMintedOptimism);
        }
    }

    function validatorSlashed(ValidatorSlashed[] calldata _validators) external onlyOracle(msg.sender) {
        for (uint256 i = 0; i < _validators.length; ++i) {
            ethSlashed += _validators[i].amount;
        }
    }

    function addDepositValidator(bytes calldata _pubKey) external onlyOptimismPortal(msg.sender) {
        depositValidators.push(_pubKey);
    }


}
