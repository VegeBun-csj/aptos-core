#[test-only]
module publisher::verifier_test{
    use std::signer;
    use std::unit_test;
    use std::vector;

    use publisher::counter;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    
}