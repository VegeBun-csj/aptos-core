module aptos_std::bellman_verifier{
    use std::debug;

    native fun bellman_verifier_internal(
        pi_a: vector<u8>,
        pi_b: vector<u8>,
        pi_c: vector<u8>,
        alpha1: vector<u8>,
        beta2: vector<u8>,
        gamma2: vector<u8>,
        delta2: vector<u8>,
        ic: vector<u8>,
    ): bool;

    public fun verifiy(
        pi_a: vector<u8>,
        pi_b: vector<u8>,
        pi_c: vector<u8>,
        alpha1: vector<u8>,
        beta2: vector<u8>,
        gamma2: vector<u8>,
        delta2: vector<u8>,
        ic: vector<u8>,
    ): bool{
        bellman_verifier_internal(pi_a, pi_b, pi_c, alpha1, beta2, gamma2, delta2, ic)
    }


    #[test]
    fun test_verify(){
        let pi_a  = x"16d2176384b0a351f98f97dff72d4f02087dd904bceb7a1c45e8d79a005524b94bab6f870a0adab679f9a62dd0dc30710c23b35735d1fe5f3d6f4e99411101ae5df432ee00afcad631caf51c98a13787c0674f52210e24ed43f595dda9c7ea5b";
        let pi_b  = x"05287e61cfeafeed004d11e02fb7c95f3a1de52641e75840ed581ccc9fb5f08e90f00e3a3eb02bdece58957de09bb79014fa02baa1e6e93f174c0e46f6f3a52469964bd4b08ce68f376ef746daa1bf1f86ba62f9d502d55705fc0103f651738b0a796beee2c509e5357f5cccfbc1afe9974f235bea10038ab0bf8ff011ddcb4327e6ab0f5a533103253deb797837b72314d77da55cb2c82575210e8c269947d625185a2bd67125da4bb4e2fb7dbc3535937c3e91c32af545af2e594d5a990ad5";
        let pi_c  = x"19a691c6029dd4158ac387497c4dc736f98685dca7d2daac383ab37d51568088e03179ba93bab07c37b8c7361ec034030d5713b0656e4f9cc90bf377869f0465f9583dd7616d4001ac1557b324960f6cfb3bc79fb26477a6814af3e3489d61f8";

        let alpha1  = x"180ea8262d7403d01be429229e5c844f7916b1aa85740316c024157600ba4e494b97b78d49e4a54c2797c283c8629dcb184f181e843846e9953021492c87a1a24e63ffe52d6b5082104c10a7b78e13503f76b103985b7140e9e3c15c826f0b69";
        let beta2 = x"0e0b1b43f6248bce0b400e517efa0d4be0028229cca2be54a96f2ad04fcbb3817cddb77b45b4ee2f9dab2ddd9c4df2eb0bcafaf53655ff7b81c9be146fe4d01d904942ddd3e89bbc380aa6ba8f0e8089792d005aa7fdfaabf2284946b020b7e50ceaf841028d71d7c032ad6b976c4247c914d5c1069abe0232dcfd7252c27ca88e06aeac6c82eb2ed76f2f9080a893c6040407e44eabab04202eb52d90ebd75ec6874fb7503245fa6d7b00742703fc806351c69a13e12fa29a1ad81b59e0bfeb";
        let gamma2  = x"13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb80606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801";
        let delta2  = x"0f80795cd306f8cb6a0cf7779d2f43bf310b634a78b78758295c609e4738ba67fd94c2f6c11e9a31bfba4a90061324c4078430d6eb3bf38e742ac276e6693aae377ebd0fb2ad7ce923b0ca9a3e8383b8b11f31a36653b7c5fff05aa87ea633a616574dd0f88875dd2703fbf2902882cf08b8203a842d43d087ea656fbc0d1350a47e06762ff395549c97d6b48c6979310e5a2547b847ba616b54538a95be02b899c0832e4c3d14f250e59df6dd3cdb5850d71c30d08609d216ac197b89dc46e7";
        let ic  = x"098afbaf76b0eea5963922c9ea4785251edd062bbaeff621353e12da4b50c16af076342fbf3cbead0864dd56bc43af8a17376db902f03174544f97e571c3135a0ce495094046ae14775aab05958c1204a600d9f1fee0843758e7341657f776b3074fb94d1fdffc66a0bca0044743e0f36194bf5f1e7729daa889a9d376f79d136c281b909a46e7c3efaaa06ea3c1333a16999490b7db2a8036f6c56e266f96c75d986e6f039cd9b4278fb0b839a4c24db636659c24a4e7380e61b3c89867b0eb";

        debug::print(&pi_a);
        let result = verifiy(
                pi_a,
                pi_b,
                pi_c,
                alpha1,
                beta2,
                gamma2,
                delta2,
                ic,
            );

        debug::print(&ic);
        debug::print(&result);
    }
}