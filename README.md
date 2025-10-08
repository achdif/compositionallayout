# MovieDB App

A simple UIKit-based iOS app that displays movies from The Movie Database (TMDb) API using `UICollectionViewCompositionalLayout` and `DiffableDataSource`.

---

## ✨ Features

- Fetches and displays:
  - 🎞️ **Popular Movies** in a horizontally scrolling carousel
  - 📅 **Upcoming Movies** in a vertically scrolling 3-column grid
- Uses **UICollectionViewCompositionalLayout** for flexible layouts
- Smooth updates with **UICollectionViewDiffableDataSource**
- Section headers with titles and pinning behavior
- Loading indicator while fetching movies
- **Clean Architecture** with proper separation of concerns (Data, Domain, Presentation layers)
- **Network Interceptor** for request/response handling and customization
- **Dependency Injection** (coming soon...)
- **Combine + URLSession** for reactive network requests
- Modular and scalable code structure

---

## 🧱 Layout Overview

This app uses a single compositional layout configured via a closure:

### Popular Section (`.popular`)
- **Scroll direction:** Horizontal
- **Item size:** 140pt width × estimated 250pt height
- **Group:** Vertical group with one item per group
- **Usage:** Featured movies carousel

### Upcoming Section (`.upcoming`)
- **Scroll direction:** Vertical
- **Grid:** 3 columns per row
- **Item width:** 1/3 of the screen
- **Item height:** Estimated (~320pt)
- **Usage:** Movie release schedule or future films

---

## 📂 Project Structure

| File                    | Description                                        |
|-------------------------|----------------------------------------------------|
| `ViewController.swift`  | Main controller handling layout, data source, and fetching |
| `MovieCell.swift`       | Custom `UICollectionViewCell` to display movie info |
| `SectionHeaderView.swift` | Reusable header view with title for each section |
| `MovieModel.swift`      | Model representing a movie, conforms to `Hashable` |
| `APIManager.swift`      | Handles TMDb API requests and decoding |

---

## ▶️ How to Run

1. Clone this repo
2. Insert your TMDb API key inside `APIManager.swift`
3. Open the project in Xcode (targeting minimum iOS 13)
4. Run on simulator or real device

---

## 📸 UI Preview

Combined view showing both sections:

- **Popular Movies** at the top (horizontal scroll)
- **Upcoming Movies** below (grid layout)

> UI preview coming soon...

---

## 🔧 Requirements

- iOS 13+
- Swift 5
- No third-party dependencies

---

## 📝 License

MIT License

---

## 🙋‍♂️ Author

Developed by [Your Name] – feel free to reach out for feedback or collaboration!
