//
//  QuoteProvider.swift
//  NudgeNotch
//
//  Motivational quotes for wellbeing.
//

import Foundation

// MARK: - Quote Model

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

// MARK: - Quote Provider

class QuoteProvider {
    static let shared = QuoteProvider()

    private let quotes: [Quote] = [
        Quote(text: "Take care of your body. It's the only place you have to live.", author: "Jim Rohn"),
        Quote(text: "The greatest wealth is health.", author: "Virgil"),
        Quote(text: "Rest when you're weary. Refresh and renew yourself.", author: "Ralph Marston"),
        Quote(text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott"),
        Quote(text: "Your calm mind is the ultimate weapon against your challenges.", author: "Bryant McGill"),
        Quote(text: "Health is not valued until sickness comes.", author: "Thomas Fuller"),
        Quote(text: "A healthy outside starts from the inside.", author: "Robert Urich"),
        Quote(text: "The mind and body are not separate. What affects one, affects the other.", author: "Unknown"),
        Quote(text: "Movement is a medicine for changing a person's physical, emotional, and mental states.", author: "Carol Welch"),
        Quote(text: "Self-care is not selfish. You cannot serve from an empty vessel.", author: "Eleanor Brownn"),
        Quote(text: "Water is the driving force of all nature.", author: "Leonardo da Vinci"),
        Quote(text: "In a gentle way, you can shake the world.", author: "Mahatma Gandhi"),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "Happiness is the highest form of health.", author: "Dalai Lama"),
        Quote(text: "Every step is progress, no matter how small.", author: "Unknown"),
        Quote(text: "You don't have to be extreme, just consistent.", author: "Unknown"),
        Quote(text: "Breathe. Let go. And remind yourself that this very moment is the only one for sure.", author: "Oprah Winfrey"),
        Quote(text: "Strive for progress, not perfection.", author: "Unknown"),
        Quote(text: "Your body hears everything your mind says. Stay positive.", author: "Naomi Judd"),
        Quote(text: "One small positive thought can change your whole day.", author: "Zig Ziglar"),
        Quote(text: "Do something today that your future self will thank you for.", author: "Sean Patrick Flanery"),
        Quote(text: "Wellness is the complete integration of body, mind, and spirit.", author: "Greg Anderson"),
        Quote(text: "The first wealth is health.", author: "Ralph Waldo Emerson"),
        Quote(text: "When you take care of yourself, you're a better person for others.", author: "Solange Knowles"),
        Quote(text: "Inhale confidence, exhale doubt.", author: "Unknown"),
        Quote(text: "Small daily improvements over time lead to stunning results.", author: "Robin Sharma"),
        Quote(text: "Energy and persistence conquer all things.", author: "Benjamin Franklin"),
        Quote(text: "The body achieves what the mind believes.", author: "Napoleon Hill"),
        Quote(text: "Drink water like it's your job today.", author: "Unknown"),
        Quote(text: "A little progress each day adds up to big results.", author: "Satya Nani"),
    ]

    private var lastIndex: Int = -1

    func randomQuote() -> Quote {
        guard quotes.count > 1 else { return quotes.first ?? Quote(text: "Stay healthy!", author: "NudgeNotch") }
        var newIndex: Int
        repeat {
            newIndex = Int.random(in: 0..<quotes.count)
        } while newIndex == lastIndex
        lastIndex = newIndex
        return quotes[newIndex]
    }

    func nextQuote() -> Quote {
        lastIndex = (lastIndex + 1) % quotes.count
        return quotes[lastIndex]
    }
}
