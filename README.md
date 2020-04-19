# Chinese Flashcards

CIS 195 Final Project

PennKey: ezwang

A flashcard app to review chinese characters, meanings, and pronunciation.
You are able to create multiple decks, each with their own set of flash cards.
You can view, edit, and delete decks after creating them.
If you enter a chinese character or pronunciation, it looks up the other two attributes and automatically fills them in for you.
Has the ability to create an account, login to an account, and logout.

You can mark a deck as public, which allows anyone to see the deck. There is a tab in the main view to view both your decks and other people's public decks.

There are three separate algorithms that the user can select:
- Random: All of the cards in the deck are shuffled and the user goes through them one time.
- Append: All of the cards in the deck are shuffled. Any card that the user gets wrong is added to the end of the deck.
- Waterfall: All of the cards in the deck are shuffled. For each card that the user gets wrong, place it in a new pile. After the initial pile has been reviewed, move on to the next pile. Repeat this process for the next pile until the user does not get any wrong (no more new piles). Go back through the piles in reverse order until you reach the first pile again, repeating the new pile process if any are wrong.

There is also a settings screen with some options, as well as buttons to delete all created decks and logout of the app.
One of the options allows you to use an offline search method to lookup character/meaning/pronunciations instead of the online method.
This has much worse quality results, but works without internet.
The second option allows you to show the answer after pressing the "No" button instead of going to the next card.

## Components Used

- [CC-CEDICT Dictionary File](https://www.mdbg.net/chinese/dictionary?page=cc-cedict)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Naver Search Endpoint](https://dict.naver.com/linedict/zhendict/dict.html#/cnen/home)
- [SQLite](https://github.com/stephencelis/SQLite.swift)

## Running the Project

- Ensure that you have [CocoaPods](https://cocoapods.org/) installed.
- Clone this repository and run `pod install` in the cloned folder.
- Open the `ChineseFlashcards.xcworkspace` file in XCode (not the `.xcodeproj` file).

## Screenshots

<img src="/images/screenshot1.png?raw=true" width="40%" />
<img src="/images/screenshot2.png?raw=true" width="40%" />
<img src="/images/screenshot3.png?raw=true" width="40%" />
