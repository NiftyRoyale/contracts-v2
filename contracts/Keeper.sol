// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract BattleRoyaleArena is VRFConsumerBase {
  // Chainlink properties
  bytes32 internal keyHash;
  uint256 public fee;
  // Address of primary wallet
  address payable public walletAddress;
  // temp mapping for battles in random elimination mechanic
  mapping(bytes32 => address payable) requestToBattle;
  mapping(address => bool) eliminationState;
  // Look into elimination logic and how to maintain state of all NFTs in and out of play
  AddressArray.Addresses battleQueue;

  constructor(
    address _vrfCoordinator,
    address _linkToken,
    bytes32 _keyHash,
    uint256 _fee
  )
  public VRFConsumerBase(_vrfCoordinator, _linkToken)
  {
    keyHash = _keyHash;
    fee = _fee; // Set to Chainlink fee for network, Rinkeby and Kovan is 0.1 LINK and MAINNET is 2 LINK

    walletAddress = payable(owner());
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }
  /**
   * Fallback function to receive ETH
   */
  receive() external payable {}
  /*
   * Method to withdraw ETH
   */
  function withdraw(uint256 amount) external onlyAdmin {
    uint256 balance = address(this).balance;
    require(amount <= balance);

    if (walletAddress != address(0)) {
      payable(walletAddress).transfer(amount);
    } else {
      msg.sender.transfer(amount);
    }
  }
  /*
   * Get Current ETH Balance from contract
   */
  function getCurrentBalance() external onlySupport view returns (uint256) {
    uint256 balance = address(this).balance;
    return balance;
  }
  /*
   * Method to withdraw LINK
   */
  function withdrawLink(uint256 amount) external onlyAdmin returns (bool) {
    uint256 balance = LINK.balanceOf(address(this));
    require(amount <= balance);

    if (walletAddress != address(0)) {
      return LINK.transfer(address(walletAddress), amount);
    } else {
      return LINK.transfer(msg.sender, amount);
    }
  }
  /*
   * Get Current LINK Balance from contract
   */
  function getCurrentLinkBalance() external onlySupport view returns (uint256) {
    return LINK.balanceOf(address(this));
  }

  /* ===== Battle Royale Arena Methods ===== */
  function addToBattleQueue(address payable _nftAddress) external payable onlySupport returns(bool) {
    eliminationState[_nftAddress] = false;
    return battleQueue.push(_nftAddress);
  }

  function getBattleQueue() external view returns (address payable[] memory) {
    return battleQueue.getAll();
  }

  function isContractInQueue(address payable _contract) external view returns (bool) {
    return battleQueue.exists(_contract);
  }

  function removeFromQueue(address payable nftAddress) external onlySupport payable returns(address payable[] memory) {
    battleQueue.remove(nftAddress);
    delete eliminationState[nftAddress];
    return battleQueue.getAll();
  }

  function setWalletAddress(address payable _wallet) external onlyOwner payable {
    walletAddress = _wallet;
  }
  /*
   * addressToBytes
   * @param  {[type]} address [description]
   * @return {[type]}         [description]
   */
  function addressToBytes(address payable a) internal pure returns (bytes memory b) {
    return abi.encodePacked(a);
  }
  /*
   * bytesToAddress
   * @param  {[type]} bytes [description]
   * @return {[type]}       [description]
   */
  function bytesToAddress(bytes memory bys) internal pure returns (address payable addr) {
    assembly {
      addr := mload(add(bys,20))
    }
  }

  /* ==========================
   * CHAINLINK METHODS
   * ========================== */
  /* === Keeper Network === */
  /*
   * Check upkeep will excute upkeep when intervals hit 0
   */
  function checkUpkeep(bytes calldata checkData)
  external
  view
  returns(
    bool upkeepNeeded,
    bytes memory performData
  ) {
    for (uint i = 0; i < battleQueue.size(); i++) {
      address payable nftAddress = battleQueue.atIndex(i);
      BattleRoyale battle = BattleRoyale(nftAddress);
      uint256 timestamp = battle.timestamp();
      uint256 intervalTime = battle.intervalTime();

      if (battle.getBattleStateInt() == 1
        && block.timestamp >= timestamp + (intervalTime * 1 minutes)
        && eliminationState[nftAddress] == false) {
        return (true, addressToBytes(nftAddress));
      }
    }
    return (false, checkData);
  }
  /*
   * Perform Upkeep execute random elimination
   */
  function performUpkeep(bytes calldata performData) onlySupport external {
    address payable nftAddress = bytesToAddress(performData);
    // execute upkeep
    if (eliminationState[nftAddress] == false) {
      executeBattle(nftAddress);
    }
  }
  /* === Verifiable Random Function === */
  function executeBattle(address payable _nftAddress) internal returns (bytes32) {
    BattleRoyale battle = BattleRoyale(_nftAddress);

    require(LINK.balanceOf(address(this)) >= fee);
    require(battle.getBattleStateInt() == 1);
    require(battle.getInPlay().length > 1);

    eliminationState[_nftAddress] = true;
    // Adjust queue
    battleQueue.remove(_nftAddress);
    battleQueue.push(_nftAddress);

    eliminationState[_nftAddress] = true;
    // Adjust queue
    battleQueue.remove(_nftAddress);
    battleQueue.push(_nftAddress);

    bytes32 requestId = requestRandomness(keyHash, fee);
    requestToBattle[requestId] = _nftAddress;

    return requestId;
  }
}
