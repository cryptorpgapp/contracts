// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoRPGPrivatePlacement is Ownable {
    address constant public rpgAddress = 0x284643d9df25551A85D68eF903E59f8Ef90Bec01;
    address constant public airdropAddress = 0x79DbAf13CAabd4b4a787a7FF04c64ABE37475B9C;

    // Identical to Unicrypt Presale
    uint constant public EXCHANGE_RATE = 110_000;
    uint constant public PRESALE_HARDCAP = 19_000_000 * 10 ** 18;
    // Mar 11 00:01 UTC
    uint constant public REDEEM_BEGIN_FOR_AIRDROP = 1_646_956_860;
    
    mapping(address => uint) public allowanceOf;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public claimedOf;
    
    uint public totalBalance;
    bool public presaleOn = false;
    bool public claimOn = false;

    function buyPresale(uint amount) public payable {
        require(presaleOn, "CryptoRPG: Presale is not up");

        address sender = _msgSender();
        balanceOf[sender] += amount;
        require(balanceOf[sender] <= allowanceOf[sender], "CryptoRPG: Allowance exceeded");
        require(msg.value * EXCHANGE_RATE >= amount, "CryptoRPG: Value is incorrect");

        totalBalance += amount;
        require(totalBalance <= PRESALE_HARDCAP, "CryptoRPG: Presale hardcap is reached");
    }

    function claimRPG() public {
        require(claimOn, "CryptoRPG: Claiming is not up");

        address sender = _msgSender();
        uint claimable = balanceOf[sender] - claimedOf[sender];        
        require(claimable > 0, "CryptoRPG: Nothing to claim");

        claimedOf[sender] += claimable;
        IERC20(rpgAddress).transfer(sender, claimable);
    }

    function redeemAirdrop() public {
        require(block.timestamp > REDEEM_BEGIN_FOR_AIRDROP, "CryptoRPG: Airdrop redeem didn't start");

        address sender = _msgSender();
        uint balance = IERC20(airdropAddress).balanceOf(sender);
        require(balance > 0, "CryptoRPG: No airdrop");
        
        IERC20(airdropAddress).transferFrom(sender, address(this), balance);
        IERC20(rpgAddress).transfer(sender, balance);
    }

    function setAllowanceOf(address[] memory addresses, uint[] memory allowances) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            allowanceOf[addresses[i]] = allowances[i];
        }
    }

    function toggleClaim() public onlyOwner {
        claimOn = !claimOn;
    }

    function togglePresale() public onlyOwner {
        presaleOn = !presaleOn;
    }

    function withdrawAdmin() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
