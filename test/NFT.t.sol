// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "forge-std/Test.sol";
import "../src/NFT.sol";

contract NFTTest is Test {
    NFT private nft;
    using stdStorage for StdStorage;

    function setUp() public {
        // Deploy the nft contract
        nft = new NFT("BoredApe", "BA", "https://ipfs.io");
    }

    function testFailNoMintPricePaid() public {
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMaxSupplyReached() public {
        // get the slot for currentTokenId
        uint256 slot = stdstore
            .target(address(nft))
            .sig("currentTokenId()")
            .find();

        // typecast to bytes32
        bytes32 loc = bytes32(slot);

        // mock currentTokenId to 10000
        bytes32 mockecCurrentTokenId = bytes32(abi.encode(10000));
        // vm.store - a cheatcode which takes an address and updates the value of slot with the provided one.
        vm.store(address(nft), loc, mockecCurrentTokenId);
        // the call will fail successfully
        nft.mintTo{value: 0.008 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        nft.mintTo{value: 0.08 ether}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        // library for accessing storage
        uint256 slotOfNewOwner = stdstore
        // address of contract
            .target(address(nft))
        // 4 bytes selector
            .sig(nft.ownerOf.selector)
        // argument to function
            .with_key(1)
        // return slot number
            .find();

        uint160 ownerOfTokenIdOne = uint160(
            uint256(
                // vm.load returns whats stored on the slot
                (vm.load(address(nft), bytes32(abi.encode(slotOfNewOwner))))
            )
        );

        // verify address 1 really is the owner of token id one
        assertEq(address(ownerOfTokenIdOne), address(1));
    }

    function testBalanceIncremented() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotBalance = stdstore
            .target(address(nft))
            .sig(nft.balanceOf.selector)
            .with_key(address(1))
            .find();

        uint256 balanceFirstMint = uint256(
            vm.load(address(nft), bytes32(slotBalance))
        );

        assertEq(balanceFirstMint, 1);

        nft.mintTo{value: 0.08 ether}(address(1));

        uint256 balanceSecondMint = uint256(
            vm.load(address(nft), bytes32(abi.encode(slotBalance)))
        );

        assertEq(balanceSecondMint, 2);
    }

    function testSafeContractReceiver() public {
        Receiver receiver = new Receiver();
        // mint the nft from nft contract and send ether to it. nft is minted to receiver contract
        nft.mintTo{value: 0.08 ether}(address(receiver));

        uint256 slotBalance = stdstore
            .target(address(nft))
            .sig(nft.balanceOf.selector)
            .with_key(address(receiver))
            .find();

        uint256 balance = uint256(vm.load(address(nft), bytes32(slotBalance)));

        assertEq(balance, 1);
    }

    function testFailUnSafeContractReceiver() public {
        // Sets the bytecode of an address to the code of another address
        vm.etch(address(1), bytes("mock code"));
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testWithdrawalWorkAsOwner() public {
        Receiver receiver = new Receiver();

        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = payee.balance; // 0

        nft.mintTo{value: nft.MINT_PRICE()}(address(receiver));

        // Check that the balance of the contract is correct
        assertEq(address(nft).balance, nft.MINT_PRICE());

        uint256 nftBalance = address(nft).balance;

        // withdraw
        nft.withdrawPayments(payee);
        assertEq(payee.balance, priorPayeeBalance + nftBalance);
    }

    function testWithdrawalFailsAsNotOwner() public {
        // Mint an NFT, sending eth to the contract
        Receiver receiver = new Receiver();
        nft.mintTo{value: nft.MINT_PRICE()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(nft).balance, nft.MINT_PRICE());
        // Confirm that a non-owner cannot withdraw
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        nft.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }
}

contract Receiver is ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
