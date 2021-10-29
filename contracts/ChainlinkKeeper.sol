// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ChainlinkKeeper is VRFConsumerBase, Ownable {
    using SafeERC20 for IERC20;

    /// @notice Event emitted when contract is deployed.
    event ChainlinkKeeperDeployed();

    /// @notice Event emitted when owner withdrew the ETH.
    event EthWithdrew(address receiver);

    /// @notice Event emitted when owner withdrew the ERC20 token.
    event ERC20TokenWithdrew(address receiver);

    /// @notice Event emitted when battle is added.
    event BattleAdded(BattleInfo battle);

    /// @notice Event emitted when battle is executed.
    event BattleExecuted(uint256 battleId, bytes32 requestId);

    /// @notice Event emitted when one nft is eliminated.
    event Eliminated(address gameAddr, uint256 tokenId);

    /// @notice Event emitted when winner is set.
    event BattleEnded(bool finished, address gameAddr, uint256 tokenId);

    bytes32 internal keyHash;
    uint256 public fee;

    mapping(bytes32 => uint256) requestToBattle;

    struct BattleInfo {
        address gameAddr;
        uint256 intervalTime;
        uint256 lastEliminatedTime;
        uint256[] inPlay;
        uint256[] outOfPlay;
        bool battleState;
    }

    BattleInfo[] public battleQueue;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Polygon(Matic) Mainnet
     * Chainlink VRF Coordinator address: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
     * LINK token address:                0xb0897686c545045aFc77CF20eC7A532E3120E0F1
     * Key Hash:                          0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
     * Fee : 0.0001LINK
     */
    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    )
        VRFConsumerBase(
            _vrfCoordinator, // VRF Coordinator
            _link // LINK Token
        )
    {
        keyHash = _keyHash;
        fee = _fee;

        emit ChainlinkKeeperDeployed();
    }

    /**
     * @dev External function to add battle. This function can be called only by owner.
     * @param _gameAddr Battle game address
     * @param _intervalTime Interval time
     * @param _inPlay Tokens in game
     */
    function addToBattleQueue(
        address _gameAddr,
        uint256 _intervalTime,
        uint256[] memory _inPlay
    ) external onlyOwner {
        BattleInfo memory battle;
        battle.gameAddr = _gameAddr;
        battle.intervalTime = _intervalTime;
        battle.lastEliminatedTime = block.timestamp;
        battle.inPlay = _inPlay;
        battle.battleState = true;

        battleQueue.push(battle);

        emit BattleAdded(battle);
    }

    /**
     * @dev External function to check up keep.
     * @param _checkData Keeper register check data
     */
    function checkUpkeep(bytes calldata _checkData)
        external
        view
        returns (bool, bytes memory)
    {
        for (uint256 i = 0; i < battleQueue.length; i++) {
            BattleInfo memory battle = battleQueue[i];
            if (
                battle.battleState == true &&
                block.timestamp >=
                battle.lastEliminatedTime + (battle.intervalTime * 1 minutes)
            ) {
                return (true, abi.encodePacked(i));
            }
        }
        return (false, _checkData);
    }

    /**
     * @dev External function to perform up keep.
     * @param _performData BattleId from checkup
     */
    function performUpkeep(bytes calldata _performData) external {
        uint256 battleId = bytesToUint256(_performData, 0);
        executeBattle(battleId);
    }

    /**
     * @dev Internal function to execute battle.
     * @param _battleId Battle Id
     */
    function executeBattle(uint256 _battleId) internal {
        BattleInfo storage battle = battleQueue[_battleId];

        require(
            LINK.balanceOf(address(this)) >= fee,
            "ChainlinkKeeper: Not enough LINK"
        );
        require(
            battle.battleState,
            "ChainlinkKeeper: Current battle is finished"
        );

        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToBattle[requestId] = _battleId;
        battle.lastEliminatedTime = block.timestamp;

        emit BattleExecuted(_battleId, requestId);
    }

    /**
     * @dev Callback function used by VRF Coordinator.
     * @param _requestId Request Id
     * @param _randomness Random Number
     */
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        uint256 _battleId = requestToBattle[_requestId];
        BattleInfo storage battle = battleQueue[_battleId];
        uint256 i = _randomness % battle.inPlay.length;
        uint256 tokenId = battle.inPlay[i];
        battle.outOfPlay.push(tokenId);
        battle.inPlay[i] = battle.inPlay[battle.inPlay.length - 1];
        battle.inPlay.pop();

        emit Eliminated(battle.gameAddr, tokenId);

        if (battle.inPlay.length == 1) {
            battle.battleState = false;
            tokenId = battle.inPlay[0];
            emit BattleEnded(true, battle.gameAddr, tokenId);
        }
    }

    /**
     * Fallback function to receive ETH
     */
    receive() external payable {}

    /**
     * @dev External function to get the current link balance in contract.
     */
    function getCurrentLinkBalance() external view returns (uint256) {
        return LINK.balanceOf(address(this));
    }

    /**
     * @dev External function to withdraw ETH in contract. This function can be called only by owner.
     * @param _amount ETH amount
     */
    function withdrawETH(uint256 _amount) external onlyOwner {
        uint256 balance = address(this).balance;
        require(_amount <= balance, "ChainlinkKeeper: Out of balance");

        payable(msg.sender).transfer(_amount);

        emit EthWithdrew(msg.sender);
    }

    /**
     * @dev External function to withdraw ERC-20 tokens in contract. This function can be called only by owner.
     * @param _tokenAddr Address of ERC-20 token
     * @param _amount ERC-20 token amount
     */
    function withdrawERC20Token(address _tokenAddr, uint256 _amount)
        external
        onlyOwner
    {
        IERC20 token = IERC20(_tokenAddr);

        uint256 balance = token.balanceOf(address(this));
        require(_amount <= balance, "ChainlinkKeeper: Out of balance");

        token.safeTransfer(msg.sender, _amount);

        emit ERC20TokenWithdrew(msg.sender);
    }

    /**
     * @dev Internal function to convert bytes to uint256.
     * @param _bytes value
     * @param _start Start index
     */
    function bytesToUint256(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint256)
    {
        require(
            _bytes.length >= _start + 32,
            "ChainlinkKeeper: toUint256_outOfBounds"
        );
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
}
