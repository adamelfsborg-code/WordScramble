import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "Swing"
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word: ", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Score") {
                    Text("\(score)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.secondary)
                }
                
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Restart", action: startGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() -> Void {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard answer.count > 3 else {
            wordError(title: "Word to short", message: "A minimum of 3 letters required.")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Word not possilbe", message: "Dont be a copycat")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not real", message: "That's not even a word...")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        updateScore()
        
        newWord = ""
    }
    
    func startGame() {
        score = 0
        usedWords = []
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                if let randomWord = allWords.randomElement() {
                    rootWord = randomWord
                    return
                }
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func updateScore() {
        var tempScore = 0
        let points = usedWords.map { $0.count * 2 }
        for point in points {
            tempScore += point
        }
        score = tempScore
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelled.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
