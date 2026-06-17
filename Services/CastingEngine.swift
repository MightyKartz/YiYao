struct CastingEngine {
    private let coinThrowProvider: () -> CoinThrow

    init() {
        self.coinThrowProvider = {
            CoinThrow.random()
        }
    }

    init(_ coinThrowProvider: @escaping () -> CoinThrow) {
        self.coinThrowProvider = coinThrowProvider
    }

    func cast() -> CastingResult {
        cast(from: (0..<6).map { _ in coinThrowProvider() })
    }

    func cast(from coinThrows: [CoinThrow]) -> CastingResult {
        CastingResult(coinThrows: coinThrows)
    }
}
