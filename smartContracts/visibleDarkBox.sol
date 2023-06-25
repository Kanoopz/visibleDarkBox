// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// Uncomment this line to use console.log
//import "hardhat/console.sol";

interface interfaceNft
{
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function approve(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface erc6551RegistryInterface
{
    function createAccount(address tokenCollection, uint256 tokenId) external;
}

contract visibleDarkBox
{
    address public chainRegistry;
    erc6551RegistryInterface public registryInstance;

    mapping(address => mapping(uint => bytes32)) private notCriticalPasswordPart;
    mapping(address => mapping(uint => bytes32)) private rootPassword;
    mapping(address => mapping(uint => bool)) private isSet;
    mapping(address => mapping(uint => address)) public tokenBoundAccounts;





    

    function setRecoveryPasswordConfig(address paramNftAddress, uint paramNftId, bytes32 paramRootPassword, bytes32 paramNotCriticalPartOfPassword) public
    {
        require(isSet[paramNftAddress][paramNftId] == false, "The password is already set for this NFT.");

        interfaceNft nftContractToSet = interfaceNft(paramNftAddress);
        require(nftContractToSet.ownerOf(paramNftId) == msg.sender, "msgSender is not the owner.");


        notCriticalPasswordPart[paramNftAddress][paramNftId] = paramNotCriticalPartOfPassword;
        rootPassword[paramNftAddress][paramNftId] = paramRootPassword;
        isSet[paramNftAddress][paramNftId] = true;


        address tokenBoundAccountToRegister = registryInstance.createAccount(paramNftAddress, paramNftId);
        registryInstance.createAccount(paramNftAddress, paramNftId);
        tokenBoundAccounts[paramNftAddress][paramNftId] = tokenBoundAccountToRegister;
    }

    function checkDarkBoxPassword(address paramNftAddress, uint paramNftId, bytes32 paramRecoveryPassword) public view returns(bool)
    {
        require(isSet[paramNftAddress][paramNftId] == true, "This NFT doesnt has visibleDarkBoxPassword.");


        bool matches;

        bytes32 rootPasswordCheking = rootPassword[paramNftAddress][paramNftId];
        bytes32 notCriticalPasswordPartChecking = notCriticalPasswordPart[paramNftAddress][paramNftId];

        bytes32 toHash = keccak256(abi.encode(paramRecoveryPassword, notCriticalPasswordPartChecking));

        if(toHash == rootPasswordCheking)
        {
            matches = true;
        }
        else
        {
            matches = false;
        }

        return matches;
    }

    function reclaimOwnershipWithDarkBoxPassword(address paramRecoveryAddress, address paramNftAddress, uint paramNftId, bytes32 paramRecoveryPassword) public
    {
        require(checkDarkBoxPassword(paramNftAddress, paramNftId, paramRecoveryPassword) == true, "Incorrect visibleDarkBoxPassword.");

        interfaceNft nftContractRecovery = interfaceNft(paramNftAddress);
        address owner = nftContractRecovery.ownerOf(paramNftId);
        
        nftContractRecovery.transferFrom(owner, paramRecoveryAddress, paramNftId);
    }

    function getIsSet(address paramNftContractAddress, uint paramNftId) public view returns(bool)
    {
        return isSet[paramNftContractAddress][paramNftId];
    }

    function getVisibleDarkBoxAddress() public view returns(address)
    {
        return address(this);
    }


    ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    function getNotCucialPassword(address paramAddress, uint paramId) public view returns(bytes32)
    {
        return notCriticalPasswordPart[paramAddress][paramId];
    }

    function getRootPassword(address paramAddress, uint paramId) public view returns(bytes32)
    {
        return rootPassword[paramAddress][paramId];
    }

    function getActualHashOfHashes(address paramAddress, uint paramId, bytes32 paramPassword) public view returns(bytes32)
    {
        bytes32 notCriticalToReturn = notCriticalPasswordPart[paramAddress][paramId];
        bytes32 toReturn = keccak256(abi.encode(paramPassword, notCriticalToReturn));

        return toReturn;
    }
}
