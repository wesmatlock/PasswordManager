//
//  HomeView.swift
//  SinglePass
//
//  Created by Matlock, Wesley on 7/3/20.
//  Copyright © 2020 Liquidcoder. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
      VStack {
        HeaderView { filter in }
        createList()
      }
    }

  private func createList() -> some View {
    List {
      createPasswordsSection()
      createNotesSection()
    }
    .onAppear {
      UITableView.appearance().backgroundColor = UIColor(named: "bg")
      UITableView.appearance().separatorColor = .clear
      UITableView.appearance().showsVerticalScrollIndicator = false
    }

  }

  private func createPasswordsSection() -> some View {
    Section(header: SectionTitle(title: "Passwords:")) {
      ForEach(1..<5) { i in
        RowItem()
      }
    }
  }

  private func createNotesSection() -> some View {
    Section(header: SectionTitle(title: "Notes")) {
      ForEach(1..<5) { i in
        RowItem()
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
