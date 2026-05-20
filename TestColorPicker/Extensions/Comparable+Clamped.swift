
extension Comparable {
    /// Constrains the value to `limits`, returning the nearest bound when out of range.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

