import Foundation
import SwiftUI

struct AppIcons {
    let OneCircle: Image = Image(systemName: "1.circle")
    let OneCircleFill: Image = Image(systemName: "1.circle.fill")
    let TwoCircle: Image = Image(systemName: "2.circle")
    let TwoCircleFill: Image = Image(systemName: "2.circle.fill")
    let ThreeCircle: Image = Image(systemName: "3.circle")
    let ThreeCircleFill: Image = Image(systemName: "3.circle.fill")
    let ChevronLeft: Image = Image(systemName: "chevron.left")
    let ChevronRight: Image = Image(systemName: "chevron.right")
    let ChevronDown: Image = Image(systemName: "chevron.down")
    let Circle: Image = Image(systemName: "circle")
    let CircleFill: Image = Image(systemName: "circle.fill")
    let CheckmarkCircle: Image = Image(systemName: "checkmark.circle")
    let ChartBar: Image = Image(systemName: "chart.bar")
    let ChartBarFill: Image = Image(systemName: "chart.bar.fill")
    let House: Image = Image(systemName: "house")
    let HouseFill: Image = Image(systemName: "house.fill")
    let InfoCircle: Image = Image(systemName: "info.circle")
    let InfoCircleFill: Image = Image(systemName: "info.circle.fill")
    let XMarkCircle: Image = Image(systemName: "xmark.circle")
    let PersonCropCircle: Image = Image(systemName: "person.crop.circle")
    let PlusCircleFill: Image = Image(systemName: "plus.circle.fill")
    let Trash: Image = Image(systemName: "trash")
}

extension Image {
    static let Icons = AppIcons()
}
