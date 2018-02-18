pragma solidity ^0.4.18;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/zeppelin/math/SafeMath.sol";



contract Project is AragonApp {
	uint256 pricePerToken;
	address director;
	bytes32 projectName;
	uint financialGoal;
	uint blocksTilFinished;
	enum stage { Funding, Denied, Succeeded}
	stage currentStatus;
	uint256 maxTokens = 100000;
	uint256 tokensLeft = maxTokens;

	function Project(bytes32 _name, address _director, uint256 _amount, uint _blocksTilFinished) public {
		director = _director;
		projectName = _name;
		financialGoal = _amount;
		blocksTilFinished = _blocksTilFinished;
		currentStatus = stage.Funding;
		pricePerToken = SafeMath.div(_amount, maxTokens);
	}

	modifier onlyDirector {
		if (msg.sender != director) {
			revert();
		}
		_;
	}

	function getStatus () public returns(stage) {
		if (block.number < blocksTilFinished && this.balance < financialGoal) {
			currentStatus = stage.Funding;
		}else if (this.balance >= financialGoal) {
			currentStatus = stage.Succeeded;
		}else {
			currentStatus = stage.Denied;
		}
		return currentStatus;
	}
	

	modifier whileFunding {
		getStatus();
		if (currentStatus != stage.Funding) {
			revert();
		}
		_;
	}

	mapping (address => uint256) tokenBalance;
	
	function deposit() payable whileFunding public {
		uint256 tokenAmount = SafeMath.div(uint256(msg.value), pricePerToken);
		if (tokensLeft - tokenAmount < 0) {
			revert();
		}
		tokensLeft -= tokenAmount;
		tokenBalance[msg.sender] += tokenAmount;
	}
	
	modifier ifDenied {
		getStatus();
		if (currentStatus != stage.Denied) {
			revert();
		}
		_;
	}

	function refund(address _returnAddress) ifDenied onlyDirector public {
		uint256 returnAmount = SafeMath.mul(tokenBalance[_returnAddress], pricePerToken);
		tokensLeft += tokenBalance[_returnAddress];
		tokenBalance[_returnAddress] = 0;
		_returnAddress.transfer(returnAmount);
	}
	
	modifier ifSucceeded {
		getStatus();
		if (currentStatus != stage.Succeeded) {
			revert();
		}
		_;
	}

	function trade(address _toAddress, uint _amount) ifSucceeded public {
		if (tokenBalance[msg.sender] >= _amount) {
			tokenBalance[_toAddress] += _amount;
			tokenBalance[msg.sender] -= _amount;
		}
	}

}
