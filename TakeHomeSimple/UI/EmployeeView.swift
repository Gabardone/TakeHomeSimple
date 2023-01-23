//
//  EmployeeView.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/9/23.
//

import SwiftUI

struct EmployeeView: View {
    /**
     `EmployeeView` initializer

     The initializer takes an employee to display as well as an image cache as a dependency injection. Both
     are immutable once set.
     - Todo: Nicer dependency injection.
     - Parameter employee: The employee that the view will display.
     - Parameter imageCache: The image cache to fetch images from. Defaults to the… default one.
     */
    init(employee: Employee, imageCache: ImageCache = .shared) {
        self.employee = employee
        self.imageCache = imageCache
    }

    let employee: Employee

    private let imageCache: ImageCache

    /**
     The image is loaded asynchronously from a cache and `AsyncImage` only does direct URL downlaods so keeping
     it as a `@State` property allows us to update the UI as it arrives.
     */
    @State
    private var image: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if let thumbnailURL = employee.thumbnailURL {
                        ProgressView()
                            .task {
                                do {
                                    // Setting the image will cause this part of the tree to be rebuilt and
                                    // we'll get the `Image` in place.
                                    image = try await imageCache.fetchImage(imageURL: thumbnailURL).value
                                } catch {
                                    image = UIImage(systemName: "xmark.octagon")
                                }
                            }
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all)
                    }
                }
                .imageScale(.large) // So the placeholder icons don't look terrible.
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                Grid(horizontalSpacing: 4.0, verticalSpacing: 4.0) {
                    EmployeeDataRow(label: "Name:", info: employee.fullName, font: .body)
                    if let phoneNumber = employee.phoneNumber {
                        EmployeeDataRow(label: "Phone:", info: phoneNumber)
                    }
                    EmployeeDataRow(label: "Email:", info: employee.emailAddress)
                    EmployeeDataRow(label: "Team:", info: employee.team)
                    EmployeeDataRow(label: "Type:", info: employee.category.displayName.capitalized)
                }
            }
            if let biography = employee.biography {
                Text(biography)
                    .padding(.top, 1.0)
                    .font(.footnote)
            }
        }
    }

    private struct EmployeeDataRow: View {
        var label: String
        var info: String
        var font: Font = .caption

        var body: some View {
            GridRow {
                Text(label)
                    .gridCellAnchor(.trailing)
                Text(info)
                    .gridCellAnchor(.leading)
            }
            .font(font)
        }
    }
}

struct EmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyURL = URL(string: "https://zombo.com/")!
        let employee = Employee(
            id: UUID(),
            fullName: "John Mastodon",
            phoneNumber: "5551234567",
            emailAddress: "john@mastodon.org",
            biography: "The One and Only, the coolest the strongest the manliest the queerest, the Ballad of John Mastodon",
            thumbnailURL: dummyURL,
            photoURL: dummyURL,
            team: "Super Awesome",
            category: .partTime
        )

        let imageSize = CGSize(width: 256.0, height: 256.0)
        let imageRenderer = UIGraphicsImageRenderer(size: imageSize)
        let image = imageRenderer.image { context in
            UIColor.yellow.setFill()
            context.fill(.init(origin: .zero, size: imageSize))
            UIColor.blue.setFill()
            UIBezierPath(ovalIn: .init(
                x: imageSize.width / 8.0,
                y: imageSize.height / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0)
            ).fill()
            UIBezierPath(ovalIn: .init(
                x: (imageSize.width * 5.0) / 8.0,
                y: (imageSize.height * 5.0) / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0)
            ).fill()
        }

        let imageData = image.pngData()!

        let imageDataProvider = MockImageDataProvider(
            remoteDataOverride: { _ in imageData },
            localDataOverride: { _ in imageData },
            storeLocallyOverride: { _, _ in }
        )

        let imageCache = ImageCache(imageDataProvider: imageDataProvider)
        EmployeeView(employee: employee, imageCache: imageCache)
    }
}
