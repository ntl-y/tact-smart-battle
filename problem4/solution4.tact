struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}
 
message DeployNewProposal {
    votingEndingAt: Int as uint32;
}
 
contract ProposalMaster {
    nextProp: Int as int32 = 0;
    const minTonRefund: Int = ton("0.01");
    // top up
    receive() {
        // TODO: implement
        if (context().value >= self.minTonRefund) {
            let refundAmount = context().value - self.minTonRefund;
            if (refundAmount > 0) {
                send(SendParameters{
                    to: sender(),
                    bounce: false,
                    value: refundAmount,
                    mode: SendIgnoreErrors
                });
            }
        }
    }
 
    receive(msg: DeployNewProposal) {
        // TODO: implement
        let senderctx: Address = sender();
        if (now() >= msg.votingEndingAt){
            throw(132);
        }
 
        let init: StateInit = initOf Proposal(ProposalInit{master: myAddress(), proposalId: self.nextProp});
        send(SendParameters{
            to: contractAddress(init),
            body: msg.toCell(),
            value: ton("0.01"),              
            mode: SendIgnoreErrors,
            code: init.code,            
            data: init.data
        });
        self.nextProp += 1;   

        send(SendParameters{
            to: senderctx,
            bounce: false,
            value: context().value,
            mode: SendIgnoreErrors,
        });    
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
    val: Int as uint32 = 0;    
    arradr: map<Address, Bool>;
 
 
    init(data: ProposalInit) {
        // TODO: implement
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
        let senderctx: Address = sender();
        if (senderctx != self.ps.master){
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(2025);
        }
        if (self.ps.votingEndingAt != 0) {
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(132);
        }
        self.ps.votingEndingAt = msg.votingEndingAt;
    }
 
    receive(msg: Vote) {
        // TODO: implement
        let senderctx: Address = sender();
        let flag: Bool? = self.arradr.get(senderctx);
        if (flag != null){
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(132);
        }
 
        if (self.ps.votingEndingAt == 0){
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(132);
        }
 
        if (now() >= self.ps.votingEndingAt){
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(132);
        }
        if (self.val >= 100) {
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(132);
        }
        if (msg.value == true){
            self.ps.yesCount += 1;
            self.val += 1;
            self.arradr.set(senderctx, true);
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
        } else if (msg.value == false){
            self.ps.noCount += 1;
            self.val += 1;
            self.arradr.set(senderctx, true);
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
        } else {
            send(SendParameters{
                to: senderctx,
                bounce: false,
                value: context().value,
                mode: SendIgnoreErrors,
            }); 
            throw(134);
        }
    }
 
    get fun proposalState(): ProposalState {
        // TODO: implement
        return self.ps;
    }
}