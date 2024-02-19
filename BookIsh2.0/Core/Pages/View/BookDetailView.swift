//
//  BookDetailView.swift
//  BookIsh2.0
//
//  Created by Hafsa Tazrian on 11/24/23.
//

import SwiftUI
import Firebase

struct BookDetailView: View {
    @State private var isInWishlist = false
    @State private var isInCurrentRead = false
    @State private var isInHaveRead = false
    let book: Book
    
    // Formatter for release date
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust this format to match your JSON
        return formatter
    }()
    
    // Converts string to formatted date
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = BookDetailView.dateFormatter.date(from: dateString) else {
            return "Unknown"
        }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Book cover image
                    AsyncImage(url: book.coverImageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(maxHeight: 150)
                                 .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                 .frame(maxHeight: 150)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Wishlist button
                    Button(action: toggleWishlist) {
                        Image(systemName: isInWishlist ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isInWishlist ? .blue : .gray)
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    Button(action: toggleCurrentRead) {
                        Image(systemName: isInCurrentRead ? "eyeglasses" : "eyeglasses")
                            .foregroundColor(isInCurrentRead ? .blue : .gray)
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    Button(action: toggleHaveRead) {
                        Image(systemName: isInHaveRead ? "checkmark.circle" : "checkmark.circle")
                            .foregroundColor(isInHaveRead ? .blue : .gray)
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                }
                
                // Book title
                Text(book.title)
                    .font(.title)
                    .fontWeight(.bold)

                // Book author
                Text("Author: \(book.author)")
                    .font(.subheadline)
                
                // Book genres
                if let genres = book.genres?.joined(separator: ", ") {
                    Text("Genre: \(genres)")
                        .font(.subheadline)
                }

                // Book average rating
                if let rating = book.averageRating {
                    StarRatingView(rating: rating)
                        .font(.subheadline)
                }
                
                // Book release date
                Text("Release Date: \(formatDate(book.releaseDate))")
                
                // Book description
                Text("Description: \(book.description ?? "No description available.")")
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitle(Text(book.title), displayMode: .inline)
        .onAppear {
            checkWishlistStatus()
            checkCurrentReadStatus()
            checkHaveReadStatus()
        }
    }
    
    // Checks Firebase for the wishlist status of the book
    private func checkWishlistStatus() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            let wishlistRef = Database.database().reference().child("users").child(userID).child("wishlist").child(String(book.id))
            wishlistRef.observeSingleEvent(of: .value, with: { snapshot in
                self.isInWishlist = snapshot.exists()
            })
        }
    private func checkCurrentReadStatus() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            let currentreadRef = Database.database().reference().child("users").child(userID).child("currentread").child(String(book.id))
            currentreadRef.observeSingleEvent(of: .value, with: { snapshot in
                self.isInCurrentRead = snapshot.exists()
            })
        }
    private func checkHaveReadStatus() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            let havereadRef = Database.database().reference().child("users").child(userID).child("haveread").child(String(book.id))
            havereadRef.observeSingleEvent(of: .value, with: { snapshot in
                self.isInHaveRead = snapshot.exists()
            })
        }
    
    // Toggles the wishlist status of the book
    private func toggleWishlist() {
        guard let userID = Auth.auth().currentUser?.uid else {
                    print("User not authenticated")
                    return
                }
                isInWishlist.toggle()
                let wishlistRef = Database.database().reference().child("users").child(userID).child("wishlist").child(String(book.id))
        
        if isInWishlist {
                    // Define bookData with all the details you want to save
                    let bookData: [String: Any] = [
                        "id": book.id,
                        "title": book.title,
                        "author": book.author,
                        "averageRating": book.averageRating as Any,
                        "coverImageURL": book.coverImageURL?.absoluteString as Any,
                        "genres": book.genres as Any,
                        "description": book.description as Any,
                        "releaseDate": formatDate(book.releaseDate) // Storing formatted date as a string
                    ]
                    wishlistRef.setValue(bookData)
                } else {
                    wishlistRef.removeValue()
                }
    }
    private func toggleCurrentRead() {
        guard let userID = Auth.auth().currentUser?.uid else {
                    print("User not authenticated")
                    return
                }
                isInCurrentRead.toggle()
                let currentreadRef = Database.database().reference().child("users").child(userID).child("currentread").child(String(book.id))
        
        if isInCurrentRead {
                    // Define bookData with all the details you want to save
                    let bookData: [String: Any] = [
                        "id": book.id,
                        "title": book.title,
                        "author": book.author,
                        "averageRating": book.averageRating as Any,
                        "coverImageURL": book.coverImageURL?.absoluteString as Any,
                        "genres": book.genres as Any,
                        "description": book.description as Any,
                        "releaseDate": formatDate(book.releaseDate) // Storing formatted date as a string
                    ]
            currentreadRef.setValue(bookData)
                } else {
                    currentreadRef.removeValue()
                }
    }
    private func toggleHaveRead() {
        guard let userID = Auth.auth().currentUser?.uid else {
                    print("User not authenticated")
                    return
                }
                isInCurrentRead.toggle()
                let havereadRef = Database.database().reference().child("users").child(userID).child("haveread").child(String(book.id))
        
        if isInCurrentRead {
                    // Define bookData with all the details you want to save
                    let bookData: [String: Any] = [
                        "id": book.id,
                        "title": book.title,
                        "author": book.author,
                        "averageRating": book.averageRating as Any,
                        "coverImageURL": book.coverImageURL?.absoluteString as Any,
                        "genres": book.genres as Any,
                        "description": book.description as Any,
                        "releaseDate": formatDate(book.releaseDate) // Storing formatted date as a string
                    ]
            havereadRef.setValue(bookData)
                } else {
                    havereadRef.removeValue()
                }
    }
}
