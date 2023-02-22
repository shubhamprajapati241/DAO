// SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

// To grant access to the people who has that priviledge
import "@openzeppelin/contracts/access/AccessControl.sol"; // For Managing roles : contributor & Proposer 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // to prevent reentrancy attack from the malicious person

contract DAO_EXPAINED is ReentrancyGuard , AccessControl {

    //* 1. Defining the state varible 
    // AccessControl handles roles by storing the role in the hash in the bytes32 format
    bytes32 private immutable CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 private immutable STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");

    // Min staking for the contruibutor
    uint256 immutable MIN_STAKEHOLDER_CONTRIBUTION = 1 ether; // If someoe give > 1 ether =>STAKEHOLDER else CONTRIBUTOR

    // Duration on the proposal voting
    uint32 immutable MIN_VOTE_DURATION = 3 minutes;

    uint32 totalProposals; // total Proposal in the DAO
    uint256 public daoBalance; // total amount of ether stake in the DAO 

    //* 2. Declaring mapping
    // proposalID => Proposal Struct
    mapping(uint256 => ProposalStruct) private raisedProposals; // To store all the raised proposals

    // stakerAddress => proposalID
    mapping(address => uint256[]) private stakeholderVotes; // To store the Stakeholder votes  

     // proposalID => Voted Struct
    mapping(uint256 => VotedStruct[]) private votedOn; // contain all the voting information of that particular proposalID

    // addressContributor => contributorId
    mapping(address => uint256) private contributors; 

     // addressStakeHolder => stakeHolderID
    mapping(address => uint256) private stakeholders;
    
    //* 3. Declaring Struct
    struct ProposalStruct {
        uint256 id; // proposalId
        uint256 amount;
        uint256 duration;
        uint256 upVotes;
        uint256 downVotes;
        string title; // heading
        string description; // details
        bool passed; // passed or failed
        bool paid; // paid or free
        address payable beneficiary; // receive the certain  when the proposal with passed
        // beneficiary => address of the receipt who is intitled to receive certain funds on success of the proposal

        address proposer;
        address executor;
    }

    struct VotedStruct {
        address voter;
        uint256 timestamp; // voting happens within timestamp
        bool chosen; // true => upvote, false => downvote
    }

    //* 4. Defining Events
    event Action (
        address indexed intiator,
        bytes32 role,
        string message,
        address indexed beneficiary,
        uint amount
    );

    //* 5. Defining Modifier

    /*
    * STAKEHOLDER has all the previledges of the CONTRIBUTOR
    * BUT CONTRIBUTOR don't have all the previledges as STAKEHOLDER

    * CONTRIBUTOR is the subset of STAKEHOLDER
    */

    // To restrict access only for the stakeholder
    modifier stakeholderOnly(string memory message) {
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);  // hasRole from AccessControl
        _;
    }

    // To restrict access only for the contriutor
    modifier contributorOnly(string memory message) {
        require(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);
        _;
    }

    //* 6. Defining Functions

    // createProposal => To Create new Proposal for the DAO
    function createProposal
    ( 
        string memory _title, 
        string memory _description,  
        address _beneficiary,
        uint _amount 
    ) external stakeholderOnly("Proposal creation allowed for the stakeholder only") 
    {
        uint32 proposalID = totalProposals++; // post increament so at first it will be 0

        // Initializing the new Proposal with ProposalID
        ProposalStruct storage proposal = raisedProposals[proposalID]; // Instance of proposal struct
        proposal.id = proposalID;
        proposal.proposer = payable(msg.sender);
        proposal.title = _title;
        proposal.description = _description;
        proposal.beneficiary = payable(_beneficiary);
        proposal.amount = _amount;
        proposal.duration = block.timestamp + MIN_VOTE_DURATION;
        emit Action(msg.sender, STAKEHOLDER_ROLE, "PROPOSAL RAISED", _beneficiary, _amount);
    }


    function handleVoting(ProposalStruct storage _proposal) private {

        /*
        * 1. Handling the proposer duration
        * 2. Handling the double voting issue
        */ 

        if(_proposal.passed || _proposal.duration <= block.timestamp) {
            _proposal.passed = true;
            revert("Proposal duration expired");
        }

        //* Initiazing Voting mechanism
        uint[] memory tempVotes = stakeholderVotes[msg.sender];

        // Preventing Doble voting
        for(uint256 votes=0; votes < tempVotes.length; votes++) {
            if(_proposal.id == tempVotes[votes]) {
                revert("Doble voting not allowed");
            }
        }
    }


    function Vote(uint256 _proposalId, bool _chosen) external stakeholderOnly("Unauthorized access: Stakeholders only permitted") returns(VotedStruct memory) {

        // Initializing the new Proposal with ProposalID
        ProposalStruct storage proposal = raisedProposals[_proposalId];

        if(_chosen) proposal.upVotes++; // true => upVote 
        else proposal.downVotes++; // false => downVote

        stakeholderVotes[msg.sender].push(proposal.id);
        votedOn[proposal.id].push(VotedStruct(msg.sender, block.timestamp, _chosen));
        
        emit Action(msg.sender, STAKEHOLDER_ROLE, "PROPOSAL VOTE", proposal.beneficiary, proposal.amount);

        return VotedStruct(
            msg.sender,
            block.timestamp,
            _chosen
        );
    }









}


