pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @title Multicall - Aggregate results from multiple read-only function calls. Allow failures
/// @author Michael Elliot <mike@makerdao.com>
/// @author Joshua Levine <joshua@makerdao.com>
/// @author Nick Johnson <arachnid@notdot.net>
/// @author Bryan Stitt <bryan@satoshiandkin.com>
/// @author Victor Fage <victorfage@gmail.com>


contract Multicall {
    struct Call {
        address target;
        bytes callData;
    }
    struct Result {
        bool success; // If the call was success
        bytes returnData; // Return of the call
    }

    /**
        @notice Returns the size of the auctions array

        @param requireSuccess If true revert if a call fails
                                else, check the success bool before using the returnData.
        @param calls Token to be sold in exchange for `baseToken`

        @return blockNumber The actual block number
        @return returnData Array of Results
    */
    function aggregate(bool requireSuccess, Call[] memory calls) public returns (uint256 blockNumber, Result[] memory returnData) {
        blockNumber = block.number;
        returnData = new Result[](calls.length);

        for(uint256 i = 0; i < calls.length; i++) {
            // we use low level calls to intionally allow calling arbitrary functions.
            // solium-disable-next-line security/no-low-level-calls
            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);

            if (requireSuccess) {
                // TODO: give a more useful message about specifically which call failed
                revert("Multicall aggregate: call failed");
            }

            returnData[i] = Result(success, ret);
        }
    }

    // Helper functions
    function getBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number);
    }
    function getBlockNumber() public view returns (uint256 blockNumber) {
        blockNumber = block.number;
    }
    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }
    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        // solium-disable-next-line security/no-block-members
        timestamp = block.timestamp;
    }
    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }
    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }
}