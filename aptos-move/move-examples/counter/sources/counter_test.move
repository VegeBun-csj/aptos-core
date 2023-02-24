#[test_only]
module publisher::counter_tests{
    use std::signer;
    use std::unit_test;
    use std::vector;

    use publisher::counter;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun can_set_count(){
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);

        counter::setCount(account);
        assert!(
            counter::getCount(addr) == 0,
            0
        );

        let account = get_account();
        counter::setCount(account);
        assert!(
            counter::getCount(addr) == 10,
            0
        )
    }
}