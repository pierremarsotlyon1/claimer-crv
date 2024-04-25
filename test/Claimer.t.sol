// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Claimer} from "../src/Claimer.sol";

interface ERC20 {
    function balanceOf(address user) external view returns(uint256);
}

interface CrvMinter {
    function toggle_approve_mint(address minting_user) external;
}

contract ClaimerTest is Test {
    ERC20 CRV = ERC20(address(0xD533a949740bb3306d119CC777fa900bA034cd52));
    ERC20 crvUSD = ERC20(address(0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E));
    CrvMinter minter = CrvMinter(address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0));

    address gauge = address(0x49887dF6fE905663CDB46c616BfBfBB50e85a265);
    address user = address(0x31d3243CfB54B34Fc9C73e1CB1137124bD6B13E1);

    Claimer public claimerTest;

    function setUp() public {
        claimerTest = new Claimer();
    }

    function test_Claim () public {
        vm.startPrank(user);

        uint256 crvBefore = CRV.balanceOf(user);
        uint256 crvUSDBefore = crvUSD.balanceOf(user);
        
        claimerTest.claim(gauge, true);

        uint256 newCrvBefore = CRV.balanceOf(user);
        uint256 newCrvUSDBefore = crvUSD.balanceOf(user);

        // crv eq because not autorized to mint for
        assertEq(newCrvBefore, crvBefore);
        assertGt(newCrvUSDBefore, crvUSDBefore);

        vm.stopPrank();
    }

    function test_checkMintForFalse() public {
        vm.startPrank(user);

        assertFalse(claimerTest.canMintFor());

        vm.stopPrank();
    }

    function test_checkMintForTrue() public {
        vm.startPrank(user);

        minter.toggle_approve_mint(address(claimerTest));
        assertTrue(claimerTest.canMintFor());

        vm.stopPrank();
    }

    function test_ClaimWithCRV () public {
        vm.startPrank(user);

        uint256 crvBefore = CRV.balanceOf(user);
        uint256 crvUSDBefore = crvUSD.balanceOf(user);
        
        minter.toggle_approve_mint(address(claimerTest));
        claimerTest.claim(gauge, true);

        uint256 newCrvBefore = CRV.balanceOf(user);
        uint256 newCrvUSDBefore = crvUSD.balanceOf(user);

        // crv eq because not autorized to mint for
        assertGt(newCrvBefore, crvBefore);
        assertGt(newCrvUSDBefore, crvUSDBefore);

        vm.stopPrank();
    }

    function test_ClaimAllWithCRV () public {
        vm.startPrank(user);

        uint256 crvBefore = CRV.balanceOf(user);
        uint256 crvUSDBefore = crvUSD.balanceOf(user);
        
        minter.toggle_approve_mint(address(claimerTest));

        address[] memory gauges = new address[](2);
        gauges[0] = gauge;
        gauges[1] = gauge;

        bool[] memory claimsCrv = new bool[](2);
        claimsCrv[0] = true;
        claimsCrv[1] = true;

        claimerTest.claimAll(gauges, claimsCrv);

        uint256 newCrvBefore = CRV.balanceOf(user);
        uint256 newCrvUSDBefore = crvUSD.balanceOf(user);

        // crv eq because not autorized to mint for
        assertGt(newCrvBefore, crvBefore);
        assertGt(newCrvUSDBefore, crvUSDBefore);

        vm.stopPrank();
    }
}