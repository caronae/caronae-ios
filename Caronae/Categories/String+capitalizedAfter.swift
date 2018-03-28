extension String {
    func capitalized(after separator: String) -> String {
        var componentes = self.components(separatedBy: separator)
        guard componentes.count > 1 else {
            return self
        }
        
        for i in 1..<componentes.count {
            componentes[i] = componentes[i].capitalized
        }
        return componentes.joined(separator: separator)
    }
}
