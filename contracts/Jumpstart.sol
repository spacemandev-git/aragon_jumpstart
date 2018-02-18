pragma solidity ^0.4.18;
import "@aragon/os/contracts/apps/AragonApp.sol";
import "./Project.sol";

contract Jumpstart is AragonApp {
  bytes32 constant public ROLE_DIRECTOR = keccak256("ROLE_DIRECTOR");
  bytes32 constant public ROLE_PUBLIC = keccak256("ROLE_PUBLIC");
  Project[] projects;

  function () payable {
    revert(); //default function will revert 
  }

  function newProject(bytes32 _title, uint _amt, uint _block) public returns(address) {
   // Need: Name of project, director, amount, blocks til finish
   Project newProj = new Project(_title, msg.sender, _amt, _block);
   projects.push(newProj); 
   return newProj;
  }

}