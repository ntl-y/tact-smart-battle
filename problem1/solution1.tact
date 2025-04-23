//
// Public solution template
//

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
}

struct Init {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    ps: ProposalState;
    arradr: map<Address, Bool>;
    val: Int;
    votingEndingAt: Int as uint32;

    init(data: Init) {
        self.votingEndingAt = data.votingEndingAt;
        self.ps = ProposalState{yesCount: 0, noCount: 0};
        self.val = 0;
        if (now() >= self.votingEndingAt){
            throw(132);
        }
    }

    // deploy
    receive() { }

    receive(msg: Vote) {
        // TODO: implement
        if (now() >= self.votingEndingAt){
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
