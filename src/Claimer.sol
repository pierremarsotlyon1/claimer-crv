//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface LendGauge {
    function claim_rewards(address user) external;
    function reward_count() external view returns(uint256);
}

interface CrvMinter {
    function mint_for(address gauge, address user) external;
    function allowed_to_mint_for(address minting_user, address user) external returns (bool);
}

contract Claimer {

    CrvMinter minter = CrvMinter(address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0));

    function claimAll(address[] calldata gaugeAddresses, bool[] calldata claimsCrv) external {
        uint256 i = 0;
        uint256 length = gaugeAddresses.length;
        for(;i<length;) {
            claim(gaugeAddresses[i], claimsCrv[i]);
            unchecked {
                i++;
            }
        }
    }

    function claim(address gaugeAddress, bool claimCrv) public {
        LendGauge(gaugeAddress).claim_rewards(msg.sender);

        if(claimCrv) {
            // For L2, canMintFor is here and not in the previous if
            if(canMintFor()) {
                minter.mint_for(gaugeAddress, msg.sender);
            }
        }
    }

    function canMintFor() public returns(bool) {
        return minter.allowed_to_mint_for(address(this), msg.sender);
    }
}