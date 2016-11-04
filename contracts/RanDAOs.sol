/*
RanDAOs - RanDAO Simple
Copyright (C) 2016  Dung Tran <tad88.dev@gmail.com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
pragma solidity ^0.4.2;

contract RanDAOs{
    uint256 constant MIN_DEPOSIT = 1 ether;
    uint16 constant MIN_POWER = 256;
    uint16 constant MAX_POWER = 2048;
    uint16 constant MIN_DIFFERENCE = 8;
    uint16 constant MAX_DIFFERENCE = 128;
    uint constant MAX_CONRIBUTE = 5;
    uint constant ROUND_LENGTH = 20; 
    
    struct Contribute{
        address Sender;
        bytes32 Key;
        uint16 Power;
        uint16 Difference;
        uint256 Difficulty;
    }
    
    struct Campaign{
        address Creator;
        uint256 StartBlock;
        uint256 Deposit;
        uint256 Seed;
        uint256 Difficulty;
        uint128 Fingerprint;
        uint8 Total;
        uint128 Result;
        mapping (uint => Contribute) Contributes;
    }
    
    mapping  (uint256 => Campaign) StoreCampaigns;

    //Calculate Difficulty
    function _DifficultyCalulate(uint16 Power, uint16 Difference)
    private returns(uint256) {
        return uint256(Power)*(2**128) | (uint256(MAX_DIFFERENCE) - uint256(Difference));
    }
    
    /*
    Check campaign is available
    */
    function IsCampaignAvailable(uint CampaignId)
    public returns(bool){
        return StoreCampaigns[CampaignId].Creator == address(0);
    }
    
    /*
    Create new campaign by giving valid DIFFERENCE and POWER
    */
    function CreateCampaign (uint CampaignId, uint16 Difference, uint16 Power)
    public returns(uint256){
        Campaign memory NewCampaign;
        //Only accept lower than 32 bits difference
        if(Difference > MIN_DIFFERENCE 
            || StoreCampaigns[CampaignId].Creator != address(0)
            || Power < MIN_POWER
            || msg.value < MIN_DEPOSIT){
            throw;
        }else{
            NewCampaign.Creator = msg.sender;
            NewCampaign.StartBlock = block.number;
            NewCampaign.Deposit = msg.value;
            NewCampaign.Seed = uint256(block.blockhash(0));
            NewCampaign.Difficulty = _DifficultyCalulate(Power, Difference);
            NewCampaign.Fingerprint = uint128(NewCampaign.Seed);
            StoreCampaigns[CampaignId] = NewCampaign;
            return CampaignId;
        }
    }
    
    /*
    Submit your contribute, if it wasn't existing then:
    We will add to contribute if total submissions <  MAX_CONRIBUTE
    We will update if it is a better contribute which have greater power and lower difference bits.
    */
    function Submit(uint256 MyCampaign, bytes32 Key, uint16 Power)
    public returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        Contribute memory CurContribute;
        //Make sure that contribute is good power
        if(Power < MIN_POWER
            || Power > MAX_POWER){
            throw;
        }
        bytes32 Buffer = sha3(CurCampaign.Seed, Key);
        for(uint16 Index = 1; Index < Power; Index++){
            Buffer = sha3(Buffer);
        }
        CurContribute.Difference = BitCompare(uint128(Buffer), CurCampaign.Fingerprint);
        CurContribute.Difficulty = _DifficultyCalulate(Power, CurContribute.Difference);

        if(CurContribute.Difficulty <= CurCampaign.Difficulty
            && CurContribute.Difficulty > CurCampaign.Difficulty
            && msg.value >= CurCampaign.Deposit/10){
            
            CurContribute.Sender = msg.sender;
            CurContribute.Key = Key;
            CurContribute.Power = Power;
            CurCampaign.Difficulty = CurContribute.Difficulty;
            //Add gurantee deposit
            CurCampaign.Deposit += msg.value;

            //Update fingerprint for new challenger
            CurCampaign.Seed = uint256(sha3(CurCampaign.Seed, Key));
            CurCampaign.Fingerprint = uint128(CurCampaign.Seed);
            
            if(CurCampaign.Total < MAX_CONRIBUTE){
                return AddContribute(MyCampaign, CurContribute);
            }else{
                return UpdateContribute(MyCampaign, CurContribute);
            }
        }
        throw;
    }
    
    /*
    Get the result if possible
    */
    function GetResult(uint256 MyCampaign)
    returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        if(CurCampaign.Result != 0){
            return CurCampaign.Result;
        }
        throw;
    }
    
    /*
    Reveal the result
    1st 50% prize pool
    2nd 20% prize pool
    3rd 15% prize pool
    4th 10% prize pool
    5th 5% prize pool
    All other contributors lost their deposit
    */
    function Reveal(uint256 MyCampaign)
    returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        uint256 RandomNumber = 0;
        if(CurCampaign.Result == 0){
            throw;
        }
        if(CurCampaign.Creator == msg.sender){
            for(uint Count = CurCampaign.Total; Count < CurCampaign.Total; Count++){
                RandomNumber ^= uint256(CurCampaign.Contributes[Count].Key);
            }
            CurCampaign.Result = uint128(RandomNumber/(2**128)); //Remove 128 bits fingerprint
            return CurCampaign.Result;
        }
    }
    
    /*
    Compare two number and count how many difference bits
    */
    function BitCompare(uint NumberA, uint NumberB)
    private returns(uint16){
        uint Difference = NumberA ^ NumberB;
        uint16 CompareResult = 0;
        while(Difference > 0){
            if(Difference & 1 == 1){
                CompareResult++;  
            }
            Difference = Difference/(2**1); //Shift right 1 bit
        }
        return CompareResult;
    }
    
    /*
    If your contribute is new it will be accept
    */
    function AddContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        CurCampaign.Contributes[CurCampaign.Total] = NewContribute;
        CurCampaign.Total++;
        return true;
    }
    
    /*
    Update old contribute by new one if it better (Have higher DIFFICULTY)
    */
    function UpdateContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        uint256 LowestDifficulty = 0;
        uint8 IndexDifficulty = 0;
        for(uint8 Count = CurCampaign.Total; Count > 0; Count--){
            //Set inital value for LowestDifficulty
            if(Count == CurCampaign.Total){
                LowestDifficulty = CurCampaign.Contributes[Count].Difficulty;
            }
            //Searching for LowestDifficulty index number
            if(LowestDifficulty > CurCampaign.Contributes[Count].Difficulty) {
                LowestDifficulty = CurCampaign.Contributes[Count].Difficulty;
                IndexDifficulty = Count;
            }
        }
        //Update old contribute by higher difficulty
        if(NewContribute.Difficulty > CurCampaign.Contributes[IndexDifficulty].Difficulty){
            CurCampaign.Contributes[IndexDifficulty] = NewContribute;
            return true;
        }
        return false;
    }
}
