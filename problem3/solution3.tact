struct Init {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
}

message Vote { 
    value: Bool;
}

contract Proposal {
    id: Int as uint32;
    votingEndingAt: Int as uint32;
    yesCount: Int as uint32;
    noCount: Int as uint32;
    voterBitmaps: map<Int as uint16, Int as uint256>;

    init(init: Init) {
        self.id = init.proposalId;
        self.votingEndingAt = init.votingEndingAt;
        self.yesCount = 0;
        self.noCount = 0;
        self.voterBitmaps = emptyMap();
    }

    receive(msg: Vote) {
        require(now() <= self.votingEndingAt, "Voting has ended");
        
        let addrHash = sender().asSlice().hash() % 65536; // 16-bit bucket index
        let bitPos = (sender().asSlice().hash() >> 16) % 256; // 8-bit position in bucket
        
        let maybeBucket = self.voterBitmaps.get(addrHash);
        let bucket: Int = 0;
        if (maybeBucket != null) {
            bucket = maybeBucket;
        } else {
            bucket = 0;
        }

        require((bucket & (1 << bitPos)) == 0, "Already voted");
        
        self.voterBitmaps.set(addrHash, bucket | (1 << bitPos));
        
        if (msg.value) {
            self.yesCount += 1;
        } else {
            self.noCount += 1;
        }
    }

    receive() {
        // Empty receiver for deployment
    }

    get fun proposalState(): ProposalState {
        return ProposalState{
            yesCount: self.yesCount,
            noCount: self.noCount,
        };
    }
}