import Foundation

protocol NewCategoryViewModelProtocol {
    func setNewNameCategory(text: String)
    func getNewNameCategory() -> String
    
    func setOldNameCategory(text: String)
    func getOldNameCategory() -> String
}

final class NewCategoryViewModel {
    @Observable<String> private(set) var newNameCategory: String = ""
    private var oldNameCategory: String = ""
}

extension NewCategoryViewModel: NewCategoryViewModelProtocol {
    func setOldNameCategory(text: String) {
        oldNameCategory = text
    }
    
    func getOldNameCategory() -> String {
        oldNameCategory
    }
    
    func setNewNameCategory(text: String) {
        newNameCategory = text
    }
    
    func getNewNameCategory() -> String {
        newNameCategory
    }
}
