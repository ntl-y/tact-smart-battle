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
        if (now() >= msg.votingEndingAt){
            throw(132);
        }

        let init: StateInit = initOf Proposal(ProposalInit{master: myAddress(), proposalId: self.nextProp}, msg.votingEndingAt);
        let address: Address = contractAddress(init);
        send(SendParameters{
            to: address,
            value: 0,              
            mode: SendIgnoreErrors,
            code: init.code,                
            data: init.data, 
        });

        self.nextProp += 1;
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
    arradr: map<Address, Bool>;
    val: Int as uint8 = 0;

    init(data: ProposalInit, time: Int) {
        // TODO: implement
        self.ps = ProposalState{
            yesCount: 0,
            noCount: 0,
            master: data.master,
            proposalId: data.proposalId,
            votingEndingAt: v,
        };
    }

    receive(msg: Vote) {
        // TODO: implement
        if (now() >= self.ps.votingEndingAt){
            throw(132);
        }
        if (self.val >= 100) {
            throw(132);
        }

        let senderctx: Address = sender();
        let flag: Bool? = self.arradr.get(senderctx);
        if (flag != null){
            throw(132);
        }

        if (msg.value == true){
            self.ps.yesCount += 1;
        } else if (msg.value == false){
            self.ps.noCount += 1;
        }

        self.arradr.set(senderctx, true);
        self.val += 1;
        send(SendParameters{
            to: senderctx,
            bounce: true,
            value: 0,
            mode: SendRemainingValue,
        });
    }

    get fun proposalState(): ProposalState {
        // TODO: implement
        return self.ps;
    }
}
