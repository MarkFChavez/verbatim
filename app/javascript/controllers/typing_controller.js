import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input", "progress", "loading"]
  static values = {
    passageContent: String,
    passageId: Number,
    nextUrl: String,
    bookUrl: String
  }

  connect() {
    this.typedText = ""
    this.startTime = null
    this.completed = false

    this.renderPassage()
    this.focusInput()

    // Focus input when clicking anywhere in the typing area
    this.element.addEventListener("click", () => this.focusInput())
  }

  renderPassage() {
    const content = this.passageContentValue
    const html = content
      .split("")
      .map((char, i) => {
        if (char === "\n") {
          // Render newline as a visible indicator followed by actual line break
          return `<span data-index="${i}" class="untyped newline-char">↵</span><br>`
        }
        return `<span data-index="${i}" class="untyped">${this.escapeHtml(char)}</span>`
      })
      .join("")

    this.displayTarget.innerHTML = html
    this.charSpans = this.displayTarget.querySelectorAll("span[data-index]")

    // Create caret element (append once, position with CSS)
    this.caret = document.createElement("span")
    this.caret.className = "caret"
    this.displayTarget.appendChild(this.caret)
    this.updateCaretPosition()

    this.updateProgress()
  }

  focusInput() {
    this.inputTarget.focus()
  }

  handleInput(event) {
    if (this.completed) return

    // Start timer on first keystroke
    if (!this.startTime) {
      this.startTime = Date.now()
    }

    this.typedText = this.inputTarget.value
    this.updateDisplay()
    this.updateProgress()

    // Check for completion
    if (this.typedText.length >= this.passageContentValue.length) {
      this.complete()
    }
  }

  handleKeydown(event) {
    // Escape - quit to book page
    if (event.key === "Escape") {
      event.preventDefault()
      window.Turbo.visit(this.bookUrlValue)
      return
    }

    // Tab - restart passage
    if (event.key === "Tab") {
      event.preventDefault()
      this.restart()
      return
    }
  }

  restart() {
    // Reset state
    this.typedText = ""
    this.startTime = null
    this.completed = false

    // Reset UI
    this.inputTarget.value = ""
    this.renderPassage()
    this.focusInput()
  }

  updateDisplay() {
    const typed = this.typedText
    const content = this.passageContentValue

    this.charSpans.forEach((span, i) => {
      span.classList.remove("typed-correct", "typed-incorrect", "untyped")

      if (i < typed.length) {
        if (typed[i] === content[i]) {
          span.classList.add("typed-correct")
        } else {
          span.classList.add("typed-incorrect")
        }
      } else {
        span.classList.add("untyped")
      }
    })

    this.updateCaretPosition()

    // Scroll to keep caret visible
    if (this.caret.parentNode) {
      this.caret.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }

  updateCaretPosition() {
    const position = this.typedText.length

    if (position < this.charSpans.length) {
      const currentSpan = this.charSpans[position]
      const containerRect = this.displayTarget.getBoundingClientRect()
      const spanRect = currentSpan.getBoundingClientRect()

      this.caret.style.left = `${spanRect.left - containerRect.left}px`
      this.caret.style.top = `${spanRect.top - containerRect.top}px`
      this.caret.style.height = `${spanRect.height}px`
    } else if (this.charSpans.length > 0) {
      // At end - position after last character
      const lastSpan = this.charSpans[this.charSpans.length - 1]
      const containerRect = this.displayTarget.getBoundingClientRect()
      const spanRect = lastSpan.getBoundingClientRect()

      this.caret.style.left = `${spanRect.right - containerRect.left}px`
      this.caret.style.top = `${spanRect.top - containerRect.top}px`
      this.caret.style.height = `${spanRect.height}px`
    }
  }

  updateProgress() {
    const progress = (this.typedText.length / this.passageContentValue.length) * 100
    this.progressTarget.style.width = `${progress}%`
  }

  async complete() {
    this.completed = true

    // Show loading indicator
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }

    const durationSeconds = Math.round((Date.now() - this.startTime) / 1000)
    const standardWords = this.typedText.length / 5
    const wpm = Math.round(standardWords / (durationSeconds / 60))

    // Calculate final accuracy from typed text vs content
    const content = this.passageContentValue
    let errors = 0
    for (let i = 0; i < this.typedText.length; i++) {
      if (this.typedText[i] !== content[i]) {
        errors++
      }
    }
    const accuracy = this.typedText.length > 0
      ? ((this.typedText.length - errors) / this.typedText.length) * 100
      : 100

    // Post results to server
    try {
      await fetch(`/passages/${this.passageIdValue}/complete`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({
          typing_session: {
            wpm: wpm,
            accuracy: accuracy.toFixed(2),
            duration_seconds: durationSeconds
          }
        })
      })

      // Brief pause to show completion, then navigate
      setTimeout(() => {
        window.Turbo.visit(this.nextUrlValue)
      }, 500)
    } catch (error) {
      console.error("Error saving session:", error)
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    // Cleanup if needed
  }
}
