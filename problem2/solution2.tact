struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

contract ProposalMaster {
    nextProp: Int as uint32 = 0;
    receive() { }

    receive(msg: DeployNewProposal) {
        if (now() >= msg.votingEndingAt){
            throw(132);
        }
      
        let init: StateInit = initOf Proposal(ProposalInit{master: myAddress(), proposalId: self.nextProp});
        send(SendParameters{
            to: contractAddress(init),
            body: msg.toCell(),
            value: ton("0.05"),              
            mode: SendIgnoreErrors,
            code: init.code,            
            data: init.data
        });
        self.nextProp += 1;
    }

    get fun nextProposalId(): Int {
        return self.nextProp;
    }
}

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
    val: Int as uint32 = 0;    
    arradr: map<Address, Bool>;


    init(data: ProposalInit) {
        if (sender() != data.master){
            throw(2025);
        }
        self.ps = ProposalState{
            yesCount: 0,
            noCount: 0,
            master: data.master,
            proposalId: data.proposalId,
            votingEndingAt: 0,
        };
    }

    receive(msg: DeployNewProposal) {
        if (sender() != self.ps.master){
            throw(2025);
        }
        if (self.ps.votingEndingAt != 0) {
            throw(132);
        }
        self.ps.votingEndingAt = msg.votingEndingAt;
    }

    receive(msg: Vote) {
        let senderctx: Address = sender();
        let flag: Bool? = self.arradr.get(senderctx);
        if (flag != null){
            throw(132);
        }

        if (self.ps.votingEndingAt == 0){
            throw(132);
        }

        if (now() >= self.ps.votingEndingAt){
            throw(132);
        }
        if (self.val >= 100) {
            throw(132);
        }
        if (msg.value == true){
            self.ps.yesCount += 1;
            self.val += 1;
            self.arradr.set(senderctx, true);
        } else if (msg.value == false){
            self.ps.noCount += 1;
            self.val += 1;
            self.arradr.set(senderctx, true);
        } else {
            throw(134);
        }
    }

    get fun proposalState(): ProposalState {
        return self.ps;
    }
}
