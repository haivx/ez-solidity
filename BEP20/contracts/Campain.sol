// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract CampaignFactory {
    Campaign[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    function getdeployedCampaigns() public view returns(Campaign[] memory) {
        return deployedCampaigns;
    }

    function getContract(address camp) public pure returns(Campaign) {
        return Campaign(camp);
    }

}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool completed;
        uint approvalCount;
    }

    uint private totalContributionValue;
    mapping(uint => mapping(address => bool)) public approved;
    Request[] public requests;

    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public contributors;
    uint public numOfContributors;

    constructor (uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Campaign: You are not the manager");
        _;
    }

    modifier onlyContributors() {
        require(contributors[msg.sender], "Campaign: You are not the contributor");
        _;
    }

    modifier requestIndexExist(uint _requestIndex) {
        require(_requestIndex < requests.length, "Campaign: The request not existed");
        _;
    }
    
    function contribute() public payable {
        require(msg.value > minimumContribution, "Campaign: Your contribution should be more");
        contributors[msg.sender] = true;
        numOfContributors ++;
        totalContributionValue += msg.value;
        
    }

    function getTotalContribution() public view returns(uint) {
        return totalContributionValue;
    }

    function createRequest(string memory _description, uint _value, address _recipient) public onlyManager {
        Request memory newRequest = Request({
            description: _description, 
            value:_value, 
            recipient: _recipient, 
            completed: false,
            approvalCount: 0});
        requests.push(newRequest);
    }

    function approveRequest(uint _requestIndex) public onlyContributors requestIndexExist(_requestIndex) {
        require(approved[_requestIndex][msg.sender] == false, "Campaign: You already approve this request");
        requests[_requestIndex].approvalCount ++;
        approved[_requestIndex][msg.sender] = true;
    }

    function undoAprroval(uint _requestIndex) public onlyContributors requestIndexExist(_requestIndex) {
        require(approved[_requestIndex][msg.sender] == true, "Campaign: You has not aprroved this request");
        requests[_requestIndex].approvalCount --;
        approved[_requestIndex][msg.sender] = false;
    }

    function excuteRequest(uint _requestIndex) public onlyManager requestIndexExist(_requestIndex) {
        require(totalContributionValue >= requests[_requestIndex].value, "Campaign: Not enough contributions");
        require(requests[_requestIndex].approvalCount > numOfContributors/2, "Campaign: Not enough aprrovals" );
        require(requests[_requestIndex].completed == false, "Campaign: The request already executed");
        totalContributionValue -= requests[_requestIndex].value;
        payable(requests[_requestIndex].recipient).transfer(requests[_requestIndex].value);
    }

    function getRequest(uint _requestIndex) public view returns(Request memory) {
        return requests[_requestIndex];
    }

    function getRequestArray() public view returns(Request[] memory) {
        return requests;
    }   
}