pragma solidity ^0.4.20;

import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";
import "./MainCrowdsale.sol";
import "./Checkable.sol";
import "./BonusableCrowdsale.sol";

contract TemplateCrowdsale is usingConsts, MainCrowdsale
    //#if "D_BONUS_TOKENS" != "false"
    , BonusableCrowdsale
    //#endif
    //#if D_SOFT_CAP_WEI != 0
    , RefundableCrowdsale
    //#endif
    , CappedCrowdsale
    //#if "D_AUTO_FINALISE" != "false"
    , Checkable
    //#endif
{
    function TemplateCrowdsale(MintableToken _token)
        Crowdsale(START_TIME > now ? START_TIME : now, D_END_TIME, D_RATE * TOKEN_DECIMAL_MULTIPLIER, D_COLD_WALLET)
        CappedCrowdsale(D_HARD_CAP_WEI)
        //#if D_SOFT_CAP_WEI != 0
        RefundableCrowdsale(D_SOFT_CAP_WEI)
        //#endif
    {
        token = _token;
        transferOwnership(TARGET_USER);
    }

    /**
     * @dev override token creation to set token address in constructor.
     */
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0);
    }

    //#if "D_AUTO_FINALISE" != "false"
    /**
     * @dev Do inner check.
     * @return bool true of accident triggered, false otherwise.
     */
    function internalCheck() internal returns (bool) {
        return !isFinalized && hasEnded();
    }

    /**
     * @dev Do inner action if check was success.
     */
    function internalAction() internal {
        finalization();
        Finalized();

        isFinalized = true;
    }
    //#endif

    //#if "D_MIN_VALUE_WEI" != 0 || "D_MAX_VALUE_WEI" != 0
    /**
     * @dev override purchase validation to add extra value logic.
     * @return true if sended more than minimal value
     */
    function validPurchase() internal view returns (bool) {
        //#if defined(D_MIN_VALUE_WEI)
        bool minValue = msg.value >= D_MIN_VALUE_WEI;
        //#endif
        //#if defined(D_MAX_VALUE_WEI)
        bool maxValue = msg.value <= D_MAX_VALUE_WEI;
        //#endif

        return
        //#if defined(D_MIN_VALUE_WEI)
            minValue &&
        //#endif
        //#if defined(D_MAX_VALUE_WEI)
            maxValue &&
        //#endif
            super.validPurchase();
    }
    //#endif
}
