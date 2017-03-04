import ObjectMapper

class DateTimeTransform: DateFormatterTransform {
    required convenience init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.init(dateFormatter: dateFormatter)
    }
    
    private override init(dateFormatter: DateFormatter) {
        super.init(dateFormatter: dateFormatter)
    }
}
