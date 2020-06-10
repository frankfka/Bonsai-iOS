import SwiftUI

struct RoundedBorderTitledSection<Content>: View where Content: View {

    let sectionTitle: String
    let sectionView: () -> Content

    init(sectionTitle: String, sectionView: @escaping () -> Content) {
        self.sectionView = sectionView
        self.sectionTitle = sectionTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: sectionTitle)
                    .padding(.leading, CGFloat.Theme.Layout.Small)
            sectionView()
                .frame(minWidth: 0, maxWidth: .infinity)
                .modifier(RoundedBorderSectionModifier())
        }
    }
}

struct TitledSection<Content>: View where Content: View {
    let sectionTitle: String
    let sectionView: () -> Content

    init(sectionTitle: String, sectionView: @escaping () -> Content) {
        self.sectionView = sectionView
        self.sectionTitle = sectionTitle
    }

    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(text: sectionTitle)
                    .padding(.leading, CGFloat.Theme.Layout.Normal)
            sectionView()
                    .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

struct SectionTitle: View {
    let titleText: String
    init(text: String) {
        titleText = text
    }
    var body: some View {
        Text(titleText)
            .font(Font.Theme.Heading)
            .foregroundColor(Color.Theme.Text)
            .padding(.vertical, CGFloat.Theme.Layout.Small)
    }
}

struct SectionViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoundedBorderTitledSection(sectionTitle: "Test Title") {
                Text("Test")
            }
        }
        .background(Color.Theme.BackgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}
