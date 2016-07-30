/*
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
import "TheDivine.sol";

contract RanDAOs{
    
    uint constant MIN_POW = 2;
    uint constant MAX_POW = 541;
    uint constant MIN_DIFF = 32;
    uint constant MAX_CONRIBUTE = 6;
    uint constant ROUND_LENGTH = 50; 
    
    struct Contribute{
        address Sender;
        bytes32 Key;
        uint16 Pow;
        uint16 Diff;
    }
    
    struct Campaign{
        address Creator;
        uint256 StartBlock;
        uint256 Deposit;
        uint256 Seed;
        uint16 Pow;
        uint64 Lock;
        uint16 Diff; //Lower difference higher difficulty
        uint8 Total;
        uint192 Result;
        mapping (uint => Contribute) Contributes;
        mapping (bytes32 => bool) Contributed;
    }
    
    TheDivine Divine;
    
    mapping  (uint256 => Campaign) StoreCampaigns;
    
    function IsCampaignAvailable(uint CampaignId)
    returns(bool){
        return StoreCampaigns[CampaignId].Creator == address(0);
    }
    
    function CreateCampaign (uint CampaignId, uint16 Diff)
    returns(uint256){
        Campaign memory NewCampaign;
        //Only accept lower than 32 bits difference
        if(Diff > MIN_DIFF || StoreCampaigns[CampaignId].Creator != address(0)){
            throw;
        }else{
            NewCampaign.Creator = msg.sender;
            NewCampaign.StartBlock = block.number;
            NewCampaign.Deposit = msg.value;
            NewCampaign.Seed = Divine.GetPower();
            NewCampaign.Lock = uint64(NewCampaign.Seed);
            NewCampaign.Pow = 0;
            NewCampaign.Diff = Diff;
            StoreCampaigns[CampaignId] = NewCampaign;
            return CampaignId;
        }
    }
    
    function Submit(uint256 MyCampaign, bytes32 Key, uint16 Pow)
    public returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        Contribute memory CurContribute;
        if(Pow < MIN_POW || Pow > MAX_POW){
            throw;
        }
        bytes32 Buffer = sha3(CurCampaign.Seed, Key);
        for(uint16 Index = 1; Index < Pow; Index++){
            Buffer = sha3(Buffer);
        }
        CurContribute.Diff = BitCompare(uint64(Buffer), CurCampaign.Lock);
        if(CurContribute.Diff  <= CurCampaign.Diff){
            CurContribute.Sender = msg.sender;
            CurContribute.Key = Key;
            CurContribute.Pow = Pow;
            if(CurCampaign.Total < MAX_CONRIBUTE){
                return AddContribute(MyCampaign, CurContribute);
            }else{
                return UpdateContribute(MyCampaign, CurContribute);
            }
        }
        throw;
    }
    
    function GetResult(uint256 MyCampaign)
    returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        if(CurCampaign.Result != 0){
            return CurCampaign.Result;
        }
        throw;
    }
    
    function Reveal(uint256 MyCampaign)
    returns(uint192){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        uint256 RandomNumber = Divine.GetPower();
        if(CurCampaign.Result == 0){
            throw;
        }
        if(CurCampaign.Creator == msg.sender){
            for(uint Count = CurCampaign.Total; Count < CurCampaign.Total; Count++){
                RandomNumber ^= uint256(CurCampaign.Contributes[Count].Key);
            }
            CurCampaign.Result = RandomNumber/(2**64); //Remove 64 bits fingerprint
            return CurCampaign.Result;
        }
    }
    
    function BitCompare(uint NumberA, uint NumberB)
    private returns(uint16){
        uint Diff = NumberA ^ NumberB;
        uint16 CompareResult = 0;
        while(Diff > 0){
            if(Diff & 1 == 1){
                CompareResult++;  
            }
            Diff = Diff/(2**1); //Shift right 1 bit
        }
        return CompareResult;
    }
    
    function AddContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        if(CurCampaign.Contributed[NewContribute.Key] == false){
            CurCampaign.Contributes[CurCampaign.Total] = NewContribute;
            CurCampaign.Total++;
            CurCampaign.Contributed[NewContribute.Key] = true;
            return true;
        }
        return false;
    }
    
    function UpdateContribute(uint256 MyCampaign, Contribute NewContribute)
    internal returns(bool){
        Campaign CurCampaign = StoreCampaigns[MyCampaign];
        if(CurCampaign.Contributed[NewContribute.Key] == false){
            for(uint Count = CurCampaign.Total; Count < CurCampaign.Total; Count++){
                if(CurCampaign.Contributes[Count].Diff > NewContribute.Diff
                    || (CurCampaign.Contributes[Count].Diff == NewContribute.Diff
                        && CurCampaign.Contributes[Count].Pow < NewContribute.Pow)){
                    CurCampaign.Contributes[Count] = NewContribute;
                    CurCampaign.Contributed[NewContribute.Key] = true;
                    return true;                    
                }
            }            
        }
        return false;
    }
}