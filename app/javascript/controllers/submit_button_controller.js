import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    loadingText: String
  }

  submit() {
    if (!this.hasButtonTarget) return

    this.buttonTarget.disabled = true
    this.buttonTarget.dataset.originalText = this.buttonTarget.value
    this.buttonTarget.value = this.loadingTextValue

    this.buttonTarget.classList.add(
      "cursor-not-allowed",
      "opacity-70"
    )
  }

  reset() {
    if (!this.hasButtonTarget) return
    if (!this.buttonTarget.dataset.originalText) return

    this.buttonTarget.disabled = false
    this.buttonTarget.value = this.buttonTarget.dataset.originalText

    this.buttonTarget.classList.remove(
      "cursor-not-allowed",
      "opacity-70"
    )
  }
}