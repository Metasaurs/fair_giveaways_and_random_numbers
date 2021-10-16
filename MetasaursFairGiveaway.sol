// SPDX-License-Identifier: Business Source License 1.1
// license: Business Source License 1.1!
// effectively a time-delayed GPL-2.0-or-later license.
// The license limits use of the this source code in a commercial or production setting for up to two years, at which point it will convert to a GPL license into perpetuity.
// created by Andy @ 16 Oct 2021
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// ___ ___    ___ ______   ____  _____  ____  __ __  ____    _____
//|   |   |  /  _]      | /    |/ ___/ /    ||  |  ||    \  / ___/
//| _   _ | /  [_|      ||  o  (   \_ |  o  ||  |  ||  D  )(   \_
//|  \_/  ||    _]_|  |_||     |\__  ||     ||  |  ||    /  \__  |
//|   |   ||   [_  |  |  |  _  |/  \ ||  _  ||  :  ||    \  /  \ |
//|   |   ||     | |  |  |  |  |\    ||  |  ||     ||  .  \ \    |
//|___|___||_____| |__|  |__|__| \___||__|__| \__,_||__|\_|  \___|
contract MetasaursFairGiveaway is VRFConsumerBase, Ownable {
	bytes32 internal keyHash;
	uint256 internal fee;

	uint256[] public randomResults; //keeps track of the random number from chainlink
	uint256[][] public expandedResults; //winners list
	uint256[] public winnerResults; //one winner list
	uint256 public totalDraws = 0; //drawID is drawID-1!
	string[] public ipfsProof; //proof list where the list participants is
	mapping(bytes32 => uint256) public requestIdToDrawIndex;

	event IPFSProofAdded(string proof);
	event RandomRequested(bytes32 indexed requestId, address indexed roller);
	event RandomLanded(bytes32 indexed requestId, uint256 indexed result);
	event Winners(uint256 randomResult, uint256[] expandedResult);
	event Winner(uint256 randomResult, uint256 winningNumber);

	constructor(
		address _vrfCoordinator,
		address _linkToken,
		bytes32 _keyHash,
		uint256 _fee
	) VRFConsumerBase(_vrfCoordinator, _linkToken) {
		keyHash = _keyHash;
		fee = _fee;
	}

	//you start by calling this function and having in IPFS the list of participants
	function addContestData(string memory ipfsHash) external onlyOwner {
		ipfsProof.push(ipfsHash);
		emit IPFSProofAdded(ipfsHash);
	}

	/**
	 * Requests randomness
	 */
	function getRandomNumber() external onlyOwner returns (bytes32 requestId) {
		require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in the contract");
		requestId = requestRandomness(keyHash, fee);
		emit RandomRequested(requestId, msg.sender);
		requestIdToDrawIndex[requestId] = totalDraws;
		return requestId;
	}

	/**
	 * Callback function used by VRF Coordinator
	 */
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
		randomResults.push(randomness);
		totalDraws++;
		emit RandomLanded(requestId, randomness);
	}

	//second, you may call this if many winners are required
	function pickManyWinners(
		uint256 numWinners,
		uint256 drawId,
		uint256 totalEntries
	) external onlyOwner {
		uint256[] memory expandedValues = new uint256[](numWinners);
		for (uint256 i = 0; i < numWinners; i++) {
			expandedValues[i] =
				(uint256(keccak256(abi.encode(randomResults[drawId], i))) % totalEntries) +
				1;
		}
		expandedResults.push(expandedValues);
		emit Winners(randomResults[drawId], expandedValues);
	}

	//or just one winner
	function pickOneWinner(uint256 drawId, uint256 totalEntries) external onlyOwner {
		uint256 winner = (uint256(keccak256(abi.encode(randomResults[drawId], 1))) % totalEntries) + 1;
		winnerResults.push(winner);
		emit Winner(randomResults[drawId], winner);
	}

	//------ other things --------
	function withdrawLink() external onlyOwner {
		LINK.transfer(owner(), LINK.balanceOf(address(this)));
	}
}
