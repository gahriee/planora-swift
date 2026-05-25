import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    private var dash: DashboardViewModel { DashboardViewModel(taskVM: taskVM) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(title: "Total",    value: dash.total,    icon: "list.bullet")
                    StatCard(title: "Today",    value: dash.today,    icon: "sun.max")
                    StatCard(title: "This Week",value: dash.thisWeek, icon: "calendar.badge.clock")
                    StatCard(title: "Overdue",  value: dash.overdue,  icon: "exclamationmark.triangle", tint: .red)
                }

                Text("Completion Rate")
                    .font(.headline)
                ProgressView(value: dash.completionRate)
                    .tint(.accentColor)
                Text("\(Int(dash.completionRate * 100))% of \(dash.total) tasks done")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Recent Completions").font(.headline)
                ForEach(dash.recentCompletions) { task in
                    TaskCard(task: task)
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }
}
