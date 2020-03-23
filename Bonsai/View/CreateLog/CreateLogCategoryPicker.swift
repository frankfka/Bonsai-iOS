import SwiftUI

struct CreateLogCategoryPicker: View {
    
    struct ViewModel {
        let categories: [String]
        let didTapView: VoidCallback
        @Binding var selectedCategory: Int
        @Binding var selectedCategoryString: String
        @Binding var showPicker: Bool
        
        init(
            categories: [String],
            selectedCategory: Int,
            selectedCategoryDidChange: @escaping IntCallback,
            showPicker: Binding<Bool>
        ) {
            
            self.categories = categories
            self._selectedCategory = Binding<Int>(get: {
                return selectedCategory
            }, set: { newVal in
                if newVal != selectedCategory {
                    selectedCategoryDidChange(newVal)
                }
            })
            self._selectedCategoryString = Binding<String>(get: {
                return categories[selectedCategory]
            }, set: { _ in })
            self._showPicker = showPicker
            self.didTapView = {
                ViewHelpers.toggleWithAnimation(binding: showPicker)
            }
        }
    }
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TappableRowView(viewModel: TappableRowView.ViewModel(
                primaryText: .constant("Category"),
                secondaryText: viewModel.$selectedCategoryString,
                hasDisclosureIndicator: false)
            )
                .onTapGesture {
                    self.onRowTapped()
            }
            if self.viewModel.showPicker {
                Picker(
                    selection: viewModel.$selectedCategory,
                    label: Text("")
                ) {
                    ForEach(0 ..< self.viewModel.categories.count) {
                        Text(self.viewModel.categories[$0])
                            .tag($0)
                            .font(Font.Theme.normalText)
                            .foregroundColor(Color.Theme.textDark)
                    }
                }
                .labelsHidden()
                .padding(CGFloat.Theme.Layout.small)
            }
        }
        .background(Color.Theme.backgroundSecondary)
    }
    
    func onRowTapped() {
        ViewHelpers.toggleWithAnimation(binding: viewModel.$showPicker)
    }
    
}

struct CreateLogCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CreateLogCategoryPicker(
            viewModel: CreateLogCategoryPicker.ViewModel(
                categories: LogCategory.allCases.map{ $0.displayValue() },
                selectedCategory: 0,
                selectedCategoryDidChange: { _ in },
                showPicker: .constant(true)
            )
        )
            .previewLayout(.sizeThatFits)
        //            .environment(\.colorScheme, .dark)
    }
}
