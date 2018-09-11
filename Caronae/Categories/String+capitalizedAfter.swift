extension String {
    func capitalized(after separator: String) -> String {
        var componentes = self.components(separatedBy: separator)
        guard componentes.count > 1 else {
            return self
        }
        
        for index in 1..<componentes.count {
            componentes[index] = componentes[index].capitalized
        }
        return componentes.joined(separator: separator)
    }
}
