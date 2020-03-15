//
//  LogReminderDetailView.swift
//  Bonsai
//
//  Created by Frank Jia on 2020-03-14.
//  Copyright © 2020 Frank Jia. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    // Full Date & Time
    private static var logReminderDetailDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d, yyyy"
        return dateFormatter
    }
    static func stringForLogReminderDetailDate(from date: Date) -> String {
        return logReminderDetailDateFormatter.string(from: date)
    }
}

struct LogReminderDetailView: View {

    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State(initialValue: false) private var showDeleteReminderConfirmation: Bool
    
    struct ViewModel {
        // Default Log Reminder so we don't have nullables
        private static let EmptyLogReminder: LogReminder = LogReminder(
                id: "",
                reminderDate: Date(),
                reminderInterval: nil,
                templateLoggable: NoteLog(id: "", title: "", dateCreated: Date(),notes: "")
        )
        // State
        let isLoading: Bool
        let showDeleteSuccess: Bool
        let showDeleteError: Bool
        let showErrorView: Bool
        var disableActions: Bool {
            isLoading || showDeleteSuccess || showDeleteError
        }
        var disableDelete: Bool {
            // Don't allow deletes if we're loading or if there is no log reminder
            disableActions || logReminder.id.isEmptyWithoutWhitespace()
        }
        // Log reminder
        let logReminder: LogReminder
        let reminderDate: String
        let reminderInterval: String
        let showReminderInterval: Bool
        let logTitle: String
        let logCategory: String


        init(state: LogReminderDetailState) {
            self.isLoading = state.isDeleting
            self.showDeleteSuccess = state.deleteSuccess
            self.showDeleteError = state.deleteError != nil
            self.showErrorView = state.logReminder == nil
            let logReminder = state.logReminder ?? ViewModel.EmptyLogReminder
            self.logReminder = logReminder
            self.reminderDate = DateFormatter.stringForLogReminderDetailDate(from: logReminder.reminderDate)
            self.logTitle = logReminder.templateLoggable.title
            self.logCategory = logReminder.templateLoggable.category.displayValue()
            if let interval = logReminder.reminderInterval {
                // TODO
                self.showReminderInterval = true
                self.reminderInterval = "\(interval)"
            } else {
                self.showReminderInterval = false
                self.reminderInterval = ""
            }
        }
    }
    private var viewModel: ViewModel { ViewModel(state: store.state.logReminderDetails) }

    // Main View
    var mainBody: some View {
        ScrollView {
            VStack(spacing: CGFloat.Theme.Layout.normal) {
                // Reminder Info
                TitledSection(sectionTitle: "Reminder Details") {
                    VStack(spacing: 0) {
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Reminder Date"),
                                secondaryText: .constant(self.viewModel.reminderDate),
                                hasDisclosureIndicator: false
                            )
                        )
                        if self.viewModel.showReminderInterval {
                            Divider()
                            TappableRowView(
                                viewModel: TappableRowView.ViewModel(
                                    primaryText: .constant("Interval"),
                                    secondaryText: .constant(self.viewModel.reminderInterval),
                                    hasDisclosureIndicator: false
                                )
                            )
                        }
                    }
                }
                // Loggable info
                TitledSection(sectionTitle: "Log Details") {
                    VStack(spacing: 0) {
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Log"),
                                secondaryText: .constant(self.viewModel.logTitle),
                                hasDisclosureIndicator: false
                            )
                        )
                        Divider()
                        TappableRowView(
                            viewModel: TappableRowView.ViewModel(
                                primaryText: .constant("Category"),
                                secondaryText: .constant(self.viewModel.logCategory),
                                hasDisclosureIndicator: false
                            )
                        )
                    }
                }
            }
            .padding(.vertical, CGFloat.Theme.Layout.normal)
        }
        .background(Color.Theme.backgroundPrimary)
    }

    // View with Error View
    var body: some View {
        VStack {
            if viewModel.showErrorView {
                ErrorView()
            } else {
                mainBody
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                // TODO
                print("delete")
            }, label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: CGFloat.Theme.Layout.navBarItemHeight)
                    .foregroundColor(
                        self.viewModel.disableDelete ?
                            Color.Theme.grayscalePrimary : Color.Theme.primary
                    )
            })
            .disabled(self.viewModel.disableDelete)
        )
        .navigationBarTitle("Log Details", displayMode: .inline)
        // Delete Reminder Confirmation
        .alert(isPresented: $showDeleteReminderConfirmation) {
            Alert(
                title: Text("Delete Reminder"),
                message: Text("Are you sure you want to delete this reminder?"),
                primaryButton: .destructive(
                    Text("Confirm"),
                    action: {
                        print("Confirm delete")
                    }),
                secondaryButton: .cancel(
                    Text("Cancel")
                )
            )
        }
    }
}

struct LogReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Valid view
            LogReminderDetailView()
                .environmentObject(PreviewRedux.filledStore)
            // Error view
            LogReminderDetailView()
                .environmentObject(PreviewRedux.initialStore)
        }
        .embedInNavigationView()
    }
}
