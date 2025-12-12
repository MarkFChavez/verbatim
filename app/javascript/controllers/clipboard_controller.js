import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static values = { text: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this.showSuccess()
    })
  }

  showSuccess() {
    const icon = this.iconTarget
    const originalHTML = icon.innerHTML

    // Show checkmark
    icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>'
    icon.classList.add("text-emerald-400")

    // Revert after 2 seconds
    setTimeout(() => {
      icon.innerHTML = originalHTML
      icon.classList.remove("text-emerald-400")
    }, 2000)
  }
}
