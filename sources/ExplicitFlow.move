module 0xCAFE::Marketplace {
    use std::signer;
    use std::vector;

    struct Bid has key, store, drop {
        bidder: address,
        value: u64
    }

    struct Auction has key, store, drop {
        bids: vector<Bid>
    }

    const ADMIN: address = @0xCA11;

    public fun initialize(account: &signer) {
        assert!(signer::address_of(account) == ADMIN, 0);
        move_to<Auction>(account, Auction { bids: vector::empty<Bid>() });
    }

    public fun bid(account: &signer, bid: u64) acquires Auction {
        let auction = borrow_global_mut<Auction>(ADMIN);
        vector::push_back(&mut auction.bids, Bid {bidder: signer::address_of(account), value: bid});
    }

    fun maxBid(vec: &vector<Bid>) : u64 {
        let max = 0;
        let index = 0;
        let len = vector::length<Bid>(vec);
        while (index < len) {
            let currentBid = vector::borrow<Bid>(vec, index);
            if (currentBid.value > max) {
                max = currentBid.value;
            };
            index = index + 1;
        };
        return max
    }

    public fun getHighestBid(): u64 acquires Auction {
        //get the vector of bids from the ADMIN address
        let auction = borrow_global<Auction>(ADMIN);
        return maxBid(&auction.bids)
    }

    ///////////////////////////////       TESTS       ///////////////////////////////

    #[test(account = @0xCA11)]
    fun test_bid(account: &signer) acquires Auction {
        //create initial state with empty auction
        move_to<Auction>(account, Auction { bids: vector::empty<Bid>() });
        //place a bid
        bid(account, 55);
        //check that the bid has actually been registered in the auction
        let bids = &borrow_global<Auction>(signer::address_of(account)).bids;
        assert!(vector::contains<Bid>(bids, &Bid {bidder: signer::address_of(account), value: 55}), 0);
    }

    #[test]
    fun test_maxBid() {
        let vec = vector[Bid { bidder: @0x11, value: 1 }, Bid { bidder: @0x12, value: 55 }, Bid { bidder: @0x13, value: 2 }];
        let max = maxBid(&vec);
        assert!(max == 55, 0);
    }

}