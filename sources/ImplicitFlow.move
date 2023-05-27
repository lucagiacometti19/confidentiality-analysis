module 0xCAFE::ImplicitFlow_Marketplace {
    use std::signer;
    use std::vector;
    use std::debug;

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

    //Implicit flow via conditionals

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

    public fun bidWithImplicitFlow(account: &signer, bid: u64) acquires Auction {
        let auction = borrow_global_mut<Auction>(ADMIN);
        if (maxBid(&auction.bids) > bid) {
            debug::print(&200);
        } else {
            debug::print(&400);
        };
        vector::push_back(&mut auction.bids, Bid {bidder: signer::address_of(account), value: bid});
    }

    ///////////////////////////////       TESTS       ///////////////////////////////

    #[test(account = @0xCA11)]
    fun test_bidWithImplicitFlow(account: &signer) acquires Auction {
        //create initial state with empty auction
        move_to<Auction>(account, Auction { bids: vector::empty<Bid>() });
        //place a bid
        bidWithImplicitFlow(account, 55);
        //check that the bid has actually been registered in the auction
        let bids = &borrow_global<Auction>(signer::address_of(account)).bids;
        assert!(vector::contains<Bid>(bids, &Bid {bidder: signer::address_of(account), value: 55}), 0);
        //place one bid lower than before, should print 400
        bidWithImplicitFlow(account, 50);
        //place one bid higher than before, should print 200
        bidWithImplicitFlow(account, 60);
    }
}