//
//  LoadingSpinner.swift
//  HealthTrack
//
//  Created by Frank Jia on 2019-12-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import SwiftUI

// See https://www.blckbirds.com/post/progress-bars-in-swiftui
struct LoadingSpinner: View {

    enum Size {
        case small
        case normal
    }

    @State var degrees = 0.0
    let spinnerColor: Color
    let size: Size
    
    init(size: Size = .normal) {
        self.spinnerColor = Color.Theme.primary
        self.size = size
    }
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.6)
            .stroke(self.spinnerColor, lineWidth: size == .normal ? 5.0 : 2.5)
            .frame(
                    width: size == .normal ? CGFloat.Theme.Misc.spinnerSizeNormal : CGFloat.Theme.Misc.spinnerSizeSmall,
                    height: size == .normal ? CGFloat.Theme.Misc.spinnerSizeNormal : CGFloat.Theme.Misc.spinnerSizeSmall)
            .rotationEffect(Angle(degrees: degrees))
            .onAppear(perform: {self.start()})
    }
    
    func start() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            withAnimation {
                self.degrees += 10.0
            }
            if self.degrees == 360.0 {
                self.degrees = 0.0
            }
        }
    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinner()
    }
}
