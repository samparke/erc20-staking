## ERC-20 Staking Contract

**Allows users to deposit staking token into the contract and earns rewards in the forms of reward tokens.**

## Key functions

**Owner set-up**:

-   **Deploy staking and reward tokens**: DeployToken.s.sol
-   **Deploy staking contract**: Enter Staking and Reward token address into parameters
-   **Interact and set up staking contract**: 'setDuration()' and 'notifyRewardAmount()'

**User interaction**:

-   **Key functions**: stake(), withdraw(), earned(), getRewards()