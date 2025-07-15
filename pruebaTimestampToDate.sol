// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./DateTime.sol";
import "hardhat/console.sol";

//https://github.com/RollaProject/solidity-datetime/blob/master/contracts/TestDateTime.sol

// ----------------------------------------------------------------------------
// DateTime Library v2.0 - Contract Instance
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/DateTime
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------



contract pruebas {

    // https://sepolia.etherscan.io/address/0x5733eE985e22eFF46F595376d79e31413b1A1e16#code
    uint256 public storedTimestamp = 1752613200;

    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    uint256 yearT;
    uint256 monthT;
    uint256 dayT;
    uint256 hourT;
    uint256 minuteT;
    uint256 secondT;

    constructor() {
        
    }

    function Date() public {
    
    (yearT, monthT, dayT, hourT, minuteT, secondT) = timestampToDateTime(storedTimestamp); 

    console.log(" year: ", yearT);
    console.log(" month: ", monthT);
    console.log("day: ", dayT);
    console.log(" hour: ", hourT);
    console.log(" minute: ", minuteT);
    console.log(" second: ", secondT);

    }





    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }

        return (year, month, day);
    }


    function timestampToDateTime(uint256 timestamp)
        internal pure
        returns (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second)
    {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
            uint256 secs = timestamp % SECONDS_PER_DAY;
            hour = secs / SECONDS_PER_HOUR;
            secs = secs % SECONDS_PER_HOUR;
            minute = secs / SECONDS_PER_MINUTE;
            second = secs % SECONDS_PER_MINUTE;
        }

        return (year, month, day, hour, minute, second);
    }

}