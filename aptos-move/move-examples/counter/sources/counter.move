module publisher::counter{

    use std::signer;

    // define a struct about count
    struct Counter has key{
        count: u64
    }

    // we all need `acquires` in definition of functions

    // pay attention to the parameter, which is an address instead of an account 
    // also, you need a return type, which is a u64 in here
    public fun getCount(addr: address): u64 acquires Counter{
        assert!(exists<Counter>(addr), 0);
        *&borrow_global<Counter>(addr).count
    }

    public entry fun setCount(account: signer) acquires Counter{
        let addr = signer::address_of(&account);
        if(!exists<Counter>(addr)){
            // Attention: when the operation is about resources, eg: move. we need to use `account`.count
            // in other case, we use `address`. This is very important.
            move_to(&account, Counter{
                count: 0
            })
        }else{
            let old_count = borrow_global_mut<Counter>(addr);
            old_count.count = old_count.count + 10;
        }
    }

}