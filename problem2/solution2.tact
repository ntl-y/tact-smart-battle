struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

contract ProposalMaster {
    nextProp: Int as uint8 = 0;
    // deploy
    receive() { }

    receive(msg: DeployNewProposal) {
        // TODO: implement
        dump("ProposalMaster: DeployNewProposal received");
        if (now() >= msg.votingEndingAt){
            dump("ProposalMaster: deadline passed, throwing");
            throw(132);
        }

        let init: StateInit = initOf Proposal(ProposalInit{master: myAddress(), proposalId: self.nextProp});
        let address: Address = contractAddress(init);

        dump("ProposalMaster: deploying Proposal");
        
        deploy(DeployParameters{
            init: init,
            value: 0,              
            mode: SendIgnoreErrors,
        });

        message(MessageParameters   {
            to: address,
            value: 0,              
            mode: SendIgnoreErrors,
            body: msg.toCell(),
        });

        dump("ProposalMaster: Proposal deployed");

        self.nextProp += 1;
        dump("ProposalMaster: nextProp incremented");
    }

    get fun nextProposalId(): Int {
        // TODO: implement
        return self.nextProp;
    }
}

// ==============================================================================

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
    master: Address;
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    ps: ProposalState;
    val: Int as uint8 = 0;

    init(data: ProposalInit) {
        // TODO: implement
        dump("Proposal: initing");
        self.ps = ProposalState{
            yesCount: 0,
            noCount: 0,
            master: data.master,
            proposalId: data.proposalId,
            votingEndingAt: 0,
        };
        dump("Proposal: inited");
    }

    receive(msg: DeployNewProposal) {
        dump("Proposal: DeployNewProposal received");
        if (sender() != self.ps.master) {
            dump("Proposal: invalid sender, throwing 2025");
            throw(2025); 
        }

        if (self.ps.votingEndingAt != 0) {
            dump("Proposal: already initialized, throwing 132");
            throw(132);
        }

        dump("Setting votingEndingAt");
        self.ps.votingEndingAt = msg.votingEndingAt;
        dump("VotingEndingAt setted");
    }

    receive(msg: Vote) {
        // TODO: implement
        dump("Proposal: Vote received");
        dump(msg.value);

        if (self.ps.votingEndingAt == 0){
            dump("Proposal: votingEndingAt not set, throwing 132");
            throw(132);
        }

        if (now() >= self.ps.votingEndingAt){
            dump("Proposal: voting closed, throwing 132");
            throw(132);
        }
        if (self.val >= 100) {
            dump("Proposal: vote limit reached, throwing 132");
            throw(132);
        }

        if (msg.value == true){
            self.ps.yesCount += 1;
            self.val += 1;
            dump("Proposal: counted YES vote");
        } else if (msg.value == false){
            self.ps.noCount += 1;
            self.val += 1;
            dump("Proposal: counted NO vote");
        }
    }

    get fun proposalState(): ProposalState {
        // TODO: implement
        return self.ps;
    }
}
