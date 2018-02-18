pragma solidity ^0.4.18;

import "@aragon/os/contracts/apps/AragonApp.sol";


contract Project is AragonApp {
	address creator;
    bytes32 constant public DIRECTOR_ROLE = keccak256("MINT_ROLE");
    bytes32 constant public GENERAL_PUBLIC_ROLE = keccak256("ISSUE_ROLE");

	function initialize(string _name) onlyInit {
		initialized();
		kernel.initialize(msg.sender);
		creator = msg.sender;
	}

	function grantNewPermission(address _memberAddress){
		grantPermission(_memberAddress, PERMISSIONS_CREATOR_ROLE, creator)
	}
}
